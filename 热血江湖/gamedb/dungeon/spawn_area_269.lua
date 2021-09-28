----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[26901] = {	id = 26901, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 26901, 26902,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
