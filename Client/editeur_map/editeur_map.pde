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

PrintWriter filemap;

void setup(){
  size(660,600);
  herbe = loadImage("Images/herbe.jpg");
  sable = loadImage("Images/sable.jpg");
  eau = loadImage("Images/eau.jpg");
  route = loadImage("Images/route.jpg");
  chemin = loadImage("Images/chemin.jpg");
  beton = loadImage("Images/beton.jpg");
  
  for(int i = 0; i < 100;i++){
    for(int j = 0; j < 100;j++){
      map[i][j] = 1;
    }
  }
  
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
  
}



void draw(){
  background(255);
  
  afficheGrille();
  afficheInventaire();
  testPosInvent();
  
  setTuile();
  afficheTuile();
  deplaceMap();
  saveMap();
  
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
  
  //beton
  if(curseurInventaire == 5)strokeWeight(3);
  image(beton,0,300,60,60);
  noFill();
  rect(0,300,60,60);
  
  strokeWeight(5);
  stroke(0);
  line(60,0,60,height);
  strokeWeight(1);
  
  stroke(0);
  
}

void testPosInvent(){
  if(mousePressed == true){
    if(mouseX < 60 && mouseY < 360){
      curseurInventaire = int(mouseY / 60);  
    }
  }
}

void setTuile(){
  if(mousePressed == true){
    if(mouseX >= 60){
      map[posY+int(mouseY / 60)][posX+int((mouseX-60) / 60)] = curseurInventaire + 1;
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
      
      String name = "map"+millis()+".txt";
      
      filemap = createWriter(name);
      //SAUVEGARDE
      println("Enregistrement...");
      for(int i = 0; i < 100;i++){
        for(int j = 0; j < 100;j++){
          filemap.print(map[i][j]); 
        }
      } 
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
  noFill();
  stroke(255,0,0);
  rect(posX+549,posY+489,12,12);
  stroke(0);
  
  
}
