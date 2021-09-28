----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[340201] = {	id = 340201, pos = { x = 1.172954, y = 0.3588619, z = 31.48075 }, randomPos = 0, randomRadius = 0, monsters = { 90311,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340202] = {	id = 340202, pos = { x = -4.982321, y = 0.5249913, z = 34.0887 }, randomPos = 0, randomRadius = 0, monsters = { 90311,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340203] = {	id = 340203, pos = { x = 3.553918, y = 0.6745236, z = 35.40873 }, randomPos = 0, randomRadius = 0, monsters = { 90311,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340204] = {	id = 340204, pos = { x = -2.655524, y = 0.5312254, z = 35.42673 }, randomPos = 0, randomRadius = 0, monsters = { 90312,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340205] = {	id = 340205, pos = { x = 0.0, y = 0.3588619, z = 36.73865 }, randomPos = 0, randomRadius = 0, monsters = { 90312,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340301] = {	id = 340301, pos = { x = -10.97604, y = 0.7586398, z = 40.39954 }, randomPos = 0, randomRadius = 0, monsters = { 90312,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340302] = {	id = 340302, pos = { x = -3.473181, y = 0.7505663, z = 40.9609 }, randomPos = 0, randomRadius = 0, monsters = { 90312,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340303] = {	id = 340303, pos = { x = -8.979491, y = 0.5408056, z = 44.45912 }, randomPos = 0, randomRadius = 0, monsters = { 90312,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340304] = {	id = 340304, pos = { x = -3.941504, y = 0.4399494, z = 47.00089 }, randomPos = 0, randomRadius = 0, monsters = { 90313,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340305] = {	id = 340305, pos = { x = -6.775056, y = 0.4974114, z = 46.18417 }, randomPos = 0, randomRadius = 0, monsters = { 90313,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[340306] = {	id = 340306, pos = { x = -7.804074, y = 0.4458585, z = 49.00136 }, randomPos = 0, randomRadius = 0, monsters = { 90313,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
