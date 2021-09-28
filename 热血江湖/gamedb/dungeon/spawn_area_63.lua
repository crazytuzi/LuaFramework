----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[6301] = {	id = 6301, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 630101, 630102, 630103, 630104, 630105, 630106, 630107, 630108, 630109, 630110,  } , spawndeny = 0 },
	[6302] = {	id = 6302, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 630201, 630202, 630203, 630204, 630205, 630206, 630207, 630208, 630209, 630210,  } , spawndeny = 0 },
	[6303] = {	id = 6303, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 630301, 630302, 630303, 630304, 630305, 630306, 630307, 630308, 630309, 630310,  } , spawndeny = 0 },
	[6304] = {	id = 6304, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 6001,  }, EndClose = {  }, spawnPoints = { 630401, 630402, 630403, 630404, 630405, 630406, 630407, 630408, 630409, 630410,  } , spawndeny = 0 },
	[6305] = {	id = 6305, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 630501, 630502, 630503, 630504, 630505, 630506, 630507, 630508, 630509, 630510, 630511,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
