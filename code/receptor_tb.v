module receptor_tb;
    reg clk;
    reg rst;
    reg rx;
    wire [7:0] data_out;
    wire valid;

    receptor uut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data_out(data_out),
        .valid(valid)
    );

    // Generador de reloj
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        rx = 1; // Línea en reposo
        #20 rst = 0;

        // Simulación de un paquete UART
        #160 rx = 0; // Bit de inicio
        #160 rx = 1; // Bit 0
        #160 rx = 0; // Bit 1
        #160 rx = 1; // Bit 2
        #160 rx = 0; // Bit 3
        #160 rx = 1; // Bit 4
        #160 rx = 0; // Bit 5
        #160 rx = 1; // Bit 6
        #160 rx = 0; // Bit 7
        #160 rx = 1; // Bit de paridad (par)
        #160 rx = 1; // Bit de parada
        #320;

        if (valid && data_out == 8'b10101010) $display("Prueba pasada: Datos correctos.");
        else $display("Prueba fallida: Datos incorrectos.");

        $finish;
    end

    initial begin
        $dumpfile("receptor_waveform.vcd");
        $dumpvars(0, receptor_tb);
    end
endmodule
