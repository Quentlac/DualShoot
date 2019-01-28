import socket
import select
import time
import os
import json
from math import *
from random import randint

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

	respawn = 0

	pseudo = ""

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
	
	def setPseudo(self, nP):
		self.pseudo = nP

	def getPseudo(self):
		return self.pseudo

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


	dist = 40
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

class Base:
	x = 0
	y = 0

	vie = 1000

	nbJ = 0

	def setPosition(self,setX,setY):
		self.x = setX
		self.y = setY

	def getPosX(self):
		return self.x

	def getPosY(self):
		return self.y

	def supprVie(self,valeur):
		self.vie = self.vie - valeur

	def getVie(self):
		return self.vie

	


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
	#-1 = colision avec un arbre
	#-2 = bord de map
	#-3 = base A
	#-4 = base B
	#0 = Aucune colision
	#>0 = colision avec un pers(nombre = id perso)
	
	#on prend chaque arbre un par un
	for loop2 in range(len(arbre)):
		#on considere un arbre comme un cercle, il va donc falloir calculer la distance entre le joueur et l'arbre		
		
		#pythagore
		#les -35 permettent de specifier le centre de l'arbre pas l'angle
		distance = sqrt(abs(x - arbre[loop2].getPosX()-35)*abs(x - arbre[loop2].getPosX()-35)+abs(y - arbre[loop2].getPosY()-35)*abs(y - arbre[loop2].getPosY()-35))
		if(distance < 35):
			return -1

	#On calcule la colision avec les personnages
	for loop2 in range(nb_joueur):
		#On ne vas pas detecter une colision avec le joueur lui meme!!
		if(pers != loop2):
			#On test aussi que le pers est encore en vie/connecte
			if(joueur[loop2].getVie() > 0):
				distance = sqrt(abs(x - joueur[loop2].getPosX())*abs(x - joueur[loop2].getPosX())+abs(y - joueur[loop2].getPosY())*abs(y - joueur[loop2].getPosY()))

				if(distance < 30):
					return loop2+1	

	#On calcule maintenant les collisions avec les limites de la map:
	if(x >= 6000 or x < 0 or y >= 6000 or y < 0):
		return -2

	#Colision avec les bases des equipes
	if(x > baseA.getPosX() and x < baseA.getPosX() + 300 and y > baseA.getPosY() and y < baseA.getPosY() + 200):
		return -3
	if(x > baseB.getPosX() and x < baseB.getPosX() + 300 and y > baseB.getPosY() and y < baseB.getPosY() + 200):
		return -4

	return 0


baseA = Base()
baseB = Base()

def lancePartie():
	#On fait spawn les bases des deux equipes
	baseA.setPosition(randint(200,5800),randint(200,5800))
	baseA.vie = 5000

	baseB.setPosition(randint(200,5800),randint(200,5800))
	baseB.vie = 5000

	#On elimine tous les joueurs
	for loop in range(nb_joueur):
		joueur[loop].supprVie(100)
	
	
	


message_tchat = "-"

lancePartie()

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
		
		#On definit son equipe en fonction du nombre de joueur dans chaque equipe
		if(baseA.nbJ < baseB.nbJ):
			player.equipe = 1
			baseA.nbJ += 1
		else:
			player.equipe = 2
			baseB.nbJ += 1
		
		#On le fait spawn:
		
		if(player.equipe == 1):
			player.setPosition(baseA.getPosX()+randint(-150,150),baseA.getPosY()+randint(-150,150))
		else:
			player.setPosition(baseB.getPosX()+randint(-150,150),baseB.getPosY()+randint(-150,150))	

		while(detectColision(player.getPosX(),player.getPosY(),nb_joueur) != 0):
			if(player.equipe == 1):
				player.setPosition(baseA.getPosX()+randint(-150,150),baseA.getPosY()+randint(-150,150))
			else:
				player.setPosition(baseB.getPosX()+randint(-150,150),baseB.getPosY()+randint(-150,150))

		#On met un pseudo temporaire en attendant que il nous le donne
		player.pseudo = "-"

		joueur.append(player)

		nb_joueur = nb_joueur + 1

	#on envoi toutes les infos aux joueurs
	id_joueur = 0
	for client in liste_client:
		message = "{"
		message = message + "ID:" + str(id_joueur)+","

		message = message + "X:" + str(joueur[id_joueur].getPosX())+","
		message = message + "Y:" + str(joueur[id_joueur].getPosY())+","


		message = message + "pv:" + str(joueur[id_joueur].getVie())+","

		message = message + "equipe:" + str(joueur[id_joueur].equipe)+","

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

		#On envoi le pseudo des joueurs:
		message = message + "pPseudo:[";
		for loop in range(nb_joueur):
			if(joueur[loop].getVie() > 0 and abs(joueur[loop].getPosX() - joueur[id_joueur].getPosX()) < 400 and abs(joueur[loop].getPosY() - joueur[id_joueur].getPosY()) < 400):
				if(id_joueur != loop):				
					message = message + "\'" + str(joueur[loop].getPseudo()) + "\',";

		message = message + "],"

		#On envoi les pv des joueurs:
		message = message + "pVie:[";
		for loop in range(nb_joueur):
			if(joueur[loop].getVie() > 0 and abs(joueur[loop].getPosX() - joueur[id_joueur].getPosX()) < 400 and abs(joueur[loop].getPosY() - joueur[id_joueur].getPosY()) < 400):
				if(id_joueur != loop):				
					message = message + str(joueur[loop].getVie()) + ",";

		message = message + "],"

		#On envoi les equipes des joueurs:
		message = message + "pEquipe:[";
		for loop in range(nb_joueur):
			if(joueur[loop].getVie() > 0 and abs(joueur[loop].getPosX() - joueur[id_joueur].getPosX()) < 400 and abs(joueur[loop].getPosY() - joueur[id_joueur].getPosY()) < 400):
				if(id_joueur != loop):				
					message = message + str(joueur[loop].equipe) + ",";

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

		#On envoi la positon des bases des equipes et les pv:
		message = message + "baseAX: " + str(baseA.getPosX()) + ","
		message = message + "baseAY: " + str(baseA.getPosY()) + ","
		message = message + "baseAPv: " + str(baseA.getVie()) + ","

		message = message + "baseBX: " + str(baseB.getPosX()) + ","
		message = message + "baseBY: " + str(baseB.getPosY()) + ","
		message = message + "baseBPv: " + str(baseB.getVie()) + ","
		

		message = message + "tchat: \""

		#On envoi le tchat si il y a un msg a envoye:
		if(message_tchat != "-"):
			message = message + message_tchat
			message_tchat = "-"
		else:
			#le - signifie rien pour le client
			message = message + "-"	

		message = message + "\","


		message = message + "}"

		try:
			#si client est = a 0 cela signifie que le client est parti (voir un plus bas)
			if(client != 0):
				client.send(message)
		except socket.error:
			print("Client("+str(id_joueur)+") est parti")
			message_tchat = "Une pers est partie! ("+str(id_joueur)+")"

			liste_client[id_joueur] = 0

			#On supprime le joueur de la base associe
			if(joueur[id_joueur].equipe == 1):
				baseA.nbJ -= 1
			else:
				baseB.nbJ -= 1	
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

			#On regarde que le joueur soit en vie pour se deplacer ou tirer
			if(joueur[id_client].getVie() > 0):

				joueur[id_client].setAngle(json_msg['ang'])

				#on recupere le pseudo
				joueur[id_client].setPseudo(json_msg['pseudo'])

				#on cree une variable vitesse pour pouvoir changer plus rapidement
				vitesse = 10


				cmd = json_msg['cmd']

				if(cmd.find("RIGHT") != -1):
					if(detectColision(joueur[id_client].getPosX()+vitesse,joueur[id_client].getPosY(),id_client) == 0):
						joueur[id_client].moveToRight(vitesse)

				if(cmd.find("LEFT") != -1):
					if(detectColision(joueur[id_client].getPosX()-vitesse,joueur[id_client].getPosY(),id_client) == 0):
						joueur[id_client].moveToLeft(vitesse)
			
				if(cmd.find("UP") != -1):
					if(detectColision(joueur[id_client].getPosX(),joueur[id_client].getPosY()-vitesse,id_client) == 0):
						joueur[id_client].moveToUp(vitesse)

				if(cmd.find("DOWN") != -1):
					if(detectColision(joueur[id_client].getPosX(),joueur[id_client].getPosY()+vitesse,id_client) == 0):
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
			balle[loop].move(15)
			#On detect la colision avec les autres objets
			if(detectColision(balle[loop].getPosX(),balle[loop].getPosY(),balle[loop].getIdJoueur()) != 0):
				#La balle touche on va donc la supprimer
				if(detectColision(balle[loop].getPosX(),balle[loop].getPosY(),balle[loop].getIdJoueur())>0):
					#Avec un joueur
					#On applique les degats
					#Le -1 sert a remmettre la bonne valeur(pour ne pas qu'elle soit a 0 lors du return de la fonction)
					joueur_touche = detectColision(balle[loop].getPosX(),balle[loop].getPosY(),balle[loop].getIdJoueur())-1
					joueur[joueur_touche].supprVie(10)
					if(joueur[joueur_touche].getVie() <= 0):
						#Le joueurs est mort on envoi un petit msg sur le chat
						message_tchat = str(balle[loop].getIdJoueur())+" a elimine "+str(joueur_touche)
						#Ensuite on fait respawn le personnage
						joueur[joueur_touche].respawn = time.time()
				if(detectColision(balle[loop].getPosX(),balle[loop].getPosY(),balle[loop].getIdJoueur()) == -3):	
					#Colision avec la baseA
					#on verifie que la personne ne tire pas sur sa base
					if(joueur[balle[loop].getIdJoueur()].equipe == 2):
						baseA.supprVie(10)

				if(detectColision(balle[loop].getPosX(),balle[loop].getPosY(),balle[loop].getIdJoueur()) == -4):	
					#Colision avec la baseB
					if(joueur[balle[loop].getIdJoueur()].equipe == 1):					
						baseB.supprVie(10)

				del balle[loop]

	#On fait respawn tous les joueurs en attente de respawn
	for loop in range(nb_joueur):
		if(joueur[loop].respawn != 0):
			if(time.time() - joueur[loop].respawn > 5):
				joueur[loop].respawn = 0
				if(joueur[loop].equipe == 1):
					joueur[loop].setPosition(baseA.getPosX()+randint(-150,150),baseA.getPosY()+randint(-150,150))
				else:
					joueur[loop].setPosition(baseB.getPosX()+randint(-150,150),baseB.getPosY()+randint(-150,150))
				
				#La boucle while sert a eviter que le joueurs spawn sur un objet avec une collision
				while(detectColision(joueur[loop].getPosX(),joueur[loop].getPosY(),loop) != 0):
					if(joueur[loop].equipe == 1):
						joueur[loop].setPosition(baseA.getPosX()+randint(-150,150),baseA.getPosY()+randint(-150,150))
					else:
						joueur[loop].setPosition(baseB.getPosX()+randint(-150,150),baseB.getPosY()+randint(-150,150))
				joueur[loop].vie = 100
	
	if(baseA.vie <= 0 or baseB.vie <= 0):
		#La partie est fini et on recommence
		lancePartie()
						
	
			
	
			
			

	
