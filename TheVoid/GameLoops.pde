/*
 * Convenience tab to hold all draw loops. These just play the main draw loop in different game states,
 * as named by their method name.
*/

PFont startupFont;
void DrawStartupLoop()
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


PVector cameraPan = new PVector(0,0);     //Pixels of camera pan to follow ship
void DrawPlayLoop()
{
  textFont(startupFont, 12);
  background(0);

  loopCounter++;

  //******* ALL ZOOMED AFTER THIS ********//
  BeginZoom();      //See visuals.pde
  cameraPan.x = width/2 -playerShip.location.x;
  cameraPan.y = height/2 - playerShip.location.y;
  
  translate(cameraPan.x, cameraPan.y);    //Pan camera on ship
  //rotate(playerShip.baseAngle);
  
  if(mousePressed)
  {
    PVector offset = new PVector(width,height);
    offset.sub(playerShip.location);
    playerShip.BuildLaserToTarget(new PVector(2*mouseX-offset.x,2*mouseY-offset.y));
  }

  //Only render/update visible sectors (slightly faster)
  // DrawSectors(visibleSectors);
  // UpdateSectors(visibleSectors);

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
  
  //// ******* ALL ZOOMED BEFORE THIS ********//
  EndZoom();

  //// Draw main interface
  // currentPlayer.DrawUI();

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
 
}


void DrawGameOverLoop()
{
 
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
