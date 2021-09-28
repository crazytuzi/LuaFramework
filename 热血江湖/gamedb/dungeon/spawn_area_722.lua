----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[72201] = {	id = 72201, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72201, 72202, 72203,  } , spawndeny = 0 },
	[72202] = {	id = 72202, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72204, 72205, 72206,  } , spawndeny = 0 },
	[72203] = {	id = 72203, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72207, 72208, 72209,  } , spawndeny = 0 },
	[72204] = {	id = 72204, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72210, 72211, 72212,  } , spawndeny = 0 },
	[72205] = {	id = 72205, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72213, 72214, 72215,  } , spawndeny = 0 },
	[72206] = {	id = 72206, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72216, 72217, 72218,  } , spawndeny = 0 },
	[72207] = {	id = 72207, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72219, 72220, 72221,  } , spawndeny = 0 },
	[72208] = {	id = 72208, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72222, 72223, 72224,  } , spawndeny = 0 },
	[72209] = {	id = 72209, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72225, 72226, 72227,  } , spawndeny = 0 },
	[72210] = {	id = 72210, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 72228, 72229, 72230,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
