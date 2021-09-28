----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local res_area = 
{
	[30100] = {	id = 30100, pos = { x = -72.8867, y = 7.052431, z = 48.876 }, dir = { x = 0.0, y = 0.0, z = 0.0 }, ResourcepointID = 2120},

};
function get_db_table()
	return res_area;
end
