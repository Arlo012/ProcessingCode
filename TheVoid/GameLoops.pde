/*
 * Convenience tab to hold all draw loops. These just play the main draw loop in different game states,
 * as named by their method name.
*/

PFont startupFont;
void DrawStartupLoop()
{
  image(bg, -10 + (10*sin(introAngle + HALF_PI)),(10*sin(introAngle)),displayWidth+20,displayHeight+20);
  image(nebula3, displayWidth*.55 + (10*sin(introAngle + HALF_PI)), displayHeight*.25 +(10*sin(introAngle + HALF_PI)));
  image(shipSprite,startLocation.x,startLocation.y, playerSize.x,playerSize.y);
  
  fill(75,247,87);   //Green
  textFont(introFont, 154);
  textAlign(CENTER, CENTER);
  text("The", displayWidth/2 - 72, displayHeight/8);
  textAlign(CENTER, CENTER);
  text("Void", displayWidth/2 + 72, displayHeight/8 + 154);
  fill(255);
  textFont(instructFont, 56);
  text("Press 'S' to enter The Void!", displayWidth/2, displayHeight*.8);
  text("Press 'M' for instructions", displayWidth/2, displayHeight*.8 + 72);
  if(introAngle <= 6.28)
  {
    introAngle += .01;
  }
  else
  {
    introAngle = 0.0;
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
void DrawInstructionsLoop()
{
  textFont(instructFont, 32);
  image(bg,0,0,displayWidth,displayHeight);
  image(shipSprite, displayWidth/2, displayHeight/2, playerSize.x,playerSize.y);
  playerShip.leftEnginePower = 5.0;
  playerShip.rightEnginePower = 7.0;
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
    DrawArrow(width/2.5,height*.8,HALF_PI,50);
    textFont(instructFont, 32);
    textAlign(LEFT);
    text("This is your Sheild Strength, you will not lose health\nwhile the sheild is up. Once your sheild is lost it will \nregenerate after 5 seconds.", 0, 
    displayHeight*.75);
  }
  else if(instructionNumber == 2)
  {
    DrawArrow(width*.96,height*.76,HALF_PI,50);
    textFont(instructFont, 32);
    textAlign(RIGHT);
    text("These are you Engine Powers,\nyour left engine in green,\nyour right engine in blue",width,height*.65);
  }
  else if(instructionNumber == 3)
  {
    PVector enemyShipSize = enemyShipSizes.get(0);
    image(enemyShipSprites.get(0), width*.8, height/2,enemyShipSize.x*.25,enemyShipSize.y*.25);
    DrawArrow(width*.8+enemyShipSize.x/8, height/2 - 60, HALF_PI, 50);
    textAlign(LEFT);
    textFont(instructFont, 32);
    text("This is an Enemy Ship. They will attack \nyou relentlessly until you are destroyed!",width/2,height/2-120);
  }
  else if(instructionNumber == 4)
  {
    image(blueStation1,width*.8, height/2, blueStation1.width*.15, blueStation1.height*.15);
    DrawArrow(width*.8+((blueStation1.width*.15)/2), height/2 - 60,HALF_PI, 50);
    textAlign(LEFT);
    textFont(instructFont, 32);
    text("This is a Healing Station. Hover you ship \nabove it to regain health.",width/2,height/2-120);
  }
    
  
  
  playerShip.leftEnginePower = 0.0;
  playerShip.rightEnginePower = 0.0;
}


PVector cameraPan = new PVector(0,0);     //Pixels of camera pan to follow ship
void DrawPlayLoop()
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
void DrawPauseLoop()
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

void DrawGameOverLoop()
{
  textFont(startupFont, 12);
  background(0);

  loopCounter++;

  pushMatrix();
  cameraPan.x = width/2 -playerShip.location.x;
  cameraPan.y = height/2 - playerShip.location.y;
  
  translate(cameraPan.x, cameraPan.y);    //Pan camera on ship
  
  DrawSectors(sectors);   //Draw sectors (actually just push sector objects onto render lists)
  
  popMatrix();

  //// ******* DrawMainUI ********//
  DrawMainUI();

}

//--------- MISC -----------//

SoundFile currentTrack;
long trackStartTime;
int currentTrackIndex = 0;
void MusicHandler()
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

void DrawMainUI()
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
  fill(0,255,0,250);
  leftThrottleSize.y = playerShip.leftEnginePower/playerShip.maxThrust * fullThrottleSize;
  leftThrottleLocation.y = height - leftThrottleSize.y;
  rect(leftThrottleLocation.x, leftThrottleLocation.y, leftThrottleSize.x, leftThrottleSize.y, 12, 12, 0, 0);
  
  fill(0,0,255,250);
  rightThrottleSize.y = playerShip.rightEnginePower/playerShip.maxThrust * fullThrottleSize;
  rightThrottleLocation.y = height - rightThrottleSize.y;
  rect(rightThrottleLocation.x, rightThrottleLocation.y, rightThrottleSize.x, rightThrottleSize.y, 12, 12, 0, 0);
  popStyle();
}

void DrawArrow(float arrowX, float arrowY, float angle,int arrowLen)
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

void DrawControls()
{
  textAlign(LEFT);
  textFont(instructFont, 32);
  text("Controls: \nFire Laser -> Left mouse click \nIncrease Left Engine -> Y \nDecrease Left Engine -> H \nIncrease Right Engine -> I \nDecrease Right Engine -> K \nPause - P",0,32);
}
