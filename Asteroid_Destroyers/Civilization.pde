public enum CivOrientation {
LEFT, RIGHT
}

public class Civilization
{
  ArrayList<Ship> fleet;
  String name;
  PVector topCorner;
  CivOrientation orientation;
  
  TextWindow CivName;
  
  
  public Civilization(PVector _upperCorner, String _name, ArrayList<Ship> _fleet)
  {
    topCorner = _upperCorner;
    name = _name;
    fleet = _fleet;
    if(PVector.dist(topCorner,new PVector(0,0)) == 0)
    {
      orientation = CivOrientation.LEFT;
    }
    else if(PVector.dist(topCorner,new PVector(width,0)) == 0)
    {
      orientation = CivOrientation.RIGHT;
    }
    else
    {
      orientation = CivOrientation.RIGHT;
      println("ERROR: Incorrectly assigned civilization corner. Assuming right-side");
    }
    
    
    //Build civ name window based on side
    PVector windowSize = new PVector(250,50);
    if(orientation == CivOrientation.LEFT)
    {
      CivName = new TextWindow(topCorner, windowSize, name, 50);
    }
    else
    { 
      PVector textLocation = new PVector(topCorner.x - windowSize.x, topCorner.y);
      CivName = new TextWindow(textLocation, windowSize, name, 50);
    }
    CivName.SetTextRenderMode(CENTER);
    
    
  }
  
  public void DrawCivilizationUI()
  {
    //println(CivName.location);
    CivName.DrawObject();
  }
  
  public void SetCivilizationIcon(PImage _icon, int _size)
  {
    CivName.AddIcon(new PVector(10,10), new PVector(_size, _size), _icon);
  }
  
}
