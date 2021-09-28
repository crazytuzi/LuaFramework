require("app.cfg.skill_info")
local SkillTreeData = class("SkillTreeData")

function SkillTreeData:ctor()
    self.skillList = {}
    self.slotList = {}
    self.ITEM_TYPE = 
    {
        ITEM_BASESKILL = 1,     --基础技能
        ITEM_NORMALSKILL = 2,   -- 普通技能
        ITME_UNIQUESKILL = 3         -- 必杀技
    }

    self.SKILL_TYPE = 
    {
        TYPE_HURT = 1,     --伤害类型
        TYPE_CURE = 2,   -- 治疗类型
        TYPE_AUXILIARY = 3    -- 辅助类型
    }
end

function SkillTreeData:setSkillTree(_data)
    for k,v in pairs(_data) do
        local data = skill_info.get(v.id)
        self.skillList[data.id] = data
        self.skillList[data.id].level = v.level
        if v.slot ~= 0 then
            self.slotList[v.slot] = data.id
        end
    end
end

-- 设置槽位
function SkillTreeData:setSlot(_data)
    dump(_data)
    for k,v in pairs(_data) do
        print("@@@@@@@@@@@@@@@:" .. v.slot)
        self.slotList[v.slot] = v.id
    end
end

-- 洗技能

function SkillTreeData:resetSkill(skill_id)
    for k=1,skilltree_info.getLength() do
        local v = skilltree_info.indexOf(k)
        if v.skill_id == skill_id then
            self.skillList[skill_id] = nil
            break
        end
    end
end
-- 上阵槽位
function SkillTreeData:changSolt(skill_id,slot)
    if self.skillList[skill_id] then 
        self.slotList[slot] = skill_id
        return true
    else
        return false
    end
end


-- 交换槽位
function SkillTreeData:exchangeSolt(slot1,slot2)
    local temp = self.slotList[slot2]
    self.slotList[slot2] = self.slotList[slot1]
    self.slotList[slot1] = temp
end

function SkillTreeData:learnSkill(id,data)
    local _skill_info_data = skill_info.get(data.id)
    self.skillList[_skill_info_data.id] = _skill_info_data
    self.skillList[_skill_info_data.id].level = data.level
    if data.slot > 0 then
        self.slotList[data.slot] = _skill_info_data.id
    end
end

-- 得到槽位信息
function SkillTreeData:getSoltList()
    return self.slotList
end

function SkillTreeData:getSkillLevel(skill_id)
    if self.skillList[skill_id] then
        return self.skillList[skill_id].level
    else
       return 0 
    end
end

function SkillTreeData:getSkillInfoData(skill_id)
    return self.skillList[skill_id]
end
-- 查找技能是否已上阵
function SkillTreeData:isLineUp(skill_id)
    for k,v in pairs(self.slotList) do
        if v == skill_id then
            return true
        end
    end
    return false
end

-- 查找是否学过同类基础技能
function SkillTreeData:findBaseSkill(_type)
    for k=1,skilltree_info.getLength() do
        local v = skilltree_info.indexOf(k)
        if v.func == _type and v.kind_level == self.ITEM_TYPE.ITEM_BASESKILL  then
            
            return (self.skillList[v.skill_id] and true) or false
        end
    end
    return false
end

-- 查找是否学过同类普通技能
function SkillTreeData:findNormalSkill(_type)
    for k=1,skilltree_info.getLength() do
        local v = skilltree_info.indexOf(k)
        if v.func == _type and v.kind_level == self.ITEM_TYPE.ITEM_NORMALSKILL  then
            if self.skillList[v.skill_id] then
                return true
            end
        end
    end
    return false
end


-- 查找是否学过伤害类必杀技
function SkillTreeData:findUniqueSkill()
    for k=1,skilltree_info.getLength() do
        local v = skilltree_info.indexOf(k)
        if v.func == self.SKILL_TYPE.TYPE_HURT and v.kind_level == self.ITEM_TYPE.ITME_UNIQUESKILL  then
            return (self.skillList[v.skill_id] == nil and true) or false
        end
    end
    return false
end

-- 查找同种类同等级的其他技能
function SkillTreeData:findSameTypeAndLevel(_func,_kindLevel)
    for k,v in pairs(self.skillList) do 
        for i=1,skilltree_info.getLength() do
        local j = skilltree_info.indexOf(i)
            if j.skill_id == k then
                if j.skill_id ~= skill_id and j.func == _func and j.kind_level == _kindLevel then
                    return true
                end
                break
            end
        end
    end
    return false
end



return SkillTreeData

