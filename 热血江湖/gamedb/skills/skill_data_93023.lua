----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[93023] = {
		[1] = {cool = 8000, events = {{triTime = 800, damage = {odds = 10000, atrType = 1, arg1 = 1.5, }, }, {triTime = 1050, damage = {odds = 10000, atrType = 1, arg1 = 1.3, }, }, },},
	},

};
function get_db_table()
	return level;
end
