----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[7401] = {	id = 7401, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 740101, 740102, 740103, 740104, 740105, 740106, 740107,  } , spawndeny = 0 },
	[7402] = {	id = 7402, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7201,  }, EndClose = {  }, spawnPoints = { 740201, 740202, 740203, 740204, 740205, 740206, 740207, 740208, 740209, 740210,  } , spawndeny = 0 },
	[7403] = {	id = 7403, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 740301, 740302, 740303, 740304, 740305, 740306, 740307, 740308, 740309, 740310, 740311,  } , spawndeny = 0 },
	[7404] = {	id = 7404, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 7202,  }, EndClose = {  }, spawnPoints = { 740401, 740402, 740403, 740404, 740405, 740406, 740407, 740408, 740409, 740410, 740411, 740412,  } , spawndeny = 0 },
	[7405] = {	id = 7405, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 740501, 740502, 740503, 740504, 740505, 740506, 740507, 740508, 740509, 740510, 740511, 740512,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
