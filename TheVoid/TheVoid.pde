import java.util.Map;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Random;
import java.util.Iterator;
import java.util.LinkedList;
import processing.sound.*;

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
static boolean debuggingAllowed = false;      //Display DEBUG button on GUI?
TogglableBoolean debugMode = new TogglableBoolean(true);
boolean profilingMode = true;

//Handle zooming http://forum.processing.org/one/topic/zoom-based-on-mouse-position.html
float minX, maxX, minY, maxY;
WorldViewData wvd = new WorldViewData();

//UI Info
LinkedList<Clickable> toDisplay;        //List of clickable UI objects to display //<>//

//TEST AREA
Player playerShip;

void setup()
{
  size(1600, 1200, P3D);    //Need 3D acceleration to make this game run at decent FPS
  frame.setTitle(title);

  //Zoom setup
  cursor(CROSS);
  minX = 0;
  minY = 0;
  maxX = width;
  maxY = height;

  //Camera setup
  beginCamera();

  //Load all image/sound assets
  LoadImageAssets();      //See AssetLoader.pde
  LoadSoundAssets();
  startupFont = loadFont("SourceCodePro-Regular-48.vlw");

  //Game area setup
  sectors = new HashMap<Integer, Sector>();
  generatedSectors = new HashMap<Integer, Sector>();
  sectorSize = new PVector(width*2,height*2);
  visibleSectors = new ArrayList<Sector>();
  explosions = new ArrayList<Explosion>();

  playerShip = new Player(new PVector(width, height), new PVector(100, 50), 
      shipSprite, 100, color(255,0,0), null);     //Place player in start sector
  playerShip.health.current = 10000;

  //Setup civilizations and their game objects, along with controllers
  GameObjectSetup();    //See AssetLoaders.pde
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

  //HACK just render current sector
  visibleSectors.clear();
  visibleSectors.add(playerShip.currentSector);
}

void draw()
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
