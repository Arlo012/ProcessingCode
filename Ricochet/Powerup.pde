public class powerup
{
  private boolean ghostMode = false;           //Ball goes through tiles, one extra 'life' for person who gets it
  public boolean extraLifeUsed = false;
  private long ghostModeDuration = 15000;    //milliseconds
  private long ghostModeStartTime;
  private int ghostModeCost = 300;          //Point cost to activate ghost mode
  
  private boolean opponentScramble = false;    //Make my opponents colors scramble everywhere
  private long scrambleDuration = 5000;        //milliseconds
  private long scrambleStartTime;
  private int opponentScrambleCost = 200;     //Point cost to activate opponent target scrambler
  
  private boolean targetRandomizer = false;    //Randomize my color target
  private int targetRandomizerCost = 100;     //Point cost to activate self target randomizer
  
  //Returns score after activating ghost mode, passing in the player's current score
  public int ActivateGhostMode(int currentScore)
  {
    if(currentScore >= ghostModeCost)
    {
      ghostMode = true;
      println("Activated ghost mode");
      backgroundColor = color(183, 174, 174);      //'Ghost' background color effect
      ghostModeStartTime = millis();
      return currentScore - ghostModeCost;
    }
    else
    {
      return currentScore;
    }
  }
  
  //Returns true/false if ghost mode is still active based on the mode duration and timer
  //HACK also responsible for keeping track of alive time -- should be a separate function
  public boolean IsGhostModeActive()
  {
    //If game is paused due to ball spawning, terminate ghost mode
    if(ballSpawnPaused)
    {
       ghostMode = false;
       return false;
    }
    
    if(!ghostMode)
      return false;
      
    else
    {
      if(millis() - ghostModeStartTime < ghostModeDuration)
      {
        //Draw in the ghost timer
        float timeElapsed = millis() - ghostModeStartTime;
        float timeLeft = (ghostModeDuration - timeElapsed)/1000;
        fill(color(255));
        textAlign(CENTER, CENTER);
        text(timeLeft,width/2, 75);
        return true;
      }
      else
      {
        println("Ghost mode timed out");
        backgroundColor = color(0);      //Restore black background color
        ghostMode = false;
        return false;
      }
    }
    
  }
  
  //Returns score after activating opponent scramble, passing in the player's current score
  public int ActivateOpponentScramble(int currentScore)
  {
    if(currentScore >= opponentScrambleCost)
    {
      opponentScramble = true;
      println("Activated scramble mode");
      scrambleStartTime = millis();
      return currentScore - opponentScrambleCost;
    }
    else
    {
      return currentScore;
    }
  }
  
  //Returns true/false if scramble mode is still active based on the mode duration and timer
  public boolean IsScrambleModeActive()
  {
    if(!opponentScramble)
      return false;
    else
    {
      if(millis() - scrambleStartTime < scrambleDuration)
      {
        return true;
      }
      else
      {
        println("Scramble mode timed out");
        opponentScramble = false;
        return false;
      }
    }
    
  }
  
  //Returns score after activating target randomizer, passing in the player's current score
  public int ActivateTargetRandomizer(int currentScore)
  {
    if(currentScore >= targetRandomizerCost)
    {
      targetRandomizer = true;
      println("Activated target randomizer");
      return currentScore - targetRandomizerCost;
    }
    else
    {
      return currentScore;
    }
  }
  
  //Returns true/false if scramble mode is still active based on the mode duration and timer
  public boolean IsTargetRandomizerActive()
  {
    //Reading this is a destructive operation, i.e. the randomizer only occurs once; flip the bit
    if(targetRandomizer)
    {
      targetRandomizer = false;      
      return true;
    }
    else
      return false;
  }
  
}

//Checks what powerups are active for player 1 & 2 in the above powerup class
void CheckActivePowerups()
{
  //TODO separate check from counter
  p1powerup.IsGhostModeActive();
  p2powerup.IsGhostModeActive(); 
  
  if(p1powerup.IsScrambleModeActive())
  {
    //Player 1 activated the scrambler -- scramble player 2's color objective
    if(colorUpdateCounter % colorUpdateInterval == 0)
    {
      colorObj2 = getNewColor();
    }
  }
  
  if(p2powerup.IsScrambleModeActive())
  {
    //Player 2 activated the scrambler -- scramble player 1's color objective
    if(colorUpdateCounter % colorUpdateInterval == 0)
    {
      colorObj1 = getNewColor();
    }
  }
  
  if(p1powerup.IsTargetRandomizerActive())
  {
    //Player 1 has requested a new random color
    colorObj1 = getNewColor();
  }
  
  if(p2powerup.IsTargetRandomizerActive())
  {
    //Player 2 has requested a new random color
    colorObj2 = getNewColor();
  }
}
