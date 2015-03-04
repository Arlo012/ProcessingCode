float globalSpeedLimit = 5;      //Universal speed limit (magnitude vector)

public class Physical extends Drawable implements Movable, Turnable, Collidable
{
  protected int mass;
  protected PVector velocity;              //On absolute plane
  protected float localSpeedLimit;       //Max velocity magnitude for this object
  
  //Rotation
  protected int rotationMode;              //-1 = stationary, 0 = instant, 1 = spin, 2 = face point
  protected float currentAngle; 
  protected int spinDirection;             //-1 CCW, 1 CW
  protected float destinationAngle;        //TODO phase out -- why need a destination angle if have target?
  protected float rotationRate;            //Degrees/sec
  protected PVector rotationLookTarget;    //Coordinate of what we want to look at
  
  public Physical(PVector _loc, PVector _size, int _mass, DrawableType _type)
  {
    super(_loc, _size, _type);
    
    mass = _mass;
    velocity = new PVector(0, 0);
    localSpeedLimit = globalSpeedLimit;      //Default speed limit
    
    //Rotation
    currentAngle = 0;
    destinationAngle = 0;
    rotationMode = -1;      //Default to no rotation
    rotationRate = 0.01;    //Degrees/sec TODO broken not related to deg/sec right now
    spinDirection = 1;      //CW
    rotationLookTarget = new PVector(0,0);      //Default look at origin
  }
  
  @Override public void DrawObject()
  {
    pushMatrix();
    translate(location.x, location.y);
    
    if(debugMode)
    {
      //Debug velocity direction
      stroke(255, 0, 0);
      line(0, 0, 100 * velocity.x, 100 * velocity.y);
    }
    
    
    //Handle rotation
    if (rotationMode == -1)
    {   //Not rotating
    } 
    else if (rotationMode == 0)
    {
      //Rotate instantly
      rotate(destinationAngle);
      println(destinationAngle);
      currentAngle = destinationAngle;      //We instantly rotated there
    } 
    else if (rotationMode == 1)
    {
      //Rotate in direction
      currentAngle += spinDirection * rotationRate;
      rotate(currentAngle);
    } 
    else if (rotationMode == 2)
    {
      RotateToTarget();
    } 
    else
    {
      println("WARNING: Rotation mode not supported");
    }

    //End handle rotation

    imageMode(CENTER);

    //Display forward vector (white), velocity vector (red)
    if (debugMode)
    {
      //Debug forward direction
      stroke(255);
      line(0, 0, 50 * forward.x, 50 * forward.y);    
    }

    translate(-location.x, -location.y);      //Return to standard orientation before drawing
    image(sprite, location.x, location.y);
    popMatrix();
  }
  
  //******* MOVE *********/
  public void SetDestinationAngle(float _destination)
  {
    destinationAngle = _destination;
  }

  public void SetVelocity(PVector _vector)
  {
    if(_vector.mag() < globalSpeedLimit && _vector.mag() < localSpeedLimit)
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
    PVector newVelocity = new PVector(velocity.x + _vector.x, velocity.y + _vector.x);
    SetVelocity(newVelocity);
    
  }

  //Set local speed limit
  public void SetMaxSpeed(float _limit)
  {
    localSpeedLimit = _limit;
  }
  
  //Move location of the asteroid
  public void Move()
  {
    location = PVector.add(location, velocity);
  }

  //******* ROTATE *********/
  //0 = instant, 1 = spin, 2 = standard
  public void SetRotationMode(int _rotateMode)
  {
    rotationMode = _rotateMode;
  }

  public void SetRotationRate(float _degreePerSec)
  {
    rotationRate = _degreePerSec;
  }

  public void SetRotationTarget(PVector _target)
  {
    rotationLookTarget = _target;
  }
  
  //Rotate mode 2
  private void RotateToTarget()
  {
    PVector targetRelativeToLocal = new PVector(rotationLookTarget.x - location.x, 
                rotationLookTarget.y - location.y);

    float radToRotate = atan2(targetRelativeToLocal.y - forward.y, targetRelativeToLocal.x - forward.x);
    //println(degrees(radToRotate));
    //println(degrees(currentAngle));
    //println("-------");
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
  float frictionFactor = 1;        //How much to slow down after collision
  public void HandleCollision(Physical _other)
  {
    //Mass scaling factor (other/mine)
    float massRatio = 1;//_other.mass/mass;
    
    PVector deltaP = new PVector(0,0);    //Delta of position, dP(12) = P2 - P1
    deltaP.x = _other.location.x - location.x;
    deltaP.y = _other.location.y - location.y;
    
    deltaP.normalize();      //Create unit vector for new direction from deltaP
    
    //Opposite vector for this object
    deltaP.mult(-1); //<>//
    deltaP.setMag(velocity.mag());
    
    SetVelocity(deltaP);

    //TODO testme 
    rotationRate /= 1.5;
  }
}
