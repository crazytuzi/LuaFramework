local skill_base = include("skillbase")
local skill_AnSha = class("skill_AnSha",skill_base)

function skill_AnSha:ctor(id)
	skill_AnSha.super.ctor(self,id)	
end


function skill_AnSha:enterStart()
	
	self.caster:getActor():ClearAttackTargetActors()		
	self.caster.m_Targets = {}
	self.caster.m_TargetsDamage = {}
	
	local skillname = dataConfig.configs.skillConfig[self.skillId].actionName
	local damageFlag = -1;
	local size = #(self.targets)
	if size >= 1 then
		local v = self.targets[1]
	
		self.caster.m_Targets[1]= 	sceneManager.battlePlayer():getCropsByIndex(v.target.id)
		sceneManager.battlePlayer():signGrid(self.caster.m_Targets[1].m_PosX,self.caster.m_Targets[1].m_PosY,"r");
		self.caster.m_TargetsDamage[1] = v;		
			
		self.caster.m_Targets[1].HIT_CALLBACK_FINISH = 1;
		self.caster:getActor():AddAttackTargetActors(self.caster.m_Targets[1].actor,false);
		
		damageFlag = v.target.damageFlag;
	end
	

	self.caster.skillIsAoe = false;

	--self.m_SkillPlayedTime = self.caster:getActor():PlaySkill(skillname,false,false,1, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, self.skillId);
	self:playSkill(self.caster, self.skillId, damageFlag, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, self.skillId);
	self.m_SkillPlayed = true
		
	self:displayname();
	
	-- 第0阶段
	self.damageState = 0;
	
	self.extroHitTime = 0;
	
	-- 从第二个开始 九 零  一 起 玩 ww w .9 0  1 7 5. com
	self.currentIndex = 2;
	
	self.hitTimeParam = {};
	
	if self.skillId == enum.SKILL_TABLE_ID.AnSha or 
	  self.skillId == enum.SKILL_TABLE_ID.AnSha2 then
		for i=1, #(self.targets)-1 do
			table.insert(self.hitTimeParam, 2500);
		end
		
	elseif self.skillId == enum.SKILL_TABLE_ID.DuoChongShiFa then

		for i=1, #(self.targets)-1 do
			table.insert(self.hitTimeParam, 100);
		end
				
	end
	
	self.extroHitTime = self.hitTimeParam[self.currentIndex-1] or 0;
			
end

function skill_AnSha:OnTick(dt)
	
	
	self.extroHitTime = self.extroHitTime - dt;
	
	if self.damageState == 0 and ___targertHurtEnd(self.caster) and self.extroHitTime < 0 then
		
		if self.currentIndex > #(self.targets) then
			self.damageState = 1;
		else
			
			self:directDamageByIndex(self.currentIndex);
		
			self.currentIndex = self.currentIndex + 1;
			
			self.extroHitTime = self.hitTimeParam[self.currentIndex-1] or 0;
		end
	end
	
	if self.damageState == 1 and ___targertHurtEnd(self.caster) then

		self:enterEnd();
		return true;
	else

		return false;
	end
end

function skill_AnSha:directDamageByIndex(index)
	
	local v = self.targets[index];
		
	if v then
		self.caster.m_Targets[1] = sceneManager.battlePlayer():getCropsByIndex(v.target.id);
		self.caster.m_TargetsDamage[1] = v;			
		self.caster.m_Targets[1].HIT_CALLBACK_FINISH = 1;
		__directDanmage(self.caster);
	end
		
end

return skill_AnSha;