PFont standardFont =  createFont("Helvetica", 14);    // font name and size

public class UI extends Drawable
{
  PFont font;
  int fontSize;
  protected color textColor;      //Used by inhereted classes only
  
  boolean visibleNow;      //Is this part of the UI being rendered right now?
  boolean scalesWithZoom;
  
  public UI(String _name, PVector _loc, PVector _size, boolean _scalesWithZoom)
  {
    super(_name, _loc, _size, DrawableType.UI);
    scalesWithZoom = _scalesWithZoom;
    
    font = standardFont;      //Use pre-generated font from above
    fontSize = 14;
    visibleNow = false;
  }
  
  public UI(String _name, PVector _loc, PVector _size, int _fontSize, boolean _scalesWithZoom)
  {
    super(_name, _loc, _size, DrawableType.UI);
    scalesWithZoom = _scalesWithZoom;
    
    fontSize = _fontSize;
    font = createFont("Helvetica", fontSize);
    visibleNow = false;
  }
  
  //Update the absolute coordinates of this UI
  public void UpdateLocation(PVector _newlocation)
  {
    location = _newlocation;
  }
}
