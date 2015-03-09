PImage missileSprite;      //Loaded in setup()

/**
 * A missile gameobject, inheriting from Pilotable
 */
public class Missile extends Pilotable implements Clickable, Updatable
{
  TextWindow info;
  int damage = 40;        //How much damage this missile does when it hits something

  Missile(PVector _loc, PVector _moveVector) 
  {
    //Parent constructor
    super("Missile", _loc, new PVector(20,10), 10, DrawableType.MISSILE);    //mass = 10
    
    //Physics
    velocity = _moveVector;
    rotationRate = 0.1;          //Rotation rate on a missile is ~10x better than a ship
    
    //UI
    sprite = missileSprite;
    sprite.resize(int(size.x), int(size.y));
    
    //Set the overlay icon
    iconOverlay.SetIcon(color(255,0,0),ShapeType._SQUARE_);
    
    String descriptor = new String();
    descriptor += name;
    descriptor += "\nVelocity: ";
    descriptor += velocity.mag();
    descriptor += " m/s ";
    info = new TextWindow("Missile Info", location, descriptor, true);
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
  
  @Override public void HandleCollision(Physical _other)
  {
    Effect explosion = new Effect("Explosion", location, new PVector(64,48), EffectType.EXPLOSION);    //New explosion here
    effects.add(explosion);      //Add to list of effects to render
    
    _other.health.current -= damage;
    
    //TODO implement explosion throwback    
    
    toBeKilled = true;
  }

}
