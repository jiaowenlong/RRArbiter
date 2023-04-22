`timescale 1ps/1ps

module rrb (
    input  wire           clk_i  ,
    input  wire           rst_i  ,
    input  wire [3:0]     req_i  ,
    output wire [3:0]     grant_o
);

parameter IDLE = 4'b0000;
parameter S1   = 4'b0001;
parameter S2   = 4'b0010;
parameter S3   = 4'b0100;
parameter S4   = 4'b1000;

// register
reg        current_state     = IDLE;
reg  [3:0] next_state        = IDLE;
reg  [3:0] current_priority  = 'b0;
reg  [3:0] r_grant           = 'b0;

// state machine
always @(posedge clk_i) begin
    if(rst_i)begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

always @(*) begin
    case(current_state)
    IDLE:begin
        case(1'b1)
        current_priority[3]:begin
            case(1'b1)
            req_i[0]:next_state = S1;
            req_i[1]:next_state = S2;
            req_i[2]:next_state = S3;
            req_i[3]:next_state = S4;
            default:;
            endcase
        end
        current_priority[0]:begin
            case(1'b1)
            req_i[1]:next_state = S2;
            req_i[2]:next_state = S3;
            req_i[3]:next_state = S4;
            req_i[0]:next_state = S1;
            default:;
            endcase
        end
        current_priority[1]:begin
            case(1'b1)
            req_i[2]:next_state = S3;
            req_i[3]:next_state = S4;
            req_i[0]:next_state = S1;
            req_i[1]:next_state = S2;
            default:;
            endcase
        end
        current_priority[2]:begin
            case(1'b1)
            req_i[3]:next_state = S4;
            req_i[0]:next_state = S1;
            req_i[1]:next_state = S2;
            req_i[2]:next_state = S3;
            default:;
            endcase
        end
        endcase
    end
    S1:begin
        next_state = IDLE;
    end
    S2:begin
        next_state = IDLE;
    end
    S3:begin
        next_state = IDLE;
    end
    S4:begin
        next_state = IDLE;
    end
    default:;
    endcase
end

always @(posedge clk_i) begin
    if(rst_i)begin
        current_priority <= 4'b1000;
        r_grant <= 4'b0000;
    end
    else begin
        case(next_state)
        IDLE:begin
            current_priority <= current_priority;
            r_grant <= 4'b0000;
        end
        S1:begin
            current_priority <= 4'b0001;
            r_grant <= 4'b0001;
        end
        S2:begin
            current_priority <= 4'b0010;
            r_grant <= 4'b0010;
        end
        S3:begin
            current_priority <= 4'b0100;
            r_grant <= 4'b0100;
        end
        S4:begin
            current_priority <= 4'b1000;
            r_grant <= 4'b1000;
        end
        endcase
    end
end

assign grant_o = r_grant;
    
endmodule