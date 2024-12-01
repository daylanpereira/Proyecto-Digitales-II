module uart_dut (
    input wire clk,             // Reloj del sistema
    input wire rst,             // Señal de reinicio
    input wire start,           // Señal de inicio de transmisión
    input wire [7:0] tx_data_in, // Datos a transmitir
    output wire tx,             // Línea serial de salida del transmisor
    output wire tx_ready,       // Indica que el transmisor está listo
    input wire rx,              // Línea serial de entrada para el receptor
    output wire [7:0] rx_data_out, // Datos recibidos por el receptor
    output wire rx_ready        // Indica que los datos del receptor están listos
);
    // Instancia del transmisor UART
    transmitter tx_unit (
        .clk(clk),
        .rst(rst),
        .data_in(tx_data_in),
        .start(start),
        .tx(tx),
        .ready(tx_ready)
    );

    // Instancia del receptor UART
    receiver rx_unit (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data_out(rx_data_out),
        .ready(rx_ready)
    );
endmodule

// Transmisor UART
module transmitter (
    input wire clk,              // Reloj del sistema
    input wire rst,              // Señal de reinicio
    input wire [7:0] data_in,    // Datos paralelos a transmitir
    input wire start,            // Señal de inicio de transmisión
    output reg tx,               // Línea serial de salida
    output reg ready             // Señal para indicar que está listo
);
    parameter IDLE = 3'b000, START = 3'b001, DATA = 3'b010, PARITY = 3'b011, STOP = 3'b100;
    reg [2:0] state = IDLE;
    reg [3:0] bit_index;
    reg [7:0] data_buffer;
    reg parity_bit;
    reg [3:0] sample_count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx <= 1'b1;
            ready <= 1'b1;
            bit_index <= 0;
            data_buffer <= 8'b0;
            parity_bit <= 0;
            sample_count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    ready <= 1'b1;
                    if (start) begin
                        data_buffer <= data_in;
                        parity_bit <= ^data_in;
                        bit_index <= 0;
                        sample_count <= 0;
                        state <= START;
                        ready <= 1'b0;
                    end
                end
                START: begin
                    tx <= 1'b0;
                    if (sample_count == 15) begin
                        sample_count <= 0;
                        state <= DATA;
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end
                DATA: begin
                    tx <= data_buffer[bit_index];
                    if (sample_count == 15) begin
                        sample_count <= 0;
                        if (bit_index == 7) begin
                            state <= PARITY;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end
                PARITY: begin
                    tx <= parity_bit;
                    if (sample_count == 15) begin
                        sample_count <= 0;
                        state <= STOP;
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end
                STOP: begin
                    tx <= 1'b1;
                    if (sample_count == 15) begin
                        sample_count <= 0;
                        state <= IDLE;
                        ready <= 1'b1;
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end
            endcase
        end
    end
endmodule

// Receptor UART
module receiver (
    input wire clk,           // Reloj del sistema
    input wire rst,           // Señal de reinicio
    input wire rx,            // Línea serial de entrada
    output reg [7:0] data_out, // Datos paralelos recibidos
    output reg ready          // Señal para indicar que los datos están listos
);
    parameter IDLE = 3'b000, START = 3'b001, DATA = 3'b010, PARITY = 3'b011, STOP = 3'b100;
    reg [2:0] state = IDLE;
    reg [3:0] bit_index;
    reg [7:0] data_buffer;
    reg parity_bit;
    reg [3:0] sample_count;
    reg calculated_parity;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            data_out <= 8'b0;
            ready <= 1'b0;
            bit_index <= 0;
            data_buffer <= 8'b0;
            parity_bit <= 0;
            calculated_parity <= 0;
            sample_count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    ready <= 1'b0;
                    if (rx == 1'b0) begin
                        bit_index <= 0;
                        sample_count <= 0;
                        state <= START;
                    end
                end
                START: begin
                    if (sample_count == 7) begin
                        sample_count <= 0;
                        state <= DATA;
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end
                DATA: begin
                    if (sample_count == 15) begin
                        data_buffer[bit_index] <= rx;
                        sample_count <= 0;
                        if (bit_index == 7) begin
                            state <= PARITY;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end
                PARITY: begin
                    if (sample_count == 15) begin
                        parity_bit <= rx;
                        calculated_parity <= ^data_buffer;
                        sample_count <= 0;
                        state <= STOP;
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end
                STOP: begin
                    if (sample_count == 15) begin
                        sample_count <= 0;
                        if (rx == 1'b1 && parity_bit == calculated_parity) begin
                            data_out <= data_buffer;
                            ready <= 1'b1;
                        end
                        state <= IDLE;
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end
            endcase
        end
    end
endmodule 

	
