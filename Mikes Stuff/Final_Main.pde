//Enviornment
int sector;
PImage asteroidIMG;
PImage planetIMG;
PImage enemyIMG;
Player player;

void setup()
{
  size(displayWidth,displayHeight);
  asteroidIMG = loadImage("asteroid.png");
  planetIMG = loadImage("p10shaded.png");
  enemyIMG = loadImage("Fighter.png");
  
  player = new Player();
}
void draw()
{
  background(0);
  player.display();
  player.update();
}
