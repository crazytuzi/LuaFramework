----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[91018] = {
		[1] = {cool = 1000, events = {{triTime = 500, hitEffID = 30916, hitSoundID = 3, damage = {odds = 10000, atrType = 1, arg1 = 0.625, arg2 = 53.0, realmAddon = 0.05, }, }, {triTime = 1000, hitEffID = 30916, hitSoundID = 3, damage = {odds = 10000, atrType = 1, arg1 = 0.75, arg2 = 63.0, realmAddon = 0.05, }, }, },},
	},

};
function get_db_table()
	return level;
end
