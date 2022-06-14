local skill_base = include("skillbase")
local skillRepel = class("skillRepel",skill_base)

function skillRepel:ctor(id)
	skillRepel.super.ctor(self,id)
end

function skillRepel:enterStart()
	
	self.caster:getActor():ClearAttackTargetActors()		
	self.caster.m_Targets = {}
	self.caster.m_TargetsDamage = {}
	
	self.repelTarget = nil;
	
	--print("skillRepel:enterStart()")
	--dump(self.targets);
	
	if self.targets and self.targets[1] then
		local skillname = dataConfig.configs.skillConfig[self.skillId].actionName;
	
		self.repelTarget = 	sceneManager.battlePlayer():getCropsByIndex(self.targets[1].target.id);
		
		sceneManager.battlePlayer():signGrid(self.repelTarget.m_PosX, self.repelTarget.m_PosY, "r");	
		table.insert(self.caster.m_TargetsDamage, self.targets[1]);	
		table.insert(self.caster.m_Targets, self.repelTarget);
		
		self.caster:getActor():AddAttackTargetActors(self.repelTarget:getActor(),false);
		
		self:playSkill(self.caster, self.skillId, self.targets[1].target.damageFlag, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, -1);	
	
		self.m_SkillPlayed = true;
	end

end

function skillRepel:OnTick(dt)
	if self.repelTarget == nil then
		return true;
	end
	
	local repelRet = self.repelTarget:onRepel(dt);
	local skillRet = skillRepel.super.OnTick(self, dt);
	
	--print("repelRet "..tostring(repelRet));
	--print("skillRet "..tostring(skillRet));
	
	return  skillRet and repelRet;
end

return skillRepel;