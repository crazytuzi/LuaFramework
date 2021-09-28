----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[64071] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 32007},
	[64072] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 32007},
	[64071] = {pos = { x = 1.827212, y = -11.22577, z = -4.592784 }, mapid = 32007},
	[64161] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 32016},
	[64162] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 32016},
	[64061] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 32006},
	[64062] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 32006},
	[64081] = {pos = { x = -7.494146, y = 6.364571, z = -12.08766 }, mapid = 32008},
	[64011] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 32001},
	[64012] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 32001},
	[64021] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 32002},
	[64022] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 32002},
	[64031] = {pos = { x = -7.494146, y = 6.364571, z = -12.08766 }, mapid = 32003},
	[64032] = {pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, mapid = 32003},
	[64041] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 32004},
	[64042] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 32004},
	[64051] = {pos = { x = -22.12462, y = 8.989296, z = 50.56207 }, mapid = 32005},
	[64082] = {pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, mapid = 32008},
	[64091] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 32009},
	[64092] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 32009},
	[64101] = {pos = { x = -22.12462, y = 8.989296, z = 50.56207 }, mapid = 32010},
	[64111] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 32011},
	[64112] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 32011},
	[64121] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 32012},
	[64122] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 32012},
	[64131] = {pos = { x = -7.494146, y = 6.364571, z = -12.08766 }, mapid = 32013},
	[64132] = {pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, mapid = 32013},
	[64141] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 32014},
	[64142] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 32014},
	[64151] = {pos = { x = -22.12462, y = 8.989296, z = 50.56207 }, mapid = 32015},
	[64171] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 32017},
	[64172] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 32017},
	[64181] = {pos = { x = -7.494146, y = 6.364571, z = -12.08766 }, mapid = 32018},
	[64182] = {pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, mapid = 32018},
	[64191] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 32019},
	[64192] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 32019},

};
function get_db_table()
	return map;
end
