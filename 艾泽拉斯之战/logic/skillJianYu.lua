local skill_base = include("skillbase")
local skillJianYu = class("skillJianYu",skill_base)

function skillJianYu:ctor(id)
	skillJianYu.super.ctor(self,id)	
end

function skillJianYu:enterStart()
	
	self.caster:getActor():ClearAttackTargetActors()		
	self.caster.m_Targets = {}
	self.caster.m_TargetsDamage = {}
	self.currentTarget = 0;
		
	local skillname = dataConfig.configs.skillConfig[self.skillId].actionName
		
	if self.skillId == enum.SKILL_TABLE_ID.AoShuFeiDan then
		self.timeInterval = 100;
		self.startTime = 1300;
		self.aoeAttName = "aofaS_feidan01.att";
	elseif self.skillId == enum.SKILL_TABLE_ID.JianYu then
		self.timeInterval = 100;
		self.startTime = 1500;
		self.aoeAttName = "youxiaA_jianyu.att";
	end
	
	self.m_SkillPlayed = false;
	
	-- 由于要判断回调，所以要加入target中判断
	for k,v in ipairs(self.targets) do
	
		local targetUnit = sceneManager.battlePlayer():getCropsByIndex(v.target.id);
		targetUnit.HIT_CALLBACK_FINISH = targetUnit.HIT_CALLBACK_FINISH + 1;
		sceneManager.battlePlayer():signGrid(targetUnit.m_PosX, targetUnit.m_PosY, "r");
		self.caster.m_TargetsDamage[k] = v;
		self.caster.m_Targets[k]= targetUnit;
	end
	
	--local cameraActors = self:getCameraActorNamesFromOrignal();
	--local isPlayCamera = false;
	--if self.targets[1] then
		--dump(self.targets[1]);
	--	isPlayCamera = self:isPlayCamera(self.targets[1].target.damageFlag);
	--end
	
	--if isPlayCamera then
	--	self.m_SkillPlayedTime = self.caster:getActor():PlaySkill(skillname,false,false,1, -1, -1, cameraActors);
	--else
	--	self.m_SkillPlayedTime = self.caster:getActor():PlaySkill(skillname,false,false,1, -1, -1, "");
	--end
	self:playSkill(self.caster, self.skillId, self.targets[1].target.damageFlag, -1, -1);
	
	self:displayname();
		
	self.timeStamp = 0;
	self.currentStage = 0;
end

function skillJianYu:OnTick(dt)
	
	if self.m_SkillPlayedTime > 0 then
		self.m_SkillPlayedTime = self.m_SkillPlayedTime - dt;
	else
		self.m_SkillPlayedTime = 0;
	end
	
	local firstAtt = false;
	
	if self.currentStage == 0 then
		if self.timeStamp > self.startTime then
			self.timeStamp = 0;
			self.currentStage = 1;
			self.m_SkillPlayed = true;
			firstAtt = true;
		else
			self.timeStamp = self.timeStamp + dt;
		end
	elseif self.currentStage == 1 then
		local targetCount = #self.targets;
		
		if self.m_SkillPlayed == true then
			if self.timeStamp > self.timeInterval or firstAtt then
				self.timeStamp = 0;
				
				if self.currentTarget < targetCount then
		
					self.currentTarget = self.currentTarget + 1;
					local v = self.targets[self.currentTarget];
				
					local targetUnit = sceneManager.battlePlayer():getCropsByIndex(v.target.id);
					local casterUnit = self.caster;
					
					print("skillJianYu addatt: targetindex:"..self.currentTarget);
					targetUnit:getActor():AddSkillAttack(self.aoeAttName, casterUnit:getActor(),true, enum.SKILL_CALLBACK_TYPE.SCT_SKIILL_CONSECUTIVE, self.currentTarget);
				else
					self.m_SkillPlayed = false;
				end
				
			else
				self.timeStamp = self.timeStamp + dt;
			end
		end
				
		if self.m_SkillPlayed == false and ___targertHurtEnd(self.caster) and self.m_SkillPlayedTime <= 0 then
			self:enterEnd();
			return true;
		end
	end
	
	return false;
	
end

return skillJianYu;