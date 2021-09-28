----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[28701] = {	id = 28701, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 28701, 28702, 28703, 28704, 28705, 28706,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
