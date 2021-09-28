----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[77101] = {	id = 77101, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77101, 77102, 77103,  } , spawndeny = 0 },
	[77102] = {	id = 77102, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77104, 77105, 77106,  } , spawndeny = 0 },
	[77103] = {	id = 77103, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77107, 77108, 77109,  } , spawndeny = 0 },
	[77104] = {	id = 77104, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77110, 77111, 77112,  } , spawndeny = 0 },
	[77105] = {	id = 77105, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77113, 77114, 77115,  } , spawndeny = 0 },
	[77106] = {	id = 77106, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77116, 77117, 77118,  } , spawndeny = 0 },
	[77107] = {	id = 77107, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77119, 77120, 77121,  } , spawndeny = 0 },
	[77108] = {	id = 77108, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77122, 77123, 77124,  } , spawndeny = 0 },
	[77109] = {	id = 77109, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77125, 77126, 77127,  } , spawndeny = 0 },
	[77110] = {	id = 77110, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77128, 77129, 77130,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
