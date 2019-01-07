import processing.net.*;

Client c;

//-1 = pas encore init
int id_client = -1;

float angle_arme = 0;

Joueur[] joueur = new Joueur[100];

class Joueur{
  int x = 0;
  int y = 0;  
  
  int angle = 0;
  
  String pseudo = "";
  
  int arme_en_main = 0;

  void setX(int Nx){
    x = Nx;      
  }
  
  void setY(int Ny){
    y = Ny;      
  }
  
  int getX(){
    return x;  
  }
  
  int getY(){
    return y;  
  }
  
  void setAngle(int Na){
    angle = Na;  
    
  }
  
  int getAngle(){
    return angle;  
  }
  
  void setPseudo(String NewPseudo){
    pseudo = NewPseudo;  
  }
  String getPseudo(){
    return pseudo;  
  }
  
  void setArme(int Na){
    arme_en_main = Na;  
    
  }
  
  int getArme(){
    return arme_en_main;  
  }
}

int pv_joueur = 100;

Balle[] balle = new Balle[100];

class Balle{
  int x = 0;
  int y = 0;  
  
  void setX(int Nx){
    x = Nx;      
  }
  
  void setY(int Ny){
    y = Ny;      
  }
  
  int getX(){
    return x;  
  }
  
  int getY(){
    return y;  
  }
}

Item[] item = new Item[100];

class Item{
  int x = 0;
  int y = 0;  
  
  int idArme = 0;
  
  void setX(int Nx){
    x = Nx;      
  }
  
  void setY(int Ny){
    y = Ny;      
  }
  
  void setIdArme(int id){
    idArme = id;  
  }
  
  int getX(){
    return x;  
  }
  
  int getY(){
    return y;  
  } 
  
  int getIdArme(){
    return idArme;  
  }
}

long regul_send = 0;

int nb_joueur = 0;

int nb_item = 0;

int angle_personnage = 0;

int nb_balle = 0;

String message_info = "";

int key_RIGHT = 0;
int key_LEFT = 0;
int key_UP = 0;
int key_DOWN = 0;
int key_E = 0;

String pseudo = "";

//coordone du personnage client
int xPers = 0;
int yPers = 0;

void setup(){
  size(600,600); 
  
  c = new Client(this, "localhost", 222);

  
  for (int i = 0; i < 100; i++) {
    joueur[i] = new Joueur();
  } 
  
  for (int i = 0; i < 100; i++) {
    balle[i] = new Balle();
  } 
   
  for (int i = 0; i < 100; i++) {
    item[i] = new Item();
  } 

}


void draw(){
  background(255);
  
  connect_serveur();
  
  //on test si l'id_client est valide pour effectuer les actions suivante
  if(id_client != -1){
    affichage_grille();
    
    test_commande();
    affiche_personnage();
    
  } 
}


void connect_serveur(){
  if (c.available()>0){
    delay(2);
    String data = "";
    data = c.readStringUntil('}');  

    if(data != null){
      JSONObject json = parseJSONObject(data);
      if(json != null){ 
        //on récupère d'abord l'ID si on l'a pas encore
        if(id_client == -1){
          id_client = json.getInt("ID");  
        }
        else{
          //On commence par récupérer la position des personnages 
          JSONArray posX = json.getJSONArray("pX");
          JSONArray posY = json.getJSONArray("pY");
          
          //on actualise en local
          
          //la taille du tableau correspond au nombre de joueur
          nb_joueur = posX.size();
          for(int i = 0; i < nb_joueur;i++){
            joueur[i].setX(posX.getInt(i));
            joueur[i].setY(posY.getInt(i));
          }   
        }
      } 
    } 
  }  
}

void test_commande(){
  //regul_send sert à ne pas saturer le serveur en régulant l'envoi d'une requete toutes les 50ms
  if(millis() - regul_send > 100){
    regul_send = millis();
    
    float x = mouseX-300;
    float y = mouseY-300;
    
    
    if(y == 0)y = 1;
    
    if(mouseY < 300){
      angle_arme = 90+atan(x/y) * 180 / PI;
    }
    else{
      angle_arme = 270+(atan(x/y) * 180 / PI);  
    }
    
    angle_arme = 360 - angle_arme;
    //si angle est negatif c'est qu'on veux tirer
    if(mousePressed == true){
      angle_arme = 0 - angle_arme;  
    }
    if(key_RIGHT + key_LEFT + key_UP + key_DOWN + key_E > 0){
      String message_cmd = "";
      if(key_RIGHT == 1)message_cmd = message_cmd + "RIGHT;";
      if(key_LEFT == 1)message_cmd = message_cmd + "LEFT;";
      if(key_UP == 1)message_cmd = message_cmd + "UP;";
      if(key_DOWN == 1)message_cmd = message_cmd + "DOWN;";
      if(key_E == 1)message_cmd = message_cmd + "TAKE;";
      c.write("{\"ID\": "+id_client+" , \"cmd\": \""+message_cmd+"\", \"ang\": "+angle_arme+", \"pseudo\": \""+pseudo+"\"}");    
    }
    else{
      c.write("{\"ID\": "+id_client+" , \"cmd\": \"NULL\", \"ang\": "+angle_arme+", \"pseudo\": \""+pseudo+"\"}");    
    }
    angle_arme = abs(angle_arme);
  }
}

void affiche_personnage(){
   
  //il faut récupérer les coordonées de notre personnage pour afficher les autres en fonctions de nous
  //Les coordonées de notre perso correspondent a la valeur numero id_client du tableau des joueurs
  
  xPers = joueur[id_client].getX();
  yPers = joueur[id_client].getY();
  
  println(xPers+","+yPers);
  
  //on affiche tous les personnages (sauf le notre)
  
  for(int i = 0; i < nb_joueur;i++){
    int x = width/2 - (xPers - joueur[i].getX()); 
    int y = height/2 - (yPers - joueur[i].getY()); 
    
    fill(0,255,0);
    ellipse(x,y,10,10);
  }  
  
  //On affiche ensuite notre personnage
  fill(255,0,0);
  ellipse(width/2, width/2,20,20);
}





void keyPressed(){
  if(keyCode == RIGHT){
    key_RIGHT = 1;  
  }
  if(keyCode == LEFT){
    key_LEFT = 1;  
  }
  if(keyCode == UP){
    key_UP = 1;  
  }
  if(keyCode == DOWN){
    key_DOWN = 1;  
  }
  if(key == '0'){
    key_E = 1;  
  }
}

void keyReleased(){
  if(keyCode == RIGHT){
    key_RIGHT = 0;  
  }
  if(keyCode == LEFT){
    key_LEFT = 0;  
  }
  if(keyCode == UP){
    key_UP = 0;  
  }
  if(keyCode == DOWN){
    key_DOWN = 0;  
  }   
  if(key == '0'){
    key_E = 0;  
  }
}

void affichage_grille(){
  int xDep = xPers - int(xPers/10)*10;
  int yDep = yPers - int(yPers/10)*10;
  
  stroke(200);
  
  for(int i = 0; i < 60;i++){
    line(xDep+(i*10),0,xDep+(i*10),height); 
    line(0,yDep+(i*10),width,yDep+(i*10)); 
  }
  
  stroke(0);
  
  
}
