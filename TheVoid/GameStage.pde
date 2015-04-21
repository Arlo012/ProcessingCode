//A string container for the game stage we are currently in
public class GameStage
{
  private String stageName;
  
  public GameStage(String _stageName)
  {
    stageName = _stageName;
  }
  
  public String GetStage()
  {
    return stageName;
  }
  
}
