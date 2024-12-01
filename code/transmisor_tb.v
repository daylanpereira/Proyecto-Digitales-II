module transmitter_tb;
    reg clk;
    reg rst;
    reg start;
    reg [7:0] data_in;
    wire tx;
    wire ready;

    transmitter uut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .start(start),
        .tx(tx),
        .ready(ready)
    );

    // Generador de reloj
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        data_in = 8'b0;
        #20 rst = 0;

        // Transmitir el primer dato
        #40 data_in = 8'b10101010; // Enviar 0xAA
        start = 1;
        #10 start = 0;

        // Esperar a que termine
        wait(ready == 1);

        // Transmitir el segundo dato
        #40 data_in = 8'b11001100; // Enviar 0xCC
        start = 1;
        #10 start = 0;

        #500;
        $finish;
    end

    initial begin
        $dumpfile("transmitter_waveform.vcd");
        $dumpvars(0, transmitter_tb);
    end
endmodule

