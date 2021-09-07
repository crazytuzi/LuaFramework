-- @author 黄耀聪
-- @date 2017年3月17日

TalismanModel = TalismanModel or BaseClass(BaseModel)

function TalismanModel:__init()
    -- 熔炉等级
    self.fusion_lev = nil

    -- 熔炉进度
    self.fusion_val = nil

    -- 方案表
    self.planList = {}

    -- 法宝表
    self.itemDic = {}
    self.useItemDic = {}
    self.newItemId = {}


    self.giftShow = nil

    self.hasLockGridNum = 48

    --重塑配方表
    self.formula_list = {}
    self.selectedData = {}  --当前可合成宝物的已选中材料
    self.initStatus = true

    self.suitItemSet = {}
    for k,v in pairs(DataTalisman.data_get) do
        if (v.quality == 2 and v.grade == 1) or (v.quality == 3 and v.grade == 2) then
            self.suitItemSet[v.set_id] = self.suitItemSet[v.set_id] or {}
            if self.suitItemSet[v.set_id][TalismanEumn.TypeProto[v.type]] == nil then
                self.suitItemSet[v.set_id][TalismanEumn.TypeProto[v.type]] = v.base_id
            end
        end
    end

    -- 临时存储用
    self.tempSkillTab = {}
    for _,v in pairs(DataTalisman.data_set) do
        self.tempSkillTab[v.set_id] = {["blue"] = 0, ["purple"] = 0, ["orange"] = 0, ["red"] = 0}
    end
end

function TalismanModel:__delete()
end

function TalismanModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = TalismanWindow.New(self)
    end
    self.mainWin:Open(args)
end

function TalismanModel:SetBase(data)
    local i = 0

    self.times = data.times or self.times or 0
    self.fusion_lev = data.fusion_lev or self.fusion_lev
    self.fusion_val = data.fusion_val or self.fusion_val
    self.fc = data.fc or self.fc

    while true do
        i = i + 1
        if data["plan_" .. i] == nil then
            break
        end
        self.planList[i] = {}
        for _,v in ipairs(data["plan_" .. i]) do
            self.planList[i][TalismanEumn.TypeProto[v["type_" .. i]]] = {id = v["id_" .. i], type = v["type_" .. i]}
        end
    end

    if data.items ~= nil then
        local idList = {}
        for k,v in pairs(self.itemDic) do
            if v ~= nil then table.insert(idList, k) end
        end
        for _,id in ipairs(idList) do
            self.itemDic[id] = nil
        end
        for i,v in ipairs(data.items) do
            self.itemDic[v.id] = v
        end
    end

    self:UsePlan(data.use_plan)
end

function TalismanModel:UsePlan(plan)
    self.use_plan = plan
    local idList = {}
    for k,v in pairs(self.useItemDic) do
        if v ~= nil then table.insert(idList, k) end
    end
    for _,id in ipairs(idList) do
        self.useItemDic[id] = nil
    end
    for _,v in pairs(self.planList[plan]) do
        self.useItemDic[v.id] = 1
    end
end

function TalismanModel:OpenAbsorb(args)
    if self.absorbWin == nil then
        self.absorbWin = TalismanAbsorbWindow.New(self)
    end
    self.absorbWin:Open(args)
end

function TalismanModel:Sort(id1, id2)
    if self.useItemDic[id1] ~= nil and self.useItemDic[id2] == nil then
        return true
    elseif self.useItemDic[id1] == nil and self.useItemDic[id2] ~= nil then
        return false
    else
        return self:SortNoWear(id1, id2)
    end
end

function TalismanModel:SortNoWear(id1, id2)
    local base_id1 = self.itemDic[id1].base_id
    local base_id2 = self.itemDic[id2].base_id
    if DataTalisman.data_get[base_id1].set_id == DataTalisman.data_get[base_id2].set_id then
        return DataTalisman.data_get[base_id1].quality > DataTalisman.data_get[base_id2].quality
    else
        return DataTalisman.data_get[base_id1].set_id < DataTalisman.data_get[base_id2].set_id
    end
end

function TalismanModel:IsSuiting(base_id)
    for id,v in pairs(self.useItemDic or {}) do
        if v == 1 and self.itemDic[id].base_id == base_id then
            return true
        end
    end
    return false
end

function TalismanModel:GetSkillList()
    -- 初始化
    local setTab = {}
    for _,v in pairs(self.planList[self.use_plan or 1]) do
        if self.itemDic[v.id] ~= nil then
            local set_id = DataTalisman.data_get[self.itemDic[v.id].base_id].set_id
            for k,_ in pairs(self.tempSkillTab[set_id]) do
                self.tempSkillTab[set_id][k] = 0
                setTab[set_id] = 1
            end
        end
    end

    for _,v in pairs(self.planList[self.use_plan or 1]) do
        if self.itemDic[v.id] ~= nil then
            local cfgData = DataTalisman.data_get[self.itemDic[v.id].base_id]
            self.tempSkillTab[cfgData.set_id][TalismanEumn.Qualify[cfgData.quality]] = self.tempSkillTab[cfgData.set_id][TalismanEumn.Qualify[cfgData.quality]] + 1
        end
    end
    local skillInfoTab = {}
    for set_id,_ in pairs(setTab) do
        for i=5,2,-1 do
            if TalismanEumn.Qualify[i + 1] ~= nil then
                self.tempSkillTab[set_id][TalismanEumn.Qualify[i]] = self.tempSkillTab[set_id][TalismanEumn.Qualify[i]] +self.tempSkillTab[set_id][TalismanEumn.Qualify[i + 1]]
            end
        end
    end
    local skillTab = {}
    local two = nil
    local four = nil
    for set_id,_ in pairs(setTab) do
        two = false
        four = false
        for i=5,2,-1 do
            if self.tempSkillTab[set_id][TalismanEumn.Qualify[i]] >= 2 then
                if not two then
                    -- for _,v in ipairs(DataTalisman.data_set[set_id][string.format("skills_%s_2",TalismanEumn.Qualify[i])]) do
                    --     -- print("===================================1========================== "..v[2])
                    --     skillTab[v[2]] = 1
                    -- end
                    -- 只读取第一个技能
                    skillTab[DataTalisman.data_set[set_id][string.format("skills_%s_2",TalismanEumn.Qualify[i])][1][2]] = 1
                    two = true
                end
            end
            if self.tempSkillTab[set_id][TalismanEumn.Qualify[i]] >= 4 then
                if not four then
                    -- for _,v in ipairs(DataTalisman.data_set[set_id][string.format("skills_%s_4",TalismanEumn.Qualify[i])]) do
                    --     -- print("===================================2========================== "..v[2])
                    --     skillTab[v[2]] = 1
                    -- end
                    -- 只读取第一个技能
                    skillTab[DataTalisman.data_set[set_id][string.format("skills_%s_4",TalismanEumn.Qualify[i])][1][2]] = 1
                    four = true
                end
                if not two then
                    -- for _,v in ipairs(DataTalisman.data_set[set_id][string.format("skills_%s_2",TalismanEumn.Qualify[i])]) do
                    -- -- print("===================================3========================== "..v[2])
                    --     skillTab[v[2]] = 1
                    -- end
                    -- 只读取第一个技能
                    skillTab[DataTalisman.data_set[set_id][string.format("skills_%s_2",TalismanEumn.Qualify[i])][1][2]] = 1
                    two = true
                end
            end
        end
    end
    local skillList = {}
    for skill_id,_ in pairs(skillTab) do
        table.insert(skillList, skill_id)
    end
    -- BaseUtils.dump(skillList, "skillList")
    return skillList
end

function TalismanModel:OpenFusion(args)
    if self.fusionWin == nil then
        self.fusionWin = TalismanFusionWindow.New(self)
    end
    self.fusionWin:Open(args)
end

function TalismanModel:CanAbsorbed(id)
    return self.planList[self.use_plan or 0][TalismanEumn.TypeProto[DataTalisman.data_get[self.itemDic[id].base_id].type]] ~= nil
end


function TalismanModel:OpenGiftShow(args)
    if self.giftShow ~= nil then
        self.giftShow:Close()
    end
    if self.giftShow == nil then
        self.giftShow = BackpackGiftShow.New(self)
    end

    self.giftShow:Show(args)
end

function TalismanModel:CloseGiftShow()
    if self.giftShow ~= nil then
        self.giftShow:DeleteMe()
        self.giftShow = nil
    end
end

