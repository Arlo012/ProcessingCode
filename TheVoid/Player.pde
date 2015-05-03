
/**
 * Player ship object, with reactor cores, stations, etc.
 */
public class Player extends Ship
{
  private Reactor reactor;
  private int maxPowerToNode;			//Maximum power any one node may have
  
  //Behavoir Ranges for Enemy
  public Shape seekCircle, seekAgainCircle, avoidCircle;
  public int seekRadius, seekAgainDiameter, avoidDiameter;

  public Player(PVector _loc, PVector _size, PImage _sprite, int _mass, color _outlineColor, Sector _sector) 
  {
  //Parent constructor
  super("Player", _loc, _size, _sprite, _mass, _outlineColor, _sector);

  reactor = new Reactor(100);
  maxPowerToNode = reactor.totalCapacity/3;
  
  //Behavior Ranges for Enemies
  seekRadius = displayWidth;        //All ships inside the screen + 100 pixels will seek to destory
  seekAgainDiameter = 500;
  avoidDiameter = 400;
  
  seekCircle = new Shape("seekCircle", location, new PVector(seekRadius,seekRadius), color(0,255,255), ShapeType._CIRCLE_);                    //Light Blue
  seekAgainCircle = new Shape("seekAgainCircle", location, new PVector(seekAgainDiameter,seekAgainDiameter), color(255,18,200), ShapeType._CIRCLE_); //Pink
  avoidCircle = new Shape("avoidCircle",location , new PVector(avoidDiameter,avoidDiameter), color(18,255,47), ShapeType._CIRCLE_);                  //Green
  }	

  @Override public void Update()
  {
  super.Update();
  
  seekCircle.location = location;
  seekAgainCircle.location = location;
  avoidCircle.location = location;

  PVector spinForce = Spin();
  ApplyForce(spinForce);

  PVector thrustForce = Thrust();
  ApplyForce(thrustForce); 

  //TODO modify ship parameters (engine power, shield, etc) based off
  //of reactor right now
  //Modify weapon fire speed
  int weaponCooldownModifier = reactor.GetReactorPower(NodeType.WEAPONS)/maxPowerToNode;
  currentFireInterval = minFireInterval + weaponCooldownModifier * minFireInterval;
  }
  
  @Override public void DrawObject()
  {
    super.DrawObject();
    if(debugMode.value)
    {
      seekCircle.DrawObject();
      seekAgainCircle.DrawObject();
      avoidCircle.DrawObject();
    }
  }	
  
}


enum NodeType
{
  SHIELDS, WEAPONS, ENGINES
}

/**
 * A power reactor that controls how much power the ship gets to each of its
 * nodes. To be controlled by keyboard / external controller
 */
public class Reactor
{
  int totalCapacity;
  Map<NodeType, Node> nodes;

  public Reactor(int _capacity)
  {
    totalCapacity = _capacity;
    nodes = new HashMap<NodeType, Node>();
    nodes.put(NodeType.SHIELDS, new Node(NodeType.SHIELDS));
    nodes.put(NodeType.WEAPONS, new Node(NodeType.WEAPONS));
    nodes.put(NodeType.ENGINES, new Node(NodeType.ENGINES));
  }
  public int GetReactorPower(NodeType _type)
  {
    return nodes.get(_type).currentPower;
  }
}

/**
 * Power node on the reactor control board
 */
public class Node
{
	NodeType type;
	int currentPower;

	public Node(NodeType _type)
	{
		type = _type;
		currentPower = 0;
	}

	public void SetPower(int _power)
	{
		currentPower = _power;
	}

}
