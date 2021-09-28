--[[
文件名:CacheTreasure.lua
描述：神兵数据抽象类型
创建人：liaoyuangang
创建时间：2016.05.09
--]]

-- 神兵数据说明
--[[
-- 服务器返回的神兵数据中，每个条目包含的字段如下
	{
        Id              = "36cb3abd-da4a-4369-b07d-b12da70d8022"
        ModelId = 14020605
        Lv              = 0
        Step            = 0
        EXP             = 0
        GemId           = "3be7c8f6-2770-438a-be5d-3a62ac52f168"
        GemModelID"     = 20010402
    },
]]

-- 过滤条件说明
--[[
    { 
        alwaysIdList = {}, -- 始终包含的条目Id列表
        excludeIdList = {}, -- 需要排除掉实体Id
        excludeModelIdList = {}, -- 需要排除的神兵模型Id列表
        resourcetypeSub = nil,  -- 需要获取的资源类型, 默认为nil
        notInFormation = false, -- 是否需要过滤掉上阵的神兵，默认为false
        minColorLv = 1,         -- 最低的颜色等级，默认为1
        maxColorLv = 1,         -- 最高的颜色等级，
        maxLv = 1000,           -- 最大的强化等级, 默认为 1000
        minLv = 0,              -- 最小的强化等级，默认为0
        maxStep = 1000,         -- 最大的进阶等级， 默认为1000
        minStep = 0,            -- 最小进阶等级
        notExpTreasure = false, -- 是否需要过滤经验神兵，默认为 false

        isResolve = true,         -- 选择可分解的神兵，已经进阶和升级的显示在后面并且不可选
        isRebirth = true,         -- 选择可重生的神兵，升级或进阶过，不包括已上阵的
        isTreasureCompare = true, -- 选择可合成的神兵, 紫色及以上并且没有上阵的神兵，已进阶的需要显示在列表尾，
        isTreasureLvUp = true,    -- 选择可用于强化的神兵，强化过的可以选；进阶过的不行；不包括已上阵的
        isTreasureStepUp = true,  -- 选择可用于进阶的神兵，强化过的可以选；进阶过的不行；不包括已上阵的；
    }
]]


local CacheTreasure = class("CacheTreasure", {})

-- 检查一个条目是否满足条件
--[[
-- 参数
    treasureItem: 神兵信息，参考 “神兵数据说明”
    filter: 过滤条件 参考 “过滤条件说明”
]]
local function checkOneItem(treasureItem, filter)
    -- 判断是否是始终需要的记录
    if table.indexof(filter.alwaysIdList or {}, treasureItem.Id) then
        return true
    end
    
    -- 判断需要排除的实体Id
    if table.indexof(filter.excludeIdList or {}, treasureItem.Id) then
        return false
    end

    -- 选择可分解的神兵
    if filter.isResolve then
        if FormationObj:equipInFormation(treasureItem.Id) then
            return false
        end

        -- 不需要经验神兵, 不需要橙色以下
        local tempModel = TreasureModel.items[treasureItem.ModelId]
        local colorLv = Utility.getQualityColorLv(tempModel.quality)
        if tempModel.maxLV == 0 or colorLv < 4 then  
            return false
        end
    end

    -- 选择可重生的神兵，
    if filter.isRebirth then
        if FormationObj:equipInFormation(treasureItem.Id) or treasureItem.Lv == 0 and treasureItem.Step == 0 and treasureItem.EXP == 0 or
            TreasureModel.items[treasureItem.ModelId].maxStep == 0 then
            return false
        end

        -- 过滤掉紫色以下的神兵
        if Utility.getQualityColorLv(ConfigFunc:getItemBaseModel(treasureItem.ModelId).quality) < 4 then
            return false
        end
    end

    -- 选择可合成的神兵
    if filter.isTreasureCompare then
        if FormationObj:equipInFormation(treasureItem.Id) then
            return false
        end

        -- 只能合成紫色非经验神兵  
        local tempModel = TreasureModel.items[treasureItem.ModelId]
        local colorLv = Utility.getQualityColorLv(tempModel.quality)
        if tempModel.maxLV == 0 or colorLv ~= 4 then -- 只能合成紫色非经验神兵  
            return false
        end
    end

    -- 选择可用于强化的神兵
    if filter.isTreasureLvUp then
        if FormationObj:equipInFormation(treasureItem.Id) or treasureItem.Step > 0 then
            return false
        end

        -- 需要经验神兵
        local tempModel = TreasureModel.items[treasureItem.ModelId]
        if tempModel.maxLV == 0  then  
            return true
        end
    end

    -- 选择可用于进阶的神兵
    if filter.isTreasureStepUp then
        if FormationObj:equipInFormation(treasureItem.Id) or treasureItem.Step > 0 then
            return false
        end

        -- 如果强化过就要排除
        if (treasureItem.EXP > 0) or (treasureItem.Lv > 0) then
            return false
        end

        -- 不需要经验神兵, 需要指定品质
        local tempModel = TreasureModel.items[treasureItem.ModelId]
        if filter.resourcetypeSub and filter.resourcetypeSub == tempModel.typeID and tempModel.maxLV == 0 then
            return true
        end
    end

    if table.indexof(filter.excludeModelIdList or {}, treasureItem.ModelId) then
        return false
    end

    if filter.notInFormation and FormationObj:equipInFormation(treasureItem.Id) then  -- 过滤掉已上阵的神兵
        return false
    end
    if filter.maxLv and filter.maxLv < treasureItem.Lv then -- 强化等级小于等于一定值
        return false
    end
    if filter.minLv and treasureItem.Lv < filter.minLv then -- 强化等级大于等于一定值
        return false
    end
    if filter.maxStep and filter.maxStep < treasureItem.Step then  -- 进阶等级小于等于一定值
        return false
    end
    if filter.minStep and treasureItem.Step < filter.minStep then  -- 进阶等级大于等于一定值
        return false
    end

    local tempModel = TreasureModel.items[treasureItem.ModelId]
    if filter.notExpTreasure and tempModel.maxLV == 0 then  -- 不需要经验神兵
        return false
    end
    if filter.minColorLv or filter.maxColorLv then  -- 需要的最低颜色等级
        local colorLv = Utility.getQualityColorLv(tempModel.quality)
        if filter.minColorLv and colorLv < filter.minColorLv then
            return false
        end

        if filter.maxColorLv and colorLv > filter.maxColorLv then
            return false
        end
    end
    return true
end 

--[[
]]
function CacheTreasure:ctor()
    -- 神兵列表的原始数据
	self.mTreasureList = {}
    -- 装备分类存储列表
    self.mTreasureTypeList = {}
    -- 以实例Id为key的神兵列表
    self.mIdList = {}
    -- 以模型Id为key的神兵列表
    self.mModelList = {}
    
    -- 新得到神兵Id列表对象
    self.mNewIdObj = require("data.NewIdList"):create()
end

-- 清空管理对象中的数据
function CacheTreasure:reset()
    self.mTreasureList = {}
    self.mTreasureTypeList = {}
    self.mIdList = {}
    self.mModelList = {}
    self.mNewIdObj:clearNewId()
    Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagTreasure)
end

-- 刷新神兵辅助缓存，主要用于数据获取时效率优化
function CacheTreasure:refreshAssistCache()
    self.mTreasureTypeList = {}
    self.mIdList = {}
    self.mModelList = {}
    for _, item in ipairs(self.mTreasureList) do
        self.mIdList[item.Id] = item
        self.mModelList[item.ModelId] = self.mModelList[item.ModelId] or {}
        table.insert(self.mModelList[item.ModelId], item)

        -- 分类存储列表
        local tempModel = TreasureModel.items[item.ModelId]
        self.mTreasureTypeList[tempModel.typeID] = self.mTreasureTypeList[tempModel.typeID] or {}
        table.insert(self.mTreasureTypeList[tempModel.typeID], item)
    end
end

-- 设置神兵列表
function CacheTreasure:setTreasureList(treasureList)
	self.mTreasureList = treasureList or {}
    self:refreshAssistCache()
end

-- 添加神兵数据
--[[
-- 参数
    treasureItem: 需要插入的数据
    onlyInsert: 是否只是插入数据，默认为false，如果设置为true，则需要在适当的地方调用 refreshAssistCache 接口
]]
function CacheTreasure:insertTreasure(treasureItem, onlyInsert)
    if not treasureItem or not Utility.isEntityId(treasureItem.Id) then
        return
    end
    table.insert(self.mTreasureList, treasureItem)
    if not onlyInsert then
        self:refreshAssistCache()
    end

    local tempModel = TreasureModel.items[treasureItem.ModelId]
    local colorLv = Utility.getQualityColorLv(tempModel and tempModel.quality or 1)
    if colorLv > 3 then    -- 紫色或以上显示NEW标识
        self.mNewIdObj:insertNewId(treasureItem.Id)
        Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagTreasure)
    end
end

-- 修改神兵数据
function CacheTreasure:modifyTreasureItem(treasureItem)
	if not treasureItem or not Utility.isEntityId(treasureItem.Id) then
        return
    end

    for index, item in pairs(self.mTreasureList) do
        if item.Id == treasureItem.Id then
            self.mTreasureList[index] = clone(treasureItem)
            break
        end
    end
    self:refreshAssistCache()
end

-- 删除神兵列表中的一批数据
function CacheTreasure:deleteTreasureItems(needDelItemList)
	for _, item in pairs(needDelItemList) do
        self:deleteTreasureById(item.Id, true)
    end
    self:refreshAssistCache()
end

-- 根据神兵事例Id删除列表中对应的数据
--[[
-- 参数
    treasureId: 神兵实例Id
    onlyDelete: 是否只是删除神兵缓存列表中的数据，默认为false, 外部调用者一般使用默认参数
]]
function CacheTreasure:deleteTreasureById(treasureId, onlyDelete)
	for index, item in pairs(self.mTreasureList) do
        if treasureId == item.Id then
            table.remove(self.mTreasureList, index)
            break
        end
    end
    if not onlyDelete then
        self:refreshAssistCache()
    end
    self.mNewIdObj:clearNewId(treasureId)
    Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagTreasure)
end

--- 返回神兵列表数据
--[[
-- 参数：
    filter: 过滤条件 参考 “过滤条件说明”
-- 返回值单个神兵的信息参考文件头部的 “神兵数据说明”   
--]]
function CacheTreasure:getTreasureList(filter)
    --dump(filter, "CacheTreasure:getTreasureList")
    if not filter or not next(filter) then  -- 不需要过滤，直接就返回所有列表数据
        return self.mTreasureList
    end
    local treasureType = filter.resourcetypeSub
    local tempList = treasureType and self.mTreasureTypeList[treasureType] or not treasureType and self.mTreasureList or {}
    -- 判断是否只过滤资源类型
    local function onlyFilterResourcetypeSub()
        for key, value in pairs(filter) do
            if key ~= "resourcetypeSub" then
                return false
            end
        end
        return true
    end
    if onlyFilterResourcetypeSub() then
        return tempList
    end

    local ret = {}
    for _, item in ipairs(tempList) do
        if checkOneItem(item, filter) then
            table.insert(ret, item)
        end
    end

    return ret
end

--- 获取以模型Id为key的神兵列表
--[[
-- 返回值的格式为：
    {
        [ModelId] = {
            {
                神兵实例数据，具体内容参看文件顶部的说明
            },
            ...
        }
    }
]]
function CacheTreasure:getTreasureListAsModelId()
    return self.mModelList
end

--- 获取神兵信息,
--[[
-- 获取装备信息,
-- 参数：
    treasureId:神兵实例id
-- 返回值参考文件头部的 “神兵数据说明” 
--]]
function CacheTreasure:getTreasure(treasureId)
    return self.mIdList[treasureId]
end

--- 判断神兵列表中是否有未上阵的某类型神兵
--[[
-- 参数
    treasureType: 神兵类型在EnumsConfig.lua中有定义
-- 返回值: 返回 true表示有未上阵的某类型神兵，false表示没有
 ]]
function CacheTreasure:haveIdleTreasure(treasureType)
    local tempList = treasureType and self.mTreasureTypeList[treasureType] or not treasureType and self.mTreasureList or {}

    for _, item in pairs(tempList) do
        if not FormationObj:equipInFormation(item.Id) then  -- 找到一个未上阵的装备
            return true
        end
    end

    return false
end


--- 判断玩家是否拥有某种类型的神兵
--[[
-- 参数
    modelId: 神兵的模型Id
    filter: 过滤条件 参考 “过滤条件说明”
-- 返回值
    返回该神兵模型Id的实例列表，单个神兵的信息参考文件头部的 “神兵数据说明” 
 ]]
function CacheTreasure:findByModelId(modelId, filter)
    local tempList = self.mModelList[modelId] or {}
    if not filter then
        return tempList
    end

    local ret = {}
    for _, item in pairs(tempList) do
        if checkOneItem(item, filter) then
            table.insert(ret, item)
        end
    end
    return ret
end

--- 获取玩家拥有某种神兵的数量
--[[
-- 参数：
    modelId: 神兵模型Id
    filter: 过滤条件 参考 “过滤条件说明”
]]
function CacheTreasure:getCountByModelId(modelId, filter)
    local tempList = self.mModelList[modelId] or {}
    if not filter then
        return #tempList
    else
        local ret = 0
        for _, item in pairs(tempList) do
            if checkOneItem(item, filter) then
                ret = ret + 1
            end
        end
        return ret
    end
end

-- 判断是否有未上阵的神兵
--[[
-- 参数
    treasuretypeSub: 判断的神兵类型
    filterExpTreasure: 是否需要过滤经验神兵
]]
function CacheTreasure:haveUnBattle(treasuretypeSub, filterExpTreasure)
    local formationObj = Player.mFormationObj
    local tempList = self.mTreasureTypeList[treasuretypeSub or 0] or self.mTreasureList
    for _, item in pairs(tempList) do
        if not formationObj:equipInFormation(item.Id) then
            if not filterExpTreasure then
                return true
            end 
            local tempModel = TreasureModel.items[item.ModelId]
            if tempModel.maxLV > 0 then  -- 不是经验神兵
                return true
            end
        end
    end

    return false
end

-- 获取神兵上阵卡槽的人物信息
--[[
-- 参数
    treasureId: 神兵实例Id
-- 返回值
    第一个返回值：如果该神兵已上阵，则返回该神兵所在的阵容卡槽Id, 否则为nil
    第二个返回值：如果该神兵已上阵，则返回该神兵所在阵容卡槽人物的信息， 否则为nil
]]
function CacheTreasure:getTreasureSlotInfo(treasureId)
    local inFormation, slotId = FormationObj:equipInFormation(treasureId)
    if not inFormation then
        return 
    end
    local slotInfo = FormationObj:getSlotInfoBySlotId(slotId)
    local heroInfo = HeroObj:getHero(slotInfo.HeroId)
    
    return slotId, heroInfo
end

-- 获取新装备Id列表对象
--[[
-- 返回值
    返回值提供的接口查看 "data/NewidList.lua" 文件
]]
function CacheTreasure:getNewIdObj()
    return self.mNewIdObj
end

return CacheTreasure
