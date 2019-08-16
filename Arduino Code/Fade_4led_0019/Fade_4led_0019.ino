/*
Adding a switch to control the lighting

*/

const int led_blue =  5;  // the PWM pin the LED is attached to
const int led_uv =    6;    
const int led_red =   10;
const int led_amber = 9;

const int switchPin = 3;

void setup() {
  // Output
  pinMode(led_blue, OUTPUT);
  pinMode(led_uv, OUTPUT);
  pinMode(led_red, OUTPUT);
  pinMode(led_amber, OUTPUT);

  // Input
  pinMode(switchPin, INPUT);
  //Serial.begin(9600);

}

void loop() {
 
  int switchVal;
  switchVal = digitalRead(switchPin);

   if (switchVal == HIGH) {
    //Serial.println("Toggle: On");
    analogWrite(led_blue,   35);
    analogWrite(led_uv,     0);
    analogWrite(led_red,    141);
    analogWrite(led_amber,  0);
    (delay(1000));
  }

   if (switchVal == LOW) {
    //Serial.println("Toggle: Off");
    analogWrite(led_blue,   0);
    analogWrite(led_uv,     169);
    analogWrite(led_red,    0);
    analogWrite(led_amber,  240);
    (delay(1000));
  }
}
