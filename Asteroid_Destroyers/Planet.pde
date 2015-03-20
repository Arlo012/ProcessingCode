/*
 * A planet gameobject, inheriting from Drawable
 */
public class Planet extends Physical implements Clickable, Updatable
{
  TextWindow info;
  String[] planetDescriptions = {"Lifeless Planet", "Ocean Planet", "Lava Planet", "Crystalline Planet",
                                "Desert Planet", "Swamp Planet", "Class-M Planet", "Lifeless Planet",
                                "Class-M Planet", "Ionically Charged Planet", "Forest Planet", "Scorched Planet"};
  
  int planetTypeIndex;
  /*
   * Constructor
   * @param  _size  diameter of the asteroid
   * @param  _xloc  x coordinate of the asteroid
   * @param  _yloc  y coordinate of the asteroid
   * @see         Asteroid
   */
  public Planet(String _name, PVector _loc, int _diameter, int _mass, Civilization _owner) 
  {
    //Parent constructor
    super(_name, _loc, new PVector(_diameter, _diameter), _mass, DrawableType.PLANET, _owner);
    
    //Select my planet image from spritesheet (total of 10 options)
    planetTypeIndex = rand.nextInt(11) + 1;    //There is no p0, add 1
    
    //Create filesystem path to sprite
    String filePath = "";
    filePath += "Assets/Planets/p";
    filePath += planetTypeIndex;
    filePath += "shaded.png";

    //Set the sprite to the random subset of the spritesheet
    sprite = loadImage(filePath);
    sprite.resize((int)size.x, (int)size.y);
    
    //Set string descriptor for real-ish values that look pretty
    String descriptor = new String();
    descriptor += planetDescriptions[planetTypeIndex-1];
    descriptor += "\nDiameter: ";
    descriptor += (float)size.x*150;
    descriptor += " km \nMass: ";
    descriptor += mass/10;
    descriptor += "E23 kg\n";
    info = new TextWindow("Planet info", location, descriptor, true);
  }

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
  }

/*Click & mouseover UI*/
  ClickType GetClickType()
  {
    return ClickType.INFO;
  }
  
  void MouseOver()
  {
    info.visibleNow = true;
    info.DrawObject();
  }
  
  void Click()
  {
    
  }
  
  //When the object moves this must move as well
  void UpdateUIInfo()
  {
    info.UpdateLocation(location);
    
    String descriptor = planetDescriptions[planetTypeIndex-1];
    descriptor += "\nDiameter: ";
    descriptor += (float)size.x*150;
    descriptor += " km \nMass: ";
    descriptor += mass/10;
    descriptor += "E23 kg\n";

    info.UpdateText(descriptor);
  }
  

}
