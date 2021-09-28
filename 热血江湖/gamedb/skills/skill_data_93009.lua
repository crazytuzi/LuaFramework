----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93009] = {
		[1] = {cool = 30000, events = {{triTime = 500, damage = {odds = 10000, atrType = 1, arg1 = 2.5, }, }, {triTime = 1250, damage = {odds = 10000, atrType = 1, arg1 = 2.5, }, }, {triTime = 1950, damage = {odds = 10000, atrType = 1, arg1 = 2.5, }, }, },},
	},

};
function get_db_table()
	return level;
end
