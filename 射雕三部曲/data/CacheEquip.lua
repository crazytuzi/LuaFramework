--[[
文件名:CacheEquip.lua
描述：装备数据抽象类型
创建人：liaoyuangang
创建时间：2016.05.09
--]]

-- 装备数据说明
--[[
-- 服务器返回的装备数据中，每个条目包含的字段如下
	{
        Id           = "13672dcd-a79a-471b-b203-379b98a641d1"
        ModelId = 13020507
        Lv           = 0
        Step         = 0
        GemId        = "00000000-0000-0000-0000-000000000000"
        GemModelID   = 0
    },
]]

-- 过滤条件说明
--[[
    { 
        alwaysIdList = {}, -- 始终包含的条目Id列表
        excludeIdList = {}, -- 需要排除掉实体Id
        resourcetypeSub = nil,  -- 需要获取的资源类型, 默认为nil
        notInFormation = false, -- 是否需要过滤掉上阵的神兵，默认为false
        minColorLv = 1,         -- 最低的颜色等级，默认为1
        maxColorLv = 4,         -- 最高的颜色等级
        needQuality = 1,        -- 指定颜色品质
        needValueLv = 1,        -- 指定的价等
        maxLv = 1000,           -- 最大的强化等级, 默认为 1000
        minLv = 0,              -- 最小的强化等级，默认为0
        maxStep = 1000,         -- 最大的进阶等级， 默认为1000
        minStep = 0,            -- 最小进阶等级

        isRebirth = true,       -- 选择可重生的装备，升级或进阶过，不符合条件的不显示
        isEquipCompare = true,  -- 选择可用于合成的装备，未上阵的装备，已进阶的需要显示在列表尾，
        isRefine = true,        -- 选择可分解的装备，升级或进阶过，不符合条件的不显示
    }
]]

local CacheEquip = class("CacheEquip", {})

-- 检查一个条目是否满足条件
--[[
-- 参数
    equipItem: 装备信息，参考 “装备数据说明”
    filter: 过滤条件 参考 “过滤条件说明”
]]
local function checkOneItem(equipItem, filter)
    -- 判断是否是始终需要的记录
    if table.indexof(filter.alwaysIdList or {}, equipItem.Id) then
        return true
    end
    -- 判断需要排除的实体Id
    if table.indexof(filter.excludeIdList or {}, equipItem.Id) then
        return false
    end
    
    -- 选择可重生的装备
    if filter.isRebirth then
        if FormationObj:equipInFormation(equipItem.Id) then  -- 过滤掉已上阵的
            return false
        end
        -- 过滤掉既没有升级有没有进阶的装备
        if equipItem.Step == 0 and equipItem.Lv == 0 then
            return false
        end

        return true
    end

    -- 选择可分解的装备
    if filter.isRefine then
        if FormationObj:equipInFormation(equipItem.Id) then  -- 过滤掉已上阵的
            return false
        end
        if equipItem.Star ~= 0 then
            return false
        end
        -- 后续条件继续判定
    end 

    --  选择可用于合成的装备
    if filter.isEquipCompare then
        if FormationObj:equipInFormation(equipItem.Id) then  -- 过滤掉已上阵的
            return false
        end
        -- 过滤掉品质为最高的装备
        local tempModel = EquipModel.items[equipItem.ModelId]
        if not tempModel or Utility.getQualityColorLv(tempModel.quality) == 7 then
            return false
        end

        return true
    end

    -- 过滤其他规则
    if filter.notInFormation and FormationObj:equipInFormation(equipItem.Id) then  -- 过滤掉已上阵的装备
        return false
    end
    if filter.maxLv and filter.maxLv < equipItem.Lv then -- 强化等级小于等于一定值
        return false
    end
    if filter.minLv and equipItem.Lv < filter.minLv then -- 强化等级大于等于一定值
        return false
    end
    if filter.maxStep and filter.maxStep < equipItem.Step then  -- 进阶等级小于等于一定值
        return false
    end
    if filter.minStep and equipItem.Step < filter.minStep then  -- 进阶等级大于等于一定值
        return false
    end

    if filter.minColorLv or filter.maxColorLv or filter.needQuality or filter.needValueLv then  -- 需要的最低颜色等级
        local tempModel = EquipModel.items[equipItem.ModelId]
        local tempColorLv = Utility.getQualityColorLv(tempModel.quality)
        if filter.minColorLv and tempColorLv < filter.minColorLv then
            return false
        end
        if filter.maxColorLv and tempColorLv > filter.maxColorLv then
            return false
        end
        if filter.needQuality and tempModel.quality ~= filter.needQuality then
            return false
        end
        if filter.needValueLv and tempModel.valueLv ~= filter.needValueLv then
            return false
        end
    end
    return true
end 

--
function CacheEquip:ctor()
    -- 装备列表的原始数据
	self.mEquipList = {}
    -- 装备分类存储列表
    self.mEquipTypeList = {}
    -- 以实例Id为key的装备列表
    self.mIdList = {}
    -- 以模型Id为key的装备列表
    self.mModelList = {}
    
    -- 新得到装备Id列表对象
    self.mNewIdObj = require("data.NewIdList"):create()
end

-- 清空管理对象中的数据
function CacheEquip:reset()
    self.mEquipList = {}
    self.mEquipTypeList = {}
    self.mIdList = {}
    self.mModelList = {}
    self.mNewIdObj:clearNewId()
    Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagEquipDebris)
end

-- 刷新装备辅助缓存，主要用于数据获取时效率优化
function CacheEquip:refreshAssistCache()
    self.mEquipTypeList = {}
    self.mIdList = {}
    self.mModelList = {}
    for _, item in ipairs(self.mEquipList) do
        self.mIdList[item.Id] = item
        self.mModelList[item.ModelId] = self.mModelList[item.ModelId] or {}
        table.insert(self.mModelList[item.ModelId], item)
        -- 分类存储列表
        local tempModel = EquipModel.items[item.ModelId]
        if tempModel then
            self.mEquipTypeList[tempModel.typeID] = self.mEquipTypeList[tempModel.typeID] or {}
            table.insert(self.mEquipTypeList[tempModel.typeID], item)
        end
    end
end

-- 设置装备列表
function CacheEquip:setEquipList(equipList)
	self.mEquipList = equipList or {}
    self:refreshAssistCache()
end

-- 添加装备数据
--[[
-- 参数
    equipItem: 需要插入的数据
    onlyInsert: 是否只是插入数据，默认为false，如果设置为true，则需要在适当的地方调用 refreshAssistCache 接口
]]
function CacheEquip:insertEquip(equipItem, onlyInsert)
    if not equipItem or not Utility.isEntityId(equipItem.Id) then
        return
    end
    table.insert(self.mEquipList, equipItem)
    if not onlyInsert then
        self:refreshAssistCache()
    end

    local tempModel = EquipModel.items[equipItem.ModelId]
    if tempModel and Utility.getQualityColorLv(tempModel.quality) > 3 then    -- 紫色或以上显示NEW标识
        self.mNewIdObj:insertNewId(equipItem.Id)
        Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagEquipDebris)
    end
end

-- 修改装备数据
function CacheEquip:modifyEquipItem(equipItem)
    if not equipItem or not Utility.isEntityId(equipItem.Id) then
        return
    end

    for index, item in pairs(self.mEquipList) do
        if item.Id == equipItem.Id then
            self.mEquipList[index] = clone(equipItem)
            break
        end
    end
    self:refreshAssistCache()
end

-- 删除装备列表中的一批数据
function CacheEquip:deleteEquipItems(needDelItemList)
    for _, item in pairs(needDelItemList) do
        if (item.Id ~= nil) then
            -- 传的是装备列表
            self:deleteEquipById(item.Id, true)
        else
            -- 传的是ID列表
            self:deleteEquipById(item, true)
        end
    end
    self:refreshAssistCache()
end

-- 根据装备事例Id删除列表中对应的数据
--[[
-- 参数
    equipId: 装备实例Id
    onlyDelete: 是否只是删除装备缓存列表中的数据，默认为false, 外部调用者一般使用默认参数
]]
function CacheEquip:deleteEquipById(equipId, onlyDelete)
	for index, item in pairs(self.mEquipList) do
        if equipId == item.Id then
            table.remove(self.mEquipList, index)
            break
        end
    end
    if not onlyDelete then
        self:refreshAssistCache()
    end
    self.mNewIdObj:clearNewId(equipId)
    Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagEquipDebris)
end

--- 返回装备列表数据
--[[
-- 参数：
    filter: 过滤条件 参考 “过滤条件说明”
-- 返回值单个装备的信息参考文件头部的 “装备数据说明”   
--]]
function CacheEquip:getEquipList(filter)
    if not filter or not next(filter) then  -- 不需要过滤，直接就返回所有列表数据
        return self.mEquipList
    end
    local equipType = filter.resourcetypeSub
    local tempList = equipType and self.mEquipTypeList[equipType] or not equipType and self.mEquipList or {}

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

    --dump(filter, "getEquipList filter:")
    --dump(ret, "getEquipList ret:")

    return ret
end

--- 获取以模型Id为key的装备列表
--[[
-- 返回值的格式为：
    {
        [ModelId] = {
            {
                装备实例数据，具体内容参看文件顶部的说明
            },
            ...
        }
    }
]]
function CacheEquip:getEquipListAsModelId()
    return self.mModelList
end

--- 获取装备信息,
--[[
-- 获取装备信息,
-- 参数：
    equipId:装备实例id
-- 返回值参考文件头部的 “装备数据说明” 
--]]
function CacheEquip:getEquip(equipId)
    return self.mIdList[equipId]
end

--- 判断装备列表中是否有未上阵的某类型装备
--[[
-- 参数
    equipType: 装备类型在EnumsConfig.lua中有定义
-- 返回值: 返回 true表示有未上阵的某类型装备，false表示没有
 ]]
function CacheEquip:haveIdleEquip(equipType)
    local tempList = equipType and self.mEquipTypeList[equipType] or not equipType and self.mEquipList or {}

    for _, item in pairs(tempList) do
        if not FormationObj:equipInFormation(item.Id) then  -- 找到一个未上阵的装备
            return true
        end
    end

    return false
end

--- 判断玩家是否拥有某种类型的装备
--[[
-- 参数
    modelId: 装备的模型Id
    filter: 过滤条件 参考 “过滤条件说明”
-- 返回值
    返回该装备模型Id的实例列表，单个装备的信息参考文件头部的 “装备数据说明” 
 ]]
function CacheEquip:findByModelId(modelId, filter)
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

--- 获取玩家拥有某种装备的数量
--[[
-- 参数：
    modelId: 装备模型Id
    filter: 过滤条件 参考 “过滤条件说明”
]]
function CacheEquip:getCountByModelId(modelId, filter)
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

-- 获取装备上阵卡槽的人物信息
--[[
-- 参数
    equipId: 装备实例Id
-- 返回值
    第一个返回值：如果该装备已上阵，则返回该装备所在的阵容卡槽Id, 否则为nil
    第二个返回值：如果该装备已上阵，则返回该装备所在阵容卡槽人物的信息， 否则为nil
]]
function CacheEquip:getEquipSlotInfo(equipId)
    local inFormation, slotId = FormationObj:equipInFormation(equipId)
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
function CacheEquip:getNewIdObj()
    return self.mNewIdObj
end

--- 返回升星所需要的装备材料
--[[
-- 参数
    modelId: 需要升星的装备模型Id
    excludeId: 需要排除的装备ID
-- 返回值
    返回该装备模型Id的实例列表，单个装备的信息参考文件头部的 “装备数据说明” 
 ]]
function CacheEquip:getListOfStarUp(modelId, excludeId)
    local equipModel = EquipModel.items[modelId]
    if (equipModel == nil) or (equipModel.typeID == nil) then
        return {}
    end

    --
    local ret = {}
    local tempList = self.mEquipTypeList[equipModel.typeID] or {}
    for _, item in pairs(tempList) do
        if checkOneItem(item, {needValueLv = equipModel.valueLv, notInFormation = true}) then
            if (excludeId == nil) or (excludeId ~= item.Id) then
                table.insert(ret, item)
            end
        end
    end

    return ret
end

return CacheEquip
