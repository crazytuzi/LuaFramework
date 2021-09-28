----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[470101] = {	id = 470101, pos = { x = -6.44502, y = 6.265144, z = 16.23118 }, randomPos = 0, randomRadius = 0, monsters = { 90421,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470102] = {	id = 470102, pos = { x = 2.337078, y = 6.456934, z = 19.1848 }, randomPos = 0, randomRadius = 0, monsters = { 90421,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470103] = {	id = 470103, pos = { x = 2.023999, y = 6.438373, z = 19.77399 }, randomPos = 0, randomRadius = 0, monsters = { 90421,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470104] = {	id = 470104, pos = { x = 8.165356, y = 6.42244, z = 17.09965 }, randomPos = 0, randomRadius = 0, monsters = { 90421,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470105] = {	id = 470105, pos = { x = 13.30334, y = 6.418609, z = 12.05585 }, randomPos = 0, randomRadius = 0, monsters = { 90422,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470106] = {	id = 470106, pos = { x = 13.71148, y = 6.399738, z = 9.768052 }, randomPos = 0, randomRadius = 0, monsters = { 90422,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470107] = {	id = 470107, pos = { x = 4.020269, y = 6.385777, z = 20.16146 }, randomPos = 0, randomRadius = 0, monsters = { 90422,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[470108] = {	id = 470108, pos = { x = 0.0, y = 6.009236, z = 20.71723 }, randomPos = 0, randomRadius = 0, monsters = { 90422,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
