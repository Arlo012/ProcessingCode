public static enum ShapeType {
  _SQUARE_, _TRIANGLE_, _CIRCLE_, _RECTANGLE_
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
  
  public PVector triangleOffset;    //If in triangle mode, how much to offset triangle
  public float triangleRotate;    //If in triangle mode, angle to rotate in radians

  public Shape(String _name, PVector _loc, PVector _size, color _color, ShapeType _shapeType)
  {
    super(_name, _loc, _size);

    //Color & shape setup
    borderColor = _color;
    defaultColor = borderColor;
    shapeType = _shapeType;
    colorSet = false;
    fillColor = color(255,255,255,0);

    //Triangle offsets -- used in shields
    triangleOffset = new PVector(0,0);
    triangleRotate = 0;
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
      if(size.x != size.y)
      {
        println("[WARNING] Square shape being force-rendered with rectangle edges!");
      }
      
    }
    if(shapeType == ShapeType._RECTANGLE_)
    {
      rectMode(renderMode);
      rect(0, 0, size.x, size.y); 
    }
    else if(shapeType == ShapeType._TRIANGLE_)
    {
      //HACK the Y dimension of size is totally ignored here!
      translate(triangleOffset.x, triangleOffset.y);
      rotate(triangleRotate);
      float a = size.x;
      float r = a * sqrt(3)/6;      //See http://www.treenshop.com/Treenshop/ArticlesPages/FiguresOfInterest_Article/The%20Equilateral%20Triangle.htm
      float R = r * 2;
    
      beginShape(TRIANGLES);
      vertex(0,0);
      vertex(r+R, 7*a/8);
      vertex(r+R, -7*a/8);
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
