module receptor (
    input wire clk,          // Reloj del sistema
    input wire rst,          // Señal de reset
    input wire rx,           // Entrada serial (línea de recepción)
    output reg [7:0] data_out, // Salida paralela de datos
    output reg valid         // Señal que indica datos válidos
);
    // Parámetros de estado
    parameter IDLE = 3'b000, START = 3'b001, DATA = 3'b010, PARITY = 3'b011, STOP = 3'b100;

    reg [2:0] state = IDLE;         // Estado actual
    reg [3:0] bit_index;            // Contador de bits
    reg [7:0] data_buffer;          // Almacena los datos recibidos
    reg parity_bit;                 // Bit de paridad recibido
    reg calculated_parity;          // Paridad calculada
    reg [3:0] sample_count;         // Contador para sincronización
    reg valid_next;                 // Señal temporal para manejar `valid`



always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Inicializar valores
            state <= IDLE;
            bit_index <= 0;
            data_out <= 8'b0;
            data_buffer <= 8'b0;
            valid <= 0;
            valid_next <= 0;
            parity_bit <= 0;
            calculated_parity <= 0;
            sample_count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    valid <= valid_next;       // Mantener `valid` por un ciclo
                    valid_next <= 0;          // Reinicia después de un ciclo
                    sample_count <= 0;
                    if (!rx) state <= START; // Detectar bit de inicio
                end

                START: begin
                    if (sample_count == 7) begin
                        sample_count <= 0;
                        if (!rx) state <= DATA; // Confirmar bit de inicio
                        else state <= IDLE;    // Volver a IDLE si no es válido
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end

                DATA: begin
                    if (sample_count == 15) begin
                        sample_count <= 0;
                        data_buffer[bit_index] <= rx; // Leer bit de datos
                        bit_index <= bit_index + 1;
                        if (bit_index == 7) state <= PARITY; // Todos los datos leídos
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end

                PARITY: begin
                    if (sample_count == 15) begin
                        sample_count <= 0;
                        parity_bit <= rx;                 // Leer bit de paridad
                        calculated_parity <= ^data_buffer; // Calcular paridad
                        if (calculated_parity == parity_bit) state <= STOP; // Verificar paridad
                        else state <= IDLE;               // Paridad incorrecta
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end

                STOP: begin
                    if (sample_count == 15) begin
                        sample_count <= 0;
                        if (rx) begin // Validar bit de parada
                            data_out <= data_buffer; // Transferir datos al registro de salida
                            valid_next <= 1;         // Activar validación temporal
                        end
                        state <= IDLE;             // Volver a IDLE
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end
            endcase
        end
    end


    
endmodule