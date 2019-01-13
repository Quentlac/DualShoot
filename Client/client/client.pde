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

//tableau pour charger la map
int[][] map = new int[100][100];

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

//variable pour calculer le ping
long ping_millis = 0;
long ping = 0;

PImage herbe;
PImage sable;
PImage eau;
PImage route;
PImage chemin;
PImage beton;

Arbre[] arbre = new Arbre[300];

class Arbre{
  int x = 0;
  int y = 0;
  
}
int nb_arbre = 0;

PImage arbreimg;


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
  
  //on charge les images
  herbe = loadImage("Images/herbe.jpg");
  sable = loadImage("Images/sable.jpg");
  eau = loadImage("Images/eau.jpg");
  route = loadImage("Images/route.jpg");
  chemin = loadImage("Images/chemin.jpg");
  beton = loadImage("Images/beton.jpg");
  
  PImage arbreimgtmp = loadImage("Images/trees.png");
  arbreimg = arbreimgtmp.get(0,0,256,256);
  
  //on charge la map
  String[] txtMap = loadStrings("map");
  
  if(txtMap[0].length() != 10000){
    println("Fichier map corrompu");  
  }
  else{
    for(int i = 0; i < 100;i++){
      for(int j = 0; j < 100;j++){
        if(txtMap[0].charAt(i*100+j) == '0'){
          map[i][j] = 0;  
        }
        if(txtMap[0].charAt(i*100+j) == '1'){
          map[i][j] = 1;  
        }
        if(txtMap[0].charAt(i*100+j) == '2'){
          map[i][j] = 2;  
        }
        if(txtMap[0].charAt(i*100+j) == '3'){
          map[i][j] = 3;  
        }
        if(txtMap[0].charAt(i*100+j) == '4'){
          map[i][j] = 4;  
        }
        if(txtMap[0].charAt(i*100+j) == '5'){
          map[i][j] = 5;  
        }
        if(txtMap[0].charAt(i*100+j) == '6'){
          map[i][j] = 6;  
        }
      }      
    }
  }
  
  for (int i = 0; i < 300; i++){
    arbre[i] = new Arbre();  
  } 
  
  //on charge les objets
  //arbre
  JSONObject jsonArbre = parseJSONObject(txtMap[1]);
  
  JSONArray arbreX = jsonArbre.getJSONArray("arbreX");
  JSONArray arbreY = jsonArbre.getJSONArray("arbreY");
  
  nb_arbre = arbreX.size();
  
  for(int i = 0; i < nb_arbre;i++){
    arbre[i].x = arbreX.getInt(i);
    arbre[i].y = arbreY.getInt(i); 
  }


}


void draw(){
  background(255);
  
  connect_serveur();
  
  //on test si l'id_client est valide pour effectuer les actions suivante
  if(id_client != -1){
    affichage_map();
    
    test_commande();
    affiche_personnage();
    affiche_limite();
    afficheObjet();
    
    afficheMiniMap();
    
  } 
}


void connect_serveur(){
  if (c.available()>0){
    delay(2);
    //on calcul le ping
    ping = millis() - ping_millis;
    
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
          //On commence par récupérer la position de nous
          xPers = json.getInt("X");
          yPers = json.getInt("Y");
          
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
  if(millis() - regul_send > 90){
    regul_send = millis();
    
    ping_millis = millis();
    
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
      
      int vitesse = 3;
      
      if(key_RIGHT == 1){
        message_cmd = message_cmd + "RIGHT;";
        
      }
      if(key_LEFT == 1){
        message_cmd = message_cmd + "LEFT;";
      }
      if(key_UP == 1){
        message_cmd = message_cmd + "UP;";
      }
      if(key_DOWN == 1){
        message_cmd = message_cmd + "DOWN;";
      }
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
  //on affiche tous les personnages (sauf le notre)
  
  for(int i = 0; i < nb_joueur;i++){
    int x = width/2 - (xPers - joueur[i].getX()); 
    int y = height/2 - (yPers - joueur[i].getY()); 
    
    fill(0,255,0);
    ellipse(x,y,30,30);
  }  
  
  //On affiche ensuite notre personnage
  fill(255,0,0);
  ellipse(width/2, width/2,30,30);
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

void affichage_map(){
  int xDep = int(xPers/60)*60 - xPers;
  int yDep = int(yPers/60)*60 - yPers;
  
  //on calcul ou commencer dans le tableau map
  int xTab = int(xPers/60)-5;
  int yTab = int(yPers/60)-5;
  
  println(xTab+","+yTab);
  
  stroke(200);
  
  for(int y = 0; y < 11;y++){
    for(int x = 0; x < 11;x++){
      if((y+yTab) >= 0 && (x+xTab) >= 0 && (x+xTab) < 100 && (y+yTab) >= 0){
        if(map[y+yTab][x+xTab] == 0)fill(255);
        if(map[y+yTab][x+xTab] == 1)image(herbe,x*60+xDep,y*60+yDep,60,60);
        if(map[y+yTab][x+xTab] == 2)image(sable,x*60+xDep,y*60+yDep,60,60);
        if(map[y+yTab][x+xTab] == 3)image(eau,x*60+xDep,y*60+yDep,60,60);
        if(map[y+yTab][x+xTab] == 4)image(route,x*60+xDep,y*60+yDep,60,60);
        if(map[y+yTab][x+xTab] == 5)image(chemin,x*60+xDep,y*60+yDep,60,60);
        if(map[y+yTab][x+xTab] == 6)image(beton,x*60+xDep,y*60+yDep,60,60);  
      }
    }
  }
  
  stroke(0);
  
  
  
  
}

void affiche_limite(){
  textSize(25);
  fill(255,0,0);
  text(xPers+","+yPers,100,100);
  
  strokeWeight(5);
  line(width/2 - (xPers - 0),height/2 - (yPers - 0),width/2 - (xPers - 0),height/2 - (yPers - 6000));
  line(width/2 - (xPers - 0),height/2 - (yPers - 0),width/2 - (xPers - 6000),height/2 - (yPers - 0));
  line(width/2 - (xPers - 0),height/2 - (yPers - 6000),width/2 - (xPers - 6000),height/2 - (yPers - 6000));
  line(width/2 - (xPers - 6000),height/2 - (yPers - 0),width/2 - (xPers - 6000),height/2 - (yPers - 6000));
  strokeWeight(1);
}

void afficheMiniMap(){
  fill(255);
  
  rect(489,489,101,101);
  
  for(int i = 0; i < 100;i++){
    for(int j = 0; j < 100; j++){
      if(map[i][j] == 0)fill(255);
      if(map[i][j] == 1)image(herbe,j+490,i+490,1,1);
      if(map[i][j] == 2)image(sable,j+490,i+490,1,1);
      if(map[i][j] == 3)image(eau,j+490,i+490,1,1);
      if(map[i][j] == 4)image(route,j+490,i+490,1,1);
      if(map[i][j] == 5)image(chemin,j+490,i+490,1,1);
      if(map[i][j] == 6)image(beton,j+490,i+490,1,1);      
      
    }  
  }
  fill(255,0,0);
  stroke(255,0,0);
  ellipse((xPers/60)+489,(yPers/60)+489,3,3);
  stroke(0);
  
  
}

void afficheObjet(){
  for(int i = 0; i < nb_arbre;i++){
    int x = width/2 - (xPers - arbre[i].x); 
    int y = height/2 - (yPers - arbre[i].y); 
    
    
    image(arbreimg,x,y,70,70);
  }    
  
}
