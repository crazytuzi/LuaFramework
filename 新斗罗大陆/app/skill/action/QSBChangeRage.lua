--[[
    Class name QSBChangeRage
    Create by Tdy
	2018-4-24
--]]

local QSBAction = import(".QSBAction")
local QSBChangeRage = class("QSBChangeRage", QSBAction)

-- 必填参数有:
---- rage_value 怒气改变值(int 建议填在skill_data)
-- 应当填的参数有:
---- is_target||lowest_hp_teammate||teammate_and_self||teammate||enemy||all_enemy 几种目标类型(bool 互斥)
---- rage_value_min, rage_value_max 怒气改变值上下限(int)
-- 可选参数有:
---- rage_resistance_type
---- support
---- showTip
---- buff_id

function QSBChangeRage:_execute(dt)

	local target = self._attacker
	local targets = nil
	if self._options.is_target == true then
		target = self._target
	elseif self._options.lowest_hp_teammate then
		local mates = app.battle:getMyTeammates(target, true)
		local candidate = q.max(mates, 
			function(target) 
				if target:isDead() then
					return 999999
				else
					return target:getHp() / target:getMaxHp()
				end
			end,
			function(d1, d2)
				if d1 == nil and d2 ~= 999999 then
					return true
				end
				return (d1 == nil and d2 ~= 999999) or (d1 ~= nil and d2 < d1)
			end)
		if candidate == nil or candidate:getHp() / target:getMaxHp() == 1.0 then
			candidate = target
		end
		target = candidate
	elseif self._options.teammate_and_self then
		targets = app.battle:getMyTeammates(target, true)
	elseif self._options.teammate then
		targets = app.battle:getMyTeammates(target, false)
	elseif self._options.enemy then
		targets = app.battle:getMyEnemies(target, false)
	elseif self._options.all_enemy then
		targets = app.battle:getAllMyEnemies(target)
	end
	
	if targets ~= nil then
		for _, target in ipairs(targets) do
			self:_changeTargetRage(target)
		end
	elseif target ~= nil then
		self:_changeTargetRage(target)
	end
	self:finished()
end

function QSBChangeRage:_changeTargetRage(target)
	if self._options.check_enmey and self._attacker:isTeammate(target) then
		return
	end
	-- 可在skill_data表配置怒气变化值, 以及抗性比较值(因为怒气变化可能要有成长性,但目标未必有所谓的"怒气抗性",因此需要其他属性代替)
	local rage_value = self._options.rage_value or self._skill:getAdditionValueWithKey("rage_value")
    local rage_resistance_type = self._options.rage_resistance_type
	-- 安全起见,设置单次怒气变化上下限; 默认0防止配表的人不知道自己在做什么
	local rage_value_min = self._options.rage_value_min or 0
	local rage_value_max = self._options.rage_value_max or 0

	local dRage = 0

	--当rage_value小于1时,则视作系数,转为目标当前怒气*该系数
	if rage_value >-1 and rage_value < 1 then
		rage_value = target:getRage() * rage_value
	end
	
	-- TODO: 希望程序能安全地支持更多比较类型
	if "Level" == rage_resistance_type then
		if not (target:getLevel() >= 1) then
			dRage = math.clamp(math.ceil(rage_value / 1),rage_value_min,rage_value_max)
		else
			dRage = math.clamp(
				math.ceil(
					rage_value / target:getLevel()
				),
				rage_value_min,rage_value_max
			)
			-- assert(false, "dRage:"..dRage..";rage_value:"..rage_value..";rage_value_min:"..rage_value_min..";rage_value_max:"..rage_value_max..";level:"..target:getLevel())
		end
	elseif "MaxHp" == rage_resistance_type then
		dRage = math.clamp(
			math.ceil(
				rage_value / target:getMaxHp()
			),
			rage_value_min,rage_value_max
		)
	else
		dRage = math.ceil(rage_value / 1)
	end
    target:changeRage(dRage, self._options.support, self._options.showTip)
	
	if self._options.buff_id ~= nil then
		local be_add_buff = false
		if not target:hasRage() or (target:isSupportHero() and not self._options.support) then
			be_add_buff = true
		else
			be_add_buff = (1 > target:getRage())
		end
		if be_add_buff then
			local id, level = q.parseIDAndLevel(self._options.buff_id, 1, self._skill)
			local buffInfo = db:getBuffByID(id)
			if buffInfo == nil then
				printError("buff id: %s does not exist!", self._options.buff_id)
			else
				target:applyBuff(self._options.buff_id, self._attacker, self._skill)
			end
		end
	end
end

return QSBChangeRage