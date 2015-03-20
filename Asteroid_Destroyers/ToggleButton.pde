public class ToggleButton extends UI implements Clickable
{
  String text;
  TogglableBoolean varToToggle;      //What to toggle if button is pushed
  private SoundFile clickSound;              //To play if clicked
  
  ToggleButton(String _name, PVector _loc, PVector _size, String _text, 
                  String _fileName, TogglableBoolean _variable, boolean _scalesWithZoom)
  {
    super(_name, _loc, _size, _scalesWithZoom);
    String fileName = "Assets/UI/";
    fileName += _fileName;
    sprite = loadImage(fileName);
    sprite.resize((int)size.x, (int)size.y);
    
    visibleNow = true;
    text = _text;
    varToToggle = _variable;
  }
  
  public void SetClickSound(SoundFile _sound)
  {
    clickSound = _sound;
  }
  
  public void SetTextColor(color _color)
  {
    textColor = _color;
  }
  
   
  @Override public void DrawObject()
  {
    pushMatrix();
    pushStyle();
    translate(location.x, location.y);
    
    imageMode(renderMode);
    image(sprite, 0, 0);
    
    textAlign(CENTER,CENTER);
    fill(textColor);      //For font coloring
    text(text, 0, 0);
    popStyle();
    popMatrix();
  }
  
  
  //Set the render mode for this icon
  public void SetRenderMode(int _renderMode)
  {
    renderMode = _renderMode;
  }

  void UpdateUIInfo()
  {
  }
  
  ClickType GetClickType()
  {
    return ClickType.BUTTON;
  }
  
  void Click()
  {
    if(clickSound != null)
    {
      clickSound.play();
    }
    
    if(debugMode.value)
    {
      print("INFO: Clicked ");
      print(name);
      print("\n");
    }
    
    if(varToToggle != null)
    {
      varToToggle.value = !varToToggle.value;

    }
    else
    {
      println("INFO: Clicked button with no toggle set");
    }

  }
  
  void MouseOver()
  {
  }
}
