/*
Updating knob control

Match for DG (at 7hz), with amber maxed
82.50  195 0   | 50  160 255 255

Match for DG (at 7hz), with amber decreased to 240
66.28  207 88  | 32  137 167 240 | 14/02
75.66  197 93  | 44  149 162 240 | (roughly) 14/02
72.34  206 92  | 36  149 163 240 | (fairly precisely) 1619 14/02
60.31  197 59  | 35  118 196 240 | 2hz with black ring removed, 14/02
65.00  205 63  | 33  133 192 240 | 2hz with black ring removed, 14/02
60.31  221 75  | 21  133 180 240 | 20hz with black ring removed, 14/02
54.25  197 66  | 32  106 189 240 | 7hz with black ring removed, 14/02





 */

int led_uv =    3;           // the PWM pin the LED is attached to
int led_blue =  5;     
int led_amber = 9;           
int led_red =   10;           

int potPin_0 =    A0; 
int potPin_1 =    A1; 
int potPin_2 =    A2; 

float val_0=0;
int val_1=0;
int val_2=0;

int hz = 7;

void setup() {
  pinMode(led_uv, OUTPUT);
  pinMode(led_blue, OUTPUT);
  pinMode(led_amber, OUTPUT);
  pinMode(led_red, OUTPUT);

  Serial.begin(9600);  
}

void loop() {

  // percentage brightness of red/blue
  
  val_0 = 100-(analogRead(potPin_0))/10.23;    // read the value from the sensor

  // red/blue-ness
  // At one end, all blue, at the other all red
  val_1 = 255-(analogRead(potPin_1)/4);    // read the value from the sensor

  // yellow/uv-ness
  // Blue fader (amber stays high)
  val_2 = 255-(analogRead(potPin_2)/4);    // read the value from the sensor

  analogWrite(led_uv,     0);
  analogWrite(led_amber,  0);
  analogWrite(led_blue,   int((256-val_1) *(val_0/100)));
  analogWrite(led_red,    int(val_1       *(val_0/100)));   
  delay(1000/hz);
  
  analogWrite(led_blue,   0);
  analogWrite(led_red,    0);
  analogWrite(led_uv,     255- val_2);
  analogWrite(led_amber,  240);

  Serial.print(val_0);
  Serial.print("\t");
  Serial.print(val_1);
  Serial.print("\t");
  Serial.print(val_2);
  Serial.print("\t");
  Serial.print("|");
  Serial.print("\t");
  Serial.print(int((256-val_1) *(val_0/100)));
  Serial.print("\t");
  Serial.print(int(val_1       *(val_0/100)));
  Serial.print("\t");
  Serial.print(255- val_2);
  Serial.print("\t");
  Serial.println(240);

  delay(1000/hz); 

}
