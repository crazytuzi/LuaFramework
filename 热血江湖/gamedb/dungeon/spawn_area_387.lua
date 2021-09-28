----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[38701] = {	id = 38701, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 38701, 38702, 38703, 38704, 38705, 38706,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
