----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_point = 
{
	[43401] = {	id = 43401, pos = { x = -22.09304, y = 9.163523, z = 46.33497 }, randomPos = 0, randomRadius = 600, monsters = { 65401,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43402] = {	id = 43402, pos = { x = -22.9626, y = 8.989296, z = 55.60693 }, randomPos = 0, randomRadius = 600, monsters = { 65402,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43411] = {	id = 43411, pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, randomPos = 1, randomRadius = 600, monsters = { 65411,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43412] = {	id = 43412, pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, randomPos = 1, randomRadius = 600, monsters = { 65412,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43413] = {	id = 43413, pos = { x = 1.827212, y = -11.22577, z = -4.592784 }, randomPos = 1, randomRadius = 600, monsters = { 65411,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43414] = {	id = 43414, pos = { x = 1.038051, y = -11.17081, z = 1.988159 }, randomPos = 1, randomRadius = 600, monsters = { 65412,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43421] = {	id = 43421, pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, randomPos = 1, randomRadius = 600, monsters = { 65421,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43422] = {	id = 43422, pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, randomPos = 1, randomRadius = 600, monsters = { 65422,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43423] = {	id = 43423, pos = { x = 1.827212, y = -11.22577, z = -4.592784 }, randomPos = 1, randomRadius = 600, monsters = { 65421,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43424] = {	id = 43424, pos = { x = 1.038051, y = -11.17081, z = 1.988159 }, randomPos = 1, randomRadius = 600, monsters = { 65422,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43431] = {	id = 43431, pos = { x = -7.494146, y = 6.364571, z = -12.08766 }, randomPos = 1, randomRadius = 600, monsters = { 65431,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43432] = {	id = 43432, pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, randomPos = 1, randomRadius = 600, monsters = { 65432,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43433] = {	id = 43433, pos = { x = 12.10232, y = 6.364571, z = -6.277208 }, randomPos = 1, randomRadius = 600, monsters = { 65431,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43434] = {	id = 43434, pos = { x = -0.3911991, y = 6.364571, z = 0.3233595 }, randomPos = 1, randomRadius = 600, monsters = { 65432,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43441] = {	id = 43441, pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, randomPos = 1, randomRadius = 600, monsters = { 65441,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43442] = {	id = 43442, pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, randomPos = 1, randomRadius = 600, monsters = { 65442,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43443] = {	id = 43443, pos = { x = 1.827212, y = -11.22577, z = -4.592784 }, randomPos = 1, randomRadius = 600, monsters = { 65441,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43444] = {	id = 43444, pos = { x = 1.038051, y = -11.17081, z = 1.988159 }, randomPos = 1, randomRadius = 600, monsters = { 65442,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43451] = {	id = 43451, pos = { x = -22.09304, y = 9.163523, z = 46.33497 }, randomPos = 0, randomRadius = 600, monsters = { 65451,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43452] = {	id = 43452, pos = { x = -22.9626, y = 8.989296, z = 55.60693 }, randomPos = 0, randomRadius = 600, monsters = { 65452,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43461] = {	id = 43461, pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, randomPos = 1, randomRadius = 600, monsters = { 65461,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43462] = {	id = 43462, pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, randomPos = 1, randomRadius = 600, monsters = { 65462,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43463] = {	id = 43463, pos = { x = 1.827212, y = -11.22577, z = -4.592784 }, randomPos = 1, randomRadius = 600, monsters = { 65461,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43464] = {	id = 43464, pos = { x = 1.038051, y = -11.17081, z = 1.988159 }, randomPos = 1, randomRadius = 600, monsters = { 65462,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43471] = {	id = 43471, pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, randomPos = 1, randomRadius = 600, monsters = { 65471,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43472] = {	id = 43472, pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, randomPos = 1, randomRadius = 600, monsters = { 65472,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43473] = {	id = 43473, pos = { x = 1.827212, y = -11.22577, z = -4.592784 }, randomPos = 1, randomRadius = 600, monsters = { 65471,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43474] = {	id = 43474, pos = { x = 1.038051, y = -11.17081, z = 1.988159 }, randomPos = 1, randomRadius = 600, monsters = { 65472,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43481] = {	id = 43481, pos = { x = -7.494146, y = 6.364571, z = -12.08766 }, randomPos = 1, randomRadius = 600, monsters = { 65481,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43482] = {	id = 43482, pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, randomPos = 1, randomRadius = 600, monsters = { 65482,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43483] = {	id = 43483, pos = { x = 12.10232, y = 6.364571, z = -6.277208 }, randomPos = 1, randomRadius = 600, monsters = { 65481,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43484] = {	id = 43484, pos = { x = -0.3911991, y = 6.364571, z = 0.3233595 }, randomPos = 1, randomRadius = 600, monsters = { 65482,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43491] = {	id = 43491, pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, randomPos = 1, randomRadius = 600, monsters = { 65491,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43492] = {	id = 43492, pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, randomPos = 1, randomRadius = 600, monsters = { 65492,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43493] = {	id = 43493, pos = { x = 1.827212, y = -11.22577, z = -4.592784 }, randomPos = 1, randomRadius = 600, monsters = { 65491,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43494] = {	id = 43494, pos = { x = 1.038051, y = -11.17081, z = 1.988159 }, randomPos = 1, randomRadius = 600, monsters = { 65492,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43501] = {	id = 43501, pos = { x = -22.09304, y = 9.163523, z = 46.33497 }, randomPos = 0, randomRadius = 600, monsters = { 65501,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43502] = {	id = 43502, pos = { x = -22.9626, y = 8.989296, z = 55.60693 }, randomPos = 0, randomRadius = 600, monsters = { 65502,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43511] = {	id = 43511, pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, randomPos = 1, randomRadius = 600, monsters = { 65511,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43512] = {	id = 43512, pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, randomPos = 1, randomRadius = 600, monsters = { 65512,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43513] = {	id = 43513, pos = { x = 1.827212, y = -11.22577, z = -4.592784 }, randomPos = 1, randomRadius = 600, monsters = { 65511,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43514] = {	id = 43514, pos = { x = 1.038051, y = -11.17081, z = 1.988159 }, randomPos = 1, randomRadius = 600, monsters = { 65512,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43521] = {	id = 43521, pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, randomPos = 1, randomRadius = 600, monsters = { 65521,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43522] = {	id = 43522, pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, randomPos = 1, randomRadius = 600, monsters = { 65522,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43523] = {	id = 43523, pos = { x = 1.827212, y = -11.22577, z = -4.592784 }, randomPos = 1, randomRadius = 600, monsters = { 65521,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43524] = {	id = 43524, pos = { x = 1.038051, y = -11.17081, z = 1.988159 }, randomPos = 1, randomRadius = 600, monsters = { 65522,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43531] = {	id = 43531, pos = { x = -7.494146, y = 6.364571, z = -12.08766 }, randomPos = 1, randomRadius = 600, monsters = { 65531,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43532] = {	id = 43532, pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, randomPos = 1, randomRadius = 600, monsters = { 65532,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43533] = {	id = 43533, pos = { x = 12.10232, y = 6.364571, z = -6.277208 }, randomPos = 1, randomRadius = 600, monsters = { 65531,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43534] = {	id = 43534, pos = { x = -0.3911991, y = 6.364571, z = 0.3233595 }, randomPos = 1, randomRadius = 600, monsters = { 65532,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43541] = {	id = 43541, pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, randomPos = 1, randomRadius = 600, monsters = { 65541,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43542] = {	id = 43542, pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, randomPos = 1, randomRadius = 600, monsters = { 65542,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43543] = {	id = 43543, pos = { x = 1.827212, y = -11.22577, z = -4.592784 }, randomPos = 1, randomRadius = 600, monsters = { 65541,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43544] = {	id = 43544, pos = { x = 1.038051, y = -11.17081, z = 1.988159 }, randomPos = 1, randomRadius = 600, monsters = { 65542,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43551] = {	id = 43551, pos = { x = -22.09304, y = 9.163523, z = 46.33497 }, randomPos = 0, randomRadius = 600, monsters = { 65551,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43552] = {	id = 43552, pos = { x = -22.9626, y = 8.989296, z = 55.60693 }, randomPos = 0, randomRadius = 600, monsters = { 65552,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 1, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43561] = {	id = 43561, pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, randomPos = 1, randomRadius = 600, monsters = { 65561,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43562] = {	id = 43562, pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, randomPos = 1, randomRadius = 600, monsters = { 65562,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43563] = {	id = 43563, pos = { x = 1.827212, y = -11.22577, z = -4.592784 }, randomPos = 1, randomRadius = 600, monsters = { 65561,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43564] = {	id = 43564, pos = { x = 1.038051, y = -11.17081, z = 1.988159 }, randomPos = 1, randomRadius = 600, monsters = { 65562,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43571] = {	id = 43571, pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, randomPos = 1, randomRadius = 600, monsters = { 65571,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43572] = {	id = 43572, pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, randomPos = 1, randomRadius = 600, monsters = { 65572,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43573] = {	id = 43573, pos = { x = 1.827212, y = -11.22577, z = -4.592784 }, randomPos = 1, randomRadius = 600, monsters = { 65571,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43574] = {	id = 43574, pos = { x = 1.038051, y = -11.17081, z = 1.988159 }, randomPos = 1, randomRadius = 600, monsters = { 65572,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43581] = {	id = 43581, pos = { x = -7.494146, y = 6.364571, z = -12.08766 }, randomPos = 1, randomRadius = 600, monsters = { 65581,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43582] = {	id = 43582, pos = { x = 4.808135, y = 6.364571, z = -18.34769 }, randomPos = 1, randomRadius = 600, monsters = { 65582,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 4, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43583] = {	id = 43583, pos = { x = 12.10232, y = 6.364571, z = -6.277208 }, randomPos = 1, randomRadius = 600, monsters = { 65581,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 5, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43584] = {	id = 43584, pos = { x = -0.3911991, y = 6.364571, z = 0.3233595 }, randomPos = 1, randomRadius = 600, monsters = { 65582,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 6, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43591] = {	id = 43591, pos = { x = -8.412131, y = -11.01789, z = 6.640036 }, randomPos = 1, randomRadius = 600, monsters = { 65591,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43592] = {	id = 43592, pos = { x = -7.897441, y = -11.0668, z = -4.988127 }, randomPos = 1, randomRadius = 600, monsters = { 65592,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43593] = {	id = 43593, pos = { x = 1.827212, y = -11.22577, z = -4.592784 }, randomPos = 1, randomRadius = 600, monsters = { 65591,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 2, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },
	[43594] = {	id = 43594, pos = { x = 1.038051, y = -11.17081, z = 1.988159 }, randomPos = 1, randomRadius = 600, monsters = { 65592,  }, spawnType = 1, spawnDTime = 1000, spawnTimes = 1, spawnNum = { { 3, }, { }, { }, { }, { }, { }, { }, { }, { }, }, faceType = 0, faceDir = { x = 0.0, y = 0.0, z = 0.0 } },

};
function get_db_table()
	return spawn_point;
end
