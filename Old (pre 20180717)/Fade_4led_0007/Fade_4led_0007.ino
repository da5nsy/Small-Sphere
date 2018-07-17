/*
 For testing the dimmer switches
 */
int potPin_0 =    A0; 
int val_0=0;
int potPin_1 =    A1; 
int val_1=0;
int potPin_2 =    A2; 
int val_2=0;

void setup() {
  Serial.begin(9600);  
}

void loop() {
  
  //val_0 = analogRead(potPin_0);    // read the value from the sensor
  //Serial.print((val_0-(1023/2))/40);
  //Serial.print(',');
  val_0 = (analogRead(potPin_0)-(1023/2))/34;    // read the value from the sensor
  Serial.print(val_0);
  Serial.print(',');
  
  val_1 = (analogRead(potPin_1)-(1023/2))/34;    // read the value from the sensor
  Serial.print(val_1);
  Serial.print(',');
  
  val_2 = (analogRead(potPin_2)-(1023/2))/34;    // read the value from the sensor
  Serial.println(val_2);
  delay(700);


  
  

}
