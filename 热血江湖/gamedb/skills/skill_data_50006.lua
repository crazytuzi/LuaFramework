----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[50006] = {
		[1] = {events = {{triTime = 100, hitEffID = 30094, status = {{odds = 10000, buffID = 38, }, }, }, },},
		[2] = {events = {{triTime = 100, hitEffID = 30094, status = {{odds = 10000, buffID = 39, }, }, }, },},
		[3] = {events = {{triTime = 100, hitEffID = 30094, status = {{odds = 10000, buffID = 40, }, }, }, },},
		[4] = {events = {{triTime = 100, hitEffID = 30094, status = {{odds = 10000, buffID = 41, }, }, }, },},
		[5] = {events = {{triTime = 100, hitEffID = 30094, status = {{odds = 10000, buffID = 42, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
