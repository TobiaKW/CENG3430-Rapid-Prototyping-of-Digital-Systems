library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity vga_driver is
    port (
        clk: in std_logic;
        btn: in std_logic_vector(3 downto 0);
        vsync, hsync: out std_logic;
        red, green, blue: out std_logic_vector(3 downto 0)
    );
end vga_driver;

architecture Behavioral of vga_driver is
    signal clk50MHz: std_logic; -- on-board: 100Mhz
    signal clk10Hz: std_logic; 
    signal vcount, hcount: integer := 0;
    -- row constant
    constant H_TOTAL: integer:= 1344-1;
    constant H_SYNC: integer:= 48-1;
    constant H_BACK: integer:= 240-1;
    constant H_START: integer:= 48+240-1;
    constant H_ACTIVE: integer:= 1024-1;
    constant H_END: integer:= 1344-32-1;
    constant H_FRONT: integer:= 32-1;
    -- column constant
    constant V_TOTAL: integer:= 625-1;
    constant V_SYNC: integer:= 3-1;
    constant V_BACK: integer:= 12-1;
    constant V_START: integer:= 3+12-1;
    constant V_ACTIVE: integer:= 600-1;
    constant V_END: integer:= 625-10-1;
    constant V_FRONT: integer:= 10-1;
    -- Clock divider
    component clock_divider is
        generic(N: integer);
        port (
            clkin: in std_logic;
            clkout: out std_logic
        );
    end component;
    
    -- Constants of the square
    constant LENGTH: integer := 100;
    signal H_TOP_LEFT: integer := (H_START + H_END)/2 - LENGTH/2;
    signal V_TOP_LEFT: integer := (V_START + V_END)/2 - LENGTH/2;
    

begin
    comp_clk50MHz: clock_divider generic map (N => 1) port map (clkin => clk, clkout => clk50MHz);
    comp_clk10Hz: clock_divider generic map (N => 5000000) port map (clkin => clk, clkout => clk10Hz);
    
    hcount_proc: process(clk50MHz) begin
        if rising_edge(clk50MHz) then
            if hcount = H_TOTAL then
                hcount <= 0;
            else
                hcount <= hcount + 1;
            end if;
        end if;
    end process hcount_proc;
    
    vcount_proc: process(clk50MHz) begin
        if rising_edge(clk50MHz) then
            if hcount = H_TOTAL then
                if vcount = V_TOTAL then
                    vcount <= 0;
                else
                    vcount <= vcount + 1;
                end if;
            end if;
        end if;
    end process vcount_proc;
    
    hsync_gen_proc: process(hcount) begin
        if hcount < H_SYNC then
            hsync <= '0';
        else
            hsync <= '1';
        end if;
    end process hsync_gen_proc;
    
    vsync_gen_proc: process(vcount) begin
        if vcount < V_SYNC then
            vsync <= '0';
        else
            vsync <= '1';
        end if;
    end process vsync_gen_proc;
    
    data_output_proc: process(hcount, vcount) begin
        if((hcount>=H_START and hcount < H_END) and (vcount>=V_START and vcount < V_END)) then
            if ((hcount >= H_TOP_LEFT and hcount < H_TOP_LEFT + LENGTH) 
                    and (vcount >= V_TOP_LEFT and vcount < V_TOP_LEFT + LENGTH)) then
                red <= "1111";
                green <= "0000";
                blue <= "1111";
            else
                red <= "1111";
                green <= "1111";
                blue <= "1111";
            end if;
        else
            red     <= "0000";
            green   <= "0000";
            blue    <= "0000";
        end if;
    end process data_output_proc;
    
    move: process(clk10Hz, btn) begin
        if rising_edge(clk10Hz) then
            case btn is
                when "1000" => if H_TOP_LEFT > H_START+50 then H_TOP_LEFT <= H_TOP_LEFT - 10; end if;
                when "0100" => if V_TOP_LEFT < V_END-LENGTH then V_TOP_LEFT <= V_TOP_LEFT + 10; end if;
                when "0010" => if H_TOP_LEFT < H_END then H_TOP_LEFT <= H_TOP_LEFT + 10; end if;
                when "0001" => if V_TOP_LEFT > V_START then V_TOP_LEFT <= V_TOP_LEFT - 10; end if;

                when others => Null;
            end case;
        end if;
    end process move;
    
end Behavioral;
