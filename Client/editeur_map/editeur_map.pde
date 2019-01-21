//Logiciel pour créer une map

int[][] map = new int[100][100];

int curseurInventaire = 0;

int posX = 0;
int posY = 0;

PImage herbe;
PImage sable;
PImage eau;
PImage route;
PImage chemin;
PImage beton;

PImage arbreimg;

PrintWriter filemap;

Arbre[] arbre = new Arbre[300];

class Arbre{
  int x = 0;
  int y = 0;
  
  int pv = 0;
  
}

int nb_arbre = 0;

void setup(){
  size(660,600);
  herbe = loadImage("Images/herbe.jpg");
  sable = loadImage("Images/sable.jpg");
  eau = loadImage("Images/eau.jpg");
  route = loadImage("Images/route.jpg");
  chemin = loadImage("Images/chemin.jpg");
  beton = loadImage("Images/beton.jpg");
  
  arbreimg = loadImage("Images/trees.png");
  
  for(int i = 0; i < 100;i++){
    for(int j = 0; j < 100;j++){
      map[i][j] = 1;
    }
  }
  
  for (int i = 0; i < 300; i++) {
    arbre[i] = new Arbre();  
  } 
  
  /*//on charge la map
  String[] txtMap = loadStrings("map");

  //on charge les objets
  //arbre
  JSONObject jsonMap = parseJSONObject(txtMap[0]);
  JSONArray mapTab = jsonMap.getJSONArray("map");
  for(int i = 0; i < 100;i++){
    for(int j = 0; j < 100;j++){
      map[i][j] = mapTab.getInt(i*100+j);
    }
  }
  
  JSONArray arbreX = jsonMap.getJSONArray("arbreX");
  JSONArray arbreY = jsonMap.getJSONArray("arbreY");
  
  nb_arbre = arbreX.size();
  
  for(int i = 0; i < nb_arbre;i++){
    arbre[i].x = arbreX.getInt(i);
    arbre[i].y = arbreY.getInt(i); 
  }*/
  
  
  
  
}



void draw(){
  background(255);
  
  afficheGrille();
  
  testPosInvent();
  
  setTuile();
  afficheTuile();
  deplaceMap();
  saveMap();
  afficheObjet();
  afficheInventaire();
  afficheObjetCurseur();
  afficheMiniMap();
  
  
  
}

void afficheGrille(){
  stroke(200);
  for(int i = 0; i < 10;i++){
    line(i*60+60,0,i*60+60,600);  
    line(60,i*60,660,i*60);
  }
}

void afficheInventaire(){
  stroke(255,0,0);
  
  
  
  
  //herbe
  if(curseurInventaire == 0)strokeWeight(3);
  image(herbe,0,0,60,60);
  noFill();
  rect(0,0,60,60);
  strokeWeight(1);
  
  //sable
  if(curseurInventaire == 1)strokeWeight(3);
  image(sable,0,60,60,60);
  noFill();
  rect(0,60,60,60);
  strokeWeight(1);
  
  //eau
  if(curseurInventaire == 2)strokeWeight(3);
  image(eau,0,120,60,60);
  noFill();
  rect(0,120,60,60);
  strokeWeight(1);
  
  //route
  if(curseurInventaire == 3)strokeWeight(3);
  image(route,0,180,60,60);
  noFill();
  rect(0,180,60,60);
  strokeWeight(1);
  
  //chemin
  if(curseurInventaire == 4)strokeWeight(3);
  image(chemin,0,240,60,60);
  noFill();
  rect(0,240,60,60);
  strokeWeight(1);
  
  //beton
  if(curseurInventaire == 5)strokeWeight(3);
  image(beton,0,300,60,60);
  noFill();
  rect(0,300,60,60);
  strokeWeight(1);
  
  //arbre
  if(curseurInventaire == 6)strokeWeight(3);
  PImage arbreCut = arbreimg.get(0,0,256,256);
  image(arbreCut,0,360,60,60);
  noFill();
  rect(0,360,60,60);
  strokeWeight(1);
  
  strokeWeight(5);
  stroke(0);
  line(60,0,60,height);
  strokeWeight(1);
  
  stroke(0);
  
}

void testPosInvent(){
  if(mousePressed == true){
    if(mouseX < 60 && mouseY < 420){
      curseurInventaire = int(mouseY / 60);  
    }
  }
}

void setTuile(){
  if(mousePressed == true){
    if(mouseX >= 60){
      if(curseurInventaire < 6){
        map[posY+int(mouseY / 60)][posX+int((mouseX-60) / 60)] = curseurInventaire + 1;
      }
      else{
        //objet(arbre, maison...)
        if(nb_arbre < 300){
          arbre[nb_arbre].x = posX*60 + (mouseX - 35);
          arbre[nb_arbre].y = posY*60 + (mouseY - 35);
          nb_arbre++;
          delay(300);
        }
      }
    }
  }  
}

void afficheTuile(){
  for(int i = 0; i < 10;i++){
    for(int j = 0; j < 10;j++){
      /*if(map[i+posY][j+posX] == 0)fill(255); 
      if(map[i+posY][j+posX] == 1)fill(0,175,10); 
      if(map[i+posY][j+posX] == 2)fill(255,200,0);
      if(map[i+posY][j+posX] == 3)fill(0,100,255);
      if(map[i+posY][j+posX] == 4)fill(50,50,50);
      if(map[i+posY][j+posX] == 5)fill(150,180,0);
      rect((j*60+60),(i*60),60,60);*/ 
      
      if(map[i+posY][j+posX] == 0)fill(255);
      if(map[i+posY][j+posX] == 1)image(herbe,j*60+60,i*60,60,60);
      if(map[i+posY][j+posX] == 2)image(sable,j*60+60,i*60,60,60);
      if(map[i+posY][j+posX] == 3)image(eau,j*60+60,i*60,60,60);
      if(map[i+posY][j+posX] == 4)image(route,j*60+60,i*60,60,60);
      if(map[i+posY][j+posX] == 5)image(chemin,j*60+60,i*60,60,60);
      if(map[i+posY][j+posX] == 6)image(beton,j*60+60,i*60,60,60);
      
    }   
  } 
}

void deplaceMap(){
  if(keyPressed == true){
    if(keyCode == UP){
      if(posY > 0)
        posY--;  
      
      
      delay(100);
    }
    if(keyCode == DOWN){
      if(posY < 90)
        posY++;  
      
      delay(100);
    }
    if(keyCode == RIGHT){
      if(posX < 90)
        posX++;  
      
      delay(100);
    }
    if(keyCode == LEFT){
      if(posX > 0)
        posX--;  
      
      delay(100);
    }
    
  }
  
}

void saveMap(){
  if(keyPressed == true){
    if(key == ' '){
      
      String name = "map";
      
      filemap = createWriter(name);
      //SAUVEGARDE
      println("Enregistrement...");
      
      filemap.print("{\"map\": [");
      for(int i = 0; i < 100;i++){
        for(int j = 0; j < 100;j++){
          filemap.print(map[i][j]); 
          if(i*100+j != 9999)filemap.print(",");
        }
      } 
      filemap.print("],");;
      //arbre
      filemap.print("\"arbreX\": [");
      for(int i = 0; i < nb_arbre;i++){
        filemap.print(arbre[i].x);
        if(i != nb_arbre-1)filemap.print(",");
      }
      filemap.print("], \"arbreY\": [");
      for(int i = 0; i < nb_arbre;i++){
        filemap.print(arbre[i].y);     
        if(i != nb_arbre-1)filemap.print(",");
      }
      filemap.print("]}");
      
      
      filemap.flush();
      filemap.close();
      delay(5000);
      println("Termine! -> "+name);
    }    
  }
}

void afficheMiniMap(){
  fill(255);
  
  rect(549,489,101,101);
  
  for(int i = 0; i < 100;i++){
    for(int j = 0; j < 100; j++){
      if(map[i][j] == 0)fill(255);
      if(map[i][j] == 1)image(herbe,j+550,i+490,1,1);
      if(map[i][j] == 2)image(sable,j+550,i+490,1,1);
      if(map[i][j] == 3)image(eau,j+550,i+490,1,1);
      if(map[i][j] == 4)image(route,j+550,i+490,1,1);
      if(map[i][j] == 5)image(chemin,j+550,i+490,1,1);
      if(map[i][j] == 6)image(beton,j+550,i+490,1,1);      
      
    }  
  }
  
  //on affiche tous les arbres
  stroke(0,255,0);
  if(curseurInventaire == 6){
    //on affiche les arbres
    for(int i = 0; i < nb_arbre;i++){
      fill(0,255,0);  
      ellipse((arbre[i].x/60)+550,(arbre[i].y/60)+490,3,3);
    }
  }
  
  noFill();
  stroke(255,0,0);
  rect(posX+549,posY+489,12,12);
  
  
  stroke(0);
  
}

void afficheObjetCurseur(){
  if(curseurInventaire == 6){
    PImage arbreCut = arbreimg.get(0,0,256,256);
    image(arbreCut,mouseX-35,mouseY-35,70,70);
  }
    
  
}

void afficheObjet(){
  //arbre
  for(int i = 0; i < nb_arbre;i++){
    PImage arbreCut = arbreimg.get(0,0,256,256);
    image(arbreCut,arbre[i].x - posX*60,arbre[i].y - posY*60,70,70);      
  }
  
  
}
