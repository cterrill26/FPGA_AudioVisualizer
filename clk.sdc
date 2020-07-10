create_clock -name clk -period 20.000 [get_ports {clk}]
create_generated_clock -name clk_2M5 -source [get_ports {clk}] -divide_by 20 [get_pins {generate_clk_2M5|clk_out|q}]
create_generated_clock -name clk_25M -source [get_ports {clk}] -divide_by 2 [get_pins {generate_clk_25M|clk_out|q}]
create_generated_clock -name newline -source [get_pins {generate_clk_25M|clk_out|q}] -divide_by 1600 [get_pins {vga|horizontal|newline_out|q}]