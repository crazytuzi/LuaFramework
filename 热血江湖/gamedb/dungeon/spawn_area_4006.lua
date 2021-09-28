----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[400601] = {	id = 400601, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351015, 351016, 351017, 351018, 351019,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
