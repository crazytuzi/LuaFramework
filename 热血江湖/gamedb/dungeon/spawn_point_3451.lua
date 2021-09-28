----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[690201] = {	id = 690201, pos = { x = -18.60965, y = 0.4378013, z = 6.86248 }, randomPos = 0, randomRadius = 0, monsters = { 93102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690202] = {	id = 690202, pos = { x = -18.76703, y = 0.3857151, z = 5.663572 }, randomPos = 0, randomRadius = 0, monsters = { 93102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690203] = {	id = 690203, pos = { x = -20.01352, y = 0.3857151, z = 4.278868 }, randomPos = 0, randomRadius = 0, monsters = { 93103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690204] = {	id = 690204, pos = { x = -17.10081, y = 0.3857151, z = 5.420115 }, randomPos = 0, randomRadius = 0, monsters = { 93103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690301] = {	id = 690301, pos = { x = 1.245443, y = 6.237802, z = 6.806665 }, randomPos = 0, randomRadius = 0, monsters = { 93103,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690302] = {	id = 690302, pos = { x = -3.37873, y = 6.185715, z = 7.538982 }, randomPos = 0, randomRadius = 0, monsters = { 93102,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690303] = {	id = 690303, pos = { x = -2.290779, y = 6.185715, z = 3.475144 }, randomPos = 0, randomRadius = 0, monsters = { 93101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690304] = {	id = 690304, pos = { x = 4.722187, y = 6.185715, z = 9.944166 }, randomPos = 0, randomRadius = 0, monsters = { 93101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[690305] = {	id = 690305, pos = { x = 2.220728, y = 6.185715, z = 4.850598 }, randomPos = 0, randomRadius = 0, monsters = { 93104,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
