----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[7301] = {	id = 7301, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 730101, 730102, 730103, 730104, 730105,  } , spawndeny = 0 },
	[7302] = {	id = 7302, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7201,  }, EndClose = {  }, spawnPoints = { 730201, 730202, 730203, 730204, 730205,  } , spawndeny = 0 },
	[7303] = {	id = 7303, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 730301, 730302, 730303, 730304, 730305, 730306,  } , spawndeny = 0 },
	[7304] = {	id = 7304, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7202,  }, EndClose = {  }, spawnPoints = { 730401, 730402, 730403, 730404, 730405, 730406, 730407,  } , spawndeny = 0 },
	[7305] = {	id = 7305, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 730501, 730502, 730503, 730504, 730505, 730506, 730507, 730508, 730509, 730510,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
