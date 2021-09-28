----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[2401] = {	id = 2401, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2101,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 240101, 240102, 240103, 240104, 240105, 240106,  } , spawndeny = 0 },
	[2402] = {	id = 2402, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2101,  }, EndClose = {  }, spawnPoints = { 240201, 240202, 240203, 240204, 240205, 240206, 240207, 240208,  } , spawndeny = 0 },
	[2403] = {	id = 2403, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = { 2102,  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 240301, 240302, 240303, 240304, 240305, 240306, 240307, 240308,  } , spawndeny = 0 },
	[2404] = {	id = 2404, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 2102,  }, EndClose = {  }, spawnPoints = { 240401, 240402, 240403, 240404, 240405, 240406, 240407, 240408, 240409, 240410, 240411,  } , spawndeny = 0 },
	[2405] = {	id = 2405, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 240501, 240502, 240503, 240504, 240505, 240506, 240507, 240508, 240509, 240510, 240511,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
