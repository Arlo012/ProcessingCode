PFont standardFont =  createFont("Helvetica", 14);    // font name and size

public class UI extends Drawable
{
  PFont font;
  int fontSize;
  
  boolean visibleNow;      //Is this part of the UI being rendered right now?
  
  public UI(String _name, PVector _loc, PVector _size)
  {
    super(_name, _loc, _size, DrawableType.UI);
    
    font = standardFont;
    textFont(font, 14);    //Standard font and size for drawing fonts
    visibleNow = false;
  }
  
  public UI(String _name, PVector _loc, PVector _size, PFont _font, int _fontSize)
  {
    super(_name, _loc, _size, DrawableType.UI);
    
    font = _font;
    textFont(font, _fontSize);
    visibleNow = false;
  }
  
  //Update the absolute coordinates of this UI
  public void UpdateLocation(PVector _newlocation)
  {
    location = _newlocation;
  }
}
