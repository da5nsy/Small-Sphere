/*
 Fade example mod
 */

int led_uv =    3;           // the PWM pin the LED is attached to
int led_blue =  5;     
int led_amber = 9;           
int led_red =   10;           

int brightness_uv =     0;    // how bright the LED is
int brightness_blue =   0;    
int brightness_amber =  0;    
int brightness_red =    0;   

int fadeAmount_uv =     250/10;    // how many points to fade the LED by
int fadeAmount_blue =   30/10;    
int fadeAmount_amber =  80/10;   
int fadeAmount_red =    80/10;    

// the setup routine runs once when you press reset:
void setup() {
  // declare pin 9 to be an output:
  pinMode(led_uv, OUTPUT);
  pinMode(led_blue, OUTPUT);
  pinMode(led_amber, OUTPUT);
  pinMode(led_red, OUTPUT);
}

// the loop routine runs over and over again forever:
void loop() {
  // set the brightness of pin 9:
  analogWrite(led_uv,     brightness_uv);
  analogWrite(led_blue,   brightness_blue);
  analogWrite(led_amber,  brightness_amber);
  analogWrite(led_red,    brightness_red);

  // change the brightness for next time through the loop:
  brightness_uv =     brightness_uv +     fadeAmount_uv;
  brightness_blue =   brightness_blue +   fadeAmount_blue;
  brightness_amber =  brightness_amber +  fadeAmount_amber;
  brightness_red =    brightness_red +    fadeAmount_red;

  // reverse the direction of the fading at the ends of the fade:
  if (brightness_uv <= 0 || brightness_uv >= 250) {
    fadeAmount_uv = -fadeAmount_uv;
  }
    if (brightness_blue <= 0 || brightness_blue >= 30) {
    fadeAmount_blue = -fadeAmount_blue;
  }
    if (brightness_amber <= 0 || brightness_amber >= 80) {
    fadeAmount_amber = -fadeAmount_amber;
  }
      if (brightness_red <= 0 || brightness_red >= 80) {
    fadeAmount_red = -fadeAmount_red;
  }
  // wait for 30 milliseconds to see the dimming effect
  delay(30);
}
