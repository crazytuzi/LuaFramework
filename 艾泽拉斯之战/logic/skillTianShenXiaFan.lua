local skill_base = include("skillbase")
local skillTianShenXiaFan = class("skillTianShenXiaFan",skill_base)

-- self.startEd 这个标志位必须存在，一定不要删除
function skillTianShenXiaFan:ctor(id)
	skillTianShenXiaFan.super.ctor(self,id)
	self.startEd = false	
end

function skillTianShenXiaFan:enterStart()

	-- change actor
	if self.caster and self.caster:getActor() then
		self.caster:changeActor("shanqiuzhiwang.actor");
		self.m_SkillPlayed = true;
		self:playSkill(self.caster, self.skillId, enum.DAMAGE_FLAG.DAMAGE_FLAG_NORMAL, enum.SKILL_CALLBACK_TYPE.SCT_SKILL_COMMON, self.skillId);
	end
	
	self.startEd = true;
end

function skillTianShenXiaFan:OnTick(dt)

	 local res = true	
			if(self.startEd == true)then					
				res = skillTianShenXiaFan.super.OnTick(self,dt);
			else
				res = false
			end								
	return res			
end


return skillTianShenXiaFan