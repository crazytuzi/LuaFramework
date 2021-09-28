----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[720101] = {	id = 720101, pos = { x = 17.67808, y = 25.2, z = 28.24665 }, randomPos = 0, randomRadius = 0, monsters = { 94101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720102] = {	id = 720102, pos = { x = 15.40523, y = 25.28661, z = 15.45189 }, randomPos = 0, randomRadius = 0, monsters = { 94101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720103] = {	id = 720103, pos = { x = 17.33345, y = 25.25152, z = 19.11258 }, randomPos = 0, randomRadius = 0, monsters = { 94101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[720104] = {	id = 720104, pos = { x = 18.8678, y = 25.22352, z = 22.06199 }, randomPos = 0, randomRadius = 0, monsters = { 94101,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
