//
// 2012 :: woody(at)hysteria(dot)sk
//
final int level_size=12;
final int maxlevels = 10;
final int levelshift = 2;
final int count = 5;
final int count_max = 6;
final int count_min = 3;

class Vec {
  int x;
  int y;
  int radius1;
  int radius2;
  float angle1;
  float angle2;
  float angle_space;
  float mov;
  int state; // 2 - born  1 - living  0 - dying 42 - dead
  int level;
  int growth;
  int sg;  // stroke growth  

  Vec(int level_) {
    // generate some random data
    angle1 = random(360);
    angle2 = angle1 + random(90, 270);
    float speed;
    level =  level_;    
    
    
    if (level < 5) {
      angle_space=random(12, 14);
      speed=random(6)-3;
    } 
    else {
      speed=random(0.2, 0.8);
      if (random(2)<1) {
        speed*=-1;
      }
      angle_space=random(3, 10);
    }
    
    x = width/2;
    y = height/2;
    radius1 = level_size*(level*2);
    radius2 = level_size*((level*2)+1);
    mov = speed;
    growth = int(random(2, 5));
    state = 2;
    sg = 0;
  }

  int getState() {
    return state;
  }
  
  int getLevel() {
    return level;
  }

  void die(int poison_) {
    growth = poison_;
    state = 0;
  }

  void display() {
    // magic
    if (state==2) {
      if (sg+growth > 255) {
        sg=255;
      } 
      else {
        sg+=growth;
      }
    }
    if (state==0) {
      if (sg-growth <= 0) {
        sg=0;
        state = 42;
      } 
      else {
        sg-=growth;
      }
    }

    // actual drawing
    for (float i=angle1 ; i <= angle2 ; i += angle_space) {
      stroke(sg);
      line(x+cos(radians(i))*radius1, y+sin(radians(i))*radius1, x+cos(radians(i))*radius2, y+sin(radians(i))*radius2);
      stroke(sg, 0, 0);
      ellipse(x+cos(radians(i))*(radius2+3), y+sin(radians(i))*(radius2+3), 4, 4);
    }
    angle1+=mov;
    angle2+=mov;
  }
}

class MegaVec {
  int count;
  ArrayList veci;
  int levels[] = new int[maxlevels];

  int howMuch() {
    int alive=0;
    for (int i=0;i < veci.size(); i++){
      Vec vec = (Vec) veci.get(i);
      if (vec.getState()==2) {
        alive++;
      }
    }
    return alive;
  }
  
  void initLevels() {
    for (int i=0; i<maxlevels; i++) {
      levels[i]=0;
    }
  }

  int getRandomFreeLevel() {
    int i;
    int j = 0;
    int freelevels[] = new int[maxlevels];
    
    for (i = 1; i < maxlevels; i++) {
      if (levels[i]==0) {
        freelevels[j]=i;
        j++;
      }
    }
    if (j>0) {
      int randlevel = freelevels[int(random(0,j))];
      levels[randlevel] = 1;
      return randlevel;
    } else {
      return -1;
    }
  }


  MegaVec(int count_)
  {
    initLevels();
    count = count_;
    veci = new ArrayList();

    int level;
    for (int i=0; i<count; i++) {
      level = getRandomFreeLevel();
      veci.add(new Vec(level));
    }
  }


  void display() {
    for (int i=0; i<veci.size(); i++) {
      Vec vec = (Vec) veci.get(i);
      vec.display();
      if (vec.getState()==42) {
        levels[vec.getLevel()]=0;
        veci.remove(i);
      }
    }
  }

  void evolve(int destiny) {
    Vec vec;
    int level;
    int i;

    // killing
    if (destiny==1) {
      do {
        i = int(random(0, veci.size()-1));
        vec = (Vec) veci.get(i);
      } 
      while (vec.getState () != 2);
      vec.die(int(random(2, 5)));
    } 
    // creating
    else {
      level = getRandomFreeLevel();
      if (level!=-1) {
        veci.add(new Vec(level));
      }
    }
  }
}


MegaVec megaVec;


void setup() 
{
  size(700, 700);
  background(0);
  frameRate(30);  
  stroke(255);
  smooth();
  strokeWeight(2.0);
  strokeCap(ROUND);

  megaVec = new MegaVec(count);
}

void teleport()
{
  int mmm = 10000000;
  for (int i=0; i<mmm; i++)
    fill(0, (255/mmm)*i);
  setup();
}

void draw() 
{
  noStroke();
  fill(0, 120);
  rect(0, 0, width, height); 


  megaVec.display();


  if (int(random(0, 100))==1) {
    if (megaVec.howMuch() <= count_min) {
      megaVec.evolve(2);
    } else if (megaVec.howMuch() >= count_max) {
      megaVec.evolve(1);
    } else {
      megaVec.evolve(int(random(1,3)));
    }
  }
}

