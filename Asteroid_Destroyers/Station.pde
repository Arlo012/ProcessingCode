PImage redStation1, redStation2, redStation3;
PImage blueStation1, blueStation2, blueStation3;

enum StationType {
  MILITARY, ENERGY
}

public class Station extends Physical implements Clickable, Updatable
{
  TextWindow info;
  
  //TODO: not implemented
  private PVector orbitForward;      //Forward vector for obiting (true rotation, independent of 
  
  //Station INFO
  int stationLevel = 1;        //For updating sprites
  StationType stationType;
  
  public Station(StationType _type, PVector _loc, PVector _size, PImage _sprite, Physical _orbitBody) 
  {
    super("Station", _loc, _size, 10000, DrawableType.STRUCTURE);
    stationType = _type;
    if(stationType == StationType.MILITARY)
    {
      name = "Military Station";
    }
    else if(stationType == StationType.ENERGY)
    {
      name = "Energy Station";
    }
    
    sprite = _sprite;
    sprite.resize((int)size.x, (int)size.y);
    
    //Get magnitude of the distance between the orbit body and this object and set as orbit distance
    PVector orbitTemp = new PVector(0,0);
    PVector.sub(_orbitBody.location,location,orbitTemp);
    orbitDistance = (int)orbitTemp.mag();
    
    rotationMode = RotationMode.SPIN;    //Station spins in orbit
    
    SetOrbitalMode(MoveMode.ORBITAL, _orbitBody);  //Set station rotating
    
    //Set the description string
    String descriptor = new String();
    descriptor += name;
    descriptor += "\n";
    descriptor += owner;
    descriptor += "\nHealth: ";
    descriptor += health.current;
    info = new TextWindow("Station Info", location, descriptor, true);
  }
  
/*Click & mouseover UI*/
  ClickType GetClickType()
  {
    return ClickType.INFO;
  }
  
  public void Click()
  {
    println("INFO: No interaction defined for station click");
  }
  
  public void MouseOver()
  {
    info.visibleNow = true;
    info.DrawObject();
  }
  
  public void UpdateUIInfo()
  {
    //Update textbox
    info.UpdateLocation(location);
    
    //Set the description string
    String descriptor = new String();
    descriptor += name;
    descriptor += "\n";
    descriptor += owner;
    descriptor += "\nHealth: ";
    descriptor += health.current;
    
    info.UpdateText(descriptor);
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
    
    //Update icon overlay
    iconOverlay.UpdateLocation(location);
    
    //If the ship will die after this frame
    if(toBeKilled)
    {
      GenerateDeathExplosions(5, location, size);
    }
  }
}
