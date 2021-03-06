  
public class Pilotable extends Physical implements Updatable
{
  PVector destination;              //Where would I like to go?
  int collisionStunTime;            //If collision occurs, how long stunned before movement may occur (milliseconds)
  
  //Orders
  public LinkedList<Order> orders;            //FIFO queue of location vectors to move to
  public Order currentOrder;          //HACK keep track of just current order, e.g. for drawing it
  int maxOrders;                         //How many orders are allowed in the order queue?
  
  //Order overrides
  TogglableBoolean allStopOrder = new TogglableBoolean(false);
  
  //Currently selection variables
  public boolean currentlySelected;      //TODO should this be a pilotable only thing? Probably not...
   /*
   * Constructor
   * @param  _name  string to identify this
   * @param  _loc   2d vector of location
   * @param  _size  2d vector of size
   * @param  _mass  integer of mass
   * @param  _type  A DrawableType (depending who extends this class)
   * @see         Pilotable
   */
  public Pilotable(String _name, PVector _loc, PVector _size, int _mass, DrawableType _type, Civilization _owner) 
  {
    //Parent constructor
    super(_name, _loc, _size, _mass, _type, _owner);
    
    rotationMode = RotationMode.FACE;    //Face target
    collisionStunTime = 2000;      //2 second stun
    
    maxOrders = 5;      
    orders = new LinkedList<Order>();
    
    currentlySelected = false;
  }
  
  //Set the point this pilotable object will fly to
  public void SetDestination(PVector _destination)
  {
    destination = _destination;
    AccelerateToTarget();
  }
  
  //Move location
  @Override public void Move()
  {

    if(!AtTarget())
    {
      if(!Stunned())
      {
        AccelerateToTarget();
        SetRotationTarget(destination);
      }
    }
    else
    {
      AllStop();
      
      //Reached the target -- get new order
      PVector nextDestination = null;
      currentOrder = GetNextOrder();
      if(currentOrder != null)
      {
        if(currentOrder.orderType == OrderType._MOVE_ 
          || currentOrder.orderType == OrderType._KILL_)
        {
          nextDestination = currentOrder.location;   
          destination = nextDestination;
        }

      }
      
      //There are no new orders
      else
      {
        //Do.... what?
        AllStop();
      }
    }
    location = PVector.add(location, velocity);
    
    
  }
  
  //Public method to provide a target and actuate rotation & acceleration
  public void MoveToTarget(PVector _target)
  {
    if(_target != null)
    {
       SetRotationTarget(_target);
       SetDestination(_target);
    }
  }
  
  //TODO implement an algorithm that also accounts for current velocity
  private void AccelerateToTarget()
  {
    //Guarantee we are rotating toward target
    SetRotationMode(RotationMode.FACE);          //Face target
    
    PVector newVelocity = new PVector(localSpeedLimit, 0);    //New vector straight in front of object
    newVelocity.rotate(currentAngle);
    newVelocity.mult(acceleration);
    ChangeVelocity(newVelocity);
  }
  
  protected void AllStop()
  {
    //println("All stop!");
    SetVelocity(new PVector(0,0));    //TODO is this the most fun way to play?
    SetRotationMode(RotationMode.NONE);              //Don't rotate 
  }
  
  //Checks if pilotable object is within one half size from the target. If null also assume at target
  private boolean AtTarget()
  {
    if(destination != null)
    {
      if(abs(wvd.pixel2worldX(location.x) - wvd.pixel2worldX(destination.x)) < size.x/2
        && abs(wvd.pixel2worldY(location.y) - wvd.pixel2worldY(destination.y)) < size.y/2)
      {
        return true;
      }
      else
      {
        return false;
      }
    }
    else
    {
      return true;
    }
  }
  
  private boolean Stunned()
  {
    if(millis() - lastCollisionTime < collisionStunTime)
    {
      return true;
    }
    else
    {
      return false;
    }
  }
  
  //Location in CONVERTED world coordinates
  public void AddNewOrder(PVector _orderLoc, Physical _target, OrderType _orderType)
  {
    //TODO implement other order types (besides move)
    if(orders.size() < maxOrders)
    {
      Order newOrder = null;
      if(_orderType == OrderType._MOVE_)
      {
        newOrder = new Order("Move Order", _orderLoc, _orderType);
      }
      else if(_orderType == OrderType._KILL_)
      {
        newOrder = new Order("Kill Order", _orderLoc, _orderType);
      }
      else
      {
        print("Unsupported new order type for ");
        print(name);
        println();
      }
      
      newOrder.SetOrderTarget(_target);
      orders.push(newOrder);        //Append this order to the END of the linked list
      
      //TODO fix this system to be less... broken.. and dependent on currentOrder
      //Update the previous order to inform it of this order
      if(currentOrder != null)
      {
        //HACK workaround for this bad push/pop system (where tracking the current order is still needed)
        if(orders.size() == 1)
        {
          //There is only one order in queue -- match to current order
          orders.peek().SetNextOrder(currentOrder);
        }
        else 
        {
          //Set to next order (-1 because of FIFO)
          Order nextOrder = orders.get(1);
          orders.peek().SetNextOrder(nextOrder);
        }
      }
    }
    else
    {
      print("INFO: Cannot add new order to ");
      print(name);
      print(";\n");
      print("Order queue full");
    }
  }
  
  //Get next order from the order queue. If empty return current destination
  private Order GetNextOrder()
  {
    if(!orders.isEmpty())
    {
      return orders.removeLast();
    }
    else
    {
      return null;
    }
  }
  
  /**** UPDATE ****/
  //TODO the implement interface of this class isnt requiring this function -- why?
  public void Update()
  {
    super.Update();
    if(currentOrder != null)
    {
       //Update kill orders to follow target (CURRENT ORDER)
      if(currentOrder.orderType == OrderType._KILL_)
      {
        //Set the kill order's location to the order's physical object tracker
        if(currentOrder.orderTarget != null)    //Make sure the target is still alive
        {
          //Update the orders to match the (presumably moving) target's new location
          currentOrder.UpdateLocation(currentOrder.orderTarget.location);
          
          //Update the order icon to follow the target
          currentOrder.orderIcon.UpdateLocation(currentOrder.orderTarget.location);
          
          //Update this pilotable's destination to match the targets new position
          destination = currentOrder.orderTarget.location;
        }
        else    //Target is dead -- get a new current order
        {
          //TODO test me
          currentOrder = GetNextOrder();
        }
      }
    }
    
    for(Order _ord : orders)
    {
      //Set the kill order's location to the order's physical object tracker
      if(_ord.orderTarget != null)    //Make sure the target is still alive
      {
        //Update the orders to match the (presumably moving) target's new location
        _ord.UpdateLocation(_ord.orderTarget.location);
        
        //Update the order icon to follow the target
        _ord.orderIcon.UpdateLocation(_ord.orderTarget.location);
      }
    }
  }
}
  
  
