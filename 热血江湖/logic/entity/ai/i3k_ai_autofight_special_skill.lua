----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;
------------------------------------------------------
--PreCommand
--ePreTypeCommonattack	= 0	--普通攻击
--ePreTypeBindSkill1	= 1	--绑定技能1
--ePreTypeBindSkill2	= 2	--绑定技能2
--ePreTypeBindSkill3	= 3	--绑定技能3
--ePreTypeBindSkill4	= 4	--绑定技能4
--ePreTypeDodgeSkill	= 5	--轻功
--ePreTypeDIYSkill	= 6	--自定义技能
--ePreTypeClickMove	= 7	--点击移动
--ePreTypeJoystickMove	= 8	--摇杆移动
--ePreTypeResetMove	= 9	--强制复位
------------------------------------------------------
i3k_ai_autofight_special_skill = i3k_class("i3k_ai_autofight_special_skill", BASE);
function i3k_ai_autofight_special_skill:ctor(entity)
	self._type	= eAType_AUTOFIGHT_SKILL;
	self._lastattackID = -1
	self._SkillCheck = false
end

function i3k_ai_autofight_special_skill:IsValid()
	local entity = self._entity;
	if entity._AutoFight == false then
		self._lastattackID = -1
		self._entity._attackID = -1
		return false
	end
	
	if g_i3k_game_context:GetjoystickMoveState() then
		return false
	end

	if entity:IsDead() or not entity:CanAttack() then
		return false;
	end

	if entity._superMode.valid then
		return false
	end

	if entity._missionMode.valid then
		return false
	end
	if g_i3k_game_context:GetWorldMapType() == g_CATCH_SPIRIT then
		return false
	end

	if entity._PreCommand == ePreTypeClickMove or entity._PreCommand == ePreTypeResetMove then
		return false;
	end

	return entity:CanUseSkill() and not entity._curSkill or entity._maunalSkill;
end

function i3k_ai_autofight_special_skill:OnEnter()
	if BASE.OnEnter(self) then
		if self._entity._superMode.valid then
			self:SetSkill();
			return true
		end

		if self._entity._PreCommand ~= -1 then
			return true
		end

		if self._entity._maunalSkill then
			for k,v in pairs(self._entity._attacks) do
				if v._id == self._entity._maunalSkill._id then
					self._entity:UseSkill(v);
					return false;
				end
			end
		end

		self._SkillCheck = false
		self._lastattackID = self._entity._attackID
		while not self._SkillCheck do
			self:GetSkillCheck()	
		end
		--if self._entity._attackID == lastattackID then 
			self:SetSkill();
		--end
		return true;
	end

	return false;
end

function i3k_ai_autofight_special_skill:OnLeave()
	if BASE.OnLeave(self) then
		return true;
	end

	return false;
end

function i3k_ai_autofight_special_skill:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function i3k_ai_autofight_special_skill:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		return false; -- only one frame
	end

	return false;
end

function i3k_ai_autofight_special_skill:SetSkill()
	local entity = self._entity;
	local nid = entity._attackID

	local sid = entity._attackLst[nid];
	if nid == 0 then
		sid = 0
		entity._attackID = entity._attackID + 1
	end
	if entity._behavior:Test(eEBSilent) then
			sid = 0
	end
	if sid then
		local skill = nil;
		
		if sid == 0 then
			skill = entity:GetAttackSkill();
		elseif sid == SKILL_DIY then
			skill = entity._DIYSkill
		--elseif entity._anqiSkill and sid == entity._anqiSkill._id then
			--skill = entity._anqiSkill
		else
			skill = entity._skills[sid];
		end

		if skill then
			entity:UseSkill(skill);
		end
	end
end

function i3k_ai_autofight_special_skill:GetSkillCheck()
	local entity = self._entity;

	if entity._maunalSkill then
		entity:UseSkill(entity._maunalSkill);
		entity._maunalSkill = nil;
		self._SkillCheck = true
	else
		local nid = entity._attackID + 1;
		if nid == nil or nid < 1 or nid > #entity._attackLst then
			--if nid ~= 0 then
				nid = 1;
			--end
		end

		local sid = entity._attackLst[nid];
		if #entity._attackLst == 0 then
			sid = 0
		end
		if entity._behavior:Test(eEBSilent) then
			sid = 0
			self._SkillCheck = true
		end
		if sid then
			local skill = nil;
			if sid == 0 then
				skill = entity:GetAttackSkill();
			elseif sid == SKILL_DIY then
				skill = entity._DIYSkill
			--elseif entity._anqiSkill and sid == entity._anqiSkill._id then
				--if g_i3k_game_context:getAnqiSkillIsCanUse() then
					--skill = entity._anqiSkill
				--end
			else
				skill = entity._skills[sid];
			end

			if skill and skill:CanUse() then
				--entity._attackID = nid;
				self._SkillCheck = true
			end
			entity._attackID = nid
			if self._lastattackID == -1 then
				self._lastattackID = nid
			end
			if (nid == self._lastattackID and not self._SkillCheck) or #entity._attackLst == 0 then
				entity._attackID = 0;
				self._SkillCheck = true
			end
		end
	end
end

function create_component(entity, priority)
	return i3k_ai_autofight_special_skill.new(entity, priority);
end
