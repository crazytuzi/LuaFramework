----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[750801] = {	id = 750801, pos = { x = -3.069938, y = 37.70901, z = -25.35605 }, randomPos = 0, randomRadius = 0, monsters = { 94303,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750802] = {	id = 750802, pos = { x = 0.3033235, y = 37.70901, z = -25.12433 }, randomPos = 0, randomRadius = 0, monsters = { 94303,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750803] = {	id = 750803, pos = { x = -4.956987, y = 37.70901, z = -24.39829 }, randomPos = 0, randomRadius = 0, monsters = { 94303,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750804] = {	id = 750804, pos = { x = 2.138496, y = 37.70901, z = -23.9109 }, randomPos = 0, randomRadius = 0, monsters = { 94303,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750805] = {	id = 750805, pos = { x = -0.8537277, y = 37.70901, z = -23.22298 }, randomPos = 0, randomRadius = 0, monsters = { 94305,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750901] = {	id = 750901, pos = { x = -4.113502, y = 51.50901, z = 60.47458 }, randomPos = 0, randomRadius = 0, monsters = { 94306,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750902] = {	id = 750902, pos = { x = 3.424713, y = 51.50901, z = 59.74678 }, randomPos = 0, randomRadius = 0, monsters = { 94307,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750903] = {	id = 750903, pos = { x = -0.2450171, y = 51.50901, z = 52.93994 }, randomPos = 0, randomRadius = 0, monsters = { 94308,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
