#include <WiFi.h>
#include <FirebaseESP32.h>
#include <ESP32Servo.h>

//Provide the token generation process info.
#include <addons/TokenHelper.h>
//Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>

#define WIFI_SSID "SerhatMuratFurkan"
#define WIFI_PASSWORD "21032000"

#define API_KEY ""
#define DATABASE_URL ""

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

bool signupOK = false;

// donanim
///const int led = 33;

Servo sg90; // create a servo object
int servoPin = 13;


// CAMERA LIBRARY
#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"
#include "Base64.h"
#include "esp_camera.h"

//CAMERA_MODEL_AI_THINKER
#define PWDN_GPIO_NUM     32
#define RESET_GPIO_NUM    -1
#define XCLK_GPIO_NUM      0
#define SIOD_GPIO_NUM     26
#define SIOC_GPIO_NUM     27

#define Y9_GPIO_NUM       35
#define Y8_GPIO_NUM       34
#define Y7_GPIO_NUM       39
#define Y6_GPIO_NUM       36
#define Y5_GPIO_NUM       21
#define Y4_GPIO_NUM       19
#define Y3_GPIO_NUM       18
#define Y2_GPIO_NUM        5
#define VSYNC_GPIO_NUM    25
#define HREF_GPIO_NUM     23
#define PCLK_GPIO_NUM     22

void setup() {
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);

  Serial.begin(115200);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h

  /* Sign up */
  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("ok");
    signupOK = true;
  }
  else {
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }


  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  /*
    Firebase.RTDB.setMaxRetry(fbdo, 3);
    Firebase.RTDB.setMaxErrorQueue(fbdo, 30);
    Firebase.RTDB.enableClassicRequest(fbdo, true);
  */
  /*
    // led pin tanimlamalari
    pinMode(led, OUTPUT);
    digitalWrite(led, HIGH);
  */

  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sscb_sda = SIOD_GPIO_NUM;
  config.pin_sscb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;

  // if PSRAM IC present, init with UXGA resolution and higher JPEG quality
  //                      for larger pre-allocated frame buffer.

  if (psramFound()) {
    config.frame_size = FRAMESIZE_UXGA;
    config.jpeg_quality = 10;
    config.fb_count = 2;
  } else {
    config.frame_size = FRAMESIZE_SVGA;
    config.jpeg_quality = 12;
    config.fb_count = 1;
  }
  // camera init
  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("Camera init failed with error 0x%x", err);
    ESP.restart();
    //return;
  }
  //drop down frame size for higher initial frame rate
  sensor_t * s = esp_camera_sensor_get();
  //s->set_framesize(s, FRAMESIZE_QVGA);
  s->set_framesize(s, FRAMESIZE_QQVGA);  // VGA|CIF|QVGA|HQVGA|QQVGA   ( UXGA? SXGA? XGA? SVGA? )



  sg90.attach(servoPin); // attaches the servo on pin 13 to the servo object
}

void loop() {

  // && signupOK
  if (Firebase.ready() && signupOK) {

    if (Firebase.RTDB.getString(&fbdo, "/servo/servoStatus")) {
      int servoStatus = 76;
      servoStatus = fbdo.intData();
      Serial.print("servoStatus ");
      Serial.println(servoStatus);
      if (servoStatus == 1) {
        sg90.write(90);
        delay(500);
        sg90.write(1);
        Firebase.RTDB.setInt(&fbdo, "/servo/servoStatus", 0);
        Serial.println("Mama verildi");
      }
    }
    else {
      Serial.println("servoStatus elseye girdi hata: " + fbdo.errorReason());
    }

    // photo status
    if (Firebase.RTDB.getString(&fbdo, "/photo/photoStatus")) {
      delay(10);
      int photoStatus = fbdo.intData();
      Serial.print("photoStatus ");
      Serial.println(photoStatus);

      if (photoStatus == 1) {
        String photoData = Photo2Base64();

        Firebase.RTDB.setInt(&fbdo, "/photo/photoStatus", 0);
        delay(10);

        FirebaseJson json;
        //json.set("photoData", Photo2Base64());
        json.add("photoData", Photo2Base64());
        //json.set("photoData", photoData);
        Serial.printf("Update json... %s\n\n", Firebase.updateNode(fbdo, "/photo/photoData", json) ? "ok" : fbdo.errorReason().c_str());
      }
      else if (photoStatus == 0) {
        Serial.println("photo istenmiyor");
      }
      else {
        Serial.println("photoStatus kısmında bilginmeyen bir hata oluştu");
      }
    }
    else {
      Serial.println("photoStatus elseye girdi hata: " + fbdo.errorReason());
    }
    // photo status end


    delay(3000);
  }
}

String Photo2Base64(){
  camera_fb_t * fb = NULL;
  fb = esp_camera_fb_get();
  if (!fb) {
    Serial.println("Camera capture failed");
    return "";
  }

  String imageFile = "data:image/jpeg;base64,";
  char *input = (char *)fb->buf;
  char output[base64_enc_len(3)];
  for (int i = 0; i < fb->len; i++) {
    base64_encode(output, (input++), 3);
    if (i % 3 == 0) imageFile += urlencode(String(output));
  }

  esp_camera_fb_return(fb);

  return imageFile;
}

String urlencode(String str){
  String encodedString = "";
  char c;
  char code0;
  char code1;
  char code2;
  for (int i = 0; i < str.length(); i++) {
    c = str.charAt(i);
    if (c == ' ') {
      encodedString += '+';
    } else if (isalnum(c)) {
      encodedString += c;
    } else {
      code1 = (c & 0xf) + '0';
      if ((c & 0xf) > 9) {
        code1 = (c & 0xf) - 10 + 'A';
      }
      c = (c >> 4) & 0xf;
      code0 = c + '0';
      if (c > 9) {
        code0 = c - 10 + 'A';
      }
      code2 = '\0';
      encodedString += '%';
      encodedString += code0;
      encodedString += code1;
    }
    yield();
  }
  return encodedString;
}
