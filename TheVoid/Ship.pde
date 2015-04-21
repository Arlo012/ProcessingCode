//TODO implement all the other ship sprites....
PImage shipSprite;      //Loaded in setup()

/**
 * A ship gameobject, inheriting from Pilotable. Expensive purchase cost, but great at shooting 
 * down enemy missiles.
 */
public class Ship extends Pilotable implements Clickable, Updatable
{
  TextWindow info;
  
  //Damage effects
  PVector smoke1Loc, smoke2Loc;    //In local coordinats relative to ship's location
  Smoke smokeEffect1;
  Smoke smokeEffect2;
  boolean smoke1Visible, smoke2Visible;
  
  //Scanners
  int scanInterval = 500;         //ms between scans
  long lastScanTime;              //When last scan occured
  int sensorRange = 250;          //Units of pixels
  Shape scanRadius;               //Circle outline, when hovered over, shows sensor/weapons range
  
  //Weapons
  long lastFireTime;
  float fireInterval = 850;          //ms between shots
  ArrayList<Physical> targets;    //Firing targets selected after scan
  
  //Shields
  Shield shield;
  
  //Enemy objects
  ArrayList<Asteroid> allAsteroids;    //For tracking mobile asteroid toward this ship's base
  ArrayList<Missile> enemyMissiles;
  ArrayList<Ship> enemyShips;
  ArrayList<Station> enemyStations;
  
  public Ship(String _name, PVector _loc, PVector _size, PImage _sprite, int _mass, 
        color _outlineColor, Civilization _owner) 
  {
    //Parent constructor
    super(_name, _loc, _size, _mass, DrawableType.SHIP, _owner);
    sprite = _sprite.get(); 
    sprite.resize(int(size.x), int(size.y));

    //Setup health, scaled by size relative to max size
    //TODO implement this into constructor (it is redundantly over-written in many places)
    health.max = 200;      //Health scaled to size, take advantage of integer division to round
    health.current = health.max;
    
    //Rotation rate
    rotationRate = 0.05;
    
    //Set the overlay icon
    iconOverlay.SetIcon(_outlineColor,ShapeType._TRIANGLE_);
    
    //Prepare smoke damage effect
    smoke1Loc = new PVector(size.x * rand.nextFloat() - size.x/2, size.y * rand.nextFloat() - size.y/2);
    smoke2Loc = new PVector(size.x * rand.nextFloat() - size.x/2, size.y * rand.nextFloat() - size.y/2);
    smokeEffect1 = new Smoke(location, new PVector(10,10));      //Place at origin for time being, use smoke locations in update
    smokeEffect2 = new Smoke(location, new PVector(10,10));  
    smoke1Visible = false;
    smoke2Visible = false;
    
    //Prepare shields
    shield = new Shield(this, 250);
    GetOwner().shields.add(shield);
    
    //Prepare sensors
    scanRadius = new Shape("Scan radius", location, new PVector(sensorRange,sensorRange), 
                color(255,0,0), ShapeType._CIRCLE_);
    
    //Prepare laser
    targets = new ArrayList<Physical>();
    lastScanTime = 0;
    
    //Prepare enemy lists
    allAsteroids = asteroids;      //Asteroids is globally accessible; this is a convenience pointer
    if(GetOwner() == P1)
    {
      //Enemy is P2, build lists off of that
      enemyMissiles = P2.missiles;
      enemyShips = P2.fleet;
      enemyStations = P2.stations;
    }
    else
    {
      //Enemy is P1, build lists off of that
      enemyMissiles = P1.missiles;
      enemyShips = P1.fleet;
      enemyStations = P1.stations;
    }
    
    //Set the description string
    String descriptor = new String();
    descriptor += name;
    descriptor += "\n";
    descriptor += GetOwner().name;
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
  
  public void Update()
  {
    super.Update();    //Call pilotable update
    
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
    
  //**** SCANS *****//
    //Update sensor radius shape center
    scanRadius.location = location;
  
    if(millis() - lastScanTime > scanInterval)    //Time to scan?
    {
      SearchForTargets();                //Search for targets
      lastScanTime = millis();
    }
    
  //**** WEAPONS *****//
    if(millis() - lastFireTime > fireInterval)    //Time to fire?
    {
      if(!targets.isEmpty())
      {
        Physical closestTarget = null;    //Default go after first target
        float closestDistance = 99999;
        for(Physical phys : targets)    //Check each target to find if it is closest
        {
          PVector distance = new PVector(0,0);
          PVector.sub(phys.location,location,distance);
          if(distance.mag() < closestDistance)
          {
            closestTarget = phys;
          }
        }
        
        if(closestTarget != null)    //Found a target
        {
          //Calculate laser targeting vector
          PVector targetVector = PVector.sub(closestTarget.location, location);
          targetVector.normalize();        //Normalize to simple direction vector
          targetVector.x += rand.nextFloat() * 0.5 - 0.25;
          targetVector.y += rand.nextFloat() * 0.5 - 0.25;
          
          //Create laser object
          LaserBeam beam = new LaserBeam(location, targetVector, GetOwner());
          GetOwner().lasers.add(beam);
          
          lastFireTime = millis();
        }

      }
    }
    
  //**** ORDERS *****//
    //If all stop override, don't move
    if(allStopOrder.value)
    {
      currentOrder = null;
      destination = location;
      orders.clear();
      AllStop();
      allStopOrder.Toggle();
    }
    
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
  
  //Search enemy missiles/ ships/ asteroids moving toward this ship's base and set them as
  //members of *targets* list, within range of 'sensorRange'
  private void SearchForTargets()
  {  
    //Use the scan radius circle for collision testing
    targets.clear();
    for(Missile m : enemyMissiles)
    {
      if(CheckShapeOverlap(scanRadius, m.location))    //Is object center within scan radius?
      {
        targets.add(m);
      }
    }
    for(Station s : enemyStations)
    {
      if(CheckShapeOverlap(scanRadius, s.location))    //Is object center within scan radius?
      {
        targets.add(s);
      }
    }
    for(Ship s : enemyShips)
    {
      if(CheckShapeOverlap(scanRadius, s.location))    //Is object center within scan radius?
      {
        targets.add(s);
      }
    }
    for(Asteroid a : allAsteroids)
    {
      if(a.isRogue)    //Has asteroid been hit by a missile / ship?
      {
        if(GetOwner().orientation == CivOrientation.LEFT)    //Look for targets moving left
        {
          if(a.velocity.x < -0.1)
          {
            if(CheckShapeOverlap(scanRadius, a.location))    //Is object center within scan radius?
            {
              targets.add(a);
            }
          }
        }
        else    //Look for targets moving right
        {
          if(a.velocity.x > 0.1)
          {
            if(CheckShapeOverlap(scanRadius, a.location))    //Is object center within scan radius?
            {
              targets.add(a);
            }
          }
        }
      }
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
    
    scanRadius.DrawObject();
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
    descriptor += "\n";
    descriptor += GetOwner().name;
    descriptor += "\nHealth: ";
    descriptor += health.current;
    descriptor += "\nShield: ";
    descriptor += shield.health.current ;
    
    info.UpdateText(descriptor);
  }

}
