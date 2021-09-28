----------------------------------------------------------------
module(..., package.seeall)

local require = require
local testindex = 0;
--local baseModule = require("logic/entity/ai/i3k_trap_base");
require("i3k_global");
--require("logic/entity/i3k_entity_trap_def");
local baseModule = require("logic/entity/ai/i3k_trap_base");


------------------------------------------------------
i3k_trap_Closed = i3k_class("i3k_trap_Closed",baseModule.i3k_trap_base);
function i3k_trap_Closed:ctor(entity)
	self._entity	= entity;
	self._turnOn	= false;
	self._type = eSTrapClosed;
end

function i3k_trap_Closed:OnEnter()
	if self.__super.OnEnter(self) then
		testindex = 0;
		--i3k_log("i3k_trap_Closed:")
		if self._entity._trapinit then
			--i3k_log("i3k_trap_Closed:##########")
			if self._entity._gcfg_base.Action4 ~= "" then
				self._entity:Play(self._entity._gcfg_base.Action4, -1);
			else
				self._entity:Play(i3k_db_common.engine.defaultDeadLoopAction, -1);
			end
			self._entity._trapinit = false;
		end
		self._entity:SetHittable(false)
		self:CheckEventProcess()
		if self._entity._obstacle and self._entity._gcfg_base.TrapType == eEntityTrapType_Barrier then
			self._entity._obstacle:Release()
			self._entity._obstacle = nil;
		end
		return true;
	end
	return false;
end

function i3k_trap_Closed:OnLeave()
	if self.__super.OnLeave(self) then
		return true;
	end

	return false;
end

function i3k_trap_Closed:OnUpdate(dTime)
	if not self:IsValid() then
		return false;
	end
	--self._entity.OnUpdate(self, dTime);
	
	return true;
end

function i3k_trap_Closed:OnLogic(dTick)
	if not self:IsValid() then
		return false;
	end

	return true;
end

function i3k_trap_Closed:IsValid()
	return true
end

function i3k_trap_Closed:CheckEventProcess()
	local ntype = self._entity._ntype
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
					if q.trapid == trapid and q.trapgroup == v._LogicId and q.closedmode ~= -1 then
						local logic = i3k_game_get_logic();
						if logic then
							local world = logic:GetWorld();
							if world then
								if q.closedmode == eSTrapAttack then
									local args = {trapID = v._gid,trapState = eSTrapClosed};
									i3k_sbean.sync_privatemap_trap(args)
								else
									local args = {trapID = v._gid,trapState = q.closedmode};
									i3k_sbean.sync_privatemap_trap(args)
								end
							end
						end
						v:SetTrapBehavior(q.closedmode,false);
					end
				end
			end
		else
			self._entity._activeonce = true;
		end
	end
end 

function create_component(entity, priority)
	return i3k_trap_Closed.new(entity, priority);
end

