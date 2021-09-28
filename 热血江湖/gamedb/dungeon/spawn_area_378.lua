----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[37801] = {	id = 37801, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 37801, 37802, 37803, 37804, 37805, 37806,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
