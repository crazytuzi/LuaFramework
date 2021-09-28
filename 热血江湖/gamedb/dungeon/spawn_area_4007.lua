----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[400701] = {	id = 400701, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351020, 351021, 351022, 351023, 351024,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
