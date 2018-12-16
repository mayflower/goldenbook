{ ... }:

{
  name = "golden-book-test";

  nodes.server = { pkgs, ... }: {
    services.mysql = {
      enable = true;
      package = pkgs.mariadb;
      initialDatabases = [
        { name = "goldenbook";
          schema = pkgs.writeText "init.sql" ''
            CREATE TABLE entries (text TEXT);
          '';
        }
      ];
      ensureUsers = [
        { name = "goldenuser";
          ensurePermissions = {
            "goldenbook.*" = "ALL PRIVILEGES";
          };
        }
      ];
    };

    users.extraUsers.goldenuser.isSystemUser = true;

    services.phpfpm = {
      poolConfigs."golden-book" = ''
        listen = /run/phpfpm/golden-book
        listen.group = nginx
        user = goldenuser
        group = nogroup
        pm = static
        pm.max_children = 1
      '';
    };

    services.nginx = {
      enable = true;
      virtualHosts."_" = {
        root = ./src;
        locations = {
          "/".index = "index.php";
          "~ \\.php$" = {
            tryFiles = "$uri =404";
            extraConfig = ''
              fastcgi_pass unix:/run/phpfpm/golden-book;
            '';
          };
        };
      };
    };
  };

  testScript = ''
    startAll;
    # Wait for all services to finish starting
    $server->waitForUnit("multi-user.target");
    # Server should start out with no posts in the database and return an empty but successful response at first
    $server->succeed('[ -z "$(curl --fail localhost)" ]');
    # Making a post should succeed and the server should respond politely
    $server->succeed("curl --fail -F text=testpost localhost | grep Thanks");
    # And after that, the post should be displayed on the main page.
    $server->succeed("curl --fail localhost | grep testpost");
  '';
}
