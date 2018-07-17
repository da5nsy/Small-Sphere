/*
 Fade example mod
 */

int led_uv =    3;           // the PWM pin the LED is attached to
int led_blue =  5;     
int led_amber = 9;           
int led_red =   10;           

int brightness_uv =     250;    // how bright the LED is
int brightness_blue =   30;    
int brightness_amber =  80;    
int brightness_red =    80;    

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

  if (button_1 is pressed) {
    brightness_uv     = brightness_uv     +5;
    brightness_amber  = brightness_amber  -5;
  }

  if (button_2 is pressed) {
    brightness_uv     = brightness_uv     -5;
    brightness_amber  = brightness_amber  +5;
  }

  if (button_3 is pressed) {
    brightness_blue = brightness_blue     +5;
    brightness_red  = brightness_red      -5;
  }

    if (button_4 is pressed) {
    brightness_blue = brightness_blue     -5;
    brightness_red  = brightness_red      +5;
  }

  if (button_3 is pressed) {
    brightness_blue = brightness_blue     +5;
    brightness_red  = brightness_red      -5;
  }

    if (button_4 is pressed) {
    brightness_blue = brightness_blue     -5;
    brightness_red  = brightness_red      -5;

  delay(30);
}
