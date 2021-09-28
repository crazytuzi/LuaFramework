----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[26701] = {	id = 26701, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 26701, 26702, 26703, 26704, 26705, 26706,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
