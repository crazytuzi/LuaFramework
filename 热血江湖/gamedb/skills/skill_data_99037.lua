----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99037] = {
		[1] = {events = {{triTime = 475, hitEffID = 30418, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
