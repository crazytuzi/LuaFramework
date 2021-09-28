----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[86001] = {	id = 86001, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 86001, 86002, 86003, 86004,  } , spawndeny = 3000 },
	[86002] = {	id = 86002, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 86005, 86006, 86007, 86008,  } , spawndeny = 3000 },
	[86003] = {	id = 86003, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 86009, 86010, 86011, 86012, 86013, 86014,  } , spawndeny = 3000 },
	[86004] = {	id = 86004, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 86015, 86016,  } , spawndeny = 3000 },
	[86005] = {	id = 86005, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 86017, 86018, 86019, 86020, 86021, 86022,  } , spawndeny = 3000 },
	[86006] = {	id = 86006, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 86023, 86024, 86025, 86026, 86027, 86028,  } , spawndeny = 3000 },
	[86007] = {	id = 86007, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 86029, 86030, 86031, 86032, 86033, 86034,  } , spawndeny = 3000 },
	[86008] = {	id = 86008, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 86035, 86036, 86037, 86038, 86039, 86040,  } , spawndeny = 3000 },

};
function get_db_table()
	return spawn_area;
end
