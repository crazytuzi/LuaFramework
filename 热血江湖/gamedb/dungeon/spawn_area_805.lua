----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[80501] = {	id = 80501, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80501, 80502, 80503, 80504, 80505, 80506,  } , spawndeny = 3000 },
	[80521] = {	id = 80521, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80521, 80522, 80523, 80524, 80525, 80526, 80527, 80528,  } , spawndeny = 3000 },
	[80541] = {	id = 80541, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80541, 80542, 80543, 80544,  } , spawndeny = 3000 },
	[80561] = {	id = 80561, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80561, 80562, 80563, 80564, 80565, 80566,  } , spawndeny = 3000 },
	[80581] = {	id = 80581, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 80581, 80582, 80583, 80584, 80585, 80586,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
