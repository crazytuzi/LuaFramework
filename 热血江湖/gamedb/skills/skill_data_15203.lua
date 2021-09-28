----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[15203] = {
		[1] = {events = {{triTime = 100, status = {{odds = 10000, buffID = 679, }, }, }, },},
		[2] = {needCoin = 30, events = {{triTime = 100, status = {{odds = 10000, buffID = 680, }, }, }, },},
		[3] = {needCoin = 50, events = {{triTime = 100, status = {{odds = 10000, buffID = 681, }, }, }, },},
		[4] = {needCoin = 100, events = {{triTime = 100, status = {{odds = 10000, buffID = 682, }, }, }, },},
		[5] = {needCoin = 200, events = {{triTime = 100, status = {{odds = 10000, buffID = 683, }, }, }, },},
	},

};
function get_db_table()
	return level;
end
