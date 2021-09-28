----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[74001] = {	id = 74001, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74001, 74002, 74003,  } , spawndeny = 0 },
	[74002] = {	id = 74002, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74004, 74005, 74006,  } , spawndeny = 0 },
	[74003] = {	id = 74003, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74007, 74008, 74009,  } , spawndeny = 0 },
	[74004] = {	id = 74004, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74010, 74011, 74012,  } , spawndeny = 0 },
	[74005] = {	id = 74005, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74013, 74014, 74015,  } , spawndeny = 0 },
	[74006] = {	id = 74006, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74016, 74017, 74018,  } , spawndeny = 0 },
	[74007] = {	id = 74007, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74019, 74020, 74021,  } , spawndeny = 0 },
	[74008] = {	id = 74008, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74022, 74023, 74024,  } , spawndeny = 0 },
	[74009] = {	id = 74009, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74025, 74026, 74027,  } , spawndeny = 0 },
	[74010] = {	id = 74010, range = 600.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 74028, 74029, 74030,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
