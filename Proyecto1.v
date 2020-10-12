//Flip flop tipo D de 1 bit
module FlipFlopD(input wire clock, reset, input wire D, output reg Y);
  always @ (posedge clock, posedge reset) begin
      if (reset) begin
        Y <= 1'b0;
      end
      else begin
        Y <= D;
      end
    end
endmodule
//Buffer de 2 bits
module buffer_1(input wire enable, input wire [1:0]A, output wire [1:0] Y);
  assign Y = (enable)? A : 2'b0;
endmodule

//Buffer de 3 bits
module buffer_2(input wire enable, input wire [2:0]A, output wire [2:0] Y);
  assign Y = (enable)? A : 3'b0;
endmodule

//FSM Antirebote
module antirebote(input wire clock, reset, PB, output wire Y);
  wire S0F, S0;
  FlipFlopD G1(clock, reset, S0F, S0);
  assign S0F = PB;
  assign Y = ~S0 & PB;
endmodule

//FSM Velocidad
module FSMVel(input wire clock, reset, PB1, PB2, output wire [1:0] Vel);
  wire S1F, S0F; //Siguiente estado
  wire S1, S0; //Estado actual

  FlipFlopD G1(clock, reset, S1F, S1);
  FlipFlopD G2(clock, reset, S0F, S0);

  //Siguiente estado
  assign S1F = (S1 & ~PB2) | (S0 & PB1);
  assign S0F = (~S0 & PB2) | (S0 & ~PB1 & ~PB2) | (~S0 & PB1);

  //Salidas
  assign Vel[1] = S1 | S0;
  assign Vel[0] = ~S0;
endmodule

//FSM Temperatura y modo
module FSMTem(input wire clock, reset, PB3, PB4, output wire [2:0] T, M);
  wire S1F, S0F; //Siguiente estado
  wire S1, S0;  //Estado actual

  FlipFlopD G1(clock, reset, S1F, S1);
  FlipFlopD G2(clock, reset, S0F, S0);

  //Siguiente estado
  assign S1F = (S1 & S0) | (S0 & PB3) | (S1 & ~PB4);
  assign S0F = (~S0 & PB4) | (~S0 & PB3) | (S0 & ~PB3 & ~PB4);

  //Salidas
  assign T[2] = S1 & S0;
  assign T[1] = (~S1 & S0) | (S1 & ~S0);
  assign T[0] = ~S0;
  assign M[2] = ~S1 | ~S0;
  assign M[1] = (S1 & S0) | (~S1 & ~S0);
  assign M[0] = S0;
endmodule

//FSM Control
module FSMControl(input wire clock, reset, ON, input wire [1:0] Vel, input wire [2:0] Ok, T, M, output wire [1:0] Y);
  wire S1F, S0F; //Siguiente estado
  wire S1, S0;  //Estado actual

  FlipFlopD G1(clock, reset, S1F, S1);
  FlipFlopD G2(clock, reset, S0F, S0);

  //Siguiente estado
  assign S1F=((S0&ON&~Ok[2]&~Ok[1])|(S1&ON&~Ok[2]&~Ok[1])|(S1&S0&ON&Ok[2]&Ok[0])|(S1&~S0&ON&Ok[1]&Ok[0])|(S1&~S0&ON&Ok[2]&~Ok[0])|(S1&S0&ON&Ok[1]&~Ok[0])|(S1&ON&Ok[1]&~Ok[0]&Vel[1])|(S1&ON&Ok[1]&~Ok[0]&Vel[0])|(S1&ON&Ok[1] & Ok[0] & T[2] & ~T[1] & ~T[0] & ~M[2] & M[1] & M[0]) | (S1 & ON & Ok[1] & Ok[0] & ~T[2] & T[1] & ~T[0] & M[2] & ~M[1] & M[0]) | (S1 & ON & Ok[1] & Ok[0] & ~T[2] & ~T[1] & T[0] & M[2] & M[1] & ~M[0]) | (S1 & ON & Ok[1] & Ok[0] & ~T[2] & T[1] & T[0] & M[2] & ~M[1] & ~M[0]));
  assign S0F = (~S1 & ~S0 & ON) | (S0 & ON & Ok[2]) | (ON & Ok[2] & ~Ok[1] & Ok[0]) | (ON & ~Ok[2] & Ok[1] & ~Ok[0] & Vel[1]) | (ON & ~Ok[2] & Ok[1] & ~Ok[0] & Vel[0]) | (~S1 & ON & Ok[1]) | (S0 & ON & ~Ok[1] & Ok[0]) | (S1 & S0 & ON & ~Ok[0]);

  //Salidas
  assign Y[1] = S1;
  assign Y[0] = S0;
endmodule

//FSM Aire acondicionado
module FSMAire(input wire clock, reset, ON, PB1, PB2, PB3, PB4, input wire [2:0] Ok, output wire [1:0] Led1, LCD1, output wire [2:0] LCD2, Led2);
  wire PB_1, PB_2, PB_3, PB_4; //Salidas antirebote
  wire A, B, C, D; //Salidas de la FSM Control
  wire [1:0] Vel, Y; //Salidas FSM Velocidad y Control
  wire [2:0] T, M; //Salidas FSM Temperatura y Modo

  antirebote FSM_ANTIREBOTE1(clock, reset, PB1, PB_1);
  antirebote FSM_ANTIREBOTE2(clock, reset, PB2, PB_2);
  antirebote FSM_ANTIREBOTE3(clock, reset, PB3, PB_3);
  antirebote FSM_ANTIREBOTE4(clock, reset, PB4, PB_4);
  FSMVel FSM_VELOCIDAD(clock, reset, PB_1, PB_2, Vel);
  FSMTem FSM_TM(clock, reset, PB_3, PB_4, T, M);
  FSMControl FSM_CONTROL(clock, reset, ON, Vel, Ok, T, M, Y);

  assign A = ~Y[1] & Y[0];
  assign B = Y[1] & ~Y[0];
  assign C = Y[1] & Y[0];
  assign D = A | B | C;

  buffer_1 Buffer1(D, Vel, LCD1);
  buffer_2 Buffer2(D, T, LCD2);
  buffer_2 Buffer3(D, M, Led2);

  assign Led1 = Y;
endmodule
