class Wall {

  PVector position;
  private int maxNumberOfFramesVisible = (int)frameRate * 15;//the harcoded number basically means number of seconds the wall should be visible
  private int numberOfFramesVisible = 0;
  private boolean dissapear = true;

  Wall(PVector position, boolean dissapear) {
    this.position= position;
    this.dissapear=dissapear;
  }

  void draw() {

    if (dissapear) {
      numberOfFramesVisible++;
      float transparancy = map(numberOfFramesVisible, 0, maxNumberOfFramesVisible, 255, 0);
      fill(255, 255, 0, transparancy);
    } else {
      fill(255, 255, 0);
    }

    drawRectInGrid(position);
  }

  boolean isVisible() {
    return numberOfFramesVisible <= maxNumberOfFramesVisible;
  }
}
