float globalSpeedLimit = 10;      //Universal speed limit (magnitude vector)

public enum PhysicsMode {       //Normal physics (Newtonian) or spin (planet/asteroid) 
  STANDARD, SPIN
}


public class Physical extends Drawable implements Movable, Collidable, Updatable
{
  //UI
  public Shape iconOverlay;
  public boolean drawOverlay = true;
  
  //Stats
  protected float mass;
  protected Health health;
  
  //Movement
  protected PVector velocity;              //On absolute plane
  protected float localSpeedLimit;         //Max velocity magnitude for this object
  protected PVector acceleration;          //Modifier on velocity
  protected float maxForceMagnitude;       //How large an acceleration force may be applied

  //Collisions
  protected long lastCollisionTime = -9999;
  protected int damageOnHit = 0;           //Automatic damage incurred on hit
  boolean collidable = true;               //Can this object be collided with by ANYTHING? see shields when down
  
  public Physical(String _name, PVector _loc, PVector _size, float _mass)
  {
    super(_name, _loc, _size);
    
    health = new Health(100, 100);       //Default health
    mass = _mass;
    
    //Movement
    velocity = new PVector(0, 0);
    acceleration = new PVector(0,0);
    localSpeedLimit = 10;         //Default speed limit
    maxForceMagnitude = .2;          //TODO implement me
    
    //UI
    iconOverlay = new Shape("Physical Overlay", location, 
                size, color(0,255,0), ShapeType._SQUARE_);
  }
  
  @Override public void DrawObject()
  {
    super.DrawObject();

    pushMatrix();
    translate(location.x, location.y);

    //Display forward vector (white), velocity vector (red)
    if (debugMode.value)
    {
      //Debug forward direction
      stroke(255, 255, 255);
      line(0, 0, 50 * forward.x, 50 * forward.y);  

      //Debug velocity direction
      stroke(255, 0, 0);
      line(0, 0, 100 * velocity.x, 100 * velocity.y);  
    }

    //Handle drawing rotation
    rotate(radians(baseAngle));

    popMatrix();
  }
  
//******* MOVE *********/
  public void SetVelocity(PVector _vector)
  {
    if(_vector.mag() <= globalSpeedLimit && _vector.mag() <= localSpeedLimit)
    {
      velocity = _vector;
    }
    else if (_vector.mag() > localSpeedLimit)
    {
      PVector scaledV = new PVector(_vector.x, _vector.y);
      scaledV.limit(localSpeedLimit);
      velocity = scaledV;
    }
    else if (_vector.mag() > globalSpeedLimit)
    {
      PVector scaledV = new PVector(_vector.x, _vector.y);
      scaledV.limit(globalSpeedLimit);
      velocity = scaledV;
    }
  }
  
  //Modify the current velocity of the object, respecting speed limit
  public void ChangeVelocity(PVector _vector)
  {
    PVector newVelocity = new PVector(velocity.x + _vector.x, velocity.y + _vector.y);
    SetVelocity(newVelocity);   
  }

  public void ApplyForce(PVector _accel)
  {
    acceleration.add(_accel);
  }

  //Set local speed limit
  public void SetMaxSpeed(float _limit)
  {
    localSpeedLimit = _limit;
  }
  
  //Move location
  public void Move()
  {
    location.add(velocity);               //Move based on velocity   
  }

  
//******* COLLIDE *********/

  //The other object's effect on this object
  float frictionFactor = 1.5;        //How much to slow down after collision (divisor)
  public void HandleCollision(Physical _other)
  {
    lastCollisionTime = millis();
    
    //Damage based on automatic damage 
    health.current -= _other.damageOnHit;
    
    //Damage this object based on delta velocity
    PVector deltaV = new PVector(0,0);
    PVector.sub(_other.velocity, velocity, deltaV);
    float velocityMagDiff = deltaV.mag();
    
    //Mass scaling factor (other/mine)
    float massRatio = _other.mass/mass;
    float damage = 10 * massRatio * velocityMagDiff;
    health.current -= damage;        //Lower this health
    
    if(debugMode.value)
    {
      print("[DEBUG] ");
      print(_other.name);
      print(" collision caused ");
      print(damage);
      print(" damage to ");
      print(name);
      print("\n");
    }
    
    //Create a velocity change based on this object and other object's position
    PVector deltaP = new PVector(0,0);    //Delta of position, dP(12) = P2 - P1
    deltaP.x = _other.location.x - location.x;
    deltaP.y = _other.location.y - location.y;
    
    deltaP.normalize();      //Create unit vector for new direction from deltaP
    
    //Opposite vector for this object (reverse direction)
    deltaP.mult(-1);
    deltaP.setMag(velocity.mag()/frictionFactor);
    
    SetVelocity(deltaP);
  }
  
//******* UPDATE *********/
  public void Update()
  {
    velocity.add(acceleration);           //Update velocity by acceleration vector
    velocity.limit(localSpeedLimit);      //Make sure we haven't accelerated over speed limit

    //acceleration.mult(0);                 //Reset acceleration (acts like an impulse)

    if(health.current <= 0)
    {
      toBeKilled = true;
      if(debugMode.value)
      {
        print("INFO: ");
        print(name);
        print(" has died\n");
      }

    }
  }
}
