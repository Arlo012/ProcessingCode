//TODO implement all the other ship sprites....
PImage shipSprite;      //Loaded in setup()

/**
 * An asteroid gameobject, inheriting from Drawable
 */
public class Ship extends Pilotable implements Clickable, Updatable
{
  TextWindow info;
  
  /*
   * Constructor
   * @param  _xloc    x coordinate of the ship
   * @param  _yloc    y coordinate of the ship
   * @param  _xdim    x size of this ship
   * @param  _ydim    y size of this ship
   * @param  _sprite  sprite of this ship
   * @see         Asteroid
   */
  public Ship(String _name, PVector _loc, PVector _size, PImage _sprite, int _mass) 
  {
    //Parent constructor
    super(_name, _loc, _size, _mass, DrawableType.SHIP);
    
    sprite = _sprite;
    sprite.resize(int(size.x), int(size.y));
    
    String descriptor = new String();
    descriptor += name;
    descriptor += "\nVelocity: ";
    descriptor += velocity.mag();
    descriptor += " m/s ";
    info = new TextWindow("Asteroid Info", location, descriptor);
  }
  
  //HACK this update() function is highly repeated through child classes
  public void Update()
  {
    //Check if UI is currently rendered, and if so update info
    if(info.visibleNow)
    {
      UpdateUIInfo();
    }
    //Assume UI will not be rendered next frame
    info.visibleNow = false;    //Another mouseover/ click will negate this
    
    //Update icon overlay
    iconOverlay.UpdateLocation(location);
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
    info.UpdateLocation(location);
    
    String descriptor = new String();
    descriptor += name;
    descriptor += "\nVelocity: ";
    descriptor += velocity.mag();
    descriptor += " m/s ";

    info.UpdateText(descriptor);
  }

}
