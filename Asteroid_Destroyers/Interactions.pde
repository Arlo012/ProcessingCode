
// Panning
void mouseDragged() {
  //Make sure we haven't panned outside the screen view
  if(!debugMode.value)
  {
    if (mouseX < width && mouseY < height 
      && wvd.pixel2worldX(width) < width 
      && wvd.pixel2worldY(height) < height) 
    {
      wvd.orgX -= (mouseX - pmouseX) / wvd.viewRatio;
      wvd.orgY -= (mouseY - pmouseY) / wvd.viewRatio;
    }
    
    if(wvd.orgX < 0)
    {
      wvd.orgX = 0;
    }
    if(wvd.orgY < 0)
    {
      wvd.orgY = 0;
    }
    
    if(wvd.pixel2worldX(width) > width)
    {
      wvd.orgX--;
    }
    if(wvd.pixel2worldY(height) > height)
    {
      wvd.orgY--;
    }
  }
  else
  {
    wvd.orgX -= (mouseX - pmouseX) / wvd.viewRatio;
    wvd.orgY -= (mouseY - pmouseY) / wvd.viewRatio;
  }

}

// Change zoom level
void mouseClicked() 
{
  PVector currentMouseLoc = new PVector(mouseX, mouseY);
  if(mouseButton == LEFT)
  {
    //Response from player controller when something left clicked
    Controller1.HandleLeftClick(currentMouseLoc);

  }
  else if (mouseButton == RIGHT)
  {
    Controller1.HandleRightClick(currentMouseLoc);
  }

}

void mouseWheel(MouseEvent e)
{
  float wmX = wvd.pixel2worldX(mouseX);
  float wmY = wvd.pixel2worldY(mouseY);
  
  wvd.viewRatio -= e.getAmount() / 20;
  wvd.viewRatio = constrain(wvd.viewRatio, 0.05, 200.0);
  
  //Prevent zooming out past standard zoom
  if(wvd.viewRatio < 1)
  {
    wvd.viewRatio = 1.00f;
  }
  else if(wvd.viewRatio > 2)
  {
    wvd.viewRatio = 2.00f;
  }
  else    //Only shift translation if we aren't zoomed out all the way
  {
    wvd.orgX = wmX - mouseX / wvd.viewRatio;
    wvd.orgY = wmY - mouseY / wvd.viewRatio;
  }
}


//Check for keypresses
void keyPressed() 
{
  //Player 1 movement
  if (key == CODED) 
  {
    if (keyCode == UP) 
    {
    }
    else if (keyCode == DOWN) 
    {
    }
    else if (keyCode == LEFT) 
    {
    }
    else if (keyCode == RIGHT) 
    {
    }
  }
  
  if(key == ENTER)
  {
    asteroids.get(0).SetDestinationAngle(250);
    asteroids.get(0).SetRotationMode(RotationMode.SPIN);    //Spin
    println("DEBUG: Rotating asteroid");
  }
  
  if (key == 'x') 
  {
    //Emulated 'click' the stop orders button
    currentPlayer.cancelOrders.Click();
  }
  
  if (key == 'e') 
  {
    if(debugMode.value)
    {
      Explosion boom2 = new Explosion(new PVector(wvd.pixel2worldX(mouseX),wvd.pixel2worldY(mouseY)), new PVector(64,48)); 
      explosions.add(boom2);
    }

  }

  
  if(key == 'r')
  {
    wvd.viewRatio = 1;
    wvd.orgX = 0.0f;
    wvd.orgY = 0.0f;
  }
  
}
