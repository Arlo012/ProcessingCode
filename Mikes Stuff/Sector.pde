class Sector
{
  ArrayList<Asteroid> asteroids = new ArrayList<Asteroid>();
  ArrayList<Planet> planets = new ArrayList<Planet>();
  ArrayList<Enemy> enemies = new ArrayList<Enemy>();
 
  int maxAsteroids = 8;
  int minAsteroids = 1;
  int maxPlanets = 3;
  int minPlanets = 0;
  int maxEnemies = 5;
  int minEnemies = 0;
  
  int lengthX = 3*displayWidth; //9X9 grid
  int lengthY = 3*displayHeight;
  int positionX = 0;
  int positionY = 0;
  
  Sector()
  {
    for(int i=0; i<(int(random(minAsteroids,maxAsteroids))); i++)
    {
      Asteroid a = new Asteroid(random(0,lengthX-50), random(0,lengthY-50));
      asteroids.add(a);
    }
    for(int i=0; i<(int(random(minPlanets,maxPlanets))); i++)
    {
      Planet p = new Planet(random(0,lengthX-100), random(0,lengthY-100));
      planets.add(p);
    }
    for(int i=0; i<(int(random(minEnemies,maxEnemies))); i++)
    {
      Enemy e = new Enemy(random(0,lengthX-50), random(0,lengthY-50));
      enemies.add(e);
    }
  }
  
  void display()
  {
    
  }
}
