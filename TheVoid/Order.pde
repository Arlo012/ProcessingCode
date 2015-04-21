public enum OrderType {
_KILL_, _MOVE_, _ORBIT_
}

/*
 * An order object that contains the type of action to be carried 
 * out as well as a method of drawing it for UI feedback
*/
public class Order extends UI
{
  OrderType orderType;          //What kind of order is this (see OrderType)
  private Order nextOrder;      //The next order in this owner's order queue
  
  public color orderColor;
  
  //Shapes to represent orders
  private Shape orderIcon;
  
  public Physical orderTarget;        //Physical object target (kill/ orbit)
  
  Order(String _name, PVector _loc, OrderType _orderType)
  {
    super(_name, _loc, new PVector(20, 20), true);      //Default size 20x20
    
    orderType = _orderType;
    
    SetupOrderColor();    //Based on type
    
    orderIcon = new Shape(_name, location, size, orderColor, ShapeType._CIRCLE_);
  }
  
  //Note: This DrawObject function uses minimal push/pop matrix because it implements drawing other
  //Draw functions that already take care of that
  @Override public void DrawObject()
  {
    pushStyle();
    orderIcon.DrawObject();
    
    //Draw line to next order
    if(nextOrder != null)
    {
      stroke(nextOrder.orderColor);
      
      //Handle in absolute coordinates (w/o translate) because delta position difficult to calculate
      line(location.x,location.y, nextOrder.location.x, nextOrder.location.y);
    }
    popStyle();
  }
  
  //Set order color based on type
  private void SetupOrderColor()
  {
    if(orderType == OrderType._KILL_)
    {
      orderColor = color(255,0,0);
    }
    else if(orderType == OrderType._MOVE_)
    {
      orderColor = color(0,255,0);
    }
    else if(orderType == OrderType._ORBIT_)
    {
      orderColor = color(0,0,255);
    }
    else
    {
      orderColor = color(255);
    }
  } 
  
  //Set the order that is to take place AFTER this one
  public void SetNextOrder(Order _order)
  {
    nextOrder = _order;
  }
  
  //Set the physical object that this order is tracking (i.e. for kill)
  public void SetOrderTarget(Physical _phys)
  {
    orderTarget = _phys;
  }
  
}
