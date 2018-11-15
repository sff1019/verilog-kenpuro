// Draw a square in the middle and never move it

module m_aim (
	input wire clk
)

	localparam REC_WIDTH = 80;
	localparam REC_HEIGHT = 60;
	wire [11:0] w_draw_pos_x, w_draw_pos_y;

	draw_entity
