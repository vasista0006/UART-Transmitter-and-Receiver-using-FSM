module tb_uart;
    reg clk=0, reset=1, tx_start=0, rx;
    reg [7:0] data_in=8'h00;
    wire tx, tx_done, rx_done;
    wire [7:0] data_out;

    UART_Tx_Rx dut(.clk(clk), .reset(reset), .data_in(data_in),
                   .tx_start(tx_start), .tx(tx), .tx_done(tx_done),
                   .rx(rx), .data_out(data_out), .rx_done(rx_done));

    always #10 clk = ~clk;  // 50 MHz clock

    initial begin
        $display("UART Simulation Start");
        reset = 1; #100; reset = 0;
        data_in = 8'hA5; tx_start = 1; #20; tx_start = 0;
        rx = 1; #100000;
        $finish;
    end
endmodule
