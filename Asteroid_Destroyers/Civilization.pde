public enum CivOrientation {
LEFT, RIGHT
}

public class Civilization
{
  ArrayList<Ship> fleet;
  ArrayList<Planet> planets;
  String name;
  private PVector topCorner;            //Which corner is this civilization in (0,0) or (width,0)
  CivOrientation orientation;
  
  TextWindow CivName;
  
  public Civilization(PVector _upperCorner, String _name, ArrayList<Ship> _fleet, ArrayList<Planet> _planets)
  {
    topCorner = _upperCorner;
    name = _name;
    fleet = _fleet;
    planets = _planets;
    
    //Determine civilization orientation (LEFT?RIGHT)
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
      CivName = new TextWindow("Civ name window", topCorner, windowSize, name, 15, false);
    }
    else
    { 
      PVector textLocation = new PVector(topCorner.x - windowSize.x, topCorner.y);
      CivName = new TextWindow("Civ name window", textLocation, windowSize, name, 15, false);
    }
    CivName.SetTextRenderMode(CENTER);
  }
  
  
  public void DrawCivilizationUI()
  {
    CivName.DrawObject();
  }
  
  //Place an icon in the upper-left corner of the civilization info screen
  public void SetCivilizationIcon(PImage _icon, int _size)
  {
    //HACK: the icon is rendering center and I don't see why -- just manually adjust with text window size
    CivName.AddIcon(new PVector(-CivName.size.x/2 + _size, CivName.size.y/2), 
    new PVector(_size, _size), _icon);
  }
  
}
