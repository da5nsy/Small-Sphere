/*
 Fade example mod
 */

int led_uv =    3;           // the PWM pin the LED is attached to
int led_blue =  5;     
int led_amber = 9;           
int led_red =   10;           

int brightness_uv =     250;    // how bright the LED is
int brightness_blue =   30;    
int brightness_amber =  100;    
int brightness_red =    80;   

int hz = 2;

// the setup routine runs once when you press reset:
void setup() {
  pinMode(led_uv, OUTPUT);
  pinMode(led_blue, OUTPUT);
  pinMode(led_amber, OUTPUT);
  pinMode(led_red, OUTPUT);
}

// the loop routine runs over and over again forever:
void loop() {
  
  analogWrite(led_uv,     0);
  analogWrite(led_amber,  0);
  analogWrite(led_blue,   brightness_blue);
  analogWrite(led_red,    brightness_red);
  delay(1000/hz);
  
  analogWrite(led_blue,   0);
  analogWrite(led_red,    0);
  analogWrite(led_uv,     brightness_uv);
  analogWrite(led_amber,  brightness_amber);
  delay(1000/hz);

}
