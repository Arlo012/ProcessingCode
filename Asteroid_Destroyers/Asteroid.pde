//Each sprite spaced 128 pixels apart
PImage asteroidSpriteSheet;      //Loaded in setup()

/*
 * An asteroid gameobject, inheriting from Drawable
 */
public class Asteroid extends Physical implements Clickable, Updatable
{
  private static final int minDiameter = 10;
  private static final int maxDiameter = 20;
  private static final int maxAsteroidHealth = 100;
  
  TextWindow info;
  public boolean isOffScreen = false;      //Is this asteroid offscreen?
  public boolean isRogue;                  //Asteroid's course has been altered by an impact / explosion
  
  private boolean isDebris = false;        //Is this asteroid just debris from another asteroid's death?
  
  /*
   * Constructor
   * @param  _size  diameter of the asteroid
   * @param  _xloc  x coordinate of the asteroid
   * @param  _yloc  y coordinate of the asteroid
   * @see         Asteroid
   */
  public Asteroid(String _name, PVector _loc, int _diameter, int _mass) 
  {
    //Parent constructor
    super(_name, _loc, new PVector(_diameter, _diameter), _mass, DrawableType.ASTEROID, null);
    
    //Select my asteroid image from spritesheet     
    int RandomAsteroidIndex1 = rand.nextInt(8);      //x coordinate in sprite sheet
    int RandomAsteroidIndex2 = rand.nextInt(8);      //y coordinate in sprite sheet

    //Set the sprite to the random subset of the spritesheet
    sprite = asteroidSpriteSheet.get(RandomAsteroidIndex1 * 128, RandomAsteroidIndex2 * 128, 128, 128);
    
    //Scale by 128/90 where 128 is provided size above and 90 is actual size of the asteroid sprite
    sprite.resize(int(size.x * 128/90), int(size.y * 128/90));
    
    //Setup health, scaled by size relative to max size
    //TODO implement this into constructor (it is redundantly over-written in many places)
    health.max = (int)(size.x/maxDiameter * maxAsteroidHealth);      //Health scaled to size, take advantage of integer division to round
    health.current = health.max;
    
    //Setup string (only displayed once, e.g. in instructions
    String descriptor = new String();
    descriptor += name;
    descriptor += "\nFast-flying objects that\n";
    descriptor += "wreak havoc on impact.\n";
    descriptor += "They break into pieces\n";
    descriptor += "when destroyed!";
    info = new TextWindow("Asteroid Info", location, descriptor, true);
  }
  
  @Override public void Update()
  {
    super.Update();
    
    //Check if UI is currently rendered, and if so update info
    if(info.visibleNow)
    {
      UpdateUIInfo();
    }
    //Assume UI will not be rendered next frame
    info.visibleNow = false;    //Another mouseover/ click will negate this
    
    //Update icon overlay
    iconOverlay.UpdateLocation(location);
    
    if(toBeKilled && !isDebris)    //Generate debris asteroids iff dying and not already debris
    {
      for(int i = 0; i < 3; i++)
      {
        Asteroid debris = new Asteroid("Asteroid Debris", location, (int)size.x/2, (int)(mass/2));
        
        //New velocity with some randomness based on old velocity
        debris.SetVelocity(new PVector(velocity.x/2 + rand.nextFloat()*velocity.x/3-velocity.x/6,
                               velocity.y/2 + rand.nextFloat()*velocity.y/3-velocity.y/6));
        debris.isDebris = true;
        
        //See AsteroidFactory for details on this implementation
        debris.SetRotationRate(rotationRate);
        debris.SetRotationMode(RotationMode.SPIN);    //Spinning
        debris.SetMaxSpeed(2.5);      //Local speed limit for asteroid
        debris.iconOverlay.SetIcon(color(255,0,0),ShapeType._CIRCLE_);
        debris.drawOverlay = true;      //Dont draw overlay by default
        
        //Setup health, scaled by size relative to max size. 1/4 health of std asteroid
        //HACK this just overwrites the constructor
        debris.health.max = (int)(debris.size.x/maxDiameter * maxAsteroidHealth)/8;
        debris.health.current = health.max;
        
        debris.isRogue = true;      //Bit flag to allow enemy ships to scan for this asteroid
        
        debrisSpawned.add(debris);
      }
    }
  }

  @Override public void DrawObject()
  {
    super.DrawObject();
    
    //Check if I am offscreen
    if(location.y < -size.x - 200 || location.y > height + size.x + 200 || 
       location.x < -size.x || location.x > width + size.x)
    {
      isOffScreen = true;      //Mark for removal
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
    println("INFO: No interaction defined for asteroid click");
  }
  
  //When the object moves this must move as well
  void UpdateUIInfo()
  {
    info.UpdateLocation(location);
    
    String descriptor = new String();
    descriptor += name;
    descriptor += " #";
    descriptor += ID;
    descriptor += "\nDiameter: ";
    descriptor += size.x;
    descriptor += " m \nMass: ";
    descriptor += mass;
    descriptor += " kg\nHealth:";
    descriptor += health.current;
    descriptor += "\nVelocity: ";
    descriptor += (int)(velocity.mag()*100);
    descriptor += " m/s ";

    info.UpdateText(descriptor);
  }
  

}
