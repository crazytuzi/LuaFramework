----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[37701] = {	id = 37701, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 37701, 37702, 37703, 37704, 37705, 37706,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
