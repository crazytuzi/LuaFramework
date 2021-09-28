----------------------------------------------------------------
module(..., package.seeall)

local require = require

--local baseModule = require("logic/entity/ai/i3k_trap_Closed");
local baseModule = require("logic/entity/ai/i3k_trap_base");

------------------------------------------------------
i3k_trap_Active = i3k_class("i3k_trap_Active", baseModule.i3k_trap_base);
function i3k_trap_Active:ctor(entity)
	self._entity	= entity;
	self._type = eSTrapActive;
	self._turnOn	= false;
	self.TransLogic	= 0;
end

function i3k_trap_Active:OnEnter()
	if self.__super.OnEnter(self) then
		if self._entity._gcfg_base.Action2 ~= "" then
			self._entity:Play(self._entity._gcfg_base.Action2, -1);
		else
			self._entity:Play(i3k_db_common.engine.defaultRunAction, -1);
		end
		if self._entity._gcfg_external.ActiveTransLogic2 ~= -1 then
			self.TransLogic = self._entity._gcfg_external.ActiveTransLogic2;
		end
		self._entity._trapinit = false;
		self:CheckEventProcessPro()
		return true;
	end
	return false;
end

function i3k_trap_Active:OnLeave()
	if self.__super.OnLeave(self) then
		self:CheckEventProcessEnd()
		return true;
	end

	return false;
end

function i3k_trap_Active:OnUpdate(dTime)
	--self._entity.OnUpdate(self, dTime);

	return false;
end

function i3k_trap_Active:OnLogic(dTick)
	
	if not self:IsValid() then
		return false;
	end
	
	if self.TransLogic ~= 0 then
		self:CheckEventProcess()
	end

	return true;
end

function i3k_trap_Active:OnDamage(attacker, affectType, showInfo)
	if attacker then
		--self:ShowInfo(eEffectID_Immune.style, eEffectID_Immune.txt);
	end
end

function i3k_trap_Active:CheckEventProcessPro()
	local ntype = self._entity._ntype
	if ntype == eEntityTrapType_Barrier then
		if self._entity._obstacle then

		else
			if self._entity._obstacleValid then
				local obstacle = require("logic/battle/i3k_obstacle");
				self._entity._obstacle = obstacle.i3k_obstacle.new(i3k_gen_entity_guid_new(obstacle.i3k_obstacle.__cname,i3k_gen_entity_guid()));
				if self._entity._obstacle:Create(self._entity._gcfg_external.Pos, self._entity._gcfg_external.Direction, self._entity._gcfg_base.obstacleType, self._entity._gcfg_base.obstacleArgs) then
					self._entity._obstacle:Show(false, true,10);
				else
					self._entity._obstacle = nil;
				end
			end
		end
	end

	if self._entity._LogicId ~= -1 then
		if self._entity._activeonce then
			local gcfg = i3k_db_trap_exchange;
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
					if q.trapid == trapid and q.trapgroup == v._LogicId and q.activemode ~= -1 then
						local logic = i3k_game_get_logic();
						if logic then
							local world = logic:GetWorld();
							if world then
								if q.activemode == eSTrapAttack then
									local args = {trapID = v._gid,trapState = eSTrapClosed};
									i3k_sbean.sync_privatemap_trap(args)
								else
									--hdr:SendCmd(eMAP_PRIVATE_TRAP,v._gid,q.activemode);
									local args = {trapID = v._gid,trapState = q.activemode};
									i3k_sbean.sync_privatemap_trap(args)
								end
							end
						end
						v:SetTrapBehavior(q.activemode,false);
					end
				end
			end
		else
			self._entity._activeonce = true;
		end
	end
end

function i3k_trap_Active:CheckEventProcess()
	if self._entity:GetTransLogic() ~= self.TransLogic then
	--	if bit.band(self.TransLogic,eTrapTransAreaClear) ~= 0 then
			--𨱌傛椂鐢盨pawn鍐呯殑release鍜孋lose𨱒ュ奖鍝嶏纴濡傛湁闇€瑕佸湪姝ゅ娣诲姞鍏朵粬阃昏緫
	--	end
	--	if bit.band(self.TransLogic,eTrapTransLinkActive) ~= 0 then

	--	end
	else
		self._turnOn = false;
		self._entity:ClearTransLogic();
		local logic = i3k_game_get_logic();
		if logic then
			local world = logic:GetWorld();
			if world then
				local args = {trapID = self._entity._gid,trapState = eSTrapClosed};
				i3k_sbean.sync_privatemap_trap(args)
			end	
		end
		self._entity:SetTrapBehavior(eSTrapAttack,true);
	end

	if ntype == eEntityTrapType_Boomer then
		-----------------------TODO 娣诲姞Boomer锣冨洿妫€娴嬩富瑙?
		local dungeon = logic:GetWorld();
		if dungeon then
			local targets = dungeon:GetAliveEntities(self,eGroupType_O);
			for k, v in pairs(targets) do
				if v then
					local dist = i3k_vec3_sub1(v.entity._curPos, self._curPos);
					if self._skill._range > i3k_vec3_len(dist) then
						local logic = i3k_game_get_logic();
						if logic then
							local world = logic:GetWorld();
							if world then
								local args = {trapID = self._entity._gid,trapState = eSTrapClosed};
								i3k_sbean.sync_privatemap_trap(args)
							end	
						end	
						self._entity:SetTrapBehavior(eSTrapAttack,true);			
					end
				end
			end
		end
	end
end 

function i3k_trap_Active:CheckEventProcessEnd()
end

function create_component(entity, priority)
	return i3k_trap_Active.new(entity, priority);
end
