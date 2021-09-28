----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[35401] = {	id = 35401, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 35401, 35402, 35403, 35404, 35405, 35406, 35407, 35408, 35409, 35410,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
