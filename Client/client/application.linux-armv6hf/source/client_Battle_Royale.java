import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.net.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class client_Battle_Royale extends PApplet {



Client c;

int id_client = 0;

int map_jeu[][] = {
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},  
};

float angle_arme = 0;

Joueur[] joueur = new Joueur[100];

class Joueur{
  int x = 0;
  int y = 0;  
  
  int angle = 0;
  
  String pseudo = "";

  public void setX(int Nx){
    x = Nx;      
  }
  
  public void setY(int Ny){
    y = Ny;      
  }
  
  public int getX(){
    return x;  
  }
  
  public int getY(){
    return y;  
  }
  
  public void setAngle(int Na){
    angle = Na;  
    
  }
  
  public int getAngle(){
    return angle;  
  }
  
  public void setPseudo(String NewPseudo){
    pseudo = NewPseudo;  
  }
  public String getPseudo(){
    return pseudo;  
  }
}

int pv_joueur = 100;

Balle[] balle = new Balle[100];

class Balle{
  int x = 0;
  int y = 0;  
  
  public void setX(int Nx){
    x = Nx;      
  }
  
  public void setY(int Ny){
    y = Ny;      
  }
  
  public int getX(){
    return x;  
  }
  
  public int getY(){
    return y;  
  }
}

int camX = -45;
int camY = -45;

long regul_send = 0;

int nb_joueur;

int angle_personnage = 0;

int nb_balle = 0;

String message_info = "";

int key_RIGHT = 0;
int key_LEFT = 0;
int key_UP = 0;
int key_DOWN = 0;

int nb_joueur_restant = 0;

int taille_zone = 0;
int depX_zone = 0;
int depY_zone = 0;

int nb_kill = 0;

int set_pseudo = 0;

String pseudo = "";

public void setup(){
   
  
  c = new Client(this, "quentin-fr.ddns.net", 222);
 
  
  //on r\u00e9cupere l'ID envoy\u00e9 par le serveur:
  while(c.available() == 0); 
  String mesg = c.readString(); 
  id_client = PApplet.parseInt(mesg);
  
  
  for (int i = 0; i < 100; i++) {
    joueur[i] = new Joueur();
  } 
  
  for (int i = 0; i < 100; i++) {
    balle[i] = new Balle();
  } 
   
}


public void draw(){
  background(255);
  affiche_map();
  affiche_degat();
  affiche_zone();
  affiche_personnage();
  affiche_balle();
  affiche_kill();
  connect_serveur();
  test_commande();
  
  affiche_pv_joueur();
  affiche_joueur_restant();
      
  
  textSize(25);
  fill(0,255,0);
  text(message_info,20,50);
  
  if(set_pseudo == 0){
    setPseudo();   
  }
  
  if(pv_joueur <= 0){
    textSize(30);
    fill(255,0,0);
    text("GAME OVER",220,200);
  
  }
  if(nb_joueur_restant == 1 && pv_joueur > 0){
    textSize(25);
    fill(0,255,0);
    text("Bravo vous etes le vainqueur!!!!",100,200);
  }
  
  
  
}

public void affiche_map(){
  for(int y = 0; y < 22;y++){
    for(int x = 0; x < 22;x++){
      if(map_jeu[y][x] == 1){
        if(camY+(y*30)>=depY_zone && camY+(y*30)<depY_zone+taille_zone && camX+(x*30)>=depX_zone && camX+(x*30)<depX_zone+taille_zone){
          fill(100,50,70);
        }
        else{
          fill(0,50,0);  
        }
        stroke(0);
        rect((x*30)+camX,(y*30)+camY,30,30);
      }
      else if(map_jeu[y][x] == 0){
        if(camY+(y*30)>=depY_zone && camY+(y*30)<depY_zone+taille_zone && camX+(x*30)>=depX_zone && camX+(x*30)<depX_zone+taille_zone){
          fill(255);  
        }
        else{
          fill(0,100,0);  
        }      
        stroke(0);
        rect((x*30)+camX,(y*30)+camY,30,30);
        
      }
      else if(map_jeu[y][x] == 2){
        fill(0);
        stroke(0);
        rect((x*30)+camX,(y*30)+camY,30,30);  
      }
    }
  }
}

public void connect_serveur(){
  if (c.available()>0){
    delay(2);
    String data = "";
    data = c.readStringUntil('}');  
    //println(data);
    //println("------------------------------------------------------------");

    if(data != null){
      JSONObject json = parseJSONObject(data);
      if(json != null){
        message_info = json.getString("msg");
        
        if(message_info.indexOf("Debut de la partie dans") == -1){
          String newMap = json.getString("map");
          for(int y = 0;y < 22;y++){
            for(int x = 0;x < 22;x++){
              if(newMap.charAt(y*22+x) == '1'){
                map_jeu[y][x] = 1;  
              }
              if(newMap.charAt(y*22+x) == '0'){
                map_jeu[y][x] = 0;  
              }
              if(newMap.charAt(y*22+x) == '2'){
                map_jeu[y][x] = 2;  
              }
              
              //println(newMap);
              //println("-------");
            }
          }
          
          camX = json.getInt("camX");
          camY = json.getInt("camY");
          
          pv_joueur = json.getInt("pv");
          nb_kill = json.getInt("nb_kill");
          
          nb_joueur = json.getInt("nb_j");
          
          nb_joueur_restant = json.getInt("j_rst");
          
          taille_zone = json.getInt("taille_zone");
          depX_zone = 300+(json.getInt("depX_zone"));
          depY_zone = 300+(json.getInt("depY_zone"));
          
          for(int i = 0; i < nb_joueur;i++){
            joueur[i].setX(300+(json.getInt("X"+i))); 
            joueur[i].setY(300+(json.getInt("Y"+i))); 
            joueur[i].setAngle(json.getInt("A"+i));
            joueur[i].setPseudo(json.getString("P"+i));
          }
          
          nb_balle = json.getInt("nb_b");
          
          println(nb_balle);
          
          for(int i = 0; i < nb_balle;i++){
            balle[i].setX(300+(json.getInt("BX"+i))); 
            balle[i].setY(300+(json.getInt("BY"+i))); 
          }   
        } 
      }
    }
  }  
  /*while(c.available()>0){
    c.readString(); 
  }*/
}

public void test_commande(){
  if(millis() - regul_send > 50){
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
    if(key_RIGHT + key_LEFT + key_UP + key_DOWN > 0){
      String message_cmd = "";
      if(key_RIGHT == 1)message_cmd = message_cmd + "RIGHT;";
      if(key_LEFT == 1)message_cmd = message_cmd + "LEFT;";
      if(key_UP == 1)message_cmd = message_cmd + "UP;";
      if(key_DOWN == 1)message_cmd = message_cmd + "DOWN;";
      c.write("{\"ID\": "+id_client+" , \"cmd\": \""+message_cmd+"\", \"ang\": "+angle_arme+", \"pseudo\": \""+pseudo+"\"}");    
    }
    else{
      c.write("{\"ID\": "+id_client+" , \"cmd\": \"NULL\", \"ang\": "+angle_arme+", \"pseudo\": \""+pseudo+"\"}");    
    }
    angle_arme = abs(angle_arme);
  }
}

public void affiche_personnage(){
  //pseudo du joueur actuel
  if(pv_joueur > 0){
    textSize(12);
    fill(255,0,0);
    text(pseudo,280,277);
  }
  for(int i = 0; i < nb_joueur;i++){
    
    pushMatrix();
    translate(joueur[i].getX(),joueur[i].getY()); 
    textSize(12);
    fill(255,0,0);
    text(joueur[i].getPseudo(),-20,-23);
    rotate(PI * joueur[i].getAngle() / 180);
    fill(0);
    rect(0,-5,15,6);
    fill(255,0,0);
    ellipse(0,0,20,20); 
    popMatrix();
  }  
  
  if(pv_joueur > 0){
    pushMatrix();
    translate(300,300);  
    rotate(PI * angle_arme / 180);
    fill(0);
    rect(0,-5,15,6);
    fill(0,255,0);
    ellipse(0,0,20,20); 
    popMatrix();
  }
  
}

public void affiche_balle(){
  for(int i = 0; i < nb_balle;i++){
    
    pushMatrix();
    translate(balle[i].getX(),balle[i].getY());   
    fill(0);
    ellipse(0,0,5,5); 
    popMatrix();
  }  
}

public void affiche_pv_joueur(){
  stroke(0);
  noFill();
  rect(240,575,120,15);
  
  fill(0,255,0);
  
  rect(242,577,map(pv_joueur,0,100,0,116),11);
}

public void affiche_degat(){
  for(int i = 0; i < nb_balle;i++){
    for(int j = 0; j < nb_joueur;j++){
      if(balle[i].getX() > joueur[j].getX()-12 && balle[i].getX() < joueur[j].getX()+12 && balle[i].getY() > joueur[j].getY()-12 && balle[i].getY() < joueur[j].getY()+12){
        fill(255);
        ellipse(joueur[j].getX(),joueur[j].getY(),25,25);
        println("collision");
      }      
    }
  }
}

public void keyPressed(){
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
}

public void keyReleased(){
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
}

public void affiche_joueur_restant(){
  fill(255);
  textSize(25);  
  text(nb_joueur_restant,10,50);
  
  
}

public void affiche_kill(){
  fill(255);
  textSize(25);  
  text(nb_kill,500,50);    
}

public void affiche_zone(){
  stroke(255,0,0);
  strokeWeight(5);
  noFill();
  rect(depX_zone,depY_zone,taille_zone,taille_zone);
  
  
  strokeWeight(1);
  stroke(0);
}

public void setPseudo(){
  fill(0);
  stroke(255);
  rect(200,250,200,50);
  
  textSize(12);
  fill(255);
  text("Pseudo: ",205,266);
  textSize(21);
  text(pseudo,205,285);
  fill(0);
  if(keyPressed == true){
    delay(100);
    if(key != '\n'){
      if(keyCode == LEFT){
        String newPseudo = "";
        for(int i = 0; i < pseudo.length()-1;i++){
          newPseudo = newPseudo + pseudo.charAt(i);
        }
        pseudo = newPseudo;
      }
      else{
        pseudo = pseudo + key;  
      }
    }
    else{
      set_pseudo = 1; 
    }
  } 
}
  public void settings() {  size(600,600); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "client_Battle_Royale" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
