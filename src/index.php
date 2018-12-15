<?php
/*
Things missing for a production application:
 - Sensible database credentials
 - Handle database errors
 - Use a framework
*/
$db = new PDO('mysql:dbname=goldenbook;', 'goldenuser');
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $ins = $db->prepare('INSERT INTO entries (text) VALUES (?);');
    $ins->execute([$_POST['text']]);
    echo('Thanks for your post!');
} else if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Plain text is a good format.
    header('Content-Type: text/plain;charset=utf8');
    $entries = $db->query('SELECT (text) FROM entries;');
    while ($text = $entries->fetchColumn()) {
        echo("$text\n\n");
    }
} else {
    http_response_code(405);
    echo('Method not allowed');
}
