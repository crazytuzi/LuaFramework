----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[80701] = {	id = 80701, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80701, 80702,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
