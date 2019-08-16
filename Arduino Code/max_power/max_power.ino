/*
  LW - UA
*/

const int led_blue =  5;  // the PWM pin the LED is attached to
const int led_uv =    6;
const int led_amber = 9;
const int led_red =   10;

void setup() {
  // Output
  pinMode(led_blue, OUTPUT);
  pinMode(led_uv, OUTPUT);
  pinMode(led_amber, OUTPUT);
  pinMode(led_red, OUTPUT);

  analogWrite(led_blue,   250);
  analogWrite(led_uv,     250);
  analogWrite(led_amber,  250);
  analogWrite(led_red,    250);

}

void loop() {
}

