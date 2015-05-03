import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Map; 
import java.util.HashMap; 
import java.util.LinkedHashMap; 
import java.util.Random; 
import java.util.Iterator; 
import java.util.LinkedList; 
import processing.sound.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class TheVoid extends PApplet {









enum GameState {
  START, INSTRUCTIONS,
  PLAY, PAUSED, GAMEOVER
}

//Random number generator
Random rand = new Random();

GameState gameState = GameState.PLAY;

//Game Name
String title = "The Void";

//TODO Controllers

//Game objects and areas
HashMap<Integer,Sector> sectors;      //Sector IDs mapped against sector objects
HashMap<Integer,Sector> generatedSectors;   //Storage of mid-loop generated sectors for later merging
ArrayList<Sector> visibleSectors;     //Sectors on-screen right now (only render/update these)
ArrayList<Explosion> explosions;      //Explosions are global game object
PVector sectorSize;                   //Set to width/height for now

//Counters
long loopCounter;        //How many loop iterations have been completed
long loopStartTime;      //Millis() time main loop started

//Debugging & profiling
static boolean debuggingAllowed = true;      //Display DEBUG button on GUI?
TogglableBoolean debugMode = new TogglableBoolean(true);
boolean profilingMode = false;

//Handle zooming http://forum.processing.org/one/topic/zoom-based-on-mouse-position.html
float minX, maxX, minY, maxY;
WorldViewData wvd = new WorldViewData();

//UI Info
LinkedList<Clickable> toDisplay;        //List of clickable UI objects to display //<>//

//TEST AREA
Player playerShip;

public void setup()
{
  size(1600, 1200);
  frame.setTitle(title);

  //Zoom setup
  cursor(CROSS);
  minX = 0;
  minY = 0;
  maxX = width;
  maxY = height;

  //Load all image/sound assets
  LoadImageAssets();      //See AssetLoader.pde
  LoadSoundAssets();
  startupFont = loadFont("SourceCodePro-Regular-48.vlw");

  //Game area setup
  sectors = new HashMap<Integer, Sector>();
  sectorSize = new PVector(width*2,height*2);
  visibleSectors = new ArrayList<Sector>();
  explosions = new ArrayList<Explosion>();

  playerShip = new Player(new PVector(width/2, height/2), new PVector(100, 50), 
    shipSprite, 100, color(255,0,0), sectors.get(0));     //Place player in start sector

  //Setup civilizations and their game objects, along with controllers
  GameObjectSetup();    //See AssetLoaders.pde
  
  //Counters & framerate
  loopCounter = 0;
  frameRate(60);
  loopStartTime = millis();
  
  //Intro music
  // introMusic.play();
  // trackStartTime = millis();
  // currentTrack = introMusic;

  //TEST AREA
  sectors.get(0).ships.add(playerShip);

  //HACK just render current sector
  visibleSectors.clear();
  visibleSectors.add(playerShip.currentSector);
}

public void draw()
{
  // MusicHandler();      //Handle background music
  
  if(gameState == GameState.START)
  {
    DrawStartupLoop();
  }
  
  else if(gameState == GameState.PLAY)
  {
    DrawPlayLoop();     //See GameLoops.pde
  }

  else if(gameState == GameState.PAUSED)
  {
    DrawPauseLoop();
  }
  
  else if(gameState == GameState.GAMEOVER)
  {
    DrawGameOverLoop();
  }

}
//Image Assetss
PImage bg;             //Background

//TODO move all PImage instances here
PImage redLaser, greenLaser;
ArrayList<PImage> enemyShipSprites; 
ArrayList<PVector> enemyShipSizes;      //Size (by index) of above sprite
int enemyShipCount = 10;                //HACK this is rigid -- careful to update if add ships
public void LoadImageAssets()
{
  bg = loadImage("Assets/Backgrounds/back_3.png");
  bg.resize(width, height);
  
  //Load sprites
  asteroidSpriteSheet = loadImage("Assets/Environment/asteroids.png");
  shipSprite = loadImage("Assets/Ships/10(2).png");

  //enemy ships
  enemyShipSprites = new ArrayList<PImage>();
  enemyShipSizes = new ArrayList<PVector>();

  //Total of 10 enemy ship sprites
  enemyShipSprites.add(loadImage("Assets/Ships/7(1).png"));
  enemyShipSizes.add(new PVector(257,140));
  enemyShipSprites.add(loadImage("Assets/Ships/8(1).png"));
  enemyShipSizes.add(new PVector(232,182));
  enemyShipSprites.add(loadImage("Assets/Ships/9(1).png"));
  enemyShipSizes.add(new PVector(336,230));
  enemyShipSprites.add(loadImage("Assets/Ships/10(1).png"));
  enemyShipSizes.add(new PVector(110,116));
  enemyShipSprites.add(loadImage("Assets/Ships/11(1).png"));
  enemyShipSizes.add(new PVector(225,398));
  enemyShipSprites.add(loadImage("Assets/Ships/12(1).png"));
  enemyShipSizes.add(new PVector(122,342));
  enemyShipSprites.add(loadImage("Assets/Ships/13(1).png"));
  enemyShipSizes.add(new PVector(104,168));
  enemyShipSprites.add(loadImage("Assets/Ships/1(1).png"));
  enemyShipSizes.add(new PVector(135,124));
  enemyShipSprites.add(loadImage("Assets/Ships/2(1).png"));
  enemyShipSizes.add(new PVector(199,134));
  enemyShipSprites.add(loadImage("Assets/Ships/3(1).png"));
  enemyShipSizes.add(new PVector(248,182));

  missileSprite = loadImage("Assets/Weapons/Missile05.png");
  redStation1 = loadImage("Assets/Stations/Spacestation1-1.png");
  redStation2 = loadImage("Assets/Stations/Spacestation1-2.png");
  redStation3 = loadImage("Assets/Stations/Spacestation1-3.png");
  blueStation1 = loadImage("Assets/Stations/Spacestation2-1.png");
  blueStation2 = loadImage("Assets/Stations/Spacestation2-2.png");
  blueStation3 = loadImage("Assets/Stations/Spacestation2-3.png");
  smokeTexture = loadImage("Assets/Effects/Smoke/0000.png");
  redLaser = loadImage("Assets/Weapons/redLaser.png");
  greenLaser = loadImage("Assets/Weapons/greenLaser.png");
  
  //Load explosions (see Explosion.pde for variables)
  for (int i = 1; i < explosionImgCount + 1; i++) 
  {
    // Use nf() to number format 'i' into four digits
    String filename = "Assets/Effects/64x48/explosion1_" + nf(i, 4) + ".png";
    explosionImgs[i-1] = loadImage(filename);
  }
}

SoundFile explosionSound, collisionSound, laserSound, 
    clickShipSpawnButtonSound, clickMissileSpawnButtonSound, clickNormalModeButtonSound, 
    clickCancelOrderButtonSound, errorSound, shieldHitSound;
    
SoundFile introMusic;
ArrayList<SoundFile> mainTracks;
public void LoadSoundAssets()
{
  String sketchDir = sketchPath("");    //Get current directory
  explosionSound = new SoundFile(this, sketchDir + "Assets/SoundEffects/Impact/explosion2.wav");
  collisionSound = new SoundFile(this, sketchDir + "Assets/SoundEffects/Impact/Hit Impact Metal Scrap Debris_UC 06.wav");
  laserSound = new SoundFile(this, sketchDir + "Assets/SoundEffects/Weapons/laser6.wav");
  clickShipSpawnButtonSound = new SoundFile(this, sketchDir + "Assets/SoundEffects/UI/AstroDroid11.wav");
  clickMissileSpawnButtonSound = new SoundFile(this, sketchDir + "Assets/SoundEffects/UI/AstroDroid26.wav");
  clickNormalModeButtonSound = new SoundFile(this, sketchDir + "Assets/SoundEffects/UI/on.ogg");
  clickCancelOrderButtonSound = new SoundFile(this, sketchDir + "Assets/SoundEffects/UI/off.ogg");
  errorSound = new SoundFile(this, sketchDir + "Assets/SoundEffects/UI/error.wav");
  shieldHitSound = new SoundFile(this, sketchDir + "Assets/SoundEffects/Impact/138489__randomationpictures__shield-hit-2.wav");

  //Music
  introMusic = new SoundFile(this, sketchDir + "Assets/Music/ZanderNoriega-Darker_Waves_0.mp3");
  mainTracks = new ArrayList<SoundFile>();
  SoundFile track1 = new SoundFile(this, sketchDir + "Assets/Music/e.ogg");
  SoundFile track2 = new SoundFile(this, sketchDir + "Assets/Music/Nebulous.mp3");
  SoundFile track3 = new SoundFile(this, sketchDir + "Assets/Music/poss_-_next_-_attack.mp3");
  SoundFile track4 = new SoundFile(this, sketchDir + "Assets/Music/streetsound_150_bpm.mp3");
  mainTracks.add(track1); 
  mainTracks.add(track2);
  mainTracks.add(track3);
  mainTracks.add(track4);
}


int sectorID = 1;      //Unique sector ID. Begin generating @ 1 because the startSector has ID = 0
SectorDirection[] sectorDirections = new SectorDirection[]{SectorDirection.UL, SectorDirection.Above, 
  SectorDirection.UR, SectorDirection.Left, SectorDirection.Right, SectorDirection.LL, 
  SectorDirection.Below, SectorDirection.LR};
/**
 * Generate sectors around the provided sector. Check which sectors have already been
 * generated by using the sector's neighbor pointers.
 * @param {Sector} _origin The starting sector from which to generate surrounding sectors
 * @return {HashMap<Integer,Sector>} Mapping of sector IDs to sector objects
 */
public HashMap<Integer,Sector> BuildSectors(Sector _origin)
{
  //Hold a list of sectors to generate linkings
  Sector[] sectorGenArray = new Sector[9];
  sectorGenArray[4] = _origin;      //origin is at core of these 9 sectors
  int sectorCounter = 0;

  HashMap<Integer,Sector> generatedSectors = new HashMap<Integer,Sector>();

  //Check all 8 surrounding sectors 
  for(SectorDirection direction : sectorDirections)
  {
    Sector neighbor;     //Sector to generate or grab below
    if(!_origin.HasNeighbor(direction))
    {
      //No neighbor in this direction -- generate one
      PVector sectorLocation = _origin.GetNeighborLocation(direction);
      neighbor = new Sector(sectorID, sectorLocation, sectorSize, bg, SectorType.RANDOM);
      generatedSectors.put(sectorID, neighbor);
      sectorID++;     //Next unique ID for this sector!
    }
    else
    {
      neighbor = _origin.GetNeighbor(direction);
    }

    sectorGenArray[sectorCounter] = neighbor;   //Track an adjacent sector

    sectorCounter++;            //Next sector!
    if(sectorCounter == 4)      //Skip -- this is the core
    {
      sectorCounter++;
    }
  }

  //Attach adjacent sectors to each other
  for(int i = 1; i < 10; i++)
  {
    if(i%3 != 0)    //If not far right side
    {
      sectorGenArray[i-1].SetNeighbor(SectorDirection.Right, sectorGenArray[i]);
      if(i > 3)   //Not top row
      {
        sectorGenArray[i-1].SetNeighbor(SectorDirection.UR, sectorGenArray[i-3]);
      }
      if( i < 7)   //Not bottom row
      {
        sectorGenArray[i-1].SetNeighbor(SectorDirection.LR, sectorGenArray[i+3]);
      }
    }
    if(i != 1 && i%4 != 0)    //Not far left side
    {
      sectorGenArray[i-1].SetNeighbor(SectorDirection.Left, sectorGenArray[i-2]);
      if(i > 3)   //Not top row
      {
        sectorGenArray[i-1].SetNeighbor(SectorDirection.UL, sectorGenArray[i-5]);
      }
      if( i < 7)   //Not bottom row
      {
        sectorGenArray[i-1].SetNeighbor(SectorDirection.LL, sectorGenArray[i+1]);
      }
    }
    if(i > 3)     //Not top row
    {
      sectorGenArray[i-1].SetNeighbor(SectorDirection.Above, sectorGenArray[i-4]);
    }
    if(i < 7)     //Not bottom row
    {
      sectorGenArray[i-1].SetNeighbor(SectorDirection.Below, sectorGenArray[i+2]);
    }   
  }
  return generatedSectors;
}


/**
 * Load assets such as sprites, music, and build all sectors.
 */
public void GameObjectSetup()
{
  LoadImageAssets();
  LoadSoundAssets();
  
  Sector startSector = new Sector(0, new PVector(0,0), sectorSize, bg, SectorType.PLANETARY);
  sectors.put(0, startSector);
  
  //Generate other sectors around this one
  println("[INFO] Generating sectors around the origin...");
  sectors.putAll(BuildSectors(startSector));     //Generate new sectors, force into current
  println("[INFO] Start sector generation complete! There are now " + sectorID + " sectors generated.");

  //DEBUG FOR LINKING SECTORS
  if(debugMode.value)
  {
    println(startSector);
  }
  
}

/**
 * Merge the provided mapping into the current secto rmap
 * @param toMerge Generated sectors we want to merge in after all loops are complete
 */
public void MergeSectorMaps(HashMap<Integer,Sector> toMerge)
{
  if(toMerge != null)
  {
    Iterator it = toMerge.entrySet().iterator();
    while (it.hasNext()) 
    {
      Map.Entry pair = (Map.Entry)it.next();
      sectors.put((Integer)pair.getKey(), (Sector)pair.getValue());   //Hack unchecked cast
      
      if(debugMode.value)
      {
        println("[DEBUG] Added new entry pair to sector map");
      }
      it.remove();      //Avoids a ConcurrentModificationException
    }
  }

}
//Each sprite spaced 128 pixels apart
PImage asteroidSpriteSheet;      //Loaded in setup()

/*
 * An asteroid gameobject, inheriting from Physical
 */
public class Asteroid extends Physical implements Updatable
{
  private static final int minDiameter = 10;
  private static final int maxDiameter = 30;
  private static final int maxAsteroidHealth = 100;
  
  private boolean isDebris = false;        //Is this asteroid just debris from another asteroid's death?
  
  public Asteroid(PVector _loc, int _diameter, int _mass, Sector _sector) 
  {
    //Parent constructor
    super("Asteroid", _loc, new PVector(_diameter, _diameter), _mass, _sector);
    
    //Select my asteroid image from spritesheet     
    int RandomAsteroidIndex1 = rand.nextInt(8);      //x coordinate in sprite sheet
    int RandomAsteroidIndex2 = rand.nextInt(8);      //y coordinate in sprite sheet

    //Set the sprite to the random subset of the spritesheet
    sprite = asteroidSpriteSheet.get(RandomAsteroidIndex1 * 128, RandomAsteroidIndex2 * 128, 128, 128);
    
    //Scale by 128/90 where 128 is provided size above and 90 is actual size of the asteroid sprite
    sprite.resize(PApplet.parseInt(size.x * 128/90), PApplet.parseInt(size.y * 128/90));
    
    //Setup health, scaled by size relative to max size
    health.max = (int)(size.x/maxDiameter * maxAsteroidHealth);      //Health scaled to size, take advantage of integer division to round
    health.current = health.max;
  }
  
  @Override public void Update()
  {
    super.Update();

    //Update icon overlay
    iconOverlay.UpdateLocation(location);
    
    if(toBeKilled && !isDebris)    //Generate debris asteroids iff dying and not already debris
    {
      for(int i = 0; i < 3; i++)
      {
        Asteroid debris = new Asteroid(location, (int)size.x/2, (int)(mass/2), currentSector);
        
        //New velocity with some randomness based on old velocity
        debris.SetVelocity(new PVector(velocity.x/2 + rand.nextFloat()*velocity.x/3-velocity.x/6,
                               velocity.y/2 + rand.nextFloat()*velocity.y/3-velocity.y/6));
        debris.isDebris = true;
        
        //See AsteroidFactory for details on this implementation
        // debris.SetRotationRate(rotationRate);
        // debris.SetRotationMode(RotationMode.SPIN);    //Spinning
        debris.SetMaxSpeed(2.5f);      //Local speed limit for asteroid
        debris.iconOverlay.SetIcon(color(255,0,0),ShapeType._CIRCLE_);
        debris.drawOverlay = true;      //Dont draw overlay by default
        
        //Setup health, scaled by size relative to max size. 1/4 health of std asteroid
        //HACK this just overwrites the constructor
        debris.health.max = (int)(debris.size.x/maxDiameter * maxAsteroidHealth)/8;
        debris.health.current = health.max;
        
        //TODO implement me
        //debrisSpawned.add(debris);
      }
    }
  }

  @Override public void DrawObject()
  {
    super.DrawObject();
    
    //TODO any special actions here? Otherwise remove this override
  }


  /*Click & mouseover UI*/
  public ClickType GetClickType()
  {
    return ClickType.INFO;
  }

  

}
/**
 * Tools to generate asteroid parameters, and return asteroid objects.
 */
public class AsteroidFactory
{
  //Default values
  private PVector maxVelocity = new PVector(0,0);                 //Max velocity in given x/y direction of asteroid

  //Generator values (keep these stored for next asteroid to create
  private int minX, minY, maxX, maxY, size, xCoor, yCoor;
  private float xVelocity, yVelocity;
  private PVector asteroidSizeRange = new PVector(Asteroid.minDiameter, Asteroid.maxDiameter);
  private Sector nextAsteroidSector;      //Sector to place next asteroid on

  /**
   * Constructor for default asteroid factory generation
   */
  AsteroidFactory(){
  }

  /**
   * Constructor for asteroid generation over provided size range
   * @param {PVector} _sizeRange Overriding size range (min, max) of asteroids
   */
  AsteroidFactory(PVector _sizeRange)
  {
    asteroidSizeRange = _sizeRange;
  }
  
  public void SetMaxVelocity(PVector _maxVelocity)
  {
    maxVelocity = _maxVelocity;
  }
  
  /**
   * Generate parameters for the next asteroid generated
   * @param {Sector} _sector Sector to generate on
   * @see  Helpers.pde for implementation
   * @see  GenerateAsteroid() for object construction
   */
  public void SetNextAsteroidParameters(Sector _sector)
  {
    minX = PApplet.parseInt(_sector.GetLocation().x + asteroidSizeRange.x);
    minY = PApplet.parseInt(_sector.GetLocation().y + asteroidSizeRange.y);
    maxX = PApplet.parseInt(_sector.GetSize().x - asteroidSizeRange.x);
    maxY = PApplet.parseInt(_sector.GetSize().y - asteroidSizeRange.y);
  
    size = rand.nextInt(PApplet.parseInt(asteroidSizeRange.y - asteroidSizeRange.x))+ PApplet.parseInt(asteroidSizeRange.x);
    
    //Generate a random X coordinate guaranteed to be within the boundary
    //accounting for the diameter of the asteroid where asteroidSizeRange.y is max size
    xCoor = rand.nextInt(maxX - PApplet.parseInt(asteroidSizeRange.y)) + minX + PApplet.parseInt(asteroidSizeRange.y/2);
    yCoor = rand.nextInt(maxY)+minY;
    
    //Generate random movement vector
    //TODO velocity unused in asteroids!
    xVelocity = 2 * maxVelocity.x * rand.nextFloat() - maxVelocity.x;    //Desensitize in x direction
    yVelocity = 2 * maxVelocity.y * rand.nextFloat() - maxVelocity.y;

    nextAsteroidSector = _sector;
  }
  
  /**
   * Build asteroid with parameters generated in SetNextAsteroidParameters and return it
   * @return {Asteroid} Generated asteroid
   */
  public Asteroid GenerateAsteroid()
  {
    Asteroid toBuild = new Asteroid(new PVector(xCoor, yCoor), size, PApplet.parseInt(100000*size/asteroidSizeRange.y), nextAsteroidSector);
    toBuild.SetVelocity(new PVector(xVelocity, yVelocity));
    toBuild.SetMaxSpeed(2.5f);      //Local speed limit for asteroid
    toBuild.iconOverlay.SetIcon(color(0xffE8E238),ShapeType._CIRCLE_);
    toBuild.drawOverlay = false;      //Dont draw overlay by default
    
    return toBuild;
  }
  
  public PVector GetNextAsteroidLocation()
  {
    return new PVector(xCoor, yCoor);
  }
  
  public int Size()
  {
    return size;
  }
  
  //Force the asteroid's Y direction to have this sign (for use with spawn areas)
  public void OverrideYDirection(float _sign)
  {
    if(_sign > 0)    //DOWN, positive
    {
      if(yVelocity < 0)    //Flip, making positive
      {
        yVelocity *= -1;
      }
    }
    else            //UP, negative
    {
      if(yVelocity > 0)
      {
        yVelocity *= -1;    //Flip, making negative
      }
    }
  }
}
//Handle collisiosn between two sets of drawable objects
//ONLY VALID FOR CIRCLES/ RECTANGLES


/**
 * Handle intra-sector collisions between ships and asteroids
 * @param {Map<Integer, Sector>} _sectors Sector to do collision checks on
 */
public void HandleSectorCollisions(Map<Integer, Sector> _sectors)
{
  for(Sector a : _sectors.values())
  {
    HandleCollisions(a.asteroids, a.ships);
  }
}

public void HandleCollisions(ArrayList<? extends Physical> a, ArrayList<? extends Physical> b)
{
  for(Physical obj1 : a)
  {
    for(Physical obj2 : b)
    {
      if(obj1.collidable && obj2.collidable)
      {
        if(obj1.location.x + obj1.size.x/2 >= obj2.location.x - obj2.size.x/2    //X from right
            && obj1.location.y + obj1.size.y/2 >= obj2.location.y - obj2.size.y/2  //Y from top
            && obj1.location.x - obj1.size.x/2 <= obj2.location.x + obj2.size.x/2  //X from left
            && obj1.location.y - obj1.size.y/2 <= obj2.location.y + obj2.size.y/2)    //Y from bottom
        {
          
          if(debugMode.value)
          {
            print("COLLISION BETWEEN: ");
            print(obj1.name);
            print(" & ");
            print(obj2.name);
            print("\n");
          }
          collisionSound.play();
          obj1.HandleCollision(obj2);
          obj2.HandleCollision(obj1);
        }
      }

    }
  }
}

//ONLY VALID FOR CIRCLES/ RECTANGLES
public void HandleCollisions(ArrayList<? extends Physical> a)
{
  for(int i = 0; i < a.size(); i++)
  {
    for(int j = 0; j < a.size(); j++)
    {
      if(i != j)        //Don't compare to myself
      {
        if(a.get(i).location.x + a.get(i).size.x/2 >= a.get(j).location.x - a.get(j).size.x/2    //X from right
          && a.get(i).location.y + a.get(i).size.y/2 >= a.get(j).location.y - a.get(j).size.y/2  //Y from top
          && a.get(i).location.x - a.get(i).size.x/2 <= a.get(j).location.x + a.get(j).size.x/2  //X from left
          && a.get(i).location.y - a.get(i).size.y/2 <= a.get(j).location.y + a.get(j).size.y/2)    //Y from bottom
        {
          if(debugMode.value)
          {
            print("COLLISION BETWEEN: ");
            print(a.get(i).GetID());
            print(" & ");
            print(a.get(j).GetID());
            print("\n");
          } //<>//
          collisionSound.play(); //<>//
          //Give both collision handlers info about the other
          a.get(i).HandleCollision(a.get(j)); //<>//
          a.get(j).HandleCollision(a.get(i)); //<>//
        }
      }
    }
  }
}

public void HandleShieldCollisions(ArrayList<? extends Shield> s, ArrayList<? extends Physical> b)
{
  for(Shield shield : s)
  {
    for(Physical obj2 : b)
    {
      if(shield.collidable && obj2.collidable)
      {
        if(shield.location.x + shield.size.x/2 >= obj2.location.x - obj2.size.x/2    //X from right
            && shield.location.y + shield.size.y/2 >= obj2.location.y - obj2.size.y/2  //Y from top
            && shield.location.x - shield.size.x/2 <= obj2.location.x + obj2.size.x/2  //X from left
            && shield.location.y - shield.size.y/2 <= obj2.location.y + obj2.size.y/2)    //Y from bottom
        {
          
          if(debugMode.value)
          {
            print("COLLISION BETWEEN: ");
            print(shield.name);
            print(" & ");
            print(obj2.name);
            print("\n");
          }
          shieldHitSound.play();
          shield.HandleCollision(obj2);
          obj2.HandleCollision(shield);
        }
      }
    }
    
    
  }
}

//ONLY VALID FOR CIRCLES/ RECTANGLES
public void HandleMissileCollision(ArrayList<? extends Missile> a, ArrayList<? extends Physical> b)
{
  for(Missile obj1 : a)
  {
    //TODO add a check if in the same GameArea?
    for(Physical obj2 : b)
    {
      if(obj1.collidable && obj2.collidable)
      {
        if(obj1.location.x + obj1.size.x/2 >= obj2.location.x - obj2.size.x/2    //X from right
            && obj1.location.y + obj1.size.y/2 >= obj2.location.y - obj2.size.y/2  //Y from top
            && obj1.location.x - obj1.size.x/2 <= obj2.location.x + obj2.size.x/2  //X from left
            && obj1.location.y - obj1.size.y/2 <= obj2.location.y + obj2.size.y/2)    //Y from bottom
        {
          
          if(debugMode.value)
          {
            print("INFO: COLLISION BETWEEN: ");
            print(obj1.name);
            print(" & ");
            print(obj2.name);
            print("\n");
          }
          
          collisionSound.play();    //TODO migrate this to missile object
          obj1.HandleCollision(obj2);
          obj2.HandleCollision(obj1);
        }
      }
    }
  }
}

//ONLY VALID FOR CIRCLES/ RECTANGLES
public void HandleLaserCollision(ArrayList<? extends LaserBeam> a, ArrayList<? extends Physical> b)
{
  for(LaserBeam obj1 : a)
  {
    //TODO add a check if in the same GameArea?
    for(Physical obj2 : b)
    {
      if(obj1.collidable && obj2.collidable)
      {
        if(obj1.location.x + obj1.size.x/2 >= obj2.location.x - obj2.size.x/2    //X from right
          && obj1.location.y + obj1.size.y/2 >= obj2.location.y - obj2.size.y/2  //Y from top
          && obj1.location.x - obj1.size.x/2 <= obj2.location.x + obj2.size.x/2  //X from left
          && obj1.location.y - obj1.size.y/2 <= obj2.location.y + obj2.size.y/2)    //Y from bottom
        {
          
          if(debugMode.value)
          {
            print("INFO: COLLISION BETWEEN: ");
            print(obj1.name);
            print(" & ");
            print(obj2.name);
            print("\n");
          }
          
          collisionSound.play();
          obj1.HandleCollision(obj2);    //Laser acts on the gameobject, but no response back to the laser
        }
      }

    }
  }
}

//Handle a click with any drawable objects and a given point, checking of the obj is clickable
public Clickable CheckClickableOverlap(ArrayList<? extends Drawable> a, PVector point)
{
  PVector collisionOffset;      //Offset due to center vs rect rendering (rect = 0 offset)
  for(Drawable obj1 : a)
  {
    //Check if this is CENTER or CORNER rendered -- center rendered needs to account for half size of self
    if(obj1.renderMode == CENTER)
    {
      collisionOffset = new PVector(-obj1.size.x/2, -obj1.size.y/2);
    }
    else if(obj1.renderMode == CORNER)
    {
      collisionOffset = new PVector(0,0);
    }
    else
    {
      collisionOffset = new PVector(obj1.size.x/2, obj1.size.y/2);
      print("WARNING: Unsupported collision offset mode on");
      print(obj1.name);
      print("\n");
    }
    
    if(point.x >= obj1.location.x + collisionOffset.x
      && point.y >= obj1.location.y + collisionOffset.y
      && point.y <= obj1.location.y + collisionOffset.y + obj1.size.y
      && point.x <= obj1.location.x + collisionOffset.x + obj1.size.x)
    {
      if(obj1 instanceof Clickable)
      {
        Clickable clickable = (Clickable)obj1;
        return clickable;
      }
    }
  }
  
  return null;
}

//Handle a click with any drawable object and a given point, checking of the obj is clickable
public Clickable CheckClickableOverlap(Drawable obj1, PVector point)
{
  PVector collisionOffset;      //Offset due to center vs rect rendering (rect = 0 offset)
  
  //Check if this is CENTER or CORNER rendered -- center rendered needs to account for half size of self
  if(obj1.renderMode == CENTER)
  {
    collisionOffset = new PVector(-obj1.size.x/2, -obj1.size.y/2);
  }
  else if(obj1.renderMode == CORNER)
  {
    collisionOffset = new PVector(0,0);
  }
  else
  {
    collisionOffset = new PVector(obj1.size.x/2, obj1.size.y/2);
    print("WARNING: Unsupported collision offset mode on");
    print(obj1.name);
    print("\n");
  }
  
  if(point.x >= obj1.location.x + collisionOffset.x
    && point.y >= obj1.location.y + collisionOffset.y
    && point.y <= obj1.location.y + collisionOffset.y + obj1.size.y
    && point.x <= obj1.location.x + collisionOffset.x + obj1.size.x)
  {
    if(obj1 instanceof Clickable)
    {
      Clickable clickable = (Clickable)obj1;
      return clickable;
    }
  }

  return null;
}

//Check if a point falls within a shape object
public boolean CheckShapeOverlap(Shape obj, PVector point)
{
  if(obj != null)
  {  
    PVector collisionOffset;      //Offset due to center vs rect rendering (rect = 0 offset)
    //Check if this is CENTER or CORNER rendered -- center rendered needs to account for half size of self
    if(obj.renderMode == CENTER)
    {
      collisionOffset = new PVector(-obj.size.x/2, -obj.size.y/2);
    }
    else if(obj.renderMode == CORNER)
    {
      collisionOffset = new PVector(0,0);
    }
    else
    {
      collisionOffset = new PVector(obj.size.x/2, obj.size.y/2);
      print("WARNING: Unsupported collision offset mode on");
      print(obj.name);
      print("\n");
    }
    
    if(point.x >= obj.location.x + collisionOffset.x
      && point.y >= obj.location.y + collisionOffset.y
      && point.y <= obj.location.y + collisionOffset.y + obj.size.y
      && point.x <= obj.location.x + collisionOffset.x + obj.size.x)
    {
      return true;
    }
  }
  
  return false;
}
int uniqueIDCounter = 0;
/* Drawable
 * Base class for all drawable objects in the project
 * Implements a basic DrawObject() method
 */
public class Drawable
{
  protected int ID;
  protected String name;
  
  //Image properties
  protected PVector location;               //On absolute plane
  protected PVector size;               
  public float baseAngle;                   //Starting angle in degrees
  public int renderMode = CENTER;          //Render mode for visible outline
  boolean toBeKilled = false;              //Does this object need to be destroyed?
  
  //Visuals
  protected PImage sprite;                 //TODO should be private

  //Movement
  protected PVector forward;               //On absolute plane

  public Drawable(String _name, PVector _loc, PVector _size)
  {
    name = _name;
    
    ID = uniqueIDCounter;
    uniqueIDCounter++;
    
    location = new PVector(_loc.x, _loc.y);
    size = new PVector(_size.x, _size.y);
    
    //Movement
    forward = new PVector(1, 0);      //Forward is by default in the positive x direction
  }
  
  public int GetID()
  {
    return ID;
  }
  
  public String GetName()
  {
    return name;
  }

  //Render this base object's sprite, if it is initialized.
  public void DrawObject()
  {
    pushMatrix();
    pushStyle();
    if(sprite != null)
    {
      translate(location.x, location.y);
      rotate(baseAngle);

      imageMode(renderMode);
      image(sprite, 0, 0);
    }
    else
    {
      print("WARNING: Tried to draw base drawable object with no sprite! ID = ");
      print(ID);
      print("\n");
    }
    popStyle();
    popMatrix();
  }

  public PVector GetLocation()
  {
    return location;
  }

  public PVector GetSize()
  {
    return size;
  }
  
  //Special force-updater for location of a UI element
  public void UpdateLocation(PVector _location)
  {
    location = _location;
  }

}
public class Enemy extends Ship
{
  //AI here
  boolean inAvoid;
  Player player;
  
  
  public Enemy(String _name, PVector _loc, PVector _size, PImage _sprite, int _mass, int _outlineColor, Sector _sector) 
  {
    //Parent constructor
    super(_name, _loc, _size, _sprite, _mass, _outlineColor, _sector);
    player = playerShip;
    inAvoid = false;
    
  }


  @Override public void Update()
  {
   super.Update();
   PVector avoidForce = Avoid(playerShip.location);
   PVector seekForce = Seek(playerShip.location);
   if(CheckShapeOverlap(player.seekCircle, location))    //Sees if within the Seek radius
   {
     if(CheckShapeOverlap(player.avoidCircle, location))
     {
       inAvoid = true;
     }
     if(inAvoid && CheckShapeOverlap(player.seekAgainCircle,location))    //Currently avoiding the player until outside seek again range
     {
       ApplyForce(avoidForce);      //Run away from player
     }
     else      //We've made it outside seek again -- attack player
     {
       ApplyForce(seekForce);
       inAvoid = false;
     } 
   }


   //**** WEAPONS *****//
   //TODO update me for new AI?
    if(millis() - lastFireTime > currentFireInterval)    //Time to fire?
    {
      if(!targets.isEmpty())
      {
        Physical closestTarget = null;    //Default go after first target
        float closestDistance = 99999;
        for(Physical phys : targets)    //Check each target to find if it is closest
        {
          PVector distance = new PVector(0,0);
          PVector.sub(phys.location,location,distance);
          if(distance.mag() < closestDistance)
          {
            closestTarget = phys;
          }
        }
        
        if(closestTarget != null)    //Found a target
        {
          //Calculate laser targeting vector
          PVector targetVector = PVector.sub(closestTarget.location, location);
          targetVector.normalize();        //Normalize to simple direction vector
          targetVector.x += rand.nextFloat() * 0.5f - 0.25f;
          targetVector.y += rand.nextFloat() * 0.5f - 0.25f;
          
          //Create laser object
          LaserBeam beam = new LaserBeam(location, targetVector, currentSector);
          
          //TODO put the beam object somewhere

          lastFireTime = millis();
        }

      }
    }
  }
  
  
  public PVector Seek(PVector target)
  {
    //if(seekAgainDiameter is true && seekRadius true)
    PVector desired = PVector.sub(target, location);
    desired.normalize();
    desired.mult(localSpeedLimit);
    PVector steer= PVector.sub(desired, velocity);
    steer.limit(maxForceMagnitude);
    
    return steer;
  }
  
  public PVector Avoid(PVector target)
  {
    //if(avoidDiameter is true and seekAgainDiameter is false)
    PVector desired = PVector.sub(target,location);
    desired.normalize();
    desired.mult(localSpeedLimit);
    PVector steer= PVector.sub(desired,velocity);
    steer.limit(maxForceMagnitude);
    steer.mult(-1);                             // to flip the direction of the desired vector in the opposite direction of the target
    
    return steer;
  }
}
PImage[] explosionImgs = new PImage[90];
int explosionImgCount = 90;

/*
 * Displays a range of png images to simulate an explosion, and plays a sound
*/
public class Explosion extends Drawable
{
  PImage[] images;                  //Array of images to display
  int imageFrames;                  //How many images (frames) are to be displayed              
  
  //Sound
  SoundFile sound;
  boolean soundPlayed = false;
  
  //Delay action
  int frameDelay = 0;                 //Delay how many frames after creation to draw?
  long frameCountAtSpawn;             //At creation what was the framecount
  
  private int frameCounter = 0;      //Count how many frames of total we have gone thru
  
  Explosion(PVector _loc, PVector _size)
  {
    super("Explosion", _loc, _size);
    
    frameCountAtSpawn = frameCount;
    
    imageFrames = 90;        //based on image count
    images = explosionImgs;  //TODO: add constructor support for different explosion images
    renderMode = CENTER;
    
    sound = explosionSound;
  }
  
  //Delay how many frames from creation to actually render?
  public void SetRenderDelay(int _frames)
  {
    frameDelay = _frames;
  }
  
  @Override public void DrawObject()
  {
    //Have we passed the 'start' point for drawing? If frameDelay = 0, begin immediately
    if(frameCount >= frameCountAtSpawn + frameDelay)     
    {
      if(!soundPlayed)        //Play the explosion sound
      {
        sound.amp(0.5f);
        sound.play();
        soundPlayed = true;
      }
      if(frameCounter < imageFrames)        //Have all frames been drawn?
      {
        sprite = images[frameCounter];      //Update current sprite to the next frame of the explosion
        super.DrawObject();                 //Invoke parent draw function
        frameCounter++;                     //Prepare for next frame
      }
      else
      {
        toBeKilled = true;
      }
    }
  }
}
/*
 * Convenience tab to hold all draw loops. These just play the main draw loop in different game states,
 * as named by their method name.
*/

PFont startupFont;
public void DrawStartupLoop()
{
  background(0);
  
  pushStyle();
  fill(color(255));
  textFont(startupFont, 48);
  textAlign(CENTER, CENTER);
  text("The Void", width/2, height/2);
  
  textFont(startupFont, 24);
  text("Connecting to game controllers....", width/2, 3*height/4);
  
  //TODO actually connect to controllers
  
  popStyle();
}

public void DrawPlayLoop()
{
  textFont(startupFont, 12);
  background(0);
  
  loopCounter++;

//******* ALL ZOOMED AFTER THIS ********//
  BeginZoom();      //See visuals.pde
  translate(width/2 -playerShip.location.x, height/2 - playerShip.location.y);    //Pan camera on ship

  //Only render/update visible sectors (slightly faster)
  // DrawSectors(visibleSectors);
  // UpdateSectors(visibleSectors);
  
  //ALL sectors (slower)
  DrawSectors(sectors);   //Draw sectors (actually just push sector objects onto render lists)
  MoveSectorObjects(sectors);   //Move all objects in the sectors
  HandleSectorCollisions(sectors);
  UpdateSectors(sectors); //Update sectors (and all updatable objects within them)

  //TODO handle object sector transistion

//// ******* UI ********//

//// Mouseover text window info
  // PVector currentMouseLoc = new PVector(wvd.pixel2worldX(mouseX), wvd.pixel2worldY(mouseY));
  
  // //Add response from overlap checks to 'toDisplay' linkedlist
  // toDisplay.clear();
  // toDisplay.add(CheckClickableOverlap(asteroids, currentMouseLoc));
  // toDisplay.add(CheckClickableOverlap(P1.planets, currentMouseLoc));
  // toDisplay.add(CheckClickableOverlap(P1.fleet, currentMouseLoc));
  // toDisplay.add(CheckClickableOverlap(P1.stations, currentMouseLoc));
  
  // while(!toDisplay.isEmpty())
  // {
  //   Clickable _click = toDisplay.poll();
  //   if(_click != null)
  //   {
  //     if(_click.GetClickType() == ClickType.INFO)
  //     {
  //       _click.MouseOver();
  //     }
  //     else
  //     {
  //       print("Moused over unsupported UI type: ");
  //       print(_click.GetClickType());
  //       print("\n");
  //     }
  //   }
  // }

//// ******* ALL ZOOMED BEFORE THIS ********//
   EndZoom();
  
//// Draw main interface
  // currentPlayer.DrawUI();

//// ******* UPDATES ********//
  MergeSectorMaps(generatedSectors);

  // //Effects MUST be called as last update. Some update functions have death frame action that will not be called if this runs first
  // UpdateExplosions(explosions);       
  
  // //Update UI information for the main UI
  // currentPlayer.UpdateUI();
  
//// ******* PROFILING ********//
  if(profilingMode)
  {
    println(frameRate);
  }
  
//// ******* GAMEOVER Condition ********//  
  
}


//Identical to main draw loop, but without updates
public void DrawPauseLoop()
{
 
}


public void DrawGameOverLoop()
{
 
}

//--------- MISC -----------//

SoundFile currentTrack;
long trackStartTime;
int currentTrackIndex = 0;
public void MusicHandler()
{
  if(millis() > trackStartTime + currentTrack.duration()*1000 + 200)    //Track ended 
  {
    if(currentTrackIndex < mainTracks.size())
    {
      println("INFO: New track now playing");
      currentTrack = mainTracks.get(currentTrackIndex);
      currentTrack.play();
      currentTrackIndex++;
      trackStartTime = millis();
    }
    else    //Ran out of songs -- start again
    {
      currentTrackIndex = 0;
      MusicHandler();
    }

  }
}
/*
 * A health class for tracking health on a given object. 
 */

public class Health
{
  int current, max;
  
  Health(int _current, int _max)
  {
    current = _current;
    max = _max;
  }
  
}

int generationPersistenceFactor = 5;     //How hard should I try to generate the requested asteroids?
AsteroidFactory asteroidFactory = new AsteroidFactory();
/**
* This function will generate asteroids in random locations on a given game area. If too 
* many asteroids are requested the function will only generate as many as it can without
* overlapping.
* @param  {Sector} sector Sector to render these asteroids on
* @param  {Integer} initialAsteroidCount how many asteroids to generate (max)
* @see  Sector.pde for implementation, AsteroidFactory.pde for generation of asteroids
*/
public void GenerateAsteroids(Sector sector, int initialAsteroidCount)
{
  println("[INFO] Generating asteroids");
  
  //Tile arraylist constructor 
  int i = 0;      //Iterator  
  int timeoutCounter = 0;    //To check if loop has run too long
  boolean noOverlap = true;    //Is this coordinate original, or will it allow overlap?
  while(i < initialAsteroidCount)
  {
    //Generate new asteroid location, size, etc parameters
    asteroidFactory.SetNextAsteroidParameters(sector);
    
    PVector roidLoc = asteroidFactory.GetNextAsteroidLocation();    //Asteroid location
    int roidSize = asteroidFactory.Size();
    noOverlap = true;    //Assume this coordinate is good to begin
    for(Asteroid roid : sector.asteroids)
    {
      //Check if this asteroid's center + diameter overlaps with roid's center + diameter
      if( Math.abs(roid.GetLocation().x-roidLoc.x) < roid.GetSize().x/2 + roidSize/2 
            && Math.abs(roid.GetLocation().y-roidLoc.y) < roid.GetSize().y/2 + roidSize/2 )
      {
        noOverlap = false;
        println("[INFO] Asteroid location rejected!");
        break;
      }
    }
    
    if(noOverlap)
    { 
      Asteroid toAdd = asteroidFactory.GenerateAsteroid();
      toAdd.baseAngle = rand.nextInt((360) + 1);
      sector.asteroids.add(toAdd);
      i++;
    }
    else
    {
      //Failed to generate the asteroid
      timeoutCounter++;
      if(timeoutCounter > generationPersistenceFactor * initialAsteroidCount)
      {
        print("[WARNING] Asteroid generation failed for ");
        print(initialAsteroidCount - i);
        print(" asteroid(s)\n");
        break;    //abort the generation loop
      }
    }
  }
}


PVector planetSizeRange = new PVector(50, 100);      //Min, max planet size
int borderSpawnDistance = 1;      //How far from the gameArea border should the planet spawn?
/**
* Generate planets in random locations on a given sector
* @param  {Sector} sector Sector to render these planets on
* @param  Integer} count How many planets to spawn
* @see  Sector.pde for implementation
*/
public void GeneratePlanets(Sector sector, int count)
{
  //Guarantee no planets within 3 diameters from the edge of the game area
  println("[INFO] Generating Planets");  
  int minX = PApplet.parseInt(sector.GetLocation().x + planetSizeRange.y * borderSpawnDistance);
  int minY = PApplet.parseInt(sector.GetLocation().y + planetSizeRange.y * borderSpawnDistance);
  int maxX = PApplet.parseInt(sector.GetLocation().x + sector.GetSize().x - planetSizeRange.y * borderSpawnDistance);
  int maxY = PApplet.parseInt(sector.GetLocation().y + sector.GetSize().y - planetSizeRange.y * borderSpawnDistance);
  
  //Tile arraylist constructor 
  int i = 0;      //Iterator  
  int timeoutCounter = 0;      //To check if loop has run too long
  boolean noOverlap = true;    //Is this coordinate original, or will it allow overlap?
  while(i < count)
  {
    int size = rand.nextInt(PApplet.parseInt(planetSizeRange.y - planetSizeRange.x))+ PApplet.parseInt(planetSizeRange.x);
    
    //Generate a random X/Y coordinate guaranteed to be within the boundary
    //accounting for the diameter of the asteroid where asteroidSizeRange.y is max size

    int xCoor = rand.nextInt(maxX-minX)+minX;
    int yCoor = rand.nextInt(maxY-minY)+minY;
    
    //Check that this planet will not spawn too near one another 
    noOverlap = true;    //Assume this coordinate is good to begin
    
    //TODO re-implement
    for(Planet planet : sector.planets)
    {
      //Check if this planet's center + diameter overlaps with planet's center + 4 * diameter
      if( Math.abs(planet.GetLocation().x-xCoor) < planet.GetSize().x * 1.5f + size * 1.5f
            && Math.abs(planet.GetLocation().y-yCoor) < planet.GetSize().y * 1.5f + size * 1.5f )
      {
        noOverlap = false;
        println("[INFO] Planet location rejected!");
        break;
      }
    }
    
    //Guarantee planets are too close to each oher
    if(noOverlap)
    {  
      Planet toBuild = new Planet("Planet", new PVector(xCoor, yCoor), size, PApplet.parseInt(10000*size/planetSizeRange.y), sector);
      toBuild.SetMaxSpeed(0);        //Local speed limit for planet (don't move)
      toBuild.baseAngle = rand.nextInt((360) + 1);
      sector.planets.add(toBuild);
      println("[INFO] Generated a new planet at " + toBuild.location + " in sector " + sector.name);
      i++;
    }
    else
    {
      //Failed to generate the planet
      timeoutCounter++;
      if(timeoutCounter >  4 * count)    //Try to generate 4x as many planets
      {
        print("[WARNING] Planet generation failed for ");
        print(count - i);
        print(" planet(s)\n");
        break;    //abort the generation loop
      }
    }
  }
}


float shipScaleFactor = 0.25f;     //Scale down ship sizes by this factor
/**
 * Build a given number of enemies on the provided Sector. If there
 * are planets, generate around the planet. If asteroid, generate
 * around asteroids. Else just generate anywhere in free space.
 * @param {Sector} sector Sector to build the enemies on
 * @param {Integer} count How many enemies to make
 */
public void GenerateEnemies(Sector sector, int count)
{
  PVector position = sector.location.get();   //Default position at origin of sector

  int minX, minY, maxX, maxY;                 //Max allowed positions

  int enemyShipRandomIndex = rand.nextInt((enemyShipCount -1) + 1);
  PImage enemySprite = enemyShipSprites.get(enemyShipRandomIndex).get();    //Make sure to get a COPY of the vector
  PVector enemyShipSize = enemyShipSizes.get(enemyShipRandomIndex).get();

  //Scale enemyshipsize
  enemyShipSize.x = PApplet.parseInt(shipScaleFactor * enemyShipSize.x);
  enemyShipSize.y = PApplet.parseInt(shipScaleFactor * enemyShipSize.y);

  if (enemyShipSize.x <= 0 || enemyShipSize.y <= 0)
  {
    println("[ERROR] Ship Scale error! Returning ship to standard size (large)");
    enemyShipSize = enemyShipSizes.get(enemyShipRandomIndex).get();
  }

  for(int i = 0; i < count; i++)
  {
    PVector shipSize = new PVector(75,30);
    if(sector.asteroids.size() > 0)   //This sector has asteroids -- check for overlap
    {
      boolean validLocation = false;
      while(!validLocation)
      {
        //Generation parameters
        minX = PApplet.parseInt(sector.GetLocation().x + enemyShipSize.x);
        minY = PApplet.parseInt(sector.GetLocation().y + enemyShipSize.y);
        maxX = PApplet.parseInt(sector.GetSize().x - enemyShipSize.x);
        maxY = PApplet.parseInt(sector.GetSize().y - enemyShipSize.y);

        //Generate position offsets from the sector location
        position.x = rand.nextInt(maxX - PApplet.parseInt(shipSize.x)) + minX + PApplet.parseInt(shipSize.x/2);
        position.y = rand.nextInt(maxY)+minY;

        for(Asteroid roid : sector.asteroids)
        {
          //Check if this asteroid's center + diameter overlaps with ships center = size
          if( Math.abs(roid.GetLocation().x-position.x) < roid.GetSize().x/2 + shipSize.x 
                && Math.abs(roid.GetLocation().y-position.y) < roid.GetSize().y/2 + shipSize.y )
          {
            validLocation = false;
            println("[INFO] Enemy placement location rejected!");
            break;
          }
          validLocation = true;   //Went thru each asteroid -- no overlap
        }
      }

    }
    else
    {      
      //Generation parameters
      minX = PApplet.parseInt(sector.GetLocation().x);
      minY = PApplet.parseInt(sector.GetLocation().y);
      maxX = PApplet.parseInt(sector.GetSize().x);
      maxY = PApplet.parseInt(sector.GetSize().y);

      //Generate position offsets from the sector location
      position.x = rand.nextInt(maxX - PApplet.parseInt(shipSize.x)) + minX + PApplet.parseInt(shipSize.x/2);
      position.y = rand.nextInt(maxY)+minY;
    }

    Enemy enemyGen = new Enemy("Bad guy", position, enemyShipSize, enemySprite, 
      1000, color(255,0,0), sector);
    enemyGen.baseAngle = rand.nextInt((360) + 1);     //Random rotation 0-360
    sector.ships.add(enemyGen);
  }

}

/**
 * Checks if an object implements an interface, returns boo
 * @param  object Any object
 * @param  interf Interface to compare against
 * @return {Boolean} True for implements, false if doesn't
 */
public static boolean implementsInterface(Object object, Class interf){
    return interf.isInstance(object);
}

/*
 * Mouse & keyboard input here.
 */

// Panning
public void mouseDragged() {
  //DEBUG ONLY
    wvd.orgX -= (mouseX - pmouseX) / wvd.viewRatio;
    wvd.orgY -= (mouseY - pmouseY) / wvd.viewRatio;

  //Make sure we haven't panned outside the screen view
  // if(!debugMode.value)
  // {
  //   if (mouseX < width && mouseY < height 
  //     && wvd.pixel2worldX(width) < width 
  //     && wvd.pixel2worldY(height) < height) 
  //   {
  //     wvd.orgX -= (mouseX - pmouseX) / wvd.viewRatio;
  //     wvd.orgY -= (mouseY - pmouseY) / wvd.viewRatio;
  //   }
    
  //   //Code for preventing zoom to one screen width
  //   if(wvd.orgX < 0)
  //   {
  //     wvd.orgX = 0;
  //   }
  //   if(wvd.orgY < 0)
  //   {
  //     wvd.orgY = 0;
  //   }
    
  //   if(wvd.pixel2worldX(width) > width)
  //   {
  //     wvd.orgX--;
  //   }
  //   if(wvd.pixel2worldY(height) > height)
  //   {
  //     wvd.orgY--;
  //   }
  // }
  // else
  // {
  //   wvd.orgX -= (mouseX - pmouseX) / wvd.viewRatio;
  //   wvd.orgY -= (mouseY - pmouseY) / wvd.viewRatio;
  // }

}

// Change zoom level
public void mouseClicked() 
{
  PVector currentMouseLoc = new PVector(mouseX, mouseY);
  
  //Click actions here, based on gamestate
}

public void mouseWheel(MouseEvent e)
{
  //TODO phase out mousewheel (centering camera messes up zoom... fix or remove this)
  float wmX = wvd.pixel2worldX(mouseX);
  float wmY = wvd.pixel2worldY(mouseY);
  
  wvd.viewRatio -= e.getAmount() / 20;
  wvd.viewRatio = constrain(wvd.viewRatio, 0.05f, 200.0f);
  
  //DEBUG ONLY
  wvd.orgX = wmX - mouseX / wvd.viewRatio;
  wvd.orgY = wmY - mouseY / wvd.viewRatio;

  // //Prevent zooming out past standard zoom
  // if(wvd.viewRatio < 1)
  // {
  //   wvd.viewRatio = 1.00f;
  // }
  // else if(wvd.viewRatio > 2)
  // {
  //   wvd.viewRatio = 2.00f;
  // }
  // else    //Only shift translation if we aren't zoomed out all the way
  // {
  //   wvd.orgX = wmX - mouseX / wvd.viewRatio;
  //   wvd.orgY = wmY - mouseY / wvd.viewRatio;
  // }
}


//Check for keypresses
public void keyPressed() 
{  
  if(key == 'r')
  {
    wvd.viewRatio = 1;
    wvd.orgX = 0.0f;
    wvd.orgY = 0.0f;
  }
  
  if(key == 'h' || key == 'H')
  {
    if(playerShip.leftEnginePower > playerShip.minThrust)
    {
      playerShip.leftEnginePower -= 1;
    }
    else
    {
      playerShip.leftEnginePower = playerShip.minThrust;
    }
  }
  else if(key =='y' || key == 'Y')
  {
    if(playerShip.leftEnginePower < playerShip.maxThrust)
    {
      playerShip.leftEnginePower += 1;
    }
    else
    {
      playerShip.leftEnginePower = playerShip.maxThrust;
    }
  }
  else if(key == 'k' || key == 'K')
  {
    if(playerShip.rightEnginePower > playerShip.minThrust)
    {
      playerShip.rightEnginePower -= 1;
    }
    else
    {
      playerShip.rightEnginePower = playerShip.minThrust;
    }
  }
  else if(key =='i' || key == 'I')
  {
    if(playerShip.rightEnginePower < playerShip.maxThrust)
    {
      playerShip.rightEnginePower += 1;
    }
    else
    {
      playerShip.rightEnginePower = playerShip.maxThrust;
    }
  }

  //DEBUG ONLY
  if(key == 'w')
  {
    playerShip.ChangeVelocity(new PVector(0, -2));
  }
  else if(key == 's')
  {
    playerShip.ChangeVelocity(new PVector(0, 2));
  }
  else if(key == 'a')
  {
    playerShip.ChangeVelocity(new PVector(-5, 0));
  }
  else if(key == 'd')
  {
    playerShip.ChangeVelocity(new PVector(5, 0));
  }
}
public interface Movable
{
  public void Move();
  public void ChangeVelocity(PVector _modifier);
  public void SetVelocity(PVector _velocity);
}

public interface Collidable
{
  public void HandleCollision(Physical _collider);
}

enum ClickType{
  INFO, TARGET, BUTTON
}

public interface Clickable
{
  public void UpdateUIInfo();          //Update the location and any text/ UI information in the given window
  public ClickType GetClickType();
  public void Click();                 //Click the target
  public void MouseOver();             //Mouseover the target
}

//For all classes that have information to update each loop
public interface Updatable
{
  public void Update();
}
public class LaserBeam extends Physical
{
  //Draw properties (limit range)
  static final float laserSpeedLimit = 4.0f;    //Speed limit, static for all laserbeams
  static final int timeToFly = 2500;        //Effective range, related to speed (ms)
  private long spawnTime;
  
  LaserBeam(PVector _loc, PVector _direction, Sector _sector)
  {
    super("Laser beam", _loc, new PVector(20,3), .01f, _sector);    //HACK Mass very low!! For handling physics easier 
    
    //Set laser color
      //TODO set laser color by player / enemy

    sprite.resize((int)size.x, (int)size.y);
    
    //Set laser speed and lifetime
    localSpeedLimit = laserSpeedLimit;
    spawnTime = millis();
    
    //Damage settings
    damageOnHit = 40;
    
    //Rotation setter
    // currentAngle = _direction.heading();
    
    //Velocity setter
    PVector scaledVelocity = _direction.get();
    scaledVelocity.setMag(laserSpeedLimit);
    
    SetVelocity(scaledVelocity);
    
    //Play laser fire sound
    laserSound.play();
  }
  
  //Standard update() + handle time of flight
  @Override public void Update()
  {
    super.Update();
          
    if(spawnTime + timeToFly < millis())
    {
      toBeKilled = true;
    }
  }
  
  //Handle laser damage in addition to standard collision
  @Override public void HandleCollision(Physical _other)
  {
    _other.health.current -= damageOnHit;
    
    if(debugMode.value)
    {
      print("INFO: Laser beam burn hurt ");
      print(_other.name);
      print(" for ");
      print(damageOnHit);
      print(" damage.\n");
    }
    
    toBeKilled = true;
  }

}
PImage missileSprite;      //Loaded in setup()

/**
 * A missile gameobject, inheriting from Pilotable
 */
public class Missile extends Physical implements Clickable, Updatable
{
  TextWindow info;

  Missile(PVector _loc, PVector _moveVector, int _outlineColor, Sector _sector) 
  {
    //Parent constructor
    super("Missile", _loc, new PVector(20,10), 10, _sector);    //mass = 10
    
    //Health
    health.max = 60;
    health.current = 60;
    
    //Damage
    damageOnHit = 250;
    
    //Physics
    velocity = _moveVector;
    // rotationRate = 0.1;          //Rotation rate on a missile is ~10x better than a ship
    
    //Override local speed limit
    //TODO test me
    localSpeedLimit = 1.25f;   //Overrides physical default value
    
    //UI
    sprite = missileSprite;
    sprite.resize(PApplet.parseInt(size.x), PApplet.parseInt(size.y));
    
    //Set the overlay icon
    iconOverlay.SetIcon(_outlineColor,ShapeType._SQUARE_);
    
    String descriptor = new String();
    descriptor += name;
    descriptor += "\nVelocity: ";
    descriptor += velocity.mag();
    descriptor += " m/s ";
    info = new TextWindow("Missile Info", location, descriptor, true);
  }
  
  //HACK this update() function is highly repeated through child classes
  public void Update()
  {
    super.Update();    //Call pilotable update
    
    //Check if UI is currently rendered, and if so update info
    if(info.visibleNow)
    {
      UpdateUIInfo();
    }
    //Assume UI will not be rendered next frame
    info.visibleNow = false;    //Another mouseover/ click will negate this
    
    //Update icon overlay
    iconOverlay.UpdateLocation(location);
    
  }

/*Click & mouseover UI*/
  public ClickType GetClickType()
  {
    return ClickType.INFO;
  }
  
  //Handle click actions on this object
  public void MouseOver()
  {
    info.visibleNow = true;
    info.DrawObject();
  }
  
  public void Click()
  {
    //No action
  }
  
  //When the object moves its UI elements must as well
  public void UpdateUIInfo()
  {
    //Update textbox
    info.UpdateLocation(new PVector(wvd.pixel2worldX(location.x), wvd.pixel2worldY(location.y)));
    
    String descriptor = new String();
    descriptor += name;
    descriptor += "\nVelocity: ";
    descriptor += velocity.mag();
    descriptor += " m/s ";

    info.UpdateText(descriptor);
  }
  
  @Override public void HandleCollision(Physical _other)
  {
    super.HandleCollision(_other);
    Explosion explosion = new Explosion(location, new PVector(64,48));    //New explosion here
    explosions.add(explosion);      //Add to list of effects to render
    
    //Explosion force!
    float explosiveForce = 0.75f;
    
    PVector explosionDirection = new PVector(0,0);    //Delta of position, dP(12) = P2 - P1
    explosionDirection.x = _other.location.x - location.x;
    explosionDirection.y = _other.location.y - location.y;
    
    explosionDirection.normalize();      //Create unit vector for new direction from deltaP
    
    //Opposite vector for this object
    explosionDirection.mult(-1);
    explosionDirection.setMag(explosiveForce);
    
    if(debugMode.value)
    {
      print("Explosion from missile hit ");
      print(_other.name);
      print(" for ");
      print(damageOnHit);
      print(" damage.\n");
    }
    _other.ChangeVelocity(explosionDirection);
    
    toBeKilled = true;
  }

}
float globalSpeedLimit = 10;      //Universal speed limit (magnitude vector)

public enum PhysicsMode {       //Normal physics (Newtonian) or spin (planet/asteroid) 
  STANDARD, SPIN
}


public class Physical extends Drawable implements Movable, Collidable, Updatable
{
  //UI
  public Shape iconOverlay;
  public boolean drawOverlay = true;
  
  //Stats
  protected float mass;
  protected Health health;
  
  //Movement
  protected PVector velocity;              //On absolute plane
  protected float localSpeedLimit;         //Max velocity magnitude for this object
  protected PVector acceleration;          //Modifier on velocity
  protected float maxForceMagnitude;       //How large an acceleration force may be applied

  //Collisions
  protected long lastCollisionTime = -9999;
  protected int damageOnHit = 0;           //Automatic damage incurred on hit
  boolean collidable = true;               //Can this object be collided with by ANYTHING? see shields when down
  
  //Location
  protected Sector currentSector;                //What physical sector this object is in


  public Physical(String _name, PVector _loc, PVector _size, float _mass, Sector _sector)
  {
    super(_name, _loc, _size);
    
    health = new Health(100, 100);       //Default health
    mass = _mass;
    
    currentSector = _sector;

    //Movement
    velocity = new PVector(0, 0);
    acceleration = new PVector(0,0);
    localSpeedLimit = 10;         //Default speed limit
    maxForceMagnitude = .2f;          //TODO implement me
    
    //UI
    iconOverlay = new Shape("Physical Overlay", location, 
                size, color(0,255,0), ShapeType._SQUARE_);
  }
  
  @Override public void DrawObject()
  {
    super.DrawObject();

    pushMatrix();
    translate(location.x, location.y);

    //Display forward vector (white), velocity vector (red)
    if (debugMode.value)
    {
      //Debug forward direction (white)
      stroke(255, 255, 255);
      line(0, 0, 50 * forward.x, 50 * forward.y);  

      //Debug velocity direction (red)
      stroke(255, 0, 0);
      line(0, 0, 100 * velocity.x, 100 * velocity.y);  
    }

    //Handle drawing rotation
    baseAngle= velocity.heading2D();
    rotate(baseAngle);

    popMatrix();
  }
  
//******* MOVE *********/
  public void SetVelocity(PVector _vector)
  {
    if(_vector.mag() <= globalSpeedLimit && _vector.mag() <= localSpeedLimit)
    {
      velocity = _vector;
    }
    else if (_vector.mag() > localSpeedLimit)
    {
      PVector scaledV = new PVector(_vector.x, _vector.y);
      scaledV.limit(localSpeedLimit);
      velocity = scaledV;
    }
    else if (_vector.mag() > globalSpeedLimit)
    {
      PVector scaledV = new PVector(_vector.x, _vector.y);
      scaledV.limit(globalSpeedLimit);
      velocity = scaledV;
    }
  }
  
  //Modify the current velocity of the object, respecting speed limit
  public void ChangeVelocity(PVector _vector)
  {
    PVector newVelocity = new PVector(velocity.x + _vector.x, velocity.y + _vector.y);
    SetVelocity(newVelocity);   
  }

  public void ApplyForce(PVector _accel)
  {
    acceleration.add(_accel);
  }

  //Set local speed limit
  public void SetMaxSpeed(float _limit)
  {
    localSpeedLimit = _limit;
  }
  
  //Move location
  public void Move()
  {
    location.add(velocity);               //Move based on velocity   
  }

  
//******* COLLIDE *********/

  //The other object's effect on this object
  float frictionFactor = 1.5f;        //How much to slow down after collision (divisor)
  public void HandleCollision(Physical _other)
  {
    lastCollisionTime = millis();
    
    //Damage based on automatic damage 
    health.current -= _other.damageOnHit;
    
    //Damage this object based on delta velocity
    PVector deltaV = new PVector(0,0);
    PVector.sub(_other.velocity, velocity, deltaV);
    float velocityMagDiff = deltaV.mag();
    
    //Mass scaling factor (other/mine)
    float massRatio = _other.mass/mass;
    float damage = 10 * massRatio * velocityMagDiff;
    health.current -= damage;        //Lower this health
    
    if(debugMode.value)
    {
      print("[DEBUG] ");
      print(_other.name);
      print(" collision caused ");
      print(damage);
      print(" damage to ");
      print(name);
      print("\n");
    }
    
    //Create a velocity change based on this object and other object's position
    PVector deltaP = new PVector(0,0);    //Delta of position, dP(12) = P2 - P1
    deltaP.x = _other.location.x - location.x;
    deltaP.y = _other.location.y - location.y;
    
    deltaP.normalize();      //Create unit vector for new direction from deltaP
    
    //Opposite vector for this object (reverse direction)
    deltaP.mult(-1);
    deltaP.setMag(velocity.mag()/frictionFactor);
    
    SetVelocity(deltaP);
  }
  
//******* UPDATE *********/
  public void Update()
  {
    velocity.add(acceleration);           //Update velocity by acceleration vector
    velocity.limit(localSpeedLimit);      //Make sure we haven't accelerated over speed limit

    //acceleration.mult(0);                 //Reset acceleration (acts like an impulse)

    if(health.current <= 0)
    {
      toBeKilled = true;
      if(debugMode.value)
      {
        print("INFO: ");
        print(name);
        print(" has died\n");
      }

    }
  }
}
/*
 * A planet gameobject, inheriting from Drawable. May contain stations orbiting it
 */
public class Planet extends Physical implements Clickable, Updatable
{
  public TextWindow info;     //For mouseover

  private String[] planetDescriptions = {"Lifeless Planet", "Ocean Planet", "Lava Planet", "Crystalline Planet",
                                "Desert Planet", "Swamp Planet", "Class-M Planet", "Lifeless Planet",
                                "Class-M Planet", "Ionically Charged Planet", "Forest Planet", "Scorched Planet"};
  
  private int planetTypeIndex;
  private ArrayList<Station> stations;      //Stations around this planet

  public Planet(String _name, PVector _loc, int _diameter, int _mass, Sector _sector) 
  {
    //Parent constructor
    super(_name, _loc, new PVector(_diameter, _diameter), _mass, _sector);
    
    //Select my planet image from spritesheet (total of 10 options)
    planetTypeIndex = rand.nextInt(11) + 1;    //There is no p0, add 1
    
    //Create filesystem path to sprite
    String filePath = "";
    filePath += "Assets/Planets/p";
    filePath += planetTypeIndex;
    filePath += "shaded.png";

    //Set the sprite to the random subset of the spritesheet
    sprite = loadImage(filePath);
    sprite.resize((int)size.x, (int)size.y);
    
    //Generate stations
    stations = new ArrayList<Station>();
    int maxStations = 2;
    int minStations = 0;
    int stationCount = rand.nextInt((maxStations - minStations) + 1) + minStations;
    GenerateStations(stationCount);

    //Set string descriptor for real-ish values that look pretty
    String descriptor = new String();
    descriptor += planetDescriptions[planetTypeIndex-1];
    descriptor += "\nAll planets support";
    descriptor += "\nup to 4 orbital stations.";
    info = new TextWindow("Planet info", location, descriptor, true);
  }

  //Create possible station locations around each planet
  private void GenerateStations(int _count)
  {
    ArrayList<PVector> stationOrbitLocationCandidates = new ArrayList<PVector>();
    
    PVector locationCandidate1 = new PVector(location.x - 75, location.y);
    PVector locationCandidate2 = new PVector(location.x + 75, location.y);
    PVector locationCandidate3 = new PVector(location.x, location.y - 75);
    PVector locationCandidate4 = new PVector(location.x, location.y + 75);
   
    stationOrbitLocationCandidates.add(locationCandidate1);
    stationOrbitLocationCandidates.add(locationCandidate2);
    stationOrbitLocationCandidates.add(locationCandidate3);
    stationOrbitLocationCandidates.add(locationCandidate4);
    
    for(int i = 0; i < _count; i++)
    {
      //Random size
      int sizeGen = rand.nextInt(Station.maxStationSize * 2/3) + Station.maxStationSize * 1/2;       //TODO how does this work again?
      PVector stationSize = new PVector(sizeGen, sizeGen);
      
      //Randomly select station location from generated list above
      int locationSelectedIndex = rand.nextInt(stationOrbitLocationCandidates.size());
      PVector stationLoc = stationOrbitLocationCandidates.get(locationSelectedIndex);
      stationOrbitLocationCandidates.remove(locationSelectedIndex);
      
      //Select station color & build station
      Station station;
      int stationLevel = rand.nextInt(2) + 1;     //to set station size
      int stationColor = rand.nextInt(2) + 1;     //to set station color
      if(stationLevel == 1)
      {
        if(stationColor == 1)
        {
          station = new Station(StationType.MILITARY, stationLoc, stationSize, blueStation1, currentSector);
        }
        else
        {
          station = new Station(StationType.MILITARY, stationLoc, stationSize, redStation1, currentSector);
        }
      }
      else if(stationLevel == 2)
      {
        if(stationColor == 1)
        {
          station = new Station(StationType.MILITARY, stationLoc, stationSize, blueStation2, currentSector);
        }
        else
        {
          station = new Station(StationType.MILITARY, stationLoc, stationSize, redStation2, currentSector);
        }
      }
      else
      {
        if(stationColor == 1)
        {
          station = new Station(StationType.MILITARY, stationLoc, stationSize, blueStation2, currentSector);
        }
        else
        {
          station = new Station(StationType.MILITARY, stationLoc, stationSize, redStation2, currentSector);
        }
      }

      stations.add(station);
    }
  }

  @Override public void DrawObject()
  {
    super.DrawObject();
    DrawObjects(stations);    //Draw child stations
  }
  public void Update()
  {    
    super.Update();    //Call physical update

    //Check if UI is currently rendered, and if so update info
    if(info.visibleNow)
    {
      UpdateUIInfo();
    }
    //Assume UI will not be rendered next frame
    info.visibleNow = false;    //Another mouseover/ click will negate this

    UpdatePhysicalObjects(stations);    //HACK Update child stations
  }

/*Click & mouseover UI*/
  public ClickType GetClickType()
  {
    return ClickType.INFO;
  }
  
  public void MouseOver()
  {
    info.visibleNow = true;
    info.DrawObject();
  }
  
  public void Click()
  {
    
  }
  
  //When the object moves this must move as well
  public void UpdateUIInfo()
  {
    info.UpdateLocation(location);
    
    String descriptor = planetDescriptions[planetTypeIndex-1];
    descriptor += "\nDiameter: ";
    descriptor += (float)size.x*150;
    descriptor += " km \nMass: ";
    descriptor += mass/10;
    descriptor += "E23 kg\n";

    info.UpdateText(descriptor);
  }
  

}

/**
 * Player ship object, with reactor cores, stations, etc.
 */
public class Player extends Ship
{
  private Reactor reactor;
  private int maxPowerToNode;			//Maximum power any one node may have
  
  //Behavoir Ranges for Enemy
  public Shape seekCircle, seekAgainCircle, avoidCircle;
  public int seekRadius, seekAgainDiameter, avoidDiameter;

  public Player(PVector _loc, PVector _size, PImage _sprite, int _mass, int _outlineColor, Sector _sector) 
  {
  //Parent constructor
  super("Player", _loc, _size, _sprite, _mass, _outlineColor, _sector);

  reactor = new Reactor(100);
  maxPowerToNode = reactor.totalCapacity/3;
  
  //Behavior Ranges for Enemies
  seekRadius = displayWidth;        //All ships inside the screen + 100 pixels will seek to destory
  seekAgainDiameter = 500;
  avoidDiameter = 400;
  
  seekCircle = new Shape("seekCircle", location, new PVector(seekRadius,seekRadius), color(0,255,255), ShapeType._CIRCLE_);                    //Light Blue
  seekAgainCircle = new Shape("seekAgainCircle", location, new PVector(seekAgainDiameter,seekAgainDiameter), color(255,18,200), ShapeType._CIRCLE_); //Pink
  avoidCircle = new Shape("avoidCircle",location , new PVector(avoidDiameter,avoidDiameter), color(18,255,47), ShapeType._CIRCLE_);                  //Green
  }	

  @Override public void Update()
  {
  super.Update();
  
  seekCircle.location = location;
  seekAgainCircle.location = location;
  avoidCircle.location = location;

  PVector spinForce = Spin();
  ApplyForce(spinForce);

  PVector thrustForce = Thrust();
  ApplyForce(thrustForce); 

  //TODO modify ship parameters (engine power, shield, etc) based off
  //of reactor right now
  //Modify weapon fire speed
  int weaponCooldownModifier = reactor.GetReactorPower(NodeType.WEAPONS)/maxPowerToNode;
  currentFireInterval = minFireInterval + weaponCooldownModifier * minFireInterval;
  }
  
  @Override public void DrawObject()
  {
    super.DrawObject();
    if(debugMode.value)
    {
      seekCircle.DrawObject();
      seekAgainCircle.DrawObject();
      avoidCircle.DrawObject();
    }
  }	
  
}


enum NodeType{
  SHIELDS, WEAPONS, ENGINES
}

/**
 * A power reactor that controls how much power the ship gets to each of its
 * nodes. To be controlled by keyboard / external controller
 */
public class Reactor
{
	int totalCapacity;
	Map<NodeType, Node> nodes;

	public Reactor(int _capacity)
	{
		totalCapacity = _capacity;
		nodes = new HashMap<NodeType, Node>();
		nodes.put(NodeType.SHIELDS, new Node(NodeType.SHIELDS));
		nodes.put(NodeType.WEAPONS, new Node(NodeType.WEAPONS));
		nodes.put(NodeType.ENGINES, new Node(NodeType.ENGINES));
	}

	public int GetReactorPower(NodeType _type)
	{
		return nodes.get(_type).currentPower;
	}
}

/**
 * Power node on the reactor control board
 */
public class Node
{
	NodeType type;
	int currentPower;

	public Node(NodeType _type)
	{
		type = _type;
		currentPower = 0;
	}

	public void SetPower(int _power)
	{
		currentPower = _power;
	}

}
static enum SectorType {
  ASTEROIDFIELD, EMPTY, PLANETARY, RANDOM
}

enum SectorDirection {
  UL, Above, UR, Left, Right, LL, Below, LR
}

//An area in 2D space containing asteroids, planets, ships, stations, etc
public class Sector extends Drawable implements Updatable
{
  //Contents of this sector. Built by helper functions in helpers.pde
  public ArrayList<Asteroid> asteroids;
  public ArrayList<Planet> planets;
  public ArrayList<Ship> ships;           //May include enemies and the player ship
  
  //Link to neighboring sectors
  public HashMap<SectorDirection, Sector> neighbors;

  //Collider shape
  Shape collider;     //For checking overlap of game objects in this sector

  private int debugViewColor;       //Color displayed over this sector in debug mode
  private SectorType sectorType;      //What kind of sector is this? Asteroid field, planetary, etc

  //Sector parameters
  int minPlanets = 1;
  int maxPlanets = 4;
  int minAsteroids = 10;
  int maxAsteroids = 60;

/**
 * [Sector description]
 * @param {Integer} _ID Unique identifier for this sector
 * @param {PVector} _loc Pixel location of this sector
 * @param {PVector} _size Pixel size of this sector
 * @param {PImage} _background Sprite of the background of this sector
 */
  public Sector(int _ID, PVector _loc, PVector _size, PImage _background, SectorType _sectorType)
  {
    super(Integer.toString(_ID), _loc, _size);

    sprite = _background;
    sprite.resize(PApplet.parseInt(size.x), PApplet.parseInt(size.y));

    renderMode = CORNER;        //Don't draw sector in center
     
    //Shape for collision detection
    collider = new Shape("collider", location, size, color(255,255,255), ShapeType._RECTANGLE_);
    collider.renderMode = CORNER;

    //Object containers
    asteroids = new ArrayList<Asteroid>();
    planets = new ArrayList<Planet>();
    ships = new ArrayList<Ship>();

    //Neighbors
    neighbors = new HashMap<SectorDirection, Sector>();

    //Generate all objects in the sector
    GenerateSectorObjects(_sectorType);   //Build static objects (asteroids, planets, stations)
    GenerateSectorEnemies();          //Build dynamic objects (enemies)
    
    //DEBUG INFO
    debugViewColor = color(255);    //Default = white
  }
  
  /**
   * Generate the sector's objects (asteroids, planets, etc)
   * @param {SectorType} _sectorType What kind of sector to generate
   * @see  Helpers.pde for generation function
   */
  private void GenerateSectorObjects(SectorType _sectorType)
  {
    if(_sectorType == SectorType.RANDOM)
    {
      //Determine what type of sector we are
      int sectorTypeRand = rand.nextInt((3 - 1) + 1) + 1;   //rand.nextInt((max - min) + 1) + min;
      if(sectorTypeRand == 1)
      {
        println("[INFO] Building asteroid field sector");
        sectorType = SectorType.ASTEROIDFIELD;
      }
      else if(sectorTypeRand == 2)
      {
        println("[INFO] Building empty sector");   
        sectorType = SectorType.EMPTY;
      }
      else if(sectorTypeRand == 3)
      {
        println("[INFO] Building planetary sector"); 
        sectorType = SectorType.PLANETARY;
      }
      else
      {
        println("[ERROR] Invalid sector type selected. Defaulting to asteroid field");  
        sectorType = SectorType.ASTEROIDFIELD;
      }
    }
    else    //Passed in parameter determines sectorType
    {
      sectorType = _sectorType;
    }

    if(sectorType == SectorType.PLANETARY)
    {
      //Generate planets
      int planetCount = rand.nextInt((maxPlanets - minPlanets) + 1) + minPlanets;
      GeneratePlanets(this, planetCount);         //See helpers.pde
    }
    else if(sectorType == SectorType.ASTEROIDFIELD)
    {
      //Generate asteroids in this sector
      int asteroidCount = rand.nextInt((maxAsteroids - minAsteroids) + 1) + minAsteroids;
      GenerateAsteroids(this, asteroidCount);     //See helpers.pde
    }
  }

  /**
   * Generate dynamic entities (enemies) in this sector
   * @see  Helpers.pde for generation function
   */
  private void GenerateSectorEnemies()
  {
    int maxEnemies = 4;
    int minEnemies = 1;
    int enemyCount = rand.nextInt((maxEnemies - minEnemies) + 1) + minEnemies;
    GenerateEnemies(this, enemyCount);
  }

  public void SetDebugColor(int _color)
  {
    debugViewColor = _color;
  }
  
  /**
   * Draw the sector itself
   * @see Visuals.pde DrawSectors() for drawing of child objects in the sector
   */
  @Override public void DrawObject()
  {
    super.DrawObject();    //Draw using parent method
    
    //Sector's game objects are drawn in visuals.pde DrawSectors()

    if(debugMode.value)    //Draw sector ID
    {
      pushStyle();
      textFont(startupFont, 80);
      pushMatrix();
      translate(location.x + size.x/2, location.y + size.y/2);
      text(name, 0, 0);
      popMatrix();
      popStyle();
    }
  }

  public void Update()
  {
    //TODO handle ships moving between sectors
      //TODO subset: generate more sectors if player moves between sectors
  }
  
  /**
   * Attach a neighboring sector to this sector
   * @param {SectorDirection} _direction Where relative to this sector?
   * @param {Sector} _neighbor Neighboring sector object
   */
  public void SetNeighbor(SectorDirection _direction, Sector _neighbor)
  {
    if(neighbors.get(_direction) == null)    //If mapping already exists
    {
      neighbors.put(_direction, _neighbor);
      if(debugMode.value)
      {
        println("[DEBUG] Created neighbor relationship between " + name + " and " + _neighbor.name);
      }    
    }
  }

  /**
   * Check if this sector has already popualted and linked a neighbor
   * in the provided direction
   * @param {SectorDirection} _direction Which direction to check
   * @return {boolean} True if neighbor populated, false if none
   */
  public boolean HasNeighbor(SectorDirection _direction)
  {
    if(neighbors.get(_direction) == null)   
    {
      return false;  //If mapping already exists, already has neighbor
    }
    else
    {
      return true;
    }
  }

  /**
   * Returns the PVector coordinates of an adjacent neighbor
   * (upper left corner of that sector coordinates)
   * @param {SectorDirection} _neighbor Direction to check
   * @return {PVector} Coordinates of where this neighbor would be (raw calculation)
   */
  public PVector GetNeighborLocation(SectorDirection _neighbor)
  {
    if(_neighbor == SectorDirection.UL)
    {
      return new PVector(location.x - size.x, location.y - size.y);  
    }
    else if(_neighbor == SectorDirection.Above)
    {
      return new PVector(location.x, location.y - size.y);  
    }
    else if(_neighbor == SectorDirection.UR)
    {
      return new PVector(location.x + size.x, location.y - size.y);  
    }
    else if(_neighbor == SectorDirection.Left)
    {
      return new PVector(location.x - size.x, location.y);  
    }
    else if(_neighbor == SectorDirection.Right)
    {
      return new PVector(location.x + size.x, location.y);   
    }
    else if(_neighbor == SectorDirection.LL)
    {
      return new PVector(location.x - size.x, location.y + size.y);  
    }
    else if(_neighbor == SectorDirection.Below)
    {
      return new PVector(location.x, location.y + size.y);  
    }
    else if(_neighbor == SectorDirection.LR)
    {
      return new PVector(location.x + size.x, location.y + size.y);  
    }
    else    //A weird value was passed in....
    {
      println("[ERROR] Requested neighbor on unspecified direction. Coordinates will be invalid!");
    }

    println("[ERROR] Returned invalid sector coordinates!");
    return new PVector(0,0);
  }

  /**
   * Return arraylist of all generated neighboring cells
   * @return arraylist of sectors
   */
  public ArrayList<Sector> GetAllNeighbors()
  {
    ArrayList<Sector> allNeighbors = new ArrayList<Sector>();
    for(Sector neighbor : neighbors.values())
    {
      allNeighbors.add(neighbor);
    }

    return allNeighbors;
  }

  /**
   * Get a neighbor at a given direction. Returns null if DNE
   * @param {SectorDirection} _direction Which way?
   * @return {Sector} Null / valid sector
   */
  public Sector GetNeighbor(SectorDirection _direction)
  {
    return neighbors.get(_direction);
  }


  /**
   * A new object has entered this sector -- typecast it and place in
   * appropriate container
   * @param {Physical} obj object to cast and hold
   * @see  Updaters.pde > UpdatePhysicalObjects()
   */
  public void ReceiveNewObject(Physical obj)
  {
    if(obj instanceof Ship)
    {
      ships.add((Ship)obj);
    }
    else if(obj instanceof Asteroid)
    {
      asteroids.add((Asteroid)obj);
    }
    else if(obj instanceof Planet)
    {
      planets.add((Planet)obj);
      println("[INFO] That's interesting.... a planet moved sectors.");
    }
  }

  //Print debug sector ID map
  public String toString() 
  {
    String[] ids = {"~", "~", "~", "~", "~", "~", "~", "~", "~"};

    for(SectorDirection key : neighbors.keySet()) 
    {
      SectorDirection direction = key;
      Sector sector = neighbors.get(key);   //Grab sector from map
      String sectorID = sector.name;       //Get sector ID name

      if(direction == SectorDirection.UL)
      {
        ids[0] = sectorID;
      }
      else if(direction == SectorDirection.Above)
      {
        ids[1] = sectorID;
      }
      else if(direction == SectorDirection.UR)
      {
        ids[2] = sectorID;
      }
      else if(direction == SectorDirection.Left)
      {
        ids[3] = sectorID;
      }
      else if(direction == SectorDirection.Right)
      {
        ids[5] = sectorID;
      }
      else if(direction == SectorDirection.LL)
      {
        ids[6] = sectorID;
      }
      else if(direction == SectorDirection.Below)
      {
        ids[7] = sectorID;
      }
      else if(direction == SectorDirection.LR)
      {
        ids[8] = sectorID;
      }

    }
    ids[4] = this.name;

    String toReturn = "";
    toReturn += "Sector " + name + " map\n";
    toReturn += "----------\n";
    toReturn += ("| " + ids[0] + " " + ids[1] + " " + ids[2] + " |\n");
    toReturn += ("| " + ids[3] + " " + ids[4] + " " + ids[5] + " |\n");
    toReturn += ("| " + ids[6] + " " + ids[7] + " " + ids[8] + " |\n");
    toReturn += "----------\n";
    return toReturn;
  }
}
public static enum ShapeType {
  _SQUARE_, _TRIANGLE_, _CIRCLE_, _RECTANGLE_
}

/*
 * UI shape (Square, circle, triangle allowed)
*/
public class Shape extends Drawable
{
  public ShapeType shapeType;
  public int borderColor;
  
  private int defaultColor;
  private boolean colorSet;          //Allow only one initial set of color after the constructor's default
  private int fillColor;
  
  public Shape(String _name, PVector _loc, PVector _size, int _color, ShapeType _shapeType)
  {
    super(_name, _loc, _size);
    borderColor = _color;
    defaultColor = borderColor;
    shapeType = _shapeType;
    colorSet = false;
    fillColor = color(255,255,255,0);
  }
  
  @Override public void DrawObject()
  {
    pushMatrix();
    translate(location.x, location.y);
    pushStyle();
    stroke(borderColor);
    fill(fillColor);
    
    if(shapeType == ShapeType._SQUARE_)
    {
      rectMode(renderMode);
      rect(0, 0, size.x, size.x);    //TODO forced square here
      if(size.x != size.y)
      {
        println("[WARNING] Square shape being force-render with rectangle edges!");
      }
      
    }
    if(shapeType == ShapeType._RECTANGLE_)
    {
      rectMode(renderMode);
      rect(0, 0, size.x, size.y); 
    }
    else if(shapeType == ShapeType._TRIANGLE_)
    {
      float a = size.x;
      float r = a * sqrt(3)/6;      //See http://www.treenshop.com/Treenshop/ArticlesPages/FiguresOfInterest_Article/The%20Equilateral%20Triangle.htm
      float R = r * 2;
    
      beginShape(TRIANGLES);
      vertex(-a/2, r);
      vertex(a/2, r);
      vertex(0, -R);
      endShape();
    }
    else if(shapeType == ShapeType._CIRCLE_)
    {
      ellipseMode(RADIUS);
      ellipse(0, 0, size.x/2, size.y/2);
    }
    popStyle();
    popMatrix();
  }
  
  public void SetFillColor(int _fillColor)
  {
    fillColor = _fillColor;
  }
  
  public void SetIcon(int _color, ShapeType _type)
  {
    if(!colorSet)
    {
      //Set shape type
      shapeType = _type;
      
      //Set border color
      borderColor = _color;
      defaultColor = borderColor;
      
      colorSet = true;
    }
    else
    {
      println("WARNING: Attempted to set icon color after it had been initially set. Try UpdateIcon instead?");
    }
  }
  
  public void SetBorderColor(int _borderColor, ShapeType _type)
  {
    shapeType = _type;
    borderColor = _borderColor;
  }
  
  public void SetBorderColor(int _borderColor)
  {
    borderColor = _borderColor;
  }
  
  public void RestoreDefaultColor()
  {
    borderColor = defaultColor;
  }
}

public class Shield extends Physical implements Updatable
{
  Shape overlay;    //Shape to render
  Physical parent;  //What is generating the shield
  
  long lastUpdateTime;          //When were shield updates last checked
  int shieldRegenAmount = 1;    //Per second
  int failureTime = 5000;       //How long shields are offline in event they fail, ms
  
  //String _name, PVector _loc, PVector _size, float _mass, DrawableType _type, Civilization _owner
  Shield(Physical _parent, int _dmgCapacity, Sector _sector)
  {
    //HACK size is forced round to compensate for no rotation of a Shape object (even though the Shield itself is 'physical')
    //HACK shield mass set to 1500 to get around a collision w/ really massive objects
    super("Shield", _parent.location, new PVector(_parent.size.x*1.25f, _parent.size.x*1.25f), 2000, _sector);
    overlay = new Shape("Shield Overlay", location, size, color(0xff5262E3, 50), ShapeType._CIRCLE_);
    overlay.SetFillColor(color(0xff5262E3, 50));
    
    health.current = _dmgCapacity;
    health.max = health.current;
    
    parent = _parent;
    
    //Regen setup
    lastUpdateTime = millis();
  }
  
  @Override public void Update()
  {
    location = parent.location;
    overlay.location = location;    //Move overlay to real position
    
    //Check for shields down during this past loop
    if(collidable && health.current <= 0)
    {
      collidable = false;
      lastUpdateTime += failureTime;        //Won't update (regen for another 5 seconds)
      
      health.current = 0;      //Reset to zero health (no negative shield health)
    }
    
    //Regen
    if(millis() > lastUpdateTime + 1000)    //Do one second tick updates
    {
      collidable = true;
      if(health.current < health.max)
      {
        health.current += shieldRegenAmount;
      }
      lastUpdateTime = millis();
    }
  }
  
}
//TODO implement all the other ship sprites....
PImage shipSprite;      //Loaded in setup()

/**
 * A ship gameobject, inheriting from Pilotable. Expensive purchase cost, but great at shooting 
 * down enemy missiles.
 */
public class Ship extends Physical implements Clickable, Updatable
{
  TextWindow info;
  
  //Damage effects
  PVector smoke1Loc, smoke2Loc;    //In local coordinats relative to ship's location
  Smoke smokeEffect1;
  Smoke smokeEffect2;
  boolean smoke1Visible, smoke2Visible;
  
  //Scanners
  protected int scanInterval = 500;         //ms between scans
  protected long lastScanTime;              //When last scan occured
  protected int sensorRange = 250;          //Units of pixels
  protected Shape scanRadius;               //Circle outline, when hovered over, shows sensor/weapons range
  
  //Weapons
  protected long lastFireTime;
  protected float minFireInterval = 850;          //ms between shots
  protected float currentFireInterval = minFireInterval;

  ArrayList<Physical> targets;    //Firing targets selected after scan
  
  //Shields
  Shield shield;

  //Engines
  float leftEnginePower, rightEnginePower;
  float minThrust, maxThrust;
  
  //Enemy objects
  ArrayList<Asteroid> allAsteroids;    //For tracking mobile asteroid toward this ship's base
  ArrayList<Missile> enemyMissiles;
  ArrayList<Ship> enemyShips;
  ArrayList<Station> enemyStations;
  
  public Ship(String _name, PVector _loc, PVector _size, PImage _sprite, int _mass, 
    int _outlineColor, Sector _sector) 
  {
    //Parent constructor
    super(_name, _loc, _size, _mass, _sector);
    sprite = _sprite.get(); 
    sprite.resize(PApplet.parseInt(size.x), PApplet.parseInt(size.y));

    //Setup health, scaled by size relative to max size
    //TODO implement this into constructor (it is redundantly over-written in many places)
    health.max = 200;      //Health scaled to size, take advantage of integer division to round
    health.current = health.max;
    
    //Set the overlay icon
    iconOverlay.SetIcon(_outlineColor,ShapeType._TRIANGLE_);
    
    //Prepare smoke damage effect
    smoke1Loc = new PVector(size.x * rand.nextFloat() - size.x/2, size.y * rand.nextFloat() - size.y/2);
    smoke2Loc = new PVector(size.x * rand.nextFloat() - size.x/2, size.y * rand.nextFloat() - size.y/2);
    smokeEffect1 = new Smoke(location, new PVector(10,10));      //Place at origin for time being, use smoke locations in update
    smokeEffect2 = new Smoke(location, new PVector(10,10));  
    smoke1Visible = false;
    smoke2Visible = false;
    
    //Prepare engines
    leftEnginePower = 0;
    rightEnginePower = 0;
    minThrust = 0.0f;
    maxThrust = 10.0f;

    //Prepare shields
    shield = new Shield(this, 250, currentSector);
    
    //Prepare sensors
    scanRadius = new Shape("Scan radius", location, new PVector(sensorRange,sensorRange), 
                color(255,0,0), ShapeType._CIRCLE_);
    
    //Prepare laser
    targets = new ArrayList<Physical>();
    lastScanTime = 0;
    
    //Set the description string
    String descriptor = new String();
    descriptor += name;
    descriptor += "\nHealth: ";
    descriptor += health.current ;
    descriptor += "\nShield: ";
    descriptor += shield.health.current ;
    info = new TextWindow("Ship Info", location, descriptor, true);
    
  }
  
  @Override public void DrawObject()
  {
    super.DrawObject();

    //Draw smoke effects
    if(smoke1Visible)
    {
      smokeEffect1.DrawObject();
    }
    if(smoke2Visible)
    {
      smokeEffect2.DrawObject();
    }

  }
  
  /**
   * Set the sector this ship is currently in.
   * @param {Sector} _sector Sector object of current location
   */
  public void UpdateCurrentSector(Sector _sector)
  {
    currentSector = _sector;
  }

  @Override public void Update()
  {
    super.Update();    //Call Physical update (movement occurs here)
    
  //**** UI ****//
    //Check if UI is currently rendered, and if so update info
    if(info.visibleNow)
    {
      UpdateUIInfo();
    }
    
    //Assume UI will not be rendered next frame
    info.visibleNow = false;    //Another mouseover/ click will negate this
    
    //Update icon overlay
    iconOverlay.UpdateLocation(location);


   //**** MOVEMENT *****//

   //**** HEALTH *****//
    //Check health effect thresholds
    if(health.current <= health.max/2)
    {
      smoke1Visible = true;
    }
    if(health.current <= health.max/4)
    {
      smoke2Visible = true;
    }
    
  //**** EFFECTS *****//
    //Update smoke effect location
    if(smoke1Visible)
    {
      smokeEffect1.location = PVector.add(location,smoke1Loc);
      smokeEffect1.Update();
    }
    if(smoke2Visible)
    {
      smokeEffect2.location = PVector.add(location,smoke2Loc);
      smokeEffect2.Update();
    }
    
  //**** DEATH *****//
    //If the ship will die after this frame
    if(toBeKilled)
    {
      shield.toBeKilled = true;
      GenerateDeathExplosions(3, location, size);
    }
  }

   /*
  SPIN: 
  Creates two 'spin' vectors for each of the two engines.
  The vectors are both perpendicular to the Velocity vector and face opposite directions from one another
  They are scaled based on the engines power and then summed to each other and passed as a steering force to be summed to the acceleration vector
  */
  public PVector Spin()
  {
    PVector spinLeftEngine = new PVector(1,0);
    PVector spinRightEngine = new PVector(1,0);
   
    spinLeftEngine.rotate(velocity.heading() + HALF_PI);    //left engine vector set perdendicular to Velocity facing left.
    spinRightEngine.rotate(velocity.heading() - HALF_PI);   //right engine vector set perpendiuclar to Velocity facing right.
    spinLeftEngine.setMag(leftEnginePower);                 //Set magnitudes to Engines power ranging 0-10
    spinRightEngine.setMag(rightEnginePower);
    PVector spinSum = PVector.add(spinRightEngine, spinLeftEngine);  //Sum the apposing facing spin vectors
    
    PVector desired = PVector.add(spinSum, velocity);                // Sum 'spin' vector with velocity go get a desired direction
    desired.normalize();
    desired.mult(localSpeedLimit);                                   // Scale based on Maximum Player Speed
    PVector steer = PVector.sub(desired, velocity);
    steer.x = map(steer.x, 0,7.66f, 0,.5f);                            // 7.66 was max value seen when debugging---- .5 seems reasonable for max spin
    steer.y = map(steer.y, 0,7.66f, 0,.5f);
    //steer.limit(maxForceMagnitude);
    println("Spin: "+steer.mag());
    println("Velocity Mag: "+velocity.mag());
    return steer;                                                    // Pass Vector to be applied to ship
  }

  //FIXME not working
  public PVector Thrust()
  {
    PVector thrust = new PVector(1,0);
    thrust.rotate(velocity.heading());
    float thrustPower = (leftEnginePower/maxThrust)+(rightEnginePower/maxThrust);
    println("Left: "+leftEnginePower);
    println("Right: "+rightEnginePower);
    println("Thrust BEFORE: "+thrustPower);
    thrustPower = map(thrustPower, 0, 2, 0, maxForceMagnitude);
    println("Thrust AFTER: "+thrustPower);
    thrust.setMag(thrustPower);

    return thrust;
  }

/*Click & mouseover UI*/
  public ClickType GetClickType()
  {
    return ClickType.INFO;
  }
  
  //Handle click actions on this object
  public void MouseOver()
  {
    info.visibleNow = true;
    info.DrawObject();
  }
  
  public void Click()
  {
    println("INFO: No interaction defined for ship click");
  }
  
  //When the object moves its UI elements must as well
  public void UpdateUIInfo()
  {
    //Update textbox
    info.UpdateLocation(location);
    
    //Set the description string
    String descriptor = new String();
    descriptor += name;
    descriptor += "\nHealth: ";
    descriptor += health.current;
    descriptor += "\nShield: ";
    descriptor += shield.health.current ;
    
    info.UpdateText(descriptor);
  }

}
PImage smokeTexture;

/*
 * A smoke object that is attached to other drawable objects, and whose Draw
 * and Update functions are controlled by them. Implements a particle system
 * 
 */
public class Smoke extends Drawable implements Updatable
{
  ParticleSystem ps;
  float billowDirection;
  
  Smoke(PVector _loc, PVector _size)
  {
    super("Smoke", _loc, _size);
    sprite = smokeTexture.get();
    sprite.resize((int)size.x, (int)size.y);
    ps = new ParticleSystem(0, location, sprite);
    
    billowDirection = rand.nextFloat() * 0.1f - 0.05f;
  }

  @Override public void DrawObject() //<>//
  {
    float dx = billowDirection;
    PVector wind = new PVector(dx,0);
    ps.applyForce(wind);
    ps.run();
    for (int i = 0; i < 2; i++) 
    {
      ps.addParticle();
    }
    noTint();      //Clear tint from smoke particles before returning to drawing other objects
  }
  
  public void Update()
  {
    //Translation from Drawable object location to ParticleSystem origin
    ps.origin = location;
  }
}

// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {

  ArrayList<Particle> particles;    // An arraylist for all the particles
  PVector origin;                   // An origin point for where particles are birthed
  PImage img;
  
  ParticleSystem(int num, PVector v, PImage img_) {
    particles = new ArrayList<Particle>();              // Initialize the arraylist
    origin = v.get();                                   // Store the origin point
    img = img_;
    for (int i = 0; i < num; i++) {
      particles.add(new Particle(origin, img));         // Add "num" amount of particles to the arraylist
    }
  }

  public void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
  
  // Method to add a force vector to all particles currently in the system
  public void applyForce(PVector dir) {
    // Enhanced loop!!!
    for (Particle p: particles) {
      p.applyForce(dir);
    }
  
  }  

  public void addParticle() {
    particles.add(new Particle(origin,img));
  }

}

// A simple Particle class, renders the particle as an image

class Particle {
  PVector loc;
  PVector vel;
  PVector acc;
  float lifespan;
  PImage img;

  Particle(PVector l,PImage img_) {
    acc = new PVector(0,0);
    float vx = randomGaussian()*0.3f;
    float vy = randomGaussian()*0.3f - 1.0f;
    vel = new PVector(vx,vy);
    loc = l.get();
    lifespan = 100.0f;
    img = img_;
  }

  public void run() {
    update();
    render();
  }
  
  // Method to apply a force vector to the Particle object
  // Note we are ignoring "mass" here
  public void applyForce(PVector f) {
    acc.add(f);
  }  

  // Method to update location
  public void update() {
    vel.add(acc);
    loc.add(vel);
    lifespan -= 2.5f;
    acc.mult(0); // clear Acceleration
  }

  // Method to display
  public void render() {
    imageMode(CENTER);
    tint(255,lifespan);
    image(img,loc.x,loc.y);
    // Drawing a circle instead
    // fill(255,lifespan);
    // noStroke();
    // ellipse(loc.x,loc.y,img.width,img.height);
  }

  // Is the particle still useful?
  public boolean isDead() {
    if (lifespan <= 0.0f) {
      return true;
    } else {
      return false;
    }
  }
}
PImage redStation1, redStation2, redStation3;
PImage blueStation1, blueStation2, blueStation3;

enum StationType {
  MILITARY, ENERGY
}

public class Station extends Physical implements Clickable, Updatable
{
  static final int maxStationSize = 60;      //Maximum station size
  static final int maxStationHealth = 1000;  //Maximum health for a station
  TextWindow info;
  
  //Station INFO
  
  //Station mass-energy generation per sec
  int massEnergyGen;
  
  //Placement parameters
  Shape placementCircle;      //Shows the area where a spawned ship/ missile may be placed around this station
  int placementRadius;
  boolean displayPlacementCircle = false;    //Whether or not to draw the placement circle
  
  //Damage effects
  PVector smoke1Loc, smoke2Loc;    //In local coordinats relative to ship's location
  Smoke smokeEffect1;
  Smoke smokeEffect2;
  boolean smoke1Visible, smoke2Visible;
  
  public Station(StationType _type, PVector _loc, PVector _size, PImage _sprite, Sector _sector) 
  {
    super("Military Station", _loc, _size, 1500, _sector);
    //TODO implement something besides military station

    sprite = _sprite.get();      //Use get() for a copy
    sprite.resize((int)size.x, (int)size.y);

    //Setup health, scaled by size
    health.max = ((int)(size.x/maxStationSize * maxStationHealth)/100)*100;      //Health scaled to size, take advantage of integer division to round
    health.current = health.max;

    //Prepare smoke damage effect
    smoke1Loc = new PVector(size.x/4 * rand.nextFloat(), size.y/2 * rand.nextFloat());
    smoke2Loc = new PVector(size.x/4 * rand.nextFloat(), size.y/2 * rand.nextFloat());
    smokeEffect1 = new Smoke(location, new PVector(10,10));      //Place at origin for time being, use smoke locations in update
    smokeEffect2 = new Smoke(location, new PVector(10,10));  
    smoke1Visible = false;
    smoke2Visible = false;

    //Set the description string
    String descriptor = new String();
    descriptor += name;
    info = new TextWindow("Station Info", location, descriptor, true);
  }
  
  @Override public void DrawObject()
  {
    super.DrawObject();
    
    //Draw smoke effects
    if(smoke1Visible)
    {
      smokeEffect1.DrawObject();
    }
    if(smoke2Visible)
    {
      smokeEffect2.DrawObject();
    }
  }
  
/*Click & mouseover UI*/
  public ClickType GetClickType()
  {
    return ClickType.INFO;
  }
  
  public void Click()
  {
    println("INFO: No interaction defined for station click");
  }
  
  public void MouseOver()
  {
    info.visibleNow = true;
    info.DrawObject();
  }
  
  public void UpdateUIInfo()
  {
    //Update textbox
    info.UpdateLocation(location);
    
    //Set the description string
    String descriptor = new String();
    descriptor += name;    
    info.UpdateText(descriptor);
  }
  
  
  public void Update()
  {
    super.Update();    //Call physical update
    
    //Check if UI is currently rendered, and if so update info
    if(info.visibleNow)
    {
      UpdateUIInfo();
    }
    //Assume UI will not be rendered next frame
    info.visibleNow = false;    //Another mouseover/ click will negate this
    
    //Update icon overlay
    iconOverlay.UpdateLocation(location);
    
    //Check health effect thresholds
    if(health.current <= health.max/2)
    {
      smoke1Visible = true;
    }
    if(health.current <= health.max/4)
    {
      smoke2Visible = true;
    }
    
    //Update smoke effect location
    if(smoke1Visible)
    {
      smokeEffect1.location = PVector.add(location,smoke1Loc);
      smokeEffect1.Update();
    }
    if(smoke2Visible)
    {
      smokeEffect2.location = PVector.add(location,smoke2Loc);
      smokeEffect2.Update();
    }
    
    //If the ship will die after this frame
    if(toBeKilled)
    {
      GenerateDeathExplosions(5, location, size);
    }
  }
}
public enum DrawStyle {
  STANDARD, GRADIENT
}

class TextWindow extends UI
{  
  private String textData = "";
  private int backgroundColor;            //For standard background
  private int gradientColor;         //Destination color (background -> gradientColor)
  private int textRenderMode;          //Render as center or corner
  private DrawStyle fillMode;          //How to fill the text window
  
  ArrayList<Drawable> icons;  //Icons within the window
  
  TextWindow(String _name, PVector _loc, String _text, boolean _scalesWithZoom)
  {
    super(_name, _loc, new PVector(200, 125), _scalesWithZoom);      //Default size 200 by 100
    textData = _text;
    
    fillMode = DrawStyle.STANDARD;      //Solid color fill by default
    backgroundColor = color(0,0,65,200);
    textColor = color(255);
    textRenderMode = CORNER;
    renderMode = CORNER;            //Default render mode for a textbox is corner
    
    icons = new ArrayList<Drawable>();
  }
  
  TextWindow(String _name, PVector _loc, PVector _size, String _text, boolean _scalesWithZoom)
  {
    super(_name, _loc, _size, _scalesWithZoom);      //Non-standard window size
    textData = _text;
    
    fillMode = DrawStyle.STANDARD;      //Solid color fill by default
    backgroundColor = color(0,0,65,200);
    textColor = color(255);
    textRenderMode = CORNER;
    renderMode = CORNER;            //Default render mode for a textbox is corner
    
    icons = new ArrayList<Drawable>();
  }
  
  TextWindow(String _name, PVector _loc, PVector _size, String _text, int _fontSize, boolean _scalesWithZoom)
  {
    super(_name, _loc, _size, _fontSize, _scalesWithZoom);      //Non-standard window size
    textData = _text;
    
    fillMode = DrawStyle.STANDARD;      //Solid color fill by default
    backgroundColor = color(0,0,65,200);
    textColor = color(255);
    textRenderMode = CORNER;
    renderMode = CORNER;            //Default render mode for a textbox is corner
    
    icons = new ArrayList<Drawable>();
  }
  
  //TODO why does this DrawObject() function need to be scaled by wvd.view ratio but not others?
  @Override public void DrawObject()
  {
    pushMatrix();
    pushStyle();
    translate(location.x, location.y);
    
    //BACKGROUND
    rectMode(renderMode);

    if(fillMode == DrawStyle.STANDARD)
    {
      fill(backgroundColor);
    }
    else if(fillMode == DrawStyle.GRADIENT)
    {
      DrawGradient();
    }
    else
    {
      println("WARNING: tried to render textwindow background of unsupported DrawStyle");
    }
    

    if(scalesWithZoom)
    {
      rect(0, 0, size.x/wvd.viewRatio, size.y/wvd.viewRatio);
    }
    else
    {
      rect(0, 0, size.x, size.y);
    }
    
    //TEXT
    fill(textColor);
    if(textRenderMode == CENTER)
    {
      translate(size.x/2,0);    //Shift by half text box size (fake center rendering)
    }
    
    textAlign(textRenderMode,TOP);
    
    //Scale the text box with zoom
    if(scalesWithZoom)
    {
      textFont(font, fontSize/wvd.viewRatio);    //Scaled with zoom
    }
    else
    {
      textFont(font, fontSize);    //Standard font and size for drawing fonts
    }
    text(textData, 10, 10);
    
    //Icon
    if(icons.size() > 0)
    {
      for(Drawable img : icons)
      {
        img.DrawObject();
      }
    }
    popStyle();
    popMatrix();
  }
  
  public void AddIcon(PVector _loc, PVector _size, PImage _img)
  {
    Drawable icon = new Drawable("Civ icon", _loc, _size);
    icon.sprite = _img;
    icons.add(icon);
  }
  
  public void UpdateText(String _newText)
  {
    textData = _newText;
  }
  
  //Set single color background, change fill style
  public void SetBackgroundColor(int _background)
  {
    fillMode = DrawStyle.STANDARD;
    backgroundColor = _background;
  }
  
  public void SetTextColor(int _textColor)
  {
    textColor = _textColor;
  }
  
  public void SetTextRenderMode(int _mode)
  {
    if(_mode == CENTER || _mode == CORNER)
    {
      textRenderMode = _mode;
    }
    else
    {
      print("WARNING: tried to set text render mode on TextWindow ID=");
      print(ID);
      print(" to an invalid value (not corner or center).\n");
    }
  }
  
  public void SetGradient(int c1, int c2) 
  {
    fillMode = DrawStyle.GRADIENT;
    backgroundColor = c1;
    gradientColor = c2;
  }

  
  private void DrawGradient()
  {
    noFill();
    
    int y = 0;
    int x = 0;
    int w = (int)size.x;
    int h = (int)size.y;
    
    for (int i = y; i <= y+h; i++) 
    {
      float inter = map(i, y, y+h, 0, 1);
      int c = lerpColor(backgroundColor, gradientColor, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  }
}

//Wrapper for a boolean to pass mutably between classes (Java doesnt support pointers or references)
public class TogglableBoolean
{
  public boolean value;
  
  TogglableBoolean(boolean _val)
  {
    value = _val;
  }
  
  public void Toggle()
  {
    value = !value;
  }
}
/*
 * A button that, when clicked, toggles a togglableboolean object (mutable). 
 * Requires a UI image for the  button, unlike a TextWindow
 */
public class ToggleButton extends UI implements Clickable
{
  String text;
  TogglableBoolean varToToggle;      //What to toggle if button is pushed
  private SoundFile clickSound;              //To play if clicked
  
  /**
   * Creates a button that, when clicked, toggles a mutable TogglableBoolean
   * object. Requires a sprite image from the UI folder.
   *
   * @param  _name              String ID for debugging of this object
   * @param  _loc               PVector screen coordinates to draw the button
   * @param  _size              PVector button size
   * @param  _text              Text inside the button to render. "" for no text
   * @param  _filename          Image file relative to Assets/UI/ to load for the button
   * @param  _TogglableBoolean  Mutable boolean object to toggle
   * @param  _scalesWithZoom    Boolean - does this object adhere to transform/pan of a zoom?
   * 
   * @see         ToggleButton
   */
  ToggleButton(String _name, PVector _loc, PVector _size, String _text, 
                  String _fileName, TogglableBoolean _variable, boolean _scalesWithZoom)
  {
    super(_name, _loc, _size, _scalesWithZoom);
    String fileName = "Assets/UI/";
    fileName += _fileName;
    sprite = loadImage(fileName);
    sprite.resize((int)size.x, (int)size.y);
    
    visibleNow = true;
    text = _text;
    varToToggle = _variable;
  }
  
  public void SetClickSound(SoundFile _sound)
  {
    clickSound = _sound;
  }
  
  public void SetTextColor(int _color)
  {
    textColor = _color;
  }
  
   
  @Override public void DrawObject()
  {
    pushMatrix();
    pushStyle();
    translate(location.x, location.y);
    
    imageMode(renderMode);
    image(sprite, 0, 0);
    
    textAlign(CENTER,CENTER);
    fill(textColor);      //For font coloring
    text(text, 0, 0);
    popStyle();
    popMatrix();
  }
  
  
  //Set the render mode for this icon
  public void SetRenderMode(int _renderMode)
  {
    renderMode = _renderMode;
  }

  public void UpdateUIInfo()
  {
  }
  
  public ClickType GetClickType()
  {
    return ClickType.BUTTON;
  }
  
  public void Click()
  {
    if(clickSound != null)
    {
      clickSound.play();
    }
    
    if(debugMode.value)
    {
      print("INFO: Clicked ");
      print(name);
      print("\n");
    }
    
    if(varToToggle != null)
    {
      varToToggle.value = !varToToggle.value;

    }
    else
    {
      println("INFO: Clicked button with no toggle set");
    }

  }
  
  public void MouseOver()
  {
  }
}
PFont standardFont =  createFont("Helvetica", 14);    // font name and size

public class UI extends Drawable
{
  PFont font;
  int fontSize;
  protected int textColor;      //Used by inhereted classes only
  
  boolean visibleNow;      //Is this part of the UI being rendered right now?
  boolean scalesWithZoom;
  
  public UI(String _name, PVector _loc, PVector _size, boolean _scalesWithZoom)
  {
    super(_name, _loc, _size);
    scalesWithZoom = _scalesWithZoom;
    
    font = standardFont;      //Use pre-generated font from above
    fontSize = 14;
    visibleNow = false;
  }
  
  public UI(String _name, PVector _loc, PVector _size, int _fontSize, boolean _scalesWithZoom)
  {
    super(_name, _loc, _size);
    scalesWithZoom = _scalesWithZoom;
    
    fontSize = _fontSize;
    font = createFont("Helvetica", fontSize);
    visibleNow = false;
  }
  
  //Update the absolute coordinates of this UI
  public void UpdateLocation(PVector _newlocation)
  {
    location = _newlocation;
  }
}
/*
 *  Updater methods on physical objects that run update loop and check for
 *  death condition.
 */

public void UpdatePhysicalObjects(ArrayList<? extends Physical> _object)
{
  for (Iterator<? extends Physical> iterator = _object.iterator(); iterator.hasNext();) 
  {
    Physical obj = iterator.next();
    obj.Update();
    if (obj.toBeKilled) 
    {
      // Remove the current element from the iterator and the list.
      iterator.remove();
    }

    if(obj.velocity.mag() > 0)      //If moving, check if it has left the sector
    {
      if(!CheckShapeOverlap(obj.currentSector.collider, obj.location))   //Is object inside the sector still?
      {
        println("[INFO] " + obj.name + " has left its parent sector...");
        //TODO should be doing rectangle-rectangle collision, not point-point. This should do for now
        //Object left sector -- find new sector it is in
        for(Sector sector : sectors.values())
        {
          if(CheckShapeOverlap(sector.collider, obj.location))
          {
            obj.currentSector = sector;
            println("[INFO] " + obj.name + " moved to sector " + sector.name);

            //HACK check if this is the playership to generate more sectors
            if(obj.name.toLowerCase().contains("player"))
            {
              //Add to temp hashmap, merge at end (see GameLoops & AssetLoader's MergeSectorMaps)
              generatedSectors = BuildSectors(obj.currentSector);
            }

            //Remove from current sector's objects, add to next sector's objects
            sector.ReceiveNewObject(obj);
            iterator.remove();      //Remove from current list inside sector
            return;
          }
        }
        println("[ERROR] Couldn't find what sector " + obj.name + " is in!");
      }
    }
  }
}


public void UpdateSectors(ArrayList<Sector> _sectors)
{
  for(Sector a : _sectors)
  {
    UpdatePhysicalObjects(a.ships);
    UpdatePhysicalObjects(a.asteroids);
    UpdatePhysicalObjects(a.planets);    //Station updates occur in planet update loop
  }
}


public void UpdateSectors(HashMap<Integer, Sector> _sectors)
{
  for(Sector a : _sectors.values())
  {
    UpdatePhysicalObjects(a.ships);
    UpdatePhysicalObjects(a.asteroids);
    UpdatePhysicalObjects(a.planets);  //Station updates occur in planet update loop
  }
}

//******* DRAW ********//

public void DrawObjects(ArrayList<? extends Drawable> _objects)
{
  for(Drawable a : _objects)
  {
    a.DrawObject();
  }
}

/**
 * Draw sectors and all child objects
 * @param {Hashmap<Int,Sector> _sectors Draw sector background
 * then all objects on top of it
 */
public void DrawSectors(Map<Integer, Sector> _sectors)
{
  //Draw sector backgrounds themselves
  for(Sector a : _sectors.values())
  {
    a.DrawObject();

    if(debugMode.value)
    {
      a.collider.DrawObject();
    }
  }

  for(Sector a : _sectors.values())
  {
    DrawObjects(a.planets);     //Stations drawn here too
  }

  for(Sector a : _sectors.values())
  {
    DrawObjects(a.asteroids);
  }

  for(Sector a : _sectors.values())
  {
    DrawObjects(a.ships);
  }
}

/**
 * Draw a raw arraylist of sector objects and their contents
 * @param {ArrayList<Sector>} _sectors Sector list to draw
 */
public void DrawSectors(ArrayList<Sector> _sectors)
{
  //Draw sector backgrounds themselves
  for(Sector a : _sectors)
  {
    a.DrawObject();
  }

  for(Sector a : _sectors)
  {
    ArrayList<Planet> planets = a.planets;
    DrawObjects(planets);     //Stations drawn here too
  }

  for(Sector a : _sectors)
  {
    ArrayList<Asteroid> asteroids = a.asteroids;
    DrawObjects(asteroids);
  }

  for(Sector a : _sectors)
  {
    ArrayList<Ship> ships = a.ships;
    DrawObjects(ships);
  }
}


public void DrawShields(ArrayList<Shield> _shields)
{
  for(Shield shield : _shields)
  {
    //Draw shield
    if(shield.collidable)
    {
      //TODO allow for shield rotation (need a physical object with rotation, shape wont cut it)
      shield.overlay.DrawObject();
    }
  }
}

//******* MOVE ********//

/**
 * Move all objects in a sector
 * @param _sectors [description]
 */
public void MoveSectorObjects(Map<Integer, Sector> _sectors)
{
  for(Sector a : _sectors.values())
  {
    MovePhysicalObject(a.planets);     //Stations drawn here too
  }

  for(Sector a : _sectors.values())
  {
    MovePhysicalObject(a.asteroids);
  }

  for(Sector a : _sectors.values())
  {
    MovePhysicalObject(a.ships);
  }
}

//Move an array of movable objects
public void MovePhysicalObject(ArrayList<? extends Physical> physical)
{
  for(Physical a : physical)
  {
    a.Move();
  }
}

//******* ZOOM ********//

public void BeginZoom()
{
  pushMatrix();
  translate(-wvd.orgX * wvd.viewRatio, -wvd.orgY * wvd.viewRatio);
  scale(wvd.viewRatio);
}

public void EndZoom()
{
  popMatrix();
}

//******* EXPLOSIONS ********//

//Generate a number of explosions, generally upon the death of some ship, station, etc
public void GenerateDeathExplosions(int _count, PVector _center, PVector _deadObjSize)
{
  for(int i = 0; i < _count; i++)
  {
    float explosionScale = rand.nextFloat() + 0.5f;    //explosion scale 0.5-1.5
    PVector explosionSize = new PVector(explosionScale * 64, explosionScale * 48);  //Scale off standard size
    PVector spawnLoc = new PVector(_center.x + _deadObjSize.x/2 * rand.nextFloat() - 0.5f, 
                  _center.y + _deadObjSize.y/2 * rand.nextFloat() - 0.5f);
    
    Explosion explosion = new Explosion(spawnLoc, explosionSize); 
    int frameDelay = rand.nextInt(60);                //Delay 0-60 frames
    explosion.SetRenderDelay(frameDelay);             //Setup delay on this explosion to render
    
    //TODO add global explosion
    explosions.add(explosion);                        //Add this explosion to an ArrayList<Explosion> for rendering
  }
}
/*
 * A helper class to aid in zooming in/out and panning
 * Sourced & modified from Processing forum user 'quarks' on post:
 * http://forum.processing.org/one/topic/zoom-based-on-mouse-position.html
*/
class WorldViewData {
  // Pan offsets Made public to speed up get access
  public float orgX = 0.0f;
  public float orgY = 0.0f;
  // viewRatio = number of pixels that represents a distance
  // of 1.0 in real world coordinates - bigger the value the
  // greater the magnification
  public float viewRatio = 1.0f;

  public WorldViewData() {
    orgX = 0.0f;
    orgY = 0.0f;
    viewRatio = 1.0f;
  }

  /**
   * Resize the world due to changes in magnification
   * so that the image is centred on the screen
   * @param f    new viewRatio
   * @param pw    width of view area in pixels
   * @param ph    height of view area in pixels
   */
  public void resizeWorld(float zf, int pw, int ph) {
    float newX, newY;
    float w = pw;
    float h = ph;
    // Calculate new origin so as to centre the image
    newX = orgX + w/(2.0f*viewRatio) - w/(2.0f*zf);
    newY = orgY + h/(2.0f*viewRatio) - h/(2.0f*zf);
    orgX = newX;
    orgY = newY;
    viewRatio = zf;
  }

  // Calculate the world X position corresponding to
  // pixel position
  public float pixel2worldX(float px) {
    return orgX + px / viewRatio;
  }

  // Calculate the world Y position corresponding to
  // pixel position
  public float pixel2worldY(float py) {
    return orgY + py / viewRatio;
  }

  // Calculate the display X position corresponding to
  // world position
  public float world2pixelX(float wx) {
    return viewRatio / (wx - orgX);
  }

  // Calculate the display Y position corresponding to
  // world position
  public float world2pixelY(float wy) {
    return viewRatio / (wy - orgY);
  }

  /**
   * Set origin of top left to x, y
   * @param x
   * @param y
   * @return true if the origin has changed else return false
   */
  public boolean setXY(float x, float y) {
    if (orgX != x || orgY != y) {
      orgX = x;
      orgY = y;
      return true;
    }
    else
      return false;
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "TheVoid" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
