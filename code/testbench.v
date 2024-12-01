`timescale 1ns/1ps

module uart_dut_tb;
    // Señales del sistema
    reg clk;
    reg rst;
    reg start;
    reg [7:0] tx_data_in;
    wire tx;
    wire tx_ready;
    wire [7:0] rx_data_out;
    wire rx_ready;

    // Instancia del DUT
    uart_dut dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .tx_data_in(tx_data_in),
        .tx(tx),
        .tx_ready(tx_ready),
        .rx(tx), // Conexión loopback: El tx del transmisor se conecta al rx del receptor
        .rx_data_out(rx_data_out),
        .rx_ready(rx_ready)
    );

    // Generar reloj del sistema
    initial clk = 0;
    always #5 clk = ~clk; // Periodo de 10 ns

    // Simulación
    initial begin
        // Inicialización de señales
        $display("Inicio de simulación");
        rst = 1;
        start = 0;
        tx_data_in = 8'h00;

        // Liberar reset
        #20 rst = 0;
        $display("Reset liberado");

        // Enviar primer dato
        #20 tx_data_in = 8'hA5; // Enviar 0xA5
        start = 1;
        #10 start = 0;
        $display("Dato 0xA5 enviado");

        // Esperar a que el receptor reciba los datos
        wait(rx_ready);
        $display("Dato recibido: %h", rx_data_out);
        #20
        $finish;
    end

    // Monitor para observar las señales clave
    initial begin
        $monitor("Time: %0dns, TX: %b, RX_DATA_OUT: %h, RX_READY: %b, TX_READY: %b",
                 $time, tx, rx_data_out, rx_ready, tx_ready);
    end

    // Dumps para GTKWave
    initial begin
        $dumpfile("tb.vcd ");
        $dumpvars(0, uart_dut_tb);
    end
endmodule

