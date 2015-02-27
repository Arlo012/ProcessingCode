//Each sprite spaced 128 pixels apart
PImage asteroidSpriteSheet;      //Loaded in setup()

/*
 * An asteroid gameobject, inheriting from Drawable
 */
public class Asteroid extends Physical implements Clickable
{
  TextWindow info;
  
  /*
   * Constructor
   * @param  _size  diameter of the asteroid
   * @param  _xloc  x coordinate of the asteroid
   * @param  _yloc  y coordinate of the asteroid
   * @see         Asteroid
   */
  public Asteroid(PVector _loc, int _diameter, int _mass) 
  {
    //Parent constructor
    super(_loc, new PVector(_diameter, _diameter), _mass, DrawableType.ASTEROID);
    
    //Select my asteroid image from spritesheet     
    int RandomAsteroidIndex1 = rand.nextInt(9);      //x coordinate in sprite sheet
    int RandomAsteroidIndex2 = rand.nextInt(9);      //y coordinate in sprite sheet

    //Set the sprite to the random subset of the spritesheet
    sprite = asteroidSpriteSheet.get(RandomAsteroidIndex1 * 128, RandomAsteroidIndex2 * 128, 128, 128);
    
    //Scale by 128/90 where 128 is provided size above and 90 is actual size of the asteroid sprite
    sprite.resize(int(size.x * 128/90), int(size.y * 128/90));
    
    String descriptor = new String();
    descriptor += "This is an asteroid.\n Diameter: ";
    descriptor += size.x;
    descriptor += " m \n Mass: ";
    descriptor += mass;
    descriptor += " kg\n";
    descriptor += "Velocity: ";
    descriptor += velocity.mag();
    descriptor += " m/s ";
    info = new TextWindow(location, descriptor);
  }

  @Override public void DrawObject()
  {
    super.DrawObject();
    
    //Check if UI is currently rendered, and if so update info
    if(info.visibleNow)
    {
      UpdateUIInfo();
    }
    //Assume UI will not be rendered next frame
    info.visibleNow = false;    //Another mouseover/ click will negate this
  }


/*Click & mouseover UI*/
  ClickType GetClickType()
  {
    return ClickType.INFO;
  }
  
  void Click()
  {
    info.visibleNow = true;
    info.DrawObject();
  }
  
  //When the object moves this must move as well
  void UpdateUIInfo()
  {
    info.UpdateLocation(location);
    
    String descriptor = new String();
    descriptor += "This is an asteroid.\nDiameter: ";
    descriptor += size.x;
    descriptor += " m \nMass: ";
    descriptor += mass;
    descriptor += " kg\n";
    descriptor += "Velocity: ";
    descriptor += velocity.mag();
    descriptor += " m/s ";

    info.UpdateText(descriptor);
  }
  

}
