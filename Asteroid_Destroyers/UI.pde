PFont standardFont =  createFont("Helvetica", 14);    // font name and size

/*
public enum UItype {
}*/

public class UI extends Drawable
{
  PFont font;
  int fontSize;
  
  boolean visibleNow;      //Is this part of the UI being rendered right now?
  
  public UI(PVector _loc, PVector _size)
  {
    super(_loc, _size, DrawableType.UI);
    
    font = standardFont;
    textFont(font, 14);    //Standard font and size for drawing fonts
    visibleNow = false;
  }
  
  public UI(PVector _loc, PVector _size, PFont _font, int _fontSize)
  {
    super(_loc, _size, DrawableType.UI);
    
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
