----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[33301] = {	id = 33301, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 33301, 33302, 33303, 33304,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
