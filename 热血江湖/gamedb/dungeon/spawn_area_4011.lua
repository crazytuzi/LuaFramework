----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[401101] = {	id = 401101, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351040, 351041, 351042, 351043, 351044,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
