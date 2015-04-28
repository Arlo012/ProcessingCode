//Enviornment
int sector;
PImage asteroidIMG;
PImage planetIMG;
PImage enemyIMG;
PImage bgIMG;
PImage playerIMG;
Player player;

void setup()
{
  size(displayWidth,displayHeight);
  asteroidIMG = loadImage("asteroid.png");
  planetIMG = loadImage("p10shaded.png");
  enemyIMG = loadImage("Fighter.png");
  bgIMG = loadImage("back_3.png");
  playerIMG = loadImage("Human-Battleship.png");
  player = new Player();
}
void draw()
{
  image(bgIMG,0,0);
  player.display();
  player.update();
  player.applyBehaviors();
}

void keyPressed()
  {
    if(key == 'h' || key == 'H')
    {
      if(player.leftEngine > player.minThrust)
      {
        player.leftEngine -= player.minThrust;
      }
    }
    else if(key =='y' || key == 'Y')
    {
      if(player.leftEngine < player.maxThrust)
      {
        player.leftEngine += player.minThrust;
        println(player.leftEngine);
      }
    }
    else if(key == 'k' || key == 'K')
    {
      if(player.leftEngine > player.minThrust)
      {
        player.rightEngine -= .1;
      }
    }
    else if(key =='i' || key == 'I')
    {
      if(player.leftEngine < player.maxThrust)
      {
        player.rightEngine += player.minThrust;
      }
    }
  }
