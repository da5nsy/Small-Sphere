/*
Rig in place
Matched for periphery
 */

int led_uv =    3;           // the PWM pin the LED is attached to
int led_blue =  5;     
int led_amber = 9;           
int led_red =   10;           

  
int brightness_blue =   36;    
int brightness_red =    155;
int brightness_uv =     177;    

int brightness_amber =  255; 

//int brightness_blue =   42;    
//int brightness_red =    144;
//int brightness_uv =     175;    
//int brightness_amber =  255; 

int potPin_0 =    A0; 
int potPin_1 =    A1; 
int potPin_2 =    A2; 

int val_0=0;
int val_1=0;
int val_2=0;

int hz = 2;
int scaling_factor = 45;
//34 for +/- 15
//45 for +/- 11

void setup() {
  pinMode(led_uv, OUTPUT);
  pinMode(led_blue, OUTPUT);
  pinMode(led_amber, OUTPUT);
  pinMode(led_red, OUTPUT);

  Serial.begin(9600);  
}

void loop() {

  val_0 = (analogRead(potPin_0)-(1023/2))/scaling_factor;    // read the value from the sensor
  Serial.print(val_0);
  Serial.print(',');
  
  val_1 = (analogRead(potPin_1)-(1023/2))/scaling_factor;    // read the value from the sensor
  Serial.print(val_1);
  Serial.print(',');
  
  val_2 = (analogRead(potPin_2)-(1023/2))/scaling_factor;    // read the value from the sensor
  Serial.println(val_2);
  
  analogWrite(led_uv,     0);
  analogWrite(led_amber,  0);
  analogWrite(led_blue,   brightness_blue + val_0);
  analogWrite(led_red,    brightness_red  + val_1);
  delay(1000/hz);
  
  analogWrite(led_blue,   0);
  analogWrite(led_red,    0);
  analogWrite(led_uv,     brightness_uv + val_2);
  analogWrite(led_amber,  brightness_amber);
  delay(1000/hz);

}
