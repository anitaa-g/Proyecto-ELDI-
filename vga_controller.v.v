module vga_controller (
    input  wire clk_pixel, // Reloj de 25 MHz
    input  wire rst_n,     // Botón de reset
    output wire hs,        // Sincronización horizontal
    output wire vs,        // Sincronización vertical
    output wire de,        // Data Enable (área visible)
    output wire [7:0] r,   // Canal Rojo
    output wire [7:0] g,   // Canal Verde
    output wire [7:0] b    // Canal Azul
);

    // Parámetros estándar de temporización para 640x480 @ 60Hz
    parameter H_VISIBLE = 640;
    parameter H_FRONT   = 16;
    parameter H_SYNC    = 96;
    parameter H_BACK    = 48;
    parameter H_TOTAL   = 800;

    parameter V_VISIBLE = 480;
    parameter V_FRONT   = 10;
    parameter V_SYNC    = 2;
    parameter V_BACK    = 33;
    parameter V_TOTAL   = 525;

    // Registros para los contadores de posición X e Y
    reg [9:0] h_cnt = 0;
    reg [9:0] v_cnt = 0;

    // Lógica de barrido de la pantalla
    always @(posedge clk_pixel or negedge rst_n) begin
        if (!rst_n) begin
            h_cnt <= 0;
            v_cnt <= 0;
        end else begin
            if (h_cnt == H_TOTAL - 1) begin
                h_cnt <= 0;
                if (v_cnt == V_TOTAL - 1)
                    v_cnt <= 0;
                else
                    v_cnt <= v_cnt + 1;
            end else begin
                h_cnt <= h_cnt + 1;
            end
        end
    end

    // Generación de pulsos de sincronización (Activos en bajo para 640x480)
    assign hs = ~((h_cnt >= H_VISIBLE + H_FRONT) && (h_cnt < H_VISIBLE + H_FRONT + H_SYNC));
    assign vs = ~((v_cnt >= V_VISIBLE + V_FRONT) && (v_cnt < V_VISIBLE + V_FRONT + V_SYNC));
    
    // La señal 'de' indica si estamos en el área donde hay píxeles visibles
    assign de = (h_cnt < H_VISIBLE) && (v_cnt < V_VISIBLE);

    // --- GENERADOR DE PATRÓN DE PRUEBA (BARRAS DE COLORES) ---
    reg [7:0] red, green, blue;
    
    always @(*) begin
        if (!de) begin
            // Fuera del área visible, siempre debe enviarse negro
            red = 8'h00; green = 8'h00; blue = 8'h00;
        end else begin
            // Divide los 640 píxeles en 8 franjas de 80 píxeles cada una
            if      (h_cnt < 80)  {red, green, blue} = {8'hFF, 8'h00, 8'h00}; // Blanco
            else if (h_cnt < 160) {red, green, blue} = {8'hFF, 8'hA5, 8'h00}; // Amarillo
            else if (h_cnt < 240) {red, green, blue} = {8'hFF, 8'hFF, 8'h00}; // Cian
            else if (h_cnt < 320) {red, green, blue} = {8'h00, 8'hFF, 8'h00}; // Verde
            else if (h_cnt < 400) {red, green, blue} = {8'h00, 8'h77, 8'h00}; // Magenta
            else if (h_cnt < 480) {red, green, blue} = {8'h00, 8'h00, 8'h99}; // Rojo
            else if (h_cnt < 560) {red, green, blue} = {8'h00, 8'h00, 8'hFE}; // Azul
            else                  {red, green, blue} = {8'hA0, 8'h20, 8'hF0}; // Negro
        end
    end

    assign r = red;
    assign g = green;
    assign b = blue;

endmodule