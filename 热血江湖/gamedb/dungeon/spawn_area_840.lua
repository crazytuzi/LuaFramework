----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[84001] = {	id = 84001, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 84001, 84002, 84003, 84004,  } , spawndeny = 5000 },
	[84002] = {	id = 84002, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 84005, 84006, 84007, 84008,  } , spawndeny = 3000 },
	[84003] = {	id = 84003, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 84009, 84010, 84011, 84012, 84013, 84014,  } , spawndeny = 3000 },
	[84004] = {	id = 84004, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 84015, 84016,  } , spawndeny = 3000 },
	[84005] = {	id = 84005, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 84017, 84018, 84019, 84020, 84021, 84022,  } , spawndeny = 3000 },
	[84006] = {	id = 84006, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 84023, 84024, 84025, 84026, 84027, 84028,  } , spawndeny = 3000 },
	[84007] = {	id = 84007, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 84029, 84030, 84031, 84032, 84033, 84034,  } , spawndeny = 3000 },
	[84008] = {	id = 84008, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 84035, 84036, 84037, 84038, 84039, 84040,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
