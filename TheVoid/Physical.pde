float globalSpeedLimit = 10;      //Universal speed limit (magnitude vector)

public enum RotationMode {
NONE, INSTANT, SPIN, FACE
}

public enum MoveMode {
LINEAR, ORBITAL
}

public class Physical extends Drawable implements Movable, Turnable, Collidable, Updatable
{
  //UI
  public Shape iconOverlay;
  public boolean drawOverlay = true;
  private Civilization owner;              //Point to owner of this object, null by default
  
  //Stats
  protected float mass;
  protected Health health;
  
  //Movement
  protected PVector velocity;              //On absolute plane
  protected float localSpeedLimit;         //Max velocity magnitude for this object
  protected float acceleration = 0.05;     //Multiple to max velocity out of 1. 0 = none, 1 = instant
  private MoveMode moveMode;               //Linear movement or orbit
  
  //Orbitals
  private PVector orbitForwardVector;      //Forward vector for rotation
  protected int orbitDistance;             //How far from object to orbit
  
  //Rotation
  protected RotationMode rotationMode;     //How to rotate (see RotationMode)
  protected float currentAngle;            //In radians
  protected int spinDirection;             //-1 CCW, 1 CW
  protected float destinationAngle;        //TODO phase out -- why need a destination angle if have target?
  protected float rotationRate;            //Degrees/sec
  protected PVector rotationLookTarget;    //Coordinate of what we want to look at
  
  //Collisions
  protected long lastCollisionTime = -9999;
  protected int damageOnHit = 0;           //Automatic damage incurred on hit
  boolean collidable = true;               //Can this object be collided with by ANYTHING? see shields when down
  
  public Physical(String _name, PVector _loc, PVector _size, float _mass, DrawableType _type, Civilization _owner)
  {
    super(_name, _loc, _size, _type);
    
    health = new Health(100, 100);       //Default health
    mass = _mass;
    owner = _owner;
    
    //Movement
    velocity = new PVector(0, 0);
    localSpeedLimit = 1.5;         //Default speed limit
    moveMode = MoveMode.LINEAR;    //Default to linear movement
    orbitForwardVector = new PVector(0,0);    //Default no orbital vector
    
    //Rotation
    currentAngle = 0;
    destinationAngle = 0;
    rotationMode = RotationMode.NONE;      //Default to no rotation
    rotationRate = 0.01;    //Degrees/sec TODO broken not related to deg/sec right now
    spinDirection = 1;      //CW
    rotationLookTarget = new PVector(0,0);      //Default look at origin
    
    //UI
    iconOverlay = new Shape("Physical Overlay", location, 
                size, color(0,255,0), ShapeType._SQUARE_);
  }
  
  //Return civilization that owns this object
  public Civilization GetOwner()
  {
    if(owner == null)
    {
      print("ERROR: Requested owner on ");
      print(name);
      print(" with no owner!");
    }
    return owner;
  }
  
  @Override public void DrawObject()
  {
    pushMatrix();
    translate(location.x, location.y);
    
    if(debugMode.value)
    {
      //Debug velocity direction
      stroke(255, 0, 0);
      line(0, 0, 100 * velocity.x, 100 * velocity.y);
      
      //Debug orbital forward vector
      stroke(0,255,0);
      line(0, 0, orbitForwardVector.x, orbitForwardVector.y);
    }
    
    //Handle rotation
    if (rotationMode == RotationMode.NONE)
    {   //Not rotating (hold whatever angle is provided)
      //TODO this is the same in practice as rotationMode = 0
      rotate(currentAngle);
    } 
    else if (rotationMode == RotationMode.INSTANT)
    {
      //Rotate instantly
      currentAngle = destinationAngle;      //We instantly rotated there
      rotate(currentAngle);
    } 
    else if (rotationMode == RotationMode.SPIN)
    {
      //Rotate in direction
      currentAngle += spinDirection * rotationRate;
      rotate(currentAngle);
    } 
    else if (rotationMode == RotationMode.FACE)
    {
      RotateToTarget();
    } 
    else
    {
      println("WARNING: Rotation mode not supported");
    }

    //End handle rotation

    imageMode(renderMode);

    //Display forward vector (white), velocity vector (red)
    if (debugMode.value)
    {
      //Debug forward direction
      stroke(255);
      line(0, 0, 50 * forward.x, 50 * forward.y);    
    }

    image(sprite, 0, 0);
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

  //Set local speed limit
  public void SetMaxSpeed(float _limit)
  {
    localSpeedLimit = _limit;
  }
  
  //Move location
  public void Move()
  {
    if(moveMode == MoveMode.LINEAR)    //TODO phase out (only did linear motion)
    {
      location = PVector.add(location, velocity);      
    }
    else
    {
      print("WARNING: ");
      print(name);
      print(" has attempted to move in an unsupported mode.\n");
    }

  }
 

//******* ROTATE *********/
  //0 = instant, 1 = spin, 2 = standard
  public void SetRotationMode(RotationMode _rotateMode)
  {
    rotationMode = _rotateMode;
  }

  public void SetRotationRate(float _degreePerSec)
  {
    rotationRate = _degreePerSec;
  }

  public void SetRotationTarget(PVector _target)
  {
    if(_target != null)
    {
      rotationLookTarget = _target;
    }
    else
    {
      //TODO setting this is messing up control flow of pathing
      rotationLookTarget = new PVector(0,0);
    }
    
  }
  
  public void SetDestinationAngle(float _destination)
  {
    destinationAngle = _destination;
  }
  
  //Rotate mode 2
  //TODO cleanup here
  private void RotateToTarget()
  {
    PVector targetRelativeToLocal = new PVector(rotationLookTarget.x - location.x, 
                rotationLookTarget.y - location.y);

    float radToRotate = atan2(targetRelativeToLocal.y - forward.y, targetRelativeToLocal.x - forward.x);

    if(degrees(currentAngle) > 360)
    {
      currentAngle -= radians(360);
    }
    else if(degrees(currentAngle) < -360)
    {
      currentAngle += radians(360);
    }
    
    //Check for wrap-around degrees
    if(degrees(radToRotate - currentAngle) < -180)
    {
      radToRotate += radians(360);
    }
    else if(degrees(radToRotate - currentAngle) > 180)
    {
      radToRotate -= radians(360);
    }
    
    //Jitter prevention
    if (Math.abs(radToRotate - currentAngle) > radians(0.5))
    {
      if (radToRotate - currentAngle > 0)
      {
        //CW
        spinDirection = 1;
      } 
      else
      {
        spinDirection = -1;
      }
      
      currentAngle += spinDirection * rotationRate;
      rotate(currentAngle);
    }
    else
    {
      rotate(currentAngle);
    }
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
      print("INFO: ");
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
    
    //If the object was an asteroid it is now a projectile -- update its color
    //TODO _other --> this
    if(_other instanceof Asteroid)
    {
      //Asteroid object specific
      Asteroid roid = (Asteroid)_other;
      roid.isRogue = true;
      
      //Overlay update to red if impacted
      _other.iconOverlay.borderColor = color(255,0,0);
      _other.drawOverlay = true;        //Draw icon overlay when missile impacts the asteroid
      
    }
  }
  
//******* UPDATE *********/
  public void Update()
  {
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
