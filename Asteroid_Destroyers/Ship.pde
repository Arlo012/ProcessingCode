//TODO implement all the other ship sprites....
PImage shipSprite;      //Loaded in setup()

/**
 * A ship gameobject, inheriting from Pilotable
 */
public class Ship extends Pilotable implements Clickable, Updatable
{
  TextWindow info;
  
  public Ship(String _name, PVector _loc, PVector _size, PImage _sprite, int _mass) 
  {
    //Parent constructor
    super(_name, _loc, _size, _mass, DrawableType.SHIP);
    
    sprite = _sprite;
    sprite.resize(int(size.x), int(size.y));
    
    //Set the overlay icon
    iconOverlay.SetIcon(color(0,0,255),ShapeType._TRIANGLE_);
    
    //Set the description string
    String descriptor = new String();
    descriptor += name;
    descriptor += "\nVelocity: ";
    descriptor += velocity.mag();
    descriptor += " m/s ";
    info = new TextWindow("Ship Info", location, descriptor, true);
  }
  
  //HACK this update() function is highly repeated through child classes
  public void Update()
  {
    super.Update();    //Call physical update
    
    //Check if UI is currently rendered, and if so update info
    if(info.visibleNow)
    {
      UpdateUIInfo();
    }
    //Assume UI will not be rendered next frame
    info.visibleNow = false;    //Another mouseover/ click will negate this
    
    //Update icon overlay
    iconOverlay.UpdateLocation(location);
    
    //If all stop override, don't move
    if(allStopOrder.value)
    {
      currentOrder = null;
      destination = location;
      orders.clear();
      AllStop();
      allStopOrder.Toggle();
    }
  }

/*Click & mouseover UI*/
  ClickType GetClickType()
  {
    return ClickType.INFO;
  }
  
  //Handle click actions on this object
  void MouseOver()
  {
    info.visibleNow = true;
    info.DrawObject();
  }
  
  void Click()
  {
    
  }
  
  //When the object moves its UI elements must as well
  void UpdateUIInfo()
  {
    //Update textbox
    info.UpdateLocation(new PVector(wvd.pixel2worldX(location.x), wvd.pixel2worldY(location.y)));
    
    String descriptor = new String();
    descriptor += name;
    descriptor += "\nVelocity: ";
    descriptor += velocity.mag();
    descriptor += " m/s ";

    info.UpdateText(descriptor);
  }

}
