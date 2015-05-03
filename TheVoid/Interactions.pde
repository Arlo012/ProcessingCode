/*
 * Mouse & keyboard input here.
 */

// Panning
void mouseDragged() {
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
void mouseClicked() 
{
  PVector currentMouseLoc = new PVector(mouseX, mouseY);
  
  //Click actions here, based on gamestate
}

void mouseWheel(MouseEvent e)
{
  //TODO phase out mousewheel (centering camera messes up zoom... fix or remove this)
  float wmX = wvd.pixel2worldX(mouseX);
  float wmY = wvd.pixel2worldY(mouseY);
  
  wvd.viewRatio -= e.getAmount() / 20;
  wvd.viewRatio = constrain(wvd.viewRatio, 0.05, 200.0);
  
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
void keyPressed() 
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
      playerShip.leftEnginePower -= playerShip.minThrust;
    }
  }
  else if(key =='y' || key == 'Y')
  {
    if(playerShip.leftEnginePower < playerShip.maxThrust)
    {
      playerShip.leftEnginePower += playerShip.minThrust;
      println(playerShip.leftEnginePower);
    }
  }
  else if(key == 'k' || key == 'K')
  {
    if(playerShip.leftEnginePower > playerShip.minThrust)
    {
      playerShip.rightEnginePower -= .1;
    }
  }
  else if(key =='i' || key == 'I')
  {
    if(playerShip.leftEnginePower < playerShip.maxThrust)
    {
      playerShip.rightEnginePower += playerShip.minThrust;
    }
  }

  //DEBUG ONLY
  if(key == 'w')
  {
    playerShip.location.y -= 5;
  }
  else if(key == 's')
  {
    playerShip.location.y += 5;
  }
  else if(key == 'a')
  {
    playerShip.location.x -= 5;
  }
  else if(key == 'd')
  {
    playerShip.location.x += 5;
  }
}
