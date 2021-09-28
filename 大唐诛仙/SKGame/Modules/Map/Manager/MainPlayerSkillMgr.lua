--角色技能管理
MainPlayerSkillMgr =BaseClass()

function MainPlayerSkillMgr:__init()
	self._comboInfoDic = {}
	self._skillDic = {}
	self._figther = nil
end

function MainPlayerSkillMgr:__delete()
	if self._skillDic then
		for k, v in pairs(self._skillDic) do
			v:Destroy()
		end
		self._skillDic = nil
	end

	self._comboInfoDic = nil
	self._figther = nil
end

function MainPlayerSkillMgr:Init(figther)
	self._figther = figther
end

--根据ID获取技能
function MainPlayerSkillMgr:GetSkillById(skillId)
	return self._skillDic[skillId]
end

--检索技能连击数据
function MainPlayerSkillMgr:IndexComboId(skilId)
   	if self._comboInfoDic[skilId] then
   		local comboInfo = self._comboInfoDic[skilId]
   		local curIndex = comboInfo["curIndex"]
   		local comboCfgData = comboInfo["comboCfgData"]
		local comboSkillList = comboInfo["skillList"]
   		if curIndex + 1 > #comboCfgData then
   			curIndex = 1
   		else
   			curIndex = curIndex + 1
   		end
		comboInfo["curIndex"] = curIndex
		local cfg = comboCfgData[curIndex]
   		return {self._skillDic[cfg[1]], cfg[2]} --返回 技能数据, 连击判定时长
   	end
   	return nil
end

function MainPlayerSkillMgr:ComboIndexReset(skilId)
	if self._comboInfoDic and self._comboInfoDic[skilId] then
		self._comboInfoDic[skilId]["curIndex"] = 0
	end
end

--添加(更新)连招技能
function MainPlayerSkillMgr:AddComboSkill(skillId, combo)
	self._comboInfoDic[skillId] = {}
	local info = self._comboInfoDic[skillId]
	info["comboCfgData"] = combo
	info["skillList"] = {}
	info["curIndex"] = 0


	for i = 1, #combo do
		local skillVo = SkillManager.GetSkillVo(combo[i][1])
		if skillVo then
			local skill = Skill.New()
			skill:Init(self._figther, skillVo, false)
			self._skillDic[combo[i][1]] = skill
		end
	end
end

function MainPlayerSkillMgr:Reset()
	self:RemoveSkillList()
	local normal = self._figther.normalSkillIdList
	if normal ~= nil then
		for i = 1, #normal do
			local vo = normal[i]
			local skillVo = SkillManager.GetSkillVo(vo)
			local skill = Skill.New()
			skill:Init(self._figther, skillVo, false)

			if #skillVo.combo > 0 then
				self:AddComboSkill(vo, skillVo.combo)
			end
			self._skillDic[vo] = skill
		end
	end
	local skills = self._figther.skillIDlist
	if skills ~= nil then
		for j = 1, #skills do
			local vo = skills[j]
			local skillVo = SkillManager.GetSkillVo(vo)
			local skill = Skill.New()
			skill:Init(self._figther, skillVo, false)

			if #skillVo.combo > 0 then
				self:AddComboSkill(vo, skillVo.combo)
			end
			self._skillDic[vo] = skill
		end
	end
end

function MainPlayerSkillMgr:UpdateSkill(oldSkill, newSkill)
	local old = self._skillDic[oldSkill]
	if old then
		if old.needSkillEndCall == true then
			--old:SkillEnd()
		else
			old:Destroy()
		end
		self._skillDic[oldSkill] = nil
	end
	local skillVo = SkillManager.GetSkillVo(newSkill)
	if skillVo then
		local skill = Skill.New()
		skill:Init(self._figther, skillVo, false)
		if #skillVo.combo > 0 then
			self:AddComboSkill(skillVo.un32SkillID, skillVo.combo)
		end
		self._skillDic[newSkill] = skill
	end
end

function MainPlayerSkillMgr:_update()
	
end

--使用技能 by skillId
function MainPlayerSkillMgr:UseSkillById(skillId)
	local v = self:GetSkillById(skillId)
	if v then
		v:UseSkill()
	end
end

--服务器通知主角放技能
function MainPlayerSkillMgr:UseSkillByFightVo(fightVo)
	local skill = self:GetSkillById(fightVo.fightType)
	if skill ~= nil then
		skill:UseSkill(fightVo)
		return
	else

	end
end

function MainPlayerSkillMgr:RemoveSkillList()
	self._comboInfoDic = {}
	if self._skillDic then
		for k, v in pairs(self._skillDic) do
			v:Destroy()
		end
	end
	self._skillDic = {}
end

--根据技能id判断技能是否准备好
function MainPlayerSkillMgr:IsSkillReady( skillId )
	local skill = self:GetSkillById(skillId)
	if skill then
		return skill:IsCD()
	end
	return true
end	

function MainPlayerSkillMgr:Clear()
	self:RemoveSkillList()
end