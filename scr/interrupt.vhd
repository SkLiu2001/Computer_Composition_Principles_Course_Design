library ieee;
use ieee.std_logic_1164.all;

entity nopipe is
    port(
        CLR,CLK,C,Z: in std_logic;
        PULSE      : in std_logic;
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
        signal INT, EN_INT, INTDI, INTEN: std_logic;
        signal ST0, SST0, ST1, SST1     : std_logic;        
    begin
      
        process(CLR,CLK,PULSE,SW,IR,W(1),W(2),W(3),ST0,SST0,ST1,SST1,INT, EN_INT, INTDI, INTEN)
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
            S       <= "0000";
            SEL     <= "0000";

            SST0    <= '0';
            SST1    <= '0';
            
            if (CLR = '0') then
                ST0    <= '0';
                --ST1    <= '0';
                EN_INT <= '1';
                --INT    <= '0';
                INTDI  <= '0';
                INTEN  <= '0';
                --MBUS  <= '0';
            else
                if (INTDI = '1') then
                    EN_INT <= '0';
                    --INT    <= '0';
                end if;

                if (INTEN = '1') then
                    EN_INT <= '1';
                    --INT    <= '1';
                end if;
            
                --if (PULSE = '1') then
                    --INT <= EN_INT;                   
                --end if;

                if (CLK'event and CLK = '0') then
                    if SST0 = '1' then
                                                ST0 <= '1';
                    end if;
                    --if SST1 = '1' then
                        --ST1 <= '0';
                    --end if;
                end if;
                                 
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
                    when "000" =>

                        if ST1 = '1' then   --关中断 && 指定中断程序地址
                            INTDI <= W(1);
                            STOP  <= W(1);

                            SBUS  <= W(2);
                            LPC   <= W(2);
                            SST1  <= W(2);
                        else 
                            if ST0 = '0' then   --指定PC指针 && PC == R3
                                SEL    <= W(1) & W(1) & '0' & '0';
                                SELCTL <= W(1);
                                SBUS   <= W(1);
                                LPC    <= W(1);
                                DRW    <= W(1);
                                SST0   <= W(1);
                                STOP   <= W(1);                               
                                SHORT  <= W(1);
                            else
                                if EN_INT = '1' then    --未进入中断(同步PC与R3)
                                    SEL    <= W(1) & W(1) & '0' & '0';
                                    SELCTL <= W(1);
                                    S           <= "0000";
                                    ABUS   <= W(1);
                                    DRW    <= W(1);
                                end if;
                                
                                LIR   <= W(1);
                                PCINC <= W(1);
                                
                                if (W(2) = '1' or W(3) = '1') then
                                                                        case( IR ) is
                                                                                --ADD
                                                                                when "0001" =>
                                                                                        S    <= W(2) & '0' & '0' & W(2);
                                                                                        CIN  <= W(2);
                                                                                        ABUS <= W(2); 
                                                                                        DRW  <= W(2);
                                                                                        LDZ  <= W(2);
                                                                                        LDC  <= W(2);
                                                                                        --ST1  <= W(2) and INT;
                                
                                                                                --SUB
                                                                                when "0010" =>
                                                                                        S    <= '0' & W(2) & W(2) & '0';
                                                                                        ABUS <= W(2); 
                                                                                        DRW  <= W(2);
                                                                                        LDZ  <= W(2);
                                                                                        LDC  <= W(2);
                                                                                        --ST1  <= W(2) and INT;
                                
                                                                                --AND
                                                                                when "0011" =>
                                                                                        S    <= W(2) & '0' & W(2) & W(2);
                                                                                        ABUS <= W(2); 
                                                                                        DRW  <= W(2);
                                                                                        LDZ  <= W(2);
                                                                                        --ST1  <= W(2) and INT;
                                                                                
                                                                                --INC
                                                                                when "0100" =>
                                                                                        S    <= '0' & '0' & '0' & '0';
                                                                                        ABUS <= W(2); 
                                                                                        DRW  <= W(2);
                                                                                        LDZ  <= W(2);
                                                                                        LDC  <= W(2);
                                                                                        --ST1  <= W(2) and INT;
                                
                                                                                --LD
                                                                                when "0101" =>
                                                                                        S    <= W(2) & '0' & W(2) & '0';
                                                                                        M    <= W(2);
                                                                                        ABUS <= W(2);
                                                                                        LAR  <= W(2);
                                                                                        LONG <= W(2);
                                                                                        DRW  <= W(3);
                                                                                        MBUS <= W(3);
                                                                                        --ST1  <= W(3) and INT;
                                
                                                                                --ST
                                                                                when "0110" =>
                                                                                        S    <= ( W(2) or W(3)) &  W(2) & ( W(2) or W(3)) & W(2);
                                                                                        M    <= W(2) or W(3);
                                                                                        ABUS <= W(2) or W(3);
                                        
                                                                                        LAR  <= W(2);
                                                                                        LONG <= W(2);
                                                                                        MEMW <= W(3);
                                                                                        --ST1  <= W(3) and INT;
                                
                                                                                --JMP
                                                                                when "1001" =>
                                                                                        S     <= W(2) & '0' & W(2) & '0';
                                                                                        M     <= W(2);
                                                                                        ABUS  <= W(2);
                                                                                        LPC   <= W(2);

                                                                                        if (EN_INT = '1') then  --未进入中断
                                                                                                DRW  <= W(2);
                                                                                                --ST1  <= W(2) and INT;
                                                                                        end if;
                           
                                                                                --STP
                                                                                when "1110" =>
                                                                                        STOP  <= W(2);
                                                                                        
                                                                                --OUT
                                                                                --when "1010" =>
                                                                                        --S <= W(2) & '0' & W(2) & '0';
                                                                                        --M <= W(2);
                                                                                        --ABUS <= W(2);

                                                                                --IRET
                                                                                when "1111" =>
                                                                                        
                                                                                        INTEN <= W(2);
                                                                                        LONG  <= W(2);
                                                                                        STOP  <= W(2);
                                                                                        S      <= W(3) & '0' & W(3) & '0';
                                                                                        SEL    <= '0' & '0' & W(3) & W(3);
                                                                                        M                <= W(3);
                                                                                        SELCTL <= W(3);
                                                                                        ABUS   <= W(3);
                                                                                        LPC    <= W(3);
                                                                                        --ST1    <= W(3) and INT;
                                                                
                                                                                when others =>null;     

                                                                        end case ;
                                                                end if;
                                                                
                                

                            end if;  

                        end if;
                        
                    when others =>null;
                
                end case ;

            end if;

        end process;  
        
        process(CLK, CLR, W(1),W(2),W(3), IR, SW, INT)
                begin
                        if (CLR = '0') then
                                ST1 <= '0';
                        elsif (CLK'event and CLK = '0') then
                                if (SST1 = '1') then
                                        ST1 <= '0';
                                end if;                        
                                if (SW = "000" and ST1 = '0') then
                                        case( IR ) is
                                                --ADD
                                                when "0001" =>
                                                        ST1  <= W(2) and INT;

                                                --SUB
                                                when "0010" =>
                                                        ST1  <= W(2) and INT;

                                                --AND
                                                when "0011" =>
                                                        ST1  <= W(2) and INT;
                                                
                                                --INC
                                                when "0100" =>
                                                        
                                                        ST1  <= W(2) and INT;
                                                        --LONG <= W(2) and ST1;

                                                --LD
                                                when "0101" =>
                                                        
                                                        ST1  <= W(3) and INT;

                                                --ST
                                                when "0110" =>
                                                        
                                                        ST1  <= W(3) and INT;

                                                --JMP
                                                when "1001" =>

                                                        ST1  <= W(2) and INT and EN_INT;

                                                --IRET
                                                when "1111" =>
                                                        ST1  <= W(3) and INT;
                                
                                                when others =>null;
                                        
                                        end case;
                                end if;        
                        end if;                                
                end process;
                
                process (CLR, EN_INT, PULSE)
                                begin
                        if (CLR = '0') then
                                                        INT <= '0';                      
                        end if;
                        
                        if (PULSE = '1') then
                                                        INT <= EN_INT;
                        end if;
                        
                        if (EN_INT = '0') then
                                                        INT <= EN_INT;
                                                end if;
           
                                end process;
        
    end behave;