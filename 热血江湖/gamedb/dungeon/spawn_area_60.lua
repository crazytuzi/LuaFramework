----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[6001] = {	id = 6001, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 600101, 600102, 600103, 600104,  } , spawndeny = 0 },
	[6002] = {	id = 6002, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 600201, 600202, 600203, 600204,  } , spawndeny = 0 },
	[6003] = {	id = 6003, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 600301, 600302, 600303, 600304,  } , spawndeny = 0 },
	[6004] = {	id = 6004, range = 700.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 6001,  }, EndClose = {  }, spawnPoints = { 600401, 600402, 600403, 600404,  } , spawndeny = 0 },
	[6005] = {	id = 6005, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 600501, 600502, 600503, 600504, 600505, 600506, 600507, 600508, 600509,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
