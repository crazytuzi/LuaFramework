----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[400301] = {	id = 400301, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351000, 351001, 351002, 351003, 351004,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
