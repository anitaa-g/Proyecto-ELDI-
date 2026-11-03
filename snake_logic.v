module snake_logic (
    input clk_pixel,
    input rst_n,
    input [7:0] rx_data,     // Tecla presionada desde el PC
    input rx_valid,          // Pulso que indica que llegó una nueva tecla
    output reg [4:0] head_x,
    output reg [4:0] head_y,
    output reg [4:0] body1_x, output reg [4:0] body1_y,
    output reg [4:0] body2_x, output reg [4:0] body2_y,
    output reg [4:0] body3_x, output reg [4:0] body3_y
);

    // Reloj de Movimiento
    reg [22:0] tick_cnt = 0;
    wire move_tick = (tick_cnt == 23'd6_250_000);

    always @(posedge clk_pixel or negedge rst_n) begin
        if (!rst_n) tick_cnt <= 0;
        else if (move_tick) tick_cnt <= 0;
        else tick_cnt <= tick_cnt + 1;
    end

    // Máquina de Estados (Dirección) controlada por UART
    localparam UP = 2'b00, DOWN = 2'b01, LEFT = 2'b10, RIGHT = 2'b11;
    reg [1:0] dir_state;

    always @(posedge clk_pixel or negedge rst_n) begin
        if (!rst_n) begin
            dir_state <= RIGHT;
        end else if (rx_valid) begin
            // ASCII: 'w'=8'h77, 's'=8'h73, 'a'=8'h61, 'd'=8'h64
            if (rx_data == 8'h77 && dir_state != DOWN)       dir_state <= UP;
            else if (rx_data == 8'h73 && dir_state != UP)    dir_state <= DOWN;
            else if (rx_data == 8'h61 && dir_state != RIGHT) dir_state <= LEFT;
            else if (rx_data == 8'h64 && dir_state != LEFT)  dir_state <= RIGHT;
        end
    end

    // Actualización de Coordenadas
    always @(posedge clk_pixel or negedge rst_n) begin
        if (!rst_n) begin
            head_x <= 5; head_y <= 2;
            body1_x <= 0; body1_y <= 0;
        end else if (move_tick) begin
            body3_x <= body2_x; body3_y <= body2_y;
            body2_x <= body1_x; body2_y <= body1_y;
            body1_x <= head_x;  body1_y <= head_y; 

            case (dir_state)
                UP:    head_y <= (head_y == 0) ? 19 : head_y - 1;
                DOWN:  head_y <= (head_y == 19) ? 0 : head_y + 1;
                LEFT:  head_x <= (head_x == 0) ? 19 : head_x - 1;
                RIGHT: head_x <= (head_x == 19) ? 0 : head_x + 1;
            endcase
        end
    end
endmodule