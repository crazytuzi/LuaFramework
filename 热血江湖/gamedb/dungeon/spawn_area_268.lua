----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[26801] = {	id = 26801, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 26801, 26802, 26803, 26804, 26805, 26806,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
