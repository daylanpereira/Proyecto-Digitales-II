module transmitter (
    input wire clk,              // Reloj del sistema
    input wire rst,              // Señal de reset
    input wire [7:0] data_in,    // Datos paralelos a transmitir
    input wire start,            // Señal de inicio de transmisión
    output reg tx,               // Línea serial de salida
    output reg ready,            // Señal para indicar que está listo
    output reg [2:0] state       // Estado actual para monitoreo
);
    // Parámetros de estado
    parameter IDLE = 3'b000, START = 3'b001, DATA = 3'b010, PARITY = 3'b011, STOP = 3'b100;

    reg [3:0] sample_count;      // Contador para sincronización
    reg [3:0] bit_index;         // Contador de bits de datos
    reg [7:0] data_buffer;       // Buffer para los datos a transmitir
    reg parity_bit;              // Bit de paridad

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx <= 1'b1;          // Línea inactiva (alto)
            ready <= 1'b1;       // Listo para recibir nuevos datos
            bit_index <= 0;
            data_buffer <= 8'b0;
            parity_bit <= 0;
            sample_count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1; // Línea inactiva
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
                    tx <= 1'b0; // Bit de inicio
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
                        if (bit_index == 7) state <= PARITY;
                        else bit_index <= bit_index + 1;
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
                    tx <= 1'b1; // Bit de parada
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

module receptor (
    input wire clk,              // Reloj UART
    input wire rst,              // Señal de reset
    input wire rx,               // Línea serial de entrada
    output reg [7:0] data_out,   // Salida paralela de datos
    output reg valid,            // Señal para indicar datos válidos
    output reg [2:0] state       // Estado actual para monitoreo
);
    // Parámetros de estado
    parameter IDLE = 3'b000, START = 3'b001, DATA = 3'b010, PARITY = 3'b011, STOP = 3'b100;

    reg [3:0] bit_index;         // Contador de bits
    reg [3:0] sample_count;      // Contador para sincronización
    reg [7:0] data_buffer;       // Buffer para los datos recibidos
    reg parity_bit;              // Bit de paridad recibido
    reg calculated_parity;       // Paridad calculada

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            valid <= 1'b0;
            data_out <= 8'b0;
            data_buffer <= 8'b0;
            parity_bit <= 1'b0;
            calculated_parity <= 1'b0;
            sample_count <= 0;
            bit_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    valid <= 1'b0;
                    if (!rx) state <= START; // Detectar bit de inicio
                end

                START: begin
                    if (sample_count == 7) begin
                        sample_count <= 0;
                        if (!rx) state <= DATA; // Validar bit de inicio
                        else state <= IDLE;
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end

                DATA: begin
                    if (sample_count == 15) begin
                        sample_count <= 0;
                        data_buffer[bit_index] <= rx; // Leer bit recibido
                        if (bit_index == 7) state <= PARITY;
                        else bit_index <= bit_index + 1;
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end

                PARITY: begin
                    if (sample_count == 15) begin
                        sample_count <= 0;
                        parity_bit <= rx;
                        calculated_parity <= ^data_buffer;
                        if (calculated_parity == parity_bit) state <= STOP;
                        else state <= IDLE; // Paridad incorrecta
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end

                STOP: begin
                    if (sample_count == 15) begin
                        sample_count <= 0;
                        if (rx) begin
                            data_out <= data_buffer;
                            valid <= 1'b1;
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

// *MODULO 2*

module transmitter_2 (
    input wire clk,              // Reloj del sistema
    input wire rst,              // Señal de reset
    input wire [7:0] data_in_2,    // Datos paralelos a transmitir
    input wire start_2,            // Señal de inicio de transmisión
    output reg tx_2,               // Línea serial de salida
    output reg ready_2,            // Señal para indicar que está listo
    output reg [2:0] state_2       // Estado actual para monitoreo
);
    // Parámetros de estado
    parameter IDLE = 3'b000, START = 3'b001, DATA = 3'b010, PARITY = 3'b011, STOP = 3'b100;

    reg [3:0] sample_count_2;      // Contador para sincronización
    reg [3:0] bit_index_2;         // Contador de bits de datos
    reg [7:0] data_buffer_2;       // Buffer para los datos a transmitir
    reg parity_bit_2;              // Bit de paridad

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_2 <= IDLE;
            tx_2 <= 1'b1;          // Línea inactiva (alto)
            ready_2 <= 1'b1;       // Listo para recibir nuevos datos
            bit_index_2 <= 0;
            data_buffer_2 <= 8'b0;
            parity_bit_2 <= 0;
            sample_count_2 <= 0;
        end else begin
            case (state_2)
                IDLE: begin
                    tx_2 <= 1'b1; // Línea inactiva
                    ready_2 <= 1'b1;
                    if (start_2) begin
                        data_buffer_2 <= data_in_2;
                        parity_bit_2 <= ^data_in_2;
                        bit_index_2 <= 0;
                        sample_count_2 <= 0;
                        state_2 <= START;
                        ready_2 <= 1'b0;
                    end
                end

                START: begin
                    tx_2 <= 1'b0; // Bit de inicio
                    if (sample_count_2 == 15) begin
                        sample_count_2 <= 0;
                        state_2 <= DATA;
                    end else begin
                        sample_count_2 <= sample_count_2 + 1;
                    end
                end

                DATA: begin
                    tx_2 <= data_buffer_2[bit_index_2];
                    if (sample_count_2 == 15) begin
                        sample_count_2 <= 0;
                        if (bit_index_2 == 7) state_2 <= PARITY;
                        else bit_index_2 <= bit_index_2 + 1;
                    end else begin
                        sample_count_2 <= sample_count_2 + 1;
                    end
                end

                PARITY: begin
                    tx_2 <= parity_bit_2;
                    if (sample_count_2 == 15) begin
                        sample_count_2 <= 0;
                        state_2 <= STOP;
                    end else begin
                        sample_count_2 <= sample_count_2 + 1;
                    end
                end

                STOP: begin
                    tx_2 <= 1'b1; // Bit de parada
                    if (sample_count_2 == 15) begin
                        sample_count_2 <= 0;
                        state_2 <= IDLE;
                        ready_2 <= 1'b1;
                    end else begin
                        sample_count_2 <= sample_count_2 + 1;
                    end
                end
            endcase
        end
    end
endmodule

module receptor_2 (
    input wire clk,              // Reloj UART
    input wire rst,              // Señal de reset
    input wire rx_2,               // Línea serial de entrada
    output reg [7:0] data_out_2,   // Salida paralela de datos
    output reg valid_2,            // Señal para indicar datos válidos
    output reg [2:0] state_2       // Estado actual para monitoreo
);
    // Parámetros de estado
    parameter IDLE = 3'b000, START = 3'b001, DATA = 3'b010, PARITY = 3'b011, STOP = 3'b100;

    reg [3:0] bit_index_2;         // Contador de bits
    reg [3:0] sample_count_2;      // Contador para sincronización
    reg [7:0] data_buffer_2;       // Buffer para los datos recibidos
    reg parity_bit_2;              // Bit de paridad recibido
    reg calculated_parity_2;       // Paridad calculada

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_2 <= IDLE;
            valid_2 <= 1'b0;
            data_out_2 <= 8'b0;
            data_buffer_2 <= 8'b0;
            parity_bit_2 <= 1'b0;
            calculated_parity_2 <= 1'b0;
            sample_count_2 <= 0;
            bit_index_2 <= 0;
        end else begin
            case (state_2)
                IDLE: begin
                    valid_2 <= 1'b0;
                    if (!rx_2) state_2 <= START; // Detectar bit de inicio
                end

                START: begin
                    if (sample_count_2 == 7) begin
                        sample_count_2 <= 0;
                        if (!rx_2) state_2 <= DATA; // Validar bit de inicio
                        else state_2 <= IDLE;
                    end else begin
                        sample_count_2 <= sample_count_2 + 1;
                    end
                end

                DATA: begin
                    if (sample_count_2 == 15) begin
                        sample_count_2 <= 0;
                        data_buffer_2[bit_index_2] <= rx_2; // Leer bit recibido
                        if (bit_index_2 == 7) state_2 <= PARITY;
                        else bit_index_2 <= bit_index_2 + 1;
                    end else begin
                        sample_count_2 <= sample_count_2 + 1;

                    end
                end

                PARITY: begin
                    if (sample_count_2 == 15) begin
                        sample_count_2 <= 0;
                        parity_bit_2 <= rx_2;
                        calculated_parity_2 <= ^data_buffer_2;
                        if (calculated_parity_2 == parity_bit_2) state_2 <= STOP;
                        else state_2 <= IDLE; // Paridad incorrecta
                    end else begin
                        sample_count_2 <= sample_count_2 + 1;
                    end
                end

                STOP: begin
                    if (sample_count_2 == 15) begin
                        sample_count_2 <= 0;
                        if (rx_2) begin
                            data_out_2 <= data_buffer_2;
                            valid_2 <= 1'b1;
                        end
                        state_2 <= IDLE;
                    end else begin
                        sample_count_2 <= sample_count_2 + 1;
                    end
                end
            endcase
        end
    end
endmodule










