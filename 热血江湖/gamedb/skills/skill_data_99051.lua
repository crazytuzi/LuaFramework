----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99051] = {
		[1] = {cool = 7000, events = {{triTime = 1025, hitEffID = 30250, hitSoundID = 14, damage = {odds = 10000, arg1 = 1.5, }, }, },},
	},

};
function get_db_table()
	return level;
end
