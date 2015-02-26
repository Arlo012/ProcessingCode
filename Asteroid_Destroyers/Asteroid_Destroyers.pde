
import java.util.Random;

//Random number generator
Random rand = new Random();

//Game Name
String title = "Asteroid Destroyers";

//Game stage
GameStage gameStage;

//Image Assets
PImage bg;

//Game objects
ArrayList<Asteroid> asteroids;
ArrayList<Ship> ships;

//Game areas
ArrayList<GameArea> gameAreas;

//Counters
long loopCounter;

//Setup constants
boolean debugMode = false;

void setup()
{
  //Window setup
  gameStage = new GameStage("Intro");

  size(1600, 1000);
  frame.setTitle(title);

  //Asset setup
  bg = loadImage("Assets/Backgrounds/image5_0.jpg");
  bg.resize(width, height);

  //Load sprites
  asteroidSpriteSheet = loadImage("Assets/Environment/asteroids.png");
  shipSprite = loadImage("Assets/Ships/10(2).png");
  
  loopCounter = 0;

  //Game area setup
  gameAreas = new ArrayList<GameArea>();

  //Create asteroid field filling half of the screen
  GameArea asteroidField = new GameArea("Asteroid Field", width/2, height/2, width/2, height);
  gameAreas.add(asteroidField);

  //Left/right player area
  GameArea P1Field = new GameArea("P1 Build Area", width/8, height/2, width/4, height);
  GameArea P2Field = new GameArea("P2 Build Area", 7*width/8, height/2, width/4, height);
  P1Field.SetDebugColor(color(0, 0, 255));
  P2Field.SetDebugColor(color(255, 0, 0));
  gameAreas.add(P1Field);
  gameAreas.add(P2Field);

  //Game object initializers
  asteroids = new ArrayList<Asteroid>();
  GenerateAsteroids(asteroidField);        //See Helpers.pde
  
  ships = new ArrayList<Ship>();
  Ship testShip = new Ship(width/8, height/2, 125, 97, shipSprite);
  //testShip.velocity = new PVector(.1, .2);
  ships.add(testShip);

}

void draw()
{
  loopCounter++;
  background(bg);
  //DrawGameObjects(asteroids);         //See Visuals.pde
  //DrawGameObjects(ships);
  if(debugMode)
  {
    DrawGameObjects(gameAreas);       //See Visuals.pde
  }
  
  MoveGameObjects(asteroids);        //See Visuals.pde
  MoveGameObjects(ships);
}
