module top_module (
    input  clk_27m,      // Reloj físico de la placa (Pin 52)
    input  rst_n,        // Botón físico de reset
    input  uart_rx_pin,
    
    // NUEVO: Entradas físicas para los botones de movimiento
    input  btn_up,
    input  btn_down,
    input  btn_left,
    input  btn_right,
    
    // Salidas físicas hacia el puerto HDMI
    output       O_tmds_clk_p,
    output       O_tmds_clk_n,
    output [2:0] O_tmds_data_p,
    output [2:0] O_tmds_data_n
);

    // 1. Cables internos
    wire [7:0] rx_data;
    wire rx_valid;
    wire clk_serial; 
    wire clk_pixel;  
    wire vs, hs, de; 
    wire [7:0] r, g, b; 
    wire [4:0] head_x, head_y;
    wire [4:0] body1_x, body1_y, body2_x, body2_y, body3_x, body3_y;
    
    // 1. Instancia UART
    uart_rx uart_inst (
        .clk(clk_27m),
        .rst_n(rst_n),
        .rx(uart_rx_pin), // Deberás agregar input uart_rx_pin en tu top_module
        .rx_data(rx_data),
        .rx_valid(rx_valid)
    );

    // 2. Instancia de Lógica
    snake_logic logic_inst (
        .clk_pixel(clk_pixel),
        .rst_n(rst_n),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .head_x(head_x), .head_y(head_y),
        .body1_x(body1_x), .body1_y(body1_y),
        .body2_x(body2_x), .body2_y(body2_y),
        .body3_x(body3_x), .body3_y(body3_y)
    );

    // 2. Instancia del rPLL y Divisor
    Gowin_rPLL pll_inst (
        .clkout(clk_serial), 
        .clkin(clk_27m)
    );

    CLKDIV u_clkdiv (
        .RESETN(rst_n),
        .HCLKIN(clk_serial), 
        .CLKOUT(clk_pixel),  
        .CALIB(1'b0)
    );
    defparam u_clkdiv.DIV_MODE = "5";
    defparam u_clkdiv.GSREN = "false";



    // 3. Instancia del Controlador VGA
    vga_controller vga_inst (
        .clk_pixel(clk_pixel),
        .rst_n(rst_n),
        .head_x(head_x), // NUEVO: Pasamos las coordenadas calculadas al VGA
        .head_y(head_y), // NUEVO
        .body1_x(body1_x), .body1_y(body1_y),
        .body2_x(body2_x), .body2_y(body2_y),
        .body3_x(body3_x), .body3_y(body3_y),
        .hs(hs),
        .vs(vs),
        .de(de),
        .r(r),
        .g(g),
        .b(b)
    );

    // 4. Instancia del DVI TX
    DVI_TX_Top dvi_tx_inst (
        .I_rst_n(rst_n), 
        .I_serial_clk(clk_serial),
        .I_rgb_clk(clk_pixel),     
        .I_rgb_vs(vs),             
        .I_rgb_hs(hs),             
        .I_rgb_de(de),             
        .I_rgb_r(r),               
        .I_rgb_g(g),               
        .I_rgb_b(b),               
        .O_tmds_clk_p(O_tmds_clk_p),     
        .O_tmds_clk_n(O_tmds_clk_n),     
        .O_tmds_data_p(O_tmds_data_p),   
        .O_tmds_data_n(O_tmds_data_n)    
    );

endmodule
