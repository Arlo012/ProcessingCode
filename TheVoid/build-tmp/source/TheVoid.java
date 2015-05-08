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

GameState gameState;
boolean restartFlag;    //Restart game?

//Game Name
String title = "The Void";

//Game objects and areas
HashMap<Integer,Sector> sectors;      //Sector IDs mapped against sector objects
HashMap<Integer,Sector> generatedSectors;   //Storage of mid-loop generated sectors for later merging
ArrayList<Sector> visibleSectors;     //Sectors on-screen right now (only render/update these)
ArrayList<Explosion> explosions;      //Explosions are global game object
PVector sectorSize;                   //Set to width/height for now
PVector playerSize;                   //Used to resize player image

//Start Menu stuff
float introAngle;                     //Angle used to shift background during Start menu
boolean sPressed, mPressed;
PVector startLocation;
PVector startAccel;
PVector startVel;

//Counters
long loopCounter;        //How many loop iterations have been completed
long loopStartTime;      //Millis() time main loop started

//Debugging & profiling
static boolean debuggingAllowed = true;      //Display DEBUG button on GUI?
TogglableBoolean debugMode = new TogglableBoolean(false);
boolean profilingMode = false;

//Handle zooming http://forum.processing.org/one/topic/zoom-based-on-mouse-position.html
float minX, maxX, minY, maxY;
WorldViewData wvd = new WorldViewData();

//UI Info
LinkedList<Clickable> toDisplay;        //List of clickable UI objects to display //<>//

Player playerShip;

public void setup()
{
  size(1800, 1000, P3D);    //Need 3D acceleration to make this game run at decent FPS
  frame.setTitle(title);

  gameState = GameState.START;
  restartFlag = false;
  background(0);        //For new game, reset  background

  //Zoom setup
  cursor(CROSS);
  minX = 0;
  minY = 0;
  maxX = width;
  maxY = height;

  //Load all image/sound assets
  LoadImageAssets();      //See AssetLoader.pde
  LoadSoundAssets();
  PrepareUIElements();
  startupFont = loadFont("SourceCodePro-Regular-48.vlw");

  //Game area setup
  sectors = new HashMap<Integer, Sector>();
  generatedSectors = new HashMap<Integer, Sector>();
  sectorSize = new PVector(2*width,2*height);
  visibleSectors = new ArrayList<Sector>();   //TODO implement me
  explosions = new ArrayList<Explosion>();

  //Start Menu initialize
  introAngle = 0.0f;
  mPressed = false;
  sPressed = false;
  startLocation = new PVector(displayWidth/2,displayHeight/2);
  startVel= new PVector(0,0);
  startAccel = new PVector(.04f,0);
  
  //Player and sector setup
  PVector spawnLocation = new PVector(width, height);
  playerSize = new PVector(100,50);
  int playerMass = 100;
  Shape playerCollider = new Shape("collider", spawnLocation, playerSize, color(0,255,0), 
              ShapeType._RECTANGLE_);
  playerShip = new Player(spawnLocation, playerSize, shipSprite, playerMass, 
              color(255,0,0), null, playerCollider);     //null sector until created
  playerShip.health.SetMaxHealth(1500);

  GameObjectSetup();    //See Helpers.pde
  playerShip.currentSector = sectors.get(0);      //Now that sector is created, feed to player obj
  sectors.get(0).ships.add(playerShip);

  //Counters & framerate
  loopCounter = 0;
  frameRate(60);
  loopStartTime = millis();
  
  //Intro music
  // introMusic.play();
  // trackStartTime = millis();
  // currentTrack = introMusic;
}

public void draw()
{
  // MusicHandler();      //Handle background music
  
  if(gameState == GameState.START)
  {
    DrawStartupLoop();
  }
  
  else if(gameState == GameState.INSTRUCTIONS)
  {
    DrawInstructionsLoop();
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
//Image Assets
PImage bg;             //Background
PFont standardFont;    //Standard font for all text windows
PFont introFont;       //Start screen font
PFont instructFont;    //Intrustion font

PImage charredPlayerShip;       //For gameover, charred ship
PImage blueButton, redButton;   //For background of health
PImage blueBar, redBar;         //For percent health

//TODO move all PImage instances here
PImage nebula1, nebula2, nebula3;
ArrayList<PImage> nebulaSprites;
PImage shipSprite; 
PImage shieldSprite;
PImage redLaser, greenLaser;
ArrayList<PImage> enemyShipSprites; 
ArrayList<PVector> enemyShipSizes;      //Size (by index) of above sprite
int enemyShipTypeCount = 10;                //HACK this is rigid -- careful to update if add ships
PImage redPowerupSprite, shieldPowerupSprite, enginePowerupSprite;
public void LoadImageAssets()
{
  bg = loadImage("Assets/Backgrounds/back_3.png");
  bg.resize(width, height);
  
  standardFont = loadFont("SourceCodePro-Regular-48.vlw");    // font name and size
  introFont = loadFont("Magneto-Bold-128.vlw");
  instructFont = loadFont("OCRAExtended-128.vlw");

  //Load sprites
  asteroidSpriteSheet = loadImage("Assets/Environment/asteroids.png");
  shipSprite = loadImage("Assets/Ships/10(2).png");

  //enemy ships
  enemyShipSprites = new ArrayList<PImage>();
  enemyShipSizes = new ArrayList<PVector>();

  //Shields
  shieldSprite = loadImage("Assets/Effects/ShieldFull.png");

  //Nebulas
  nebula1 = loadImage("Assets/Nebula/Nebula1.png");
  nebula2 = loadImage("Assets/Nebula/Nebula2.png");
  nebula3 = loadImage("Assets/Nebula/Nebula3.png");
  nebulaSprites = new ArrayList<PImage>();
  nebulaSprites.add(nebula1);
  nebulaSprites.add(nebula2);
  nebulaSprites.add(nebula3);

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

  redLaser = loadImage("Assets/Weapons/laserRed12.png");
  greenLaser = loadImage("Assets/Weapons/laserGreen02.png");

  redPowerupSprite = loadImage("Assets/Power-ups/powerupRed_bolt.png");
  enginePowerupSprite = loadImage("Assets/Power-ups/things_gold.png");
  shieldPowerupSprite = loadImage("Assets/Power-ups/powerupBlue_shield.png");

  charredPlayerShip = loadImage("Assets/Ships/ship_charred.png");
  
  //Load explosions (see Explosion.pde for variables)
  for (int i = 1; i < explosionImgCount + 1; i++) 
  {
    // Use nf() to number format 'i' into four digits
    String filename = "Assets/Effects/64x48/explosion1_" + nf(i, 4) + ".png";
    explosionImgs[i-1] = loadImage(filename);
  }

  //Load UI Elements
  blueButton = loadImage("Assets/UI/PNG/blue_button13.png");
  redButton = loadImage("Assets/UI/PNG/red_button10.png");
  blueBar = loadImage("Assets/UI/PNG/blue_sliderUp.png");
  redBar = loadImage("Assets/UI/PNG/red_sliderUp.png");
}

SoundFile explosionSound, collisionSound, laserSound, 
    clickShipSpawnButtonSound, clickMissileSpawnButtonSound, clickNormalModeButtonSound, 
    clickCancelOrderButtonSound, errorSound, shieldHitSound, laserHitSound;
    
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
  laserHitSound = new SoundFile(this, sketchDir + "Assets/SoundEffects/Weapons/laser4_0.wav");

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



//Shield/health bars
PVector blueButtonSize;
PVector blueButtonLocation; 
PVector redButtonSize;
PVector redButtonLocation; 
PVector barOffset;      //How far bars are offset from UI background
PVector barSize;        
int barSpacing;         //How far bars are apart
//Engine power bars
int fullThrottleSize;   //Y size
PVector leftThrottleLocation, rightThrottleLocation;
PVector leftThrottleSize, rightThrottleSize;
public void PrepareUIElements()
{
//Shield/health bars
  blueButtonSize = new PVector(width/2.5f, height/16);
  blueButtonLocation = new PVector(0, height - 2 *blueButtonSize.y);
  blueButton.resize((int)blueButtonSize.x, (int)blueButtonSize.y);

  redButtonSize = blueButtonSize;
  redButtonLocation = new PVector(0, height - redButtonSize.y);
  redButton.resize((int)redButtonSize.x, (int)redButtonSize.y);

  barSize = new PVector(width/42, height/22);
  barOffset = new PVector(width/50,height/100);
  barSpacing = (int)barSize.x + 10;

//Engine power bars
  fullThrottleSize = height/4;
  leftThrottleSize = new PVector(width/32, fullThrottleSize);    //Max
  rightThrottleSize = leftThrottleSize.get();   //Same size

  leftThrottleLocation = new PVector(width - 2* leftThrottleSize.x, height - leftThrottleSize.y);
  rightThrottleLocation = new PVector(width - rightThrottleSize.x, height - rightThrottleSize.y);
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
  
  public Asteroid(PVector _loc, int _diameter, int _mass, Sector _sector, Shape _collider) 
  {
    //Parent constructor
    super("Asteroid", _loc, new PVector(_diameter, _diameter), _mass, _sector, _collider);
    
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
        Shape debrisCollider = new Shape("collider", location, new PVector((int)size.x/2, (int)(size.y/2)), color(0,255,0), ShapeType._CIRCLE_);
        Asteroid debris = new Asteroid(location, (int)size.x/2, (int)(mass/2), currentSector, debrisCollider);
        
        //New velocity with some randomness based on old velocity
        debris.SetVelocity(new PVector(velocity.x/4 + rand.nextFloat()*localSpeedLimit/6,
                                        velocity.y/4 + rand.nextFloat()*localSpeedLimit/6));
        debris.isDebris = true;
        
        //See AsteroidFactory for details on this implementation
        debris.SetMaxSpeed(2.5f);      //Local speed limit for asteroid
        
        //Setup health, scaled by size relative to max size. 1/4 health of std asteroid
        //HACK this just overwrites the constructor
        debris.health.max = (int)(debris.size.x/maxDiameter * maxAsteroidHealth)/8;
        debris.health.current = health.max;
        
        currentSector.debrisSpawned.add(debris);
      }
    }
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
  private PVector maxVelocity = new PVector(.2f,.1f);                 //Max velocity in given x/y direction of asteroid

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
    Shape colliderGenerated = new Shape("collider", new PVector(xCoor, yCoor), new PVector(size, size), 
                color(0,255,0), ShapeType._CIRCLE_);
    Asteroid toBuild = new Asteroid(new PVector(xCoor, yCoor), size, PApplet.parseInt(1000*size/asteroidSizeRange.y),
                nextAsteroidSector, colliderGenerated);
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
    HandleCollisions(a.enemyLaserFire, playerShip);
    HandleCollisions(a.enemyLaserFire, a.asteroids);
    HandleCollisions(a.friendlyLaserFire, a.asteroids);
    HandleCollisions(a.friendlyLaserFire, a.ships);   //HACK still allows player collision with his own shots
    HandleCollisions(a.asteroids);

    for(Planet p : a.planets)
    {
      HandleCollisions(a.enemyLaserFire, p.stations);
      HandleCollisions(a.friendlyLaserFire, p.stations);
      HandleCollisions(a.asteroids, playerShip.shield);

      HandleFriendlyCollision(p.stations, playerShip);    //Heal at stations
    }

    for(Ship s : a.ships)
    {
      if(s.shield.online && s.shield.enabled)
      {
        HandleCollisions(a.asteroids, s.shield);
        HandleCollisions(a.enemyLaserFire, s.shield);   //HACK doesn't allow for enemy shields
      }
    }

    HandleFriendlyCollision(a.powerups, playerShip);
    
  }
}

public void HandleCollisions(ArrayList<? extends Physical> a, ArrayList<? extends Physical> b)
{
  Shape collider1, collider2;
  for(Physical obj1 : a)
  {
    for(Physical obj2 : b)
    {
      if(obj1.collidable && obj2.collidable)
      {
        collider1 = obj1.collider;      //Grab shape objects for overlap checking
        collider2 = obj2.collider;

        if(CheckShapeToShapeOverlap(collider1, collider2))
        {
          if(debugMode.value)
          {
            print("[DEBUG] COLLISION BETWEEN: ");
            print(obj1.name + "[" + obj1.GetID() + "]");
            print(" & ");
            print(obj2.name + "[" + obj2.GetID() + "]");
            print("\n");
          }
          // collisionSound.play();
          obj1.HandleCollision(obj2);
          obj2.HandleCollision(obj1);
        }
      }

    }
  }
}

public void HandleCollisions(ArrayList<? extends Physical> a, Physical obj2)
{
  Shape collider1, collider2;
  collider2 = obj2.collider;      //Grab shape object for overlap checking
  for(Physical obj1 : a)
  {
    if(obj1.collidable && obj2.collidable)
    {
      collider1 = obj1.collider;
      if(CheckShapeToShapeOverlap(collider1, collider2)) 
      {
        if(debugMode.value)
        {
          print("[DEBUG] COLLISION BETWEEN: ");
          print(obj1.name + "[" + obj1.GetID() + "]");
          print(" & ");
          print(obj2.name + "[" + obj2.GetID() + "]");
          print("\n");
        }
        // collisionSound.play();
        obj1.HandleCollision(obj2);
        obj2.HandleCollision(obj1);
      }
    }
  }
}

/**
 * Handle self collisions within physical object list
 * @param a ArrayList of physical objects to check self-collision on
 */
public void HandleCollisions(ArrayList<? extends Physical> a)
{
  Shape collider1, collider2;
  for(Physical obj1 : a)
  {
    for(Physical obj2 : a)
    {
      if(obj1 != obj2)
      {
        if(obj1.collidable && obj2.collidable)
        {
          collider1 = obj1.collider;      //Grab shape objects for overlap checking
          collider2 = obj2.collider;

          if(CheckShapeToShapeOverlap(collider1, collider2))
          {
            if(debugMode.value)
            {
              print("[DEBUG] COLLISION BETWEEN: ");
              print(obj1.name + "[" + obj1.GetID() + "]");
              print(" & ");
              print(obj2.name + "[" + obj2.GetID() + "]");
              print("\n");
            }
            // collisionSound.play();
            obj1.HandleCollision(obj2);
            obj2.HandleCollision(obj1);
          }
        }
      }
    }
  }
}

/**
 * Handle a friendly object providing aid to the player (or enemy!)
 * @param a   List of objects that MIGHT be friendly
 * @param obj Physical object which will receive aid
 */
public void HandleFriendlyCollision(ArrayList<? extends Physical> a, Physical obj2)
{
  Shape collider1, collider2;
  collider2 = obj2.collider;      //Grab shape object for overlap checking
  for(Physical obj1 : a)
  {
    // if(implementsInterface(a, Friendly))
    // {
      collider1 = obj1.collider;
      if(CheckShapeToShapeOverlap(collider1, collider2)) 
      {
        if(debugMode.value)
        {
          print("[DEBUG] FRIENDLY AID BETWEEN: ");
          print(obj1.name + "[" + obj1.GetID() + "]");
          print(" & ");
          print(obj2.name + "[" + obj2.GetID() + "]");
          print("\n");
        }
        Friendly friend = (Friendly)obj1;
        friend.ProvideAid(obj2);
      }
    // }
  }
}

//Check if a point falls within a drawable object
public boolean CheckDrawableOverlap(Drawable obj, PVector point)
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

//Check if a point falls within a drawable object
public boolean CheckDrawableOverlap(Drawable obj1, Drawable obj2)
{
  if(obj1 != null)
  {  
    PVector collisionOffset1, collisionOffset2;      //Offset due to center vs rect rendering (rect = 0 offset)
    //Check if this is CENTER or CORNER rendered -- center rendered needs to account for half size of self
    if(obj1.renderMode == CENTER)
    {
      collisionOffset1 = new PVector(-obj1.size.x/2, -obj1.size.y/2);
    }
    else if(obj1.renderMode == CORNER)
    {
      collisionOffset1 = new PVector(0,0);
    }
    else
    {
      collisionOffset1 = new PVector(obj1.size.x/2, obj1.size.y/2);
      print("WARNING: Unsupported collision offset mode on");
      print(obj1.name);
      print("\n");
    }

    if(obj2.renderMode == CENTER)
    {
      collisionOffset2 = new PVector(-obj2.size.x/2, -obj2.size.y/2);
    }
    else if(obj2.renderMode == CORNER)
    {
      collisionOffset2 = new PVector(0,0);
    }
    else
    {
      collisionOffset2 = new PVector(obj2.size.x/2, obj2.size.y/2);
      print("WARNING: Unsupported collision offset mode on");
      print(obj2.name);
      print("\n");
    }
    
    if(obj1.location.x + collisionOffset1.x >= obj2.location.x - collisionOffset2.x   //X from right
        && obj1.location.y + collisionOffset1.y >= obj2.location.y - collisionOffset2.y  //Y from top
        && obj1.location.x - collisionOffset1.x <= obj2.location.x + collisionOffset2.x  //X from left
        && obj1.location.y - collisionOffset1.y <= obj2.location.y + collisionOffset2.x)    //Y from bottom
    {
      return true;
    }
  }
  
  return false;
}


public boolean CheckShapeToShapeOverlap(Shape obj1, Shape obj2)
{
  if(obj1 == obj2)    //Avoid self collision
  {
    return false;
  }

  //*Handle different combinations of collisions*//
  //Line-line collisions
  if(obj1.shapeType != ShapeType._CIRCLE_ && obj2.shapeType != ShapeType._CIRCLE_)
  {
    //Check if any of the lines in the first object overlap any of the lines
    //in the second object
    for(Line line1 : obj1.lines)     
    {
      for(Line line2 : obj2.lines)
      {
        if(LineLineCollision(line1, line2))
        {
          return true;
        }
      }
    }
  }
  //Obj1 circle, obj2 not
  else if(obj1.shapeType == ShapeType._CIRCLE_ && obj2.shapeType != ShapeType._CIRCLE_)
  {
    for(Line line2 : obj2.lines)
    {
      if(LineCircleCollision(obj1, line2))    //Check every line in obj2's line list against the circle
      {
        return true;
      }
    }
  }
  //Obj2 circle, obj1 not
  else if(obj2.shapeType == ShapeType._CIRCLE_ && obj1.shapeType != ShapeType._CIRCLE_)
  {
    for(Line line1 : obj1.lines)
    {
      if(LineCircleCollision(obj2, line1))
      {
        return true;
      }
    }
  }
  //Circle-circle
  else if(obj2.shapeType == ShapeType._CIRCLE_ && obj1.shapeType == ShapeType._CIRCLE_)
  {
    if(BallBallCollision(obj1, obj2))
    {
      return true;
    }
  }
  else
  {
    println("[WARNING] Unsupported collision type!");
  }

  return false;
}

public boolean CheckShapeToPointOverlap(Shape obj1, PVector point2)
{
  println("[WARNING] Point collision not implemented!");
  return false;
}


/**
 * Credit Jeff Thompson, modified by Jeff Eitel
 * @param  {Line} line1 Line to check
 * @param  {Line} line2 Line to check
 * @return   {boolean} True if collided
 */
public boolean LineLineCollision(Line line1, Line line2)
{
  float x1, x2, x3, x4, y1, y2, y3, y4;
  x1 = line1.start.x;
  y1 = line1.start.y;

  x2 = line1.end.x;
  y2 = line1.end.y;

  x3 = line2.start.x;
  y3 = line2.start.y;

  x4 = line2.end.x;
  y4 = line2.end.y;

  // find uA and uB
  float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

  // note: if the below equations is true, the lines are parallel
  // ... this is the denominator of the above equations
  // (y4-y3)*(x2-x1) - (x4-x3)*(y2-y1)

  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) 
  {
    // find intersection point, if desired
    float intersectionX = x1 + (uA * (x2-x1));
    float intersectionY = y1 + (uA * (y2-y1));
    // noStroke();
    // fill(0);
    // ellipse(intersectionX, intersectionY, 10,10);

    return true;
  }
  else 
  {
    return false;
  }
}

/**
 * Source: http://www.openprocessing.org/sketch/65771
 * Modified for use with my data types
 * @param  {Shape} ball Ball object with type circle
 * @param  {Line} line A line....
 * @return     True for any collision type, false for no collision
 */
public boolean LineCircleCollision(Shape ball, Line line)
{
  // Translate everything so that line segment start point to (0, 0)
  PVector ballLoc = ball.location.get();
  ballLoc.x -= line.start.x;
  ballLoc.y -= line.start.y;
  PVector lineEnd = new PVector(line.end.x, line.end.y);
  lineEnd.x -= line.start.x;
  lineEnd.y -= line.start.y;
  float r = ball.size.x/2;

  float a = lineEnd.x; // Line segment end point horizontal coordinate
  float b = lineEnd.y; // Line segment end point vertical coordinate
  float c = ballLoc.x; // Circle center horizontal coordinate
  float d = ballLoc.y; // Circle center vertical coordinate
  
  // Collision computation
  boolean startInside = false;
  boolean endInside = false;
  boolean middleInside = false;
  if ((d*a - c*b)*(d*a - c*b) <= r*r*(a*a + b*b)) 
  {
    // Collision is possible
    if (c*c + d*d <= r*r) 
    {
      // Line segment start point is inside the circle
      startInside = true;
      return true;
    }
    if ((a-c)*(a-c) + (b-d)*(b-d) <= r*r) 
    {
      // Line segment end point is inside the circle
      endInside = true;
      return true;
    }
    if (!startInside && !endInside && c*a + d*b >= 0 && c*a + d*b <= a*a + b*b) 
    {
      // Middle section only
      middleInside = true;
      return true;
    }
  }

  return false;
}

/**
 * Credit Jeff Thompson, modified by Jeff Eitel
 * Ball-ball collision
 * @param  ball1 First shape object
 * @param  ball2 Second shape object
 * @return       True for collision, false for not
 */
public boolean BallBallCollision(Shape ball1, Shape ball2) 
{
  if(ball1.shapeType != ShapeType._CIRCLE_ || ball1.shapeType != ShapeType._CIRCLE_)
  {
    println("[ERROR] Tried to determine ball-ball collision on non-circle objects!");
    return false;
  }

  float x1, x2, y1, y2, d1, d2;
  x1 = ball1.location.x;
  y1 = ball1.location.y;
  x2 = ball2.location.x;
  y2 = ball2.location.y;
  d1 = ball1.size.x;
  d2 = ball2.size.x;
  // find distance between the two objects
  float xDist = x1-x2;                                   // distance horiz
  float yDist = y1-y2;                                   // distance vert
  float distance = sqrt((xDist*xDist) + (yDist*yDist));  // diagonal distance

  // test for collision
  if (d1/2 + d2/2 > distance) {
    return true;    // if a hit, return true
  }
  else {            // if not, return false
    return false;
  }
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
    
    //Facing
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
      print("[WARNING] Tried to draw base drawable object with no sprite! ID = ");
      print(name);
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
  boolean fleeingPlayer;
  Player player;
  
  int avoidAsteroidWeight, avoidPlayerWeight, seekPlayerWeight, avoidShipWeight;  // Handles enemies priority of movement
  
  int firingRange;     //How far away enemy will fire

  int asteroidFleeDistance = 100;
  int shipFleeDistance = 100;

  public Enemy(String _name, PVector _loc, PVector _size, PImage _sprite, int _mass, int _outlineColor, Sector _sector, Shape _collider) 
  {
    //Parent constructor
    super(_name, _loc, _size, _sprite, _mass, _outlineColor, _sector, _collider);
    
    //Convenience pointer to player
    player = playerShip;

    //Flee/attack
    fleeingPlayer = false;
    targets.add(player);      //All enemies are looking for the player
    
    firingRange = (width + height)/2;

    //Weight Amounts for flee/seek
    avoidAsteroidWeight = 2;
    avoidShipWeight = 3;
    avoidPlayerWeight = 3;
    seekPlayerWeight = 1;

    localSpeedLimit = 4.5f;
    maxForceMagnitude = 0.3f;      //For smoother turning
  }

  @Override public void Update()
  {
   super.Update();

   ArrayList<Sector> thisSectorAndNeighbors = currentSector.GetSelfAndAllNeighbors();
   for(Sector s : thisSectorAndNeighbors)
   {
     for(Asteroid a : s.asteroids)
     {
       if(PVector.dist(a.location, location) < asteroidFleeDistance)
       {
         PVector avoidAsteroidForce = Avoid(a.location);
         avoidAsteroidForce.mult(avoidAsteroidWeight);
         ApplyForce(avoidAsteroidForce);
       }
     }

     for(Ship ship : s.ships)
     {
      if(ship != this && ship != playerShip)
      {
        if(PVector.dist(ship.location, location) < shipFleeDistance)
        {
          PVector avoidShipForce = Avoid(ship.location);
          avoidShipForce.mult(avoidShipWeight);
          ApplyForce(avoidShipForce);
        }
      }
     }
   }

   PVector avoidPlayerForce = Avoid(playerShip.location);
   avoidPlayerForce.mult(avoidPlayerWeight);
   PVector seekPlayerForce = Seek(playerShip.location);
   seekPlayerForce.mult(seekPlayerWeight);

   if(CheckDrawableOverlap(player.seekCircle, location))   //I see the player
   {
      if(CheckDrawableOverlap(player.avoidCircle, location))
      {
        fleeingPlayer = true;
      }
      else if(!CheckDrawableOverlap(player.avoidCircle, location) 
        && !CheckDrawableOverlap(player.seekAgainCircle, location))    //I am in the seek circle but NOT either of the others
      {
        fleeingPlayer = false;
      }

     if(fleeingPlayer)
     {
        ApplyForce(avoidPlayerForce);
     }
     else
     {
        ApplyForce(seekPlayerForce);
     }
   }

   //**** WEAPONS *****//
    if(millis() - lastFireTime > currentFireInterval)    //Time to fire?
    {
      if(!targets.isEmpty())
      {
        Physical closestTarget = null;    //Default go after closest target
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
          float targetRange = PVector.dist(closestTarget.location, location);
          if(targetRange < firingRange)   //I am within fire range of player
          {
            BuildLaserToTarget(closestTarget, LaserColor.RED);
            lastFireTime = millis();
          }
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
    PVector steer = Seek(target);
    steer.mult(-1);      // to flip the direction of the desired vector in the opposite direction of the target
    
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
  imageMode(CORNER);
  image(bg, -10 + (10*sin(introAngle + HALF_PI)),(10*sin(introAngle)),displayWidth+20,displayHeight+20);
  image(nebula3, displayWidth*.55f + (10*sin(introAngle + HALF_PI)), displayHeight*.25f +(10*sin(introAngle + HALF_PI)));
  image(shipSprite,startLocation.x,startLocation.y, playerSize.x,playerSize.y);
  
  fill(75,247,87);   //Green
  textFont(introFont, 154);
  textAlign(CENTER, CENTER);
  text("The", displayWidth/2 - 72, displayHeight/8);
  textAlign(CENTER, CENTER);
  text("Void", displayWidth/2 + 72, displayHeight/8 + 154);
  fill(255);
  textFont(instructFont, 56);
  text("Press 'S' to enter The Void!", displayWidth/2, displayHeight*.8f);
  text("Press 'M' for instructions", displayWidth/2, displayHeight*.8f + 72);
  if(introAngle <= 6.28f)
  {
    introAngle += .01f;
  }
  else
  {
    introAngle = 0.0f;
  }
  
  if(mPressed || sPressed)
  { 
    startLocation.add(startVel);
    startVel.add(startAccel);
    if(startLocation.x > displayWidth + 2*playerSize.x && mPressed)
    {
      gameState = GameState.INSTRUCTIONS;
    }
    else if(startLocation.x > displayWidth + 2*playerSize.x && sPressed)
    {
      gameState = GameState.PLAY;
    }
  }
}

int instructionNumber = 0;
public void DrawInstructionsLoop()
{
  textFont(instructFont, 32);
  image(bg,0,0,displayWidth,displayHeight);
  image(shipSprite, displayWidth/2, displayHeight/2, playerSize.x,playerSize.y);
  playerShip.leftEnginePower = 5.0f;
  playerShip.rightEnginePower = 7.0f;
  DrawMainUI();
  DrawControls();
        
  if(instructionNumber == 0)
  {
    textFont(instructFont, 56);
    textAlign(CENTER);
    text("Press 'N' to see next instructions", displayWidth/2, displayHeight/3);
  }
  else if(instructionNumber == 1)
  {
    DrawArrow(width/2.5f,height*.8f,HALF_PI,50);
    textFont(instructFont, 32);
    textAlign(LEFT);
    text("This is your Sheild Strength, you will not lose health\nwhile the sheild is up. Once your sheild is lost it will \nregenerate after 5 seconds.", 0, 
    displayHeight*.75f);
  }
  else if(instructionNumber == 2)
  {
    DrawArrow(width*.96f,height*.76f,HALF_PI,50);
    textFont(instructFont, 32);
    textAlign(RIGHT);
    text("These are you Engine Powers,\nyour left engine in green,\nyour right engine in blue",width,height*.65f);
  }
  else if(instructionNumber == 3)
  {
    PVector enemyShipSize = enemyShipSizes.get(0);
    image(enemyShipSprites.get(0), width*.8f, height/2,enemyShipSize.x*.25f,enemyShipSize.y*.25f);
    DrawArrow(width*.8f+enemyShipSize.x/8, height/2 - 60, HALF_PI, 50);
    textAlign(LEFT);
    textFont(instructFont, 32);
    text("This is an Enemy Ship. They will attack \nyou relentlessly until you are destroyed!",width/2,height/2-120);
  }
  else if(instructionNumber == 4)
  {
    image(blueStation1,width*.8f, height/2, blueStation1.width*.15f, blueStation1.height*.15f);
    DrawArrow(width*.8f+((blueStation1.width*.15f)/2), height/2 - 60,HALF_PI, 50);
    textAlign(LEFT);
    textFont(instructFont, 32);
    text("This is a Healing Station. Hover you ship \nabove it to regain health.",width/2,height/2-120);
  }
    
  
  
  playerShip.leftEnginePower = 0.0f;
  playerShip.rightEnginePower = 0.0f;
}


PVector cameraPan = new PVector(0,0);     //Pixels of camera pan to follow ship
public void DrawPlayLoop()
{
  textFont(startupFont, 12);
  background(0);

  loopCounter++;

  wvd.Reset();      //No zoom, pan, nothing
  pushMatrix();
  cameraPan.x = width/2 -playerShip.location.x;
  cameraPan.y = height/2 - playerShip.location.y;
  
  translate(cameraPan.x, cameraPan.y);    //Pan camera on ship
  
  if(mousePressed)    //Bullet hell
  {
    PVector offset = new PVector(width,height);
    offset.sub(playerShip.location);
    playerShip.BuildLaserToTarget(new PVector(2*mouseX-offset.x, 2*mouseY-offset.y), LaserColor.GREEN);
  }

  //ALL sectors (slower)
  if(profilingMode)
  {
    long start1 = millis();
    DrawSectors(sectors);   //Draw sectors (actually just push sector objects onto render lists)
    println("Draw time: " + (millis() - start1));

    long start2 = millis();
    MoveSectorObjects(sectors);   //Move all objects in the sectors
    println("Move time: " + (millis() - start2));

    long start3 = millis();
    HandleSectorCollisions(sectors);
    println("Collision time: " + (millis() - start3));

    long start4 = millis();
    UpdateSectorMap(sectors); //Update sectors (and all updatable objects within them)
    println("Update time: " + (millis() - start4));
  }
  else
  {
    DrawSectors(sectors);   //Draw sectors (actually just push sector objects onto render lists)
    MoveSectorObjects(sectors);   //Move all objects in the sectors
    HandleSectorCollisions(sectors);
    UpdateSectorMap(sectors); //Update sectors (and all updatable objects within them)
  }

  if(playerShip.toBeKilled)
  {
    gameState = GameState.GAMEOVER;

    //Update all enemy ships to not shoot
    ArrayList<Sector> nearbySectors = playerShip.currentSector.GetSelfAndAllNeighbors();
    for(Sector a : nearbySectors)
    {
      for(Ship s : a.ships)
      {
        if(s instanceof Enemy)
        {
          Enemy e = (Enemy)s;
          e.firingRange = 0;      //Prevent enemy from firing
        }
      }
    }
    
  }
  
  popMatrix();

  //// ******* DrawMainUI ********//
  DrawMainUI();

  //// ******* UPDATES ********//
  if(!generatedSectors.isEmpty())
  {
    MergeSectorMaps(generatedSectors);
  }

  //// ******* PROFILING ********//
  if(profilingMode)
  {
    println("Framerate: " + frameRate);
  }

  //// ******* GAMEOVER Condition ********//  

}


//Identical to main draw loop, but without updates
public void DrawPauseLoop()
{
  textFont(startupFont, 12);
  background(0);

  //******* ALL ZOOMED AFTER THIS ********//
  BeginZoom();      //See visuals.pde
  cameraPan.x = width/2 -playerShip.location.x;
  cameraPan.y = height/2 - playerShip.location.y;
  
  translate(cameraPan.x, cameraPan.y);    //Pan camera on ship

  DrawSectors(sectors);   //Draw sectors (actually just push sector objects onto render lists)
  
  // ******* ALL ZOOMED BEFORE THIS ********//
  EndZoom();
  DrawControls();

  //// ******* DrawMainUI ********//
  DrawMainUI();

  //// ******* UPDATES ********//
  if(!generatedSectors.isEmpty())
  {
    MergeSectorMaps(generatedSectors);
  }

}

public void DrawGameOverLoop()
{
  background(0);

  loopCounter++;

  BeginZoom();      //See visuals.pde
  cameraPan.x = width/2 -playerShip.location.x;
  cameraPan.y = height/2 - playerShip.location.y;
  
  translate(cameraPan.x, cameraPan.y);    //Pan camera on ship
  
  DrawSectors(sectors);   //Draw sectors (actually just push sector objects onto render lists)
  MoveSectorObjects(sectors);   //Move all objects in the sectors
  HandleSectorCollisions(sectors);
  UpdateSectorMap(sectors); //Update sectors (and all updatable objects within them)

  EndZoom();

  //// ******* DrawMainUI ********//

  fill(255,0,0); 
  textFont(introFont, 154);
  textAlign(CENTER, CENTER);
  text("Game", displayWidth/2 - 72, displayHeight/8);
  textAlign(CENTER, CENTER);
  text("Over", displayWidth/2 + 72, displayHeight/8 + 154);

  //ENTER TO RESTART
  textFont(instructFont, 40);
  fill(255);
  textMode(CENTER);
  text("Press ENTER to try again...", width/2, height * 0.6f);

  if(restartFlag)
  {
    setup();
  }
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
      println("[INFO] New track now playing");
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

//---------UI----------//

public void DrawMainUI()
{
  pushStyle();
//Shield/health bars
  imageMode(CORNER);
  redButton.resize((int)redButtonSize.x, (int)redButtonSize.y);     //HACK not sure why this needs to be here
  blueButton.resize((int)blueButtonSize.x, (int)blueButtonSize.y);
  image(blueButton,blueButtonLocation.x,blueButtonLocation.y);    //Shield health background
  image(redButton,redButtonLocation.x,redButtonLocation.y);

  int maxHealth = playerShip.health.max;
  int maxShields = playerShip.shield.health.max;
  int healthBars = (int)Math.floor(((float)playerShip.health.current)/maxHealth*10);
  int shieldBars = (int)Math.floor(((float)playerShip.shield.health.current)/maxShields*10);


  redBar.resize((int)barSize.x, (int)barSize.y);
  for(int i = 0; i < healthBars; i++)
  {
    image(redBar, i * barSpacing + barOffset.x + redButtonLocation.x, barOffset.y + redButtonLocation.y);
  }

  blueBar.resize((int)barSize.x, (int)barSize.y);
  for(int i = 0; i < shieldBars; i++)
  {
    image(blueBar, i * barSpacing + barOffset.x + blueButtonLocation.x, barOffset.y + blueButtonLocation.y);
  }

  textAlign(CENTER,CENTER);
  fill(0);
  textFont(standardFont, 30);    //Standard standardFont and size for drawing fonts
  text("HEALTH", 10 * barSpacing + redButtonLocation.x + 100, redButtonLocation.y + redButtonSize.y/2);
  text("SHIELDS", 10 * barSpacing + blueButtonLocation.x + 100, blueButtonLocation.y + blueButtonSize.y/2);
  
//Engine power bars
  fill(16,208,35,250);
  leftThrottleSize.y = playerShip.leftEnginePower/playerShip.maxThrust * fullThrottleSize;
  leftThrottleLocation.y = height - leftThrottleSize.y;
  rect(leftThrottleLocation.x, leftThrottleLocation.y, leftThrottleSize.x, leftThrottleSize.y, 12, 12, 0, 0);
  
  fill(0,0,255,250);
  rightThrottleSize.y = playerShip.rightEnginePower/playerShip.maxThrust * fullThrottleSize;
  rightThrottleLocation.y = height - rightThrottleSize.y;
  rect(rightThrottleLocation.x, rightThrottleLocation.y, rightThrottleSize.x, rightThrottleSize.y, 12, 12, 0, 0);
  
  textFont(instructFont, 32);
  fill(255);
  text("L", leftThrottleLocation.x + leftThrottleSize.x/2, leftThrottleLocation.y + 32);
  text("R", rightThrottleLocation.x + rightThrottleSize.x/2, rightThrottleLocation.y + 32);

  popStyle();
}

public void DrawArrow(float arrowX, float arrowY, float angle,int arrowLen)
{
  pushMatrix();
  translate(arrowX, arrowY);
  rotate(angle);
  fill(255);
  stroke(255);
  line(0,0, arrowLen,0);
  line(arrowLen,0, arrowLen-5, 5);
  line(arrowLen,0, arrowLen-5, -5);
  //ellipse(0,0,5,5);
  popMatrix();
  noStroke();
}

public void DrawControls()
{
  textAlign(LEFT);
  textFont(instructFont, 32);
  text("Controls: \nFire Laser -> Left mouse click \nIncrease Left Engine -> Y \nDecrease Left Engine -> H \nIncrease Right Engine -> I \nDecrease Right Engine -> K \nPause - P",0,32);
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

  public void SetMaxHealth(int _newMax)
  {
  	max = _newMax;
  	current = max;
  }
  
  public void Add(int _addition)
  {
    current += _addition;
    if(current > max)
    {
      current = max;
    }
  } 
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
  // [ 1 2 3 ]
  // [ 4 5 6 ]      Sector layout for adjacency check
  // [ 7 8 9 ]
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
    if(i != 1 && i != 4 && i != 7)    //Not far left side
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
      sectors.put((Integer)pair.getKey(), (Sector)pair.getValue());   //HACK unchecked cast
      
      if(debugMode.value)
      {
        println("[DEBUG] Added new entry pair to sector map");
      }
      it.remove();      //Avoids a ConcurrentModificationException
    }
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
      toAdd.baseAngle = radians(rand.nextInt((360) + 1));
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
      Shape colliderGenerated = new Shape("collider", new PVector(xCoor, yCoor), new PVector(size, size), 
            color(0,255,0), ShapeType._CIRCLE_);
      Planet toBuild = new Planet("Planet", new PVector(xCoor, yCoor), size, PApplet.parseInt(10000*size/planetSizeRange.y), 
            sector, colliderGenerated);
      toBuild.SetMaxSpeed(0);        //Local speed limit for planet (don't move)
      toBuild.baseAngle = radians(rand.nextInt((360) + 1));
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


float shipScaleFactor = 0.25f;     //Scale down ship sprite sizes by this factor
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

  int enemyShipRandomIndex = rand.nextInt((enemyShipTypeCount -1) + 1);
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

    Shape colliderGenerated = new Shape("collider", position, enemyShipSize, color(0,255,0), ShapeType._RECTANGLE_);
    Enemy enemyGen = new Enemy("Bad guy", position, enemyShipSize, enemySprite, 
      1000, color(255,0,0), sector, colliderGenerated);
    enemyGen.baseAngle = radians(rand.nextInt((360) + 1));     //Random rotation 0-360

    //TODO: fix rendering of enemy shields when in another sector
    // Small chance for enemy with shields....
    // int shieldOdds = 95;     //percentage of enemies with shield
    // int rolledNumber = rand.nextInt((100) + 1);
    // if(rolledNumber <= shieldOdds)
    // {
    //   enemyGen.shield.enabled = true;
    //   enemyGen.shield.online = true;
    // }

    sector.ships.add(enemyGen);
  }

}

public void GeneratePowerups(Sector sector, int count)
{
  PVector position = sector.location.get();   //Default position at origin of sector

  int minX, minY, maxX, maxY;                 //Max allowed positions

  PImage sprite;      //What the powerup looks like
  PVector powerupSize = new PVector(width/64, width/64);

  for(int i = 0; i < count; i++)
  {
    int typeGenerator = rand.nextInt((2) + 1);    //0-2 to select type of powerup
    PowerupType type;
    if(typeGenerator == 0)
    {
      type = PowerupType.BULLETHELL;
      sprite = redPowerupSprite.get();
    }
    else if(typeGenerator == 1)
    {
      type = PowerupType.SHIELDS;
      sprite = shieldPowerupSprite.get();
    }
    else
    {
      type = PowerupType.ENGINES;
      sprite = enginePowerupSprite.get();
    }

    if(sector.asteroids.size() > 0)   //This sector has asteroids -- check for overlap
    {
      boolean validLocation = false;
      while(!validLocation)
      {
        //Generation parameters
        minX = PApplet.parseInt(sector.GetLocation().x + powerupSize.x);
        minY = PApplet.parseInt(sector.GetLocation().y + powerupSize.y);
        maxX = PApplet.parseInt(sector.GetSize().x - powerupSize.x);
        maxY = PApplet.parseInt(sector.GetSize().y - powerupSize.y);

        //Generate position offsets from the sector location
        position.x = rand.nextInt(maxX - PApplet.parseInt(powerupSize.x)) + minX + PApplet.parseInt(powerupSize.x/2);
        position.y = rand.nextInt(maxY)+minY;

        for(Asteroid roid : sector.asteroids)
        {
          //Check if this asteroid's center + diameter overlaps with ships center = size
          if( Math.abs(roid.GetLocation().x-position.x) < roid.GetSize().x/2 + powerupSize.x 
                && Math.abs(roid.GetLocation().y-position.y) < roid.GetSize().y/2 + powerupSize.y )
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
      position.x = rand.nextInt(maxX - PApplet.parseInt(powerupSize.x)) + minX + PApplet.parseInt(powerupSize.x/2);
      position.y = rand.nextInt(maxY)+minY;
    }

    Shape colliderGenerated = new Shape("collider", position, powerupSize, color(0,255,0), ShapeType._RECTANGLE_);
    Powerup powerupGen = new Powerup(position, powerupSize, sprite, type, sector, colliderGenerated);

    sector.powerups.add(powerupGen);
  }

}

/**
 * Checks if an object implements an interface, returns boo
 * @param  object Any object
 * @param  interf Interface to compare against
 * @return {Boolean} True for implements, false if doesn't
 */
public static boolean implementsInterface(Object object, Class interf)
{
    return interf.isInstance(object);
}

/*
 * Mouse & keyboard input here.
 */

public void mouseWheel(MouseEvent e)
{
  float wmX = wvd.pixel2worldX(mouseX);
  float wmY = wvd.pixel2worldY(mouseY);
  
  wvd.viewRatio -= e.getAmount() / 20;
  wvd.viewRatio = constrain(wvd.viewRatio, 0.05f, 200.0f);
  
  wvd.orgX = wmX - mouseX / wvd.viewRatio;
  wvd.orgY = wmY - mouseY / wvd.viewRatio;
}

// Panning
public void mouseDragged() {
  if(gameState == GameState.PAUSED)
  {
    wvd.orgX -= (mouseX - pmouseX) / wvd.viewRatio;
    wvd.orgY -= (mouseY - pmouseY) / wvd.viewRatio;
  }
}


//Check for keypresses
public void keyPressed() 
{
  if(key == 'r')    //Reset zoom DEBUG ONLY
  {
    wvd.Reset();
  }

  if(key == 'p' || key == 'P')
  {
    if(gameState == GameState.PLAY)
    {
      gameState = GameState.PAUSED;
    }
    else if(gameState == GameState.PAUSED)
    {
      gameState = GameState.PLAY;
    }
  }

  
  //ENGINE DEBUG CONTROLS
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
  if(key =='y' || key == 'Y')
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
  if(key == 'k' || key == 'K')
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
  if(key =='i' || key == 'I')
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

  //WEAPON DEBUG CONTROLS
  if(key == 'q' || key == 'Q')    //Cycle targets
  {
    playerShip.SelectNextTarget();
  }
  if(key == 'e' || key == 'E')    //Cycle targets
  {
    playerShip.FireAtTarget();
  }
  
  //Start menu options
  if(key == 's' || key == 'S')
  {
    sPressed=true;
  }
  if(key == 'm' || key == 'M')
  {
    mPressed=true;
  }
  if(key == 'n' || key == 'N')
  {
    instructionNumber++;
  }

  //Game over restart
  if(gameState == GameState.GAMEOVER)
  {
    if(keyCode == ENTER)
    {
      restartFlag = true;
    }
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

/**
 * A friendly object (e.g. station) that provides
 * aid to physical objects
 */
public interface Friendly
{
  public void ProvideAid(Physical _friend);
}
enum LaserColor {
  RED, GREEN
}

public class LaserBeam extends Physical
{
  //Draw properties (limit range)
  static final float laserSpeedLimit = 20.0f;    //Speed limit, static for all laserbeams
  static final int timeToFly = 2000;        //Effective range, related to speed (ms)
  private long spawnTime;
  
  LaserColor laserColor;

  LaserBeam(PVector _loc, PVector _direction, PVector _size, Sector _sector, 
                Shape _collider, LaserColor _color)
  {
    super("Laser beam", _loc, _size, .0001f, _sector, _collider);    //HACK Mass very low!! For handling physics easier 
    
    //Set laser color
    laserColor = _color;
    if(_color == LaserColor.GREEN)
    {
      sprite = greenLaser.get();
    }
    else
    {
      sprite = redLaser.get();
    }
    
    sprite.resize((int)size.x, (int)size.y);
    
    //Set laser speed and lifetime
    localSpeedLimit = laserSpeedLimit;
    spawnTime = millis();
    
    //Damage settings
    damageOnHit = 20;
    
    //Velocity setter
    PVector scaledVelocity = _direction.get();
    scaledVelocity.setMag(laserSpeedLimit);
    
    velocity = scaledVelocity;
    
    //Play laser fire sound
    // laserSound.play();       //TODO too many of these play calls in one loop crashes the sound library....

    if(_color == LaserColor.GREEN)      //HACK determine team  by color
    {
      currentSector.friendlyLaserFire.add(this);
    }
    else
    {
      currentSector.enemyLaserFire.add(this);
    }
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
      print("[DEBUG] Laser beam burn hurt ");
      print(_other.name);
      print(" for ");
      print(damageOnHit);
      print(" damage.\n");
    }
    
    laserHitSound.play();
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

  Missile(PVector _loc, PVector _moveVector, int _outlineColor, Sector _sector, Shape _collider) 
  {
    //Parent constructor
    super("Missile", _loc, new PVector(20,10), 10, _sector, _collider);    //mass = 10
    
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
    info = new TextWindow("Missile Info", location, descriptor);
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
  public Shape collider;                //Shape to check for collision
  protected long lastCollisionTime = -9999;
  protected int damageOnHit = 0;           //Automatic damage incurred on hit
  boolean collidable;               //Can this object be collided with by ANYTHING? see shields when down
  
  //Location
  protected Sector currentSector;                //What physical sector this object is in

  public Physical(String _name, PVector _loc, PVector _size, float _mass, Sector _sector, Shape _collider)
  {
    super(_name, _loc, _size);
    
    health = new Health(100, 100);       //Default health
    mass = _mass;
    
    //Convenience pointer to sector
    currentSector = _sector;

    //Collider setup
    collidable = true;
    collider = _collider;

    //Movement
    velocity = new PVector(0, 0);
    acceleration = new PVector(0,0);
    localSpeedLimit = 10;         //Default speed limit
    maxForceMagnitude = 1;       //TODO implement me
    
    //UI
    iconOverlay = new Shape("Physical Overlay", location, 
                size, color(0,255,0), ShapeType._SQUARE_);
  }
  
  @Override public void DrawObject()
  {
    super.DrawObject();

    //Debug collider
    if(debugMode.value)
    {
      collider.DrawObject();
      pushStyle();
      stroke(255);
      for(Line l : collider.lines)
      {
        line(l.start.x, l.start.y, l.end.x, l.end.y);
      }
      popStyle();
    }
    

    pushMatrix();
    translate(location.x, location.y);

    //Display forward vector (white), velocity vector (red)
    if (debugMode.value)
    {
      pushStyle();
      //Debug forward direction (white)
      stroke(255, 255, 255);
      line(0, 0, 50 * forward.x, 50 * forward.y);  

      //Debug velocity direction (red)
      stroke(255, 0, 0);
      line(0, 0, 100 * velocity.x, 100 * velocity.y);  
      popStyle();
    }

    //Handle drawing rotation
    baseAngle = velocity.heading2D();
    rotate(baseAngle);

    popMatrix();
  }
  
//******* UPDATE *********/
  public void Update()
  {
    velocity.add(acceleration);           //Update velocity by acceleration vector
    velocity.limit(localSpeedLimit);      //Make sure we haven't accelerated over speed limit

    acceleration.setMag(0);

    //Match collider to position and location
    collider.location = location;       //Move collider to this position
    collider.baseAngle = baseAngle;     //Rotate collider by this rotation
    collider.Update();         //Update colliders to allow lines to rotate, move, etc

    //Update forward vector based on rotation
    forward.x = cos(baseAngle);
    forward.y = sin(baseAngle);
    forward.normalize();

    if(health.current <= 0)
    {
      toBeKilled = true;
      if(debugMode.value)
      {
        print("[INFO] ");
        print(name);
        print(" has died\n");
      }

    }
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

  /**
   * Add to the acceleration the ship will feel
   * @param {PVector} _accel acceleration vector
   */
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
float frictionFactor = 1.1f;        //Slow down factor after collision
  
  /**
   * Cause collision effects on the OTHER object
   * @param  {Physical} _other Other object to affect by this collision
   */
  @Override public void HandleCollision(Physical _other)
  {
    lastCollisionTime = millis();
    
    //Damage this object based on delta velocity
    PVector deltaV = new PVector(0,0);
    PVector.sub(_other.velocity, velocity, deltaV);
    float velocityMagDiff = deltaV.mag();
    
    //Mass scaling factor (other/mine) for damage
    float massRatio = _other.mass/mass;
    float damage = 1 * massRatio * velocityMagDiff;
    _other.health.current -= damage;        //Lower other's health
    
    if(debugMode.value)
    {
      print("[DEBUG] ");
      print(name);
      print(" collision caused ");
      print(damage);
      print(" damage to ");
      print(_other.name);
      print("\n");
    }

    //Create a velocity change based on this object and other object's position
    PVector deltaP = new PVector(0,0);    //Delta of position, dP(12) = P2 - P1
    deltaP.x = _other.location.x - location.x;
    deltaP.y = _other.location.y - location.y;
    
    deltaP.normalize();      //Create unit vector for new direction from deltaP
    
    //Use this delta position to flip direction -- slow down by friction factor
    deltaP.setMag(velocity.mag()/frictionFactor);

    _other.ApplyForce(deltaP);
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

  public Planet(String _name, PVector _loc, int _diameter, int _mass, Sector _sector, Shape _collider) 
  {
    //Parent constructor
    super(_name, _loc, new PVector(_diameter, _diameter), _mass, _sector, _collider);
    
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
    info = new TextWindow("Planet info", location, descriptor);
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
      Shape colliderGen = new Shape("collider", stationLoc, stationSize, color(0,255,0), 
          ShapeType._CIRCLE_);
      if(stationLevel == 1)
      {
        if(stationColor == 1)
        {
          station = new Station(StationType.MILITARY, stationLoc, stationSize, 
            blueStation1, currentSector, colliderGen);
          station.friendly = true;
        }
        else
        {
          station = new Station(StationType.MILITARY, stationLoc, stationSize, 
            redStation1, currentSector, colliderGen);
        }
      }
      else if(stationLevel == 2)
      {
        if(stationColor == 1)
        {
          station = new Station(StationType.MILITARY, stationLoc, stationSize, 
            blueStation2, currentSector, colliderGen);
          station.friendly = true;
        }
        else
        {
          station = new Station(StationType.MILITARY, stationLoc, stationSize, 
            redStation2, currentSector, colliderGen);
        }
      }
      else
      {
        if(stationColor == 1)
        {
          station = new Station(StationType.MILITARY, stationLoc, stationSize, 
            blueStation2, currentSector, colliderGen);
          station.friendly = true;
        }
        else
        {
          station = new Station(StationType.MILITARY, stationLoc, stationSize, 
            redStation2, currentSector, colliderGen);
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
  //Ship components
  private Reactor reactor;
  private int maxPowerToNode;			//Maximum power any one node may have

  //Engines
  float leftEnginePower, rightEnginePower;  
  
  //Weapons targeting
  private Shape targetCircle;
  private Physical currentTarget;         //What ship is currently looking at
  private int currentTargetIndex;         //Index into targets arraylist 

  //Power ups
  boolean bulletHellEnabled = false;        //Fire FAST!
  private int bulletHellDuration = 7000;     //How long to make bullet hell enabled
  private long bulletHellStartTime = 0;

  boolean enginesBoosted = false;         //Fly fast
  float engineSpeedModifier = 2;          //Multiplier of how fast engine can go
  private float standardSpeed;            //Store standard power to restore at the end

  private int engineBoostDuration = 7000;  
  private long engineBoostStartTime = 0;

  //Scanners
  int sensorRange = 2000;          //Units of pixels
  Shape scanRadius;               //Circle outline, when hovered over, shows sensor/weapons range

  //Behavoir Ranges for Enemy
  public Shape seekCircle, seekAgainCircle, avoidCircle;    //For collision detections
  public int seekDiameter, seekAgainDiameter, avoidDiameter;

  public Player(PVector _loc, PVector _size, PImage _sprite, int _mass, int _outlineColor, Sector _sector, Shape _collider) 
  {
    //Parent constructor
    super("Player", _loc, _size, _sprite, _mass, _outlineColor, _sector, _collider);

    //Reactor setup
    reactor = new Reactor(100);
    maxPowerToNode = reactor.totalCapacity/3;
    
    //Shield setup 
    shield.online = true;
    shield.enabled = true;

    //Engine setup
    leftEnginePower = 0;
    rightEnginePower = 0;

    //Behavior Ranges for Enemies
    seekDiameter = 3000;        //All ships inside this circle will seek to destory
    seekAgainDiameter = 800;
    avoidDiameter = 400;
    
    seekCircle = new Shape("seekCircle", location, new PVector(seekDiameter,seekDiameter), color(0,255,255), ShapeType._CIRCLE_);                    //Light Blue
    seekAgainCircle = new Shape("seekAgainCircle", location, new PVector(seekAgainDiameter,seekAgainDiameter), color(255,18,200), ShapeType._CIRCLE_); //Pink
    avoidCircle = new Shape("avoidCircle",location , new PVector(avoidDiameter,avoidDiameter), color(18,255,47), ShapeType._CIRCLE_);                  //Green
  
    //Targetting circle initially transparent target circle
    targetCircle = new Shape("targetCircle", location, new PVector(200,200), color(255,0,0,125), ShapeType._CIRCLE_); 
  
    //Prepare sensors collider
    scanRadius = new Shape("Scan radius", location, new PVector(sensorRange,sensorRange), 
                color(255,0,0), ShapeType._CIRCLE_);

    localSpeedLimit = 5;
    standardSpeed = localSpeedLimit;    //To restore after engine boost 
  }	

  @Override public void Update()
  {
    super.Update();

    //Update player radius circles for seek/flee    
    seekCircle.location = location;
    seekAgainCircle.location = location;
    avoidCircle.location = location;

    //Movement input
    HandleMovement();

    //Targeting
    SearchForTargets();
    if(currentTarget != null)
    {
      targetCircle.location = currentTarget.location;
    }

    //Bullet hell updates
    if(millis() > bulletHellStartTime + bulletHellDuration)
    {
      bulletHellEnabled = false;    //Disable after duration
    }

    if(bulletHellEnabled)
    {
      currentFireInterval = minFireInterval;
    }
    else
    {
      currentFireInterval = 150;
    }

    //Engine boost update
    if(millis() > engineBoostStartTime + engineBoostDuration)
    {
      enginesBoosted = false;    //Disable after duration
    }

    if(enginesBoosted)
    {
      localSpeedLimit = standardSpeed * engineSpeedModifier;
    }
    else
    {
      localSpeedLimit = standardSpeed;
    }

    if(toBeKilled)
    {
      Ship charredHull = new Ship("Charred", location, size, charredPlayerShip, (int)mass, 
              color(255), currentSector, collider);
      charredHull.smoke1Visible = true;
      charredHull.smoke2Visible = true;
      charredHull.health.SetMaxHealth(1000000);      //Don't die....
      charredHull.localSpeedLimit = 1;
      charredHull.velocity = velocity;

      currentSector.shipsToAdd.add(charredHull);     //To add at end of update loop
    }
  }
  

  @Override public void DrawObject()
  {
    super.DrawObject();

    if(debugMode.value)
    {
      seekCircle.DrawObject();      //Circlers for where enemies seek/flee
      seekAgainCircle.DrawObject();
      avoidCircle.DrawObject();
    }

    if(currentTarget != null)
    {
      if(currentTarget.toBeKilled)
      {
        currentTarget = null;
      }
      else
      {
        targetCircle.DrawObject();
      }     
    }
  }	

  /**
   * [HandleMovement description]
   * TODO document
   */
  private void HandleMovement()
  {
    //Apply drag
    if(velocity.mag() > 0.01f)
    {
      PVector drag = velocity.get();
      drag.setMag(-velocity.mag()/100);
      ApplyForce(drag);
    }


    //Calculate spin & thrust forces
    PVector spinForce = Spin();
    ApplyForce(spinForce);

    PVector thrustForce = Thrust();
    ApplyForce(thrustForce); 
  }     

  /**
   * Creates two 'spin' vectors for each of the two engines.
   * The vectors are both perpendicular to the Velocity vector and face opposite directions from one another
   * They are scaled based on the engines power and then summed to each other and passed as a steering force to be summed to the acceleration vector 
   * @return {PVector} Vector to be applied to the player's ship
   */
  public PVector Spin()
  {
    PVector spinLeftEngine = new PVector(1,0);
    PVector spinRightEngine = new PVector(1,0);
    int engineThreshHold = 10;
    float spinFactor = 0.25f;
    
    spinLeftEngine.rotate(velocity.heading() + HALF_PI);    //left engine vector set perdendicular to Velocity facing left.
    spinRightEngine.rotate(velocity.heading() - HALF_PI);   //right engine vector set perpendiuclar to Velocity facing right.
    spinLeftEngine.setMag(leftEnginePower);                 //Set magnitudes to Engines power ranging 0-10
    spinRightEngine.setMag(rightEnginePower); 
    PVector spinSum = PVector.add(spinRightEngine, spinLeftEngine);  //Sum the apposing facing spin vectors
    PVector desired = new PVector(0,0);
    if(leftEnginePower <= engineThreshHold && rightEnginePower <= engineThreshHold && velocity.mag() <= 1)
    {
      spinSum.setMag(map(spinSum.mag(), 0, engineThreshHold, 0, spinFactor));
      desired = PVector.add(spinSum,forward);
      if(desired.mag() == 1)
      {
        desired.setMag(0);
      }
      desired.setMag(map(desired.mag(), 0,sqrt(spinFactor*spinFactor+1), 0,0.5f));
      return desired;
    }
    spinSum.x = map(spinSum.x, 0, 10, 0, 0.5f);          //Limit to better turning speed 'feel'
    spinSum.y = map(spinSum.y, 0, 10, 0, 0.5f);
  
    return spinSum;
    
  }

  /**
   * Calculate forward vector of ship thrusters
   * @return {PVector} thrust vector forward on the ship to apply
   */
  public PVector Thrust()
  {
    PVector thrust = new PVector(1,0);
    thrust.rotate(forward.heading());
    float thrustPower = (leftEnginePower/maxThrust) + (rightEnginePower/maxThrust);
    thrustPower = map(thrustPower, 0, 2, 0, 0.1f);     //Tune here to modify acceleration 'feel'

    thrust.setMag(thrustPower);

    return thrust;
  }


  /**
   * Get next target in targetlist and place in
   * currentTarget
   * @see  Interactions.pde for calling by controls
   */
  public void SelectNextTarget()
  {
    //TODO select targets besides closest
    float currentTargetDistance = 99999999;
    if(currentTarget != null)
    {
     currentTargetDistance = PVector.dist(location, currentTarget.location);
    }

    for(Physical p : targets)
    {
      float targetDistance = PVector.dist(location, p.location);
      if(targetDistance <= currentTargetDistance)
      {
        currentTargetDistance = targetDistance;
        println("[INFO] New target " + p);
        currentTarget = p;
      }
    }
          
  }

  /**
   * Search through this and surrounding sectors for targets,
   * and add them to the targets arraylist.
   */
  private void SearchForTargets()
  {
    targets.clear();
    ArrayList<Sector> neighbors = currentSector.GetSelfAndAllNeighbors();
    for(Sector sector : neighbors)
    {
      for(Ship s : sector.ships)
      {
        if(s != this)
        {
          if(PVector.dist(location, s.location) <= sensorRange)
          {
            if(!targets.contains(s))
            {
              targets.add(s);
            }
            
          }
        }
      }

    }
  }
  
  public void FireAtTarget()
  {
    if(currentTarget != null)
    {
      BuildLaserToTarget(currentTarget, LaserColor.GREEN);
    }
  }

  public void EnableBulletHell()
  {
    bulletHellStartTime = millis();
    bulletHellEnabled = true;
  }

  public void EnableEngineBoost()
  {
    engineBoostStartTime = millis();
    enginesBoosted = true;
  }


}


//---------------------------


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
public enum PowerupType
{
  BULLETHELL, SHIELDS, ENGINES
};

public class Powerup extends Physical implements Friendly
{
  PowerupType type;

	public Powerup(PVector _loc, PVector _size, PImage _sprite, PowerupType _type, Sector _sector, Shape _collider)
	{
		super("Powerup", _loc, _size, 500, _sector, _collider);

		sprite = _sprite;
		sprite.resize((int)size.x, (int)size.y);

    type = _type;
	}

  /**
	 * Toggles powerup modes on the player
	 * @param _friend Friendly object
 	 */
  public void ProvideAid(Physical _friend)
  {
  	if(_friend instanceof Player)		//HACK force check
  	{
      Player play = (Player)_friend;
      if(type == PowerupType.BULLETHELL)
      {
        play.EnableBulletHell();
      }
      else if(type == PowerupType.SHIELDS)
      {
        play.shield.RestoreShield();

      }
      else if(type == PowerupType.ENGINES)
      {
        play.EnableEngineBoost();
      }
      else
      {
        println("[ERROR] Invalid powerup type!");
      }
  		
  	}

    toBeKilled = true;
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
  public ArrayList<Asteroid> debrisSpawned;       //Storage for debris spawned to be added in update
  public ArrayList<Planet> planets;
  public ArrayList<Ship> ships, shipsToAdd; //May include enemies and the player ship, to add for player charred hull
  public ArrayList<LaserBeam> enemyLaserFire, friendlyLaserFire; 
  public ArrayList<Explosion> explosions; 
  public ArrayList<Powerup> powerups;

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
    debrisSpawned = new ArrayList<Asteroid>();
    planets = new ArrayList<Planet>();
    ships = new ArrayList<Ship>();
    shipsToAdd = new ArrayList<Ship>();
    enemyLaserFire = new ArrayList<LaserBeam>();
    friendlyLaserFire = new ArrayList<LaserBeam>();
    explosions = new ArrayList<Explosion>();
    powerups = new ArrayList<Powerup>();

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
    int powerupLottery = 100;//rand.nextInt((100) + 1);   //Random gen parameter 0 - 100
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

      if(powerupLottery > 90)
      {
        GeneratePowerups(this, 1);
      }
    }
    else if(sectorType == SectorType.ASTEROIDFIELD)
    {
      //Generate asteroids in this sector
      int asteroidCount = rand.nextInt((maxAsteroids - minAsteroids) + 1) + minAsteroids;
      GenerateAsteroids(this, asteroidCount);     //See helpers.pde

      if(powerupLottery > 95)
      {
        GeneratePowerups(this, 2);
      }
      else if(powerupLottery > 70)
      {
        GeneratePowerups(this, 1);
      }
    }
    else
    {
      if(powerupLottery > 95)
      {
        GeneratePowerups(this, 1);
      }
    }
  }

  /**
   * Generate dynamic entities (enemies) in this sector
   * @see  Helpers.pde for generation function
   */
  private void GenerateSectorEnemies()
  {
    int maxEnemies = 6;
    int minEnemies = 0;
    int enemyCount = rand.nextInt((maxEnemies - minEnemies) + 1) + minEnemies;
    // GenerateEnemies(this, 0);
    GenerateEnemies(this, enemyCount); // GenerateEnemies(this, enemyCount);
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
    if(!debrisSpawned.isEmpty())      //Put debris into asteroid tracking list
    {
      for(Asteroid a : debrisSpawned)
      {
        asteroids.add(a);
      }
      debrisSpawned.clear();
    }

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
   * Return arraylist of this sector and all neighboring sectors
   * @return arraylist of sectors
   */
  public ArrayList<Sector> GetSelfAndAllNeighbors()
  {
    ArrayList<Sector> allNeighbors = new ArrayList<Sector>();
    for(Sector neighbor : neighbors.values())
    {
      allNeighbors.add(neighbor);
    }
    allNeighbors.add(this);

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
    else if(obj instanceof LaserBeam)
    {
      LaserBeam beam = (LaserBeam)obj;
      if(beam.laserColor == LaserColor.GREEN)     //HACK team by color
      {
        friendlyLaserFire.add((LaserBeam)obj);
      }
      else
      {
        enemyLaserFire.add((LaserBeam)obj);
      }
      
    }
    else
    {
      println("[WARNING] Unknown object " + obj.name + " [" + obj.GetID() 
              + "] has entered sector");
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
 * UI shape (Square, circle, rectangle, triangle allowed)
*/
public class Shape extends Drawable implements Updatable
{
  public ShapeType shapeType;
  public int borderColor;
  
  private int defaultColor;
  private boolean colorSet;          //Allow only one initial set of color after the constructor's default
  private int fillColor;
  
  //Shape offsets/rotations
  float rotationOffset;
  PVector positionOffset;

  //Lines for collision checking
  ArrayList<Line> lines;
  Line top, left, bottom, right;    //For rectangles
  Line edge1, edge2, edge3;         //For triangles

  public Shape(String _name, PVector _loc, PVector _size, int _color, ShapeType _shapeType)
  {
    super(_name, _loc, _size);

    //Color & shape setup
    borderColor = _color;
    defaultColor = borderColor;
    shapeType = _shapeType;
    colorSet = false;
    fillColor = color(255,255,255,0);

    //Offsets
    rotationOffset = 0;
    positionOffset = new PVector(0,0);

    //Lines for collision
    lines = new ArrayList<Line>();

    //Build lines based on shape type
    if(shapeType == ShapeType._RECTANGLE_ || shapeType == ShapeType._SQUARE_)
    {
      top = new Line(location.x - size.x/2, location.y - size.y/2, //Offset for default center-render
                            location.x + size.x/2, location.y - size.y/2);    
      left = new Line(location.x - size.x/2, location.y - size.y/2, 
                            location.x - size.x/2, location.y + size.y/2);    
      bottom = new Line(location.x - size.x/2, location.y + size.y/2, 
                            location.x + size.x/2, location.y + size.y/2);
      right = new Line(location.x + size.x/2, location.y - size.y/2, 
                            location.x + size.x/2, location.y + size.y/2);
      lines.add(top);   //add all to lines list for reading during collision
      lines.add(left);
      lines.add(bottom);
      lines.add(right);
    }
    else if(shapeType == ShapeType._TRIANGLE_)
    {
      float a = size.x;
      float r = a * sqrt(3)/6;      //See http://www.treenshop.com/Treenshop/ArticlesPages/FiguresOfInterest_Article/The%20Equilateral%20Triangle.htm
      float R = r * 2;
      PVector vertex1 = new PVector(location.x,location.y);
      PVector vertex2 = new PVector(location.x + r+R, location.y + 7*a/8);
      PVector vertex3 = new PVector(location.x + r+R, location.y - 7*a/8);

      edge1 = new Line(vertex1.x, vertex1.y, vertex2.x, vertex2.y);
      edge2 = new Line(vertex2.x, vertex2.y, vertex3.x, vertex3.y);
      edge3 = new Line(vertex3.x, vertex3.y, vertex1.x, vertex1.y);

      lines.add(edge1);
      lines.add(edge2);
      lines.add(edge3);
    }
  }
  
  /**
   * Special case of draw that does not user super.DrawObject()
   * Only draw shapes
   */
  @Override public void DrawObject()
  {
    pushMatrix();
    pushStyle();

    translate(location.x, location.y);
    rotate(baseAngle);

    stroke(borderColor);
    fill(fillColor);
    
    if(shapeType == ShapeType._SQUARE_)
    {
      rectMode(renderMode);
      rect(0, 0, size.x, size.x);    //TODO forced square here
      if(size.x != size.y)
      {
        println("[WARNING] Square shape being force-rendered with rectangle edges!");
      }
      
    }
    if(shapeType == ShapeType._RECTANGLE_)
    {
      rectMode(renderMode);
      rect(0, 0, size.x, size.y); 
    }
    else if(shapeType == ShapeType._TRIANGLE_)
    {
      // rotate(triangleRotate);
      float a = size.x;
      float r = a * sqrt(3)/6;      //See http://www.treenshop.com/Treenshop/ArticlesPages/FiguresOfInterest_Article/The%20Equilateral%20Triangle.htm
      float R = r * 2;
    
      beginShape(TRIANGLES);
      vertex(0,0);
      vertex(r+R, 7*a/8);
      vertex(r+R, -7*a/8);
      endShape();

      if(size.x != size.y)
      {
        println("[WARNING] Equilateral triangle with unequal x/y parameters being drawn! This will break collision detection");
      }
    }
    else if(shapeType == ShapeType._CIRCLE_)
    {
      ellipseMode(RADIUS);
      ellipse(0, 0, size.x/2, size.y/2);
    }
    else
    {
       println("[ERROR] Invalid shape to draw!");
    }
    popStyle();
    popMatrix();
  }
  

  public void Update()
  {
    //Update line locations to move to new location, then rotate
    if(shapeType == ShapeType._RECTANGLE_ || shapeType == ShapeType._SQUARE_)
    {
      //New line locations, un-rotated
      top.start.x = location.x - size.x/2 + positionOffset.x;
      top.start.y = location.y - size.y/2 + positionOffset.y;
      top.end.x = location.x + size.x/2 + positionOffset.x;
      top.end.y = location.y - size.y/2 + positionOffset.y;

      left.start.x = location.x - size.x/2 + positionOffset.x;
      left.start.y = location.y - size.y/2 + positionOffset.y;
      left.end.x = location.x - size.x/2 + positionOffset.x;
      left.end.y = location.y + size.y/2 + positionOffset.y;

      bottom.start.x = location.x - size.x/2 + positionOffset.x;
      bottom.start.y = location.y + size.y/2 + positionOffset.y;
      bottom.end.x = location.x + size.x/2 + positionOffset.x;
      bottom.end.y = location.y + size.y/2 + positionOffset.y;

      right.start.x = location.x + size.x/2 + positionOffset.x;
      right.start.y = location.y - size.y/2 + positionOffset.y;
      right.end.x = location.x + size.x/2 + positionOffset.x;
      right.end.y = location.y + size.y/2 + positionOffset.y;

      //Rotate all lines for collision by angle
      top.UpdateByRotation(baseAngle + rotationOffset, location.get());
      left.UpdateByRotation(baseAngle + rotationOffset, location.get());
      right.UpdateByRotation(baseAngle + rotationOffset, location.get());
      bottom.UpdateByRotation(baseAngle + rotationOffset, location.get());
    }


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

/**
 * Line helper for collision
 */
public class Line
{
  PVector start;      //start of the line
  PVector end;        //end of the line
  float length;       //how long the line is

  public Line(float x1, float y1, float x2, float y2)
  {
    start = new PVector(x1, y1);
    end = new PVector(x2, y2);

    start.x = x1;
    start.y = y1;
    end.x = x2;
    end.y = y2;

    length = PVector.dist(new PVector(x1,y1), new PVector(x2,y2));
  }

  /**
   * Rotate about the origin with given angle theta
   * @param theta angle in radians
   * @param location 2D coordinates (literally location from drawable)
   */
  public void UpdateByRotation(float theta, PVector location)
  {
    PVector startOffset = new PVector(start.x-location.x, start.y-location.y);
    PVector endOffset = new PVector(end.x-location.x, end.y-location.y);

    start.x = location.x + (float)((startOffset.x)*cos(theta) - (startOffset.y)*sin(theta));
    start.y = location.y + (float)((startOffset.x)*sin(theta) + (startOffset.y)*cos(theta));

    end.x = location.x + (float)((endOffset.x)*cos(theta) - (endOffset.y)*sin(theta));
    end.y = location.y + (float)((endOffset.x)*sin(theta) + (endOffset.y)*cos(theta));
  }

}

public class Shield extends Physical implements Updatable
{
  Physical parent;  //What is generating the shield

  long lastUpdateTime;          //When were shield updates last checked
  int shieldRegenAmount = 20;    //Per tick
  int failureTime = 5000;       //How long shields are offline in event they fail, ms
  int regenPeriod = 500;        //How long between each regen tick
  
  boolean enabled;              //Are shields allowed to ever turn on?
  boolean online;               //Are shields up?

  //Shield size scaling
  float sizeScale = 1.3f;

  /**
   * Take in a parent object, build shield to default its x-size.
   * Then look at its largest dimension and re-scale the shield based on the
   * sizeScale factor around that.
   */
  Shield(Physical _parent, int _dmgCapacity, Sector _sector, Shape _collider)
  {
    super("Shield", _parent.location, new PVector(_parent.size.x, _parent.size.x), 2000, _sector, _collider);

    parent = _parent;

    sprite = shieldSprite;
    int outsideShipDimension;   //Determine which direction ship is bigger (to make shield that size)
    if(parent.size.y > parent.size.x)
    {
      outsideShipDimension = (int)parent.size.y;
    }
    else
    {
      outsideShipDimension = (int)parent.size.x;
    }

    size.x = outsideShipDimension * sizeScale;      //This is the largest ship dimension
    size.y = size.x;

    sprite.resize((int)size.x,(int)size.y);

    //Also update the collider size
    collider.size.x = size.x;
    collider.size.y = size.y;

    //Initially offline & disabled
    enabled = false;
    online = false;

    health.current = _dmgCapacity;
    health.max = health.current;
    
    //Regen setup
    lastUpdateTime = millis();
  }

  //Do NOT use physical behavior -- handle separately
  @Override public void Update()
  {
    if(enabled)
    {
      velocity = parent.velocity;         //HACK needs a velocity for collisions to register
      location = parent.location.get();   //Update to ship location
      collider.location = location;

      collider.Update();

      //Check for shields down during this past loop
      if(collidable && health.current <= 0)
      {
        collidable = false;
        online = false;
        lastUpdateTime += failureTime;        //Won't update (regen for another 5 seconds)
        
        health.current = 0;      //Reset to zero health (no negative shield health)
      }
      
      //Regen
      // if(millis() > lastUpdateTime + regenPeriod)    //Do one second tick updates
      // {
      //   if(!online)
      //   {
      //     health.current = (int)(0.35 * health.max);  //Give a reasonable amount of shield on restore
      //     online = true;
      //   }
      //   collidable = true;
        
      //   if(health.current < health.max)
      //   {
      //     health.current += shieldRegenAmount;
      //   }
      //   lastUpdateTime = millis();
      // }
    }
  }

  /**
   * Cause collision effects on the OTHER object
   * @param  {Physical} _other Other object to affect by this collision
   */
   @Override public void HandleCollision(Physical _other)
  {
    super.HandleCollision(_other);

    shieldHitSound.play();

  }
  
  public void RestoreShield()
  {
    health.current = health.max;
    collidable = true;
    online = true;
    enabled = true;
  }

}
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
  protected float minFireInterval = 1;          //ms between shots
  protected float currentFireInterval = 850;
  protected boolean canFire = true;

  ArrayList<Physical> targets;    //Firing targets selected after scan
  
  //Shields
  Shield shield;

  //Engines
  float minThrust, maxThrust;
  
  public Ship(String _name, PVector _loc, PVector _size, PImage _sprite, int _mass, 
    int _outlineColor, Sector _sector, Shape _collider) 
  {
    //Parent constructor
    super(_name, _loc, _size, _mass, _sector, _collider);
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
    
    //Shield setup
    int shieldSize = (int)size.x;      //HACK this sort of doesn't matter because the shield class over-writes this size in its constructor...
    Shape shieldCollider = new Shape("collider", location, new PVector(shieldSize, shieldSize), color(0,255,0), 
            ShapeType._CIRCLE_);

    int shieldCapacity = 500;
    shield = new Shield(this, shieldCapacity, currentSector, shieldCollider);

    //Prepare engines
    minThrust = 0.0f;
    maxThrust = 10.0f;

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
    info = new TextWindow("Ship Info", location, descriptor);
    
  }
  
  @Override public void DrawObject()
  {
    super.DrawObject();

    if(shield.online && shield.enabled)
    {
      collidable = false;     //Make double sure no collisions happen on the ship inside the shield
      shield.DrawObject();
    }
    else
    {
      collidable = true;
    }
    
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
    
    //Shield info update
    shield.Update();

  //**** UI ****//
    //Check if UI is currently rendered, and if so update info
    if(info.visibleNow)
    {
      UpdateUIInfo();
    }
    
    if(millis() > lastFireTime + currentFireInterval)
    {
      canFire = true;
    }
    else
    {
      canFire = false;
    }

    //Assume UI will not be rendered next frame
    info.visibleNow = false;    //Another mouseover/ click will negate this
    
    //Update icon overlay
    iconOverlay.UpdateLocation(location);

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
      GenerateDeathExplosions(3, location, size, currentSector);
    }
  }

  /**
   * Calculates shoot vector and builds a laser object to fire.
   * Note that the laser object adds itself to the sector in its
   * constructor, and does not need explicit appending.
   * @param {PVector} _target Target to shoot at
   * @param _color Laser color red/green
   */
  protected void BuildLaserToTarget(PVector _target, LaserColor _color)     //Replaced 'Physical _target' to a 'PVector _target';
  {
    if(canFire)
    {
      PVector targetVector = PVector.sub(_target,location);
      targetVector.normalize();
      
      //Create laser object
      PVector laserSize = new PVector(20,3);
      PVector laserSpawn;
      if(shield.enabled)
      {
        if(shield.size.x > size.x || shield.size.y > size.y)    //Fire outside shield
        { 
          laserSpawn = new PVector(location.x + targetVector.x * shield.size.x/2 * 1.25f, 
            location.y + targetVector.y * shield.size.y/2 * 1.25f);
        }
        else  //Weird case of a small shield -- just fire outside
        {
          laserSpawn = new PVector(location.x + targetVector.x * size.x * 1.1f, 
              location.y + targetVector.y * size.y * 1.1f);
        }
      }
      
      else
      {
        laserSpawn = new PVector(location.x + targetVector.x * size.x * 1.1f, 
          location.y + targetVector.y * size.y * 1.1f);
      }
      
      Shape laserCollider = new Shape("collider", laserSpawn, laserSize, color(0,255,0), 
            ShapeType._RECTANGLE_);
      LaserBeam beam = new LaserBeam(laserSpawn, targetVector, laserSize, currentSector, 
                  laserCollider, _color);
      
      lastFireTime = millis();
      canFire = false;
    }
    
  }
    
  protected void BuildLaserToTarget(Physical _target, LaserColor _color)
  {
    if(canFire)
    {
      //Calculate laser targeting vector
      PVector targetVector = PVector.sub(_target.location, location);
      targetVector.normalize();        //Normalize to simple direction vector
      targetVector.x += rand.nextFloat() * 0.5f - 0.25f;
      targetVector.y += rand.nextFloat() * 0.5f - 0.25f;
      
      //Create laser object
      PVector laserSize = new PVector(20,3);
      PVector laserSpawn;
      if(shield.enabled)    //Fire outside sheild to prevent self collision
      {
        laserSpawn = new PVector(location.x + targetVector.x * shield.size.x/2 * 1.1f, 
          location.y + targetVector.y * shield.size.y/2 * 1.1f);    //Where to spawn the laser outside ship
      }
      else
      {
        laserSpawn = new PVector(location.x + targetVector.x * size.x * 1.1f, 
          location.y + targetVector.y * size.y * 1.1f);    //Where to spawn the laser outside ship
      }
      Shape laserCollider = new Shape("collider", laserSpawn, laserSize, color(0,255,0), 
            ShapeType._RECTANGLE_);
      LaserBeam beam = new LaserBeam(laserSpawn, targetVector, laserSize , currentSector, 
            laserCollider, _color);

      lastFireTime = millis();
      canFire = false;
    }
    
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
    println("[INFO] No interaction defined for ship click");
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

public class Station extends Physical implements Updatable, Friendly
{
  static final int maxStationSize = 60;      //Maximum station size
  static final int maxStationHealth = 1000;  //Maximum health for a station
  
  //Station mass-energy generation per sec
  int massEnergyGen;

  //Aid
  boolean friendly;
  int healAmount = 50;
  int healPeriod = 200;        //How long between each heal tick
  long lastHealTime = 0;
  
  //Placement parameters
  Shape placementCircle;      //Shows the area where a spawned ship/ missile may be placed around this station
  int placementRadius;
  boolean displayPlacementCircle = false;    //Whether or not to draw the placement circle
  
  //Damage effects
  PVector smoke1Loc, smoke2Loc;    //In local coordinats relative to ship's location
  Smoke smokeEffect1;
  Smoke smokeEffect2;
  boolean smoke1Visible, smoke2Visible;
  
  public Station(StationType _type, PVector _loc, PVector _size, PImage _sprite, Sector _sector, Shape _collider) 
  {
    super("Military Station", _loc, _size, 1500, _sector, _collider);
    //TODO implement something besides military station?

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
  }
  
  @Override public void DrawObject()
  {
    super.DrawObject();
    
    //Draw smoke effects
    pushStyle();
    if(smoke1Visible)
    {
      smokeEffect1.DrawObject();
    }
    if(smoke2Visible)
    {
      smokeEffect2.DrawObject();
    }
    popStyle();
  }
  
  public void Update()
  {
    super.Update();    //Call physical update

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
      GenerateDeathExplosions(5, location, size, currentSector);
    }
  }

  /**
   * Heal the player, if friendly
   * @param _friend Friendly object
   */
  public void ProvideAid(Physical _friend)
  {
    if(friendly)
    {
      if(millis() > lastHealTime + healPeriod)
      {
        _friend.health.Add(healAmount); 
        lastHealTime = millis();
      }
    }
  }
}
public enum DrawStyle {
  STANDARD, GRADIENT
}

class TextWindow extends UI
{  
  private String textData = "";
  private int backgroundColor;         //For standard background
  private int gradientColor;         //destination color background -> gradientColor
  private int textRenderMode;          //Render as center or corner
  private DrawStyle fillMode;          //How to fill the text window
  
  ArrayList<Drawable> icons;  //Icons within the window
  
  TextWindow(String _name, PVector _loc, String _text)
  {
    super(_name, _loc, new PVector(200, 125), false);      //Default size 200 by 100
    textData = _text;
    
    fillMode = DrawStyle.STANDARD;      //Solid color fill by default
    backgroundColor = color(0,0,65,200);
    textColor = color(255);
    textRenderMode = CORNER;
    renderMode = CORNER;            //Default render mode for a textbox is corner
    
    icons = new ArrayList<Drawable>();
  }
  
  TextWindow(String _name, PVector _loc, PVector _size, String _text)
  {
    super(_name, _loc, _size, false);      //Non-standard window size
    textData = _text;
    
    fillMode = DrawStyle.STANDARD;      //Solid color fill by default
    backgroundColor = color(0,0,65,200);
    textColor = color(255);
    textRenderMode = CORNER;
    renderMode = CORNER;            //Default render mode for a textbox is corner
    
    icons = new ArrayList<Drawable>();
  }
  
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

    rect(0, 0, size.x, size.y);
    
    //TEXT
    fill(textColor);
    if(textRenderMode == CENTER)
    {
      translate(size.x/2,0);    //Shift by half text box size (fake center rendering)
    }
    
    textAlign(textRenderMode,TOP);
    
    textFont(standardFont, fontSize);    //Standard standardFont and size for drawing fonts

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
    
    font = standardFont;      //Use pre-generated font
    if(font == null)
    {
      println("[ERROR] PFont null!");
    }
    fontSize = 14;
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

/**
 * Update all physical objects using their Update() function
 * Check if objects should be killed (remove them from their arraylist)
 * Check if object has left its parent sector, removing them from that sector's list
 * and adding them to another sector's.
 * @param _object [description]
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

    else if(obj.velocity.mag() > 0)      //If moving, check if it has left the sector
    {
      if(!CheckDrawableOverlap(obj.currentSector.collider, obj.location))   //Is object inside the sector still?
      {
        boolean newSectorFound = false;
        if(debugMode.value)
        {
          println("[DEBUG] " + obj.name + " has left its parent sector...");
        }
        
        //TODO should be doing rectangle-rectangle collision, not point-point. This should do for now
        //Object left sector -- find new sector it is in
        for(Sector sector : sectors.values())
        {
          if(CheckDrawableOverlap(sector.collider, obj.location))
          {
            obj.currentSector = sector;
            if(debugMode.value)
            {
              println("[DEBUG] " + obj.name + " moved to sector " + sector.name);
            }
            //HACK check if this is the playership to generate more sectors
            if(obj instanceof Player)
            {
              //Add to temp hashmap, merge at end (see GameLoops & AssetLoader's MergeSectorMaps)
              generatedSectors = BuildSectors(obj.currentSector);
            }

            //Remove from current sector's objects, add to next sector's objects
            sector.ReceiveNewObject(obj);

            try
            {
              iterator.remove();      //Remove from current list inside sector
              newSectorFound = true;
            }
              
            catch(Exception e)
            {
              println("[ERROR] deleting object " + obj.name);
              println("[ERROR] " + e);
            }
            break;
          }
        }
        if(!newSectorFound)
        {
          println("[WARNING] " + obj.name + " moved into empty sector");
          obj.toBeKilled = true;
        }
        
      }
    }
  }
}

public void UpdateSectorMap(HashMap<Integer, Sector> _sectors)
{
  for(Sector a : _sectors.values())
  {
    a.Update();      //Update the sector object
    UpdatePhysicalObjects(a.ships);
    UpdatePhysicalObjects(a.asteroids);
    UpdatePhysicalObjects(a.planets);  //Station updates occur in planet update loop
    UpdatePhysicalObjects(a.friendlyLaserFire);
    UpdatePhysicalObjects(a.enemyLaserFire);
    UpdatePhysicalObjects(a.enemyLaserFire);
    UpdatePhysicalObjects(a.powerups);

    if(!a.shipsToAdd.isEmpty())       //Add in ships generated during update loop (currently only charred hull)
    {
      for(Ship s : a.shipsToAdd)
      {
        a.ships.add(s);
      }
      a.shipsToAdd.clear();
    }
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
    a.collider.DrawObject();    //Draw sector outlines
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

  for(Sector a : _sectors.values())
  {
    DrawObjects(a.friendlyLaserFire);
    DrawObjects(a.enemyLaserFire);
  }
  
  for(Sector a : _sectors.values())
  {
    DrawObjects(a.powerups);
  }

  for(Sector a : _sectors.values())
  {
    DrawObjects(a.explosions);
  }
}

/**
 * Move all objects in a sector
 * @param _sectors map of sectors by ID
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

  for(Sector a : _sectors.values())
  {
    MovePhysicalObject(a.friendlyLaserFire);
    MovePhysicalObject(a.enemyLaserFire);
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
public void GenerateDeathExplosions(int _count, PVector _center, PVector _deadObjSize, Sector _sector)
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
    
    _sector.explosions.add(explosion);                        //Add this explosion to an ArrayList<Explosion> for rendering
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

  public void Reset()
  {
    viewRatio = 1;
    orgX = 0.0f;
    orgY = 0.0f;
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
