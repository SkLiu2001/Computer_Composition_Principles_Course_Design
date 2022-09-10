library ieee;use ieee.std_logic_1164.all;
entity nopipe is
    port(
        CLR,CLK,C,Z: in std_logic;
        SW         : in std_logic_vector(2 downto 0);
        IR         : in std_logic_vector(7 downto 4);
        W          : in std_logic_vector(3 downto 1);
        DRW,PCINC,LPC,LAR,PCADD,ARINC,SELCTL,MEMW,STOP,
        LIR,LDZ,LDC,CIN,M,ABUS,SBUS,MBUS,
        SHORT,LONG : out std_logic;
        S,SEL      : out std_logic_vector(3 downto 0)
        );end nopipe;
architecture behave of nopipe is
        signal ST0,SST0: std_logic;
    begin
 
        process(CLR,CLK,C,Z,SW,IR,W(1),W(2),W(3),ST0,SST0)
        begin
            DRW     <= '0';
            PCINC   <= '0';
            LPC     <= '0';
            LAR     <= '0';
            PCADD   <= '0';
            ARINC   <= '0';
            SELCTL  <= '0';
            MEMW    <= '0';
            STOP    <= '0';
            LIR     <= '0';
            LDZ     <= '0';
            LDC     <= '0';
            CIN     <= '0';
            M       <= '0';
            ABUS    <= '0';
            SBUS    <= '0';
            MBUS    <= '0';
            SHORT   <= '0';
            LONG    <= '0';
            SST0    <= '0';
            S       <= "0000";
            SEL     <= "0000";
 
            if (CLR = '0') then
                ST0 <= '0';
            else
                if ((CLK'event and CLK = '0') and SST0 = '1') then
                    ST0 <= '1';
                end if ;
 
                case( SW ) is
                    --写寄存器
                    when "100" =>
                    SBUS   <= W(1) or W(2);
                    SEL(3) <= (ST0 and  W(1)) or (ST0 and  W(2));
                    SEL(2) <= W(2);
                    SEL(1) <= (not ST0 and W(1)) or (ST0 and W(2));
                    SEL(0) <= W(1);
                    SELCTL <= W(1) or W(2);
                    DRW    <= W(1) or W(2);
                    STOP   <= W(1) or W(2); 
                    SST0   <= W(2);
 
                    --读寄存器
                    when "011" =>
                    SEL(3) <= W(2);
                    SEL(2) <= '0';
                    SEL(1) <= W(2);
                    SEL(0) <= W(1) or W(2);
                    SELCTL <= W(1) or W(2);
                    STOP   <= W(1) or W(2);
 
                    --读存储器
                    when "010" =>
                    SBUS   <= (not ST0) and W(1);
                    LAR    <= (not ST0) and W(1);
                    SST0   <= (not ST0) and W(1);
 
                    STOP   <= W(1);
                    SELCTL <= W(1);
                    SHORT  <= W(1);
 
                    MBUS   <= W(1) and ST0;
                    ARINC  <= W(1) and ST0;
 
                    --写寄存器
                    when "001" =>
                    LAR    <= (not ST0) and W(1);
                    SST0   <= (not ST0) and W(1);--????
 
                    STOP   <= W(1);
                    SELCTL <= W(1);
                    SHORT  <= W(1);
                    SBUS   <= W(1);
 
                    MEMW   <= W(1) and ST0;
                    ARINC  <= W(1) and ST0;
 
                    --取指
                    when "000" =>   --取指
                        if ST0 = '0' then
                            LPC   <= W(1);
                            SBUS  <= W(1);
                            SHORT <= W(1);
                            STOP  <= W(1);
                            SST0  <= W(1);
                        else 
                            case IR is
                                when "0001" =>  --ADD
                                    S <= "1001";
                                    CIN <= W(1);
                                    ABUS <= W(1);
                                    DRW <= W(1);
                                    LDZ <= W(1);
                                    LDC <= W(1);
 
                                    LIR <= W(1);
                                    PCINC <= W(1);
                                    SHORT <= w(1);
                                when "0010" =>  --SUB
                                    S <= "0110";
                                    ABUS <= W(1);
                                    DRW <= W(1);
                                    LDZ <= W(1);
                                    LDC <= W(1);
 
                                    LIR <= W(1);
                                    PCINC <= W(1);
                                    SHORT <= w(1);
                                when "0011" =>  --AND
                                    M <= W(1);
                                    S <= "1011";
                                    ABUS <= W(1);
                                    DRW <= W(1);
                                    LDZ <= W(1);
 
                                    LIR <= W(1);
                                    PCINC <= W(1);
                                    SHORT <= w(1);
                                when "0100" =>  --INC
                                    S <= "0000";
                                    ABUS <= W(1);
                                    DRW <= W(1);
                                    LDZ <= W(1);
                                    LDC <= W(1);
 
                                    LIR <= W(1);
                                    PCINC <= W(1);
                                    SHORT <= w(1);           
                                when "0101" =>  --LD
                                    M <= W(1);
                                    S <= W(1) & '0' & W(1) & '0';
                                    ABUS <= W(1);
                                    LAR <= W(1);
                                    MBUS <= W(2);
                                    DRW <= W(2);
 
                                    LIR <= W(2);
                                    PCINC <= W(2);
                                when "0110" =>  --ST
                                    M <= W(1) or W(2);
                                    S <= '1' & W(1) & '1' & W(1);
                                    ABUS <= W(1) or W(2);
                                    LAR <= W(1);
                                    MEMW <= W(2);
 
                                    LIR <= W(2);
                                    PCINC <= W(2);
                                when "0111" =>  --JC
                                    PCADD <= C and W(1);
 
                                    LIR <=  (W(1) and (not C)) or (W(2) and C);
                                    PCINC <= (W(1) and (not C)) or (W(2) and C);
                                    SHORT <= W(1) and (not C);
                                when "1000" =>  --JZ
                                    PCADD <= Z and W(1);
 
                                    LIR <=  (W(1) and (not Z)) or (W(2) and Z);
                                    PCINC <= (W(1) and (not Z)) or (W(2) and Z);
                                    SHORT <= W(1) and (not Z);
                                when "1001" =>  --JMP
                                    M <= W(1);
                                    S <= "1111";
                                    ABUS <= W(1);
                                    LPC <= W(1);
 
                                    LIR <= W(2);
                                    PCINC <= W(2);
                                when "1110" =>  --STP
                                    STOP <= W(1);
 
                                when "1010" =>  --OUT
                                    S    <= W(1) & '0' & W(1) & '0';
                                    M    <= W(1);
                                    ABUS <= W(1);
 
                                    LIR <= W(1);
                                    PCINC <= W(1);
                                    SHORT <= w(1);
                                when "1011" =>  --OR
                                    S    <= W(1) & W(1) & W(1) & '0';
                                    M    <= W(1);
                                    ABUS <= W(1);
                                    DRW  <= W(1);
                                    LDZ  <= W(1);
 
                                    LIR <= W(1);
                                    PCINC <= W(1);
                                    SHORT <= w(1);               
                                when "1100" =>  --MOVE
                                    S    <= W(1) & '0' & W(1) & '0';
                                    M  <= W(1);
                                    ABUS <= W(1);
                                    DRW  <= W(1);
 
                                    LIR <= W(1);
                                    PCINC <= W(1);
                                    SHORT <= w(1);
                                when others =>
                                    LIR <= W(1);
                                    PCINC <= W(1);
                                    SHORT <= W(1);
                            end case;
                        end if;
 
                    when others =>null;
 
                end case ;
 
            end if;
 
        end process;  
 
    end behave;
