----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[35701] = {	id = 35701, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 35701, 35702, 35703, 35704, 35705, 35706,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
