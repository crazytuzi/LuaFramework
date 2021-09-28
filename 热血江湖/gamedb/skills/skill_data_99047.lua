----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[99047] = {
		[1] = {cool = 7000, events = {{triTime = 475, hitEffID = 30235, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.82, }, }, {triTime = 975, hitEffID = 30235, hitSoundID = 14, damage = {odds = 10000, arg1 = 0.82, }, }, },},
	},

};
function get_db_table()
	return level;
end
