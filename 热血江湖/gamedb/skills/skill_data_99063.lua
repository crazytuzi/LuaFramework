----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99063] = {
		[1] = {events = {{triTime = 550, hitEffID = 30178, hitSoundID = 14, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
