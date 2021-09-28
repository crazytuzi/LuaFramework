----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[311002] = {pos = { x = -22.6297379, y = 9.187286, z = 44.7644119 }, mapid = 91102},
	[311004] = {pos = { x = 33.5189819, y = -8.924781, z = -103.189522 }, mapid = 91104},
	[311005] = {pos = { x = -152.384689, y = 18.1046066, z = 121.036278 }, mapid = 91105},
	[311001] = {pos = { x = 140.6361, y = 0.1638422, z = -35.68009 }, mapid = 91101},
	[311003] = {pos = { x = 165.519623, y = 26.0820236, z = 64.54193 }, mapid = 91103},

};
function get_db_table()
	return map;
end
