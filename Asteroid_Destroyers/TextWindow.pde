class TextWindow extends UI
{  
  String textData = "";
  color background;
  color textColor;
  int textRenderMode;          //Render as center or corner
  
  ArrayList<Drawable> icons;  //Icons within the window
  
  //TODO this constructor might be evil
  TextWindow(String _name, PVector _loc, String _text)
  {
    super(_name, _loc, new PVector(200, 100));      //Default size 200 by 100
    textData = _text;
    
    background = color(0,0,65,200);
    textColor = color(255);
    textRenderMode = CORNER;
    
    icons = new ArrayList<Drawable>();
  }
  
  TextWindow(String _name, PVector _loc, PVector _size, String _text)
  {
    super(_name, _loc, _size);      //Non-standard window size
    textData = _text;
    
    background = color(0,0,65,200);
    textColor = color(255);
    textRenderMode = CORNER;
    
    icons = new ArrayList<Drawable>();
  }
  
  TextWindow(String _name, PVector _loc, PVector _size, String _text, int _fontSize)
  {
    super(_name, _loc, _size);      //Non-standard window size
    textData = _text;
    fontSize = _fontSize;    //Non-standard font size
    
    background = color(0,0,65,200);
    textColor = color(255);
    textRenderMode = CORNER;
    
    icons = new ArrayList<Drawable>();
  }
  
  @Override public void DrawObject()
  {
    pushMatrix();
    translate(location.x, location.y);
    
    //BACKGROUND
    rectMode(CORNER);
    fill(background);
    rect(0, 0, size.x, size.y);
    
    //TEXT
    fill(textColor);
    if(textRenderMode == CENTER)
    {
      translate(size.x/2,0);    //Shift by half text box size (fake center rendering)
    }
    
    textAlign(textRenderMode,TOP);
    text(textData, 10, 10);
    
    //Icon
    if(icons.size() > 0)
    {
      for(Drawable img : icons)
      {
        img.DrawObject();
      }
    }
    
    popMatrix();
  }
  
  public void AddIcon(PVector _loc, PVector _size, PImage _img)
  {
    Drawable icon = new Drawable("Civ icon", _loc, _size, DrawableType.UI);
    icon.sprite = _img;
    icons.add(icon);
  }
  
  public void UpdateText(String _newText)
  {
    textData = _newText;
  }
  
  public void SetBackgroundColor(color _background)
  {
    background = _background;
  }
  
  public void SetTextColor(color _textColor)
  {
    textColor = _textColor;
  }
  
  public void SetTextRenderMode(int _mode)
  {
    if(_mode == CENTER || _mode == CORNER)
    {
      textRenderMode = _mode;
    }
    else
    {
      print("WARNING: tried to set text render mode on TextWindow ID=");
      print(ID);
      print(" to an invalid value (not corner or center).\n");
    }
    
  }
}
