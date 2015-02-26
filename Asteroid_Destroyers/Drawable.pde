/* Drawable
 * Base class for all drawable objects in the project
 * Implements a basic DrawObject() method to draw a debug
 * rectangle even if not inherited from.
*/
public class Drawable implements Movable, Turnable
{
  //Image properties
  protected PVector center;
  protected PVector size;
  
  //Visuals
  protected PImage sprite;
  
  //Movement
  protected PVector velocity;              //On absolute plane
  protected PVector forward;               //On absolute plane

  //Rotation
  protected int rotationMode;              //-1 = stationary, 0 = instant, 1 = spin, 2 = face point
  protected float currentAngle; 
  protected int spinDirection;             //-1 CCW, 1 CW
  protected float destinationAngle;        //TODO phase out -- why need a destination angle if have target?
  protected float rotationRate;            //Degrees/sec
  protected PVector rotationLookTarget;    //Coordinate of what we want to look at
  
  //Location & movement
  protected PVector movementVector;
  
  public Drawable(int _centerX, int _centerY, int _width, int _height)
  {
    center = new PVector(_centerX, _centerY);
    size = new PVector(_width, _height);
    
    //Movement
    movementVector = new PVector(0, 0);
    forward = new PVector(1, 0);      //Forward is by default in the positive x direction
    velocity = new PVector(0, 0);
    
    //Rotation
    currentAngle = 0;
    destinationAngle = 0;
    rotationMode = -1;      //Default to no rotation
    rotationRate = 0.01;    //Degrees/sec TODO broken not related to deg/sec right now
    spinDirection = 1;      //CW
    rotationLookTarget = center;      //Default look at self
  }
  
  public void DrawObject()
  {
    pushMatrix();
    translate(center.x, center.y);
    
    float initialAngle = currentAngle;
    rotate(initialAngle);      //Make my 'up' this frame of reference's 'up'
    if (rotationMode == -1)
    {   //Not rotating
    }
    else if (rotationMode == 0)
    {
      Rotate(destinationAngle);
      currentAngle = destinationAngle;      //We instantly rotated there
    } 
    
    else if (rotationMode == 1)
    {
      println("Rotating to angle");
      currentAngle = RotateInDirection(currentAngle, spinDirection * rotationRate);
    }
    else if (rotationMode == 2)
    {
      currentAngle = RotateToFacePoint(currentAngle, center, rotationLookTarget);
    }
    else
    {
      println("WARNING: Rotation mode not supported");
    }
    //Update forward vector //<>//
    //forward.rotate(currentAngle - initialAngle);
    
    imageMode(CENTER);
    rotate(-initialAngle);                //Return to default frame of reference
    
    //Display forward vector (white), velocity vector (red)
    if(debugMode)
    {
      //Debug forward direction
      stroke(255);
      line(0, 0, 100 * forward.x, 100 * forward.y);    
      
      //Debug velocity direction
      stroke(255, 0, 0);
      line(0, 0, 1000 * velocity.x, 1000 * velocity.y); 
    }
    
    translate(-center.x, -center.y);      //Return to standard orientation before drawing
    image(sprite, center.x, center.y);
    popMatrix();
    
    //TODO update velocity after direction change
  }
  
  public PVector GetCenter()
  {
    return center;
  }
  
  public PVector GetSize()
  {
    return size;
  }
  
  
//******* MOVE *********/
  public void SetDestinationAngle(float _destination)
  {
    destinationAngle = _destination;
  }
  
  //Modify the current velocity of the object 
  public void ChangeVelocity(PVector _vector)
  {
    velocity = _vector;
  }

  //Move center of the asteroid
  public void Move()
  {
    center = PVector.add(center, velocity);
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
}
