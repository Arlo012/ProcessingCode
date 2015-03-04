void mouseWheel(MouseEvent e)
{

  //gameTranslate.x -= gameTranslate.x-e.getAmount()*(mouseX)/50;        //See Visuals for gameTranslate
  //gameTranslate.y -= gameTranslate.y-e.getAmount()*(mouseY)/50;
  //scaleFactor += e.getAmount() / 50;
  
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

  }
  
}
