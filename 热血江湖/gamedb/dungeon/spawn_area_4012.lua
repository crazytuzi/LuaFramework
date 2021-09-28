----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[401201] = {	id = 401201, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351045, 351046, 351047, 351048, 351049,  } , spawndeny = 0 },
	[401202] = {	id = 401202, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351090, 351091, 351092, 351093, 351094,  } , spawndeny = 0 },
	[401203] = {	id = 401203, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351095, 351096, 351097, 351098, 351099,  } , spawndeny = 0 },
	[401204] = {	id = 401204, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351100, 351101, 351102, 351103, 351104,  } , spawndeny = 0 },
	[401205] = {	id = 401205, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351105, 351106, 351107, 351108, 351109,  } , spawndeny = 0 },
	[401206] = {	id = 401206, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351110, 351111, 351112, 351113, 351114,  } , spawndeny = 0 },
	[401207] = {	id = 401207, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351115, 351116, 351117, 351118, 351119,  } , spawndeny = 0 },
	[401208] = {	id = 401208, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351120, 351121, 351122, 351123, 351124,  } , spawndeny = 0 },
	[401209] = {	id = 401209, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351125, 351126, 351127, 351128, 351129,  } , spawndeny = 0 },
	[401210] = {	id = 401210, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351130, 351131, 351132, 351133, 351134,  } , spawndeny = 0 },
	[401211] = {	id = 401211, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 351135, 351136, 351137, 351138, 351139,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
