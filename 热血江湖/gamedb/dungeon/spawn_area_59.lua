----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[5901] = {	id = 5901, range = 500.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5608,  }, EndClose = {  }, spawnPoints = { 590103, 590104, 590105, 590106, 590107, 590108,  } , spawndeny = 0 },
	[5902] = {	id = 5902, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5609,  }, EndClose = {  }, spawnPoints = { 590202, 590203, 590204, 590205, 590206, 590207, 590208, 590209, 590210, 590211,  } , spawndeny = 0 },
	[5903] = {	id = 5903, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5610, 5601,  }, EndClose = {  }, spawnPoints = { 590302, 590303, 590304, 590305, 590306, 590307, 590308, 590309, 590310, 590311,  } , spawndeny = 0 },
	[5904] = {	id = 5904, range = 1000.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = { 5602, 5607,  }, EndClose = {  }, spawnPoints = { 590401, 590402, 590403, 590404, 590405, 590406, 590407, 590408, 590409, 590410, 590411,  } , spawndeny = 0 },
	[5905] = {	id = 5905, range = 800.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 590501, 590502, 590503, 590504, 590505, 590506, 590507, 590508, 590509, 590510, 590511,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
