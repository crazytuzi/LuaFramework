----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[26401] = {	id = 26401, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 26401, 26402, 26403, 26404, 26405, 26406, 26407, 26408, 26409, 26410,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
