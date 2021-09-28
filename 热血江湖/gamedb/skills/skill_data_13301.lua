----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[13301] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 169, }, }, }, },},
		[2] = {studyLvl = 2, events = {{triTime = 100, status = {{odds = 10000, buffID = 170, }, }, }, },},
		[3] = {studyLvl = 3, events = {{triTime = 100, status = {{odds = 10000, buffID = 171, }, }, }, },},
		[4] = {studyLvl = 4, events = {{triTime = 100, status = {{odds = 10000, buffID = 172, }, }, }, },},
		[5] = {studyLvl = 5, events = {{triTime = 100, status = {{odds = 10000, buffID = 173, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
