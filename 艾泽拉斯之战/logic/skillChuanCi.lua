local skill_base = include("skillbase")
local skillChuanCi = class("skillChuanCi",skill_base)

function skillChuanCi:ctor(id)
	skillChuanCi.super.ctor(self,id)
end

function skillChuanCi:enterStart()
	
	self.caster:getActor():ClearAttackTargetActors()		
	self.caster.m_Targets = {}
	self.caster.m_TargetsDamage = {}
		
	local skillname = dataConfig.configs.skillConfig[self.skillId].actionName;
	
	--local cameraActors = self:getCameraActorNamesFromOrignal();
	local isPlayCamera = false;
	--if self.targets[1] then
	--	isPlayCamera = self:isPlayCamera(self.targets[1].target.damageFlag);
	--end
	
	--if isPlayCamera then
	--	self.m_SkillPlayedTime = self.caster:getActor():PlaySkill(skillname,false,false,1, -1, -1, cameraActors);
	--else
	--	self.m_SkillPlayedTime = self.caster:getActor():PlaySkill(skillname,false,false,1, -1, -1, "");
	--end
	self:playSkill(self.caster, self.skillId, self.targets[1].target.damageFlag, enum.SKILL_CALLBACK_TYPE.SCT_INVALID, -1);
	
	self:displayname();
	
	self.targetChuanCiFlag = {};
	self.startChuanCiFlag = {};
	
	self.timeStamp = 0;
	self.START_CHUANCI_TIME = 860;
	self.CHUANCI_STATE = enum.CHUANCI_STATE.BEFORE_CAST;
	self.CHUANCI_SPEED = 17; -- m/s
end

function skillChuanCi:OnTick(dt)

	if self.m_SkillPlayedTime > 0 then
		self.m_SkillPlayedTime = self.m_SkillPlayedTime - dt;
	end
	
	
	if self.CHUANCI_STATE == enum.CHUANCI_STATE.BEFORE_CAST then
			
		if self.timeStamp >= self.START_CHUANCI_TIME then
			self.timeStamp = 0;
			self.CHUANCI_STATE = enum.CHUANCI_STATE.CAST;
		else
			self.timeStamp = self.timeStamp + dt;
		end
		
	elseif self.CHUANCI_STATE == enum.CHUANCI_STATE.CAST then
		
		local currentChuanCiDis = self.CHUANCI_SPEED * self.timeStamp * 0.001;
		
		-- square
		currentChuanCiDis = currentChuanCiDis * currentChuanCiDis;
		
		for k,v in ipairs(self.targets) do
			local targetUnit = sceneManager.battlePlayer():getCropsByIndex(v.target.id);
			local casterUnit = self.caster;
			local disSquare = targetUnit:disSquareToUnit(casterUnit);
			--print("disSquare "..disSquare);
			--print("currentChuanCiDis "..currentChuanCiDis);
			
			if currentChuanCiDis >= disSquare and self.startChuanCiFlag[k] ~= true then
				targetUnit:startChuanCi(v, casterUnit);
				self.startChuanCiFlag[k] = true;
			end
			
			if self.startChuanCiFlag[k] then
				self.targetChuanCiFlag[k] = targetUnit:onChuanCi(dt);
			end
			
		end
		
		self.timeStamp = self.timeStamp + dt;
	end
	
	--playskill的时间结束，并且所有目标都落回到地上才算完成	
	local allTargetOver = true;
	for k,v in ipairs(self.targetChuanCiFlag) do
		if v == false then
			allTargetOver = false;
			break;
		end
	end
	
	if self.m_SkillPlayedTime <= 0 and allTargetOver then
		self:enterEnd();
		return true;
	else
		return false;
	end

end

return skillChuanCi;