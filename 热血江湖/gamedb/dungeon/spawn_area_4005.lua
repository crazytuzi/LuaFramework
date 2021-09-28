----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[400501] = {	id = 400501, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351010, 351011, 351012, 351013, 351014,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
