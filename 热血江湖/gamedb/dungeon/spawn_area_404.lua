----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[40401] = {	id = 40401, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40401,  } , spawndeny = 0 },
	[40411] = {	id = 40411, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40411, 40412, 40413, 40414,  } , spawndeny = 0 },
	[40421] = {	id = 40421, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40421, 40422, 40423, 40424,  } , spawndeny = 0 },
	[40431] = {	id = 40431, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40431,  } , spawndeny = 0 },
	[40432] = {	id = 40432, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40432,  } , spawndeny = 0 },
	[40433] = {	id = 40433, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40433,  } , spawndeny = 0 },
	[40434] = {	id = 40434, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40434,  } , spawndeny = 0 },
	[40441] = {	id = 40441, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40441, 40442, 40443, 40444,  } , spawndeny = 0 },
	[40451] = {	id = 40451, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40451,  } , spawndeny = 0 },
	[40461] = {	id = 40461, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40461, 40462, 40463, 40464,  } , spawndeny = 0 },
	[40471] = {	id = 40471, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40471, 40472, 40473, 40474,  } , spawndeny = 0 },
	[40481] = {	id = 40481, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40481,  } , spawndeny = 0 },
	[40482] = {	id = 40482, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40482,  } , spawndeny = 0 },
	[40483] = {	id = 40483, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40483,  } , spawndeny = 0 },
	[40484] = {	id = 40484, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40484,  } , spawndeny = 0 },
	[40491] = {	id = 40491, range = 2500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 40491, 40492, 40493, 40494,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
