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
