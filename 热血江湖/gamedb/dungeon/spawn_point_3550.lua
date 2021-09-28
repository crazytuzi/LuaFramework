----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[710101] = {	id = 710101, pos = { x = -20.43138, y = 0.4378013, z = 7.489514 }, randomPos = 0, randomRadius = 0, monsters = { 93131,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710102] = {	id = 710102, pos = { x = -24.03672, y = 0.3857151, z = 7.994648 }, randomPos = 0, randomRadius = 0, monsters = { 93131,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710103] = {	id = 710103, pos = { x = -24.67569, y = 0.3857151, z = 7.600822 }, randomPos = 0, randomRadius = 0, monsters = { 93133,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710104] = {	id = 710104, pos = { x = -24.09072, y = 0.3857151, z = 6.255853 }, randomPos = 0, randomRadius = 0, monsters = { 93133,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710105] = {	id = 710105, pos = { x = -24.46058, y = 0.3857151, z = 5.141614 }, randomPos = 0, randomRadius = 0, monsters = { 93134,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[710106] = {	id = 710106, pos = { x = -24.16602, y = 0.3857151, z = 9.551607 }, randomPos = 0, randomRadius = 0, monsters = { 93134,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
