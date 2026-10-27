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

    // --- LÓGICA DE DIBUJO (CUADRADO ROJO SOBRE FONDO AZUL) ---
    reg [7:0] red, green, blue;
    
    always @(*) begin
        if (!de) begin
            // Fuera del área visible (blanking), siempre debe enviarse negro
            red = 8'h00; green = 8'h00; blue = 8'h00;
        end else begin
            // Si el píxel actual está dentro de los límites del cuadrado
            //Serpiente
            if (h_cnt >= 256 && h_cnt < 320 && v_cnt >= 96 && v_cnt < 336) begin
                {red, green, blue} = {8'h7D, 8'hB5, 8'hFA}; // Azul cielo
            end
            //Ojos
            else if (h_cnt >= 364 && h_cnt < 374 && v_cnt >= 106 && v_cnt < 116) begin
                {red, green, blue} = {8'h00, 8'h00, 8'h00}; // Negro
            end
            else if (h_cnt >= 364 && h_cnt < 374 && v_cnt >= 124 && v_cnt < 134) begin
                {red, green, blue} = {8'h00, 8'h00, 8'h00}; // Negro
            end
            //Cabeza
            else if (h_cnt >= 320 && h_cnt < 384 && v_cnt >= 96 && v_cnt < 144) begin
                {red, green, blue} = {8'h7D, 8'hB5, 8'hFA}; // Azul cielo
            end
            //Manzana buena
            else if (h_cnt >= 394 && h_cnt < 438 && v_cnt >= 154 && v_cnt < 182) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00}; // Amarillo
            end
            //Manzana envenenada
            else if (h_cnt >= 138 && h_cnt < 182 && v_cnt >= 346 && v_cnt < 374) begin
                {red, green, blue} = {8'hFF, 8'h00, 8'h00}; // Rojo
            end
            

            //Primer Columna
            else if (h_cnt >= 0 && h_cnt < 64 && v_cnt >= 0 && v_cnt < 48) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 0 && h_cnt < 64 && v_cnt >= 96 && v_cnt < 144) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 0 && h_cnt < 64 && v_cnt >= 192 && v_cnt < 240) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 0 && h_cnt < 64 && v_cnt >= 288 && v_cnt < 336) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 0 && h_cnt < 64 && v_cnt >= 384 && v_cnt < 432) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end

            // Segunda Columna
            else if (h_cnt >= 64 && h_cnt < 128 && v_cnt >= 48 && v_cnt < 96) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 64 && h_cnt < 128 && v_cnt >= 144 && v_cnt < 192) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 64 && h_cnt < 128 && v_cnt >= 240 && v_cnt < 288) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 64 && h_cnt < 128 && v_cnt >= 336 && v_cnt < 384) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 64 && h_cnt < 128 && v_cnt >= 432 && v_cnt < 480) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end

            // Tercera Columna
            else if (h_cnt >= 128 && h_cnt < 192 && v_cnt >= 0 && v_cnt < 48) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 128 && h_cnt < 192 && v_cnt >= 96 && v_cnt < 144) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end 
            else if (h_cnt >= 128 && h_cnt < 192 && v_cnt >= 192 && v_cnt < 240) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end 
            else if (h_cnt >= 128 && h_cnt < 192 && v_cnt >= 288 && v_cnt < 336) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 128 && h_cnt < 192 && v_cnt >= 384 && v_cnt < 432) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end

            //Cuarta Columna
            else if (h_cnt >= 192 && h_cnt < 256 && v_cnt >= 48 && v_cnt < 96) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 192 && h_cnt < 256 && v_cnt >= 144 && v_cnt < 192) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 192 && h_cnt < 256 && v_cnt >= 240 && v_cnt < 288) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 192 && h_cnt < 256 && v_cnt >= 336 && v_cnt < 384) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 192 && h_cnt < 256 && v_cnt >= 432 && v_cnt < 480) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end

            //Quinta Columna
            else if (h_cnt >= 256 && h_cnt < 320 && v_cnt >= 0 && v_cnt < 48) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 256 && h_cnt < 320 && v_cnt >= 96 && v_cnt < 144) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end 
            else if (h_cnt >= 256 && h_cnt < 320 && v_cnt >= 192 && v_cnt < 240) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end 
            else if (h_cnt >= 256 && h_cnt < 320 && v_cnt >= 288 && v_cnt < 336) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 256 && h_cnt < 320 && v_cnt >= 384 && v_cnt < 432) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end

            //Sexta Columna
            else if (h_cnt >= 320 && h_cnt < 384 && v_cnt >= 48 && v_cnt < 96) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 320 && h_cnt < 384 && v_cnt >= 144 && v_cnt < 192) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 320 && h_cnt < 384 && v_cnt >= 240 && v_cnt < 288) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 320 && h_cnt < 384 && v_cnt >= 336 && v_cnt < 384) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 320 && h_cnt < 384 && v_cnt >= 432 && v_cnt < 480) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end

            //Septima Columna
            else if (h_cnt >= 384 && h_cnt < 448 && v_cnt >= 0 && v_cnt < 48) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 384 && h_cnt < 448 && v_cnt >= 96 && v_cnt < 144) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end 
            else if (h_cnt >= 384 && h_cnt < 448 && v_cnt >= 192 && v_cnt < 240) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end 
            else if (h_cnt >= 384 && h_cnt < 448 && v_cnt >= 288 && v_cnt < 336) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 384 && h_cnt < 448 && v_cnt >= 384 && v_cnt < 432) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end

            //Octava Columna
            else if (h_cnt >= 448 && h_cnt < 512 && v_cnt >= 48 && v_cnt < 96) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 448 && h_cnt < 512 && v_cnt >= 144 && v_cnt < 192) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 448 && h_cnt < 512 && v_cnt >= 240 && v_cnt < 288) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 448 && h_cnt < 512 && v_cnt >= 336 && v_cnt < 384) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 448 && h_cnt < 512 && v_cnt >= 432 && v_cnt < 480) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end

            //Novena columna
            else if (h_cnt >= 512 && h_cnt < 576 && v_cnt >= 0 && v_cnt < 48) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 512 && h_cnt < 576 && v_cnt >= 96 && v_cnt < 144) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end 
            else if (h_cnt >= 512 && h_cnt < 576 && v_cnt >= 192 && v_cnt < 240) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end 
            else if (h_cnt >= 512 && h_cnt < 576 && v_cnt >= 288 && v_cnt < 336) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 512 && h_cnt < 576 && v_cnt >= 384 && v_cnt < 432) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end

            //Decima Columna
            else if (h_cnt >= 576 && h_cnt < 640 && v_cnt >= 48 && v_cnt < 96) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 576 && h_cnt < 640 && v_cnt >= 144 && v_cnt < 192) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 576 && h_cnt < 640 && v_cnt >= 240 && v_cnt < 288) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 576 && h_cnt < 640 && v_cnt >= 336 && v_cnt < 384) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            else if (h_cnt >= 576 && h_cnt < 640 && v_cnt >= 432 && v_cnt < 480) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            
                else begin
                {red, green, blue} = {8'h00, 8'hFF, 8'h80}; // verde menta (Fondo)
            end
        end
    end

    assign r = red;
    assign g = green;
    assign b = blue;

endmodule
