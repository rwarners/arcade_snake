PImage head;
float screenFontSize;

String escapeButton; //text to show what to press to quit
String buttonText; //text to show what to press to continue (key or button)
Checkbox[] boxes;
ArcadeTitle title;

void setupScreens() {
  head = loadImage("snake_head.png");
  head.resize(head.width*2, head.height*2);
  screenFontSize = constrain(width * 0.04, 12, 72); // 5% of width, between 12 and 72 px
  textFont(createFont("Pixel Game.otf", screenFontSize));
  
  if (detectJoystick()) {
    escapeButton = "SELECT";
    buttonText = "BUTTON";
  } else {
    escapeButton = "Escape";
    buttonText = "key";
  }
  
  title = new ArcadeTitle("VIPR", width / 2, height / 4, true);
}

void  renderIntroScreen() {
  drawCenterSquare();
  fill(COLOR_WHITE);
    
 for (Checkbox cb : boxes) {
    cb.display();
  }

  textAlign(CENTER, BASELINE);

  //text("Welcome!", width/2, height/2 -200);
  
  title.display();
  fill(COLOR_WHITE);
  text("Press any "+buttonText+" to start", width/2, (height/2) + screenFontSize - 200);
  textAlign(LEFT, BASELINE);
}


void renderGameOver() {
  drawCenterSquare();
  fill(255, 255, 255);
  textAlign(CENTER, CENTER);
  text("GAME OVER!", width/2, height/2 - 20);
  text("Press any " + buttonText +" to start", width/2, height/2 + 40);
  textAlign(LEFT, BASELINE);

  //noLoop();
  gameState = GameState.GAME_OVER;
  //loop();
}




void renderPauseScreen() {
  
  drawCenterSquare();
  fill(COLOR_WHITE);
    
  boxes[0].display();
  boxes[1].display();
  boxes[2].display();
  
  textAlign(CENTER, BASELINE);

  title.display();
  fill(COLOR_WHITE);
  text("Press any "+buttonText+" to start", width/2, (height/2) + screenFontSize - 200);
  textAlign(LEFT, BASELINE);
  
  //drawCenterSquare();
  //fill(255, 255, 255);
  //textAlign(CENTER, BASELINE);
  //text("Zzzzz.....", width/2, height/2 );
  //text("Press any " + buttonText + " to continue", width/2, height/2 + screenFontSize);
  //text("or " + escapeButton +" to quit", width/2, height/2 + screenFontSize * 2);
  textAlign(LEFT, BASELINE);
}



//sort of a Panel where you can draw text on
private void drawCenterSquare() {
  stroke(30, 30, 30);
  strokeWeight(8);
  fill(0, 0, 0, 240);
  rectMode(CENTER);
  
  rect(width / 2, height / 2, width/2, height/2, 22);

  image(head, width / 2 -  width/4 + 10, height / 2 - height/4 + 10);
  //back to defaults
  rectMode(CORNER);
  strokeWeight(4);
  noStroke();
}

//visual effect for title
class ArcadeTitle {
  String text;
  float x, y;
  boolean useColorCycle;
  color[] palette;

  ArcadeTitle(String text, float x, float y, boolean useColorCycle) {
    this.text = text;
    this.x = x;
    this.y = y;
    this.useColorCycle = useColorCycle;

    // Classic 8-bit palette
    palette = new color[] {
      color(255, 0, 0),     // Red
      color(255, 165, 0),   // Orange
      color(255, 255, 0),   // Yellow
      color(0, 128, 255),   // Blue
      color(0, 255, 0),     // Green
      color(255, 255, 255)  // White
    };
  }

  void display() {
    textAlign(CENTER, CENTER);

    // Wiggle via zoom and rotation
    float scaleFactor = 1.0 + sin(frameCount * 1.5) * 0.3;   

      // Smooth color transition
    color currentColor = color(255); // Default white
    if (useColorCycle) {
      int index = frameCount / 60 % palette.length;
      int nextIndex = (index + 1) % palette.length;
      float t = (sin(frameCount * 0.05) + 1) / 2.0; // Smooth oscillation between 0–1
      currentColor = lerpColor(palette[index], palette[nextIndex], t);
    }
    
    pushMatrix();
    translate(x, y);    
    scale(scaleFactor);

    // Faux shadow
    fill(0);
    text(text, 2, 2);
    
    fill(currentColor);
    text(text, 0, 0);
    popMatrix();
  }
}
