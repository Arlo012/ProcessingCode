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
  PLAY, PLAYERCHANGE,
  PAUSED, GAMEOVER
}

//Turns
int turnLength = 30000;        //How many ms for each player's turn?
long currentTurnStartTime;  //When did THIS turn begin?
boolean UIFlipped = false;
int pulseDisplayDuration = 4000;    //milliseconds of screen pulse between turns

//Random number generator
Random rand = new Random();

//Game Name
String title = "Asteroid Destroyers";

//Game state
GameState gameState = GameState.START;

//Teams
Civilization P1, P2;
PlayerController Controller1, Controller2;
PlayerController currentPlayer;   //Who is currently playing, set in AssetLoaders.pde
PlayerController otherPlayer;
Civilization winner;              //For game-over state

//Game stage
GameStage gameStage;

//Game objects
ArrayList<Asteroid> asteroids;
ArrayList<Asteroid> debrisSpawned;      //Temp holder for debris generated from dead asteroids
ArrayList<Explosion> explosions;

//Game areas
HashMap<String,GameArea> gameAreas;

//Counters
long loopCounter;        //How many loop iterations have been completed
long loopStartTime;      //Millis() time main loop started
long pulseEffectStartTime;  //When the flash effect between turns started
long pauseTime;          //When the game was paused

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
  currentTurnStartTime = millis();
  
  //Intro music
  introMusic.play();
  trackStartTime = millis();
  currentTrack = introMusic;
  
  //TEST AREA
  //Missile missileToAdd = new Missile(new PVector(width/4, height/2), new PVector(0,0), P2.outlineColor, P2);
  //P2.missiles.add(missileToAdd);
}

void draw()
{
  MusicHandler();      //Handle background music
  
  if(gameState == GameState.START)
  {
    DrawStartupLoop();
  }
  else if(gameState == GameState.INSTRUCTIONS)
  {
    DrawInstructionLoop();
  }
  else if(gameState == GameState.PLAY)
  {
    DrawPlayLoop();
    //Handle gamestate change conditions
    if(millis() > currentTurnStartTime + turnLength)    //Turn over
    {
      gameState = GameState.PLAYERCHANGE;
      pulseEffectStartTime = millis();
    }
  }
  else if(gameState == GameState.PLAYERCHANGE)    //Changing turns
  {
    if(!UIFlipped)    //Check if UI has switched sides on the screen yet
    {
      //Make sure opponent doesn't still hold any 'selected' objects
      currentPlayer.CedeControlForTurnChange();
      
      PlayerController lastPlayer = currentPlayer;
      currentPlayer = otherPlayer;
      otherPlayer = lastPlayer;
      UIFlipped = true;
    }
    
    //Draw pulse for turn change & paused game
    pulseDrawTimeLeft = pulseDisplayDuration - (millis() - pulseEffectStartTime); 
    DrawPauseLoop();
    DrawScreenPulse(pulseDrawTimeLeft);
    
    if(pulseDrawTimeLeft <= 0)
    {
      //Switch teams, etc.....
      currentTurnStartTime = millis();
      
      gameState = GameState.PLAY;    //Wait for next player to hit space
      UIFlipped = false;          //On next playerchange, flip UI again
    }
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
