
public class Shield extends Physical implements Updatable
{
  Shape overlay;    //Shape to render
  Physical parent;  //What is generating the shield
  
  long lastUpdateTime;          //When were shield updates last checked
  int shieldRegenAmount = 1;    //Per second
  int failureTime = 5000;       //How long shields are offline in event they fail, ms
  
  //String _name, PVector _loc, PVector _size, float _mass, DrawableType _type, Civilization _owner
  Shield(Physical _parent, int _dmgCapacity)
  {
    //HACK size is forced round to compensate for no rotation of a Shape object (even though the Shield itself is 'physical')
    //HACK shield mass set to 1500 to get around a collision w/ really massive objects
    super("Shield", _parent.location, new PVector(_parent.size.x*1.25, _parent.size.x*1.25), 2000);
    overlay = new Shape("Shield Overlay", location, size, color(#5262E3, 50), ShapeType._CIRCLE_);
    overlay.SetFillColor(color(#5262E3, 50));
    
    health.current = _dmgCapacity;
    health.max = health.current;
    
    parent = _parent;
    
    //Regen setup
    lastUpdateTime = millis();
  }
  
  @Override public void Update()
  {
    location = parent.location;
    overlay.location = location;    //Move overlay to real position
    
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
  
}
