EffectData = class("EffectData")
EffectData.__index = EffectData

function EffectData:ctor()
	
	
	--技能特效效果数据

    --有标记的状态的 卡牌
    self.effectCardObj_ = {}
	--血量状态
	self.hpEffectBleed_ = {}
	--怒气状态
	self.manaEffectValue_ = {}
	--效果类型
    self.effectType_ = {}

    --被攻击的目标
    self.targetAttack_ = {}

end

--血量状态值
function EffectData:getHpEffectBleed(key)
	if key then 
		return self.hpEffectBleed_[key]
	end
	return self.hpEffectBleed_
end

--血量状态值
function EffectData:setHpEffectBleed(key, value)
	self.hpEffectBleed_[key] = value
end

-- 怒气状态
function EffectData:setManaEffectValue(key, value)
	self.manaEffectValue_[key] = value
end

-- 怒气状态
function EffectData:getManaEffectValue(key)
    if key then 
	    return self.manaEffectValue_[key]
    end
    return self.manaEffectValue_
end

    --有标记的状态的 卡牌
function EffectData:setEffectCardObj(key, value)
    self.effectCardObj_[key] = value
end

function EffectData:getEffectCardObj(nPosInBattleMgr)
    if key then 
        return self.effectCardObj_[nPosInBattleMgr]
    end
    return self.effectCardObj_
end

--效果类型
function EffectData:getEffectType(key)
    if key then 
        return self.effectType_[key]
    end
    return self.effectType_

end

function EffectData:setEffectType(key, value)
    self.effectType_[key] = value
end

--被攻击的目标
function EffectData:setTargetAttack(key, value)
    self.targetAttack_[key] = value
end

function EffectData:getTargetAttack(key)
    if key then 
        return self.targetAttack_[key]
    end
    return self.targetAttack_
end

function EffectData:setTargetAttackToNil()
    self.targetAttack_ = {}
end

-------------------
gEffectData = EffectData.new()