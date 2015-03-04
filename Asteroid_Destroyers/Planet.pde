/*
 * A planet gameobject, inheriting from Drawable
 */
public class Planet extends Physical implements Clickable
{
  TextWindow info;
  
  /*
   * Constructor
   * @param  _size  diameter of the asteroid
   * @param  _xloc  x coordinate of the asteroid
   * @param  _yloc  y coordinate of the asteroid
   * @see         Asteroid
   */
  public Planet(String _name, PVector _loc, int _diameter, int _mass) 
  {
    //Parent constructor
    super(_name, _loc, new PVector(_diameter, _diameter), _mass, DrawableType.PLANET);
    
    //Select my planet image from spritesheet (total of 10 options)
    int RandomPlanetIndex = rand.nextInt(9) + 1;    //There is no p0, add 1
    
    //Create filesystem path to sprite
    String filePath = "";
    filePath += "Assets/Planets/p";
    filePath += RandomPlanetIndex;
    filePath += "shaded.png";

    //Set the sprite to the random subset of the spritesheet
    sprite = loadImage(filePath);
    sprite.resize((int)size.x, (int)size.y);
    
    String descriptor = new String();
    descriptor += "This is a planet.\n Diameter: ";
    descriptor += size.x;
    descriptor += " m \n Mass: ";
    descriptor += mass;
    descriptor += " kg\n";
    info = new TextWindow("Planet info", location, descriptor);
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
    descriptor += "This is a Planet.\nDiameter: ";
    descriptor += size.x;
    descriptor += " m \nMass: ";
    descriptor += mass;
    descriptor += " kg\n";

    info.UpdateText(descriptor);
  }
  

}
