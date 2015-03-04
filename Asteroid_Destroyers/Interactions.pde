
// Panning
void mouseDragged() {
  if (mouseX < width && mouseY < height) {
    wvd.orgX -= (mouseX - pmouseX) / wvd.viewRatio;
    wvd.orgY -= (mouseY - pmouseY) / wvd.viewRatio;
  }
  
  //Make sure we haven't panned outside the screen view
  if(!debugMode)
  {
    if(wvd.orgX < 0)
    {
      wvd.orgX = 0;
    }
    if(wvd.orgY < 0)
    {
      wvd.orgY = 0;
    }
    
    //TODO: fix right side panning boundary
    /*
    if(wvd.orgX > wvd.pixel2worldX(width))
    {
      wvd.orgX = wvd.pixel2worldX(width);
    }
    if(wvd.orgY > wvd.pixel2worldY(height))
    {
      wvd.orgX =wvd.pixel2worldY(height);
    }
    */
  }

}

// Change zoom level
void mouseClicked() {
  if (mouseX < width && mouseY < height) {
    if (mouseButton == LEFT || mouseButton == RIGHT) {
      // Calculate current mouse position position
      float wmX = wvd.pixel2worldX(mouseX);
      float wmY = wvd.pixel2worldY(mouseY);
      float sf = (mouseButton == LEFT) ? 1.1 : 0.9;
      wvd.viewRatio *= sf;
      wvd.viewRatio = constrain(wvd.viewRatio, 0.05, 200.0);
      
      //Prevent zooming out past standard zoom
      if(wvd.viewRatio < 1)
      {
        wvd.viewRatio = 1.00f;
      }
      else    //Onlt shift translation if we aren't zoomed out all the way
      {
        wvd.orgX = wmX - mouseX / wvd.viewRatio;
        wvd.orgY = wmY - mouseY / wvd.viewRatio;
      }
    }
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
    asteroids.get(0).SetRotationMode(1);    //Spin
    println("DEBUG: Rotating asteroid");
  }
  
  //Player 2 movement
  if (key == 'w') 
  {
    p1Ships.get(0).SetRotationMode(2);
    p1Ships.get(0).SetRotationTarget(new PVector(mouseX,mouseY));
  }
  else if (key == 's') 
  {
   
  }
  
  if(key == 'r')
  {
    wvd.viewRatio = 1;
    wvd.orgX = 0.0f;
    wvd.orgY = 0.0f;
  }
  
}
