/* --------------------------------------------------------------------------
 * SimpleOpenNI DepthImage Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;


SimpleOpenNI  context;

import deadpixel.keystone.*;

Keystone ks;
CornerPinSurface surface;

PGraphics offscreen;
PImage imageSpring, imageSummer, imageOutumn, imageWinter, white, brown, brown2, brown3, green, green2, green3, bird, fish, tree, veado;

int cropLeft = 10; 
int cropRight = 10;
int cropTop = 10;
int cropBottom = 90;
boolean cropping = false;

SandboxImageLayer imageLayer, catImageLayer, catShitImageLayer, brownImageLayer, springImageLayer;


ArrayList<String> veados = new ArrayList<String>();
ArrayList<String> peixes = new ArrayList<String>();
ArrayList<String> trees = new ArrayList<String>();
ArrayList<String> birds = new ArrayList<String>();


int saved_time;

void setup() {
  fullScreen(P3D, 2); // 2 - second screen (projector) must be in extend mode

  //size(640, 480, P3D);
  context = new SimpleOpenNI(this);
  saved_time = millis();
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }

  // enable depthMap generation 
  context.enableDepth();

  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(width, height, 20);
  ks.load();

  offscreen = createGraphics(width, height, P3D);


  //imageLayer = new SandboxImageLayer(loadImage("girlwithbunny-closeup.jpg"), 100, 100, 100, 100, 800);


  brownImageLayer = new SandboxImageLayer(loadImage("brown.jpg"), 0, 0, 600, 350, 745, 22);

  catImageLayer = new SandboxImageLayer(loadImage("relva.jpg"), 0, 0, 600, 350, 785, 22);
  //catImageLayer = new SandboxImageLayer(loadImage("green.jpg"), 0, 0, 640, 480, 750);
  catShitImageLayer = new SandboxImageLayer(loadImage("agua.jpg"), 0, 0, 600, 350, 830, 22);//TODO
  //catShitImageLayer = new SandboxImageLayer(loadImage("blue.jpg"), 0, 0, 640, 480, 780);
  bird = loadImage("passaro.png");
  fish = loadImage("peixe.png");
  tree = loadImage("tree.png");
  veado = loadImage("veado.png");
  imageSpring = loadImage("primavera.png");
  imageSummer = loadImage("verão.png");
  imageOutumn = loadImage("outono.png");
  imageWinter = loadImage("inverno.png");
  green = loadImage("relva.jpg");
  green2 = loadImage("relva2.jpg");
  green3 = loadImage("relva3.jpg");
  brown = loadImage("brown.jpg");
  brown2 = loadImage("brown2.jpg");
  brown3 = loadImage("brown3.jpg");
  white = loadImage("white.jpg");
}

void draw() {
  context.update();
  int croppedWidth = (640-cropLeft-cropRight);
  int croppedHeight = (480-cropBottom-cropTop);


  /* Crop the depth map*/
  int depthMap[] = new int[croppedWidth * croppedHeight]; 
  for (int i = cropTop; i < 480-cropBottom; i++) {
    arrayCopy(context.depthMap(), i*640+cropLeft, depthMap, (i-cropTop)*croppedWidth, croppedWidth);
  }

  /* Crop the 3D map*/
  PVector[] realWorldMap = new PVector[croppedWidth * croppedHeight]; 
  for (int i = cropTop; i < 480-cropBottom; i++) {
    arrayCopy(context.depthMapRealWorld(), i*640+cropLeft, realWorldMap, (i-cropTop)*croppedWidth, croppedWidth);
  }

  /* Crop the depth image*/
  PImage depthImage = context.depthImage().get(cropLeft, cropTop, 640-cropRight-cropLeft, 480-cropBottom-cropTop);

  // Draw the scene, offscreen

  offscreen.beginDraw();
  offscreen.background(0);


  // Draw depth data as color green to red
  /*
  int steps = 10;
   offscreen.noStroke();
   color fromColor = color(0, 255, 0);
   color toColor = color(255, 0, 0);
   for (int y=0; y < croppedHeight; y+=steps) {
   for (int x=0; x < croppedWidth; x+=steps) {
   
   int index = x + y * croppedWidth;
   offscreen.fill (lerpColor(fromColor, toColor, map(depthMap[index], 720, 800, 0, 1)));
   offscreen.rect(map(x, 0, croppedWidth, 0, width), map(y, 0, croppedHeight, 0, height), 20, 20);
   // println(x, y, depthMap[index]);
   }
   } 
   */
  // Draw depth image
  /*
  offscreen.pushMatrix();
   offscreen.scale(width*1.0/depthImage.width, height*1.0/depthImage.height);
   offscreen.image(depthImage, 0, 0);//, width, height);
   offscreen.popMatrix();
   */


  if (cropping) {
    offscreen.stroke(#ff0000);
    offscreen.line(0, cropTop, width, cropTop);
    offscreen.line(0, height-cropBottom, width, height-cropBottom);
    offscreen.line(cropLeft, 0, cropLeft, height);
    offscreen.line(width-cropRight, 0, width-cropRight, height);
  } 


  // Regions are defined in the original image reference (640x480) so we need to scale them
  offscreen.pushMatrix();
  offscreen.scale(width*1.0/depthImage.width, height*1.0/depthImage.height);
  // imageLayer.run(depthImage, realWorldMap);
  //imageLayer.draw(offscreen);
  catImageLayer.run(depthImage, realWorldMap);
  catImageLayer.draw(offscreen);

  catShitImageLayer.run(depthImage, realWorldMap);
  catShitImageLayer.draw(offscreen);

  brownImageLayer.run(depthImage, realWorldMap);
  brownImageLayer.draw(offscreen);

  offscreen.popMatrix();




  // Show depth of the cursor point
  PVector surfaceMouse = surface.getTransformedMouse();
  int mX = (int)map(surfaceMouse.x, 0, width-1, 0, croppedWidth-1);
  mX = constrain(mX, 0, croppedWidth-1);
  int mY = (int)map(surfaceMouse.y, 0, height-1, 0, croppedHeight-1);
  mY = constrain(mY, 0, croppedHeight-1);
  //println(mX, mY, red(depthImage.pixels[mY*depthImage.width+mX]));
  offscreen.stroke(0, 0, 255);
  offscreen.strokeWeight(5);
  offscreen.noFill();
  offscreen.ellipse(surfaceMouse.x, surfaceMouse.y, 75, 75);
  offscreen.fill(255, 0, 0);
  offscreen.textSize(63);
  offscreen.text(""+realWorldMap[mY*croppedWidth+mX].z, surfaceMouse.x, surfaceMouse.y);



  offscreen.endDraw();



  background(0);
  surface.render(offscreen);



  float aux = realWorldMap[25*croppedWidth+525].z;

  //float aux = realWorldMap[455*croppedWidth+635].z;

  //println(aux + "altura");
  //println(mouseX + "mouseX");
  //println(mouseY + "mouseY");


  //*********************************** MENU CANTO SUPERIOR DIREITO *****************************************
  if (aux > 800) {
    image(imageSpring, 1011, 100, 100, 100);
    brownImageLayer = new SandboxImageLayer(brown, 0, 0, 600, 350, 745, 22);
    catImageLayer = new SandboxImageLayer(green2, 0, 0, 600, 350, 785, 22);
    SoundFile file;
    file = new SoundFile(this, "gaivotas_loucas.wav");
    file.play();
    /*
    for (int i=0;i<6;i++){
      //file = new SoundFile(this, "gaivotas_loucas.wav");
      //file.play();
      image(bird, i*50, i*20, 50, 50);
      image(bird, 0+((i+1)*50), 0+((i+1)*20), 50, 50);
      image(bird, i*50, (20+i)*20, 50, 50);
      //delay(5000);
    }
    */
    /*
    Se for primavera o spassaros surgem do canto superior esquerdo
     */
  } else if (aux > 785 && aux <= 800) {
    image(imageSummer, 1011, 100, 100, 100);
    brownImageLayer = new SandboxImageLayer(brown, 0, 0, 600, 350, 745, 40);
    catImageLayer = new SandboxImageLayer(green, 0, 0, 600, 350, 785, 30);
  } else if (aux > 770 && aux <= 785) {
    image(imageOutumn, 1011, 100, 100, 100);
    brownImageLayer = new SandboxImageLayer(brown2, 0, 0, 600, 350, 745, 22);
    catImageLayer = new SandboxImageLayer(brown3, 0, 0, 600, 350, 785, 22);
  } else if (aux > 730 && aux <= 770) {
    image(imageWinter, 1011, 100, 100, 100);
    brownImageLayer = new SandboxImageLayer(white, 0, 0, 600, 350, 745, 22);
    catImageLayer = new SandboxImageLayer(green3, 0, 0, 600, 350, 785, 22);
  } 

  int choice_esp = 0;
  //************************************** MENU CANTO ESQUERDO SUPERIOR ************************************
  float aux1 = realWorldMap[25*croppedWidth+25].z;
  if (aux1 > 800) {
    image(veado, 50, 70, 100, 100);
    choice_esp = 1;
  } else if (aux1 > 785 && aux1 <= 800) {
    image(fish, 50, 70, 100, 100);
    choice_esp = 2;
  } else if (aux1 > 770 && aux1 <= 785) {
    image(tree, 50, 70, 100, 100);
    choice_esp = 3;
  } else if (aux1 > 730 && aux1 <= 770) {
    image(bird, 50, 70, 100, 100);
  } 




  
  int passed_time;
  
  int flag = 0;
  for (int x=0; x<croppedWidth; x++) {
    for (int y=0; y<croppedHeight; y++) {
      //passed_time = 0;
      //saved_time = 0;
      if (realWorldMap[y*croppedWidth+x].z > 550 && realWorldMap[y*croppedWidth+x].z <= 730 ) {
        
        passed_time = millis()-saved_time;

        if (passed_time > 15000) {
          float x2 = map(x, 0, 600, 0, 1150);
          float y2 = map(y, 0, 480, 0, 1070);
         
          ellipse(x2, y2, 50, 50);
          fill(0, 255, 255);
          if (choice_esp == 3) {

            image(tree, x2, y2, 50, 50);
            String coord = x2+" "+y2;
            trees.add(coord);
         
            saved_time =millis();
           
          } else if (choice_esp == 1) {
            image(veado, x2, y2, 50, 50);
            String coord = x2+" "+y2;
            veados.add(coord);
          
            saved_time =millis();
          } else if (choice_esp == 2) {
            image(fish, x2, y2, 50, 50);
            String coord = x2+" "+y2;
            peixes.add(coord);
            
            saved_time =millis();
          }

          //image(fish, x2, y2, 50, 50);
          flag = 1;
          break;
        }
      }
    }
    if (flag == 1) {
      
      break;
    }
  }

  //*********************** DRAW ANIMALS **********************
  for (int i=0; i<trees.size(); i++) {
    String[] cont = trees.get(i).split(" ");
    String coord_x = cont[0];
    String coord_y = cont[1];

    image(tree, Float.parseFloat(coord_x), Float.parseFloat(coord_y), 100, 100);
  
  }


  for (int i=0; i<veados.size(); i++) {
    String[] cont = veados.get(i).split(" ");
    String coord_x = cont[0];
    String coord_y = cont[1];

    image(veado, Float.parseFloat(coord_x), Float.parseFloat(coord_y), 100, 100);

  }

  for (int i=0; i<peixes.size(); i++) {
    String[] cont = peixes.get(i).split(" ");
    String coord_x = cont[0];
    String coord_y = cont[1];

    image(fish, Float.parseFloat(coord_x), Float.parseFloat(coord_y), 100, 100);
  }
}

void keyPressed() {
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;
  }
}