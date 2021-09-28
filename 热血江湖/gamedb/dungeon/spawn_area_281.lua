----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[28101] = {	id = 28101, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 28101, 28102, 28103, 28104, 28105, 28106,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
