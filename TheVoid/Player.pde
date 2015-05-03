
/**
 * Player ship object, with reactor cores, stations, etc.
 */
public class Player extends Ship
{
	private Reactor reactor;
	private int maxPowerToNode;			//Maximum power any one node may have

	public Player(PVector _loc, PVector _size, PImage _sprite, int _mass, color _outlineColor, Sector _sector) 
	{
		//Parent constructor
		super("Player", _loc, _size, _sprite, _mass, _outlineColor, _sector);

		reactor = new Reactor(100);
		maxPowerToNode = reactor.totalCapacity/3;
	}	

	@Override public void Update()
	{
		super.Update();

		//TODO modify ship parameters (engine power, shield, etc) based off
		//of reactor right now
		//Modify weapon fire speed
		int weaponCooldownModifier = reactor.GetReactorPower(NodeType.WEAPONS)/maxPowerToNode;
		currentFireInterval = minFireInterval + weaponCooldownModifier * minFireInterval;

		
	}	

}


enum NodeType{
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