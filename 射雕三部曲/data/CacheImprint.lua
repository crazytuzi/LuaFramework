--[[
文件名:CacheImprint.lua
描述：宝石数据抽象类型
创建人：yanghongsheng
创建时间：2019.5.30
--]]

local CacheImprint = class("CacheImprint", {})


--[[
    宝石数据说明
--[[
-- 服务器返回的宝石数据中，每个条目包含的字段如下
    {
        "Lv" = 0, --宝石等级
        "ModelId" = 30013111, --模型id
        "Id" = "af945377-d0f7-44f5-a3fb-ab6216388390", --实例id
        "AttrIdStr" = "1", -- 随机属性id
        "TotalExp" = 0, -- 强化获得的总经验
        "LvUpAttrStr" = "201|100,202|100" -- 随机属性
        "IsLock" = false, -- 是否锁定
    },
--]]

-- 过滤条件说明
--[[
-- 宝石过滤条件项如下
    { 
        notInFormation = false, -- 是否需要过滤掉上阵的，默认为false
        partId,                 -- 是否只需要改部位宝石
        isUnLock,               -- 是否需要过滤锁定的，默认false
    }
]]

-- 检查一个条目是否满足条件
--[[
-- 参数
    zhenshouItem: 宝石信息，参考 “宝石数据说明”
    filter: 过滤条件 参考 “过滤条件说明”
]]
local function checkOneItem(imprintItem, filter)
    local imprintModel = ImprintModel.items[imprintItem.ModelId]
    -- 过滤部位
    if filter.partId and filter.partId ~= imprintModel.equipTypeID then
        return false
    end

    -- 过滤掉上阵的
    if filter.notInFormation and FormationObj:imprintInFormation(imprintItem.Id) then  -- 过滤掉已上阵的
        return false
    end

    -- 过滤掉锁定的
    if filter.isUnLock and imprintItem.IsLock then
        return false
    end

    return true
end 


function CacheImprint:ctor()
    --宝石列表的原始数据
    self.mImprintList = {}
    -- 以宝石实例Id为key的宝石列表
    self.mIdList = {}
    -- 以宝石模型Id为key的宝石列表
    self.mModelList = {}

    -- 新得到宝石Id列表对象
    self.mNewIdObj = require("data.NewIdList"):create()
end

-- 清空管理对象中的数据
function CacheImprint:reset()
    self.mImprintList = {}
    self.mIdList = {}
    self.mModelList = {}

    self.mNewIdObj:clearNewId()
    -- Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagHero)
end

-- 刷新宝石辅助缓存，主要用于数据获取时效率优化
function CacheImprint:refreshAssistCache()
    self.mIdList = {}
    self.mModelList = {}
    for _, item in pairs(self.mImprintList) do
        self.mIdList[item.Id] = item

        self.mModelList[item.ModelId] = self.mModelList[item.ModelId] or {}
        table.insert(self.mModelList[item.ModelId], item)
    end
end

-- 设置宝石列表
function CacheImprint:setImprintList(imprintList)
    self.mImprintList = imprintList or {}
    self:refreshAssistCache()
end

-- 添加宝石数据
--[[
-- 参数
    imprintItem: 需要插入的数据
    onlyInsert: 是否只是插入数据，默认为false，如果设置为true，则需要在适当的地方调用 refreshAssistCache 接口
]]
function CacheImprint:insertImprint(imprintItem, onlyInsert)
    if not imprintItem or not Utility.isEntityId(imprintItem.Id) then
        return
    end

    table.insert(self.mImprintList, imprintItem)
    if not onlyInsert then
        self:refreshAssistCache()
    end
end

-- 修改宝石数据
function CacheImprint:modifyImprintItem(ImprintItem)
    if not ImprintItem or not Utility.isEntityId(ImprintItem.Id) then
        return
    end

    for index, item in pairs(self.mImprintList) do
        if item.Id == ImprintItem.Id then
            self.mImprintList[index] = clone(ImprintItem)
            break
        end
    end
    self:refreshAssistCache()
end

-- 删除宝石列表中的一批数据
function CacheImprint:deleteImprintItems(needDelItemList)
    for _, item in pairs(needDelItemList) do
        self:deleteImprintById(item.Id, true)
    end
    self:refreshAssistCache()
end

-- 根据宝石事例Id删除列表中对应的数据
--[[
-- 参数
    zhenshouId: 宝石实例Id
    onlyDelete: 是否只是删除宝石缓存列表中的数据，默认为false, 外部调用者一般使用默认参数
]]
function CacheImprint:deleteImprintById(imprintId, onlyDelete)
    for index, item in pairs(self.mImprintList) do
        if imprintId == item.Id then
            table.remove(self.mImprintList, index)
            break
        end
    end
    if not onlyDelete then
        self:refreshAssistCache()
    end
    self:clearNewId(imprintId)
end

--- 返回宝石列表数据
--[[
-- 参数：
    filter: 过滤条件 参考 “过滤条件说明”
-- 返回值单个宝石的信息参考文件头部的 “宝石数据说明”   
--]]
function CacheImprint:getImprintList(filter)
    if not filter or not next(filter) then  -- 不需要过滤，直接就返回所有列表数据
        return self.mImprintList
    end

    local ret = {}
    for _, item in ipairs(self.mImprintList) do
        if checkOneItem(item, filter) then
            table.insert(ret, item)
        end
    end

    return ret
end

--- 获取宝石信息,
--[[
-- 获取宝石信息,
-- 参数：
    imprintId:宝石实例id
-- 返回值参考文件头部的 “宝石数据说明” 
--]]
function CacheImprint:getImprint(imprintId)
    return self.mIdList[imprintId]
end

--- 判断玩家是否拥有某种类型的宝石
--[[
-- 参数
    modelId: 宝石的模型Id
    filter: 过滤条件 参考 “过滤条件说明”
-- 返回值
    返回该宝石模型Id的实例列表，单个宝石的信息参考文件头部的 “宝石数据说明” 
 ]]
function CacheImprint:findZhenshouByModelId(modelId, filter)
    local tempList  = self.mModelList[modelId]
    if not filter then
        return tempList
    end
    
    -- 有过滤条件
    local ret = {}
    for _, item in pairs(tempList) do
        if checkOneItem(item, filter) then
            table.insert(ret, item)
        end
    end
    return ret
end

--- 获取玩家拥有某种宝石的数量
--[[
-- 参数：
    modelId: 宝石模型Id
    filter: 过滤条件 参考 “过滤条件说明”
]]
function CacheImprint:getCountByModelId(modelId, filter)
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

-- 获取新宝石Id列表对象
--[[
-- 返回值
    返回值提供的接口查看 "data/NewidList.lua" 文件
]]
function CacheImprint:getNewIdObj()
    return self.mNewIdObj
end

function CacheImprint:clearNewId(instanceId)
    self.mNewIdObj:clearNewId(instanceId)
    -- Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagHero)
end

-- 获取新得到物品的模型Id列表
function CacheImprint:getNewModelIdList()
    local tempList = {}
    for _, newId in pairs(self.mNewIdObj:getNewIdList()) do
        local tempImprint = self.mIdList[newId]
        tempList[tempImprint.ModelId] = true
    end

    return table.keys(tempList)
end

-- 获取宝石属性（进阶属性除外）
--[[
    imprintId: 宝石实例Id
    imprintModelId: 宝石模型Id, 如果 imprintId 为有效值，该参数失效
返回
    baseAttrInfo = {},
    ramdomAttrInfo = {},

]]
function CacheImprint:getImprintAttrList(imprintId, imprintModelId)
    local baseAttrList = {}
    local ramdomAttrList = {}

    if (not imprintId) and (not imprintModelId) then return baseAttrList, ramdomAttrList end

    if imprintId and Utility.isEntityId(imprintId) then
        local imprintInfo = self:getImprint(imprintId)
        imprintModelId = imprintInfo.ModelId

        -- 等级属性
        local lvupAttr = ImprintModel.items[imprintModelId].lvupAttr
        for _, attrInfo in pairs(Utility.analysisStrAttrList(lvupAttr)) do
            attrInfo.value = attrInfo.value*imprintInfo.Lv

            baseAttrList[attrInfo.fightattr] = baseAttrList[attrInfo.fightattr] or 0
            baseAttrList[attrInfo.fightattr] = baseAttrList[attrInfo.fightattr] + attrInfo.value
        end

        -- 随机基础属性
        local randomAttrIdList = string.splitBySep(imprintInfo.AttrIdStr or "", ",")
        local starNum = ImprintModel.items[imprintModelId].stars
        for _, attrId in pairs(randomAttrIdList) do
            local randomAttrInfo = ImprintRandomAttrRelation.items[starNum][tonumber(attrId)]
            -- 基础属性
            local attrData = Utility.analysisStrAttrList(randomAttrInfo.baseAttr)
            for _, attrInfo in pairs(attrData) do
                ramdomAttrList[attrInfo.fightattr] = ramdomAttrList[attrInfo.fightattr] or 0
                ramdomAttrList[attrInfo.fightattr] = ramdomAttrList[attrInfo.fightattr] + attrInfo.value
            end
        end
        -- 随机成长属性
        local randomLvUpAttrList = Utility.analysisStrAttrList(imprintInfo.LvUpAttrStr)
        for _, attrInfo in pairs(randomLvUpAttrList) do
            ramdomAttrList[attrInfo.fightattr] = ramdomAttrList[attrInfo.fightattr] or 0
            ramdomAttrList[attrInfo.fightattr] = ramdomAttrList[attrInfo.fightattr] + attrInfo.value
        end
    end
    -- 基础属性
    local attrData = Utility.analysisStrAttrList(ImprintModel.items[imprintModelId].baseAttr)
    for _, attrInfo in pairs(attrData) do
        baseAttrList[attrInfo.fightattr] = baseAttrList[attrInfo.fightattr] or 0
        baseAttrList[attrInfo.fightattr] = baseAttrList[attrInfo.fightattr] + attrInfo.value
    end

    -- 序列化
    local function sequence(attrList)
        local fightattrList = table.keys(attrList)
        table.sort(fightattrList, function (fightattr1, fightattr2)
            return fightattr1 < fightattr2
        end)
        local tempList = {}
        for i = 1, #fightattrList do
            local attrInfo = {fightattr = fightattrList[i], value = attrList[fightattrList[i]]}
            table.insert(tempList, attrInfo)
        end

        return tempList
    end

    local baseAttrInfo = sequence(baseAttrList)
    local ramdomAttrInfo = sequence(ramdomAttrList)

    return baseAttrInfo, ramdomAttrInfo
end

-- 获取整个卡槽所有宝石属性
function CacheImprint:getSlotAllAttr(slotId)
    local imprintItemList = FormationObj:getSlotImprint(slotId)
    local attrList = {}
    for _, imprintInfo in pairs(imprintItemList) do
        local baseAttrList, ramdomAttrList = self:getImprintAttrList(imprintInfo.Id)

        for _, attrInfo in pairs(baseAttrList) do
            attrList[attrInfo.fightattr] = attrList[attrInfo.fightattr] or 0
            attrList[attrInfo.fightattr] = attrList[attrInfo.fightattr] + attrInfo.value
        end

        for _, attrInfo in pairs(ramdomAttrList) do
            attrList[attrInfo.fightattr] = attrList[attrInfo.fightattr] or 0
            attrList[attrInfo.fightattr] = attrList[attrInfo.fightattr] + attrInfo.value
        end
    end

    local fightattrList = table.keys(attrList)
    table.sort(fightattrList, function (fightattr1, fightattr2)
        return fightattr1 < fightattr2
    end)
    local tempList = {}
    for i = 1, #fightattrList do
        local attrInfo = {fightattr = fightattrList[i], value = attrList[fightattrList[i]]}
        table.insert(tempList, attrInfo)
    end

    return tempList
end

-- 获取宝石套装属性描述
--[[
参数
    imprintModelId: 宝石模型Id, 如果 imprintId 为有效值，该参数失效
返回
    introDescList = {
        {
            desc = TR("暴击+600"),
            needNum = 2,
        }
    }
]]
function CacheImprint:getImprintSuitIntro(imprintModelId)
    if (not imprintModelId) then return {} end

    local introDescList = {}
    local imprintModel = ImprintModel.items[imprintModelId]
    local imprintSuitModel = ImprintSuitRelation.items[imprintModel.suitId]

    for needNum, suitInfo in pairs(imprintSuitModel) do
        table.insert(introDescList, suitInfo)
    end

    -- 排序
    table.sort(introDescList, function (descInfo1, descInfo2)
        return descInfo1.wearNum < descInfo2.wearNum
    end)

    return introDescList
end

-- 获取某宝石同类宝石上阵数量
--[[
参数：
    imprintId:  宝石实例Id
    slotId:     卡槽id(不传遍历所有卡槽找最多同类型宝石卡槽)
返回：
    {}
]]
function CacheImprint:getImprintCombatNum(imprintId, slotId)
    local maxNum = 0
    if not imprintId or not Utility.isEntityId(imprintId) then return maxNum end

    local imprintInfo = self:getImprint(imprintId)

    local imprintModelId = imprintInfo.ModelId
    local imprintModel = ImprintModel.items[imprintModelId]

    if slotId then
        -- 获取该卡槽所有宝石
        local imprintItemList = FormationObj:getSlotImprint(slotId)
        for _, imprintItem in pairs(imprintItemList) do
            local tempModel = ImprintModel.items[imprintItem.ModelId]
            if tempModel.suitId == imprintModel.suitId then
                maxNum = maxNum+1
            end
        end
    else
        -- 获取所有卡槽所有宝石
        local allImprintList = FormationObj:getCombtImprint()
        for _, imprintItemList in pairs(allImprintList) do
            local tempNum = 0
            for _, imprintItem in pairs(imprintItemList) do
                local tempModel = ImprintModel.items[imprintItem.ModelId]
                if tempModel.suitId == imprintModel.suitId then
                    tempNum = tempNum+1
                end
            end
            maxNum = maxNum > tempNum and maxNum or tempNum
        end
    end

    return maxNum
end

-- 是否拥有某部位可上阵宝石
function CacheImprint:isHaveCanCombat(partId)
    local imprintItemList = self:getImprintList({notInFormation = true})
    for _, imprintItem in pairs(imprintItemList) do
        local imprintModel = ImprintModel.items[imprintItem.ModelId]
        if imprintModel.equipTypeID == partId then
            return true
        end
    end

    return false
end

-- 获取某槽位激活套装属性
--[[
params:
    slotId  卡槽id
返回
    {
        {
            name
            needNum
            talId
            suitId
        }
        ...
    }
]]
function CacheImprint:getSlotActiveSuit(slotId)
    local imprintItemList = FormationObj:getSlotImprint(slotId)
    local suitInfoList = {}
    for _, imprintItem in pairs(imprintItemList) do
        local imprintModel = ImprintModel.items[imprintItem.ModelId]
        suitInfoList[imprintModel.suitId] = suitInfoList[imprintModel.suitId] or 0
        suitInfoList[imprintModel.suitId] = suitInfoList[imprintModel.suitId] + 1
    end

    local suitAttrList = {}
    for suitId, count in pairs(suitInfoList) do
        for _, suitModel in pairs(ImprintSuitRelation.items[suitId]) do
            if suitModel.wearNum <= count then
                table.insert(suitAttrList, {
                    name = suitModel.suitName,
                    needNum = suitModel.wearNum,
                    talId = suitModel.talId,
                    suitId = suitId,
                })
            end
        end
    end
    -- 排序
    table.sort(suitAttrList, function (suitAttrInfo1, suitAttrInfo2)
        if suitAttrInfo1.suitId ~= suitAttrInfo2.suitId then
            return suitAttrInfo1.suitId < suitAttrInfo2.suitId
        end
        if suitAttrInfo1.needNum ~= suitAttrInfo2.needNum then
            return suitAttrInfo1.needNum < suitAttrInfo2.needNum
        end
    end)

    return suitAttrList
end

-- 锁定or解锁宝石
function CacheImprint:setImprintLock(Id, callback)
    HttpClient:request({
        moduleName = "Imprint",
        methodName = "Lock",
        svrMethodData = {Id},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            ImprintObj:setImprintList(response.Value.ImprintInfo)
            if callback then
                callback()
            end
        end
    })
end

return CacheImprint