public class Button extends UI implements Clickable
{
  String text;
  TogglableBoolean varToToggle;      //What to toggle if button is pushed
  
  Button(String _name, PVector _loc, PVector _size, String _text, 
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
  
   
  @Override public void DrawObject()
  {
    pushMatrix();
    pushStyle();
    translate(location.x, location.y);
    
    imageMode(renderMode);
    image(sprite, 0, 0);
    
    textAlign(CENTER,CENTER);
    fill(0);
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
    if(varToToggle != null)
    {
      varToToggle.value = !varToToggle.value;
      if(debugMode.value)
      {
        print("INFO: Clicked ");
        print(name);
        print("\n");
      }
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
