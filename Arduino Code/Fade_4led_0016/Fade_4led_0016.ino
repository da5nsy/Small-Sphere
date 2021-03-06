/*
  Experiment time!
  Vals: 35  169 141  240

*/

int led_blue =  5;
int led_uv =    3;    // the PWM pin the LED is attached to
int led_red =   10;
int led_amber = 9;

int light_source = 1;

// "0" = yellow/uv
// "1" = red/blue

void setup() {
  pinMode(led_blue, OUTPUT);
  pinMode(led_uv, OUTPUT);
  pinMode(led_red, OUTPUT);
  pinMode(led_amber, OUTPUT);

}

void loop() {

  if (light_source == 1) {
    analogWrite(led_blue,   35);
    analogWrite(led_uv,     0);
    analogWrite(led_red,    141);
    analogWrite(led_amber,  0);
  }

  else {
    analogWrite(led_blue,   0);
    analogWrite(led_uv,     169);
    analogWrite(led_red,    0);
    analogWrite(led_amber,  240);
  }
}
