local magic_base = include("magic");

local magicLianSuoShanDian = class("magicLianSuoShanDian",magic_base)

function magicLianSuoShanDian:ctor(id)
	magicLianSuoShanDian.super.ctor(self,id)
end

magicLianSuoShanDian.AFFECT_TIME = 200;

function magicLianSuoShanDian:enterStart()
			
	self.affectTarget = 1;
	self.affectTime = magicLianSuoShanDian.AFFECT_TIME;
	
	self.caster:getActor():ClearAttackTargetActors()	
	self.caster.m_Targets = {}
	self.caster.m_TargetsDamage = {}
	
	local v = self.targets[1];
	self.caster.m_Targets[1]=  sceneManager.battlePlayer():getCropsByIndex(v.target.id)				
	self.caster.m_TargetsDamage[1]=  v;
	self.caster.m_Targets[1].HIT_CALLBACK_FINISH = 1;
	sceneManager.battlePlayer():signGrid(self.caster.m_Targets[1].m_PosX,self.caster.m_Targets[1].m_PosY,"r")	

	
	self.caster.m_Targets[1]:getActor():AddSkillAttack(self:getMagicAttName(), self.caster:getActor(),true, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, -1);
	--self.caster.m_Targets[1]:getActor():AddSkillAttack("liansuoshandian_mingzhong01.att",self.caster:getActor(),false, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, -1);
		
end

function magicLianSuoShanDian:getMagicAttName()
	if self.skillId == enum.MAGIC_TABEL_ID.LianSuoShanDian then
		return "liansuoshandian.att";
	elseif self.skillId == enum.MAGIC_TABEL_ID.ZhiLiaoBo then
		return "zhiliaobo.att";
	elseif self.skillId == enum.MAGIC_TABEL_ID.QianLiLianSuoShanDian then
		return "liansuoshandian.att";
	elseif self.skillId == enum.MAGIC_TABEL_ID.ShanDianLian then
		return "liansuoshandian.att";
	elseif self.skillId == enum.MAGIC_TABEL_ID.ZengQiangShanDianLian then
		return "liansuoshandian.att";
	end
	
end

function magicLianSuoShanDian:OnTick(dt)
	
	-- return ture is end
	if self.affectTarget > #self.targets and self:isTargetEnd() then	
		return true
	end
	
	if self.affectTime > 0 then
		self.affectTime  = self.affectTime - dt;
	else
		self.affectTime = magicLianSuoShanDian.AFFECT_TIME;
		
		self.affectTarget =  self.affectTarget + 1;
		if self.affectTarget <= #self.targets then		
			local v = self.targets[self.affectTarget];
			local old = self.targets[self.affectTarget-1];

			local targetUnit = sceneManager.battlePlayer():getCropsByIndex(v.target.id);
			local casterUnit = sceneManager.battlePlayer():getCropsByIndex(old.target.id);
			
			casterUnit:getActor():ClearAttackTargetActors()	
			casterUnit.m_Targets = {};
			casterUnit.m_TargetsDamage = {};

			casterUnit.m_Targets[1]=  targetUnit;
			casterUnit.m_TargetsDamage[1]= v;
			casterUnit.m_Targets[1].HIT_CALLBACK_FINISH = 1;
						
			sceneManager.battlePlayer():signGrid(targetUnit.m_PosX, targetUnit.m_PosY,"r");						
			targetUnit:getActor():AddSkillAttack(self:getMagicAttName(), casterUnit:getActor(),true, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, -1);
			--targetUnit:getActor():AddSkillAttack("liansuoshandian_mingzhong01.att",casterUnit:getActor(),false, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, -1);
		end
	end		
	return false;
end

function magicLianSuoShanDian:isTargetEnd()
	
	local targetEnd = true;
	for k,v in ipairs(self.targets) do
		local targetUnit = sceneManager.battlePlayer():getCropsByIndex(v.target.id);
		if ___targertHurtEnd(targetUnit) == false then
			targetEnd = false;
			break;
		end
	end
	
	return targetEnd;
end

return magicLianSuoShanDian;