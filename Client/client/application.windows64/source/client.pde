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
  
  //Cette variable permet de dire au client si le joueur marche ou tir afin d'adapter les animations
  //0=fixe 1=marche 2=tir 3=marche+tir
  int status = 0;

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
  
  void setStatus(int Ns){
    status = Ns;   
  }
  
  int getStatus(){
    return status;  
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

class Base{
  int x = 0;
  int y = 0;  
  
  int vie = 1000;
  
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

Base baseA = new Base();
Base baseB = new Base();

HitMarker[] hitmarker = new HitMarker[10];

class HitMarker{
  int x = 0;
  int y = 0;  
  
  int valeur = 0;
  long tmp_aff = 0;
  
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
  
  void setValeur(int Nv){
    valeur = Nv;      
  }
  
  int getValeur(){
    return valeur;      
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

int nb_hit_marker = 0;

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

PImage pers;
PImage tir;

Arbre[] arbre = new Arbre[300];

class Arbre{
  int x = 0;
  int y = 0;
  
}
int nb_arbre = 0;

PImage arbreimg;


//tchat du serveur
String[] tchat = new String[5];
int nb_msg_tchat = 0;

float angle = 0;


//La variables est a 1 si la personne est entrain de tirer
int tir_en_cours = 0;

int pv = 100;

void setup(){
  size(600,600); 
  
  c = new Client(this, "quentin-fr.ddns.net", 222);

  
  for (int i = 0; i < 100; i++) {
    joueur[i] = new Joueur();
  } 
  
  for (int i = 0; i < 100; i++) {
    balle[i] = new Balle();
  } 
   
  for (int i = 0; i < 100; i++) {
    item[i] = new Item();
  } 
  
  for (int i = 0; i < 10; i++) {
    hitmarker[i] = new HitMarker();
  } 
  
  //on charge les images
  herbe = loadImage("Images/herbe.jpg");
  sable = loadImage("Images/sable.jpg");
  eau = loadImage("Images/eau.jpg");
  route = loadImage("Images/route.jpg");
  chemin = loadImage("Images/chemin.jpg");
  beton = loadImage("Images/beton.jpg");
  
  pers = loadImage("Images/pers.gif");
  tir = loadImage("Images/tir.png");
  
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
    setAnglePers();
    affichage_map();

    
    afficheBalle();
    affiche_personnage();
    affiche_limite();
    afficheObjet();
    afficheBase();
    afficheHitMarker();
    
    afficheMiniMap();
    
    afficheTchat();
    afficheBarrePV();
   
    
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
      //println(data);
      //println("############################");
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
          
          pv = json.getInt("pv");
          
          JSONArray posX = json.getJSONArray("pX");
          JSONArray posY = json.getJSONArray("pY");
          JSONArray angleTab = json.getJSONArray("pAngle");
          JSONArray statusTab = json.getJSONArray("pStatus");
          
          JSONArray balleX = json.getJSONArray("bX");
          JSONArray balleY = json.getJSONArray("bY");
          
          //on actualise en local
          
          //la taille du tableau correspond au nombre de joueur
          nb_joueur = posX.size();
          for(int i = 0; i < nb_joueur;i++){
            joueur[i].setX(posX.getInt(i));
            joueur[i].setY(posY.getInt(i));
            joueur[i].setAngle(angleTab.getInt(i));
            joueur[i].setStatus(statusTab.getInt(i));
          }
          
          //la taille du tableau correspond au nombre de balle
          nb_balle = balleX.size();
          for(int i = 0; i < nb_balle;i++){
            balle[i].setX(balleX.getInt(i));  
            balle[i].setY(balleY.getInt(i)); 
          }
          
          //on récupère les informations sur les différentes bases
          baseA.setX(json.getInt("baseAX"));
          baseA.setY(json.getInt("baseAY"));
          baseA.vie = json.getInt("baseAPv");
          
          baseB.setX(json.getInt("baseBX"));
          baseB.setY(json.getInt("baseBY"));
          baseB.vie = json.getInt("baseBPv");
                    
          //on recupère aussi le tchat serveur
          String newTchat = json.getString("tchat");
          
          if(newTchat.indexOf("-") == -1){
            //on decale tous dans le tabelau tchat pour ne garder que les derniers messages.
            
            for(int i = 0; i < 4;i++){
              tchat[i] = tchat[i+1];                 
            }
            
            tchat[4] = newTchat;
            
          }
        }
      } 
    } 
    
    //Une fois que le client nous a envoyé un message on lui repond -> permet d'être le plus fluide possible.
    test_commande();
  }  
}

void test_commande(){
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
    c.write("{\"ID\": "+id_client+" , \"cmd\": \""+message_cmd+"\", \"ang\": "+int(angle)+", \"pseudo\": \""+pseudo+"\", \"tir\": \""+tir_en_cours+"\"}");    
  }
  else{
    c.write("{\"ID\": "+id_client+" , \"cmd\": \"NULL\", \"ang\": "+int(angle)+", \"pseudo\": \""+pseudo+"\", \"tir\": \""+tir_en_cours+"\"}");    
  }
  
}

void affiche_personnage(){  
  //on affiche tous les personnages (sauf le notre)
  
  for(int i = 0; i < nb_joueur;i++){
    int x = width/2 - (xPers - joueur[i].getX()); 
    int y = height/2 - (yPers - joueur[i].getY()); 
    
    pushMatrix();
  
    translate(x,y);
    rotate(PI * joueur[i].getAngle() / 180);
    image(pers,-35,-50,70,70);
    
    //Si la personne est entrain de tirer on affiche une petite animation de tir
    if(joueur[i].getStatus() == 2 || joueur[i].getStatus() == 3){
      if(random(0,3) < 1.5){
        image(tir,25,-10);
      }
    }
    
    popMatrix();
    
  }  
  
  //On affiche ensuite notre personnage
  //seulement si il est encore en vie
  if(pv > 0){
    //fill(255,0,0);
    //ellipse(width/2, width/2,30,30);
    
    pushMatrix();
    
    translate(width/2,height/2);
    rotate(PI * angle / 180);
    image(pers,-35,-50,70,70);
    
    //Si la personne est entrain de tirer on affiche une petite animation de tir
    if(tir_en_cours == 1){
      if(random(0,3) < 1.5){
        image(tir,25,-10);
      }
    }
    
    popMatrix();
  }
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
  
  
  stroke(200);
  
  for(int y = 0; y < 11;y++){
    for(int x = 0; x < 11;x++){
      if((y+yTab) >= 0 && (x+xTab) >= 0 && (x+xTab) < 100 && (y+yTab) < 100){
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
  
  //on affiche les bases ennemies
  fill(255,0,0);
  ellipse((baseA.getX()/60)+489,(baseA.getY()/60)+489,10,10);
  fill(0,100,255);
  ellipse((baseB.getX()/60)+489,(baseB.getY()/60)+489,10,10);
  
  
}

void afficheObjet(){
  for(int i = 0; i < nb_arbre;i++){
    int x = width/2 - (xPers - arbre[i].x); 
    int y = height/2 - (yPers - arbre[i].y); 
    
    
    image(arbreimg,x,y,70,70);
  }    
  
}

void afficheTchat(){
  textSize(10);
  
  fill(255,255,255,100);
  
  rect(10,500,300,90);
  fill(255,0,0);
  
  
  
  text(tchat[4]+"\n"+tchat[3]+"\n"+tchat[2]+"\n"+tchat[1]+"\n"+tchat[0]+"\n",20,515);  
  
  
}

void setAnglePers(){
  float x = mouseX-(width/2);
  float y = mouseY-(height/2);
  
  
  if(y == 0)y = 1;
  
  if(mouseY < 300){
    angle = 90+(atan(x/y) * 180 / PI);
  }
  else{
    angle = 270+(atan(x/y) * 180 / PI);  
  }
  
  angle = 360 - angle;  
  
  
}

void afficheBalle(){
  //Ici on affiche toutes les balles
  for(int i = 0; i < nb_balle;i++){
    int x = width/2 - (xPers - balle[i].getX()); 
    int y = height/2 - (yPers - balle[i].getY()); 
    
    
    fill(0);
    stroke(0);
    ellipse(x,y,2,2);
    
  }
  
}

void mousePressed(){
  tir_en_cours = 1;  
  
}

void mouseReleased(){
  tir_en_cours = 0;  
  
}

void afficheHitMarker(){
  //Les hitsmarkers servent à indiqué au joueur qu'il a touché son adversaire
  for(int i = 0; i < nb_balle;i++){
    for(int j = 0; j < nb_joueur;j++){
      //On calcul la distance entre les balles et les personnages:
      float distance = sqrt(abs(balle[i].getX() - joueur[j].getX())*abs(balle[i].getX() - joueur[j].getX())+abs(balle[i].getY() - joueur[j].getY())*abs(balle[i].getY() - joueur[j].getY()));
      if(distance < 40){
        if(nb_hit_marker < 9){
          hitmarker[nb_hit_marker].setValeur(-10); 
          hitmarker[nb_hit_marker].setX(balle[i].getX()-10);
          hitmarker[nb_hit_marker].setY(balle[i].getY()-10); 
          hitmarker[nb_hit_marker].tmp_aff = millis(); 
          
          nb_hit_marker++;
        }
      }
    }    
  }
  
  //maintenant ont les affiches
  for(int i = 0; i < nb_hit_marker;i++){
    fill(255,0,0);
    
    int x = width/2 - (xPers - hitmarker[i].x);
    int y = height/2 - (yPers - hitmarker[i].y);
    
    textSize(15);
    
    text(hitmarker[i].getValeur(),x,y);
    
    if(millis() - hitmarker[i].tmp_aff > 500){
      nb_hit_marker--;  
    }
  }
  
}

void afficheBarrePV(){
  fill(0);
  rect(20,10,225,25);
  fill(0,255,0);
  float xBar = map(pv,0,100,0,221);
  rect(22,12,xBar,21);
  
  //barre de pv des bases:
  fill(0);
  stroke(255,0,0);
  rect(489,440,100,15);
  xBar = map(baseA.vie,0,1000,0,96);
  fill(255,0,0);
  rect(491,442,xBar,11);
  
  fill(0);
  stroke(0,100,255);
  rect(489,465,100,15);
  xBar = map(baseB.vie,0,1000,0,96);
  fill(0,100,255);
  rect(491,467,xBar,11);
  
}

void afficheBase(){
 int x = width/2 - (xPers - baseA.getX());
 int y = height/2 - (yPers - baseA.getY()); 
  
 if(baseA.vie > 0){  
   fill(255,0,0);
   rect(x,y,300,200);
 }
 
 x = width/2 - (xPers - baseB.getX());
 y = height/2 - (yPers - baseB.getY()); 
 
 if(baseB.vie > 0){  
   fill(0,100,255);
   rect(x,y,300,200);
 }
  
}
