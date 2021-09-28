----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[29701] = {	id = 29701, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 29701, 29702, 29703, 29704, 29705, 29706,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
