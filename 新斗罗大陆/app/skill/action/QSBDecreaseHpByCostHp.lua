--[[
	消耗自身血量，对目标造成消耗血量倍数的伤害
	mode:模式 fixed_hp:固定血量 max_hp_percent:总血量百分比 current_hp_percent:当前血量百分比
	value: 相对于mode的值
	multiply_cofficient:伤害倍数
	ignore_absorb:是否无视护盾 默认否
--]]
local QSBAction = import(".QSBAction")
local QActor = import("...models.QActor")
local QSBDecreaseHpByCostHp = class("QSBDecreaseHpByCostHp", QSBAction)

function QSBDecreaseHpByCostHp:_execute(dt)
	local hpCostValue = 0
	if self._options.mode == "fixed_hp" then
		hpCostValue = self._options.value
	elseif self._options.mode == "max_hp_percent" then
		hpCostValue = self._attacker:getMaxHp() * self._options.value
	elseif self._options.mode == "current_hp_percent" then
		hpCostValue = self._attacker:getHp() * self._options.value
	end
	self._attacker:decreaseHp(hpCostValue, self._attacker, self._skill, false, false, self._options.ignore_absorb, true)	--自己掉血可以配置穿透护盾
    self._attacker:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, 
    isCritical = false, tip = "", rawTip = {
        isHero = self._attacker:getType() == ACTOR_TYPES.HERO, 
        isCritical = false, 
        isTreat = false,
        number = hpCostValue,
    }})
    if self._options.multiply_cofficient then
        if not self:isDeflection(self._attacker, self._target) then
            hpCostValue = hpCostValue * self:getDragonModifier()
    		self._target:decreaseHp(hpCostValue * self._options.multiply_cofficient, self._attacker, self._skill, false, false, false, false)	--敌人掉血不穿透护盾
    	    self._target:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = false, 
    	    isCritical = false, tip = "", rawTip = {
    	        isHero = self._target:getType() == ACTOR_TYPES.HERO, 
    	        isCritical = false, 
    	        isTreat = false,
    	        number = hpCostValue * self._options.multiply_cofficient,
    	    }})
        end
	end
	self:finished()
end

return QSBDecreaseHpByCostHp