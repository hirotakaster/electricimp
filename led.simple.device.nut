#require "WS2812.class.nut:3.0.0"
 
// グローバル変数
spi <- null;
led <- null;
state <- false;

// LEDの表示
function flash() {
    state = !state;
    local color = state ? [255,0,0] : [0,0,0];
    led.set(0, color).draw();
    imp.wakeup(1.0, flash); 
}
 
// SPI経由でのLEDを変更する設定
spi = hardware.spiAHSR;
spi.configure(MSB_FIRST, 6000);
 
// LEDの設定
led = WS2812(spi, 1);
hardware.pinH.configure(DIGITAL_OUT, 1);

// LEDの表示
flash()
