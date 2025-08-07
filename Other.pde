final int COLOR_WHITE = color(255, 255, 255);
final float DEFAULT_BORDER_PX = 8;

boolean isPositionFilledInGrid(PVector position) {

  for (Wall wall : walls) {
    if (wall.position.equals(position)) {
      return true;
    }
  }

  for (Food food : foodList) {
    if (food.position.equals(position)) {
      return true;
    }
  }

  return player1.occupiesPosition(position) || player2.occupiesPosition(position);
}


void drawCharacterInGrid(String character, PVector position, color fillColor) {
  fill(fillColor);

  textAlign(CENTER, CENTER);
  text(character, position.x * gridCellSizePx + (gridCellSizePx/2), position.y * gridCellSizePx + (gridCellSizePx/2));
  textAlign(LEFT, BASELINE);
}


void drawRectInGrid(PVector position) {
   drawRectInGrid(position, false);
}

void drawRectInGrid(PVector position, boolean animated) {
  drawRectInGrid(position, animated, 1000);
}

void drawRectInGrid(PVector position, boolean animated, float durationPerPulse) {
   float rectX = position.x * gridCellSizePx;
  float rectY =  position.y * gridCellSizePx;
  float border = DEFAULT_BORDER_PX;
  if (animated) {  
   border = getPulseValue( millis(), DEFAULT_BORDER_PX, 24, durationPerPulse);   
  }
  rect(rectX,rectY, gridCellSizePx, gridCellSizePx , border );
  
}

float getPulseValue(float time, float minVal, float maxVal, float duration) {
  // Normalize time to loop duration
  float phase = (time % duration) / duration;

  // Sine wave over one loop
  float wave = sin(phase * TWO_PI);

  // Create eased pulse shape
  float eased = wave * wave;

  // Optional: fade out negative half to keep single pulse per loop
  if (wave < 0) eased = 0;

  // Map to desired range
  return lerp(minVal, maxVal, eased);
}


float getAnimatedValue(float time, float minVal, float maxVal) {
  // Sinusoidal oscillation: value between -1 and 1
  float wave = sin(time);

  // Normalize to 0–1
  float normalized = (wave + 1) / 2.0;

  // Scale to desired range
  return lerp(minVal, maxVal, normalized);
}

void drawRectInGrid(PVector position, color fillColor) {
  fill(fillColor);
  rect(position.x * gridCellSizePx, position.y * gridCellSizePx, gridCellSizePx, gridCellSizePx);
}
