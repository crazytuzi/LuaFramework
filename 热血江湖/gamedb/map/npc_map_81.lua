----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[40501] = {	pos = { x = 22.47743, y = 7.825636, z = -57.83819 }, mapid = 5},
	[40502] = {	pos = { x = 23.55961, y = 7.808709, z = 1.983169 }, mapid = 5},
	[40503] = {	pos = { x = 78.69164, y = 7.876124, z = -0.358757 }, mapid = 5},
	[40504] = {	pos = { x = 18.03087, y = 7.772827, z = 50.51634 }, mapid = 5},
	[40505] = {	pos = { x = 50.96014, y = 12.91782, z = 76.89115 }, mapid = 5},
	[40506] = {	pos = { x = 71.13755, y = 12.94868, z = 66.34961 }, mapid = 5},
	[40507] = {	pos = { x = -84.10194, y = 8.204862, z = 44.98323 }, mapid = 5},
	[40508] = {	pos = { x = -52.1775, y = 5.510025, z = 12.04837 }, mapid = 5},
	[40509] = {	pos = { x = -123.4874, y = 3.819515, z = 9.371618 }, mapid = 5},
	[40510] = {	pos = { x = -70.77326, y = 8.172829, z = 116.1714 }, mapid = 5},
	[40601] = {	pos = { x = 130.6055, y = 0.3791679, z = -127.8702 }, mapid = 6},
	[40602] = {	pos = { x = 51.65543, y = 0.5450321, z = -99.29868 }, mapid = 6},
	[40603] = {	pos = { x = -138.5002, y = 4.271502, z = -99.13489 }, mapid = 6},
	[40606] = {	pos = { x = -103.6702, y = 17.44429, z = 115.9969 }, mapid = 6},
	[40607] = {	pos = { x = -40.45906, y = 17.26384, z = 132.201 }, mapid = 6},
	[40609] = {	pos = { x = 84.95123, y = 4.663842, z = 77.61077 }, mapid = 6},
	[40610] = {	pos = { x = 120.0681, y = 0.1638422, z = -42.54466 }, mapid = 6},
	[40903] = {	pos = { x = 54.58744, y = 11.9298, z = 29.5483 }, mapid = 9},
	[40701] = {	pos = { x = -40.055, y = 6.193672, z = -66.59292 }, mapid = 7},
	[40702] = {	pos = { x = 15.19396, y = 11.4152, z = -78.36868 }, mapid = 7},
	[40703] = {	pos = { x = 83.40112, y = 12.56663, z = 1.134706 }, mapid = 7},
	[40704] = {	pos = { x = 57.52812, y = 20.85855, z = 52.59188 }, mapid = 7},
	[40705] = {	pos = { x = 33.78417, y = 21.30875, z = 112.7508 }, mapid = 7},
	[40706] = {	pos = { x = 33.46773, y = 13.527, z = 70.27245 }, mapid = 7},
	[40707] = {	pos = { x = -35.36388, y = 13.35855, z = 1.500702 }, mapid = 7},
	[40708] = {	pos = { x = -18.57463, y = 13.35855, z = -16.56503 }, mapid = 7},
	[40709] = {	pos = { x = 34.8853, y = 12.35855, z = 13.67593 }, mapid = 7},
	[40710] = {	pos = { x = 63.03272, y = 2.358551, z = -54.25175 }, mapid = 7},
	[40801] = {	pos = { x = 71.29425, y = 17.18022, z = 36.34903 }, mapid = 8},
	[40802] = {	pos = { x = 120.1571, y = 7.591468, z = 46.96095 }, mapid = 8},
	[40803] = {	pos = { x = 140.4115, y = 7.434466, z = 76.76018 }, mapid = 8},
	[40804] = {	pos = { x = 176.6238, y = 7.492535, z = 5.38166 }, mapid = 8},
	[40805] = {	pos = { x = 118.0772, y = 7.434466, z = -42.17858 }, mapid = 8},
	[40806] = {	pos = { x = 136.5339, y = 7.434466, z = -82.42696 }, mapid = 8},
	[40807] = {	pos = { x = 4.480118, y = 17.27732, z = -13.72618 }, mapid = 8},
	[40808] = {	pos = { x = -36.70297, y = 25.17299, z = 65.44557 }, mapid = 8},
	[40809] = {	pos = { x = -70.06796, y = 24.63447, z = 22.53465 }, mapid = 8},
	[40810] = {	pos = { x = 32.78794, y = 16.72144, z = -111.6697 }, mapid = 8},
	[40604] = {	pos = { x = -83.2963, y = 7.063842, z = -135.1037 }, mapid = 6},
	[40605] = {	pos = { x = -99.11665, y = 3.163843, z = 10.97994 }, mapid = 6},
	[40608] = {	pos = { x = -7.345028, y = 0.5408002, z = 35.33871 }, mapid = 6},
	[40901] = {	pos = { x = -15.39092, y = 12.2333, z = 36.26359 }, mapid = 9},
	[40902] = {	pos = { x = 23.57499, y = 12.22172, z = 28.88023 }, mapid = 9},
	[40904] = {	pos = { x = 49.78326, y = 11.23152, z = -20.0436 }, mapid = 9},
	[40905] = {	pos = { x = 59.40118, y = 8.37036, z = -91.04483 }, mapid = 9},
	[40906] = {	pos = { x = 25.93763, y = 9.026529, z = -106.9205 }, mapid = 9},
	[40907] = {	pos = { x = -32.70127, y = 7.222049, z = -89.97247 }, mapid = 9},
	[40908] = {	pos = { x = -101.5685, y = 7.727967, z = -99.89727 }, mapid = 9},
	[40909] = {	pos = { x = -93.12012, y = 8.026529, z = -28.94592 }, mapid = 9},
	[40910] = {	pos = { x = 3.024654, y = 8.203967, z = -25.9689 }, mapid = 9},

};
function get_db_table()
	return map;
end
