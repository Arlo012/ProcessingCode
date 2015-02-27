public interface Movable
{
  void Move();
  void ChangeVelocity(PVector _vector);
}

public interface Turnable
{
  void SetDestinationAngle(float _destinationAngle);
  void SetRotationMode(int _rotateMode);      // 0 = instant, 1 = standard
  void SetRotationRate(float _degreePerSec);
  void SetRotationTarget(PVector _target);
}

public interface Collidable
{
  void HandleCollision(Physical _collider);
}

enum ClickType{
  INFO, TARGET
}
public interface Clickable
{
  void UpdateUIInfo();          //Update the location and any text/ UI information in the given window
  ClickType GetClickType();
  void Click();
}
