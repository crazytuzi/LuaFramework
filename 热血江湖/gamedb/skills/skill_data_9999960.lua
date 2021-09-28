----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local level = 
{
	[9999999] = {
		[1] = { studyLvl = 1, needCoin = 0, needItemID = 0, needItemNum = 0, needMP = 0, addSP = 0, cool = 0, events = { { triTime = 100, hitEffID = 30129, useEffID = 0, hitSoundID = 14, damage = { odds = 10000, atrType = 0, acrType = 0, arg1 = 1.0, arg2 = 10.0, realmAddon = 0.0 }, status = { { odds = 0, buffID = 0 }, { odds = 0, buffID = 0 },  } }, { triTime = 0, hitEffID = 0, useEffID = 0, hitSoundID = 0, damage = { odds = 0, atrType = 0, acrType = 0, arg1 = 0.0, arg2 = 0.0, realmAddon = 0.0 }, status = { { odds = 0, buffID = 0 }, { odds = 0, buffID = 0 },  } }, { triTime = 0, hitEffID = 0, useEffID = 0, hitSoundID = 0, damage = { odds = 0, atrType = 0, acrType = 0, arg1 = 0.0, arg2 = 0.0, realmAddon = 0.0 }, status = { { odds = 0, buffID = 0 }, { odds = 0, buffID = 0 },  } },  }, skillpower = 0, skillrealpower = { 0, 0, 0, 0, 0,  }, spArgs1 = '', spArgs2 = '', spArgs3 = '', spArgs4 = '', spArgs5 = '', additionalDamage = 0, additionalProp = {}, additionalAiID = {}, auraAddBuffs = {}, inheritRatio = 0, summonedPopId = 0, summonedSkill = { 0, 0, 0, 0, 0,  }},
	},

};
function get_db_table()
	return level;
end
