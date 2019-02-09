<?php

	$pseudo = $_POST['pseudo'];
	$mail = $_POST['mail'];

	$bdd = new PDO('mysql:host=localhost;dbname=quentin0;charset=utf8', 'quentin', '24aAj68I7YTklaA423');

	$req_prep = $bdd->prepare("INSERT INTO BetaDualShoot(pseudo,mail) VALUES(:pseudo,:mail)");

	$req_prep->execute(array(

    		'pseudo' => $pseudo,
		'mail' => $mail
	

    	));

	header("Location: merci.htm")




?>
