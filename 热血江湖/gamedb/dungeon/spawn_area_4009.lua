----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[400901] = {	id = 400901, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351030, 351031, 351032, 351033, 351034,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
