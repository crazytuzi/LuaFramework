----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[96101] = {	id = 96101, pos = { x = -104.8336, y = 3.571008, z = 75.10916 }, randomPos = 1, randomRadius = 500, monsters = { 480001,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[96102] = {	id = 96102, pos = { x = -24.22544, y = 8.426181, z = 78.09756 }, randomPos = 1, randomRadius = 500, monsters = { 480002,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[96103] = {	id = 96103, pos = { x = 61.33455, y = 3.174681, z = 91.09904 }, randomPos = 1, randomRadius = 500, monsters = { 480003,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[96104] = {	id = 96104, pos = { x = 77.7655, y = 3.290803, z = 51.87704 }, randomPos = 1, randomRadius = 500, monsters = { 480004,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[96105] = {	id = 96105, pos = { x = 56.92423, y = 20.79676, z = 40.64019 }, randomPos = 1, randomRadius = 500, monsters = { 480005,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[96106] = {	id = 96106, pos = { x = -30.61583, y = 17.3486, z = 23.49724 }, randomPos = 1, randomRadius = 500, monsters = { 480006,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[96107] = {	id = 96107, pos = { x = -1.321827, y = 7.682753, z = -92.64647 }, randomPos = 1, randomRadius = 500, monsters = { 480007,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[96108] = {	id = 96108, pos = { x = -95.21996, y = 8.026529, z = -21.23097 }, randomPos = 1, randomRadius = 500, monsters = { 480008,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[96109] = {	id = 96109, pos = { x = 7.49031, y = 16.17469, z = -34.48065 }, randomPos = 1, randomRadius = 500, monsters = { 480009,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[96110] = {	id = 96110, pos = { x = 122.224, y = 30.17469, z = 105.128 }, randomPos = 1, randomRadius = 500, monsters = { 480010,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
