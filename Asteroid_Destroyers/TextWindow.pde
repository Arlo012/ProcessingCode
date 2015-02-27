class TextWindow extends UI
{  
  String text;
  color background;
  color textColor;
  
  ArrayList<Drawable> icons;
  
  TextWindow(PVector _loc, String _text)
  {
    super(_loc, new PVector(200, 100));      //Default size 200 by 100
    text = _text;
    
    background = color(0,0,65,200);
    textColor = color(255);
  }
  
  TextWindow(PVector _loc, PVector _size, String _text)
  {
    super(_loc, _size);      //Non-standard window size
    text = _text;
    
    background = color(0,0,65,200);
    textColor = color(255);
  }
  
  @Override public void DrawObject()
  {
    
    pushMatrix();
    translate(location.x, location.y);
    
    rectMode(CORNER);
    fill(background);
    rect(0, 0, size.x, size.y);
    
    fill(textColor);
    textAlign(LEFT,TOP);
    text(text, 10, 10);
    
    popMatrix();
  }
  
  public void AddIcon(PVector _loc, PVector _size, PImage _img)
  {
    Drawable icon = new Drawable(_loc, _size, DrawableType.UI);
    icons.add(icon);
  }
  
  public void UpdateText(String _newText)
  {
    text = _newText;
  }
  
  public void SetBackgroundColor(color _background)
  {
    background = _background;
  }
  
  public void SetTextColor(color _textColor)
  {
    textColor = _textColor;
  }
}
