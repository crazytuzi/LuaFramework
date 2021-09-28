----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[94013] = {
		[1] = {cool = 10000, events = {{triTime = 350, hitEffID = 30140, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.8, }, }, {triTime = 775, hitEffID = 30140, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.8, }, }, },},
	},

};
function get_db_table()
	return level;
end
