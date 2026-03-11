library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lab06 is
  Port (
    -- TODO-1: Fill in the input/output ports for Pmod SSD and switches
    clk: in std_logic;
    switch: in std_logic_vector(7 downto 0);
    sel:  buffer std_logic := '0';
    ssd: out std_logic_vector(6 downto 0);
    -- TODO-10: Fill in the input/output ports for Pmod ALS
    cs: buffer std_logic_vector(0 downto 0);
    miso: in std_logic;
    sclk: buffer std_logic
  );
end lab06;

architecture Behavioral of lab06 is

-- TODO-7: create the component of ssd_ctrl
component ssd_ctrl is
  Port (
    clk: in std_logic;
    switch: in std_logic_vector(7 downto 0);
    sel:  buffer std_logic := '0';
    ssd: out std_logic_vector(6 downto 0)
  );
end component;

--  TODO-11: Uncomment the component
component spi_master
  generic(
    slaves  : INTEGER;  --number of spi slaves
    d_width : INTEGER); --data bus width
  port(
    clock   : IN     STD_LOGIC;                             --system clock
    reset_n : IN     STD_LOGIC;                             --asynchronous reset
    enable  : IN     STD_LOGIC;                             --initiate transaction
    cpol    : IN     STD_LOGIC;                             --spi clock polarity
    cpha    : IN     STD_LOGIC;                             --spi clock phase
    cont    : IN     STD_LOGIC;                             --continuous mode command
    clk_div : IN     INTEGER;                               --system clock cycles per 1/2 period of sclk
    addr    : IN     INTEGER;                               --address of slave
    tx_data : IN     STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --data to transmit
    miso    : IN     STD_LOGIC;                             --master in, slave out
    sclk    : BUFFER STD_LOGIC;                             --spi clock
    ss_n    : BUFFER STD_LOGIC_VECTOR(slaves-1 DOWNTO 0);   --slave select
    mosi    : OUT    STD_LOGIC;                             --master out, slave in
    busy    : OUT    STD_LOGIC;                             --busy / data ready signal
    rx_data : OUT    STD_LOGIC_VECTOR(d_width-1 DOWNTO 0) --data received
    );
end component;

-- TODO-13: Create a signal for rx_data
signal rx_data : std_logic_vector(14 downto 0);

begin

-- TODO-8: Port map the ssd_ctrl
   ssdctrl: ssd_ctrl port map(clk=>clk, switch=>rx_data(11 downto 4), sel=>sel, ssd=>ssd);
   
-- TODO-14: Send the rx_data from spi_master to ssd_ct 


--  TODO-12: Uncomment the component
    spi_master_0: spi_master
    generic map(    
        slaves => 1,
        d_width => 15
    )
    port map(
        clock => clk,
        clk_div => 5,
        sclk => sclk,
        miso => miso,
        ss_n => cs,
        mosi => open,
        reset_n => '1',
        addr => 0,
        cpol => '1',
        cpha => '1',
        tx_data => (others => '0'),
        rx_data => rx_data,
        enable => '1',
        busy => open,
        cont => '0'
    );

end Behavioral;