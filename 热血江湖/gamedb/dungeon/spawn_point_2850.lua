----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[570101] = {	id = 570101, pos = { x = -2.996635, y = 0.3410247, z = -34.73306 }, randomPos = 0, randomRadius = 0, monsters = { 90711,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570102] = {	id = 570102, pos = { x = -0.1536407, y = 0.3706557, z = -34.31026 }, randomPos = 0, randomRadius = 0, monsters = { 90711,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570103] = {	id = 570103, pos = { x = 3.316488, y = 0.3936438, z = -33.81038 }, randomPos = 0, randomRadius = 0, monsters = { 90711,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[570104] = {	id = 570104, pos = { x = 6.26737, y = 0.1966242, z = -33.97784 }, randomPos = 0, randomRadius = 0, monsters = { 90711,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
