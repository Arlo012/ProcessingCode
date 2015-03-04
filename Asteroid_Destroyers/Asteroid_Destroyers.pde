import java.util.Map;
import java.util.Map;
import java.util.HashMap;
import java.util.Random;
import java.util.Iterator;

//Random number generator
Random rand = new Random();

//Game Name
String title = "Asteroid Destroyers";

//Teams
Civilization P1, P2;

//Game stage
GameStage gameStage;

//Image Assetss
PImage bg;             //Background
PImage lion, skull;    //Icons

//Game objects
ArrayList<Asteroid> asteroids;
ArrayList<Ship> p1Ships, p2Ships;
ArrayList<Planet> p1Planets, p2Planets;

//Game areas
HashMap<String,GameArea> gameAreas;

//Counters
long loopCounter;

//Setup constants
boolean debugMode = false;
boolean profilingMode = false;
boolean asteroidCollisionAllowed = false;

//TODO: Zoom setup
//Handle zooming http://forum.processing.org/one/topic/zoom-based-on-mouse-position.html
float minX, maxX, minY, maxY;
WorldViewData wvd = new WorldViewData();

void setup()
{
  //Window setup
  gameStage = new GameStage("Intro");

  size(1600, 1000);
  frame.setTitle(title);

  //Zoom setup
  cursor(CROSS);
  minX = 0;
  minY = 0;
  maxX = width;
  maxY = height;
  
  //Asset setup
  bg = loadImage("Assets/Backgrounds/image5_0.jpg");
  bg.resize(width, height);

  //Load sprites
  asteroidSpriteSheet = loadImage("Assets/Environment/asteroids.png");
  shipSprite = loadImage("Assets/Ships/10(2).png");
  lion = loadImage("Assets/Icons/Lion.png");
  skull = loadImage("Assets/Icons/Skull.png");
  
  loopCounter = 0;

  //Game area setup
  gameAreas = new HashMap<String, GameArea>();

  //Create asteroid field filling half of the screen
  GameArea asteroidField = new GameArea("Asteroid Field", new PVector(width/3, 0), 
                      new PVector(width/3, height));
  gameAreas.put(asteroidField.GetName(), asteroidField);

  //Create two asteroid spawn areas
  GameArea topAsteroidSpawn = new GameArea("Top Asteroid Spawn", new PVector(width/3, -150), 
                      new PVector(width/3, 100));
  GameArea bottomAsteroidSpawn = new GameArea("Bottom Asteroid Spawn", new PVector(width/3, height + 50), 
                      new PVector(width/3, 100));
  gameAreas.put(topAsteroidSpawn.GetName(), topAsteroidSpawn);
  gameAreas.put(bottomAsteroidSpawn.GetName(), bottomAsteroidSpawn);

  //Left/right player area
  GameArea P1Field = new GameArea("P1 Build Area", new PVector(0, 0), 
                      new PVector(width/3, height));
  GameArea P2Field = new GameArea("P2 Build Area", new PVector(2*width/3, 0), 
                      new PVector(width/3, height));
  P1Field.SetDebugColor(color(0, 0, 255));
  P2Field.SetDebugColor(color(255, 0, 0));
  gameAreas.put(P1Field.GetName(), P1Field);
  gameAreas.put(P2Field.GetName(), P2Field);

  //Game object initializers
  asteroids = new ArrayList<Asteroid>();
  GenerateAsteroids(asteroidField);        //See Helpers.pde
  
  //Ship setup
  p1Ships = new ArrayList<Ship>();
  Ship testShip = new Ship("Test Ship", new PVector(width/8, height/2), 
              new PVector(50, 35), shipSprite, 1000);
  testShip.SetRotationRate(0.05);
  testShip.ChangeVelocity(new PVector(1,0));
  testShip.MoveToTarget(new PVector(width/2, height/2));
  p1Ships.add(testShip);
  
  p2Ships = new ArrayList<Ship>();
  
  //Planet setup
  p1Planets = new ArrayList<Planet>();
  GeneratePlanets(P1Field, p1Planets, 3);
  
  p2Planets = new ArrayList<Planet>();
  GeneratePlanets(P2Field, p2Planets, 3);
  
  //Civilization setup
  P1 = new Civilization(new PVector(0,0), "Robot Jesus Collective", p1Ships);
  P1.SetCivilizationIcon(skull,24);      //TODO icons are broken (freeze game)
  
  P2 = new Civilization(new PVector(width,0), "Normal Squishy Humans", p2Ships);
  P2.SetCivilizationIcon(lion,24);
  
  frameRate(60);
}

void draw()
{
  loopCounter++;
  background(bg);
  

  BeginZoom();

  //Draw Game objects
  DrawAsteroids(asteroids);         //See Visuals.pde
  DrawPlanets(p1Planets);
  DrawPlanets(p2Planets);
  DrawShips(p1Ships);
  

  //Move game objects
  MovePhysicalObject(asteroids);        //See Visuals.pde
  MovePhysicalObject(p1Ships);

  //Check collisions
  if(asteroidCollisionAllowed)
  {
    HandleCollisions(asteroids);            //Self collisions    
  }

  HandleCollisions(asteroids, p1Ships);
  
  //Handle clicks/mouseovers adjusting for zoom
  PVector currentMouseLoc = new PVector(wvd.pixel2worldX(mouseX), wvd.pixel2worldY(mouseY));
  HandleClick(asteroids, currentMouseLoc);
  HandleClick(p1Planets, currentMouseLoc);
  HandleClick(p2Planets, currentMouseLoc);
  HandleClick(p1Ships, currentMouseLoc);
  
  if(debugMode)
  {
    DrawGameArea(gameAreas);       //See Visuals.pde
  }

  EndZoom();
  
  //Draw Civ UI
  P1.DrawCivilizationUI();
  P2.DrawCivilizationUI();

  //TODO: Check for off-screen asteroids, destroy, replace with new
  AsteroidOffScreenUpdate(asteroids, gameAreas);      //See helpers.pde

  
  //TODO: Update game stats, i.e. resources?
  if(profilingMode)
  {
    println(frameRate);
  }

}
