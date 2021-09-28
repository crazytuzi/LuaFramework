----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[38401] = {	id = 38401, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 38401, 38402, 38403, 38404, 38405, 38406, 38407, 38408, 38409, 38410,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
