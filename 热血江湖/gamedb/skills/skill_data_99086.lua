----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99086] = {
		[1] = {cool = 6000, events = {{triTime = 750, hitEffID = 30992, hitSoundID = 10, damage = {odds = 10000, arg1 = 4.0, }, }, {triTime = 1300, hitEffID = 30138, hitSoundID = 10, damage = {odds = 10000, arg1 = 2.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
