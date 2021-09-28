----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[33101] = {	id = 33101, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 33101, 33102, 33103, 33104, 33105, 33106,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
