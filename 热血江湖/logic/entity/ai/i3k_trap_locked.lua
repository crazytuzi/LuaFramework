----------------------------------------------------------------
module(..., package.seeall)

local require = require

--local baseModule = require("logic/entity/ai/i3k_trap_Closed");
local baseModule = require("logic/entity/ai/i3k_trap_base");

------------------------------------------------------
i3k_trap_Locked = i3k_class("i3k_trap_Locked", baseModule.i3k_trap_base);
function i3k_trap_Locked:ctor(entity)
	self._entity	= entity;
	self._type = eSTrapLocked;
	self._turnOn	= false;
	self.TransLogic	= 0;
end

function i3k_trap_Locked:OnEnter()
	if self.__super.OnEnter(self) then
		if self._entity._gcfg_base.Action1 ~= "" then
			self._entity:Play(self._entity._gcfg_base.Action1, -1);
		else
			self._entity:Play(i3k_db_common.engine.defaultStandAction, -1);
		end
		if self._entity._gcfg_external.ActiveTransLogic1 ~= -1 then
			self.TransLogic = self._entity._gcfg_external.ActiveTransLogic1;
		end
		self._entity._trapinit = false;
		self:CheckEventProcessPro()
		return true;
	end

	return false;
end

function i3k_trap_Locked:OnLeave()
	if self.__super.OnLeave(self) then
		self:CheckEventProcessEnd()
		return true;
	end

	return false;
end

function i3k_trap_Locked:OnUpdate(dTime)

	return false;
end

function i3k_trap_Locked:OnLogic(dTick)
	if not self:IsValid() then
		return false;
	end

	if self.TransLogic ~= 0 and self._turnOn then
		self:CheckEventProcess()
	end
	return true;
end

function i3k_trap_Locked:CheckEventProcessPro()
	if self._entity._LogicId ~= -1 then
		if self._entity._activeonce then
			local gcfg = i3k_db_trap_exchange;
						--local Targets = self._entity:GetProperty(ePropID_TargetId);
			local targetIDs = self._entity:GetTarget()
			local target = {}
			local logic = i3k_game_get_logic();
			local world = logic:GetWorld();
			if world then
				for m,n in pairs(targetIDs) do
					for p,q in pairs(world._Traps) do
						local guid = string.split(q._guid, "|")
						if tonumber(guid[2]) == n then
							table.insert(target,q)
						end
					end
				end
			end
			for k,v in pairs(target) do
				local trapid = v._gid;
				for p,q in pairs(gcfg) do
					if q.trapid == trapid and q.trapgroup == v._LogicId and q.lockedmode ~= -1 then
						local logic = i3k_game_get_logic();
						if logic then
							local world = logic:GetWorld();
							if world then
								if q.lockedmode == eSTrapAttack then
									local args = {trapID = v._gid,trapState = eSTrapClosed};
									i3k_sbean.sync_privatemap_trap(args)
								else
									local args = {trapID = v._gid,trapState = q.lockedmode};
									i3k_sbean.sync_privatemap_trap(args)
								end	
							end
						end
						v:SetTrapBehavior(q.lockedmode,false);
					end
				end
			end
		else
			self._entity._activeonce = true;
		end
	end
end 

function i3k_trap_Locked:CheckEventProcess()
	--当条件不满足的时候没满足一条将变动属性，当属性都满足时切换状态
	if self._entity:GetTransLogic() ~= self.TransLogic then
		--if bit.band(self.TransLogic,eTrapTransAreaClear) ~= 0 then
			--暂时由Spawn内的release和Close来影响，如有需要在此处添加其他逻辑
		--end
		--if bit.band(self.TransLogic,eTrapTransLinkActive) ~= 0 then

		--end
	else
		self._turnOn = false;
		self._entity:ClearTransLogic();
		local logic = i3k_game_get_logic();
		if logic then
			local world = logic:GetWorld();
			if world then
				local args = {trapID = self._entity._gid,trapState = eSTrapActive};
				i3k_sbean.sync_privatemap_trap(args)
			end	
		end
		self._entity:SetTrapBehavior(eSTrapActive,true);

	end
end 

function i3k_trap_Locked:CheckEventProcessEnd()
end

function create_component(entity, priority)
	return i3k_trap_Locked.new(entity, priority);
end

