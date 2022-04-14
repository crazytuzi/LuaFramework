--
-- @Author: LaoY
-- @Date:   2018-09-26 10:35:02
--
SkillModel = SkillModel or class("SkillModel",BaseModel)
local SkillModel = SkillModel

function SkillModel:ctor()
	SkillModel.Instance = self
	self:Reset()
end

function SkillModel:Reset()
	self.skill_list = {}
end

function SkillModel.GetInstance()
	if SkillModel.Instance == nil then
		SkillModel()
	end
	return SkillModel.Instance
end

function SkillModel:SetSkillList(skill_list)
	self.skill_list = skill_list
end

function SkillModel:GetSkillList()
	return self.skill_list
end

function SkillModel:GetSkillByIndex(index)
	return self.skill_list[index+4]
end

function SkillModel:GetSkillGetLvByIdx(idx)
	local sex=RoleInfoModel.Instance:GetSex()
	local lv=0
	local list=Config.db_skill_get
	for k,v in pairs(list) do
		if v.slot==idx and v.career==sex then
			lv=v.level
			break
		end
	end
	return lv
end