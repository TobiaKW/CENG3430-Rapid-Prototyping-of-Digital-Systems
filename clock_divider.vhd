library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock_divider is
    generic (N: integer);
    port(
        clkin: in std_logic;
        clkout: out std_logic
    );
end clock_divider;

architecture Behavioral of clock_divider is
    signal pulse: std_logic := '0';
    signal count: integer := 0;
begin

    process(clkin) begin
        if rising_edge(clkin) then
            if (count = N-1) then
                pulse <= NOT pulse;
                count <= 0;
            else
                count <= count + 1;
            end if;
        end if;       
    end process;
    clkout <= pulse;
end Behavioral;
