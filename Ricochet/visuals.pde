
//Create objective color splotch (LL and LR)
void DrawColorObjectives()
{
  //Create objective color splotch (LL and LR)
  fill(colorObj1);
  rect(0, height - colorPalleteSize, colorPalleteSize, colorPalleteSize);
  fill(colorObj2);
  rect(width - colorPalleteSize , height - colorPalleteSize, colorPalleteSize, colorPalleteSize);
}

void DrawDottedLine()
{
  //Draw middle line
  fill(255,100);
  rect(width/2 - 3, 0, 6, height);
  
  //Create dashed effect
  int dashSize = 10;
  while(dashSize < height)
  {
    fill(0);
    rect(width/2 -3, dashSize, 6, 10);
    dashSize += 20;
  }
}

//Draw points and lives
void DrawScores()
{
  //Score
  fill(color(255));
  textAlign(LEFT, CENTER);
  text(scoreP1, 50,50);
  textAlign(RIGHT, CENTER);
  text(scoreP2, width-50,50);
  
  //Lives
  textAlign(LEFT, CENTER);
  text(p1Lives, 50,125);
  textAlign(RIGHT, CENTER);
  text(p2Lives, width-50,125);
}

//Draws all rects in the tile arraylist
void DrawGrid()
{
  for(Tile m : Tiles)
  {
    fill(m.myColor);
    
    if(EpilepsyMode)
    {
      if(flashCounter % flashInterval == 0)
      {
        //BROKEN this breaks the newly implemented behavior of powerups, but looks cool
        m.updateColor();
      }
    }
    
    if(flashCounter % flashInterval == 0 && m.isPowerup)
    {
      m.flash();
    }
    
    //Define Tile shape here
    rect(m.location.x, m.location.y, m.size, m.size);
  }
}

//Draw all of the help text before the game starts
void DrawIntoScreen()
{
  textFont(font, 40);
  //Intro text
  fill(color(255));
  textAlign(LEFT, CENTER);
  text("<- P1 score", 150,50);
  textAlign(RIGHT, CENTER);
  text("P2 score ->", width-150,50);
  
  textAlign(LEFT, CENTER);
  text("<- P1 lives", 150,125);
  textAlign(RIGHT, CENTER);
  text("P2 lives ->", width-150,125);
  
  textFont(font, 30);
  textAlign(LEFT, CENTER);
  text("<- P1 hit this color for points", 110,height-30);
  textAlign(RIGHT, CENTER);
  text("P2 hit this color for points ->", width-110,height-80);
  
  textAlign(LEFT, CENTER);
  
  text("Player 1:", 25, height/2 - 120);
  text("W/S move", 25, height/2 - 90);
  text("Press (1) for ghost powerup (300 pts)", 25, height/2 - 60);
  text("Press (2) to scramble opponent's color (200 pts)", 25, height/2 - 30);
  text("Press (3) for a new objective color (100 pts)", 25, height/2);
  
  text("Player 2:", 25, height/2 + 50);
  text("Up/Down arrow move", 25, height/2 + 80);
  text("Press (i) for ghost powerup (300 pts)", 25, height/2 +110);
  text("Press (o) to scramble opponent's color (200 pts)", 25, height/2 + 140);
  text("Press (p) for a new objective color (100 pts)", 25, height/2 + 170);
  
  textFont(font, 40);   
  textAlign(CENTER,CENTER);
  text("Press ENTER to begin", width/2,height/2 - 175);
  
  textFont(font, 72);    //Return to standard font
}


//Draw a screen pulsing effect prior to a ball spawning with a countdown until it starts moving
void DrawBallSpawnPulsing(float duration, float timeLeft)
{
  //Spawn timer text
  fill(color(255));
  textAlign(CENTER, CENTER);
  text(int(pulseTimeLeft), width/2, 50);
  //println(pulseTimeLeft/pulseDisplayDuration * 250);
  
  backgroundColor = color(pulseTimeLeft/pulseDisplayDuration * 250);
  
}
