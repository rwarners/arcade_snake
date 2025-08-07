import processing.sound.*;

void setupSound(){
  soundManager = new SoundManager(this);
}

class SoundManager {
  SoundFile moveSound;
  SoundFile startSound;
  SoundFile foodSound;
  SoundFile gameOverSound;
  SoundFile musicSounds;

  SoundManager(PApplet parent) {
    try {
      //moveSound = new SoundFile(parent, "beep.wav");
      startSound = new SoundFile(parent, "game-start-6104.mp3");      
      foodSound = new SoundFile(parent, "beep2.wav");
      gameOverSound = new SoundFile(parent, "game-over-arcade-6435.mp3");
      musicSounds = new SoundFile(parent, "TMNT_NES_OVERWORLD_small.mp3");

      // Set volumes      
      //moveSound.amp(0);
    }
    catch (Exception e) {
      e.printStackTrace();
      println("Warning: Could not load sound files");
    }
  }
  
  void playMusic() {
    if (musicSounds != null && !musicSounds.isPlaying()) {
      musicSounds.loop();
    }
  }
  
   void stopMusic() {
    if (musicSounds != null) musicSounds.stop();
  }

  void playMove() {
    if (moveSound != null) {      
      moveSound.play();
    }
  }

  void playStart() {
    if (startSound != null) startSound.play();
  }

  void playFood() {
    if (foodSound != null) foodSound.play();
  }

  void playGameOver() {
    if (gameOverSound != null) gameOverSound.play();
  }
}
