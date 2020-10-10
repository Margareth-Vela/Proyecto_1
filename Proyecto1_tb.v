module testbench();

  reg clock, reset,ON, PB1, PB2, PB3, PB4;
  reg [2:0] Ok;
  wire [1:0] Led1, LCD1;
  wire [2:0] LCD2, Led2;

  always
    begin
      clock <= 1;
      #1 clock <= ~clock;
      #1;
  end

  FSMAire FSM_FINAL(clock, reset, ON, PB1, PB2, PB3, PB4, Ok, Led1, LCD1, LCD2, Led2);

  initial begin
    $display("\n");
    $display("FSM AIRE ACONDICIONADO");
    $display("\n");
    $display(" Clk RST | ON  OK | PB1 PB2 | PB3 PB4 | Estado Velocidad Temperatura Modo");
    $display(" ------------------------------------------------------------------------- ");
    $monitor(" %b    %b  | %b  %b |  %b   %b  |  %b   %b  |   %b      %b        %b       %b", clock, reset, ON, Ok, PB1, PB2, PB3, PB4, Led1, LCD1, LCD2, Led2);
    #1 reset = 1; //Reset de las máquinas
    #2 ON=0; Ok=000; PB1=0; PB2=0; PB3=0; PB4=0; reset = 0; //Máquina Control Apagada
    #2 ON=1; Ok=000; PB1=0; PB2=0; PB3=0; PB4=0; //Máquina Control Encendida y Paso de Home a FSM Velocidad & Velocidad inicial (Low)

    #2 ON=1; Ok=000; PB1=1; PB2=0; PB3=0; PB4=0; //Subir una velocidad (Mid)
    #2 ON=1; Ok=000; PB1=0; PB2=0; PB3=0; PB4=0;
    #2 ON=1; Ok=000; PB1=1; PB2=0; PB3=0; PB4=0;//Subir una velocidad (High)
    #2 ON=1; Ok=000; PB1=0; PB2=1; PB3=0; PB4=0;//Bajar una velocidad (Mid)

    #2 ON=1; Ok[2]=0; Ok[1] = 1; Ok[0]= 0; PB1=0; PB2=0; PB3=0; PB4=0; //Paso de FSM Velocidad a FSM Temperatura con Temperatura y Modo inicial (Rango 1 & Frio)
    #2 ON=1; Ok[2]=0; Ok[1] = 1; Ok[0]= 0; PB1=0; PB2=0; PB3=1; PB4=0; //Subir una temperatura y un modo (Rango 2 & Fresco)
    #2 ON=1; Ok[2]=0; Ok[1] = 1; Ok[0]= 0; PB1=0; PB2=0; PB3=0; PB4=0;
    #2 ON=1; Ok[2]=0; Ok[1] = 1; Ok[0]= 0; PB1=0; PB2=0; PB3=1; PB4=0; //Subir una temperatura y un modo (Rango 3 & Templado)
    #2 ON=1; Ok[2]=0; Ok[1] = 1; Ok[0]= 0; PB1=0; PB2=0; PB3=0; PB4=0;
    #2 ON=1; Ok[2]=0; Ok[1] = 1; Ok[0]= 0; PB1=0; PB2=0; PB3=1; PB4=0; //Subir una temperatura y un modo (Rango 4 & Tropical)
    #2 ON=1; Ok[2]=0; Ok[1] = 1; Ok[0]= 0; PB1=0; PB2=0; PB3=0; PB4=1; //Bajar una temperatura y un modo (Rango 3 & Templado)
    #2 ON=1; Ok[2]=0; Ok[1] = 1; Ok[0]= 0; PB1=0; PB2=0; PB3=0; PB4=0;
    #2 ON=1; Ok[2]=0; Ok[1] = 1; Ok[0]= 0; PB1=0; PB2=0; PB3=0; PB4=1; //Bajar una temperatura y un modo (Rango 2 & Fresco)

    #2 ON=1; Ok[2]=1; Ok[1] = 0; Ok[0]= 0; PB1=0; PB2=0; PB3=0; PB4=0; //Regreso a Home de FSM temperatura

    #2 ON=1; Ok[2]=0; Ok[1] = 0; Ok[0]= 1; PB1=0; PB2=0; PB3=1; PB4=0; //Paso de FSM Velocidad a FSM Temperatura & Subir una temperatura y un modo (Rango 3 & Templado)

    #2 ON=1; Ok[2]=0; Ok[1] = 1; Ok[0]= 1; PB1=1; PB2=0; PB3=0; PB4=0; //Paso de FSM Temperatura a FSM Velocidad & Subir una velocidad (High)

    #2 ON=1; Ok[2]=1; Ok[1] = 0; Ok[0]= 1; PB1=0; PB2=0; PB3=0; PB4=0; //Regreso a Home de FSM Velocidad
    #2 ON=0; Ok[2]=0; Ok[1] = 0; Ok[0]= 0; PB1=0; PB2=0; PB3=0; PB4=0; //Máquina Control Apagada

    #1 $finish;
  end

  initial begin
        $dumpfile("Proyecto1_tb.vcd");
        $dumpvars(0, testbench);
      end
endmodule
