/*
 Fade example mod
 */

int led_uv =    3;           // the PWM pin the LED is attached to
int led_blue =  5;     
int led_amber = 9;           
int led_red =   10;           

int potPin_uv =     0;
int potPin_blue =   1;
int potPin_amber =  2;
int potPin_red =    3; 
   
int val_uv = 0;    
int val_blue = 0; 
int val_amber = 0; 
int val_red = 0; 

void setup() {
  pinMode(led_uv, OUTPUT);
  pinMode(led_blue, OUTPUT);
  pinMode(led_amber, OUTPUT);
  pinMode(led_red, OUTPUT);
  Serial.begin(9600);  
}

void loop() {
  
  digitalWrite(led_red,    HIGH);
  delayMicroseconds(val);
  digitalWrite(led_red,    LOW);
  delayMicroseconds(1023-val);
  val_uv = analogRead(potPin_uv);    // read the value from the sensor
  
  Serial.print(val_uv);
  Serial.print(',');
  Serial.print(val_blue);
  Serial.print(',');
  Serial.print(val_amber);
  Serial.print(',');
  Serial.println(val_red);
  
  

}
