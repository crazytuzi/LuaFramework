----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[510401] = {	id = 510401, pos = { x = 35.79536, y = 13.97486, z = -8.783749 }, randomPos = 0, randomRadius = 0, monsters = { 90619,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510402] = {	id = 510402, pos = { x = 34.80945, y = 13.95455, z = -11.88401 }, randomPos = 0, randomRadius = 0, monsters = { 90617,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510403] = {	id = 510403, pos = { x = 38.21486, y = 13.87089, z = -10.78011 }, randomPos = 0, randomRadius = 0, monsters = { 90617,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510404] = {	id = 510404, pos = { x = 37.54024, y = 13.95788, z = -5.385941 }, randomPos = 0, randomRadius = 0, monsters = { 90617,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510405] = {	id = 510405, pos = { x = 36.98103, y = 13.86703, z = -12.86724 }, randomPos = 0, randomRadius = 0, monsters = { 90618,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510406] = {	id = 510406, pos = { x = 38.24258, y = 13.94996, z = -5.353287 }, randomPos = 0, randomRadius = 0, monsters = { 90618,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[510407] = {	id = 510407, pos = { x = 38.44649, y = 13.96034, z = -7.059053 }, randomPos = 0, randomRadius = 0, monsters = { 90618,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
