------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_global");
require("logic/entity/ai/i3k_trigger_def");


------------------------------------------------------
i3k_ai_trigger = i3k_class("i3k_ai_trigger");
function i3k_ai_trigger:ctor(entity)
	self._entity	= entity;
	self._condition = { handled = nil, };
	self._damage = { direct = nil, };
	
end

function i3k_ai_trigger:Create(cfg, bid,id)
	if not cfg then return false; end

	local tcfg = i3k_db_trigger_event[cfg.tid];
	local bcfg = i3k_db_trigger_behavior[cfg.bid];

	if not tcfg or not bcfg then return false; end
	self._id		= id
	self._tcfg		= tcfg;
	self._bcfg		= bcfg;
	self._buffid	= bid or -1;
	self._valid		= false;
	self._odds		= cfg.odds;
	self._cooldown	= cfg.cooldown;
	self._tickline	= cfg.cooldown;

	return true;
end

function i3k_ai_trigger:IsActived()
	return self._tickline >= self._cooldown;
end

function i3k_ai_trigger:IsValid()
	return self._valid;
end

function i3k_ai_trigger:OnUpdate(mgr, time)
end

function i3k_ai_trigger:OnLogic(mgr, tick)
	self._tickline = math.min(self._tickline + tick * i3k_engine_get_tick_step(), self._cooldown);
end

function i3k_ai_trigger:Check(mgr, hoster, tick)
	local logic = i3k_game_get_logic();
	if not logic then
		return false;
	end

	if self._valid then
		return true;
	end

	if not self:IsActived() then
		return false;
	end

	local rnd = i3k_engine_get_rnd_u(0, 10000);

	if self._tcfg.tid == eTFuncDead then
	elseif self._tcfg.tid == eTFuncODead then
		if mgr._events[eTEventDead] then
			mgr._events[eTEventDead] = false;
			if self._odds < rnd then
				return false;
			end
			return true;
		end
	elseif self._tcfg.tid == eTFuncUseSkill then
		local args1 = self._tcfg.args[1] + self:TalentTriggerChange(hoster,eAiTypeTrigger,1)
		local args2 = self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)
		local args3 = self._tcfg.args[3] + self:TalentTriggerChange(hoster,eAiTypeTrigger,3)

		local result = 0
		if args1 == -1 then
			for k,v in pairs(mgr._events[eTEventSkill]) do
				if args3 == -1 then
					result = result + mgr._events[eTEventSkill][k].dam + mgr._events[eTEventSkill][k].buff + mgr._events[eTEventSkill][k].dot
				elseif args3 == 1 then
					result = result + mgr._events[eTEventSkill][k].dam 
				elseif args3 == 2 then
					result = result + mgr._events[eTEventSkill][k].buff 
				elseif args3 == 3 then
					result = result + mgr._events[eTEventSkill][k].dot 
				end
			end
		elseif args1 == 1 or args1 == 2 or args1 == 3 then
			if args3 == -1 then
				result = result + mgr._events[eTEventSkill][args1].dam + mgr._events[eTEventSkill][args1].buff + mgr._events[eTEventSkill][args1].dot
			elseif args3 == 1 then
				result = result + mgr._events[eTEventSkill][args1].dam 
			elseif args3 == 2 then
				result = result + mgr._events[eTEventSkill][args1].buff 
			elseif args3 == 3 then
				result = result + mgr._events[eTEventSkill][args1].dot 
			end
		end
		if result >= args2 then
			mgr._events[eTEventSkill] = { { dam = 0,buff = 0,dot = 0, skilltype = 0}, { dam = 0,buff = 0,dot = 0,skilltype = 0}, { dam = 0,buff = 0,dot = 0, skilltype = 0} };
			if self._odds < rnd then
				return false;
			end

			return true;
		end
	elseif self._tcfg.tid == eTFuncHP then
		if self._entity then
			local valueT = self._tcfg.args[1] + self:TalentTriggerChange(hoster,eAiTypeTrigger,1);
			local value = 0
			if valueT == 1 then
				value = self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2);
			elseif valueT == 2 then
				local maxhp = self._entity:GetPropertyValue(ePropID_maxHP)
				value = maxhp*(self._tcfg.args[2]+ self:TalentTriggerChange(hoster,eAiTypeTrigger,2))/10000;
			end
			local curhp = self._entity:GetPropertyValue(ePropID_hp)
			if curhp < value then
				return true;
			end
		end
	elseif self._tcfg.tid == eTFuncDirectDamage then
		if self._condition.handled == nil then
			if (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == -1 then
				self._condition.handled = { count = mgr._events[eTEventHit].count };
			elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 0 then
				self._condition.handled = { count = (mgr._events[eTEventHit].count - mgr._events[eTEventHit].cricount) };
			elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 1 then
				self._condition.handled = { count =  mgr._events[eTEventHit].cricount };
			end
		end

		local val1 = self._condition.handled.count;
		local val2 = mgr._events[eTEventHit].count;
		local val3 =  mgr._events[eTEventHit].cricount
		local result = -1
		if (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == -1 then
			result = val2 - val1
		elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 0 then
			result = (val2-val3) - val1
		elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 1 then
			result = val3 - val1
		end
		if result >= (self._tcfg.args[1] + self:TalentTriggerChange(hoster,eAiTypeTrigger,1)) then
			if (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == -1 then
				self._condition.handled.count = val2
			elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 0 then
				self._condition.handled.count = val2-val3
			elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 1 then
				self._condition.handled.count = val3
			end

			if self._odds < rnd then
				return false;
			end

			return true;
		end
	elseif self._tcfg.tid == eTFuncInDirectDamage then
		local bid = self._tcfg.args[1] + self:TalentTriggerChange(hoster,eAiTypeTrigger,1);
		if bid == -1 then
			bid = self._buffid;
		end
		local cnt = mgr._events[eTEventHit].ids["buff_" .. bid] or 0;

		if self._condition.handled == nil then
			self._condition.handled = { count = cnt };
		end

		local val = self._condition.handled.count;
		if (cnt - val) >= (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) then
			self._condition.handled.count = cnt;

			if self._odds < rnd then
				return false;
			end

			return true;
		end
	elseif self._tcfg.tid == eTFuncDamageVal then
	elseif self._tcfg.tid == eTFuncEnemies then
	elseif self._tcfg.tid == eTFuncLoseHP then
	elseif self._tcfg.tid == eTFuncIdle then
		if self._condition.handled == nil then
			self._condition.handled = { tickline = 0 };
		end

		if mgr._events[eTEventIdle].valid then
			local tick1 = self._condition.handled.tickline;
			local tick2 = mgr._events[eTEventIdle].tickline;
			local tick3 = logic:GetLogicTick();

			local val1 = ((tick3 - tick1) - tick2) * i3k_engine_get_tick_step();
			local val2 =  self._tcfg.args[1] + self:TalentTriggerChange(hoster,eAiTypeTrigger,1);
			if val1 > val2 then
				self._condition.handled.tickline = (tick3 - tick2);

				if self._odds < rnd then
					return false;
				end

				return true;
			end
		else
			self._condition.handled.tickline = 0;
		end
	elseif self._tcfg.tid == eTFuncTick then
		if self._condition.handled == nil then
			self._condition.handled = { tick = logic:GetLogicTick() };
		end

		local val = logic:GetLogicTick() - self._condition.handled.tick;
		if val * i3k_engine_get_tick_step() >= (self._tcfg.args[1] + self:TalentTriggerChange(hoster,eAiTypeTrigger,1)) then
			self._condition.handled.tick = logic:GetLogicTick();

			if self._odds < rnd then
				return false;
			end

			return true;
		end
	elseif self._tcfg.tid == eTFuncDamageClosing then
		if not mgr._events[eTEventAttack].valid then
			return false;
		end

		local valid = false;
		if (self._tcfg.args[1] + self:TalentTriggerChange(hoster,eAiTypeTrigger,1)) == 1 then
			if mgr._events[eTEventAttack].damage then
				valid = ((self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 1 and mgr._events[eTEventAttack].critical) or ((self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 0 and not mgr._events[eTEventAttack].critical) or ((self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == -1 );
			end
		elseif (self._tcfg.args[1] + self:TalentTriggerChange(hoster,eAiTypeTrigger,1)) == 2 then
			if not mgr._events[eTEventAttack].damage then
				valid = ((self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 1 and mgr._events[eTEventAttack].critical) or ((self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 0 and not mgr._events[eTEventAttack].critical) or ((self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == -1 );
			end
		end

		if self._odds < rnd then
			valid = false;
		end

		return valid;
	elseif self._tcfg.tid == eTFuncBuff then
		local bid  = self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2);
		if bid == -1 and hoster then
			bid = hoster._id;
		end

		local step = self._tcfg.args[1] + self:TalentTriggerChange(hoster,eAiTypeTrigger,1);

		local cnt = 0;
		local event = mgr._events[eTEventBuff][bid];
		if event then
			cnt = event.step[step] or 0;
		end

		if self._condition.handled == nil then
			self._condition.handled = cnt;
		end

		local valid = cnt > self._condition.handled;
		if valid then
			self._condition.handled = cnt;
		end

		if self._odds < rnd then
			valid = false;
		end

		return valid;
	elseif self._tcfg.tid == eTFuncDodge then
		if self._condition.handled == nil then
			self._condition.handled = { count = mgr._events[eTEventDodge].count };
		end

		local val1 = self._condition.handled.count;
		local val2 = mgr._events[eTEventDodge].count;

		if val2 - val1 >= (self._tcfg.args[1] + self:TalentTriggerChange(hoster,eAiTypeTrigger,1)) then
			self._condition.handled.count = val2

			if self._odds < rnd then
				return false;
			end

			return true;
		end
	elseif self._tcfg.tid == eTFuncProcessDirectDamage then
		if (self._tcfg.args[3] + self:TalentTriggerChange(hoster,eAiTypeTrigger,3)) == 1 then
			if self._condition.handled == nil then
				if (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == -1 then
					self._condition.handled = { count = mgr._events[eTEventToHit].count };
				elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 0 then
					self._condition.handled = { count = (mgr._events[eTEventToHit].count - mgr._events[eTEventToHit].cricount) };
				elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 1 then
					self._condition.handled = { count =  mgr._events[eTEventToHit].cricount };
				end
			end

			local val1 = self._condition.handled.count;
			local val2 = mgr._events[eTEventToHit].count;
			local val3 =  mgr._events[eTEventToHit].cricount
			local result = -1
			if (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == -1 then
				result = val2 - val1
			elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 0 then
				result = (val2-val3) - val1
			elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 1 then
				result = val3 - val1
			end
			if result >= self._tcfg.args[1] then
				if (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == -1 then
					self._condition.handled.count = val2
				elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 0 then
					self._condition.handled.count = val2-val3
				elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 1 then
					self._condition.handled.count = val3
				end

				if self._odds < rnd then
					return false;
				end

				return true;
			end
		elseif (self._tcfg.args[3] + self:TalentTriggerChange(hoster,eAiTypeTrigger,3)) == 2 then
			if self._condition.handled == nil then
				if (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == -1 then
					self._condition.handled = { count = mgr._events[eTEventHeal].healcount };
				elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 0 then
					self._condition.handled = { count = (mgr._events[eTEventHeal].healcount - mgr._events[eTEventHeal].cricount) };
				elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 1 then
					self._condition.handled = { count =  mgr._events[eTEventHeal].cricount };
				end
			end
			local val1 = self._condition.handled.count;
			local val2 = mgr._events[eTEventHeal].healcount;
			local val3 =  mgr._events[eTEventHeal].cricount
			local result = -1
			if (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == -1 then
				result = val2 - val1
			elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 0 then
				result = (val2-val3) - val1
			elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 1 then
				result = val3 - val1
			end
			if result >= (self._tcfg.args[1] + self:TalentTriggerChange(hoster,eAiTypeTrigger,1)) then
				if (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == -1 then
					self._condition.handled.count = val2
				elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 0 then
					self._condition.handled.count = val2-val3
				elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 1 then
					self._condition.handled.count = val3
				end

				if self._odds < rnd then
					return false;
				end

				return true;
			end
		end
	elseif self._tcfg.tid == eTFuncHPPercentOnDamage then
		if self._condition.handled == nil then
			if (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == -1 then
				self._condition.handled = { belowcount = mgr._events[eTEventHit].belowcount };
			elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 0 then
				self._condition.handled = { belowcount = (mgr._events[eTEventHit].belowcount - mgr._events[eTEventHit].belowcricount) };
			elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 1 then
				self._condition.handled = { belowcount =  mgr._events[eTEventHit].belowcricount };
			end
		end

		local val1 = self._condition.handled.belowcount;
		local val2 = mgr._events[eTEventHit].belowcount;
		local val3 =  mgr._events[eTEventHit].belowcricount
		local result = -1
		if (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == -1 then
			result = val2 - val1
		elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 0 then
			result = (val2-val3) - val1
		elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 1 then
			result = val3 - val1
		end
		if result >= 1 then
			if (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == -1 then
				self._condition.handled.belowcount = val2
			elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 0 then
				self._condition.handled.belowcount = val2-val3
			elseif (self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == 1 then
				self._condition.handled.belowcount = val3
			end
			if not self._entity then
				return false
			end

			local maxhp = self._entity:GetPropertyValue(ePropID_maxHP)
			local value = maxhp*(self._tcfg.args[1] + self:TalentTriggerChange(hoster,eAiTypeTrigger,1))/10000;
			local curhp = self._entity:GetPropertyValue(ePropID_hp)
			if curhp > value then
				return false;
			end

			if self._odds < rnd then
				return false;
			end

			return true;
		end
	elseif self._tcfg.tid == eTFuncHPPercentToDamage then
		local entity = self:TestEventAttackValid(mgr, false)
		if not entity then
			return false
		end
		
		local ismonster = entity:GetEntityType() == eET_Monster
		local unitType = self._tcfg.args[1] + self:TalentTriggerChange(hoster,eAiTypeTrigger,1)
		if (ismonster and (unitType == 1 or unitType == 3)) or  (not ismonster and unitType == 4) then
			local maxhp = entity:GetPropertyValue(ePropID_maxHP)
			local value = maxhp*(self._tcfg.args[2]+ self:TalentTriggerChange(hoster,eAiTypeTrigger,2))/10000;
			local curhp = entity:GetPropertyValue(ePropID_hp)
			if self._tcfg.args[3] == 0 then --大于或小于（0小于，1大于）
				if value < curhp then
					return false;
				end
			end

			if self._tcfg.args[3] == 1 then
				if value > curhp then
					return false;
				end
			end
			
			if self._odds >= rnd then
				return true;
			end
		end
	elseif self._tcfg.tid == eTFuncMiss then
		if self._condition.handled == nil then
			self._condition.handled = { count = mgr._events[eTEventMiss].count };
		end

		local val1 = self._condition.handled.count;
		local val2 = mgr._events[eTEventMiss].count;
		if val2 - val1 >= (self._tcfg.args[1] + self:TalentTriggerChange(hoster,eAiTypeTrigger,1)) then
			self._condition.handled.count = val2

			if self._odds < rnd then
				return false;
			end

			return true;
		end
	elseif self._tcfg.tid == eTFuncStatusToDamage then
		if self._odds < rnd then
			return false;
		end
		local entity = self:TestEventAttackValid(mgr, false)
		if not entity then
			return false
		end
		
		if ((self._tcfg.args[1]+ self:TalentTriggerChange(hoster,eAiTypeTrigger,1)) == 1) ~= mgr._events[eTEventAttack].damage then
			return false
		end
		
		if self._tcfg.args[3] > 0 and not entity._behavior:Test((self._tcfg.args[3]+ self:TalentTriggerChange(hoster,eAiTypeTrigger,3))) then
			return false;		
		end

		if ((self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == -1) or ((self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == mgr._events[eTEventAttack].critical) then
			return true;
		end
	elseif self._tcfg.tid == eTFuncIsChange then
		if mgr._events[eTEventChange][1] or mgr._events[eTEventChange][2] then
			mgr._events[eTEventChange] = {}
			return true
		end
		return false
	elseif self._tcfg.tid == eTFuncSufferDmg then --当受到伤害时（记录伤害值）
		local direct = mgr._events[eTEventDamage].direct;
		local cri =  mgr._events[eTEventDamage].cri;
		if direct and direct ~= 0 and (self._tcfg.args[1] == -1 or cri == self._tcfg.args[1]) then
			if not self._entity then
				return false
			end	
			
			if self._odds < rnd then
				return false;
			end
			if self._damage.direct == nil then
				self._damage.direct = direct;
			end
			mgr._events[eTEventDamage]	= { direct = 0, indirect = 0 , cri = 0};
			return true;		
		end
		
	elseif self._tcfg.tid == eTFuncBreakHiding then --主动施放技能打破隐身时（记录技能信息）
		if not self._entity then
			return false;
		end
		
		local args1 = self._tcfg.args[1] + self:TalentTriggerChange(hoster,eAiTypeTrigger,1)
		local result = 0;
		if args1 == 1 or args1 == 2 or args1 == 3 then
			result = result + mgr._events[eTEventSkill][args1].skilltype 
		end
		local target = self._entity._target;
		if result and result ~= 0 and target then
			
			if not self._entity._invisibleEnd then
				return false;
			end
			if target:GetEntityType() ~= eET_Monster then
				return false;
			end
			if self._odds < rnd then
				return false;
			end
			mgr._events[eTEventSkill][args1].skilltype = 0;
			return true;
		end
	elseif self._tcfg.tid == eTFuncStatusByDamage then
		if self._odds < rnd then
			return false;
		end
		if not self:TestEventAttackValid(mgr, true) then
			return false
		end

		if self._tcfg.args[3] > 0 and not self._entity._behavior:Test((self._tcfg.args[3]+ self:TalentTriggerChange(hoster,eAiTypeTrigger,3))) then
			return false;		
		end

		if ((self._tcfg.args[1]+ self:TalentTriggerChange(hoster,eAiTypeTrigger,1)) == 1) ~= mgr._events[eTEventAttack].damage then
			return false
		end
		
		if ((self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == -1) or ((self._tcfg.args[2] + self:TalentTriggerChange(hoster,eAiTypeTrigger,2)) == mgr._events[eTEventAttack].critical) then
			return true;
		end
	end

	return false;
end

function i3k_ai_trigger:OnTrigger()
	local handled = false;

	if self._bcfg.bid == eTBehaviorTalk then
		handled = true;
		local talk_str_id = self._bcfg.args[1] + self:TalentTriggerChange(self._entity,eAITypeEvent,1);
		local talk_str = i3k_db_string[talk_str_id] or "愿随主人闯荡江湖";
		self._entity:ShowInfo(self._entity, eEffectID_Buff.style, talk_str, i3k_db_common.engine.durNumberEffect[2] / 1000);
	elseif self._bcfg.bid == eTBehaviorSkill then
		if (self._bcfg.args[4] + self:TalentTriggerChange(self._entity,eAITypeEvent,4)) == 1 then
			local all_skills, use_skills = g_i3k_game_context:GetRoleSkills();
			for k, v in pairs(use_skills) do
				if v == (self._bcfg.args[1] + self:TalentTriggerChange(self._entity,eAITypeEvent,1)) then
					local skill = self._entity._skills[v];
					if skill and skill:CanUse() then
						if (self._entity:UseSkill(skill)) then
							handled = true;
						end
					end
				end
			end
		else
			local scfg = i3k_db_skills[(self._bcfg.args[1] + self:TalentTriggerChange(self._entity,eAITypeEvent,1))];
			if scfg then
				local skill = require("logic/battle/i3k_skill");
				if skill then
					local _skill = skill.i3k_skill_create(self._entity, scfg, math.max(1, (self._bcfg.args[2] + self:TalentTriggerChange(self._entity,eAITypeEvent,2))), 0, skill.eSG_TriSkill);
					if _skill then
						if _skill._specialArgs.triSkillTargets then
							if _skill._specialArgs.triSkillTargets.type == 1 then
								_skill._replaceTargets = { self._entity._lastAttacker };
							elseif _skill._specialArgs.triSkillTargets.type == 2 then
							end
						end

						if (self._bcfg.args[3] + self:TalentTriggerChange(self._entity,eAITypeEvent,3)) == 1 then
							if (self._entity:UseSkill(_skill)) then
								handled = true;
							end
						else
							handled = true;
							self._entity._deadtriskill[self._bcfg.args[1]] = self._bcfg.args[1]
							self._entity:StartAttack(_skill);
						end
					end
				end
			end
		end
	elseif self._bcfg.bid == eTBehaviorBuff then
	elseif self._bcfg.bid == eTBehaviorAction then
	elseif self._bcfg.bid == eTBehaviorChgDmgVal then
		if (self._bcfg.args[1]+ self:TalentTriggerChange(self._entity,eAITypeEvent,1)) == 1 then
			self._entity:UpdateDamageRetrive((self._bcfg.args[2] + self:TalentTriggerChange(self._entity,eAITypeEvent,2)) / 10000);
		elseif (self._bcfg.args[1] + self:TalentTriggerChange(self._entity,eAITypeEvent,1)) == 2 then
			local rnd = i3k_engine_get_rnd_f((self._bcfg.args[2]+ self:TalentTriggerChange(self._entity,eAITypeEvent,2)) / 10000, (self._bcfg.args[3]+ self:TalentTriggerChange(self._entity,eAITypeEvent,3)) / 10000);

			self._entity:UpdateDamageRetrive(rnd);
		end
	elseif self._bcfg.bid == eTBehaviorDecDmg then
		self._entity:UpdateDamageDes((self._bcfg.args[1]+ self:TalentTriggerChange(self._entity,eAITypeEvent,1))/10000, self._bcfg.args[2])
	elseif self._bcfg.bid == eTBehaviorSkillCoolDown then-- 加快指定技能冷却
		for k, v in pairs(self._entity._skills) do
			if k == (self._bcfg.args[1]+ self:TalentTriggerChange(self._entity,eAITypeEvent,1)) then
				if v and not v:CanUse() then
					v:DesCoolTime((self._bcfg.args[2]+ self:TalentTriggerChange(self._entity,eAITypeEvent,2)))
				end
			end
		end
		if self._entity._dodgeSkill and self._entity._dodgeSkill._id == (self._bcfg.args[1]+ self:TalentTriggerChange(self._entity,eAITypeEvent,1)) then
			if not self._entity._dodgeSkill:CanUse() then
				self._entity._dodgeSkill:DesCoolTime((self._bcfg.args[2] + self:TalentTriggerChange(self._entity,eAITypeEvent,2)))
			end
		end
		if self._entity._uniqueSkill and self._entity._uniqueSkill._id == (self._bcfg.args[1]+ self:TalentTriggerChange(self._entity,eAITypeEvent,1)) then
			if not self._entity._uniqueSkill:CanUse() then
				self._entity._uniqueSkill:DesCoolTime((self._bcfg.args[2] + self:TalentTriggerChange(self._entity,eAITypeEvent,2)))
			end
		end
		if self._entity._DIYSkill and (self._bcfg.args[1] + self:TalentTriggerChange(self._entity,eAITypeEvent,1)) == SKILL_DIY then
			if not self._entity._DIYSkill:CanUse() then
				self._entity._DIYSkill:DesCoolTime((self._bcfg.args[2] + self:TalentTriggerChange(self._entity,eAITypeEvent,2)))
			end
		end	
		if self._entity._anqiSkill and (self._bcfg.args[1] + self:TalentTriggerChange(self._entity,eAITypeEvent,1)) == self._entity._anqiSkill._id then
			if not self._entity._anqiSkill:CanUse() then
				self._entity._anqiSkill:DesCoolTime((self._bcfg.args[2] + self:TalentTriggerChange(self._entity,eAITypeEvent,2)))
			end
		end
		if self._entity._ultraSkill and self._entity._ultraSkill._id == (self._bcfg.args[1] + self:TalentTriggerChange(self._entity,eAITypeEvent,1)) then
			if not self._entity._ultraSkill:CanUse() then
				self._entity._ultraSkill:DesCoolTime((self._bcfg.args[2] + self:TalentTriggerChange(self._entity,eAITypeEvent,2)))
			end
		end
		handled = true;
	elseif self._bcfg.bid == eTBehaviorAddDmg then
		self._entity:UpdateDamageAddition((self._bcfg.args[1]+ self:TalentTriggerChange(self._entity,eAITypeEvent,1))/10000, self._bcfg.args[2])
	elseif self._bcfg.bid == eTBehaviorRecoverHp then
		local ratio = (self._bcfg.args[1] + self:TalentTriggerChange(self._entity, eAITypeEvent, 1)) / 10000;
		if self._damage and  self._damage.direct then
			local hpchange = math.ceil(self._damage.direct * ratio);
			local maxVal = self._entity:GetPropertyValue(ePropID_maxHP);
			local curVal = self._entity:GetPropertyValue(ePropID_hp);
			if hpchange > 0 then
				if hpchange > maxVal - curVal then
					hpchange = maxVal - curVal;
				end
				self._damage.direct = nil;
				self._entity:UpdateProperty(ePropID_hp, 1, hpchange, true, true);
			end
		end
	end

	-- reset trigger state
	if handled then
		self:Finish();
	end
end

function i3k_ai_trigger:Finish()
	self._valid = false;
	self._tickline = 0;
end

function i3k_ai_trigger:TalentTriggerChange(entity,changetype,changepos)
	---------心法改变
	local hero = i3k_game_get_player_hero()
	if hero and entity._guid == hero._guid  then
		if entity._talentChangeAi[self._id] then
			for k1,v1 in pairs(entity._talentChangeAi[self._id]) do
				for k,v in pairs(v1) do
					if eAiTypeTrigger == changetype and v.changetype == eAiTypeTrigger and v.argpos == changepos then
						return self:TalentTriggerChangevalue(v.valuetype,self._tcfg.args[changepos],v.value)
					elseif eAITypeEvent == changetype and v.changetype == eAITypeEvent and v.argpos == changepos then
						return self:TalentTriggerChangevalue(v.valuetype,self._bcfg.args[changepos],v.value)
					end
				end
			end
		end
	end
	return 0;
end

function i3k_ai_trigger:TalentTriggerChangevalue(type,arg1,arg2)
	if type == eSCValueType_add then
		return arg2
	elseif type == eSCValueType_mul then
		return arg1*arg2/100 - arg1
	elseif type == eSCValueType_instead then
		return arg2 - arg1
	end
end

function i3k_ai_trigger:TestEventAttackValid(mgr, isOwn)
	if not mgr._events[eTEventAttack].valid then
		return false;
	end
	if not self._entity then
		return false
	end

	if isOwn then
		return true
	end

	local entity = nil
	if not mgr._events[eTEventAttack].target then
		return false
	end
	
	for k,v in pairs(self._entity._alives[2]) do
		if v.entity == mgr._events[eTEventAttack].target then
			entity = v.entity;
		end
	end

	if not entity then
		return false
	end
	return entity
end

------------------------------------------------------
local g_i3k_trigger_id = 1;
local function gen_trigger_id()
	local id = g_i3k_trigger_id;

	g_i3k_trigger_id = (g_i3k_trigger_id + 1) % 999999;

	return id;
end


------------------------------------------------------
i3k_ai_trigger_mgr = i3k_class("i3k_ai_trigger_mgr");
function i3k_ai_trigger_mgr:ctor(entity)
	self._entity	= entity;
	self._triggers	= { };
	self._triIds	= { };
	self:Reset();
end

function i3k_ai_trigger_mgr:RegTrigger(trigger, hoster) 
	if not trigger then return -1; end
	local tcfg = trigger._tcfg;
	if not tcfg then return -1; end

	local id = gen_trigger_id();

	self._triggers[id] = { trigger = trigger, hoster = hoster };
	if not self._triIds[tcfg.tid] then
		self._triIds[tcfg.tid] = { };
	end
	table.insert(self._triIds[tcfg.tid], id);

	return id;
end

function i3k_ai_trigger_mgr:UnregTrigger(id)
	local hdr = self._triggers[id];
	if hdr then
		local tri = hdr.trigger;
		if tri then
			local tcfg = tri._tcfg;

			local ids = self._triIds[tcfg.tid];
			if ids then
				for k, v in ipairs(ids) do
					if v == id then
						table.remove(ids, k);

						break;
					end
				end
			end
		end
	end
	self._triggers[id] = nil;
end

function i3k_ai_trigger_mgr:Reset()
	self._events = { };
		self._events[eTEventSkill]			= { { dam = 0,buff = 0,dot = 0, skilltype = 0}, { dam = 0,buff = 0,dot = 0,skilltype = 0}, { dam = 0,buff = 0,dot = 0, skilltype = 0} };
		self._events[eTEventDead]			= false;
		self._events[eTEventSyncope]		= false;
		self._events[eTEventHit]			= { count = 0,cricount = 0, ids = { },belowcount = 0,belowcricount = 0 };
		self._events[eTEventDamage]			= { direct = 0, indirect = 0 , cri = 0};
		self._events[eTEventHeal]			= { direct = 0, indirect = 0 ,cricount = 0,healcount = 0};
		self._events[eTEventIdle]			= { valid = false, tickline = 0 };
		self._events[eTEventAttack]			= { valid = false, damage = false, critical = false,target = nil};
		self._events[eTEventBuff]			= { };
		self._events[eTEventDodge]			= { count = 0, ids = { } };
		self._events[eTEventToHit]			= { count = 0,cricount = 0, ids = { } };
		self._events[eTEventMiss]			= { count = 0 };
		self._events[eTEventChange]			= {  };
end

function i3k_ai_trigger_mgr:PostEvent(entity, eventID, ...)
	local logic = i3k_game_get_logic();
	local world = i3k_game_get_world();
	if not logic then
		return false;
	end
	if world and world._syncRpc then
		return false;
	end
	local arg = { ... };

	if eventID == eTEventSkill then
		if arg[1] >= 1 and arg[1] <= 3 then
			if arg[2] == eSE_Damage then
				self._events[eTEventSkill][arg[1]].dam = self._events[eTEventSkill][arg[1]].dam + 1
				self._events[eTEventSkill][arg[1]].skilltype = self._events[eTEventSkill][arg[1]].dam + arg[1];
			elseif arg[2] == eSE_Buff then
				self._events[eTEventSkill][arg[1]].buff = self._events[eTEventSkill][arg[1]].buff + 1
				self._events[eTEventSkill][arg[1]].skilltype = self._events[eTEventSkill][arg[1]].dam + arg[1];
			elseif arg[2] == eSE_DBuff then
				self._events[eTEventSkill][arg[1]].dot = self._events[eTEventSkill][arg[1]].dot + 1
				self._events[eTEventSkill][arg[1]].skilltype = self._events[eTEventSkill][arg[1]].dam + arg[1];
			end
		end
	elseif eventID == eTEventDead then
		self._events[eTEventDead] = true;
		if entity and entity._behavior then
			entity._behavior:Set(eEBGotodead)
		end
	elseif eventID == eTEventSyncope then
		self._events[eTEventSyncope] = true;
	elseif eventID == eTEventHit then
		local direct = arg[2];
		local cri = arg[4]
		if direct then
			self._events[eTEventHit].count = self._events[eTEventHit].count + 1;
			self._events[eTEventHit].belowcount = self._events[eTEventHit].belowcount + 1;
			if cri then
				self._events[eTEventHit].cricount = self._events[eTEventHit].cricount + 1
				self._events[eTEventHit].belowcricount = self._events[eTEventHit].belowcricount + 1;
			end
			local attacker = arg[1];
			if attacker then
				if self._events[eTEventHit].ids[attacker._guid] == nil then
					self._events[eTEventHit].ids[attacker._guid] = 0;
				end
				self._events[eTEventHit].ids[attacker._guid] = self._events[eTEventHit].ids[attacker._guid] + 1;
			end
		else
			local buffid = arg[3];
			if buffid and buffid > 0 then
				local bid = "buff_" .. buffid;

				if self._events[eTEventHit].ids[bid] == nil then
					self._events[eTEventHit].ids[bid] = 0;
				end
				self._events[eTEventHit].ids[bid] = self._events[eTEventHit].ids[bid] + 1;
			end
		end
	elseif eventID == eTEventDamage then
		local val = arg[1];
		if val then
			local direct = arg[2];
			if direct then
				self._events[eTEventDamage].direct = self._events[eTEventDamage].direct + val;
				if arg[4] then
					self._events[eTEventDamage].cri = self._events[eTEventDamage].cri + 1;
				end
			else
				self._events[eTEventDamage].indirect = self._events[eTEventDamage].indirect + val;
			end
		end
	elseif eventID == eTEventHeal then
		local val = arg[1];
		if val then
			local direct = arg[2];
			local cir = arg[4]
			if direct then
				self._events[eTEventHeal].direct = self._events[eTEventHeal].direct + val;
				self._events[eTEventHeal].healcount = self._events[eTEventHeal].healcount + 1;
				if cir then
					self._events[eTEventHeal].cricount = self._events[eTEventHeal].cricount + 1;
				end
				
			else
				self._events[eTEventHeal].indirect = self._events[eTEventHeal].indirect + val;
			end
		end
	elseif eventID == eTEventIdle then
		self._events[eTEventIdle].valid		= arg[1];
		self._events[eTEventIdle].tickline	= logic:GetLogicTick();
	elseif eventID == eTEventAttack then
		self._events[eTEventAttack].valid	= arg[1];
		self._events[eTEventAttack].damage	= arg[2];
		self._events[eTEventAttack].critical	= arg[3];
		self._events[eTEventAttack].target	= arg[4];
	elseif eventID == eTEventBuff then
		local bid	= arg[1] or -1;
		local step	= arg[2] or eBStep_Unknown;
		local val	= arg[3] or 0;

		if bid ~= -1 and step ~= eBStep_Unknown then
			if not self._events[eTEventBuff][bid] then
				self._events[eTEventBuff][bid] = { step = { }, value = 0 };
			end
			self._events[eTEventBuff][bid].value = val;

			if not self._events[eTEventBuff][bid].step[step] then
				self._events[eTEventBuff][bid].step[step] = 0;
			end
			self._events[eTEventBuff][bid].step[step] = self._events[eTEventBuff][bid].step[step] + 1;
		end
	elseif eventID == eTEventDodge then
		self._events[eTEventDodge].count = self._events[eTEventDodge].count + 1;
		local attacker = arg[1];
		if attacker then
			if self._events[eTEventDodge].ids[attacker._guid] == nil then
				self._events[eTEventDodge].ids[attacker._guid] = 0;
			end
			self._events[eTEventDodge].ids[attacker._guid] = self._events[eTEventDodge].ids[attacker._guid] + 1;
		end
	elseif eventID == eTEventToHit then
		local direct = arg[2];
		local cri = arg[4]
		if direct then
			self._events[eTEventToHit].count = self._events[eTEventToHit].count + 1;
			if cri then
				self._events[eTEventToHit].cricount = self._events[eTEventToHit].cricount + 1
			end
			local attacker = arg[1];
			if attacker then
				if self._events[eTEventToHit].ids[attacker._guid] == nil then
					self._events[eTEventToHit].ids[attacker._guid] = 0;
				end
				self._events[eTEventToHit].ids[attacker._guid] = self._events[eTEventToHit].ids[attacker._guid] + 1;
			end
		end
	elseif eventID == eTEventMiss then
		self._events[eTEventMiss].count = self._events[eTEventMiss].count + 1;
	elseif eventID == eTEventChange then
		if (arg[2] and g_i3k_db.i3k_db_is_weapon_unique_skill_has_aitrigger(arg[2])) and arg[3] then
			self._events[eTEventChange][1] = arg[1] == 1 or arg[1] == 3
			self._events[eTEventChange][2] = arg[1] == 2 or arg[1] == 3
		end
	end
	self:UpdateTris(false, dTick);
end

function i3k_ai_trigger_mgr:OnUpdate(dTime)
	local world = i3k_game_get_world();
	if world and world._syncRpc then
		return false;
	end
	for tid = eTFuncFirst, eTFuncLast do
		local ids = self._triIds[tid];
		if ids then
			for k, v in ipairs(ids) do
				local hdr = self._triggers[v];
				if hdr then
					local tri = hdr.trigger;
					if tri then
						tri:OnUpdate(self, dTime);
					end
				end
			end
		end
	end
end

function i3k_ai_trigger_mgr:OnLogic(dTick)
	local world = i3k_game_get_world();
	if world and world._syncRpc then
		return false;
	end
	if dTick > 0 then
		self:UpdateTris(true, dTick);
	end
end

function i3k_ai_trigger_mgr:UpdateTris(logic, dTick)
	for tid = eTFuncFirst, eTFuncLast do
		local ids = self._triIds[tid];
		if ids then
			for k, v in ipairs(ids) do
				local hdr = self._triggers[v];
				if hdr then
					local tri = hdr.trigger;
					if tri then
						if logic then
							tri:OnLogic(self, dTick);
						end

						if tri:Check(self, hdr.hoster, dTick) then
							tri:OnTrigger();
						end
					end
				end
			end
		end
	end
	if self._entity and self._entity._behavior and self._entity._behavior:Test(eEBGotodead) then
		local world = i3k_game_get_world();
		if world and not world._syncRpc then
			local clearDead = true
			for k,v in pairs(self._entity._attacker) do
				if self._entity._deadtriskill[v._skill._id] then
					clearDead = false
				end
			end
			
			if clearDead then
				self._entity._deadtriskill = {}
				self._entity._behavior:Clear(eEBGotodead)
				if self._entity._hp == 0 then
					self._entity:OnDead();
				end
			end
		end
	end
end

------------------------------------------------------
function i3k_ai_trigger_mgr_create(entity)
	return i3k_ai_trigger_mgr.new(entity);
end

