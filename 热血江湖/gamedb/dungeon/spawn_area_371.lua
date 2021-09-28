----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[37101] = {	id = 37101, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 37101, 37102, 37103, 37104, 37105, 37106,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
