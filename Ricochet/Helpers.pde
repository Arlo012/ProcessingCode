/*
  Helper methods
*/


//Return random color from pre-defined list
color getNewColor()
{
  return(tileColors[new Random().nextInt(tileColors.length)]);
}


//Check for keypresses
void keyPressed() 
{
  //Player 1 movement
  if (key == CODED) 
  {
    if (keyCode == UP) 
    {
      if(paddle2y - paddleHeight/2 > 0)
        paddle2y -= int(playerSpeed * paddleMoveSpeed);          // minus = up
    }
    else if (keyCode == DOWN) 
    {
      //HACK -- this check doesn't match the UP because of pixel alignment with the bottom, but works
      if(paddle2y + paddleHeight < height)
        paddle2y += int(playerSpeed * paddleMoveSpeed);          // plus = down
    }
  }
  
  if(key == ENTER)
  {
    if(gameStage == 0)
    {
      //Currently in setup state, entering play stage. Spawn ball
      newBall();
      gameStage = 1;
    }
    else if(gameStage == 2)
    {
      //Currently in game over state, restarting
      setup();
      gameStage = 0;
    }
    
    else
    {
      gameStage = 1;
    }

    println("Pressed enter");
  }
  
  //Player 2 movement
  if (key == 'w') 
  {
    if(paddle1y - paddleHeight/2 > 0)
      paddle1y -= int(playerSpeed * paddleMoveSpeed);
  }
  else if (key == 's') 
  {
    if(paddle1y + paddleHeight < height)
      paddle1y += int(playerSpeed * paddleMoveSpeed); 
  }
  
  //Player 1 powerups
  if (key == '1')
    scoreP1 = p1powerup.ActivateGhostMode(scoreP1);
  else if(key == '2')
    scoreP1 = p1powerup.ActivateOpponentScramble(scoreP1); 
  else if(key == '3')
    scoreP1 = p1powerup.ActivateTargetRandomizer(scoreP1);
  
  
  //Player 2 powerups
  if (key == 'i')
    scoreP2 = p2powerup.ActivateGhostMode(scoreP2);
  else if(key == 'o')
    scoreP2 = p2powerup.ActivateOpponentScramble(scoreP2);
  else if(key == 'p')
    scoreP2 = p2powerup.ActivateTargetRandomizer(scoreP2);
    
}


//Spawn a new ball randomly on either side of the court, with a random direction
void newBall() 
{
  println("Creating a new ball");
  //Random side to start on (this will act as the sign)
  int xStartSign = 0;
  
  //Player 2 got the last point (note this is different from ball possession in case of bounce-back)
  if(ballX < 0)
  {
    xStartSign = 1;    //Starting on player 2's side
    ballY = paddle2y + paddleHeight/2;  //Start ball on player's paddle //<>//
  }
  //Player 1 got the last point
  else
  {
    xStartSign = -1;    //Starting on player 1's side
    ballY = paddle1y + paddleHeight/2;   //Start ball on player's paddle
  }
  ballX = width/2 + xStartSign * 0.45 * width;      //Place ball with whoever got the last point
  
  ballSpeedX = random(-xStartSign*maxSpeed, -xStartSign*maxSpeed);    // random speed
  ballSpeedY = random(-maxSpeed * 3/4, maxSpeed * 3/4);
  
  //Record spawn time
  ballSpawnTime = millis();
  showSpawnPulse = true;
  
  //Guarantee that the speed isnt too slow
  while(abs(ballSpeedX) < 2)
  {
    ballSpeedX = random(-maxSpeed, maxSpeed); 
  }
  
  while(abs(ballSpeedY) < 2)
  {
   ballSpeedY = random(-maxSpeed, maxSpeed); 
  }
  
  //Depending on the side the ball started on, assume that player just hit the ball last
  if(xStartSign < 0)
    lastPlayerHitID = 0;    //Player 1 just hit the ball
  else
    lastPlayerHitID = 1;
    
  ballSpawnPaused = true;
}

//Guarantee ball doesn't move too slowly/quickly to play
void SpeedLimitCheck()
{
  if(abs(ballSpeedX) < 2)
  {
    if(ballSpeedX > 0)
      ballSpeedX = 3;
    else
      ballSpeedX = -3;
  }
  
  if(abs(ballSpeedY) < 2)
  {
    if(ballSpeedY > 0)
      ballSpeedY = 3;
    else
      ballSpeedY = -3;
  }
  
  if(abs(ballSpeedX) > maxSpeed)
  {
    if(ballSpeedX > 0)
      ballSpeedX = maxSpeed;
    else
      ballSpeedX = -maxSpeed;
  }
  
  if(abs(ballSpeedY) < maxSpeed)
  {
    if(ballSpeedY > 0)
      ballSpeedY = maxSpeed;
    else
      ballSpeedY = -maxSpeed;
  }
}

//Calculate how long until the game unpauses and the ball starts moving, in seconds
float timeLeft = 0;
float CalcPulseTimeLeft()
{
 //Note: millis() returns an int. Need it as a float to get smooth fade
  timeLeft = pulseDisplayDuration - (float(millis()) - ballSpawnTime)/1000;      //Based on a given second pulse length
  return timeLeft;
}

//FEATURE implement rotating paddle and appropriate trig
float rotationAngle;
float GetPaddleRotation()
{
  if(mouseY > 0)
  {
    rotationAngle = (mouseY * 2 * PI)/height;
    return rotationAngle;
  }
  else
    return 0.0;
}
