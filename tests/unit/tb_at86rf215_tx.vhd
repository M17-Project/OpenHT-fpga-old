library ieee;
context ieee.ieee_std_context;

library vunit_lib;
context vunit_lib.vunit_context;

use work.axi_types.all;
use work.openht_fpga_types.all;

entity tb_at86rf215_tx is
  generic (runner_cfg : string);
end entity;

architecture tb of tb_at86rf215_tx is
  constant clk_period : time    := 20 ns;

  signal clk, rst : std_logic := '0';

  signal axis_tx_mosi : axis_master_out_type;
  signal axis_tx_miso : axis_slave_out_type;
  signal lvds_out : at86rf215_tx_data_type;
begin
  clk <= not clk after clk_period/2;

  uut_inst : at86rf215_tx
  port map (
    clk => clk,
    rst => rst,
    
    axis_tx_mosi => axis_tx_mosi,
    axis_tx_miso => axis_tx_miso,

    lvds_out => lvds_out
  );

  main : process
  begin
    test_runner_setup(runner, runner_cfg);
    while test_suite loop
      if run("test") then
        rst <= '1';
        wait for 15*clk_period;
        rst <= '0';
        wait until falling_edge(clk);
        axis_tx_mosi.tdata <= "0011110000111100";
        axis_tx_mosi.tid <= "0";
        axis_tx_mosi.tvalid <= '1';
        wait for clk_period;
        axis_tx_mosi.tdata <= "0000111100001111";
        axis_tx_mosi.tid <= "1";
        axis_tx_mosi.tvalid <= '1';
        wait for clk_period;
        axis_tx_mosi.tvalid <= '0';

        wait for 100*clk_period;

        info("Test done");
      end if;
    end loop;
    test_runner_cleanup(runner); -- Simulation ends here
  end process;
end architecture;