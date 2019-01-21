import socket
import select
import time
import os
import json
from math import *

class Joueur:
	x = 0
	y = 0

	vie = 100

	angle = 0

	equipe = 1

	#Cette variable permet de dire au client si le joueur marche ou tir afin d'adapter les animations
	#0=fixe 1=marche 2=tir 3=marche+tir
	status = 0

	#cette variable permet de reguler le nombre de balle tire.
	cadence_tir = 0


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

	def setStatus(self,nS):
		self.status = nS

	def getStatus(self):
		return self.status

	def setCadTir(self,valeur):
		self.cadence_tir = valeur

	def getCadTir(self):
		return self.cadence_tir

class Arbre:
	x = 0
	y = 0

	pv = 100

	def setPosition(self,setX,setY):
		self.x = setX
		self.y = setY

	def getPosX(self):
		return self.x

	def getPosY(self):
		return self.y

class Balle:
	#Variable qui contient la position de depart des balles
	x_dep = 0
	y_dep = 0


	dist = 15
	direc = 0

	id_joueur = 0


	def init(self,id_j,direction,x,y):
		self.id_joueur = id_j
		self.direc = direction
		self.depX = x
		self.depY = y

	def move(self,speed):
		self.dist = self.dist + speed

	def getDist(self):
		return self.dist

	def getDirec(self):
		return self.direc

	def getPosX(self):
		return int(sin(radians(90-self.direc))*self.dist)+self.depX

	def getPosY(self):
		return int(cos(radians(90-self.direc))*self.dist)+self.depY

	def getIdJoueur(self):
		return self.id_joueur


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

arbre = []
balle = []

#fond de la map(herbe,sable,eau...)
map_game = []


#on charge la map
filemap = open("map", "r")
filemapjson = filemap.read()

mapJson = json.loads(filemapjson)

for loop in range(10000):
	map_game.append(mapJson["map"][loop])

#arbre
for loop in range(len(mapJson["arbreX"])):
	arbretmp = Arbre()
	arbretmp.setPosition(mapJson["arbreX"][loop],mapJson["arbreY"][loop])

	arbre.append(arbretmp)



#on definis une fonction capable de detecter une eventuel colision entre deux elements.
def detectColision(x, y, pers):
	#Colision entre le joueur et les arbres
	
	#on prend chaque arbre un par un
	for loop2 in range(len(arbre)):
		#on considere un arbre comme un cercle, il va donc falloir calculer la distance entre le joueur et l'arbre		
		
		#pythagore
		#les -35 permettent de specifier le centre de l'arbre pas l'angle
		distance = sqrt(abs(x - arbre[loop2].getPosX()-35)*abs(x - arbre[loop2].getPosX()-35)+abs(y - arbre[loop2].getPosY()-35)*abs(y - arbre[loop2].getPosY()-35))
		if(distance < 35):
			return 1

	#On calcule la colision entre les personnages
	for loop2 in range(nb_joueur):
		#On ne vas pas detecter une colision avec le joueur lui meme!!
		if(pers != loop2):
			#On test aussi que le pers est encore en vie/connecte
			if(joueur[loop2].getVie() > 0):
				distance = sqrt(abs(x - joueur[loop2].getPosX())*abs(x - joueur[loop2].getPosX())+abs(y - joueur[loop2].getPosY())*abs(y - joueur[loop2].getPosY()))

				if(distance < 30):
					return 1	

	#On calcule maintenant les collisions avec les limites de la map:
	if(x >= 6000 or x < 0 or y >= 6000 or y < 0):
		return 1
	


message_tchat = "-"


while True:
	#on test si un nouveau joueur veux se connecter
	news_client, a, b = select.select([main_socket],[],[],0.1)

	for client in news_client:
		#On accepte tous les nouveaux joueurs
		socket_client, info = client.accept()
		
		#On ajoute le joueur dans la liste des clients
		liste_client.append(socket_client)

		print("Nouveau client connecte")
		message_tchat = "Nouvelle pers connect! ("+str(nb_joueur)+")"

		#on cree le joueur
		
		player = Joueur()

		player.setPosition(0,0)

		joueur.append(player)

		nb_joueur = nb_joueur + 1

	#on envoi toutes les infos aux joueurs
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
				if(id_joueur != loop):				
					message = message + str(joueur[loop].getPosX()) + ",";

		message = message + "],"

		message = message + "pY:[";
		for loop in range(nb_joueur):
			if(joueur[loop].getVie() > 0 and abs(joueur[loop].getPosX() - joueur[id_joueur].getPosX()) < 400 and abs(joueur[loop].getPosY() - joueur[id_joueur].getPosY()) < 400):
				if(id_joueur != loop):				
					message = message + str(joueur[loop].getPosY()) + ",";

		message = message + "],"

		#On envoi aussi les angles des joueurs

		message = message + "pAngle:[";
		for loop in range(nb_joueur):
			if(joueur[loop].getVie() > 0 and abs(joueur[loop].getPosX() - joueur[id_joueur].getPosX()) < 400 and abs(joueur[loop].getPosY() - joueur[id_joueur].getPosY()) < 400):
				if(id_joueur != loop):				
					message = message + str(joueur[loop].getAngle()) + ",";

		message = message + "],"

		#On envoi le status des joueurs:
		message = message + "pStatus:[";
		for loop in range(nb_joueur):
			if(joueur[loop].getVie() > 0 and abs(joueur[loop].getPosX() - joueur[id_joueur].getPosX()) < 400 and abs(joueur[loop].getPosY() - joueur[id_joueur].getPosY()) < 400):
				if(id_joueur != loop):				
					message = message + str(joueur[loop].getStatus()) + ",";

		message = message + "],"

		#On envoi maintenant la position des balles
		message = message + "bX:[";
		for loop in range(len(balle)):
			#celles qui sont dans le champ de vision
			if(abs(balle[loop].getPosX() - joueur[id_joueur].getPosX()) < 400 and abs(balle[loop].getPosY() - joueur[id_joueur].getPosY()) < 400):
				message = message + str(balle[loop].getPosX()) + ",";

		message = message + "],"

		message = message + "bY:[";
		for loop in range(len(balle)):
			if(abs(balle[loop].getPosX() - joueur[id_joueur].getPosX()) < 400 and abs(balle[loop].getPosY() - joueur[id_joueur].getPosY()) < 400):
				message = message + str(balle[loop].getPosY()) + ",";

		message = message + "],"

		message = message + "tchat: \""

		#On envoi le tchat si il y a un msg a envoye:
		if(message_tchat != "-"):
			message = message + message_tchat
			message_tchat = "-"
		else:
			#le - signifie rien pour le client
			message = message + "-"	

		message = message + "\""	

		message = message + "}"

		try:
			#si client est = a 0 cela signifie que le client est parti (voir un plus bas)
			if(client != 0):
				client.send(message)
		except socket.error:
			print("Client("+str(id_joueur)+") est parti")
			message_tchat = "Une pers est partie! ("+str(id_joueur)+")"

			liste_client[id_joueur] = 0
			joueur[id_joueur].supprVie(100)

		id_joueur += 1

	#maintenant apres avoir donne des "ordres" au client on va l'ecouter

	#d'abord on liste tous les client qui nous ont envoye quelques chose

	client_send_msg, a, b = select.select(liste_client,[],[],0)

	for client in client_send_msg:
		message_valide = 1
		
		message = client.recv(1024)

		#print(message)

		#On doit traiter le message qui normalement est du JSON si tous va bien.

		try:
			json_msg = json.loads(message)
		except ValueError:
			message_valide = 0

		if(message_valide == 1):
			id_client = json_msg['ID']

			joueur[id_client].setAngle(json_msg['ang'])

			#on cree une variable vitesse pour pouvoir changer plus rapidement
			vitesse = 10


			cmd = json_msg['cmd']

			if(cmd.find("RIGHT") != -1):
				if(detectColision(joueur[id_client].getPosX()+vitesse,joueur[id_client].getPosY(),id_client) != 1):
					joueur[id_client].moveToRight(vitesse)

			if(cmd.find("LEFT") != -1):
				if(detectColision(joueur[id_client].getPosX()-vitesse,joueur[id_client].getPosY(),id_client) != 1):
					joueur[id_client].moveToLeft(vitesse)
			
			if(cmd.find("UP") != -1):
				if(detectColision(joueur[id_client].getPosX(),joueur[id_client].getPosY()-vitesse,id_client) != 1):
					joueur[id_client].moveToUp(vitesse)

			if(cmd.find("DOWN") != -1):
				if(detectColision(joueur[id_client].getPosX(),joueur[id_client].getPosY()+vitesse,id_client) != 1):
					joueur[id_client].moveToDown(vitesse)
			
			#On regarde maintenant si je joueur veux tirer
			tir = json_msg['tir']
			if(tir == "1"):
				joueur[id_client].setStatus(2)

				#On cree une balle pour le tir
				if(time.time() - joueur[id_client].getCadTir() > 0.3):
					#on remet le 'compteur' a 0
					joueur[id_client].setCadTir(time.time())
					nouvelle_balle = Balle()
					nouvelle_balle.init(id_client,json_msg['ang'],joueur[id_client].getPosX(),joueur[id_client].getPosY())
					balle.append(nouvelle_balle)
			else:
				joueur[id_client].setStatus(0)
	
	#On fait bouger toutes les balles tirees
	for loop in range(len(balle)):
		#La condition si dessous permet d'eviter le bug(IndexOutOfRange) dans le cas ou l'on supprime une balle
		if(loop < len(balle)):
			balle[loop].move(10)
			#On detect la colision avec les autres objets
			if(detectColision(balle[loop].getPosX(),balle[loop].getPosY(),balle[loop].getIdJoueur()) == 1):
				#La balle touche on va donc la supprimer
				del balle[loop]

			

			
			

	
	
	
