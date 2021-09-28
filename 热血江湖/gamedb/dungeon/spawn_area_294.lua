----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[29401] = {	id = 29401, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 29401, 29402, 29403, 29404, 29405, 29406, 29407, 29408, 29409, 29410,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
