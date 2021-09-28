----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[660401] = {	id = 660401, pos = { x = -35.34278, y = 28.79218, z = 120.5322 }, randomPos = 0, randomRadius = 0, monsters = { 92111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660402] = {	id = 660402, pos = { x = -43.79662, y = 28.79218, z = 111.1548 }, randomPos = 0, randomRadius = 0, monsters = { 92111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660403] = {	id = 660403, pos = { x = -46.99738, y = 28.79218, z = 133.2724 }, randomPos = 0, randomRadius = 0, monsters = { 92111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660404] = {	id = 660404, pos = { x = -37.55518, y = 28.79218, z = 129.7455 }, randomPos = 0, randomRadius = 0, monsters = { 92111,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660405] = {	id = 660405, pos = { x = -37.45556, y = 28.79218, z = 113.3651 }, randomPos = 0, randomRadius = 0, monsters = { 92113,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660406] = {	id = 660406, pos = { x = -53.75225, y = 28.79218, z = 131.1336 }, randomPos = 0, randomRadius = 0, monsters = { 92113,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660407] = {	id = 660407, pos = { x = -49.99467, y = 28.79218, z = 111.6784 }, randomPos = 0, randomRadius = 0, monsters = { 92115,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660408] = {	id = 660408, pos = { x = -35.05676, y = 28.79218, z = 114.7322 }, randomPos = 0, randomRadius = 0, monsters = { 92115,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660409] = {	id = 660409, pos = { x = -44.06837, y = 28.79218, z = 133.9934 }, randomPos = 0, randomRadius = 0, monsters = { 92115,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[660410] = {	id = 660410, pos = { x = -45.71231, y = 28.79218, z = 121.0464 }, randomPos = 0, randomRadius = 0, monsters = { 92114,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
