----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[10002] = {
		[1] = {events = {{triTime = 125, hitEffID = 30140, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.6, }, }, },},
	},

};
function get_db_table()
	return level;
end
