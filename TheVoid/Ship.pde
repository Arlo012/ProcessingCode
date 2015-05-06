//TODO implement all the other ship sprites....
PImage shipSprite;      //Loaded in setup()

/**
 * A ship gameobject, inheriting from Pilotable. Expensive purchase cost, but great at shooting 
 * down enemy missiles.
 */
public class Ship extends Physical implements Clickable, Updatable
{
  TextWindow info;
  
  //Damage effects
  PVector smoke1Loc, smoke2Loc;    //In local coordinats relative to ship's location
  Smoke smokeEffect1;
  Smoke smokeEffect2;
  boolean smoke1Visible, smoke2Visible;
  
  //Scanners
  protected int scanInterval = 500;         //ms between scans
  protected long lastScanTime;              //When last scan occured
  protected int sensorRange = 250;          //Units of pixels
  protected Shape scanRadius;               //Circle outline, when hovered over, shows sensor/weapons range
  
  //Weapons
  protected long lastFireTime;
  protected float minFireInterval = 850;          //ms between shots
  protected float currentFireInterval = minFireInterval;

  ArrayList<Physical> targets;    //Firing targets selected after scan
  
  //Shields
  Shield rightShield, leftShield, frontShield, backShield;
  ArrayList<Shield> shields;

  //Engines
  float minThrust, maxThrust;
  
  //Enemy objects
  ArrayList<Asteroid> allAsteroids;    //For tracking mobile asteroid toward this ship's base
  ArrayList<Missile> enemyMissiles;
  ArrayList<Ship> enemyShips;
  ArrayList<Station> enemyStations;
  
  public Ship(String _name, PVector _loc, PVector _size, PImage _sprite, int _mass, 
    color _outlineColor, Sector _sector) 
  {
    //Parent constructor
    super(_name, _loc, _size, _mass, _sector);
    sprite = _sprite.get(); 
    sprite.resize(int(size.x), int(size.y));

    //Setup health, scaled by size relative to max size
    //TODO implement this into constructor (it is redundantly over-written in many places)
    health.max = 200;      //Health scaled to size, take advantage of integer division to round
    health.current = health.max;
    
    //Set the overlay icon
    iconOverlay.SetIcon(_outlineColor,ShapeType._TRIANGLE_);
    
    //Prepare smoke damage effect
    smoke1Loc = new PVector(size.x * rand.nextFloat() - size.x/2, size.y * rand.nextFloat() - size.y/2);
    smoke2Loc = new PVector(size.x * rand.nextFloat() - size.x/2, size.y * rand.nextFloat() - size.y/2);
    smokeEffect1 = new Smoke(location, new PVector(10,10));      //Place at origin for time being, use smoke locations in update
    smokeEffect2 = new Smoke(location, new PVector(10,10));  
    smoke1Visible = false;
    smoke2Visible = false;
    
    //Shield setup
    rightShield = new Shield(this, 10000, ShieldDirection.RIGHT, this.currentSector);
    leftShield = new Shield(this, 10000, ShieldDirection.LEFT, this.currentSector);
    backShield = new Shield(this, 10000, ShieldDirection.BACK, this.currentSector);
    frontShield = new Shield(this, 10000, ShieldDirection.FORWARD, this.currentSector);

    shields = new ArrayList<Shield>();
    shields.add(rightShield);
    shields.add(leftShield);
    shields.add(frontShield);
    shields.add(backShield);

    //Only enable shields for player for now
    // rightShield.online = true;
    // backShield.online = true;
    // leftShield.online = true;
    // frontShield.online = true;

    //Prepare engines
    minThrust = 0.0;
    maxThrust = 10.0;

    //Prepare sensors
    scanRadius = new Shape("Scan radius", location, new PVector(sensorRange,sensorRange), 
                color(255,0,0), ShapeType._CIRCLE_);
    
    //Prepare laser
    targets = new ArrayList<Physical>();
    lastScanTime = 0;
    
    //Set the description string
    String descriptor = new String();
    descriptor += name;
    descriptor += "\nHealth: ";
    descriptor += health.current ;
    info = new TextWindow("Ship Info", location, descriptor, true);
    
  }
  
  @Override public void DrawObject()
  {
    super.DrawObject();

    if(rightShield.online)
    {
      rightShield.DrawObject();
    }
    if(leftShield.online)
    {
      leftShield.DrawObject();
    }
    if(frontShield.online)
    {
      frontShield.DrawObject();
    }
    if(backShield.online)
    {
      backShield.DrawObject();
    }
    
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
  
  /**
   * Set the sector this ship is currently in.
   * @param {Sector} _sector Sector object of current location
   */
  public void UpdateCurrentSector(Sector _sector)
  {
    currentSector = _sector;
  }

  @Override public void Update()
  {
    super.Update();    //Call Physical update (movement occurs here)
    
    //Shield info update
    frontShield.Update();
    backShield.Update();
    leftShield.Update();
    rightShield.Update();


  //**** UI ****//
    //Check if UI is currently rendered, and if so update info
    if(info.visibleNow)
    {
      UpdateUIInfo();
    }
    
    //Assume UI will not be rendered next frame
    info.visibleNow = false;    //Another mouseover/ click will negate this
    
    //Update icon overlay
    iconOverlay.UpdateLocation(location);


   //**** MOVEMENT *****//

   //**** HEALTH *****//
    //Check health effect thresholds
    if(health.current <= health.max/2)
    {
      smoke1Visible = true;
    }
    if(health.current <= health.max/4)
    {
      smoke2Visible = true;
    }
    
  //**** EFFECTS *****//
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
    
  //**** DEATH *****//
    //If the ship will die after this frame
    if(toBeKilled)
    {
      frontShield.toBeKilled = true;
      rightShield.toBeKilled = true;
      backShield.toBeKilled = true;
      frontShield.toBeKilled = true;
      GenerateDeathExplosions(3, location, size);
    }
  }

  /**
   * Calculates shoot vector and builds a laser object to fire.
   * Note that the laser object adds itself to the sector in its
   * constructor, and does not need explicit appending.
   * @param {PVector} _target Target to shoot at
   */
  protected void BuildLaserToTarget(PVector _target)     //Replaced 'Physical _target' to a 'PVector _target';
  {
    PVector targetVector = PVector.sub(_target,location);
    targetVector.normalize();
    // targetVector.x += rand.nextFloat() * 0.5 - 0.25;
    // targetVector.y += rand.nextFloat() * 0.5 - 0.25;
    
    //Create laser object
    PVector laserSpawn = new PVector(location.x + targetVector.x * size.x * 1.1, 
        location.y + targetVector.y * size.y * 1.1);
    LaserBeam beam = new LaserBeam(laserSpawn, targetVector, currentSector);
  }
    
  protected void BuildLaserToTarget(Physical _target)
  {
    //Calculate laser targeting vector
    PVector targetVector = PVector.sub(_target.location, location);
    targetVector.normalize();        //Normalize to simple direction vector
    targetVector.x += rand.nextFloat() * 0.5 - 0.25;
    targetVector.y += rand.nextFloat() * 0.5 - 0.25;
    
    //Create laser object
    PVector laserSpawn = new PVector(location.x + targetVector.x * size.x * 1.1, 
        location.y + targetVector.y * size.y * 1.1);
    LaserBeam beam = new LaserBeam(laserSpawn, targetVector, currentSector);
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
    println("[INFO] No interaction defined for ship click");
  }
  
  //When the object moves its UI elements must as well
  void UpdateUIInfo()
  {
    //Update textbox
    info.UpdateLocation(location);
    
    //Set the description string
    String descriptor = new String();
    descriptor += name;
    descriptor += "\nHealth: ";
    descriptor += health.current;
    
    info.UpdateText(descriptor);
  }

}
