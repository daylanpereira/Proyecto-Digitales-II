/* la idea principal del proyecto es generar 2 modulos, uno para transmitir y y otro para recibir.*/
// por lo que este programa sera la base para generar el mas grande, 
//que es la union de todos los programas y asi generar el full duplex.



// primero s genera el modulo transmisor 
module transmitter (
    input wire clk,              // Reloj del sistema
    input wire rst,              // Señal de reinicio
    input wire [7:0] data_in,    // Datos paralelos a transmitir
    input wire start,            // Señal de inicio de transmisión
    output reg tx,               // Línea serial de salida
    output reg ready             // Señal para indicar que está listo
);
    // Parámetros de estado
    parameter IDLE = 3'b000, START = 3'b001, DATA = 3'b010, PARITY = 3'b011, STOP = 3'b100;

    reg [2:0] state = IDLE;       // Estado actual
    reg [3:0] bit_index;          // Contador de bits de datos
    reg [7:0] data_buffer;        // Buffer para los datos a transmitir
    reg parity_bit;               // Bit de paridad
    reg [3:0] sample_count;       // Contador para sincronización

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Inicializar valores
            state <= IDLE;
            tx <= 1'b1;            // Línea inactiva (alto)
            ready <= 1'b1;         // Listo para recibir nuevos datos
            bit_index <= 0;
            data_buffer <= 8'b0;
            parity_bit <= 0;
            sample_count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;    // Línea inactiva
                    ready <= 1'b1; // Listo para recibir datos
                    if (start) begin
                        data_buffer <= data_in;  // Cargar datos a transmitir
                        parity_bit <= ^data_in;  // Calcular paridad (XOR de los datos)
                        bit_index <= 0;
                        sample_count <= 0;
                        state <= START;          // Ir al estado START
                        ready <= 1'b0;          // No está listo mientras transmite
                    end
                end

                START: begin
                    tx <= 1'b0;  // Transmitir el bit de inicio
                    if (sample_count == 15) begin
                        sample_count <= 0;
                        state <= DATA; // Ir al estado DATA
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end

                DATA: begin
                    tx <= data_buffer[bit_index]; // Transmitir el bit actual
                    if (sample_count == 15) begin
                        sample_count <= 0;
                        if (bit_index == 7) begin
                            state <= PARITY; // Todos los bits transmitidos, ir a PARITY
                        end else begin
                            bit_index <= bit_index + 1; // Avanzar al siguiente bit
                        end
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end

                PARITY: begin
                    tx <= parity_bit; // Transmitir el bit de paridad
                    if (sample_count == 15) begin
                        sample_count <= 0;
                        state <= STOP; // Ir al estado STOP
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end

                STOP: begin
                    tx <= 1'b1; // Transmitir el bit de parada
                    if (sample_count == 15) begin
                        sample_count <= 0;
                        state <= IDLE; // Volver a IDLE
                        ready <= 1'b1; // Indicar que está listo
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end
            endcase
        end
    end
endmodule




