//TODO implement all the other ship sprites....
PImage shipSprite;      //Loaded in setup()

/**
 * A ship gameobject, inheriting from Pilotable. Expensive purchase cost, but great at shooting 
 * down enemy missiles.
 */
public class Ship extends Physical implements Clickable, Updatable
{
  TextWindow info;

  //Location information
  Sector currentSector;
  
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
  Shield shield;

  //Engines
  float leftEnginePower, rightEnginePower;
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
    super(_name, _loc, _size, _mass);
    sprite = _sprite.get(); 
    sprite.resize(int(size.x), int(size.y));

    currentSector = _sector;

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
    
    //Prepare engines
    leftEnginePower = 0;
    rightEnginePower = 0;
    minThrust = 0.0;
    maxThrust = 10.0;

    //Prepare shields
    shield = new Shield(this, 250);
    
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
    descriptor += "\nShield: ";
    descriptor += shield.health.current ;
    info = new TextWindow("Ship Info", location, descriptor, true);
    
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
      shield.toBeKilled = true;
      GenerateDeathExplosions(3, location, size);
    }
  }

   /*
  SPIN: 
  Creates two 'spin' vectors for each of the two engines.
  The vectors are both perpendicular to the Velocity vector and face opposite directions from one another
  They are scaled based on the engines power and then summed to each other and passed as a steering force to be summed to the acceleration vector
  */
  PVector Spin()
  {
    PVector spinLeftEngine = new PVector(1,0);
    PVector spinRightEngine = new PVector(1,0);
   
    spinLeftEngine.rotate(velocity.heading() + HALF_PI);    //left engine vector set perdendicular to Velocity facing left.
    spinRightEngine.rotate(velocity.heading() - HALF_PI);   //right engine vector set perpendiuclar to Velocity facing right.
    spinLeftEngine.setMag(leftEnginePower);                 //Set magnitudes to Engines power ranging 0-10
    spinRightEngine.setMag(rightEnginePower);
    PVector spinSum = PVector.add(spinRightEngine, spinLeftEngine);  //Sum the apposing facing spin vectors
    
    PVector desired = PVector.add(spinSum, velocity);                // Sum 'spin' vector with velocity go get a desired direction
    desired.normalize();
    desired.mult(localSpeedLimit);                                   // Scale based on Maximum Player Speed
    PVector steer = PVector.sub(desired, velocity);
    steer.x = map(steer.x, 0,7.66, 0,.5);                            // 7.66 was max value seen when debugging---- .5 seems reasonable for max spin
    steer.y = map(steer.y, 0,7.66, 0,.5);
    //steer.limit(maxForceMagnitude);
    println("Spin: "+steer.mag());
    println("Velocity Mag: "+velocity.mag());
    return steer;                                                    // Pass Vector to be applied to ship
  }

  //FIXME not working
  PVector Thrust()
  {
    PVector thrust = new PVector(1,0);
    thrust.rotate(velocity.heading());
    float thrustPower = (leftEnginePower/maxThrust)+(rightEnginePower/maxThrust);
    println("Left: "+leftEnginePower);
    println("Right: "+rightEnginePower);
    println("Thrust BEFORE: "+thrustPower);
    thrustPower = map(thrustPower, 0, 2, 0, maxForceMagnitude);
    println("Thrust AFTER: "+thrustPower);
    thrust.setMag(thrustPower);

    return thrust;
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
    println("INFO: No interaction defined for ship click");
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
    descriptor += "\nShield: ";
    descriptor += shield.health.current ;
    
    info.UpdateText(descriptor);
  }

}
