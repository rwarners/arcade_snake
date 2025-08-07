void setupSettings() {
  boxes = new Checkbox[3];
  int centerX =  width/2 - 150;
  int centerY =  height/2;
  boxes[0] = new Checkbox(centerX, centerY, "Big grid", 30);
  boxes[1] = new Checkbox(centerX, centerY+screenFontSize, "Power ups", 30);
  boxes[2] = new Checkbox(centerX, centerY+screenFontSize+screenFontSize, "Walls dissapear", 30);

  final Checkbox cb1 = boxes[0];
  cb1.setChecked(gridWidth==48);
  cb1.setOnToggle(() -> {
    if (cb1.isChecked()) {
      updateGridSizes(48);
    } else {
      updateGridSizes(32);
    }
  }
  );

  final Checkbox cb2= boxes[1];
  cb2.setChecked(powerUps);
  cb2.setOnToggle(() -> {
    powerUps = cb2.isChecked();
  }
  );

  final Checkbox cb3= boxes[2];
  cb3.setChecked(wallsDissapear);
  cb3.setOnToggle(() -> {
    wallsDissapear = cb3.isChecked();
  }
  );
}

void selectNextCheckboxDown() {
  for (Checkbox cb : boxes) {
    cb.setHighlighted(false);
  }
  highLigtedCheckBoxIndex++;
  if (highLigtedCheckBoxIndex> boxes.length-1) {
    highLigtedCheckBoxIndex = 0;
  }
  boxes[highLigtedCheckBoxIndex].setHighlighted(true);
}

void selectNextCheckboxUp() {
  for (Checkbox cb : boxes) {
    cb.setHighlighted(false);
  }
  highLigtedCheckBoxIndex--;
  if (highLigtedCheckBoxIndex< 0) {
    highLigtedCheckBoxIndex = boxes.length-1;
  }
  boxes[highLigtedCheckBoxIndex].setHighlighted(true);
}


void checkboxToggle() {
  for (Checkbox cb : boxes) {
    if (cb.isHighlighted()) {
      cb.toggle();
    }
  }
}


class Checkbox {
  float x, y;
  String label;
  float size;
  boolean checked = false;
  boolean highlighted = false;

  PShape box;
  PShape checkmark;

  Runnable onToggle = null;

  Checkbox(float x, float y, String label, float size) {
    this.x = x;
    this.y = y;
    this.label = label;
    this.size = size;
    createShapes();
  }

  void createShapes() {
    box = createShape(RECT, 0, 0, size, size, 8);
    box.setStroke(true);
    box.setStrokeWeight(2);
    box.setStroke(color(50));
    box.setFill(COLOR_WHITE);

    checkmark = createShape();
    checkmark.beginShape();
    checkmark.stroke(0);
    checkmark.strokeWeight(4);
    checkmark.noFill();

    float s = size / 30.0;
    checkmark.vertex(6 * s, 16 * s);
    checkmark.vertex(12 * s, 22 * s);
    checkmark.vertex(24 * s, 8 * s);
    checkmark.endShape();
  }

  void display() {
    pushMatrix();
    translate(x, y);

    // Highlighted background
    if (highlighted) {
      fill(220, 240, 255);
      stroke(0, 200, 0);
      strokeWeight(2);
      rect(-4, -4, size + 8, size + 8, 8);
    }

    shape(box);
    if (checked) {
      shape(checkmark);
    }
    popMatrix();

    // Wiggle effect for highlighted text
    float wiggleOffset = 0;
    if (highlighted) {
      wiggleOffset = sin(frameCount * 2) * 2; // Adjust frequency and amplitude
    }

    fill(COLOR_WHITE);
    textAlign(LEFT, CENTER);
    text(label, x + size + 10 + wiggleOffset, y + size / 2);
  }

  void checkClick(float mx, float my) {
    if (mx > x && mx < x + size && my > y && my < y + size) {
      toggle();
    }
  }

  void toggle() {
    checked = !checked;
    if (onToggle != null) {
      onToggle.run();
    }
  }

  void setOnToggle(Runnable r) {
    onToggle = r;
  }

  boolean isChecked() {
    return checked;
  }

  void setChecked(boolean checked) {
    this.checked=checked;
  }

  void setHighlighted(boolean h) {
    highlighted = h;
  }

  boolean isHighlighted() {
    return highlighted;
  }
}
