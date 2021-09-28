----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[41401] = {	id = 41401, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41401,  } , spawndeny = 0 },
	[41411] = {	id = 41411, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41411, 41412, 41413, 41414,  } , spawndeny = 0 },
	[41421] = {	id = 41421, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41421, 41422, 41423, 41424,  } , spawndeny = 0 },
	[41431] = {	id = 41431, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41431,  } , spawndeny = 0 },
	[41432] = {	id = 41432, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41432,  } , spawndeny = 0 },
	[41433] = {	id = 41433, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41433,  } , spawndeny = 0 },
	[41434] = {	id = 41434, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41434,  } , spawndeny = 0 },
	[41441] = {	id = 41441, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41441, 41442, 41443, 41444,  } , spawndeny = 0 },
	[41451] = {	id = 41451, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41451,  } , spawndeny = 0 },
	[41461] = {	id = 41461, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41461, 41462, 41463, 41464,  } , spawndeny = 0 },
	[41471] = {	id = 41471, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41471, 41472, 41473, 41474,  } , spawndeny = 0 },
	[41481] = {	id = 41481, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41481,  } , spawndeny = 0 },
	[41482] = {	id = 41482, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41482,  } , spawndeny = 0 },
	[41483] = {	id = 41483, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41483,  } , spawndeny = 0 },
	[41484] = {	id = 41484, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41484,  } , spawndeny = 0 },
	[41491] = {	id = 41491, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 41491, 41492, 41493, 41494,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
