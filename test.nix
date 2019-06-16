{ ... }:

{
  name = "golden-book-test";

  nodes.server = ./server.nix;

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
