----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[35301] = {	id = 35301, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 35301, 35302, 35303, 35304,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
