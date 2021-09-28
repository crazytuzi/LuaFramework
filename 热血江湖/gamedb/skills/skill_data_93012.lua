----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93012] = {
		[1] = {cool = 6000, events = {{triTime = 375, damage = {odds = 10000, atrType = 1, arg1 = 1.1, }, }, {triTime = 950, damage = {odds = 10000, arg1 = 1.1, }, }, },},
	},

};
function get_db_table()
	return level;
end
