----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[35101] = {	id = 35101, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 35101, 35102, 35103, 35104, 35105, 35106,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
