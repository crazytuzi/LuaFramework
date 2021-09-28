----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[35601] = {	id = 35601, pos = { x = -47.54869, y = 0.2000002, z = -98.15753 }, randomPos = 1, randomRadius = 200, monsters = { 87607,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35602] = {	id = 35602, pos = { x = -58.84715, y = 0.2000002, z = -122.0963 }, randomPos = 1, randomRadius = 200, monsters = { 87607,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35603] = {	id = 35603, pos = { x = -63.7086, y = 7.0, z = 32.71605 }, randomPos = 1, randomRadius = 200, monsters = { 87607,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35604] = {	id = 35604, pos = { x = 44.65744, y = 13.01655, z = 24.58949 }, randomPos = 1, randomRadius = 200, monsters = { 87607,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35701] = {	id = 35701, pos = { x = 59.21457, y = 13.09666, z = 18.27781 }, randomPos = 1, randomRadius = 500, monsters = { 87608,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35702] = {	id = 35702, pos = { x = 9.075985, y = 13.88154, z = 37.42899 }, randomPos = 1, randomRadius = 500, monsters = { 87608,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35703] = {	id = 35703, pos = { x = -48.20611, y = 7.0, z = 30.55955 }, randomPos = 1, randomRadius = 500, monsters = { 87608,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35704] = {	id = 35704, pos = { x = -92.52188, y = 7.0, z = 2.888041 }, randomPos = 1, randomRadius = 500, monsters = { 87608,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35705] = {	id = 35705, pos = { x = -38.62044, y = 5.073284, z = -35.80392 }, randomPos = 1, randomRadius = 500, monsters = { 87608,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[35706] = {	id = 35706, pos = { x = -41.62426, y = 0.2000002, z = -117.0427 }, randomPos = 1, randomRadius = 500, monsters = { 87608,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
