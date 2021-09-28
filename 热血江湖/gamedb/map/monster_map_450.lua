----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[90104] = {pos = { x = 64.57233, y = 1.951529, z = -12.07419 }, mapid = 21},
	[90104] = {pos = { x = 69.11394, y = 1.951529, z = -13.9164 }, mapid = 21},
	[90102] = {pos = { x = 78.79801, y = 2.387988, z = 37.38511 }, mapid = 21},
	[90107] = {pos = { x = 68.55881, y = 2.351528, z = 50.42653 }, mapid = 21},
	[90105] = {pos = { x = 66.9882, y = 2.351528, z = 54.69167 }, mapid = 21},
	[90108] = {pos = { x = 65.09478, y = 2.603404, z = 98.5825 }, mapid = 21},
	[90103] = {pos = { x = 64.02808, y = 2.552774, z = 104.6306 }, mapid = 21},
	[90111] = {pos = { x = 63.92387, y = 1.95153, z = -12.18401 }, mapid = 22},
	[90113] = {pos = { x = 68.46693, y = 1.951529, z = -2.803144 }, mapid = 22},
	[90112] = {pos = { x = 76.38017, y = 2.394592, z = 41.86772 }, mapid = 22},
	[90115] = {pos = { x = 66.86937, y = 2.351528, z = 51.97364 }, mapid = 22},
	[90114] = {pos = { x = 66.79874, y = 2.351528, z = 47.77135 }, mapid = 22},
	[90116] = {pos = { x = 65.37045, y = 2.617527, z = 99.12891 }, mapid = 22},
	[90120] = {pos = { x = 59.90606, y = 2.005699, z = -15.60608 }, mapid = 23},
	[90122] = {pos = { x = 65.87302, y = 2.005699, z = 1.946255 }, mapid = 23},
	[90121] = {pos = { x = 76.8578, y = 2.2057, z = 38.74649 }, mapid = 23},
	[90124] = {pos = { x = 61.22942, y = 2.2057, z = 56.20582 }, mapid = 23},
	[90123] = {pos = { x = 62.63606, y = 2.2057, z = 54.85609 }, mapid = 23},
	[90125] = {pos = { x = 60.19578, y = 2.405701, z = 93.94703 }, mapid = 23},
	[90130] = {pos = { x = 60.89154, y = 2.005699, z = -12.54145 }, mapid = 401},
	[90132] = {pos = { x = 64.89324, y = 2.005699, z = -0.8151455 }, mapid = 401},
	[90131] = {pos = { x = 77.9376, y = 2.2057, z = 42.23676 }, mapid = 401},
	[90134] = {pos = { x = 62.25491, y = 2.2057, z = 53.06897 }, mapid = 401},
	[90133] = {pos = { x = 63.49718, y = 2.2057, z = 52.62141 }, mapid = 401},
	[90135] = {pos = { x = 58.95313, y = 2.405701, z = 94.29225 }, mapid = 401},
	[90001] = {pos = { x = 1.977157, y = 2.241071, z = -0.2977303 }, mapid = 100},
	[90005] = {pos = { x = 1.702101, y = 7.996634, z = 2.57873 }, mapid = 102},
	[90007] = {pos = { x = 21.71661, y = 25.0, z = -17.23981 }, mapid = 103},
	[90009] = {pos = { x = 0.2041195, y = 2.11319, z = -0.9483471 }, mapid = 104},
	[90011] = {pos = { x = 0.6789541, y = 2.21373, z = 2.984033 }, mapid = 105},
	[90013] = {pos = { x = 1.446217, y = 2.217143, z = 5.022685 }, mapid = 106},
	[90017] = {pos = { x = 21.33797, y = 25.0, z = -17.49227 }, mapid = 108},
	[90019] = {pos = { x = -0.9707909, y = 2.089866, z = -0.7130165 }, mapid = 109},
	[90021] = {pos = { x = 21.14026, y = 25.0, z = -15.15572 }, mapid = 110},
	[90023] = {pos = { x = 22.00619, y = 25.0, z = -18.00169 }, mapid = 111},
	[90025] = {pos = { x = -1.114515, y = 2.097302, z = -1.438623 }, mapid = 112},
	[90027] = {pos = { x = -1.098172, y = 2.080451, z = -0.1825046 }, mapid = 113},
	[90029] = {pos = { x = 0.6101904, y = 7.996634, z = 3.2947 }, mapid = 114},
	[90031] = {pos = { x = 1.446217, y = 2.217143, z = 5.022685 }, mapid = 115},
	[90033] = {pos = { x = 1.702101, y = 7.996634, z = 2.57873 }, mapid = 116},
	[90035] = {pos = { x = 19.39465, y = 25.0, z = -15.46873 }, mapid = 117},
	[90037] = {pos = { x = 1.702101, y = 7.996634, z = 2.57873 }, mapid = 118},
	[90039] = {pos = { x = -0.2102012, y = 2.209428, z = 0.7297373 }, mapid = 119},
	[90041] = {pos = { x = -1.114515, y = 2.097302, z = -1.438623 }, mapid = 120},
	[90043] = {pos = { x = -1.114515, y = 2.097302, z = -1.438623 }, mapid = 121},
	[90045] = {pos = { x = -0.2102012, y = 2.209428, z = 0.7297373 }, mapid = 122},
	[90047] = {pos = { x = 1.208347, y = 0.1999981, z = 0.1324501 }, mapid = 123},
	[90003] = {pos = { x = 0.5547933, y = 7.996634, z = 2.2808 }, mapid = 101},
	[90015] = {pos = { x = 0.1655359, y = 7.996634, z = 2.579562 }, mapid = 107},

};
function get_db_table()
	return map;
end
