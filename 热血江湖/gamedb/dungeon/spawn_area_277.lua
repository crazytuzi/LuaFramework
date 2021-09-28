----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[27701] = {	id = 27701, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 27701, 27702, 27703, 27704, 27705, 27706,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
