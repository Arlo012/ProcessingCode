PImage redStation1, redStation2, redStation3;
PImage blueStation1, blueStation2, blueStation3;

enum StationType {
  MILITARY, ENERGY
}

public class Station extends Physical implements Clickable, Updatable
{
  TextWindow info;
  
  //Station INFO
  int stationLevel = 1;        //For updating sprites
  StationType stationType;
  
  //Station mass-energy generation
  int massEnergyGen;
  
  //Damage effects
  PVector smoke1Loc, smoke2Loc;    //In local coordinats relative to ship's location
  Smoke smokeEffect1;
  Smoke smokeEffect2;
  boolean smoke1Visible, smoke2Visible;
  
  public Station(StationType _type, PVector _loc, PVector _size, PImage _sprite) 
  {
    super("Station", _loc, _size, 10000, DrawableType.STRUCTURE);
    
    stationType = _type;
    if(stationType == StationType.MILITARY)
    {
      name = "Military Station";
    }
    else if(stationType == StationType.ENERGY)
    {
      //TODO phase me out, abandoning concept of energy stations
      name = "Energy Station";
    }
    
    sprite = _sprite.get();      //Use get() for a copy
    sprite.resize((int)size.x, (int)size.y);

    //Mass-energy generation proportional to size
    //HACK max size (60) is hard-coded here from the helper function; make a real variable
    massEnergyGen = (int)(10 * size.x/60);

    //Generate random rotation speed
    rotationMode = RotationMode.SPIN;    //Station spins in orbit
    SetRotationRate(.02 * rand.nextFloat() - .01);    //Generate random spinning value (-0.01, .01];
    
    //Prepare smoke damage effect
    smoke1Loc = new PVector(size.x * rand.nextFloat() - size.x/2, size.y * rand.nextFloat() - size.y/2);
    smoke2Loc = new PVector(size.x * rand.nextFloat() - size.x/2, size.y * rand.nextFloat() - size.y/2);
    smokeEffect1 = new Smoke(location, new PVector(10,10));      //Place at origin for time being, use smoke locations in update
    smokeEffect2 = new Smoke(location, new PVector(10,10));  
    smoke1Visible = false;
    smoke2Visible = false;
    
    //Set the description string
    String descriptor = new String();
    descriptor += name;
    descriptor += "\n";
    descriptor += owner;
    descriptor += "\nHealth: ";
    descriptor += health.current;
    descriptor += "\nGeneration/sec: ";
    descriptor += massEnergyGen;
    info = new TextWindow("Station Info", location, descriptor, true);
  }
  
  @Override public void DrawObject()
  {
    super.DrawObject();
    //Draw smoke effects
    if(smoke1Visible)
    {
      smokeEffect1.DrawObject();
    }
    if(smoke2Visible)
    {
      smokeEffect2.DrawObject();
    }
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
    descriptor += "\nGeneration/sec: ";
    descriptor += massEnergyGen;
    
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
    
    //Check health effect thresholds
    if(health.current <= health.max/2)
    {
      smoke1Visible = true;
    }
    if(health.current <= health.max/4)
    {
      smoke2Visible = true;
    }
    
    //Update smoke effect location
    if(smoke1Visible)
    {
      smokeEffect1.location = PVector.add(location,smoke1Loc);
      smokeEffect1.Update();
    }
    if(smoke2Visible)
    {
      smokeEffect2.location = PVector.add(location,smoke2Loc);
      smokeEffect2.Update();
    }
    
    //If the ship will die after this frame
    if(toBeKilled)
    {
      GenerateDeathExplosions(5, location, size);
    }
  }
}
