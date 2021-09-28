----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[62391] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30039},
	[62392] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30039},
	[62391] = {pos = { x = 1.827212, y = -11.22577, z = -4.592784 }, mapid = 30039},
	[62201] = {pos = { x = -22.12462, y = 8.989296, z = 50.56207 }, mapid = 30020},
	[62211] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30021},
	[62212] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30021},
	[62221] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30022},
	[62222] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30022},
	[62231] = {pos = { x = -7.494146, y = 6.364571, z = -12.08766 }, mapid = 30023},
	[62232] = {pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, mapid = 30023},
	[62251] = {pos = { x = -22.12462, y = 8.989296, z = 50.56207 }, mapid = 30025},
	[62261] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30026},
	[62262] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30026},
	[62271] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30027},
	[62272] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30027},
	[62281] = {pos = { x = -7.494146, y = 6.364571, z = -12.08766 }, mapid = 30028},
	[62282] = {pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, mapid = 30028},
	[62301] = {pos = { x = -22.12462, y = 8.989296, z = 50.56207 }, mapid = 30030},
	[62311] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30031},
	[62312] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30031},
	[62321] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30032},
	[62322] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30032},
	[62332] = {pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, mapid = 30033},
	[62331] = {pos = { x = 12.10232, y = 6.364571, z = -6.277208 }, mapid = 30033},
	[62351] = {pos = { x = -22.12462, y = 8.989296, z = 50.56207 }, mapid = 30035},
	[62361] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30036},
	[62362] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30036},
	[62381] = {pos = { x = -7.494146, y = 6.364571, z = -12.08766 }, mapid = 30038},
	[62382] = {pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, mapid = 30038},
	[62241] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30024},
	[62242] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30024},
	[62371] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30037},
	[62372] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30037},
	[62291] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30029},
	[62292] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30029},
	[62341] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30034},
	[62342] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30034},

};
function get_db_table()
	return map;
end
