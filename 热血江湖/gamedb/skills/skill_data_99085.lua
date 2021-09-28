----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99085] = {
		[1] = {cool = 4000, events = {{triTime = 1050, hitEffID = 30992, hitSoundID = 2, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
