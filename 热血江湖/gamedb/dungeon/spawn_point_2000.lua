----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[400101] = {	id = 400101, pos = { x = 75.31384, y = 12.93796, z = -13.64459 }, randomPos = 0, randomRadius = 0, monsters = { 90511,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400102] = {	id = 400102, pos = { x = 74.45782, y = 12.93633, z = -12.33139 }, randomPos = 0, randomRadius = 0, monsters = { 90511,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[400103] = {	id = 400103, pos = { x = 76.71854, y = 12.95757, z = -12.36864 }, randomPos = 0, randomRadius = 0, monsters = { 90511,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
