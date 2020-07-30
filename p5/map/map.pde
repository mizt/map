int frame = 0;

int map(int x,int y) {

  int ab = 0x7FFF+(x<<2);
  int gr = 0x7FFF+(y<<2);  
  return (ab&0xFF00)<<16|(gr&0xFF)<<16|(gr&0xFF00)|ab&0xFF;

}

void setup(){
  
  size(128,128);
  
  int w = 1920;
  int h = 1080;
  
  PImage img = createImage(1920,1080, ARGB);
  for(int i=0; i<h; i++) {
    for(int j=0; j<w; j++) {  
      img.pixels[i*w+j] = map(j,i);
    }
  }
  img.save(nf(frame,5)+".png");
  
  exit();
}
