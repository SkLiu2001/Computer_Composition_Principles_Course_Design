library ieee;
use ieee.std_logic_1164.all;

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
        );
end nopipe;

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
                    --Ð´¼Ä´æÆ÷
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
                    
                    --¶Á¼Ä´æÆ÷
                    when "011" =>
                    SEL(3) <= W(2);
                    SEL(2) <= '0';
                    SEL(1) <= W(2);
                    SEL(0) <= W(1) or W(2);
                    SELCTL <= W(1) or W(2);
                    STOP   <= W(1) or W(2);

                    --¶Á´æ´¢Æ÷
                    when "010" =>
                    SBUS   <= (not ST0) and W(1);
                    LAR    <= (not ST0) and W(1);
                    SST0   <= (not ST0) and W(1);

                    STOP   <= W(1);
                    SELCTL <= W(1);
                    SHORT  <= W(1);

                    MBUS   <= W(1) and ST0;
                    ARINC  <= W(1) and ST0;

                    --Ð´¼Ä´æÆ÷
                    when "001" =>
                    LAR    <= (not ST0) and W(1);
                    SST0   <= (not ST0) and W(1);--????

                    STOP   <= W(1);
                    SELCTL <= W(1);
                    SHORT  <= W(1);
                    SBUS   <= W(1);

                    MEMW   <= W(1) and ST0;
                    ARINC  <= W(1) and ST0;

                    --È¡Ö¸
                    when "000" =>
                        LIR    <=W(1);
                        PCINC  <=W(1);

                    case( IR ) is
                        --ADD
                        when "0001" =>
                        S    <= W(2) & '0' & '0' & W(2);
                        CIN  <= W(2);
                        ABUS <= W(2); 
                        DRW  <= W(2);
                        LDZ  <= W(2);
                        LDC  <= W(2);

                        --SUB
                        when "0010" =>
                        S    <= '0' & W(2) & W(2) & '0';
                        ABUS <= W(2); 
                        DRW  <= W(2);
                        LDZ  <= W(2);
                        LDC  <= W(2);

                        --AND
                        when "0011" =>
                        S    <= W(2) & '0' & W(2) & W(2);
                        ABUS <= W(2); 
                        DRW  <= W(2);
                        LDZ  <= W(2);

                        --INC
                        when "0100" =>
                        S    <= '0' & '0' & '0' & '0';
                        ABUS <= W(2); 
                        DRW  <= W(2);
                        LDZ  <= W(2);
                        LDC  <= W(2);

                        --LD
                        when "0101" =>
                        S    <= W(2) & '0' & W(2) & '0';
                        M    <= W(2);
                        ABUS <= W(2);
                        LAR  <= W(2);
                        LONG <= W(2);
                        DRW  <= W(3);
                        MBUS <= W(3);

                        --ST
                        when "0110" =>
                        S    <= ( W(2) or W(3)) &  W(2) & ( W(2) or W(3)) & W(2);
                        M    <= W(2) or W(3);
                        ABUS <= W(2) or W(3);

                        LAR  <= W(2);
                        LONG <= W(2);
                        MEMW <= W(3);

                        --JC
                        when "0111" =>
                        PCADD <=W(2) and C;

                        --JZ
                        when "1000" =>
                        PCADD <=W(2) and Z;

                        --JMP
                        when "1001" =>
                        S     <= W(2) & W(2) & W(2) & W(2);
                        M     <=W(2);
                        ABUS  <=W(2);
                        LPC   <=W(2);

                        --STP
                        when "1110" =>
                        STOP  <=W(2);

                        when others =>null;
                    
                    end case ;

                    when others =>null;
                
                end case ;

            end if;

        end process;  


    end behave;