----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[39321] = {	id = 39321, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39321,  } , spawndeny = 10000 },
	[39322] = {	id = 39322, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39322,  } , spawndeny = 10000 },
	[39323] = {	id = 39323, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39323,  } , spawndeny = 10000 },
	[39324] = {	id = 39324, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39324,  } , spawndeny = 10000 },
	[39325] = {	id = 39325, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39325,  } , spawndeny = 10000 },
	[39326] = {	id = 39326, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39326,  } , spawndeny = 10000 },
	[39327] = {	id = 39327, range = 200.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 39327,  } , spawndeny = 10000 },

};
function get_db_table()
	return spawn_area;
end
