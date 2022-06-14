local skill_base = include("skillbase")
local skill_Ejection = class("skill_Ejection",skill_base)

function skill_Ejection:ctor(id)
	skill_Ejection.super.ctor(self,id)	
end


function skill_Ejection:enterStart()
	
	self.caster:getActor():ClearAttackTargetActors()		
	self.caster.m_Targets = {}
	self.caster.m_TargetsDamage = {}
	
	self.currentTarget = -1;
	
	local skillname = dataConfig.configs.skillConfig[self.skillId].actionName
	
	local size = #(self.targets)
	if size >= 1 then
		local v = self.targets[1]
		
		self.caster.m_Targets[1] = 	sceneManager.battlePlayer():getCropsByIndex(v.target.id)
		self.caster.m_Targets[1].ejectionHit = false;
		sceneManager.battlePlayer():signGrid(self.caster.m_Targets[1].m_PosX,self.caster.m_Targets[1].m_PosY,"r");
		self.caster.m_TargetsDamage[1] = v;		
			
		self.caster.m_Targets[1].HIT_CALLBACK_FINISH = 1;
		self.caster:getActor():AddAttackTargetActors(self.caster.m_Targets[1].actor,false);
		-- 第1阶段
		self.currentTarget = 1;
		
	end
	
	self.ejectionCasters = {};
	table.insert(self.ejectionCasters, self.caster);
	self.caster.skillIsAoe = false;

	--self.m_SkillPlayedTime = self.caster:getActor():PlaySkill(skillname,false,false,1, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, self.skillId);
	self:playSkill(self.caster, self.skillId, self.targets[1].target.damageFlag, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, self.skillId);
	
	self.m_SkillPlayed = true
		
	self:displayname();
		
end

function skill_Ejection:OnTick(dt)
	
	if self.m_SkillPlayedTime > 0 then
		self.m_SkillPlayedTime = self.m_SkillPlayedTime - dt;
	else
		self.m_SkillPlayedTime = 0;
	end
	
	local targetCount = #self.targets;
	
	if targetCount == 0 then
		return true;
	end
	
	if self.currentTarget > 0 and self.currentTarget <= targetCount then
		
		local v = self.targets[self.currentTarget];
		local targetUnit = sceneManager.battlePlayer():getCropsByIndex(v.target.id);
		if targetUnit and targetUnit.ejectionHit == true then
			-- 当前的击中了，发起下一个
			targetUnit.ejectionHit = false;
			
			self.currentTarget = self.currentTarget + 1;
			if self.currentTarget > targetCount then
				-- 没有下一个了 继续方向检查，是否都播放完
			else
				-- 发起新的一个
				local nextTargetData = self.targets[self.currentTarget];
				local nextTargetUnit = sceneManager.battlePlayer():getCropsByIndex(nextTargetData.target.id);
				nextTargetUnit.ejectionHit = false;

				table.insert(self.ejectionCasters, targetUnit);
				
				if nextTargetUnit then
					
					targetUnit.m_Targets[1]= nextTargetUnit;
					sceneManager.battlePlayer():signGrid(targetUnit.m_Targets[1].m_PosX, targetUnit.m_Targets[1].m_PosY, "r");
					targetUnit.m_TargetsDamage[1] = nextTargetData;			
					targetUnit.m_Targets[1].HIT_CALLBACK_FINISH = 1;
					
					if self.skillId == enum.SKILL_TABLE_ID.TanShe then
						nextTargetUnit:getActor():AddSkillAttack("tanshenvlieshouS_yueren.att",targetUnit:getActor(),true, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, -1);
					elseif self.skillId == enum.SKILL_TABLE_ID.ZhiLiaoBo then
						nextTargetUnit:getActor():AddSkillAttack("wuyiS-zhiliaobo.att",targetUnit:getActor(),true, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, -1);
					elseif self.skillId == enum.SKILL_TABLE_ID.ShanDianLian then
						nextTargetUnit:getActor():AddSkillAttack("anyinglieshouS_shandianlian.att",targetUnit:getActor(),true, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, -1);
					end
							
				end
				return false;
			end
			
		else
			-- 还没击中，直接返回
			return false;
		end
	end
	
	local hurtEnd = true;
	for k, v in pairs(self.ejectionCasters) do
		if not ___targertHurtEnd(v) then
			hurtEnd = false;
			break;
		end
	end
	
	if self.currentTarget > targetCount and hurtEnd  and self.m_SkillPlayedTime <= 0 then
		self:enterEnd();
		return true;
	else
		return false;
	end

	
end

return skill_Ejection;