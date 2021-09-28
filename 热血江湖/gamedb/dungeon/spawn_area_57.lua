----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[5701] = {	id = 5701, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5608,  }, EndClose = {  }, spawnPoints = { 570101, 570102, 570103, 570104,  } , spawndeny = 0 },
	[5702] = {	id = 5702, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5609,  }, EndClose = {  }, spawnPoints = { 570201, 570202, 570203, 570204, 570205, 570206,  } , spawndeny = 0 },
	[5703] = {	id = 5703, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5610, 5601,  }, EndClose = {  }, spawnPoints = { 570301, 570302, 570303, 570304, 570305, 570306,  } , spawndeny = 0 },
	[5704] = {	id = 5704, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5602, 5607,  }, EndClose = {  }, spawnPoints = { 570401, 570402, 570403, 570404, 570405, 570406, 570407,  } , spawndeny = 0 },
	[5705] = {	id = 5705, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 570501, 570502, 570503, 570504, 570505, 570506, 570507,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
