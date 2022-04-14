--
-- @Author: lwj
-- @Date:   2018-10-15 19:15:34
--
SkillUIModel = SkillUIModel or class("SkillUIModel", BaseModel)
local SkillUIModel = SkillUIModel

function SkillUIModel:ctor()
    SkillUIModel.Instance = self
    self:Reset()
end

function SkillUIModel:Reset()
    self.skill_List = {}
    self.normalAtkList = {}              --平A列表
    self.isOpenPassive = false           --打开的页面标志
    self.currentSelectId = nil           --当前选中的 用于判断当前所点击的列表技能
    self.curShowDesId = nil               --信息面板中 用于判断当前所显示信息的技能
    self.lastSlotFocus = nil             --技能槽中上一个高亮
    self.curActiveListItemList = nil     --当前的主动技能列表
    self.autoUseChangeList = {}           --自动使用改变的列表
    self.get_skills = {}
    self.is_need_set_default = true         --是否需要设置默认选中的list item
    self.groups = {}
    self.point = 0
    self.talent_skills = {}
    self:AddNormalAtk()

    self.ordinary_skill_list = {}

    self.talent_reset_itemid = 11154
end

function SkillUIModel:GetInstance()
    if SkillUIModel.Instance == nil then
        SkillUIModel()
    end
    return SkillUIModel.Instance
end

function SkillUIModel:SetSkillList(skill_List)
    --dump(skill_List, "<color=#6ce19b>SetSkillList   SetSkillList  SetSkillList  SetSkillListHandleMCInfo</color>")
    self.skill_List = skill_List
end

function SkillUIModel:GetSkillList()
    return self.skill_List
end

-- 普通攻击列表
-- 后面改为收到协议就排序，就不用每次放技能都排序
function SkillUIModel:GetOrdinarySkillList()
    local t = {}
    for k, v in pairs(self.skill_List) do
        --if v.pos == 0 then
        --    t[#t+1] = v
        --end
        if Config.db_skill[v.id] and Config.db_skill[v.id].is_hew == 1 then
            t[#t + 1] = v
        end
    end
    local function sortFunc(a, b)
        return a.id < b.id
    end
    table.sort(t, sortFunc)
    return t
end

function SkillUIModel:AddToSkillList(skill)
    table.insert(self.skill_List, skill)
    self.autoUseChangeList = self.autoUseChangeList or {}
    self.autoUseChangeList[skill.id] = skill.auto_use
end

function SkillUIModel:GetSkillByIndex(index)
    local result = nil
    for i, v in pairs(self.skill_List) do
        if v.pos == index then
            result = v
            break
        end
    end
    return result
end

function SkillUIModel:GetSkillByID(skill_id)
    for i, v in pairs(self.skill_List) do
        if v.id == skill_id then
            return v
        end
    end
    return nil
end

function SkillUIModel:UpdateSKillCd(skill_id, cd)
    local skill = self:GetSkillByID(skill_id)
    if skill then
        Yzprint('--LaoY SkillUIModel.lua,line 90--', skill_id)
        skill.cd = cd
    end
end

function SkillUIModel:GetSlotsList()
    local list = {}
    --for i = 1, 5 do
    --    for ii, vv in pairs(self.skill_List) do
    --        if vv.pos == i then
    --            list[i] = vv
    --            break
    --        end
    --    end
    --end

    -- 改为这个
    for k, v in pairs(self.skill_List) do
        if v.pos ~= 0 then
            list[v.pos] = v
        end
    end
    return list
end

function SkillUIModel:SetCurrentSkillId(id)
    self.currentSelectId = id
end

function SkillUIModel:JudgeIsNormalAtk()
    local isGet = false
    for i = 1, #self.normalAtkList do
        if self.currentSelectId == self.normalAtkList[i] then
            isGet = true
            break
        end
    end
    return isGet
end

function SkillUIModel:AddNormalAtk()
    for i, v in pairs(Config.db_skill) do
        if v.is_hew == 1 then
            self.normalAtkList[#self.normalAtkList + 1] = v.id
        end
    end
end

function SkillUIModel:GetAutoUseInfoById(id)
    return self.autoUseChangeList[id]
end

-- 是否为自动释放技能
function SkillUIModel:IsAutoUseSkill(id)
    return self:GetAutoUseInfoById(id) == 0
end

function SkillUIModel:AddSkillGet(skill)
    table.insert(self.get_skills, skill)
end

function SkillUIModel:DelSkillGet()
    return table.remove(self.get_skills, 1)
end

--检查是否已获得
function SkillUIModel:CheckTheSkillIsGet(id)
    local result = false
    for i, v in pairs(self.autoUseChangeList) do
        if id == i then
            result = true
            break
        end
    end
    return result
end

function SkillUIModel:GetCanShowSlotsList()
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    local cf = Config.db_skill_pos
    local list = {}
    for i = 1, #cf do
        local show_tbl = String2Table(cf[i].show_lv)
        if show_tbl[1] == "level" then
            if lv >= show_tbl[2] then
                list[#list + 1] = cf[i]
            end
        end
    end
    return list
end

function SkillUIModel:GetCurPetSkill()
    local result
    local inter = table.pairsByKey(self.autoUseChangeList)
    for id, _ in inter do
        if Config.db_skill[id].pos == 8 then
            result = id
            break
        end
    end
    return result
end

function SkillUIModel:RemoveSkills(skill_ids)
    for i = 1, #skill_ids do
        local skill_id = skill_ids[i]
        for j = 1, #self.skill_List do
            if self.skill_List[j] and self.skill_List[j].id == skill_id then
                table.remove(self.skill_List, j)
            end
        end
    end
end

function SkillUIModel:IsGetSkill(skill_id)
    local result = false
    for i, v in pairs(self.skill_List) do
        if v.id == skill_id then
            result = true
            break
        end
    end
    return result
end

function SkillUIModel:UpdateCd(cds)
    for skillid, cd in pairs(cds) do
        SkillModel:GetInstance():Brocast(SkillEvent.UPDATE_SKILL_CD, skillid, cd)
    end
end

-------------------------------------------天赋技能---------------------------------------------
function SkillUIModel:FromatTalent()
    for k, v in pairs(Config.db_talent) do
        self.groups[v.sex] = self.groups[v.sex] or {}
        self.groups[v.sex][v.group] = self.groups[v.sex][v.group] or {}
        table.insert(self.groups[v.sex][v.group], v)
    end
end

function SkillUIModel:GetGroups()
    local gender = RoleInfoModel:GetInstance():GetRoleValue("gender")
    local groups = self.groups[gender]
    groups = table.keys(groups)
    table.sort(groups)
    return groups
end

function SkillUIModel:GetGroupSkills(group)
    local gender = RoleInfoModel:GetInstance():GetRoleValue("gender")
    local groups = self.groups[gender]
    local skills = groups[group]
    local function sort_fun(a, b)
        return a.id < b.id
    end
    table.sort(skills, sort_fun)
    return skills
end

function SkillUIModel:SetTalentInfo(data)
    self.point = data.point
    for k, v in pairs(data.skills) do
        self.talent_skills[k] = v
    end
end

function SkillUIModel:GetTotalPoint(group)
    local gender = RoleInfoModel:GetInstance():GetRoleValue("gender")
    local groups = self.groups[gender]
    groups = groups[group]
    local total_point = 0
    for i = 1, #groups do
        local skill_id = groups[i].id
        local level = self.talent_skills[skill_id] or 0
        total_point = total_point + level
    end
    return total_point
end

-----------------------------------------------------------------------------------------------