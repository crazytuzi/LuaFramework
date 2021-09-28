----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[33401] = {	id = 33401, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 33401, 33402, 33403, 33404, 33405, 33406, 33407, 33408, 33409, 33410,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
