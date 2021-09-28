----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[4101] = {	id = 4101, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3901,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 410101, 410102, 410103, 410104,  } , spawndeny = 0 },
	[4102] = {	id = 4102, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 3901,  }, EndClose = {  }, spawnPoints = { 410202, 410203, 410204, 410205, 410206, 410207, 410209,  } , spawndeny = 0 },
	[4103] = {	id = 4103, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 3902,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 410302, 410303, 410304, 410305, 410306, 410307,  } , spawndeny = 0 },
	[4104] = {	id = 4104, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 3902,  }, EndClose = {  }, spawnPoints = { 410402, 410403, 410404, 410405, 410406, 410407, 410408,  } , spawndeny = 0 },
	[4105] = {	id = 4105, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 410502, 410503, 410504, 410505, 410506, 410507, 410508, 410509,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
