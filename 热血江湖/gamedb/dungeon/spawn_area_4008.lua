----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[400801] = {	id = 400801, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351025, 351026, 351027, 351028, 351029,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
