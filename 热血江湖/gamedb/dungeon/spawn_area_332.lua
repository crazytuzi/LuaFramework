----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[33201] = {	id = 33201, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 33201, 33202, 33203, 33204, 33205, 33206,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
