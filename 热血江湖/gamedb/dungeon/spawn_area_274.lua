----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[27401] = {	id = 27401, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 27401, 27402, 27403, 27404, 27405, 27406, 27407, 27408, 27409, 27410,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
