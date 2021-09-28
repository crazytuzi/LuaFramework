----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[27101] = {	id = 27101, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 27101, 27102, 27103, 27104, 27105, 27106,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
