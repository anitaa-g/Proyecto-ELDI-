module top_module (
    input  clk_27m,      // Reloj físico de la placa (Pin 52 en la Tang Nano 9K)
    input  rst_n,        // Botón físico de reset (ej. Pin 3 o 4)
    
    // Salidas físicas hacia el puerto HDMI (Las que van en tu .cst)
    output       O_tmds_clk_p,
    output       O_tmds_clk_n,
    output [2:0] O_tmds_data_p,
    output [2:0] O_tmds_data_n
);

    // 1. Cables internos para interconectar los bloques
    wire clk_serial; // Reloj rápido para transmisión (ej. 125 MHz)
    wire clk_pixel;  // Reloj lento para dibujar píxeles (ej. 25 MHz)
    wire vs, hs, de; // Sincronización vertical, horizontal y enable
    wire [7:0] r, g, b; // Canales de color RGB

 
    // 2. Instancia del rPLL (Genera solo los 125 MHz)
Gowin_rPLL pll_inst (
    .clkout(clk_serial), // Salida de alta frecuencia (125 MHz)
    .clkin(clk_27m)
);

// 2.5 Divisor de hardware dedicado (Divide 125 MHz entre 5 = 25 MHz)
CLKDIV u_clkdiv (
    .RESETN(rst_n),
    .HCLKIN(clk_serial), // Entran los 125 MHz generados por el PLL
    .CLKOUT(clk_pixel),  // Salen los 25 MHz para la lógica VGA
    .CALIB(1'b0)
);
defparam u_clkdiv.DIV_MODE = "5"; // <--- Aquí se aplica la división por 5
defparam u_clkdiv.GSREN = "false";


    // 3. Instancia de tu generador de imagen (Controlador VGA)
    // Toma el reloj de píxel y determina qué color va en qué coordenada.

    vga_controller vga_inst (
        .clk_pixel(clk_pixel),
        .rst_n(rst_n),
        .hs(hs),
        .vs(vs),
        .de(de),
        .r(r),
        .g(g),
        .b(b)
    );

    // 4. Tu código: La instancia del DVI TX
    DVI_TX_Top dvi_tx_inst (
        .I_rst_n(rst_n), 
        .I_serial_clk(clk_serial), // Conectado al wire interno
        .I_rgb_clk(clk_pixel),     // Conectado al wire interno
        .I_rgb_vs(vs),             // Conectado al VGA
        .I_rgb_hs(hs),             // Conectado al VGA
        .I_rgb_de(de),             // Conectado al VGA
        .I_rgb_r(r),               // Conectado al VGA
        .I_rgb_g(g),               // Conectado al VGA
        .I_rgb_b(b),               // Conectado al VGA
        .O_tmds_clk_p(O_tmds_clk_p),     // Directo a la salida física
        .O_tmds_clk_n(O_tmds_clk_n),     // Directo a la salida física
        .O_tmds_data_p(O_tmds_data_p),   // Directo a la salida física
        .O_tmds_data_n(O_tmds_data_n)    // Directo a la salida física
    );

endmodule