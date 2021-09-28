----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[750201] = {	id = 750201, pos = { x = -5.063188, y = 32.10902, z = -76.84724 }, randomPos = 0, randomRadius = 0, monsters = { 94202,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750202] = {	id = 750202, pos = { x = -2.809321, y = 32.10902, z = -74.65067 }, randomPos = 0, randomRadius = 0, monsters = { 94202,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750203] = {	id = 750203, pos = { x = 1.245964, y = 32.10902, z = -74.97948 }, randomPos = 0, randomRadius = 0, monsters = { 94202,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750204] = {	id = 750204, pos = { x = -2.116209, y = 32.10902, z = -76.3325 }, randomPos = 0, randomRadius = 0, monsters = { 94204,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750301] = {	id = 750301, pos = { x = -3.069938, y = 37.70901, z = -25.35605 }, randomPos = 0, randomRadius = 0, monsters = { 94203,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750302] = {	id = 750302, pos = { x = 0.3033235, y = 37.70901, z = -25.12433 }, randomPos = 0, randomRadius = 0, monsters = { 94203,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750303] = {	id = 750303, pos = { x = -4.956987, y = 37.70901, z = -24.39829 }, randomPos = 0, randomRadius = 0, monsters = { 94203,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750304] = {	id = 750304, pos = { x = 2.138496, y = 37.70901, z = -23.9109 }, randomPos = 0, randomRadius = 0, monsters = { 94203,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[750305] = {	id = 750305, pos = { x = -0.8537277, y = 37.70901, z = -23.22298 }, randomPos = 0, randomRadius = 0, monsters = { 94205,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
