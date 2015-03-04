//Define an area of gameplay, e.g. an asteroid field inheriting from Drawable
public class GameArea extends Drawable
{
  private String areaName;
  private color debugViewColor;
  /*
  * Constructor
  * @param  _areaName string name of this game area
  * @param  _ceterX  x location coordinate of the game area
  * @param  _cetery  y location coordinate of the game area
  * @param  _width   width of this game area, in pixels
  * @param  _height  height of this game area, in pixels
  * @see         GameArea
  */
  public GameArea(String _areaName, PVector _loc, PVector _size)
  {
    super(_loc, _size, DrawableType.GAMEAREA);
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
  
  //Override drawable for center draw
  @Override public void DrawObject()
  {
    rectMode(CORNER);
    fill(debugViewColor, 50);
    rect(location.x, location.y, size.x, size.y);
  }
}
