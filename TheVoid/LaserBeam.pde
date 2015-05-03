public class LaserBeam extends Physical
{
  //Draw properties (limit range)
  static final float laserSpeedLimit = 4.0;    //Speed limit, static for all laserbeams
  static final int timeToFly = 2500;        //Effective range, related to speed (ms)
  private long spawnTime;
  
  LaserBeam(PVector _loc, PVector _direction, Sector _sector)
  {
    super("Laser beam", _loc, new PVector(20,3), .01, _sector);    //HACK Mass very low!! For handling physics easier 
    
    //Set laser color
      //TODO set laser color by player / enemy

    sprite.resize((int)size.x, (int)size.y);
    
    //Set laser speed and lifetime
    localSpeedLimit = laserSpeedLimit;
    spawnTime = millis();
    
    //Damage settings
    damageOnHit = 40;
    
    //Rotation setter
    // currentAngle = _direction.heading();
    
    //Velocity setter
    PVector scaledVelocity = _direction.get();
    scaledVelocity.setMag(laserSpeedLimit);
    
    SetVelocity(scaledVelocity);
    
    //Play laser fire sound
    laserSound.play();
  }
  
  //Standard update() + handle time of flight
  @Override public void Update()
  {
    super.Update();
          
    if(spawnTime + timeToFly < millis())
    {
      toBeKilled = true;
    }
  }
  
  //Handle laser damage in addition to standard collision
  @Override public void HandleCollision(Physical _other)
  {
    _other.health.current -= damageOnHit;
    
    if(debugMode.value)
    {
      print("INFO: Laser beam burn hurt ");
      print(_other.name);
      print(" for ");
      print(damageOnHit);
      print(" damage.\n");
    }
    
    toBeKilled = true;
  }

}
