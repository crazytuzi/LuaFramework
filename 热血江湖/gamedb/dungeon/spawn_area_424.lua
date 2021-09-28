----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[42401] = {	id = 42401, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42401,  } , spawndeny = 0 },
	[42411] = {	id = 42411, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42411, 42412, 42413, 42414,  } , spawndeny = 0 },
	[42421] = {	id = 42421, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42421, 42422, 42423, 42424,  } , spawndeny = 0 },
	[42431] = {	id = 42431, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42431,  } , spawndeny = 0 },
	[42432] = {	id = 42432, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42432,  } , spawndeny = 0 },
	[42433] = {	id = 42433, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42433,  } , spawndeny = 0 },
	[42434] = {	id = 42434, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42434,  } , spawndeny = 0 },
	[42441] = {	id = 42441, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42441, 42442, 42443, 42444,  } , spawndeny = 0 },
	[42451] = {	id = 42451, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42451,  } , spawndeny = 0 },
	[42461] = {	id = 42461, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42461, 42462, 42463, 42464,  } , spawndeny = 0 },
	[42471] = {	id = 42471, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42471, 42472, 42473, 42474,  } , spawndeny = 0 },
	[42481] = {	id = 42481, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42481,  } , spawndeny = 0 },
	[42482] = {	id = 42482, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42482,  } , spawndeny = 0 },
	[42483] = {	id = 42483, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42483,  } , spawndeny = 0 },
	[42484] = {	id = 42484, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42484,  } , spawndeny = 0 },
	[42491] = {	id = 42491, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 42491, 42492, 42493, 42494,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
