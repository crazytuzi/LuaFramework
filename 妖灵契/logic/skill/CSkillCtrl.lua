local CSkillCtrl = class("CSkillCtrl", CCtrlBase)

function CSkillCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self:ResetCtrl()
end

function CSkillCtrl.ResetCtrl(self)
		--当前修炼的类型 1~9
	self.m_RecordCultivateType  = 1

	--职业技能，流派1，流派2的技能分开缓存
	self.m_SchoolSkills = {}

	--登录的职业技能缓存，由于服务器先发技能在发门派信息
	self.m_LoginSchoolSkillsCache = {}

	self.m_CultivateSkills = {}
end

--获取指定修炼的本地数据
--@param typ 修炼类型
--@param level,等级
function CSkillCtrl.GetCultivateLocalDataByTypeAndLevel(self, iType, iLevel)
	local t = data.skilldata.CULTIVATTE
	return t[iType][iLevel]
end

--获取指定修炼的等级，经验数据(服务器端数据)
--@param typ 修炼类型
function CSkillCtrl.GetCultivateServerDataByType(self, iType)
	local t = data.skilldata.CULTIVATTE[iType][1]

	return self.m_CultivateSkills[t.skill_id] or {sk = t.skill_id, level = 1, exp = 0}
end

--获取当前职业和流派的技能列表
function CSkillCtrl.GetMySchoolSkillListData(self)
	local t = {}
	local skillList = self.m_SchoolSkills[g_AttrCtrl.school_branch]

	if skillList == nil or next(skillList) == nil then
		self.m_SchoolSkills[g_AttrCtrl.school_branch] = self.m_LoginSchoolSkillsCache
		skillList = self.m_LoginSchoolSkillsCache
	end
	for k, v in pairs(skillList) do
		local baseData = self:GetSkillBaseDataById(v.sk)
		if baseData and next(baseData) and baseData.school_branch == g_AttrCtrl.school_branch then
			t[baseData.skill_pos] = v
		end
	end
	return t
end

--根据门派和流派获取指定职业的技能列表
--@param iSchool 大职业
--@param iSchoolBranch 流派
function CSkillCtrl.GetSchoolSkillListData(self, iSchool, iSchoolBranch)
	local d = data.skilldata.INIT_SKILL
	local t = {}
	for k , v in pairs(d) do
		if v.school == iSchool and v.school_branch == iSchoolBranch then
			table.insert(t, v)
		end
	end
	table.sort(t, function(a,b)
		return a.skill_pos < b.skill_pos
	end)
	return t
end

--根据技能id获取技能的简单信息
--@param id 技能id
function CSkillCtrl.GetSkillBaseDataById(self, id)
	local t = data.skilldata.INIT_SKILL[id] or {}
	return t
end

--根据技能id和等级获取技能的详细信息
--@param id 技能id
--@param level 技能
function CSkillCtrl.GetSkillLevelDataByIdAndLevel(self, id, level)
	--技能等级从0开始
	local t = data.skilldata.SCHOOL[id][level + 1] 
	return t
end

--是否有学习技能(如果没学习技能，则不需要重置技能)
function CSkillCtrl.IsLearnskill(self)
	local b = false
	local t = self:GetMySchoolSkillListData()
	for k, v in pairs(t) do
		if v.level ~= 0 or v.level ~= nil then



			local baseData = self:GetSkillBaseDataById(v.sk)


			if baseData.init_level ~= v.level then
				b = true
				break
			end	
		end
	end
	return b
end

-- 登录技能数据
function CSkillCtrl.LoginSchoolSkill(self, dData)
	print("技能数据登陆协议返回:")
	table.print(dData)

	for k, v in pairs(dData.cultivate) do
		self.m_CultivateSkills[v.sk] = self.m_CultivateSkills[v.sk] or {}
		local skill = v
		skill.level = skill.level or 0
		skill.exp = skill.exp or 0
		self.m_CultivateSkills[skill.sk] = skill
	end


	for k, v in pairs(dData.school) do
		local branch = g_AttrCtrl.school_branch
		
		self.m_SchoolSkills[branch] = self.m_SchoolSkills[branch] or {}
		self.m_SchoolSkills[branch][v.sk] = self.m_SchoolSkills[branch][v.sk] or {}
		local skill = v
		skill.level = skill.level or 0
		skill.type = skill.type or 1
		skill.needcost = skill.needcost or 0
		self.m_SchoolSkills[branch][skill.sk] = skill
		self.m_LoginSchoolSkillsCache[skill.sk] = skill --缓存登录发送的技能
	end
	self:OnEvent(define.Skill.Event.LoginSkill)
end

function CSkillCtrl.RefreshSchoolSkill(self, dSchoolSkill)
	print("技能升级更新协议返回:")
	local branch = g_AttrCtrl.school_branch
	self.m_SchoolSkills[branch] = self.m_SchoolSkills[branch] or {}
	self.m_SchoolSkills[branch][dSchoolSkill.sk] = self.m_SchoolSkills[branch][dSchoolSkill.sk] or{}
	self.m_SchoolSkills[branch][dSchoolSkill.sk] = dSchoolSkill
	self:OnEvent(define.Skill.Event.SchoolRefresh, dSchoolSkill)
end

function CSkillCtrl.RefreshCultivateSkill(self, dCultivateSkill)
	print("修炼技能更新协议返回:")
	table.print(dCultivateSkill)
	self.m_CultivateSkills[dCultivateSkill.sk] = dCultivateSkill
	self:OnEvent(define.Skill.Event.CultivateRefresh, dCultivateSkill)
end

-- 技能 学习修炼技能
function CSkillCtrl.C2GSLearnCultivateSkill(self, sk, count)
	netskill.C2GSLearnCultivateSkill(sk, count)
end

-- 技能 学习职业技能
function CSkillCtrl.C2GSLearnSkill(self, iType, sk)
	netskill.C2GSLearnSkill(iType, sk)
end

-- 技能 重置职业技能
function CSkillCtrl.C2GSWashSchoolSkill(self, iType)
	netskill.C2GSWashSchoolSkill(iType)
end

function CSkillCtrl.IsCanLevelUp(self)
	local b = false
	local d = self:GetMySchoolSkillListData()
	for i = 1, 6 do
		if d[i] ~= nil then			
			local skillLevel = d[i].level
			local skillId = d[i].sk
			local baseData = g_SkillCtrl:GetSkillBaseDataById(skillId)
			local levelData = g_SkillCtrl:GetSkillLevelDataByIdAndLevel(skillId, skillLevel) 
			local nextLevelData = g_SkillCtrl:GetSkillLevelDataByIdAndLevel(skillId, skillLevel + 1) 
			if baseData.unlock_grade <= g_AttrCtrl.grade then
				if nextLevelData and g_AttrCtrl.grade >= nextLevelData.player_level and g_AttrCtrl.skill_point >= levelData.skill_point then
					b = true
					break
				end						
			end
		end
	end
	return b and g_AttrCtrl.skill_point >= 20
end

function CSkillCtrl.GetEquipSkillSetDes(self, skill, level)
	local str = ""
	local t = data.skilldata.EQUIP_SET_SKILL
	if t and next(t) then
		for k, v in pairs(t) do
			if v.skill_id == skill and v.skill_level == level then
				str = v.desc
				break
			end
		end
	end
	return str 
end

return CSkillCtrl
