----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[62171] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30017},
	[62172] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30017},
	[62171] = {pos = { x = 1.827212, y = -11.22577, z = -4.592784 }, mapid = 30017},
	[62021] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30002},
	[62022] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30002},
	[62031] = {pos = { x = -7.494146, y = 6.364571, z = -12.08766 }, mapid = 30003},
	[62032] = {pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, mapid = 30003},
	[62051] = {pos = { x = -22.12462, y = 8.989296, z = 50.56207 }, mapid = 30005},
	[62061] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30006},
	[62062] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30006},
	[62081] = {pos = { x = -7.494146, y = 6.364571, z = -12.08766 }, mapid = 30008},
	[62082] = {pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, mapid = 30008},
	[62091] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30009},
	[62092] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30009},
	[62111] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30011},
	[62112] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30011},
	[62121] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30012},
	[62122] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30012},
	[62071] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30007},
	[62072] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30007},
	[62131] = {pos = { x = -7.494146, y = 6.364571, z = -12.08766 }, mapid = 30013},
	[62132] = {pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, mapid = 30013},
	[62151] = {pos = { x = -22.12462, y = 8.989296, z = 50.56207 }, mapid = 30015},
	[62161] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30016},
	[62162] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30016},
	[62181] = {pos = { x = -7.494146, y = 6.364571, z = -12.08766 }, mapid = 30018},
	[62182] = {pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, mapid = 30018},
	[62191] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30019},
	[62192] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30019},
	[62011] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30001},
	[62012] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30001},
	[62101] = {pos = { x = -22.12462, y = 8.989296, z = 50.56207 }, mapid = 30010},
	[62141] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30014},
	[62142] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30014},
	[62041] = {pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, mapid = 30004},
	[62042] = {pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, mapid = 30004},

};
function get_db_table()
	return map;
end
