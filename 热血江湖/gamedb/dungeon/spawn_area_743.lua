----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[74301] = {	id = 74301, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74301, 74302, 74303,  } , spawndeny = 0 },
	[74302] = {	id = 74302, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74304, 74305, 74306,  } , spawndeny = 0 },
	[74303] = {	id = 74303, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74307, 74308, 74309,  } , spawndeny = 0 },
	[74304] = {	id = 74304, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74310, 74311, 74312,  } , spawndeny = 0 },
	[74305] = {	id = 74305, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74313, 74314, 74315,  } , spawndeny = 0 },
	[74306] = {	id = 74306, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74316, 74317, 74318,  } , spawndeny = 0 },
	[74307] = {	id = 74307, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74319, 74320, 74321,  } , spawndeny = 0 },
	[74308] = {	id = 74308, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74322, 74323, 74324,  } , spawndeny = 0 },
	[74309] = {	id = 74309, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74325, 74326, 74327,  } , spawndeny = 0 },
	[74310] = {	id = 74310, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74328, 74329, 74330,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
