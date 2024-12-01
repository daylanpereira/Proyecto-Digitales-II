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



    
    endmodule