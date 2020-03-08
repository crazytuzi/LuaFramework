FightSkill.AdditionAnalyse = FightSkill.AdditionAnalyse or {}
local tb = FightSkill.AdditionAnalyse
tb.tbAnalysis     = tb.tbAnalysis or {}
tb.tbAdditionList = tb.tbAdditionList or {}
tb.tbIsInList = tb.tbIsInList or {}

function tb:AnalyseAddition(nSourceSkill, nLevel)
	if self.tbAnalysis[nSourceSkill * 10000 + nLevel] then
		return
	end
	local tbSkillMagic = KFightSkill.GetSkillAllMagic(nSourceSkill, nLevel)
	if not tbSkillMagic then
		return
	end
	for _, tbInfo in pairs(tbSkillMagic) do
		if tbInfo.szName == "buff_addition" then
			local nTargetSkill = tbInfo.tbValue[1]
			if not self.tbIsInList[nTargetSkill * 10000 + nSourceSkill] then
				self.tbAdditionList[nTargetSkill] = self.tbAdditionList[nTargetSkill] or {}
				table.insert(self.tbAdditionList[nTargetSkill], nSourceSkill)
				self.tbIsInList[nTargetSkill * 10000 + nSourceSkill] = true
			end
			break
		end
	end
	self.tbAnalysis[nSourceSkill * 10000 + nLevel] = true
end

function tb:GetAdditionList(nTargetSkill)
	return self.tbAdditionList[nTargetSkill] or {}
end

function tb:IsHaveAdditionValid(nSkillId)
	for _, nBuffAddSkillId in pairs(self:GetAdditionList(nSkillId)) do
		local tbState = me.GetNpc().GetSkillState(nBuffAddSkillId)
		if tbState and tbState.nEndFrame ~= 0 then
			return true
		end
	end
end

function tb:GetAdditionDesc(nAdditionId)
	if not self.tbSetting then
		self.tbSetting = {}
		local tbFile = Lib:LoadTabFile("Setting/Skill/BuffAddition.tab", {Id = 1})
		for _, tbInfo in ipairs(tbFile) do
			local nId = tbInfo.Id
			if self.tbSetting[nId] then
				self.tbSetting[nId] = string.format("%s\n%s", self.tbSetting[nId], tbInfo.Desc)
			else
				self.tbSetting[nId] = tbInfo.Desc
			end
		end
	end
	return self.tbSetting[nAdditionId] or ""
end

function tb:GetSkillAdditionDesc(nSkillId, nSkillLevel)
	local tbDesc = {}
	for _, nBuffAddSkillId in pairs(self:GetAdditionList(nSkillId)) do
		local tbState = me.GetNpc().GetSkillState(nBuffAddSkillId)
		if tbState and tbState.nEndFrame ~= 0 then
			local nLevel = me.GetSkillLevel(nBuffAddSkillId)
			nLevel = math.max(1, nLevel)
			local tbSkillMagic = KFightSkill.GetSkillAllMagic(nBuffAddSkillId, nLevel)
			for _, tbInfo in pairs(tbSkillMagic or {}) do
				if tbInfo.szName == "buff_addition" then
					table.insert(tbDesc, self:GetAdditionDesc(tbInfo.tbValue[2]))
				end
			end
		end
	end
	return table.concat(tbDesc, "\n")
end