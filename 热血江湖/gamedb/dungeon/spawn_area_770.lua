----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[77001] = {	id = 77001, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77001, 77002, 77003,  } , spawndeny = 0 },
	[77002] = {	id = 77002, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77004, 77005, 77006,  } , spawndeny = 0 },
	[77003] = {	id = 77003, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77007, 77008, 77009,  } , spawndeny = 0 },
	[77004] = {	id = 77004, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77010, 77011, 77012,  } , spawndeny = 0 },
	[77005] = {	id = 77005, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77013, 77014, 77015,  } , spawndeny = 0 },
	[77006] = {	id = 77006, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77016, 77017, 77018,  } , spawndeny = 0 },
	[77007] = {	id = 77007, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77019, 77020, 77021,  } , spawndeny = 0 },
	[77008] = {	id = 77008, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77022, 77023, 77024,  } , spawndeny = 0 },
	[77009] = {	id = 77009, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77025, 77026, 77027,  } , spawndeny = 0 },
	[77010] = {	id = 77010, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 77028, 77029, 77030,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
