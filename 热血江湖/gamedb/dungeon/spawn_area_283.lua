----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[28301] = {	id = 28301, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 28301, 28302, 28303, 28304,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
