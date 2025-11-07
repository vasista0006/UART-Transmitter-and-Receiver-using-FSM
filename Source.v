module UART_Tx_Rx #(parameter CLK_FREQ=50000000, BAUD=9600)(
    input clk, reset,
    input [7:0] data_in,
    input tx_start,
    output reg tx, tx_done,
    input rx,
    output reg [7:0] data_out,
    output reg rx_done
);
    localparam DIV = CLK_FREQ/(BAUD*16);
    reg [15:0] baud_cnt;
    reg [3:0] bit_cnt;
    reg [9:0] tx_shift;
    reg [7:0] rx_shift;
    reg tx_busy, rx_busy;

    // Baud rate generator
    always @(posedge clk) begin
        if(reset) baud_cnt <= 0;
        else baud_cnt <= (baud_cnt==DIV-1) ? 0 : baud_cnt+1;
    end

    // Transmitter
    always @(posedge clk) begin
        if(reset) begin
            tx <= 1; tx_done <= 0; tx_busy <= 0;
        end else if(tx_start && !tx_busy) begin
            tx_shift <= {1'b1, data_in, 1'b0};
            tx_busy <= 1; bit_cnt <= 0;
        end else if(tx_busy && baud_cnt==0) begin
            tx <= tx_shift[0];
            tx_shift <= {1'b1, tx_shift[9:1]};
            bit_cnt <= bit_cnt + 1;
            if(bit_cnt==9) begin tx_busy<=0; tx_done<=1; end
            else tx_done<=0;
        end
    end

    // Receiver
    reg [3:0] sample_cnt;
    always @(posedge clk) begin
        if(reset) begin rx_busy<=0; rx_done<=0; end
        else if(!rx_busy && !rx) begin
            rx_busy<=1; sample_cnt<=0; bit_cnt<=0;
        end else if(rx_busy && baud_cnt==0) begin
            sample_cnt <= sample_cnt + 1;
            if(sample_cnt==8) begin
                rx_shift <= {rx, rx_shift[7:1]};
                bit_cnt <= bit_cnt + 1;
                if(bit_cnt==8) begin rx_done<=1; data_out<=rx_shift; rx_busy<=0; end
            end
        end else rx_done<=0;
    end
endmodule
