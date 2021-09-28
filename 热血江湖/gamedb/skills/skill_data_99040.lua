----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99040] = {
		[1] = {cool = 5000, events = {{triTime = 800, hitEffID = 30213, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.48, arg2 = 1119.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
