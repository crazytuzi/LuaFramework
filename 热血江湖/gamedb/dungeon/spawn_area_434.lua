----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[43401] = {	id = 43401, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43401, 43402,  } , spawndeny = 0 },
	[43411] = {	id = 43411, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43411, 43412, 43413, 43414,  } , spawndeny = 0 },
	[43421] = {	id = 43421, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43421, 43422, 43423, 43424,  } , spawndeny = 0 },
	[43431] = {	id = 43431, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43431,  } , spawndeny = 0 },
	[43432] = {	id = 43432, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43432,  } , spawndeny = 0 },
	[43433] = {	id = 43433, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43433,  } , spawndeny = 0 },
	[43434] = {	id = 43434, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43434,  } , spawndeny = 0 },
	[43441] = {	id = 43441, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43441, 43442, 43443, 43444,  } , spawndeny = 0 },
	[43451] = {	id = 43451, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43451, 43452,  } , spawndeny = 0 },
	[43461] = {	id = 43461, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43461, 43462, 43463, 43464,  } , spawndeny = 0 },
	[43471] = {	id = 43471, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43471, 43472, 43473, 43474,  } , spawndeny = 0 },
	[43481] = {	id = 43481, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43481,  } , spawndeny = 0 },
	[43482] = {	id = 43482, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43482,  } , spawndeny = 0 },
	[43483] = {	id = 43483, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43483,  } , spawndeny = 0 },
	[43484] = {	id = 43484, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43484,  } , spawndeny = 0 },
	[43491] = {	id = 43491, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 43491, 43492, 43493, 43494,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
