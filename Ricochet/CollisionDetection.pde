
void CheckForCollisions()
{
  if(ballY < 0 || ballY > height) 
  {
    //Over the top/bottom of the screen
    ballSpeedY *= -1.0;
  }
  else if(ballX < 0) 
  {
    //Check if ghost ball is active
    if(p1powerup.ghostMode && !p1powerup.extraLifeUsed)
    {
      ballSpeedX *= -1;                  //Just reverse the direction
      p1powerup.extraLifeUsed = true;    //Used up the extra life
    }
    else
    {
      //Left of screen
      scoreP1 = 3 * scoreP1/4;
      newBall();
      
      //Player 1 loses a life
      p1Lives--;
    }

  }
  else if(ballX > width)
  {
    if(p2powerup.ghostMode && !p2powerup.extraLifeUsed)
    {
      //Ghost ball is active
      ballSpeedX *= -1;
      p2powerup.extraLifeUsed = true;    //Used up the extra life
    }
    else
    {
      //Left of screen
      scoreP2 = 3 * scoreP2/4;
      newBall();
      
      //Player 2 loses a life
      p2Lives--;
    }
  }
  
  // check for collision with paddle
  // 1. tests if ball is at the paddle on the R/L
  // 2. tests if ball is below the top of the paddle
  // 3. tests if the ball is above the bottom of the paddle
  // if so, reverse the ball's direction
  if (ballX - ballSize/2 <= paddleWidth && ballY > paddle1y &&  ballY < paddle1y + paddleHeight) {
    //Player 1 paddle hit
    lastPlayerHitID = 0;      //Track who hit the ball
    ballSpeedX *= -1;
  }
  else if (ballX + ballSize/2 >= width-paddleWidth && ballY > paddle2y && ballY < paddle2y + paddleHeight) {
    //Player 2 paddle hit
    lastPlayerHitID = 1;      //Track who hit the ball
    ballSpeedX *= -1;
  }
  
  //If either ghost mode is active dont check for collisions
  if(!p1powerup.ghostMode && !p2powerup.ghostMode)
  {
    //Check for collision with Tilefield
    if(ballX >= TileUL.x - ballSize && ballY > TileUL.y - ballSize
        && ballX <= TileLR.x + ballSize && ballY <= TileLR.y + ballSize)
    {
      //If this is true we are within the field where we need to check for Tile collision
      for(Tile m : Tiles)
      {
        //Check if the ball's center falls within the square of the Tile
        if(ballX - ballSize/2 >= m.location.x && ballY - ballSize/2 > m.location.y 
          && ballX - ballSize/2 <= m.location.x + m.size 
          && ballY - ballSize/2 <= m.location.y + m.size)
        {
          //Detect which one we hit
          int[] distanceToSide = {0,0,0,0};
          distanceToSide[0] = (int)ballX - m.location.x;              //Left
          distanceToSide[1] = (int)ballX - m.location.x + m.size;    //Right
          distanceToSide[2] = (int)ballY - m.location.y;              //Top
          distanceToSide[3] = (int)ballY - m.location.y + m.size;    //Bottom
          
          int sideID = 0;    //Which side we hit
          int smallestDistance = 999;
          for(int i = 0; i < 4; i++)
          {
            if(distanceToSide[i] < smallestDistance)
            {
              smallestDistance = distanceToSide[i];
              sideID = i;
            }
          }
          
          //println("Doing things. Side ID = " + sideID);
          switch(sideID)
          {
            case 0:
              //left
              ballSpeedX *= -1;
              //println("Reversed ball X");
              break;
            case 1:
              //right
              ballSpeedX *= -1;
              //println("Reversed ball X");
              break;
            case 2:
              //top
              ballSpeedY *= -1;
              //println("Reversed ball Y");
              break;
            case 3:
              //bottom
              ballSpeedY *= -1;
              //println("Reversed ball Y");
              break;
          }
          
          
          //println("Hit Tile at: " + m.location.x + ", " + m.location.y);
          
          //Add Tile to 'to-destroy' list
          toRemove = m;
        }
      }
    }
  }

}

//Update score & destroy hit Tile
void ProcessHitTile()
{
  if(toRemove != null)
  {
    int scoreModifier = 0;    //Note: this structure is kind of overkill here, but leaves room for scoring addons
    if(toRemove.isPowerup)
    {
      scoreModifier += 300;
    }
    
    if(lastPlayerHitID == 0)
    {
      //Player 1 got this hit
      if(colorObj1 == toRemove.myColor)
      {
        //100 points for matching color
        scoreModifier += 100;
      }
    }
    else
    {
      //Player 2 got this hit
      if(colorObj1 == toRemove.myColor)
      {
        scoreModifier += 100;
      }
    }
    
    if(lastPlayerHitID == 0)
      scoreP1 += scoreModifier;
    else
      scoreP2 += scoreModifier;
    
    //Remove the tiles from the arraylist
    Tiles.remove(toRemove);
    toRemove = null;
    
    //Check for game over state
    if(Tiles.isEmpty())
    {
      GameOver();
    }
  } 
}
