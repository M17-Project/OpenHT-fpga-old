library ieee;
context ieee.ieee_std_context;

library vunit_lib;
context vunit_lib.vunit_context;

use work.openht_fpga_types.all;

entity tb_at86rf215_tx is
  generic (runner_cfg : string);
end entity;

architecture tb of tb_at86rf215_tx is
  constant clk_period : time    := 20 ns;

  signal clk, rst : std_logic := '0';

  signal uut_ctrl : at86rf215_tx_ctrl_type;
  signal uut_data : at86rf215_tx_data_type;
begin
  clk <= not clk after clk_period/2;

  uut_inst : at86rf215_tx
  port map (
    clk => clk,
    rst => rst,
    
    din   => uut_ctrl,
    dout  => uut_data
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
        uut_ctrl.i_data <= "11110000111100";
        uut_ctrl.q_data <= "00111100001111";
        uut_ctrl.valid <= '1';
        wait for clk_period;
        uut_ctrl.valid <= '0';

        wait for 100*clk_period;

        info("Test done");
      end if;
    end loop;
    test_runner_cleanup(runner); -- Simulation ends here
  end process;
end architecture;