module vga_controller (
    input  wire clk_pixel,
    input  wire rst_n,
    
    input  wire [4:0] head_x,       input  wire [4:0] head_y,
    input  wire [4:0] apple_good_x, input  wire [4:0] apple_good_y,
    input  wire [4:0] apple_bad_x,  input  wire [4:0] apple_bad_y,
    input  wire [3:0] snake_length,
    
    input  wire [49:0] body_x_flat,
    input  wire [49:0] body_y_flat,
    input  wire game_over,
    input  wire game_win,

    output wire hs, vs, de,
    output wire [7:0] r, g, b
);

    parameter H_VISIBLE = 640, H_FRONT = 16, H_SYNC = 96, H_BACK = 48, H_TOTAL = 800;
    parameter V_VISIBLE = 480, V_FRONT = 10, V_SYNC = 2, V_BACK = 33, V_TOTAL = 525;

    reg [9:0] h_cnt = 0; reg [9:0] v_cnt = 0;

    always @(posedge clk_pixel or negedge rst_n) begin
        if (!rst_n) begin
            h_cnt <= 0; v_cnt <= 0;
        end else begin
            if (h_cnt == H_TOTAL - 1) begin
                h_cnt <= 0; v_cnt <= (v_cnt == V_TOTAL - 1) ? 0 : v_cnt + 1;
            end else h_cnt <= h_cnt + 1;
        end
    end

    assign hs = ~((h_cnt >= H_VISIBLE + H_FRONT) && (h_cnt < H_VISIBLE + H_FRONT + H_SYNC));
    assign vs = ~((v_cnt >= V_VISIBLE + V_FRONT) && (v_cnt < V_VISIBLE + V_FRONT + V_SYNC));
    assign de = (h_cnt < H_VISIBLE) && (v_cnt < V_VISIBLE);

    reg [7:0] red, green, blue;
    
    reg is_body;
    integer k;

    always @(*) begin
        is_body = 1'b0;
        for (k = 0; k < 10; k = k + 1) begin // Bucle extendido a 128
            if (k < snake_length) begin
                if (h_cnt >= (body_x_flat[k*5 +: 5] * 32) && h_cnt < ((body_x_flat[k*5 +: 5] + 1) * 32) && 
                    v_cnt >= (body_y_flat[k*5 +: 5] * 24) && v_cnt < ((body_y_flat[k*5 +: 5] + 1) * 24)) begin
                    is_body = 1'b1;
                end
            end
        end

        if (!de) begin
            {red, green, blue} = {8'h00, 8'h00, 8'h00};
        end else begin
            // 1. JERARQUÍA MÁXIMA: Pantallas de fin de juego
            // Y
            if (game_over && h_cnt >= 222 && h_cnt < 229 && v_cnt >= 200 && v_cnt < 240) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            else if (game_over && h_cnt >= 229 && h_cnt < 236 && v_cnt >= 240 && v_cnt < 280) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            else if (game_over && h_cnt >= 236 && h_cnt < 243 && v_cnt >= 200 && v_cnt < 240) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            //O
            else if (game_over && h_cnt >= 247 && h_cnt < 254 && v_cnt >= 200 && v_cnt < 280) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            else if (game_over && h_cnt >= 254 && h_cnt < 261 && v_cnt >= 200 && v_cnt < 207) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            else if (game_over && h_cnt >= 254 && h_cnt < 261 && v_cnt >= 273 && v_cnt < 280) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            else if (game_over && h_cnt >= 261 && h_cnt < 268 && v_cnt >= 200 && v_cnt < 280) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            //U
            else if (game_over && h_cnt >= 272 && h_cnt < 279 && v_cnt >= 200 && v_cnt < 280) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            else if (game_over && h_cnt >= 279 && h_cnt < 286 && v_cnt >= 273 && v_cnt < 280) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            else if (game_over && h_cnt >= 286 && h_cnt < 293 && v_cnt >= 200 && v_cnt < 280) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            //L
            else if (game_over && h_cnt >= 322 && h_cnt < 329 && v_cnt >= 200 && v_cnt < 280) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            else if (game_over && h_cnt >= 329 && h_cnt < 343 && v_cnt >= 273 && v_cnt < 280) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            //O
            else if (game_over && h_cnt >= 347 && h_cnt < 354 && v_cnt >= 200 && v_cnt < 280) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            else if (game_over && h_cnt >= 354 && h_cnt < 361 && v_cnt >= 200 && v_cnt < 207) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            else if (game_over && h_cnt >= 354 && h_cnt < 361 && v_cnt >= 273 && v_cnt < 280) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            else if (game_over && h_cnt >= 361 && h_cnt < 368 && v_cnt >= 200 && v_cnt < 280) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            //S
            else if (game_over && h_cnt >= 372 && h_cnt < 393 && v_cnt >= 200 && v_cnt < 207) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            else if (game_over && h_cnt >= 372 && h_cnt < 379 && v_cnt >= 207 && v_cnt < 236) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            else if (game_over && h_cnt >= 372 && h_cnt < 393 && v_cnt >= 236 && v_cnt < 243) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            else if (game_over && h_cnt >= 386 && h_cnt < 393 && v_cnt >= 243 && v_cnt < 273) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            else if (game_over && h_cnt >= 372 && h_cnt < 393 && v_cnt >= 273 && v_cnt < 280) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            //E
            else if (game_over && h_cnt >= 397 && h_cnt < 418 && v_cnt >= 200 && v_cnt < 207) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            else if (game_over && h_cnt >= 397 && h_cnt < 418 && v_cnt >= 236 && v_cnt < 243) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            else if (game_over && h_cnt >= 397 && h_cnt < 418 && v_cnt >= 273 && v_cnt < 280) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            else if (game_over && h_cnt >= 397 && h_cnt < 404 && v_cnt >= 200 && v_cnt < 280) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00};
            end
            //FONDO DERROTA
            else if (game_over && h_cnt >= 220 && h_cnt < 420 && v_cnt >= 190 && v_cnt < 290) begin
                {red, green, blue} = {8'hFF, 8'h00, 8'h00}; // Caja Roja (Pierdes)
            end
            // Y
            else if (game_win && h_cnt >= 222 && h_cnt < 229 && v_cnt >= 200 && v_cnt < 240) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF};
            end
            else if (game_win && h_cnt >= 229 && h_cnt < 236 && v_cnt >= 240 && v_cnt < 280) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF};
            end
            else if (game_win && h_cnt >= 236 && h_cnt < 243 && v_cnt >= 200 && v_cnt < 240) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF};
            end
            //O
            else if (game_win && h_cnt >= 247 && h_cnt < 254 && v_cnt >= 200 && v_cnt < 280) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF};
            end
            else if (game_win && h_cnt >= 254 && h_cnt < 261 && v_cnt >= 200 && v_cnt < 207) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF};
            end
            else if (game_win && h_cnt >= 254 && h_cnt < 261 && v_cnt >= 273 && v_cnt < 280) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF};
            end
            else if (game_win && h_cnt >= 261 && h_cnt < 268 && v_cnt >= 200 && v_cnt < 280) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF};
            end
            //U
            else if (game_win && h_cnt >= 272 && h_cnt < 279 && v_cnt >= 200 && v_cnt < 280) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF};
            end
            else if (game_win && h_cnt >= 279 && h_cnt < 286 && v_cnt >= 273 && v_cnt < 280) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF};
            end
            else if (game_win && h_cnt >= 286 && h_cnt < 293 && v_cnt >= 200 && v_cnt < 280) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF};
            end
            //N
            else if (game_win && h_cnt >= 411 && h_cnt < 418 && v_cnt >= 200 && v_cnt < 280) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF};
            end
            else if (game_win && h_cnt >= 404 && h_cnt < 411 && v_cnt >= 252 && v_cnt < 266) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF};
            end
            else if (game_win && h_cnt >= 397 && h_cnt < 404 && v_cnt >= 238 && v_cnt < 252) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF};
            end
            else if (game_win && h_cnt >= 390 && h_cnt < 397 && v_cnt >= 200 && v_cnt < 280) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF};
            end
            //I
            else if (game_win && h_cnt >= 379 && h_cnt < 386 && v_cnt >= 200 && v_cnt < 280) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF};
            end
            //W
            else if (game_win && h_cnt >= 368 && h_cnt < 375 && v_cnt >= 200 && v_cnt < 280) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF};
            end
            else if (game_win && h_cnt >= 340 && h_cnt < 375 && v_cnt >= 273 && v_cnt < 280) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF};
            end
            else if (game_win && h_cnt >= 340 && h_cnt < 347 && v_cnt >= 200 && v_cnt < 280) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF};
            end
            else if (game_win && h_cnt >= 354 && h_cnt < 361 && v_cnt >= 244 && v_cnt < 280) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF};
            end
            


            //FONDO VICTORIA
            else if (game_win && h_cnt >= 220 && h_cnt < 420 && v_cnt >= 190 && v_cnt < 290) begin
                {red, green, blue} = {8'hFF, 8'hD7, 8'h00}; // Caja Dorada (Ganas)
            end
            
            // 2. Dibujo normal del juego (Cabeza)
            else if (h_cnt >= (head_x * 32) && h_cnt < ((head_x + 1) * 32) && 
                     v_cnt >= (head_y * 24) && v_cnt < ((head_y + 1) * 24)) begin
                {red, green, blue} = {8'h7D, 8'hB5, 8'hFA}; 
            end
            // Cuerpo
            else if (is_body) begin
                {red, green, blue} = {8'h00, 8'h00, 8'hFF}; 
            end
            // Manzana Buena
            else if (h_cnt >= (apple_good_x * 32) && h_cnt < ((apple_good_x + 1) * 32) && 
                     v_cnt >= (apple_good_y * 24) && v_cnt < ((apple_good_y + 1) * 24)) begin
                {red, green, blue} = {8'hFF, 8'hFF, 8'h00}; 
            end
            // Manzana Mala
            else if (h_cnt >= (apple_bad_x * 32) && h_cnt < ((apple_bad_x + 1) * 32) && 
                     v_cnt >= (apple_bad_y * 24) && v_cnt < ((apple_bad_y + 1) * 24)) begin
                {red, green, blue} = {8'hFF, 8'h00, 8'h00}; 
            end
            // Fondo
            else if (((h_cnt / 32) % 2) == ((v_cnt / 24) % 2)) begin
                {red, green, blue} = {8'h00, 8'h80, 8'h00};
            end else begin
                {red, green, blue} = {8'h00, 8'hFF, 8'h80};
            end
        end
    end
    
    assign r = red; assign g = green; assign b = blue;
endmodule
