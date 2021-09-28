--当前已拥有的技能Vo
SkillMsgVo =BaseClass()

function SkillMsgVo:__init()
	self.isInited = true
	self.id = -1 --技能ID
	self.level = 0 --技能等级
	self.mastery = 0 --技能熟练度
end

function SkillMsgVo:SetVo(data)
	if data ~= nil then
		if data.mwSkillId and data.mwSkillId ~= 0 then
			self.id = data.mwSkillId
		else
			self.id = data.skillId or 0
		end
		
		if data.skillId then
			self.skillId = data.skillId
		end

		if data.mwSkillId then
			self.mwSkillId = data.mwSkillId
		end

		self.level = self:GetLevelByID(self.id)
		self.mastery = data.mastery or 0
	end
end

function SkillMsgVo:GetLevelByID(skillId)
	local rtnLev = 0
	local curSkillCfg = SkillModel:GetInstance():GetSkillVo(skillId)
	if curSkillCfg ~= nil then
		rtnLev = curSkillCfg.level
	end
	return rtnLev
end

function SkillMsgVo:ToString()
	
end

function SkillMsgVo:__delete()
	self.isInited = false
end
