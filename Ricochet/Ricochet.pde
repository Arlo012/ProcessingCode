/*
Tile Pong - Jeff Eitel
*/
import java.util.Iterator;
import java.util.List;
import java.util.Random;

//Game Stage
int gameStage = 0;        //0 = menu, 1 = play, 2 = gameover
boolean ballSpawnPaused;

//Background
color backgroundColor = color(0);

//Ball Variables
int ballSize = 12;
float ballX, ballY, ballSpeedX, ballSpeedY;
float maxSpeed = 5;

//Paddle variables
int paddleWidth = 12;
int paddleHeight = 100;
float playerSpeed = 30.0;    //How fast paddle moves
float paddle1y, paddle2y;    //Vertical position of the paddle
float paddleMoveSpeed = 3.5;  //Speed modifier for paddle

//Score
int scoreP1, scoreP2;
int p1Lives;
int p2Lives;
PFont font;

//Tiles
ArrayList<Tile> Tiles;
coordinate TileUL;    //Track where the edges of all the Tiles are for collision detection
coordinate TileLR;
Tile toRemove;        //Object to remove in case of collision (note: cannot explicitly destroy object while it is being iterated)
    //See: http://stackoverflow.com/questions/223918/iterating-through-a-list-avoiding-concurrentmodificationexception-when-removing
int flashCounter;  //Counter limit the FPS of color flashing
int flashInterval;  //To determine how many times loop must occur to flash

//Powerups
float powerupFrequency = 0.05;  //Percentage of powerups relative to total
powerup p1powerup = new powerup();
powerup p2powerup = new powerup();

//Tile colors
color[] tileColors = {color(255, 0, 0), color(0, 0, 255), color(0, 255, 0), 
                    color(234, 250, 23), color(219, 23, 250), color(250, 159, 23)};

//Objective Color
color colorObj1, colorObj2;
int colorUpdateCounter = 0;  
int colorUpdateInterval = 10000;      //Counter for how often color changes (units of frames)
int lastPlayerHitID = 0;             //Which player last hit the paddle?
int colorPalleteSize = 100;

//For fun
boolean EpilepsyMode = false;    //TODO this is a broken feature.... just use it for fun

//Ball spawning hearbeat flash
boolean showSpawnPulse = false;    //TODO this variable name is dumb
long ballSpawnTime = 0;
float pulseTimeLeft = 0;           //How much longer will the screen flash/fade?
float pulseDisplayDuration = 3;    //How long is the spawn pulse?

void setup()
{
  size(800,800);
  frame.setTitle("Richochet");
  
  //Variable setup
  flashCounter = 0;
  flashInterval = 15;
  p1Lives = 5;
  p2Lives = 5;
  
  noStroke();
  
  //Paddle setup                                                                                                                            
  paddle1y = height/2;
  paddle2y = height/2;
  
  //Score setup
  scoreP1 = scoreP2 = 0;
  
  //Tile definition
  Tiles = new ArrayList<Tile>();
  
  //HACK need to implement auto-center feature here (this only looks OK because I tuned it to look OK)
  int TileSize = 30;       //units of pixels
  int TileSpacing = 11;    //units of pixels
  int TileCount = 10;

  //Tile arraylist constructor 
  for(int i = 0; i < TileCount; i++)
  {
    for(int j = 0; j < TileCount; j++) //<>//
    {
      Tile toBuild = new Tile(width/4 + i*(TileSize+TileSpacing), 
        height/4 + j*(TileSize+TileSpacing), TileSize);
      Tiles.add(toBuild);
    }
  }
  
  //Define edges of the tile field
  TileUL = new coordinate(width/4, height/4);
  TileLR = new coordinate(width/4 + TileCount * (TileSize+TileSpacing), 
      height/4 + TileCount * (TileSize+TileSpacing));
      
  //Objective 
  colorObj1 = getNewColor();
  colorObj2 = getNewColor();
  
  //Font Setup
  font = createFont("Helvetica", 72);    // font name and size
  textFont(font, 72);

}                                                                                                                                                                              

void draw() 
{
  flashCounter++;        //global counter for how many times looped (note: framerate dependent)
  
  //Intro screen
  if(gameStage == 0)
  {
    background(0);  //Color black background
    DrawColorObjectives();   //See visuals
    DrawScores();            //See visuals
    DrawDottedLine();        //See visuals
    DrawIntoScreen();        //See visuals
  }
  
  //Play mode
  else if (gameStage == 1)
  {
    background(backgroundColor);  //Color black background
    DrawColorObjectives();    //Draw color objectives (see visuals)
    
    //Update color objective if desired
    if(EpilepsyMode)
    {
      colorUpdateCounter++;
      if(colorUpdateCounter % colorUpdateInterval == 0)
      {
        colorObj1 = getNewColor();
        colorObj2 = getNewColor();
      }
    }
    
    DrawScores();        //See visuals
    DrawDottedLine();    //See visuals
    
    //Draw Ball
    fill(255);
    ellipse(ballX, ballY, ballSize, ballSize);
  
    //Draw Paddles
    //ENHANCEMENT offset of 3 is hard-coded -- create variable
    rect(3, paddle1y, paddleWidth, paddleHeight);                          //Player1
    rect(width - paddleWidth - 3, paddle2y, paddleWidth, paddleHeight);    //Player2
    
    //Draw all Tiles
    DrawGrid();                //See visuals
    
    //Find out if either player has any active powerups right now, and respond
    CheckActivePowerups();      //See Powerup
    
    if(!ballSpawnPaused)
    {
      ballX += ballSpeedX;
      ballY += ballSpeedY;
      
      //Handle collisions
      CheckForCollisions();      //See CollisionDetection
      ProcessHitTile();          //See CollisionDetection
      
      //Guarantee ball speed is within speed limit (not too fast or slow)
      SpeedLimitCheck();    
      
      //Check for gameover condition
      if(p1Lives <= 0 || p2Lives <= 0)
      {
        gameStage = 2;
        GameOver();
      }
    }
    
    //Flash on ball spawning
    if(showSpawnPulse)
    {
      pulseTimeLeft = CalcPulseTimeLeft();
      DrawBallSpawnPulsing(pulseDisplayDuration, pulseTimeLeft);
      
      //Check if the pulse has finished
      if(pulseTimeLeft <= 0)
      {
        showSpawnPulse = false;
        ballSpawnPaused = false;
      }
      
      //Respect ghost mode color scheme when restoring
      if(p1powerup.IsGhostModeActive() || p2powerup.IsGhostModeActive())
      {
        backgroundColor = color(183, 174, 174);
      }
      
      //While ball is spawning track y-position of parent paddle
      if(lastPlayerHitID == 0)
      {
         //Track player 1 paddle
         ballY = paddle1y + paddleHeight/2;  //Start ball on player's paddle
      }
      else
      {
         //Track player 1 paddle
         ballY = paddle2y + paddleHeight/2;  //Start ball on player's paddle
      }
    }
  }
   println(frameRate);
}

void GameOver()
{
  background(0);
  DrawScores();
  
  textFont(font, 72); 
  textAlign(CENTER, CENTER);
  text("GAME OVER", width/2, height/2);
  if(p1Lives <=0)
    text("P2 WINS", width/2, height/2 + 125);
  else if(p2Lives <= 0)
    text("P1 WINS", width/2, height/2 + 125);
  else
  {
    //All tiles have been destroyed, but nobody has run out of lives
    if(scoreP1 > scoreP2)
      text("P1 WINS", width/2, height/2 + 125);
    else if (scoreP1 < scoreP2)
      text("P2 WINS", width/2, height/2 + 125);
    else
      text("Wow... a tie", width/2, height/2 + 125);
  }
  
  textFont(font, 40); 
  text("Press ENTER to Ricochet again.", width/2, height/2 + 200);
  textFont(font, 72);     //Return to standard font (courtesy)
}
