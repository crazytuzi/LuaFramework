-- @author hzf
-- @date 2016年7月6日,星期三

EncyclopediaManager = EncyclopediaManager or BaseClass(BaseManager)

function EncyclopediaManager:__init()
    if EncyclopediaManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    EncyclopediaManager.Instance = self
    self.model = EncyclopediaModel.New()
    self:InitHandler()
    self.EquipData = {}
    self.RoleSkillData = {}
    self.EquipSkillData = {} --装备技能数据
    self.WingSkillData = {}
    self.CPSkillData = {}
    self.EquipType = {}
    self.MedicineData = {}
end

function EncyclopediaManager:__delete()
end

function EncyclopediaManager:InitHandler()
end

function EncyclopediaManager:InitData()
    self:InitEquipData()
    self:InitSkillData()
    self:InitEquipSkill()
    self:InitWingSkill()
    self:InitCPSkill()
    self:InitMedicine()
    self:InitTalisman()
end

function EncyclopediaManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function EncyclopediaManager:InitEquipData()
    self.EquipData = {}
    for i,v in pairs(DataItem.data_equip) do
        if (RoleManager.Instance.RoleData.classes == v.classes or 0 == v.classes) and v.isShow == 1 then
            if self.EquipData[v.lev] == nil then
                self.EquipData[v.lev] = {}
            end
            table.insert( self.EquipData[v.lev], DataItem.data_get[i])
        end
    end

    for k,v in pairs(self.EquipData) do
        table.sort(v, function(a,b)
            if RoleManager.Instance.RoleData.classes == 6 then
                if a.type == 21 then
                    return true
                elseif b.type == 21 then
                    return false
                else
                    return a.type<b.type
                end
            else
                return a.type<b.type
            end
        end)
    end


end

function EncyclopediaManager:InitSkillData()
    self.RoleSkillData = {}
    for classes = 1, #KvData.classes_name do
        self.RoleSkillData[classes] = {}
        for i,v in ipairs(DataSkill.data_skill_role_init[classes].skills) do
            table.insert( self.RoleSkillData[classes], v)
        end
        table.insert( self.RoleSkillData[classes], DataSkillUnique.data_skill_unique[classes.."_1"].id)
    end
    -- DataSkill.data_skill_role_init[classes]
    -- for i,v in pairs(DataSkill.data_skill_role) do
    --     if v.lev == 1 then
    --         local classes = math.floor(v.id/10000)
    --         if self.RoleSkillData[classes] == nil then
    --             self.RoleSkillData[classes] = {}
    --         end
    --         table.insert( self.RoleSkillData[classes], v )
    --     end
    -- end
    -- for k,v in pairs(self.RoleSkillData) do
    --     table.sort(v, function(a,b)
    --         return a.id<b.id
    --     end)
    -- end
end

function EncyclopediaManager:GetAllEffect(effectData)
    local list = {}
    for i,v in pairs(effectData) do
        if v.classes == RoleManager.Instance.RoleData.classes or v.classes == 0 then
            for i,v1 in ipairs(v.effect) do
                table.insert(list, v1)
            end
        end
    end
    return list
end

function EncyclopediaManager:GetAllEffectData(effectList)
    local list = {}
    for i,v in pairs(effectList) do
        local skillData = nil
        if v.effect_type == 100 then
            -- 技能
            if v.val < 80000 and not hasRoleSkill then
                hasRoleSkill = true
                skillData = DataSkill.data_skill_effect[81999]
            elseif v.val >= 80000 then
                skillData = DataSkill.data_skill_effect[v.val]
            end
        elseif v.effect_type == 150 then
            -- 易强化
            skillData = DataSkill.data_skill_effect[81019]
         elseif v.effect_type == 151 then
            -- 易成长
            skillData = DataSkill.data_skill_effect[81020]
        end

        if skillData ~= nil then
            table.insert(list, skillData)
        end
    end
    return list
end

function EncyclopediaManager:InitEquipSkill()
    local typeList = {RoleManager.Instance.RoleData.classes, 6, 7, 9, 10, 11, 12, 14}
    self.EquipType = typeList
    for i,v in ipairs(typeList) do
        local effectData = DataEqm.data_effect[string.format("%s_%s", v, 90)]
        -- BaseUtils.dump(effectData,"EncyclopediaM2222222222222222222222222anager:InitEquipSkill() ==")
        local effectList = self:GetAllEffect(effectData)
        -- local list = self:GetAllEffectData(effectList)
        -- self.EquipSkillData[v] = list
        self.EquipSkillData[v] = effectList
    end
    -- BaseUtils.dump(self.EquipSkillData,"EncyclopediaManager:InitEquipSkill() ==")
end

function EncyclopediaManager:InitWingSkill()
    for i=1, WingsManager.Instance.top_grade do
        local list = WingsManager.Instance:GetSkillList(i)
        if #list > 0 then
            table.insert(self.WingSkillData, {grade = i, list = list})
        end
    end
end

function EncyclopediaManager:InitCPSkill()
    self.CPSkillData = {}
    for k,v in pairs(DataSkill.data_marry_skill) do
        if v.lev == 1 then
            table.insert(self.CPSkillData, v)
        end
    end
end

function EncyclopediaManager:InitMedicine()
    self.MedicineData = {}
    -- DataItem.data_medicine = {21400, 21401, 21402, 21403, 21404, 21405, 21406, 21407, 21408, 21409, 21410, 21411, 21412, 21413, 21302, 21306}
    for k,v in pairs(DataItem.data_typekey[118]) do
        local data = BaseUtils.copytab(DataItem.data_get[v])
        local key = BaseUtils.Key(10, v)
        if DataSkillLife.data_product_frame_lev[key] ~= nil then
            data.step = 100
        end
        table.insert(self.MedicineData, data)
    end
    table.sort( self.MedicineData, function(a,b)
        return a.id < b.id
    end)
end

function EncyclopediaManager:InitTalisman()
    self.talismanSp = {}
    self.setList = {}
    for k,v in pairs(DataTalisman.data_set) do
        local temp = {}
        local quality = 2
        for _,vv in pairs(DataTalisman.data_get) do
            if ((vv.quality == 2 and vv.grade == 1) or (vv.quality == 3 and vv.grade == 2)) and vv.set_id == v.set_id then
                table.insert(temp, vv)
                quality = vv.quality
            end
        end
        table.sort(temp, function(a, b)
            return a.type < b.type
        end)
        local basedata = BaseUtils.copytab(v)
        basedata.childList = temp
        basedata.quality = quality
        table.insert(self.setList, basedata)
    end
    table.sort(self.setList, function(a, b)
        if a.quality < b.quality then
            return true
        elseif a.quality ~= b.quality then
            return false
        elseif a.set_id < b.set_id then
            return true
        elseif a.set_id ~= b.set_id then
            return false
        else
            return false
        end
        -- return a.set_id < b.set_id or a.quality < b.quality
    end)
    for k,v in pairs(DataTalisman.data_sp_attr) do
        if self.talismanSp[k] == nil then
            self.talismanSp[k] = {}
        end
        for i=1,10 do
            local key1 = string.format("attr_name%s", i)
            local key2 = string.format("attr_val%s", i)
            local key3 = string.format("attr_ratio%s", i)
            if v[key3] > 0 and (self.talismanSp[k][key2] == nil or self.talismanSp[k][key2] < v[key2]) then
                self.talismanSp[k][key2] = v[key2]
                self.talismanSp[k][key1] = v[key1]
                self.talismanSp[k].action_object = v.action_object
            end
        end
    end
end