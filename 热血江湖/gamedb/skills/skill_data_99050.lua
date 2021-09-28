----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99050] = {
		[1] = {cool = 5000, events = {{triTime = 1100, hitEffID = 30250, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.4, }, }, },},
	},

};
function get_db_table()
	return level;
end
