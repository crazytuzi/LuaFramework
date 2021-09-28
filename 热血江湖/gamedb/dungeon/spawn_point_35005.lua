----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[7001101] = {	id = 7001101, pos = { x = 128.3801, y = 7.434466, z = -82.16456 }, randomPos = 1, randomRadius = 600, monsters = { 131001,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7001102] = {	id = 7001102, pos = { x = 164.8921, y = 7.834466, z = 27.81448 }, randomPos = 1, randomRadius = 600, monsters = { 131002,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7001103] = {	id = 7001103, pos = { x = 123.6159, y = 7.434466, z = 95.58852 }, randomPos = 1, randomRadius = 600, monsters = { 131003,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7001104] = {	id = 7001104, pos = { x = 31.08231, y = 7.434466, z = 127.0138 }, randomPos = 1, randomRadius = 600, monsters = { 131004,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7001105] = {	id = 7001105, pos = { x = 69.32014, y = 17.46605, z = 13.42181 }, randomPos = 1, randomRadius = 600, monsters = { 131005,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7001106] = {	id = 7001106, pos = { x = 6.706505, y = 17.30786, z = -6.477171 }, randomPos = 1, randomRadius = 600, monsters = { 131006,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7001107] = {	id = 7001107, pos = { x = -69.96588, y = 24.63447, z = 43.94202 }, randomPos = 1, randomRadius = 600, monsters = { 131007,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7001108] = {	id = 7001108, pos = { x = -47.00161, y = 25.17056, z = 97.16193 }, randomPos = 1, randomRadius = 600, monsters = { 131008,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7001109] = {	id = 7001109, pos = { x = -43.54765, y = 16.9485, z = -133.7606 }, randomPos = 1, randomRadius = 600, monsters = { 131009,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[7001110] = {	id = 7001110, pos = { x = 33.25965, y = 16.68578, z = -106.7389 }, randomPos = 1, randomRadius = 600, monsters = { 131010,  }, spawnType = 3, spawnDTime = 1000, spawnTimes = -1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
