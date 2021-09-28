----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[63500] = {	id = 63500, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63501, 63502, 63503, 63504,  } , spawndeny = 0 },
	[63510] = {	id = 63510, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63511, 63512,  } , spawndeny = 0 },
	[63520] = {	id = 63520, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63521, 63522, 63523, 63524,  } , spawndeny = 0 },
	[63530] = {	id = 63530, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 63531, 63532,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
