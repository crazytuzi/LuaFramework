----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[610101] = {	id = 610101, pos = { x = -8.531355, y = 6.965291, z = -42.78647 }, randomPos = 0, randomRadius = 0, monsters = { 90901,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610102] = {	id = 610102, pos = { x = -8.610928, y = 6.965291, z = -37.53231 }, randomPos = 0, randomRadius = 0, monsters = { 90901,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610103] = {	id = 610103, pos = { x = -7.043859, y = 6.965291, z = -40.07113 }, randomPos = 0, randomRadius = 0, monsters = { 90901,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610104] = {	id = 610104, pos = { x = -6.836945, y = 6.965291, z = -44.85661 }, randomPos = 0, randomRadius = 0, monsters = { 90902,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610105] = {	id = 610105, pos = { x = -6.731985, y = 6.965291, z = -33.41463 }, randomPos = 0, randomRadius = 0, monsters = { 90902,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[610106] = {	id = 610106, pos = { x = -5.470728, y = 6.965291, z = -36.99696 }, randomPos = 0, randomRadius = 0, monsters = { 90902,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
