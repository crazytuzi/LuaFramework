----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[480101] = {	id = 480101, pos = { x = -1.015974, y = 6.471603, z = 11.886 }, randomPos = 0, randomRadius = 0, monsters = { 90431,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480102] = {	id = 480102, pos = { x = 3.080342, y = 6.438322, z = 19.30554 }, randomPos = 0, randomRadius = 0, monsters = { 90431,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480103] = {	id = 480103, pos = { x = -3.072895, y = 6.435765, z = 19.33212 }, randomPos = 0, randomRadius = 0, monsters = { 90431,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480104] = {	id = 480104, pos = { x = 0.0, y = 6.044888, z = 20.205 }, randomPos = 0, randomRadius = 0, monsters = { 90431,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480105] = {	id = 480105, pos = { x = 2.90073, y = 6.396435, z = 20.40085 }, randomPos = 0, randomRadius = 0, monsters = { 90431,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480106] = {	id = 480106, pos = { x = 5.658316, y = 6.324897, z = 20.90907 }, randomPos = 0, randomRadius = 0, monsters = { 90432,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480107] = {	id = 480107, pos = { x = 7.406713, y = 6.357002, z = 19.2154 }, randomPos = 0, randomRadius = 0, monsters = { 90432,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480108] = {	id = 480108, pos = { x = 9.974225, y = 6.317111, z = 18.9231 }, randomPos = 0, randomRadius = 0, monsters = { 90432,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480109] = {	id = 480109, pos = { x = 10.92578, y = 6.307215, z = 18.31397 }, randomPos = 0, randomRadius = 0, monsters = { 90432,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[480110] = {	id = 480110, pos = { x = 1.100219, y = 6.320075, z = 6.099768 }, randomPos = 0, randomRadius = 0, monsters = { 90432,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
