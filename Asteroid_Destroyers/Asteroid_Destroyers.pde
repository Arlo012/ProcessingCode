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
PlayerController otherPlayer;

//Game stage
GameStage gameStage;

//Image Assetss
PImage bg;             //Background
PImage lion, skull;    //Icons

//Game objects
ArrayList<Asteroid> asteroids;
ArrayList<Ship> p1Ships, p2Ships;
ArrayList<Planet> p1Planets, p2Planets;
ArrayList<Missile> p1Missiles, p2Missiles;
ArrayList<Explosion> explosions;
ArrayList<Station> p1Stations, p2Stations;

//Game areas
HashMap<String,GameArea> gameAreas;

//Counters
long loopCounter;
long loopStartTime;

//Setup constants
TogglableBoolean debugMode = new TogglableBoolean(false);
boolean profilingMode = false;
boolean asteroidCollisionAllowed = false;

//Handle zooming http://forum.processing.org/one/topic/zoom-based-on-mouse-position.html
float minX, maxX, minY, maxY;
WorldViewData wvd = new WorldViewData();

//UI Info
LinkedList<Clickable> toDisplay;        //List of objects to display

//TEST AREA //<>//

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
  //bg = loadImage("Assets/Backgrounds/image5_0.jpg");
  bg = loadImage("Assets/Backgrounds/spacefield_a-000.png");
  bg.resize(width, height);
  
  //Load sprites
  asteroidSpriteSheet = loadImage("Assets/Environment/asteroids.png");
  shipSprite = loadImage("Assets/Ships/10(2).png");
  lion = loadImage("Assets/Icons/Lion.png");
  skull = loadImage("Assets/Icons/Skull.png");
  missileSprite = loadImage("Assets/Weapons/Missile05.png");
  redStation1 = loadImage("Assets/Stations/Spacestation1-1.png");
  redStation2 = loadImage("Assets/Stations/Spacestation1-2.png");
  redStation3 = loadImage("Assets/Stations/Spacestation1-3.png");
  blueStation1 = loadImage("Assets/Stations/Spacestation2-1.png");
  blueStation2 = loadImage("Assets/Stations/Spacestation2-2.png");
  blueStation3 = loadImage("Assets/Stations/Spacestation2-3.png");
  smokeTexture = loadImage("Assets/Effects/Smoke/0000.png");
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
  
//Station setup
  p1Stations = new ArrayList<Station>();
  p2Stations = new ArrayList<Station>();
  
//Missile setup
  p1Missiles = new ArrayList<Missile>();
  p2Missiles = new ArrayList<Missile>();
  
//Civilization setup
  P1 = new Civilization(new PVector(0,0), "Robot Jesus Collective", p1Ships, p1Planets, p1Stations, p1Missiles);
  P1.SetCivilizationIcon(skull,24);
  
  P2 = new Civilization(new PVector(width,0), "Normal Squishy Humans", p2Ships, p2Planets, p2Stations, p2Missiles);
  P2.SetCivilizationIcon(lion,24);
 
//Station setup
  GenerateStations(P1, 4);
  GenerateStations(P2, 4);
  
//Controller setup
  Controller1 = new PlayerController(P1);
  Controller2 = new PlayerController(P2);
  currentPlayer = Controller1;
  otherPlayer = Controller2;
  
//UI setup
  toDisplay = new LinkedList<Clickable>();
  
  frameRate(60);
  loopStartTime = millis();
  
//Effects setup
  explosions = new ArrayList<Explosion>();
  
//TEST AREA
 /*
  Missile testMissile = new Missile(new PVector(width/4, 200), new PVector(0.5,0));
  Missile testMissile2 = new Missile(new PVector(width/4, 400), new PVector(0.5,0));
  Missile testMissile3 = new Missile(new PVector(width/4, 600), new PVector(0.5,0));
  Missile testMissile4 = new Missile(new PVector(width/4, 800), new PVector(0.5,0));
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
  testShip.owner = P2.name;
  p2Ships.add(testShip);
  
  Ship testShip2 = new Ship("Test Ship2", new PVector(width/8, height/3), 
              new PVector(30, 22), shipSprite, 1000);
  testShip2.SetRotationMode(RotationMode.FACE);
  testShip2.SetRotationRate(0.05);
  testShip2.owner = P1.name;
  p1Ships.add(testShip2);
  
  PVector stationLoc = new PVector(p1Planets.get(0).location.x, p1Planets.get(0).location.y - 75);
  PVector stationSize = new PVector(50,50);
  Station stationTest = new Station(StationType.MILITARY, stationLoc, stationSize, blueStation1, p1Planets.get(0));
  stationTest.owner = P1.name;
  p1Stations.add(stationTest);
  
  PVector stationLoc2 = new PVector(p2Planets.get(0).location.x, p2Planets.get(0).location.y - 75);
  PVector stationSize2 = new PVector(50,50);
  Station stationTest2 = new Station(StationType.MILITARY, stationLoc2, stationSize2, redStation1, p2Planets.get(0));
  stationTest2.owner = P2.name;
  p2Stations.add(stationTest2);
  */
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
    DrawPlanets(p1Planets);
    DrawPlanets(p2Planets);
    DrawAsteroids(asteroids, true);         //See Visuals.pde
    DrawShips(p1Ships, true);
    DrawShips(p2Ships, true);
    DrawStations(P1.stations);
    DrawStations(P2.stations);
    DrawMissiles(p1Missiles, true);
    DrawMissiles(p2Missiles, true);
    DrawEffects(explosions);
  }
  else
  {
    //Draw Game objects
    DrawPlanets(p1Planets);
    DrawPlanets(p2Planets);
    DrawAsteroids(asteroids, false);         //See Visuals.pde
    DrawShips(p1Ships, false);
    DrawShips(p2Ships, false);
    DrawStations(P1.stations);
    DrawStations(P2.stations);  
    DrawMissiles(p1Missiles, false);
    DrawMissiles(p2Missiles, false);
    DrawEffects(explosions);
  }
  
  //Move game objects
  MovePhysicalObject(asteroids);        //See Visuals.pde
  MovePilotableObject(p1Ships);
  MovePilotableObject(p2Ships);
  MovePilotableObject(p1Missiles);
  MovePilotableObject(p2Missiles);

  //Check collisions
  if(asteroidCollisionAllowed)
  {
    HandleCollisions(asteroids);            //Self collisions    
  }

  HandleCollisions(asteroids, p1Ships);
  HandleCollisions(asteroids, p2Ships);
  HandleCollisions(asteroids, p1Stations);
  HandleCollisions(asteroids, p2Stations);
  HandleWeaponCollisions(p1Missiles, asteroids);
  HandleWeaponCollisions(p2Missiles, asteroids);
  HandleWeaponCollisions(p2Missiles, p1Ships);
  HandleWeaponCollisions(p1Missiles, p2Ships);
  HandleWeaponCollisions(p2Missiles, p1Stations);
  HandleWeaponCollisions(p1Missiles, p2Stations);
  
//******* UI ********//

//Mouseover text window info
  PVector currentMouseLoc = new PVector(wvd.pixel2worldX(mouseX), wvd.pixel2worldY(mouseY));
  
  //Add response from overlap checks to 'toDisplay' linkedlist
  toDisplay.clear();
  toDisplay.add(CheckClickableOverlap(asteroids, currentMouseLoc));
  toDisplay.add(CheckClickableOverlap(p1Planets, currentMouseLoc));
  toDisplay.add(CheckClickableOverlap(p2Planets, currentMouseLoc));
  toDisplay.add(CheckClickableOverlap(p1Ships, currentMouseLoc));
  toDisplay.add(CheckClickableOverlap(p2Ships, currentMouseLoc));
  toDisplay.add(CheckClickableOverlap(p1Stations, currentMouseLoc));
  toDisplay.add(CheckClickableOverlap(p2Stations, currentMouseLoc));
  
  while(!toDisplay.isEmpty())
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
  AsteroidOffScreenUpdate(asteroids, gameAreas);      //See helpers.pde
  
  UpdateShips(p1Ships);
  UpdateShips(p2Ships);
  UpdateAsteroids(asteroids);
  UpdatePlanets(p1Planets);
  UpdatePlanets(p2Planets);
  UpdateMissiles(p1Missiles);
  UpdateMissiles(p2Missiles);
  UpdateStations(p1Stations);
  UpdateStations(p2Stations);
  //Effects MUST be called as last update. Some update functions have death frame action that will not be called if this runs first
  UpdateExplosions(explosions);       
  
  //Update UI information for the main UI
  currentPlayer.UpdateUI();
  
  //Update civilizations (TODO: move where all other updateships, etc 
      //currently are after migrating them into these functions)
  P1.Update();
  P2.Update();
  
//******* PROFILING ********//
  if(profilingMode)
  {
    println(frameRate);
  }

}
