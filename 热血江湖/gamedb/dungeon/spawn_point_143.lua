----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[28601] = {	id = 28601, pos = { x = -99.1288, y = 8.025538, z = -102.4468 }, randomPos = 1, randomRadius = 200, monsters = { 87307,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28602] = {	id = 28602, pos = { x = -8.866747, y = 11.9237, z = 31.38043 }, randomPos = 1, randomRadius = 200, monsters = { 87307,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28603] = {	id = 28603, pos = { x = 45.33363, y = 10.92653, z = -22.07375 }, randomPos = 1, randomRadius = 200, monsters = { 87307,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28604] = {	id = 28604, pos = { x = 19.20001, y = 11.92096, z = 33.46636 }, randomPos = 1, randomRadius = 200, monsters = { 87307,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28701] = {	id = 28701, pos = { x = -99.1288, y = 8.025538, z = -102.4468 }, randomPos = 1, randomRadius = 500, monsters = { 87308,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28702] = {	id = 28702, pos = { x = 25.79156, y = 8.437611, z = -106.1419 }, randomPos = 1, randomRadius = 500, monsters = { 87308,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28703] = {	id = 28703, pos = { x = 45.33363, y = 10.92653, z = -22.07375 }, randomPos = 1, randomRadius = 500, monsters = { 87308,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28704] = {	id = 28704, pos = { x = 19.20001, y = 11.92096, z = 33.46636 }, randomPos = 1, randomRadius = 500, monsters = { 87308,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28705] = {	id = 28705, pos = { x = 80.02905, y = 11.32653, z = 30.52947 }, randomPos = 1, randomRadius = 500, monsters = { 87308,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[28706] = {	id = 28706, pos = { x = -72.7238, y = 12.92653, z = 38.8407 }, randomPos = 1, randomRadius = 500, monsters = { 87308,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
