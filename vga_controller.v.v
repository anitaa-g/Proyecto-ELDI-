module vga_controller (
    input  wire clk_pixel,
    input  wire rst_n,
    input  wire [4:0] head_x,  // Coordenada X dinámica
    input  wire [4:0] head_y,  // Coordenada Y dinámica
    input  wire [4:0] body1_x,
    input  wire [4:0] body1_y,
    input  wire [4:0] body2_x,
    input  wire [4:0] body2_y,
    input  wire [4:0] body3_x,
    input  wire [4:0] body3_y,
    output wire hs,
    output wire vs,
    output wire de,
    output wire [7:0] r,
    output wire [7:0] g,
    output wire [7:0] b
);

    parameter H_VISIBLE = 640, H_FRONT = 16, H_SYNC = 96, H_BACK = 48, H_TOTAL = 800;
    parameter V_VISIBLE = 480, V_FRONT = 10, V_SYNC = 2, V_BACK = 33, V_TOTAL = 525;

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
                v_cnt <= (v_cnt == V_TOTAL - 1) ? 0 : v_cnt + 1;
            end else begin
                h_cnt <= h_cnt + 1;
            end
        end
    end

    // Generación de pulsos de sincronización
    assign hs = ~((h_cnt >= H_VISIBLE + H_FRONT) && (h_cnt < H_VISIBLE + H_FRONT + H_SYNC));
    assign vs = ~((v_cnt >= V_VISIBLE + V_FRONT) && (v_cnt < V_VISIBLE + V_FRONT + V_SYNC));
    assign de = (h_cnt < H_VISIBLE) && (v_cnt < V_VISIBLE);

    reg [7:0] red, green, blue;
    
    // Lógica de Dibujo Combinacional
    always @(*) begin
        if (!de) begin
            {red, green, blue} = {8'h00, 8'h00, 8'h00};
        end else begin
// 1. Cabeza (Azul cielo)
            if (h_cnt >= (head_x * 32) && h_cnt < ((head_x + 1) * 32) && 
                v_cnt >= (head_y * 24) && v_cnt < ((head_y + 1) * 24)) begin
                {red, green, blue} = {8'h7D, 8'hB5, 8'hFA}; 
            end
            
            // 1.5 Cuerpo de la serpiente (Azul oscuro)
            else if ((h_cnt >= (body1_x * 32) && h_cnt < ((body1_x + 1) * 32) && v_cnt >= (body1_y * 24) && v_cnt < ((body1_y + 1) * 24)) ||
                     (h_cnt >= (body2_x * 32) && h_cnt < ((body2_x + 1) * 32) && v_cnt >= (body2_y * 24) && v_cnt < ((body2_y + 1) * 24)) ||
                     (h_cnt >= (body3_x * 32) && h_cnt < ((body3_x + 1) * 32) && v_cnt >= (body3_y * 24) && v_cnt < ((body3_y + 1) * 24))) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF}; 
            end
            
            // 2. Manzanas estáticas
            else if (h_cnt >= 394 && h_cnt < 438 && v_cnt >= 154 && v_cnt < 182) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00}; // Amarillo
            end
            else if (h_cnt >= 138 && h_cnt < 182 && v_cnt >= 346 && v_cnt < 374) begin
                {red, green, blue} = {8'hFF, 8'h00, 8'h00}; // Rojo
            end
            
            // 3. Generación automática del fondo cuadriculado
            // Evalúa si la celda actual X e Y coinciden en paridad (ambas pares o ambas impares)
            else if (((h_cnt / 32) % 2) == ((v_cnt / 24) % 2)) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00}; // Verde oscuro
            end
            
            // 4. Color por defecto del fondo
            else begin
                {red, green, blue} = {8'h00, 8'hFF, 8'h80}; // Verde menta
            end
        end
    end

    assign r = red;
    assign g = green;
    assign b = blue;

endmodule
