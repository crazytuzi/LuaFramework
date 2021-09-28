----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[33701] = {	id = 33701, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 33701, 33702, 33703, 33704, 33705, 33706,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
