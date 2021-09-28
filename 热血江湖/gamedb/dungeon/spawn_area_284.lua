----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[28401] = {	id = 28401, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 28401, 28402, 28403, 28404, 28405, 28406, 28407, 28408, 28409, 28410,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
