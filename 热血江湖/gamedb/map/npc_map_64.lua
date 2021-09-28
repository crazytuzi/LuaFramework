----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local map = 
{
	[32100] = {	pos = { x = 22.46766, y = 5.786865, z = 14.48057 }, mapid = 1},

};
function get_db_table()
	return map;
end
