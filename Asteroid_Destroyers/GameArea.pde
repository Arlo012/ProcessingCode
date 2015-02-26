//Define an area of gameplay, e.g. an asteroid field inheriting from Drawable
public class GameArea extends Drawable
{
  private String areaName;
  private color debugViewColor;
  /*
  * Constructor
  * @param  _areaName string name of this game area
  * @param  _ceterX  x center coordinate of the game area
  * @param  _cetery  y center coordinate of the game area
  * @param  _width   width of this game area, in pixels
  * @param  _height  height of this game area, in pixels
  * @see         GameArea
  */
  public GameArea(String _areaName, int _centerX, int _centerY, int _width, int _height)
  {
    super(_centerX, _centerY, _width, _height);
    areaName = _areaName;
    debugViewColor = color(255);    //Default = white
  }
  
  public String GetAreaName()
  {
    return areaName;
  }
  
  public void SetDebugColor(color _color)
  {
    debugViewColor = _color;
  }
  
  //Override drawable
  
  @Override public void DrawObject()
  {
    rectMode(CENTER);
    fill(debugViewColor, 50);
    rect(center.x, center.y, size.x, size.y);
  }
}
