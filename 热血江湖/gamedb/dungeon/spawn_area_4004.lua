----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[400401] = {	id = 400401, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351005, 351006, 351007, 351008, 351009,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
