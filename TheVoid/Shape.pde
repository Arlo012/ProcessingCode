public static enum ShapeType {
  _SQUARE_, _TRIANGLE_, _CIRCLE_
}

/*
 * UI shape (Square, circle, triangle allowed)
*/
public class Shape extends Drawable
{
  public ShapeType shapeType;
  public color borderColor;
  
  private color defaultColor;
  private boolean colorSet;          //Allow only one initial set of color after the constructor's default
  private color fillColor;
  
  public Shape(String _name, PVector _loc, PVector _size, color _color, ShapeType _shapeType)
  {
    super(_name, _loc, _size);
    borderColor = _color;
    defaultColor = borderColor;
    shapeType = _shapeType;
    colorSet = false;
    fillColor = color(255,255,255,0);
  }
  
  @Override public void DrawObject()
  {
    pushMatrix();
    translate(location.x, location.y);
    pushStyle();
    stroke(borderColor);
    fill(fillColor);
    
    if(shapeType == ShapeType._SQUARE_)
    {
      rectMode(renderMode);
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
  
  public void SetFillColor(color _fillColor)
  {
    fillColor = _fillColor;
  }
  
  public void SetIcon(color _color, ShapeType _type)
  {
    if(!colorSet)
    {
      //Set shape type
      shapeType = _type;
      
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
