----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[460101] = {	id = 460101, pos = { x = 0.8527884, y = 6.235528, z = 2.927717 }, randomPos = 0, randomRadius = 0, monsters = { 90411,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460102] = {	id = 460102, pos = { x = 1.937121, y = 6.48466, z = 18.6905 }, randomPos = 0, randomRadius = 0, monsters = { 90411,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460103] = {	id = 460103, pos = { x = 0.0, y = 6.068433, z = 16.4379 }, randomPos = 0, randomRadius = 0, monsters = { 90411,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460104] = {	id = 460104, pos = { x = 7.47064, y = 6.446761, z = 16.82325 }, randomPos = 0, randomRadius = 0, monsters = { 90412,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460105] = {	id = 460105, pos = { x = 10.27941, y = 6.41458, z = 16.20238 }, randomPos = 0, randomRadius = 0, monsters = { 90412,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[460106] = {	id = 460106, pos = { x = 0.549591, y = 6.501535, z = 18.89831 }, randomPos = 0, randomRadius = 0, monsters = { 90412,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
