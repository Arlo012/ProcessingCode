import java.util.Map;
import java.util.HashMap;
import java.util.Random;
import java.util.Iterator;
import java.util.LinkedList;

//Random number generator
Random rand = new Random();

//Game Name
String title = "Asteroid Destroyers";

//Teams
Civilization P1, P2;
PlayerController Controller1, Controller2;
PlayerController currentPlayer;   //Who is currently playing

//Game stage
GameStage gameStage;

//Image Assetss
PImage bg;             //Background
PImage lion, skull;    //Icons

//Game objects
ArrayList<Asteroid> asteroids;
ArrayList<Ship> p1Ships, p2Ships;
ArrayList<Planet> p1Planets, p2Planets;
ArrayList<Missile> missiles;
ArrayList<Effect> effects;

//Game areas
HashMap<String,GameArea> gameAreas;

//Counters
long loopCounter;

//Setup constants
TogglableBoolean debugMode = new TogglableBoolean(false);
boolean profilingMode = false;
boolean asteroidCollisionAllowed = false;

//Handle zooming http://forum.processing.org/one/topic/zoom-based-on-mouse-position.html
float minX, maxX, minY, maxY;
WorldViewData wvd = new WorldViewData();

//UI Info
LinkedList<Clickable> toDisplay;        //List of objects to display

//TEST AREA

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
  missileSprite = loadImage("Assets/Weapons/Missile05.png");
  //Load explosions (see effect.pde for variables)
  for (int i = 1; i < explosionImgCount + 1; i++) 
  {
    // Use nf() to number format 'i' into four digits
    String filename = "Assets/Effects/64x48/explosion1_" + nf(i, 4) + ".png";
    explosionImgs[i-1] = loadImage(filename);
  }
  
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
  
  p2Ships = new ArrayList<Ship>();
  
//Planet setup
  p1Planets = new ArrayList<Planet>();
  GeneratePlanets(P1Field, p1Planets, 3);
  
  p2Planets = new ArrayList<Planet>();
  GeneratePlanets(P2Field, p2Planets, 3);
  
//Civilization setup
  P1 = new Civilization(new PVector(0,0), "Robot Jesus Collective", p1Ships, p1Planets);
  P1.SetCivilizationIcon(skull,24);
  
  P2 = new Civilization(new PVector(width,0), "Normal Squishy Humans", p2Ships, p2Planets);
  P2.SetCivilizationIcon(lion,24);
  
//Controller setup
  Controller1 = new PlayerController(P1);
  //Controller2 = new PlayerController(P2);
  currentPlayer = Controller1;
  
//UI setup
  toDisplay = new LinkedList<Clickable>();
  
  frameRate(60);
  
//Effects setup
  effects = new ArrayList<Effect>();
  
//TEST AREA
  Missile testMissile = new Missile(new PVector(width/4, 200), new PVector(0.5,0));
  Missile testMissile2 = new Missile(new PVector(width/4, 400), new PVector(0.5,0));
  Missile testMissile3 = new Missile(new PVector(width/4, 600), new PVector(0.5,0));
  Missile testMissile4 = new Missile(new PVector(width/4, 800), new PVector(0.5,0));
  missiles = new ArrayList<Missile>();
  missiles.add(testMissile);
  missiles.add(testMissile2);
  missiles.add(testMissile3);
  missiles.add(testMissile4);
  
  Ship testShip = new Ship("Test Ship", new PVector(width - width/8, height/3), 
              new PVector(30, 22), shipSprite, 1000);
  testShip.SetRotationRate(0.05);
  testShip.ChangeVelocity(new PVector(0,0));
  testShip.SetRotationMode(RotationMode.INSTANT);
  testShip.SetDestinationAngle(PI);
  p2Ships.add(testShip);
  
  Ship testShip2 = new Ship("Test Ship2", new PVector(width/8, height/3), 
              new PVector(30, 22), shipSprite, 1000);
  testShip2.SetRotationMode(RotationMode.FACE);
  testShip2.SetRotationRate(0.05);
  p1Ships.add(testShip2);
}

void draw()
{
  loopCounter++;
  if(debugMode.value)
  {
    background(0);
  }
  else
  {
    background(bg);
  }

  
//******* ALL ZOOMED AFTER THIS ********//
  BeginZoom();
  
  //If zoomed out far enough, draw object icons with the objects
  if(wvd.viewRatio < 1.5)
  {
    //Draw Game objects
    DrawAsteroids(asteroids, true);         //See Visuals.pde
    DrawPlanets(p1Planets);
    DrawPlanets(p2Planets);
    DrawShips(p1Ships, true);
    DrawShips(p2Ships, true);
    DrawMissiles(missiles, true);
    DrawEffects(effects);
  }
  else
  {
    //Draw Game objects
    DrawAsteroids(asteroids, false);         //See Visuals.pde
    DrawPlanets(p1Planets);
    DrawPlanets(p2Planets);
    DrawShips(p1Ships, false);
    DrawShips(p2Ships, false);
    DrawMissiles(missiles, false);
    DrawEffects(effects);
  }
  
  //Move game objects
  MovePhysicalObject(asteroids);        //See Visuals.pde
  MovePilotableObject(p1Ships);
  MovePilotableObject(p2Ships);
  MovePilotableObject(missiles);

  //Check collisions
  if(asteroidCollisionAllowed)
  {
    HandleCollisions(asteroids);            //Self collisions    
  }

  HandleCollisions(asteroids, p1Ships);
  HandleCollisions(asteroids, p2Ships);
  HandleWeaponCollisions(missiles, asteroids);
  HandleWeaponCollisions(missiles, p1Ships);
  HandleWeaponCollisions(missiles, p2Ships);
  
//******* UI ********//

//Mouseover text window info
  PVector currentMouseLoc = new PVector(wvd.pixel2worldX(mouseX), wvd.pixel2worldY(mouseY));
  
  //Add response from overlap checks to 'toDisplay' linkedlist
  toDisplay.clear();
  toDisplay.add(CheckClickableOverlap(asteroids, currentMouseLoc));
  toDisplay.add(CheckClickableOverlap(p1Planets, currentMouseLoc));
  toDisplay.add(CheckClickableOverlap(p2Planets, currentMouseLoc));
  toDisplay.add(CheckClickableOverlap(p1Ships, currentMouseLoc));
  
  for(int i = 0; i < toDisplay.size(); i++)
  {
    Clickable _click = toDisplay.poll();
    if(_click != null)
    {
      if(_click.GetClickType() == ClickType.INFO)
      {
        _click.MouseOver();
      }
      else
      {
        print("Moused over unsupported UI type: ");
        print(_click.GetClickType());
        print("\n");
      }
    }
  }

  
//Debug mode display
  if(debugMode.value)
  {
    DrawGameArea(gameAreas);       //See Visuals.pde
  }

//******* ALL ZOOMED BEFORE THIS ********//
  EndZoom();
  
//Draw Civ UI
  P1.DrawCivilizationUI();
  P2.DrawCivilizationUI();
  
//Draw main interface
  currentPlayer.DrawUI();

//******* UPDATES ********//

  //TODO: Update game stats, i.e. resources?
  //HACK update functions are hard to access generically -- need to individually update each type
      //TODO if I am going to do this, why bother with all of the things in visual that try to be smart about it?
  AsteroidOffScreenUpdate(asteroids, gameAreas);      //See helpers.pde
  
  UpdateShips(p1Ships);
  UpdateShips(p2Ships);
  UpdateAsteroids(asteroids);
  UpdatePlanets(p1Planets);
  UpdatePlanets(p2Planets);
  UpdateMissiles(missiles);
  
  //Update UI information for the main UI
  currentPlayer.UpdateUI();
  
//******* PROFILING ********//
  if(profilingMode)
  {
    println(frameRate);
  }

}
