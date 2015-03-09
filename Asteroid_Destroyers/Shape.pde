public static enum ShapeType {
  _SQUARE_, _TRIANGLE_, _CIRCLE_
}

/*
 * UI shape
*/
public class Shape extends Drawable
{
  public ShapeType shapeType;
  public color borderColor;
  
  private ShapeType  defaultShapeType;
  private color defaultColor;
  private boolean colorSet;          //Allow only one initial set of color after the constructor's default
  
  public Shape(String _name, PVector _loc, PVector _size, color _color, ShapeType _shapeType)
  {
    super(_name, _loc, _size, DrawableType.UI);
    borderColor = _color;
    defaultColor = borderColor;
    shapeType = _shapeType;
    colorSet = false;
  }
  
  @Override public void DrawObject()
  {
    pushMatrix();
    translate(location.x, location.y);
    pushStyle();
    stroke(borderColor);
    fill(0,0,0,0);
    
    if(shapeType == ShapeType._SQUARE_)
    {
      rectMode(CENTER);
      rect(0, 0, size.x, size.x);    //TODO forced square here
    }
    else if(shapeType == ShapeType._TRIANGLE_)
    {
      float a = size.x;
      float r = a * sqrt(3)/6;      //See http://www.treenshop.com/Treenshop/ArticlesPages/FiguresOfInterest_Article/The%20Equilateral%20Triangle.htm
      float R = r * 2;
    
      beginShape(TRIANGLES);
      vertex(-a/2, r);
      vertex(a/2, r);
      vertex(0, -R);
      endShape();
    }
    else if(shapeType == ShapeType._CIRCLE_)
    {
      ellipseMode(RADIUS);
      ellipse(0, 0, size.x/2, size.y/2);
    }
    popStyle();
    popMatrix();
  }
  
  public void SetIcon(color _color, ShapeType _type)
  {
    if(!colorSet)
    {
      //Set shape type
      shapeType = _type;
      defaultShapeType = shapeType;
      
      //Set border color
      borderColor = _color;
      defaultColor = borderColor;
      
      colorSet = true;
    }
    else
    {
      println("WARNING: Attempted to set icon color after it had been initially set. Try UpdateIcon instead?");
    }
  }
  
  void SetBorderColor(color _borderColor, ShapeType _type)
  {
    shapeType = _type;
    borderColor = _borderColor;
  }
  
  void SetBorderColor(color _borderColor)
  {
    borderColor = _borderColor;
  }
  
  public void RestoreDefaultColor()
  {
    borderColor = defaultColor;
  }
}
