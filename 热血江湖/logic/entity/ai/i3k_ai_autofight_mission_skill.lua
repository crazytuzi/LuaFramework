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
i3k_ai_autofight_mission_skill = i3k_class("i3k_ai_autofight_mission_skill", BASE);
function i3k_ai_autofight_mission_skill:ctor(entity)
	self._type	= eAType_AUTOFIGHT_MISSION_SKILL;
	self._lastattackID = -1
	self._SkillCheck = false
end

function i3k_ai_autofight_mission_skill:IsValid()
	local entity = self._entity;
	if not entity._missionMode or not entity._missionMode.valid then
		return false
	end

	if entity._AutoFight == false then
		self._lastattackID = -1
		self._entity._missionMode.skillIdx = -1
		return false
	end

	if entity:IsDead() or not entity:CanAttack() then
		return false;
	end

	if entity._PreCommand == ePreTypeClickMove or entity._PreCommand == ePreTypeResetMove then
		return false;
	end

	return entity:CanUseSkill() and not entity._curSkill or entity._maunalSkill;
end

function i3k_ai_autofight_mission_skill:OnEnter()
	if BASE.OnEnter(self) then

		--[[if self._entity._PreCommand ~= -1 then
			return true
		end--]]

		if self._entity._maunalSkill then
			for k,v in pairs(self._entity._missionMode.skills) do
				if v._id == self._entity._maunalSkill._id then
					self._entity:UseSkill(v);
					return false;
				end
			end
			for k,v in pairs(self._entity._missionMode.attacks) do
				if v._id == self._entity._maunalSkill._id then
					self._entity:UseSkill(v);
					return false;
				end
			end
		end

		self._SkillCheck = false
		self._lastattackID = self._entity._missionMode.skillIdx
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

function i3k_ai_autofight_mission_skill:OnLeave()
	if BASE.OnLeave(self) then
		return true;
	end

	return false;
end

function i3k_ai_autofight_mission_skill:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function i3k_ai_autofight_mission_skill:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		return false; -- only one frame
	end

	return false;
end

function i3k_ai_autofight_mission_skill:SetSkill()
	local entity = self._entity;
	if self._entity._missionMode.skillIdx then
		local skill = nil;
		if self._entity._missionMode.skillIdx == 0 then
			if entity._missionMode and entity._missionMode.attacksIdx then
				entity._missionMode.attacksIdx = entity._missionMode.attacksIdx + 1
				if entity._missionMode.attacksIdx > # entity._missionMode.attacks then
					entity._missionMode.attacksIdx = 1;
				end
				skill = entity._missionMode.attacks[entity._missionMode.attacksIdx];
				entity._missionMode.skillIdx = -1;
			end
		else
			skill = entity._missionMode.skillList[entity._missionMode.skillIdx];
		end

		if skill then
			entity:UseSkill(skill);
		end
	end
end

function i3k_ai_autofight_mission_skill:GetSkillCheck()
	local entity = self._entity;

	if entity._maunalSkill then
		entity:UseSkill(entity._maunalSkill);
		entity._maunalSkill = nil;
		self._SkillCheck = true
	else
		local sid = entity._missionMode.skillIdx + 1;
		if sid == nil or sid < 1 or sid > #entity._missionMode.skillList then
			sid = 1;
		end

		if #entity._missionMode.skillList == 0 then
			sid = 0
		end
		if entity._behavior:Test(eEBSilent) then
			sid = 0
			self._SkillCheck = true
		end
		if sid then
			local skill = nil;
			if sid == 0 then
				if entity._missionMode and entity._missionMode.attacksIdx then
					entity._missionMode.attacksIdx = entity._missionMode.attacksIdx + 1
					if entity._missionMode.attacksIdx > # entity._missionMode.attacks then
						entity._missionMode.attacksIdx = 1;
					end
					skill = entity._missionMode.attacks[entity._missionMode.attacksIdx];
				end
			else
				skill = entity._missionMode.skillList[sid];
			end

			if skill and skill:CanUse() then
				--entity._attackID = nid;
				self._SkillCheck = true
			end
			entity._missionMode.skillIdx = sid
			if self._lastattackID == -1 then
				self._lastattackID = sid
			end
			if (sid == self._lastattackID and not self._SkillCheck) or #entity._missionMode.skillList == 0 then
				entity._missionMode.skillIdx = 0;
				self._SkillCheck = true
			end
		end
	end
end

function create_component(entity, priority)
	return i3k_ai_autofight_mission_skill.new(entity, priority);
end
