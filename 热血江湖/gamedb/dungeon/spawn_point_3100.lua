----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[620101] = {	id = 620101, pos = { x = -8.741384, y = 6.965301, z = -3.26004 }, randomPos = 0, randomRadius = 0, monsters = { 91001,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620102] = {	id = 620102, pos = { x = -6.219812, y = 6.965301, z = -3.617823 }, randomPos = 0, randomRadius = 0, monsters = { 91001,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620103] = {	id = 620103, pos = { x = -12.78184, y = 6.965301, z = -5.675609 }, randomPos = 0, randomRadius = 0, monsters = { 91001,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620104] = {	id = 620104, pos = { x = -10.61607, y = 6.965301, z = -6.195445 }, randomPos = 0, randomRadius = 0, monsters = { 91001,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620105] = {	id = 620105, pos = { x = -7.292387, y = 6.965301, z = -5.299098 }, randomPos = 0, randomRadius = 0, monsters = { 91002,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620106] = {	id = 620106, pos = { x = -10.00672, y = 6.965301, z = -4.687874 }, randomPos = 0, randomRadius = 0, monsters = { 91002,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620107] = {	id = 620107, pos = { x = -13.79607, y = 6.965301, z = -2.571427 }, randomPos = 0, randomRadius = 0, monsters = { 91002,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[620108] = {	id = 620108, pos = { x = -11.03554, y = 6.965301, z = -2.56947 }, randomPos = 0, randomRadius = 0, monsters = { 91002,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
