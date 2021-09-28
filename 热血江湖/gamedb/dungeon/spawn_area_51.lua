----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[5101] = {	id = 5101, range = 5000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 510101, 510102, 510103, 510104, 510105,  } , spawndeny = 0 },
	[5102] = {	id = 5102, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5001,  }, EndClose = {  }, spawnPoints = { 510106, 510107, 510108, 510109, 510110,  } , spawndeny = 0 },
	[5103] = {	id = 5103, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 510201, 510202, 510203, 510204, 510205, 510206,  } , spawndeny = 0 },
	[5104] = {	id = 5104, range = 1500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5006,  }, EndClose = {  }, spawnPoints = { 510301, 510302, 510303, 510304, 510305, 510306, 510307, 510308,  } , spawndeny = 0 },
	[5105] = {	id = 5105, range = 2000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 510401, 510402, 510403, 510404, 510405, 510406, 510407,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
