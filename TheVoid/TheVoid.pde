import java.io.ByteArrayOutputStream;
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

GameState gameState = GameState.START;

//Game Name
String title = "The Void";

//Teams
PlayerController Controller1;

//Game objects
ArrayList<Asteroid> asteroids;
ArrayList<Asteroid> debrisSpawned;      //Temp holder for debris generated from dead asteroids
ArrayList<Explosion> explosions;

//Game areas
HashMap<String,GameArea> gameAreas;

//Counters
long loopCounter;        //How many loop iterations have been completed
long loopStartTime;      //Millis() time main loop started

//Debugging & profiling
boolean debuggingAllowed = false;      //Display DEBUG button on GUI? Do not modify this once in play
TogglableBoolean debugMode = new TogglableBoolean(false);
boolean profilingMode = false;
boolean asteroidCollisionAllowed = false;

//Handle zooming http://forum.processing.org/one/topic/zoom-based-on-mouse-position.html
float minX, maxX, minY, maxY;
WorldViewData wvd = new WorldViewData();

//UI Info
LinkedList<Clickable> toDisplay;        //List of clickable UI objects to display //<>//
float pulseDrawTimeLeft;

//TEST AREA

void setup()
{
  size(1600, 1000);
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
  BuildGameAreas();    //See AssetLoaders.pde

  //Setup civilizations and their game objects, along with controllers
  GameObjectSetup();    //See AssetLoaders.pde
  
  //Counters & framerate
  loopCounter = 0;
  frameRate(60);
  loopStartTime = millis();
  
  //Intro music
  introMusic.play();
  trackStartTime = millis();
  currentTrack = introMusic;
}

void draw()
{
  MusicHandler();      //Handle background music
  
  if(gameState == GameState.START)
  {
    DrawStartupLoop();
  }
  
  else if(gameState == GameState.PLAY)
  {
    DrawPlayLoop();
  }

  else if(gameState == GameState.PAUSED)
  {
    DrawPauseLoop();
  }
  
  else if(gameState == GameState.GAMEOVER)
  {
    DrawGameOverLoop();
  }
  
  //TEST AREA
  
  //Can't add debris during update loops (the iterators dont like that), 
  //    so update them from here after everything is done
  for(Asteroid a : debrisSpawned)
  {
    asteroids.add(a);
  }
  debrisSpawned.clear();
  

}
