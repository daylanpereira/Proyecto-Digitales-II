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



endmodule 
