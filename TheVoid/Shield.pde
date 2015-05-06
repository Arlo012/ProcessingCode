public enum ShieldDirection {
  FORWARD, LEFT, RIGHT, BACK
};


public class Shield extends Physical implements Updatable
{
  Physical parent;  //What is generating the shield
  Shape collider;   //Collision checking triangle
  ShieldDirection direction;

  long lastUpdateTime;          //When were shield updates last checked
  int shieldRegenAmount = 1;    //Per second
  int failureTime = 5000;       //How long shields are offline in event they fail, ms
  
  
  boolean online;               //Are shields up?

  //Location shifting
  float rotationShift;
  PVector locationShift;

  //Shield size scaling
  float sizeScale = 0.75;

  Shield(Physical _parent, int _dmgCapacity, ShieldDirection _direction, Sector _sector)
  {
    super("Shield", _parent.location, new PVector(_parent.size.x, _parent.size.x), 2000, _sector);

    parent = _parent;

    sprite = shieldSprite;
    int outsideShipDimension;   //Determine which direction ship is bigger (to make shield that size)
    if(parent.size.y > parent.size.x)
    {
      outsideShipDimension = (int)parent.size.y;
    }
    else
    {
      outsideShipDimension = (int)parent.size.x;
    }
    size.x = outsideShipDimension * sizeScale;      //This is the largest ship dimension
    size.y = sqrt(size.x*size.x + size.x*size.x) + 1;    //Pythagorean theorem, +1 to connect better
    sprite.resize((int)size.x,(int)size.y);

    //Which way off of ship is it?
    direction = _direction;

    //HACK the triangle size for the shields is just tuned to match the player.... need a real formula
    //Setup collider (note: in a triangle the Y dimension is ignored))
    collider = new Shape("ShieldCollider", location, new PVector(0.8*size.x, 0.8*size.x), color(0,0,255), ShapeType._TRIANGLE_);

    locationShift = new PVector(0,0);
    rotationShift = 0;

    if(direction == ShieldDirection.FORWARD)
    {
      locationShift.x = size.x/2;
    }
    else if(direction == ShieldDirection.RIGHT)
    {
      locationShift.y = size.x/2;

      rotationShift = HALF_PI;
      collider.triangleRotate = HALF_PI;
    }
    else if(direction == ShieldDirection.LEFT)
    {
      locationShift.y = -size.x/2;

      rotationShift = -HALF_PI;
      collider.triangleRotate = -HALF_PI;
    }
    else if(direction == ShieldDirection.BACK)
    {
      locationShift.x = -size.x/2;

      rotationShift = PI;
      collider.triangleRotate = PI;
    }
    else
    {
      println("[ERROR] Spawned shield with invalid direction!");
    }

    //Initially offline
    online = false;

    health.current = _dmgCapacity;
    health.max = health.current;
    
    //Regen setup
    lastUpdateTime = millis();
  }

  @Override public void DrawObject()
  {
    super.DrawObject();
    collider.DrawObject();
  }

  //TODO careful of shield changing sector update
  @Override public void Update()
  {
    location = parent.location.get();   //Update to ship location
    location.add(locationShift);    //Shift based on shield direction
    baseAngle += rotationShift;   //Rotate based on shield direction
    
    collider.location = parent.location.get();   //Collider must follow shield

    //Check for shields down during this past loop
    if(collidable && health.current <= 0)
    {
      collidable = false;
      lastUpdateTime += failureTime;        //Won't update (regen for another 5 seconds)
      
      health.current = 0;      //Reset to zero health (no negative shield health)
    }
    
    //Regen
    if(millis() > lastUpdateTime + 1000)    //Do one second tick updates
    {
      collidable = true;
      if(health.current < health.max)
      {
        health.current += shieldRegenAmount;
      }
      lastUpdateTime = millis();
    }
  }

  /**
   * Cause collision effects on the OTHER object
   * @param  {Physical} _other Other object to affect by this collision
   */
   @Override public void HandleCollision(Physical _other)
  {
    super.HandleCollision(_other);

    //TODO Play sounds....

  }

}
