----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[1005102] = {
		[1] = {cool = 6000, events = {{triTime = 650, hitEffID = 30897, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 15000.0, }, }, },},
	},
	[1005101] = {
		[1] = {cool = 6000, events = {{triTime = 450, hitEffID = 30889, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, {triTime = 575, hitEffID = 30889, hitSoundID = 10, damage = {odds = 10000, arg1 = 0.01, arg2 = 7500.0, }, }, },},
	},

};
function get_db_table()
	return level;
end
