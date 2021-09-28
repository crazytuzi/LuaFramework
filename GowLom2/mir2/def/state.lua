local states = {
	csTmpSC = 14,
	stNil_UsedByClient = 2,
	csTmpMaxMP = 17,
	csTmpMaxHP = 16,
	stACShield = 7,
	stStone = 0,
	stAntiDebuffCD = 33,
	csTmpMH = 25,
	stAlwaysShowName = 1,
	csTmpDCSpeed = 15,
	stNoDieCD = 31,
	csRevenge = 22,
	csTmpAC = 20,
	stPoisonBlue = 26,
	stMagicShield = 5,
	stPoisonStone2 = 27,
	stAntiIce = 28,
	stWEBS = 9,
	stPoisonStone = 10,
	stAntiNumb = 29,
	csTmpAM = 19,
	stReleaseStone = 4,
	stCeleb = 24,
	stMACShield = 6,
	stNoDie = 30,
	stManaProtected = 3,
	csTmpMAC = 21,
	csWJZQ = 23,
	stAntiDebuff = 32,
	csTmpQR = 18,
	stPoisonGreen = 11,
	stHidden = 8
}
local stateEffect = {
	DAMAGE_NO_DEBUFF = 7,
	DAMAGE_EFFECT_ICE = 0,
	DAMAGE_EFFECT_NUMB = 1,
	DAMAGE_EFFECT_SHIELD = 4,
	DAMAGE_EFFECT_MISS = 5,
	DAMAGE_NO_DIE = 6
}
local def = {
	stateEffect = stateEffect,
	stateHas = function (state, key)
		if not state then
			return false
		elseif type(state) == "number" then
			return states[key] == state
		else
			for k, v in pairs(state) do
				if v == states[key] then
					return true
				end
			end

			return false
		end

		return 
	end,
	isRoleStone = function (state)
		return def.stateHas(state, "stPoisonStone") or def.stateHas(state, "stPoisonStone2")
	end
}

return def
