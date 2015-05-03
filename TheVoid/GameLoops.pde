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

void DrawPlayLoop()
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
void DrawPauseLoop()
{
  textFont(startupFont, 12);
  
  if(debugMode.value)
  {
    background(0);
  }
  else
  {
    background(bg);
  }

  loopCounter++;
//******* ALL ZOOMED AFTER THIS ********//
  BeginZoom();
  
  // //If zoomed out far enough, draw object icons with the objects
  // if(wvd.viewRatio < 1.5)
  // {
  //   //Draw Game objects
  //   DrawPlanets(P1.planets);
  //   DrawPlanets(P2.planets);
  //   DrawAsteroids(asteroids, true);         //See Visuals.pde
  //   DrawShips(P1.fleet, true);
  //   DrawShips(P2.fleet, true);
  //   DrawStations(P1.stations);
  //   DrawStations(P2.stations);
  //   DrawMissiles(P1.missiles, true);
  //   DrawMissiles(P2.missiles, true);
  //   DrawLasers(P1.lasers);
  //   DrawLasers(P2.lasers);
  //   DrawEffects(explosions);
  // }
  // else
  // {
  //   //Draw Game objects
  //   DrawPlanets(P1.planets);
  //   DrawPlanets(P2.planets);
  //   DrawAsteroids(asteroids, false);         //See Visuals.pde
  //   DrawShips(P1.fleet, false);
  //   DrawShips(P2.fleet, false);
  //   DrawStations(P1.stations);
  //   DrawStations(P2.stations);  
  //   DrawMissiles(P1.missiles, false);
  //   DrawMissiles(P2.missiles, false);
  //   DrawLasers(P1.lasers);
  //   DrawLasers(P2.lasers);
  //   DrawEffects(explosions);
  // }
  
//// ******* UI ********//

//// Mouseover text window info
  // PVector currentMouseLoc = new PVector(wvd.pixel2worldX(mouseX), wvd.pixel2worldY(mouseY));
  
  // //Add response from overlap checks to 'toDisplay' linkedlist
  // toDisplay.clear();
  // toDisplay.add(CheckClickableOverlap(asteroids, currentMouseLoc));
  // toDisplay.add(CheckClickableOverlap(P1.planets, currentMouseLoc));
  // toDisplay.add(CheckClickableOverlap(P2.planets, currentMouseLoc));
  // toDisplay.add(CheckClickableOverlap(P1.fleet, currentMouseLoc));
  // toDisplay.add(CheckClickableOverlap(P2.fleet, currentMouseLoc));
  // toDisplay.add(CheckClickableOverlap(P1.stations, currentMouseLoc));
  // toDisplay.add(CheckClickableOverlap(P2.stations, currentMouseLoc));
  
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

  
//// Debug mode display
  // if(debugMode.value)
  // {
  //   DrawGameArea(gameAreas);       //See Visuals.pde
  // }

//// ******* ALL ZOOMED BEFORE THIS ********//
  // EndZoom();
  
//// Draw Civ UI
  // P1.DrawCivilizationUI();
  // P2.DrawCivilizationUI();
  
//// Draw main interface
  // currentPlayer.DrawUI();
  
}

void DrawGameOverLoop()
{
  background(0);
  
  pushStyle();
  fill(color(255));
  textFont(startupFont, 48);
  textAlign(CENTER, CENTER);
  text("GAME OVER", width/2, height/2);
  
  popStyle();
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
