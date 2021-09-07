-- 战斗出招表
-- @author huangzefeng
-- @date 20160616
SkillScriptManager = SkillScriptManager or BaseClass(BaseManager)

function SkillScriptManager:__init()
    if SkillScriptManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    SkillScriptManager.Instance = self
    self.model = SkillScriptModel.New(self)

    self.RoleSet = {}
    self.nameSet = {
        [1] = "",
        [2] = "",
        [3] = "",
    }
    self.PetSet = nil
    self.roleCurrIndex = 0
    self.updateall = 0
    self.OnRoleScriptChange = EventLib.New()
    self.OnPetScriptChange = EventLib.New()
    self:AddAllHandlers()
end

function SkillScriptManager:AddAllHandlers()
    self:AddNetHandler(10763, self.On10763);
    self:AddNetHandler(10764, self.On10764);
    self:AddNetHandler(10765, self.On10765);
    self:AddNetHandler(10766, self.On10766);
    self:AddNetHandler(10767, self.On10767);
    self:AddNetHandler(10768, self.On10768);

end

function SkillScriptManager:SendOnConnect()
    self:Send10763()
    self:Send10767()
end

function SkillScriptManager:Send10763()
    Connection.Instance:send(10763, {})
end
--请求角色挂机方案数据
function SkillScriptManager:On10763(data)
    --BaseUtils.dump(data,"<color='#00ff00'>SkillScriptManager</color>")
    self.roleCurrIndex = data.valid_plan
    self.RoleSet = {}
    for i,v in ipairs(data.plan_data) do
        self.RoleSet[v.index] = v.skill_plan
        self.nameSet[v.index] = v.name
    end
    for k,plant in pairs(self.RoleSet) do
        for k,v in pairs(plant) do
            if self:IsValidSkill(v.skill_id) == false then
                plant[k].skill_id = 1000
            end
        end
    end
    self.OnRoleScriptChange:Fire()
end



function SkillScriptManager:Send10764(index, skill_plan, issetdefault)
    -- print("更改方案："..index)
    for i,v in ipairs(skill_plan) do
        if self:IsValidSkill(v.skill_id) == false then
            NoticeManager.Instance:FloatTipsByString(TI18N("技能数据有误请重新设置"))
            return
        end
    end
    if issetdefault then
        self.updateall = self.updateall + 1
    end
    Connection.Instance:send(10764, {index = index, skill_plan = skill_plan})
end

--设置人物挂机方案
function SkillScriptManager:On10764(data)
    -- if data.result == 1 then
        -- self.OnRoleScriptChange:Fire()
    -- end
    if self.updateall <= 0 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    else
        self.updateall = self.updateall - 1
    end
end



function SkillScriptManager:Send10765(skill_id)
    -- print("宠物技能设置为："..skill_id)
    Connection.Instance:send(10765, {skill_id = skill_id})
end

--设置宠物挂机方案
function SkillScriptManager:On10765(data)
    -- print(data.result)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end



function SkillScriptManager:Send10766(index)
    -- print("设置为："..index)
    Connection.Instance:send(10766, {index = index})
end

--设置生效挂机方案
function SkillScriptManager:On10766(data)
    -- print(data.result)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end



function SkillScriptManager:Send10767()
    Connection.Instance:send(10767, {})
end

--宠物挂机方案数据
function SkillScriptManager:On10767(data)
    -- BaseUtils.dump(data, "<color='#Ff0000'>宠物的方案</color>")
    self.PetSet = data.skill_id
    self.OnPetScriptChange:Fire()
end

function SkillScriptManager:Send10768(index, name)
    -- print("保存"..index.."的名字为"..name)
    Connection.Instance:send(10768, {index = index, name = name})
end

--宠物挂机方案数据
function SkillScriptManager:On10768(data)
    -- BaseUtils.dump(data, "<color='#Ff0000'>改名结果</color>")
    if self.updateall <= 0 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    else
        self.updateall = self.updateall - 1
    end
end

function SkillScriptManager:SetGroupName(index, name, issetdefault)
    -- local roledata = RoleManager.Instance.RoleData
    -- local key = BaseUtils.Key(roledata.id, roledata.platform, roledata.zone_id, "Group", index)
    -- local origin = WWW.EscapeURL(tostring(name))
    -- PlayerPrefs.SetString(key, origin)
    if issetdefault then
        self.updateall = self.updateall + 1
    end
    self:Send10768(index, name)
     -- self.OnRoleScriptChange:Fire()
end

function SkillScriptManager:GetGroupName(index)
    if index == 0 or index == 4 then
        return TI18N("系统默认")
    end
    -- local roledata = RoleManager.Instance.RoleData
    -- local key = BaseUtils.Key(roledata.id, roledata.platform, roledata.zone_id, "Group", index)
    -- local str = PlayerPrefs.GetString(key)
    local originStr = self.nameSet[index]
    if originStr == "" or originStr == nil then
        if index == 1 then
            originStr = TI18N("方案一")
        elseif index == 2 then
            originStr = TI18N("方案二")
        elseif index == 3 then
            originStr = TI18N("方案三")
        end
    end
    return originStr
end

function SkillScriptManager:IsValidSkill(id)
    if id == nil then
        return false
    elseif id == 1001 or id == 1000 then
        return true
    else
        local key = string.format("%s_1", id)
        if key == nil then
            return false
        end
        if DataCombatSkill.data_combat_skill[key] == nil then
            return false
        end
    end
    return true
end
