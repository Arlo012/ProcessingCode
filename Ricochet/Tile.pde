/*
Tile class helper to organize the tiles in the center of the board. 
Tiles contain a coordinate, size, color, and an effect on ball speed/ direction
*/
public class Tile
{
  public coordinate location;
  public int size;
  public color myColor;
  public boolean isPowerup = false;
  
  private color alternateColor = color(255,255,255);
  
  public Tile(int x, int y, int setSize)
  {
    location = new coordinate(x, y);
    size = setSize;
    
    updateColor();
  }
  
  //On death, what speed modifier does this have on the ball?
  public float GetSpeedModifier()
  {
    float speedMod = random(-1,1);
    return speedMod;
  }
  
  //Update color to random choice of presets, or create powerup
  public void updateColor()
  {
    float powerupCheck = random(0,1);
    if(powerupCheck <= powerupFrequency)
    {
      isPowerup = true;
    }
    myColor = getNewColor();
  }
  
  //Alternate colors
  public void flash()
  {
    if(myColor != color(255,255,255) )
    {
      //We are the standard color -- flip to white
      alternateColor = myColor;
      myColor = color(255,255,255);
    }
    else
    {
      //We are white, flip back to standard color
      myColor = alternateColor;    //restore original color
      alternateColor = color(255,255,255);
    }
  }
}
