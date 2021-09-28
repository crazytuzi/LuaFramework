
local Skills = {}
local SkillPoints = 0

local NuQiSkillManager = {}
NuQiSkillManager.SkillType = {}
local Type = NuQiSkillManager.SkillType
Type.GongJi = 1
Type.FangYu = 2
Type.FuZhu = 3
Type.WuShuang = 4

local function CheckActivedSkill(skill, ids)
	-- 学习过的无双技能不属于激活状态
	if skill.level > 0 then
		return false
	end
	for i,v in ipairs(ids) do
		local skillid = tonumber(v)
		if not Skills[skillid] or Skills[skillid].level == 0 then
			return false
		end
	end
	return true
end

local function CheckActivedSkills(skills)
	for i,v in ipairs(skills) do
		local ids = StringBuilder.Split(v.preskill, ",")
		v.active = CheckActivedSkill(v,ids)
	end
end

function NuQiSkillManager.GetSkillsByType(skilltype)
	local skill = {}
	for k,v in pairs(Skills) do
		if v.skilltype == skilltype then
			table.insert(skill, v)
		end
	end
	local sortFunc = function(a, b)
		return a.sort < b.sort
	end
	table.sort(skill, sortFunc)
	if skilltype == Type.WuShuang then
		CheckActivedSkills(skill)
	end
	return skill
end

function NuQiSkillManager.GetInUseSkills()
	local skill = {}
	for k,v in pairs(Skills) do
		if v.inuse then
			table.insert(skill, v)
		end
	end
	local sortFunc = function(a, b)
		return a.sort < b.sort
	end
	return skill
end

function NuQiSkillManager.GetAllSkills()
	return Skills
end

function NuQiSkillManager.InitNuQiSkills(skills)
	local OldSkills = Skills
	Skills = {}
	local SkillTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cnuqi")

	local allskills = SkillTable:getDisorderAllID()
	for i,v in ipairs(allskills) do
		local record = SkillTable:getRecorder(v)
		local skillcell = OldSkills[record.id] or {}
		skillcell.id = record.id
		skillcell.level = skills[record.id] or skillcell.level or 0 -- 优先协议里的等级，然后看客户端保存过的等级
		skillcell.iconid = record.image
		skillcell.passive = record.passive
		skillcell.skilltype = record.type
		skillcell.inuse = skillcell.inuse or false
		skillcell.active = skillcell.active or false
--		skillcell.txt = record.effect
		skillcell.sort = record.sort
		skillcell.preskill = record.preskill
		Skills[record.id] = skillcell
	end
	print("NuQiSkillManager.InitNuQiSkills ")
--[[
	for k,v in pairs(skills) do
		local record = SkillTable:getRecorder(k)
		if record then
			local skillcell = OldSkills[k] or {}
			skillcell.id = k
			skillcell.level = v
			skillcell.iconid = record.image
			skillcell.skilltype = record.type
			skillcell.inuse = false
			skillcell.active = false
			skillcell.txt = record.effect
			skillcell.sort = record.sort
			Skills[k] = skillcell
		end
	end
]]
end

function NuQiSkillManager.ClearSkillData()
	Skills = {}
end

function NuQiSkillManager.InUsesSkills(skills)
	for k,v in pairs(Skills) do
		v.inuse = false
	end
	for k,v in pairs(skills) do
		if Skills[v] then
			Skills[v].inuse = true
		end
	end
end

function NuQiSkillManager.SetPoints(points)
	SkillPoints = points
end
function NuQiSkillManager.GetPoints()
	return SkillPoints
end

function NuQiSkillManager.LearnSkill(skillid)
	if skillid > 0 and Skills[skillid] then
		Skills[skillid].level = 1
	end
end

function NuQiSkillManager.UpgradeSkill(skillid, level)
	if skillid > 0 and Skills[skillid] then
		Skills[skillid].level = level
	end
end

function NuQiSkillManager.GetSkillName(skillid, level)
	local SkillTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cnuqi")
	local name = SkillTable:getRecorder(skillid)
	if name then
		if level and level > 0 then
			return name.name .. MHSD_UTILS.get_resstring(3087+level)
		else
			return name.name
		end
	else
		return ""
	end
end

function NuQiSkillManager.GetSkillDescription(skillid, level)
	local SkillLevelTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cnuqidescription")
	local allskills = SkillLevelTable:getDisorderAllID()
	for i,v in ipairs(allskills) do
		local getskill = SkillLevelTable:getRecorder(v)
		if getskill.skillid == skillid and getskill.grade == level then
			return getskill.description
		end
	end
	-- 如果等级表了没有，从怒气表里读
	local skill = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cnuqi"):getRecorder(skillid)
	if skill then
		return skill.effect
	end
	return ""
end

function NuQiSkillManager.GetSkillMaxLevel(skillid)
	local maxlevel = 0
	local skilltype = Skills[skillid].skilltype
	local SkillUpTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cnuqiup")
	local allids = SkillUpTable:getDisorderAllID()
	for i,v in ipairs(allids) do
		local record = SkillUpTable:getRecorder(v)
		if record.type == skilltype and record.skilllevel > maxlevel then
			maxlevel = record.skilllevel
		end
	end
	return maxlevel
end

return NuQiSkillManager
