
--BUFFER_TYPE
BUFFER_TYPE_FREEZE   = 1 --冰冻
BUFFER_TYPE_STUN     = 2 --眩晕
BUFFER_TYPE_SEAL     = 3 --封印
BUFFER_TYPE_POISON   = 4 --中毒
BUFFER_TYPE_BURN     = 5 --灼烧
BUFFER_TYPE_CURSE    = 6 --诅咒
BUFFER_TYPE_INCREASE = 7 --增幅
BUFFER_TYPE_DECREASE = 8 --减幅
BUFFER_TYPE_REDUCTION= 9 --减伤
BUFFER_TYPE_CURELESS = 10 --无法被治疗
BUFFER_TYPE_REGE     = 11 --回血
BUFFER_TYPE_MAX      = 11

function createBufferFreeze(strength,times)
	return {type = BUFFER_TYPE_FREEZE,strength = strength,times = times}
end

function createBufferStun(strength,times)
	return {type = BUFFER_TYPE_STUN,strength = strength,times = times}
end

function createBufferSeal(strength,times)
	return {type = BUFFER_TYPE_SEAL,strength = strength,times = times}
end

function createBufferPoison(strength,times,att,percent)
	return {type = BUFFER_TYPE_POISON,strength = strength,times = times,damage=att*percent}
end

function createBufferBurn(strength,times,att,percent)
	return {type = BUFFER_TYPE_BURN,strength = strength,times = times,damage=att*percent}
end

function createBufferCurse(strength,times,att,percent)
	return {type = BUFFER_TYPE_CURSE,strength = strength,times = times,damage=att*percent}
end

function createBufferIncrease(strength,times,attackPercent,attackNumber)
	return {type = BUFFER_TYPE_INCREASE,strength = strength,times = times,attackPercent = attackPercent,attackNumber = attackNumber}
end

function createBufferDecrease(strength,times,attackPercent,attackNumber)
	return {type = BUFFER_TYPE_DECREASE,strength = strength,times = times,attackPercent = attackPercent,attackNumber = attackNumber}
end

function createBufferReduction(strength,times,damagePercent,damageNumber)
	return {type = BUFFER_TYPE_REDUCTION,strength = strength,times = times,damagePercent = damagePercent,damageNumber = damageNumber}
end

function createBufferCureless(strength,times)
	return {type = BUFFER_TYPE_CURELESS,strength = strength,times = times}
end

function createBufferRege(strength,times,att,percent)
	return {type = BUFFER_TYPE_REGE,strength = strength,times = times,damage=att*percent}
end
