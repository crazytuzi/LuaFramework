local QSBAction = import(".QSBAction")
local QSBDecreaseHpWtihoutLog = class("QSBDecreaseHpWtihoutLog", QSBAction)

local MODE_FIXED_HP = "fixed_hp"
local MODE_MAX_HP_PERCENT = "max_hp_percent"
local MODE_CURRENT_HP_PERCENT = "current_hp_percent"
--[==[
	自身扣除一部分不记录到battleLog(战斗结算数据中)中的血量
	mode:模式 fixed_hp:固定血量 max_hp_percent:总血量百分比 current_hp_percent:当前血量百分比
	value: 相对于mode的值
	ignore_absorb:是否无视护盾 默认否
	target: 是否为自身目标扣血
--]==]
function QSBDecreaseHpWtihoutLog:_execute(dt)
	local targets = {self._attacker}
    if self._options.selectTargets then
        targets = self._options.selectTargets or {}   --通过QSBArgsFindTargets获取
    elseif self._options.target then
		targets = {self._target}
    end
    for k,target in ipairs(targets) do
        if not self:isDeflection(self._attacker, target) then
        	local hp_value = 0
    		local mode = self._options.mode
    		local value = self._options.value
    		if mode == MODE_FIXED_HP then
    			hp_value = value
    		elseif mode == MODE_MAX_HP_PERCENT then
    			hp_value = target:getMaxHp() * value
    		elseif mode == MODE_CURRENT_HP_PERCENT then
    			hp_value = target:getHp() * value
    		end
            hp_value = hp_value * self:getDragonModifier()
            target:decreaseHp(hp_value, target, self._skill, false, false, self._options.ignore_absorb, true)
        end
    end
    
	self:finished()
end

return QSBDecreaseHpWtihoutLog