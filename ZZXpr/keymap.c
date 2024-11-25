#include QMK_KEYBOARD_H
#include "version.h"
#include "features/achordion.h"
#define MOON_LED_LEVEL LED_LEVEL
#define ML_SAFE_RANGE SAFE_RANGE

enum custom_keycodes {
  RGB_SLD = ML_SAFE_RANGE,
  ST_MACRO_0,
  ST_MACRO_1,
};



const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
  [0] = LAYOUT_voyager(
    MO(4),          KC_1,           KC_2,           KC_3,           KC_4,           KC_5,                                           KC_6,           KC_7,           KC_8,           KC_9,           KC_0,           KC_MINUS,       
    KC_NO,          KC_Q,           KC_W,           KC_E,           KC_R,           KC_T,                                           KC_Y,           KC_U,           KC_I,           KC_O,           KC_P,           KC_GRAVE,       
    ALL_T(KC_ESCAPE),MT(MOD_LCTL, KC_A),MT(MOD_LALT, KC_S),MT(MOD_LGUI, KC_D),MT(MOD_LSFT, KC_F),KC_G,                                           KC_H,           MT(MOD_RSFT, KC_J),MT(MOD_RGUI, KC_K),MT(MOD_LALT, KC_L),MT(MOD_RCTL, KC_SCLN),KC_QUOTE,       
    KC_MEH,         KC_Z,           KC_X,           KC_C,           KC_V,           KC_B,                                           KC_N,           KC_M,           KC_COMMA,       KC_DOT,         KC_SLASH,       KC_BSLS,        
                                                    LT(1,KC_SPACE), LT(2,KC_TAB),                                   KC_BSPC,        LT(3,KC_ENTER)
  ),
  [1] = LAYOUT_voyager(
    KC_NO,          KC_F1,          KC_F2,          KC_F3,          KC_F4,          KC_F5,                                          KC_F6,          KC_F7,          KC_F8,          KC_F9,          KC_F10,         KC_F11,         
    KC_NO,          KC_NO,          KC_NO,          KC_NO,          KC_NO,          KC_NO,                                          KC_HOME,        LGUI(KC_LEFT),  LGUI(KC_RIGHT), KC_END,         KC_NO,          KC_F12,         
    KC_HYPR,        KC_LEFT_CTRL,   KC_LEFT_ALT,    KC_LEFT_GUI,    KC_LEFT_SHIFT,  KC_NO,                                          KC_LEFT,        KC_DOWN,        KC_UP,          KC_RIGHT,       LGUI(LSFT(KC_GRAVE)),LGUI(KC_GRAVE), 
    KC_MEH,         KC_NO,          KC_NO,          KC_NO,          KC_NO,          KC_NO,                                          LGUI(KC_LBRC),  LCTL(LSFT(KC_TAB)),LCTL(KC_TAB),   LGUI(KC_RBRC),  KC_NO,          KC_NO,          
                                                    KC_TRANSPARENT, KC_NO,                                          KC_NO,          KC_NO
  ),
  [2] = LAYOUT_voyager(
    KC_NO,          KC_F13,         KC_F14,         KC_F15,         KC_F16,         KC_F17,                                         KC_F18,         KC_F19,         KC_F20,         KC_F21,         KC_F22,         KC_F23,         
    KC_NO,          KC_NO,          KC_NO,          KC_NO,          KC_NO,          KC_NO,                                          KC_KP_7,        KC_KP_8,        KC_KP_9,        KC_KP_MINUS,    KC_KP_SLASH,    KC_F24,         
    KC_HYPR,        KC_LEFT_CTRL,   KC_LEFT_ALT,    KC_LEFT_GUI,    KC_LEFT_SHIFT,  KC_NO,                                          KC_KP_4,        KC_KP_5,        KC_KP_6,        KC_KP_PLUS,     KC_KP_ASTERISK, KC_TAB,         
    KC_MEH,         KC_NO,          KC_NO,          KC_NO,          KC_NO,          KC_NO,                                          KC_KP_1,        KC_KP_2,        KC_KP_3,        KC_KP_DOT,      KC_KP_EQUAL,    KC_KP_ENTER,    
                                                    KC_NO,          KC_TRANSPARENT,                                 KC_BSPC,        KC_KP_0
  ),
  [3] = LAYOUT_voyager(
    KC_NO,          KC_NO,          KC_NO,          KC_NO,          KC_NO,          KC_NO,                                          KC_NO,          KC_NO,          KC_NO,          KC_NO,          KC_NO,          KC_NO,          
    KC_NO,          KC_EXLM,        KC_AMPR,        KC_LBRC,        KC_RBRC,        KC_LABK,                                        KC_TILD,        KC_CIRC,        KC_DLR,         KC_QUES,        KC_AT,          KC_NO,          
    KC_NO,          KC_PLUS,        KC_EQUAL,       KC_LPRN,        KC_RPRN,        KC_RABK,                                        KC_GRAVE,       KC_QUOTE,       KC_DQUO,        KC_EXLM,        KC_COLN,        ST_MACRO_0,     
    KC_NO,          KC_MINUS,       KC_PIPE,        KC_LCBR,        KC_RCBR,        KC_HASH,                                        KC_PERC,        KC_UNDS,        KC_BSLS,        KC_ASTR,        KC_SLASH,       ST_MACRO_1,     
                                                    KC_NO,          KC_NO,                                          KC_NO,          KC_TRANSPARENT
  ),
  [4] = LAYOUT_voyager(
    KC_NO,          KC_NO,          KC_NO,          KC_NO,          KC_NO,          KC_NO,                                          TOGGLE_LAYER_COLOR,RGB_VAD,        RGB_VAI,        KC_NO,          KC_NO,          KC_NO,          
    KC_NO,          KC_NO,          KC_NO,          KC_NO,          KC_NO,          KC_NO,                                          KC_AUDIO_MUTE,  KC_AUDIO_VOL_DOWN,KC_AUDIO_VOL_UP,KC_NO,          KC_NO,          KC_NO,          
    EE_CLR,         KC_NO,          KC_NO,          KC_NO,          KC_NO,          KC_NO,                                          KC_MEDIA_PREV_TRACK,KC_MEDIA_STOP,  KC_MEDIA_PLAY_PAUSE,KC_MEDIA_NEXT_TRACK,KC_NO,          KC_NO,          
    QK_BOOT,        KC_NO,          KC_NO,          KC_NO,          KC_NO,          KC_NO,                                          KC_NO,          KC_BRIGHTNESS_DOWN,KC_BRIGHTNESS_UP,KC_NO,          KC_NO,          KC_NO,          
                                                    KC_NO,          KC_NO,                                          KC_NO,          KC_NO
  ),
};



extern rgb_config_t rgb_matrix_config;

void keyboard_post_init_user(void) {
  rgb_matrix_enable();
}

const uint8_t PROGMEM ledmap[][RGB_MATRIX_LED_COUNT][3] = {
    [0] = { {251,255,142}, {78,207,162}, {78,207,162}, {78,207,162}, {78,207,162}, {78,207,162}, {0,0,0}, {147,255,248}, {147,255,248}, {147,255,248}, {147,255,248}, {147,255,248}, {165,27,121}, {190,146,254}, {190,146,254}, {190,146,254}, {190,146,254}, {147,255,248}, {165,27,121}, {147,255,248}, {147,255,248}, {147,255,248}, {147,255,248}, {147,255,248}, {112,152,221}, {78,207,162}, {78,207,162}, {78,207,162}, {78,207,162}, {78,207,162}, {78,207,162}, {144,211,255}, {147,255,248}, {147,255,248}, {147,255,248}, {147,255,248}, {147,255,248}, {144,211,255}, {147,255,248}, {190,146,254}, {190,146,254}, {190,146,254}, {190,146,254}, {144,211,255}, {147,255,248}, {147,255,248}, {144,211,255}, {144,211,255}, {144,211,255}, {144,211,255}, {165,27,121}, {22,255,167} },

    [1] = { {0,0,0}, {27,255,239}, {27,255,239}, {27,255,239}, {27,255,239}, {27,255,239}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {165,27,121}, {190,146,254}, {190,146,254}, {190,146,254}, {190,146,254}, {0,0,0}, {165,27,121}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {27,255,239}, {27,255,239}, {27,255,239}, {27,255,239}, {27,255,239}, {27,255,239}, {112,152,221}, {112,152,221}, {112,152,221}, {112,152,221}, {0,0,0}, {27,255,239}, {120,255,159}, {120,255,159}, {120,255,159}, {120,255,159}, {112,152,221}, {112,152,221}, {112,152,221}, {112,152,221}, {112,152,221}, {112,152,221}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0} },

    [2] = { {0,0,0}, {27,255,239}, {27,255,239}, {27,255,239}, {27,255,239}, {27,255,239}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {165,27,121}, {190,146,254}, {190,146,254}, {190,146,254}, {190,146,254}, {0,0,0}, {165,27,121}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {27,255,239}, {27,255,239}, {27,255,239}, {27,255,239}, {27,255,239}, {27,255,239}, {78,207,162}, {78,207,162}, {78,207,162}, {64,145,216}, {64,145,216}, {27,255,239}, {78,207,162}, {78,207,162}, {78,207,162}, {64,145,216}, {64,145,216}, {165,27,121}, {78,207,162}, {78,207,162}, {78,207,162}, {64,145,216}, {64,145,216}, {165,27,121}, {165,27,121}, {78,207,162} },

    [3] = { {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {215,171,225}, {215,171,225}, {11,210,255}, {11,210,255}, {11,210,255}, {0,0,0}, {27,255,239}, {27,255,239}, {11,210,255}, {11,210,255}, {11,210,255}, {0,0,0}, {27,255,239}, {215,171,225}, {11,210,255}, {11,210,255}, {22,255,167}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {215,171,225}, {215,171,225}, {215,171,225}, {215,171,225}, {215,171,225}, {0,0,0}, {165,27,121}, {165,27,121}, {165,27,121}, {215,171,225}, {215,171,225}, {165,27,121}, {22,255,167}, {215,171,225}, {215,171,225}, {27,255,239}, {27,255,239}, {165,27,121}, {0,0,0}, {0,0,0} },

    [4] = { {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {251,255,142}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {251,255,142}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,121,255}, {0,121,255}, {0,121,255}, {0,0,0}, {0,0,0}, {0,0,0}, {69,191,192}, {69,191,192}, {69,191,192}, {0,0,0}, {0,0,0}, {0,0,0}, {78,207,162}, {78,207,162}, {78,207,162}, {78,207,162}, {0,0,0}, {0,0,0}, {0,0,0}, {27,255,239}, {27,255,239}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0} },

};

void set_layer_color(int layer) {
  for (int i = 0; i < RGB_MATRIX_LED_COUNT; i++) {
    HSV hsv = {
      .h = pgm_read_byte(&ledmap[layer][i][0]),
      .s = pgm_read_byte(&ledmap[layer][i][1]),
      .v = pgm_read_byte(&ledmap[layer][i][2]),
    };
    if (!hsv.h && !hsv.s && !hsv.v) {
        rgb_matrix_set_color( i, 0, 0, 0 );
    } else {
        RGB rgb = hsv_to_rgb( hsv );
        float f = (float)rgb_matrix_config.hsv.v / UINT8_MAX;
        rgb_matrix_set_color( i, f * rgb.r, f * rgb.g, f * rgb.b );
    }
  }
}

bool rgb_matrix_indicators_user(void) {
  if (rawhid_state.rgb_control) {
      return false;
  }
  if (keyboard_config.disable_layer_led) { return false; }
  switch (biton32(layer_state)) {
    case 0:
      set_layer_color(0);
      break;
    case 1:
      set_layer_color(1);
      break;
    case 2:
      set_layer_color(2);
      break;
    case 3:
      set_layer_color(3);
      break;
    case 4:
      set_layer_color(4);
      break;
   default:
    if (rgb_matrix_get_flags() == LED_FLAG_NONE)
      rgb_matrix_set_color_all(0, 0, 0);
    break;
  }
  return true;
}

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  if (!process_achordion(keycode, record)) { return false; }

  switch (keycode) {
    case ST_MACRO_0:
    if (record->event.pressed) {
      SEND_STRING(SS_LSFT(SS_TAP(X_SCLN)) SS_DELAY(100) SS_LSFT(SS_TAP(X_SCLN)));
    }
    break;
    case ST_MACRO_1:
    if (record->event.pressed) {
      SEND_STRING(SS_TAP(X_DOT) SS_DELAY(100) SS_TAP(X_DOT) SS_DELAY(100) SS_TAP(X_SLASH));
    }
    break;

    case RGB_SLD:
      if (record->event.pressed) {
        rgblight_mode(1);
      }
      return false;
  }
  return true;
}



// Custom QMK below.

void matrix_scan_user(void) {
  achordion_task();
}

bool achordion_chord(uint16_t tap_hold_keycode, keyrecord_t* tap_hold_record,
                     uint16_t other_keycode, keyrecord_t* other_record) {
  switch (tap_hold_keycode) {
    // Allow thumbs.
    case KC_SPACE:
    case KC_TAB:
    case KC_ENTER:
      return true;
  }
  return achordion_opposite_hands(tap_hold_record, other_record);
}
