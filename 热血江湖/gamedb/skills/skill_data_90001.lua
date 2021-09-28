----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[90001] = {
		[1] = {events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 216, }, }, }, },},
		[2] = {studyLvl = 2, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 217, }, }, }, },},
		[3] = {studyLvl = 3, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 218, }, }, }, },},
		[4] = {studyLvl = 4, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 219, }, }, }, },},
		[5] = {studyLvl = 5, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 220, }, }, }, },},
		[6] = {studyLvl = 5, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 221, }, }, }, },},
		[7] = {studyLvl = 5, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 222, }, }, }, },},
		[8] = {studyLvl = 5, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 223, }, }, }, },},
		[9] = {studyLvl = 5, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 224, }, }, }, },},
		[10] = {studyLvl = 5, events = {{triTime = 100, damage = {atrType = 1, }, status = {{odds = 10000, buffID = 225, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
