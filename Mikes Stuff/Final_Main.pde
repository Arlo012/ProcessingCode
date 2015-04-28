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
  player.applyBehaviors(1,1);
}

void keyPressed()
  {
    if(key == 'h' || key == 'H')
    {
      if(player.leftEngine > 1)
      {
        player.leftEngine -= 5;
      }
    }
    else if(key =='y' || key == 'Y')
    {
      if(player.leftEngine < 501)
      {
        player.leftEngine += 5;
        println(player.leftEngine);
      }
    }
    else if(key == 'k' || key == 'K')
    {
      if(player.leftEngine > 1)
      {
        player.rightEngine -= 5;
      }
    }
    else if(key =='i' || key == 'I')
    {
      if(player.leftEngine < 501)
      {
        player.rightEngine += 5;
      }
    }
  }
