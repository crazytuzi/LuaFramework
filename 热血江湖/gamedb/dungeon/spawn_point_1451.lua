----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[290201] = {	id = 290201, pos = { x = -12.97759, y = 4.998282, z = -4.973912 }, randomPos = 0, randomRadius = 0, monsters = { 90221,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290202] = {	id = 290202, pos = { x = -13.23057, y = 4.709192, z = -0.383625 }, randomPos = 0, randomRadius = 0, monsters = { 90221,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290301] = {	id = 290301, pos = { x = -16.65506, y = 5.041372, z = -8.219004 }, randomPos = 0, randomRadius = 0, monsters = { 90222,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290302] = {	id = 290302, pos = { x = -18.30015, y = 4.793882, z = 0.4572487 }, randomPos = 0, randomRadius = 0, monsters = { 90222,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[290303] = {	id = 290303, pos = { x = -17.33157, y = 5.001474, z = -3.07584 }, randomPos = 0, randomRadius = 0, monsters = { 90223,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
