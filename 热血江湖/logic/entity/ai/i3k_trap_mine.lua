----------------------------------------------------------------
module(..., package.seeall)

local require = require

--local baseModule = require("logic/entity/ai/i3k_trap_Closed");
local baseModule = require("logic/entity/ai/i3k_trap_base");


------------------------------------------------------
i3k_trap_mine = i3k_class("i3k_trap_mine", baseModule.i3k_trap_base);
function i3k_trap_mine:ctor(entity)
	self._entity	= entity;
	self._type = eSTrapMine;
	self._turnOn	= false;
	self.TransLogic	= 0;
end

function i3k_trap_mine:OnEnter()
	if self.__super.OnEnter(self) then
		self._entity:Play(i3k_db_common.engine.defaultStandAction, -1);
		self:CheckEventProcessPro()
		return true;
	end
	return false;
end

function i3k_trap_mine:OnLeave()
	if self.__super.OnLeave(self) then
		self:CheckEventProcessEnd()
		return true;
	end

	return false;
end

function i3k_trap_mine:OnUpdate(dTime)
	--self._entity.OnUpdate(self, dTime);

	return false;
end

function i3k_trap_mine:OnLogic(dTick)
	if self.TransLogic ~= 0 then
		self:CheckEventProcess()
	end

	if not self:IsValid() then
		return false;
	end

	return true;
end

function i3k_trap_mine:OnDamage(attacker, affectType, showInfo)
	if attacker then
		--self:ShowInfo(eEffectID_Immune.style, eEffectID_Immune.txt);
	end
end

function i3k_trap_mine:CheckEventProcessPro()
	local ntype = self._entity:GetPropertyValue(ePropID_TrapType)
	if ntype == eEntityTrapType_Barrier then
		if self._entity._obstacle then

		else
			if self._entity._obstacleValid then
				local obstacle = require("logic/battle/i3k_obstacle");
				self._entity._obstacle = obstacle.i3k_obstacle.new(i3k_gen_entity_guid_new(obstacle.i3k_obstacle.__cname,i3k_gen_entity_guid()));
				if self._entity._obstacle:Create(self._gcfg_external.Pos, self._gcfg_external.Direction, self._gcfg_base.obstacleType, self._gcfg_base.obstacleArgs) then
					self._entity._obstacle:Show(false, true,10);
				else
					self._entity._obstacle = nil;
				end
			end
		end
	end
end

function i3k_trap_mine:CheckEventProcess()
end 

function i3k_trap_mine:CheckEventProcessEnd()
end

function create_component(entity, priority)
	return i3k_trap_mine.new(entity, priority);
end

