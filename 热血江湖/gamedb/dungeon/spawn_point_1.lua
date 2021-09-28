----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[301] = {	id = 301, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 0, randomRadius = 0, monsters = { 60301,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[302] = {	id = 302, pos = { x = -0.4404411, y = 6.419428, z = -8.96093 }, randomPos = 0, randomRadius = 0, monsters = { 60302,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[303] = {	id = 303, pos = { x = 7.386705, y = 6.322705, z = -9.86334 }, randomPos = 0, randomRadius = 0, monsters = { 60303,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[304] = {	id = 304, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 0, randomRadius = 0, monsters = { 60304,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[311] = {	id = 311, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 0, randomRadius = 0, monsters = { 60311,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[312] = {	id = 312, pos = { x = -0.4404411, y = 6.419428, z = -8.96093 }, randomPos = 0, randomRadius = 0, monsters = { 60312,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[313] = {	id = 313, pos = { x = 7.386705, y = 6.322705, z = -9.86334 }, randomPos = 0, randomRadius = 0, monsters = { 60313,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[314] = {	id = 314, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 0, randomRadius = 0, monsters = { 60314,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[321] = {	id = 321, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 0, randomRadius = 0, monsters = { 60321,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[322] = {	id = 322, pos = { x = -0.4404411, y = 6.419428, z = -8.96093 }, randomPos = 0, randomRadius = 0, monsters = { 60322,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[323] = {	id = 323, pos = { x = 7.386705, y = 6.322705, z = -9.86334 }, randomPos = 0, randomRadius = 0, monsters = { 60323,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[324] = {	id = 324, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 0, randomRadius = 0, monsters = { 60324,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[331] = {	id = 331, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 0, randomRadius = 0, monsters = { 60331,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[332] = {	id = 332, pos = { x = -0.4404411, y = 6.419428, z = -8.96093 }, randomPos = 0, randomRadius = 0, monsters = { 60332,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[333] = {	id = 333, pos = { x = 7.386705, y = 6.322705, z = -9.86334 }, randomPos = 0, randomRadius = 0, monsters = { 60333,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[334] = {	id = 334, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 0, randomRadius = 0, monsters = { 60334,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[341] = {	id = 341, pos = { x = 2.516903, y = 6.401385, z = -13.69057 }, randomPos = 0, randomRadius = 0, monsters = { 60341,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[342] = {	id = 342, pos = { x = -0.4404411, y = 6.419428, z = -8.96093 }, randomPos = 0, randomRadius = 0, monsters = { 60342,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[343] = {	id = 343, pos = { x = 7.386705, y = 6.322705, z = -9.86334 }, randomPos = 0, randomRadius = 0, monsters = { 60343,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[344] = {	id = 344, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 0, randomRadius = 0, monsters = { 60344,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[351] = {	id = 351, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 0, randomRadius = 0, monsters = { 60351,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[352] = {	id = 352, pos = { x = -0.4404411, y = 6.419428, z = -8.96093 }, randomPos = 0, randomRadius = 0, monsters = { 60352,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[353] = {	id = 353, pos = { x = 7.386705, y = 6.322705, z = -9.86334 }, randomPos = 0, randomRadius = 0, monsters = { 60353,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[354] = {	id = 354, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 0, randomRadius = 0, monsters = { 60354,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[361] = {	id = 361, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 0, randomRadius = 0, monsters = { 60361,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[362] = {	id = 362, pos = { x = -0.4404411, y = 6.419428, z = -8.96093 }, randomPos = 0, randomRadius = 0, monsters = { 60362,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[363] = {	id = 363, pos = { x = 7.386705, y = 6.322705, z = -9.86334 }, randomPos = 0, randomRadius = 0, monsters = { 60363,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[364] = {	id = 364, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 0, randomRadius = 0, monsters = { 60364,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[371] = {	id = 371, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 0, randomRadius = 0, monsters = { 60371,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[372] = {	id = 372, pos = { x = -0.4404411, y = 6.419428, z = -8.96093 }, randomPos = 0, randomRadius = 0, monsters = { 60372,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[373] = {	id = 373, pos = { x = 7.386705, y = 6.322705, z = -9.86334 }, randomPos = 0, randomRadius = 0, monsters = { 60373,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[374] = {	id = 374, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 0, randomRadius = 0, monsters = { 60374,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[381] = {	id = 381, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 0, randomRadius = 0, monsters = { 60381,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[382] = {	id = 382, pos = { x = -0.4404411, y = 6.419428, z = -8.96093 }, randomPos = 0, randomRadius = 0, monsters = { 60382,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[383] = {	id = 383, pos = { x = 7.386705, y = 6.322705, z = -9.86334 }, randomPos = 0, randomRadius = 0, monsters = { 60383,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[384] = {	id = 384, pos = { x = 3.781727, y = 6.382332, z = -13.48037 }, randomPos = 0, randomRadius = 0, monsters = { 60384,  }, spawnType = 1, spawnDTime = 15000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
