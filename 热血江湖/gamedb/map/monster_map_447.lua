----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[89404] = {pos = { x = 101.3786, y = 29.77525, z = -106.845 }, mapid = 242},
	[89406] = {pos = { x = 169.6422, y = 29.6, z = -147.0048 }, mapid = 242},
	[89407] = {pos = { x = -62.54817, y = 5.372826, z = 9.643635 }, mapid = 243},
	[89408] = {pos = { x = -71.97653, y = 8.172829, z = 116.8487 }, mapid = 243},
	[89409] = {pos = { x = -137.5861, y = 3.089657, z = 2.633394 }, mapid = 243},
	[89405] = {pos = { x = 136.3168, y = 29.66409, z = -138.7474 }, mapid = 242},

};
function get_db_table()
	return map;
end
