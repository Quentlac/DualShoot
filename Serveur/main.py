import socket
import select
import time
import os
import json

class Joueur:
	x = 0
	y = 0

	vie = 100

	angle = 0

	equipe = 1


	def supprVie(self,valeur):
		self.vie = self.vie - valeur

	def getVie(self):
		return self.vie

	def setPosition(self,setX,setY):
		self.x = setX
		self.y = setY

	def moveToRight(self,speed):
		self.x = self.x + speed	

	def moveToLeft(self,speed):
		self.x = self.x - speed	

	def moveToUp(self,speed):
		self.y = self.y - speed	

	def moveToDown(self,speed):
		self.y = self.y + speed

	def getPosX(self):
		return self.x

	def getPosY(self):
		return self.y

	def setAngle(self,nA):
		self.angle = nA

	def getAngle(self):
		return self.angle


#Initialisation du Serveur
main_socket = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
main_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
main_socket.bind(('',222))
main_socket.listen(5)

print("Serveur pret!!!")





#Definition des variables

liste_client = []

nb_joueur = 0

joueur = []



while True:
	#on test si un nouveau joueur veux se connecter
	news_client, a, b = select.select([main_socket],[],[],0.1)

	for client in news_client:
		#On accepte tous les nouveaux joueurs
		socket_client, info = client.accept()
		
		#On ajoute le joueur dans la liste des clients
		liste_client.append(socket_client)

		print("Nouveau client connecte")

		#on cree le joueur
		
		player = Joueur()

		player.setPosition(0,0)

		joueur.append(player)

		nb_joueur = nb_joueur + 1

	#on envoi toutes les infos au joueurs
	id_joueur = 0
	for client in liste_client:
		message = "{"
		message = message + "ID:" + str(id_joueur)+","

		message = message + "X:" + str(joueur[id_joueur].getPosX())+","
		message = message + "Y:" + str(joueur[id_joueur].getPosY())+","

		#la position de chaque joueur
		message = message + "pX:[";
		for loop in range(nb_joueur):
			#On affiche que les joueurs en vie(non deco) et 
			#ceux qui sont dans le champ de vision
			if(joueur[loop].getVie() > 0 and abs(joueur[loop].getPosX() - joueur[id_joueur].getPosX()) < 400 and abs(joueur[loop].getPosY() - joueur[id_joueur].getPosY()) < 400):
				message = message + str(joueur[loop].getPosX()) + ",";

		message = message + "],"

		message = message + "pY:[";
		for loop in range(nb_joueur):
			if(joueur[loop].getVie() > 0 and abs(joueur[loop].getPosX() - joueur[id_joueur].getPosX()) < 400 and abs(joueur[loop].getPosY() - joueur[id_joueur].getPosY()) < 400):
				message = message + str(joueur[loop].getPosY()) + ",";

		message = message + "],"

		#On envoi aussi les angles des joueurs

		message = message + "pAngle:[";
		for loop in range(nb_joueur):
			message = message + str(joueur[loop].getAngle()) + ",";

		message = message + "],"

		message = message + "}"

		try:
			#si client est = a 0 cela signifie que le client est parti (voir un plus bas)
			if(client != 0):
				client.send(message)
		except socket.error:
			print("Client("+str(id_joueur)+") est parti")
			liste_client[id_joueur] = 0
			joueur[id_joueur].supprVie(100)

		id_joueur += 1

	#maintenant apres avoir donne des "ordres" au client on va l'ecouter

	#d'abord on liste tous les client qui nous ont envoye quelques chose

	client_send_msg, a, b = select.select(liste_client,[],[],0)

	for client in client_send_msg:
		message_valide = 1
		
		message = client.recv(1024)

		#On doit traiter le message qui normalement est du JSON si tous va bien.

		try:
			json_msg = json.loads(message)
		except ValueError:
			message_valide = 0

		if(message_valide == 1):
			id_client = json_msg['ID']

			#on cree une variable vitesse pour pouvoir changer plus rapidement
			vitesse = 10


			cmd = json_msg['cmd']

			if(cmd.find("RIGHT") != -1):
				joueur[id_client].moveToRight(vitesse)

			if(cmd.find("LEFT") != -1):
				joueur[id_client].moveToLeft(vitesse)
			
			if(cmd.find("UP") != -1):
				joueur[id_client].moveToUp(vitesse)

			if(cmd.find("DOWN") != -1):
				joueur[id_client].moveToDown(vitesse)
			
			
			

			
			

	
	
	
