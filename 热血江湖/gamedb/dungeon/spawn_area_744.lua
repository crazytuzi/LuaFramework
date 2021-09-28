----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[74401] = {	id = 74401, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74401, 74402, 74403,  } , spawndeny = 0 },
	[74402] = {	id = 74402, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74404, 74405, 74406,  } , spawndeny = 0 },
	[74403] = {	id = 74403, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74407, 74408, 74409,  } , spawndeny = 0 },
	[74404] = {	id = 74404, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74410, 74411, 74412,  } , spawndeny = 0 },
	[74405] = {	id = 74405, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74413, 74414, 74415,  } , spawndeny = 0 },
	[74406] = {	id = 74406, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74416, 74417, 74418,  } , spawndeny = 0 },
	[74407] = {	id = 74407, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74419, 74420, 74421,  } , spawndeny = 0 },
	[74408] = {	id = 74408, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74422, 74423, 74424,  } , spawndeny = 0 },
	[74409] = {	id = 74409, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74425, 74426, 74427,  } , spawndeny = 0 },
	[74410] = {	id = 74410, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74428, 74429, 74430,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
