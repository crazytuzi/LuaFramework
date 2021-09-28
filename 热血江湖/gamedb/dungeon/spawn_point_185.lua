----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[37001] = {	id = 37001, pos = { x = -121.2083, y = 2.239738, z = -33.08291 }, randomPos = 1, randomRadius = 500, monsters = { 87701,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37002] = {	id = 37002, pos = { x = -54.28321, y = 5.082024, z = -9.61869 }, randomPos = 1, randomRadius = 500, monsters = { 87701,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37003] = {	id = 37003, pos = { x = -8.134979, y = 10.19859, z = -12.51948 }, randomPos = 1, randomRadius = 500, monsters = { 87701,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37004] = {	id = 37004, pos = { x = 53.22469, y = 17.17648, z = 78.72085 }, randomPos = 1, randomRadius = 500, monsters = { 87701,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37005] = {	id = 37005, pos = { x = 31.46379, y = 17.08202, z = 126.166 }, randomPos = 1, randomRadius = 500, monsters = { 87701,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37006] = {	id = 37006, pos = { x = -29.56939, y = 17.26768, z = 124.4688 }, randomPos = 1, randomRadius = 500, monsters = { 87701,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37007] = {	id = 37007, pos = { x = 128.5969, y = 20.08202, z = 36.31819 }, randomPos = 1, randomRadius = 500, monsters = { 87701,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37008] = {	id = 37008, pos = { x = 53.55507, y = 10.08202, z = -58.97569 }, randomPos = 1, randomRadius = 500, monsters = { 87701,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37009] = {	id = 37009, pos = { x = -11.54498, y = 0.0820236, z = -158.8184 }, randomPos = 1, randomRadius = 500, monsters = { 87701,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37010] = {	id = 37010, pos = { x = -38.06936, y = 3.082024, z = -88.81782 }, randomPos = 1, randomRadius = 500, monsters = { 87701,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37101] = {	id = 37101, pos = { x = -24.51875, y = 3.082024, z = -100.4613 }, randomPos = 1, randomRadius = 500, monsters = { 87702,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37102] = {	id = 37102, pos = { x = 4.019127, y = 5.082024, z = -86.02377 }, randomPos = 1, randomRadius = 500, monsters = { 87702,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37103] = {	id = 37103, pos = { x = 20.80551, y = 3.082024, z = -125.2773 }, randomPos = 1, randomRadius = 500, monsters = { 87702,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37104] = {	id = 37104, pos = { x = 8.560345, y = 12.08202, z = 13.97932 }, randomPos = 1, randomRadius = 500, monsters = { 87702,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37105] = {	id = 37105, pos = { x = -20.63852, y = 17.41112, z = 91.44977 }, randomPos = 1, randomRadius = 500, monsters = { 87702,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[37106] = {	id = 37106, pos = { x = 174.4443, y = 26.08202, z = 60.32961 }, randomPos = 1, randomRadius = 500, monsters = { 87702,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
