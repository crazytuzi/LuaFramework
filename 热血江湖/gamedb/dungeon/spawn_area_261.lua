----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[26101] = {	id = 26101, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 26101, 26102, 26103, 26104, 26105, 26106,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
