
public class Shield extends Physical implements Updatable
{
  Physical parent;  //What is generating the shield

  long lastUpdateTime;          //When were shield updates last checked
  int shieldRegenAmount = 1;    //Per second
  int failureTime = 5000;       //How long shields are offline in event they fail, ms
  
  
  boolean online;               //Are shields up?

  //Shield size scaling
  float sizeScale = 1.25;

  Shield(Physical _parent, int _dmgCapacity, Sector _sector, Shape _collider)
  {
    super("Shield", _parent.location, new PVector(_parent.size.x, _parent.size.x), 2000, _sector, _collider);

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
    size.y = size.x;

    sprite.resize((int)size.x,(int)size.y);

    //Also update the collider size
    collider.size.x = size.x;
    collider.size.y = size.y;

    //Initially offline
    online = false;

    health.current = _dmgCapacity;
    health.max = health.current;
    
    //Regen setup
    lastUpdateTime = millis();
  }

  //Do NOT use physical behavior -- handle separately
  @Override public void Update()
  {
    location = parent.location.get();   //Update to ship location

    collider.location = location;

    collider.Update();

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
