--[[
文件名:CacheTreasureDebris.lua
描述：神兵碎片数据抽象类型
创建人：liaoyuangang
创建时间：2016.05.09
--]]

-- 神兵碎片数据说明
--[[
-- 服务器返回的神兵碎片数据中，每个条目包含的字段如下
	{
        Id:实体ID
        TreasureDebrisModelId: 神兵碎片模型Id
        Num: 数量
    },
]]

local CacheTreasureDebris = class("CacheTreasureDebris", {})

--[[
]]
function CacheTreasureDebris:ctor()
    -- 神兵碎片列表的原始数据
	self.mTreasureDebrisList = {}
    -- 法身碎片列表数据
    self.mBookDebrisList = {}
    -- 神兽碎片列表数据
    self.mHorseDebrisList = {}
    -- 以实例Id为key的神兵碎片列表
    self.mIdList = {}
    -- 以模型Id为key的神兵碎片列表
    self.mModelList = {}

    -- 法身碎片对应的法身模型Id列表
    self.mBookModelIdList = {}
    -- 神兽碎片对应的神兽模型Id列表
    self.mHorseModelIdList = {}

    -- 基础法身模型Id列表
    self.mBaseBookModelIdList = {}
    -- 基础神兽模型Id列表
    self.mBaseHorseModelIdList = {}
    require("Config.TreasureModel")
    for _, item in pairs(TreasureModel.items) do
        if item.ifBase then
            if item.typeID == ResourcetypeSub.eBook then
                table.insert(self.mBaseBookModelIdList, item.ID)
            else
                table.insert(self.mBaseHorseModelIdList, item.ID)
            end
        end
    end

    -- 新得到神兵碎片Id列表对象
    self.mNewIdObj = require("data.NewIdList"):create()
end

-- 清空管理对象中的数据
function CacheTreasureDebris:reset()
    self.mTreasureDebrisList = {}
    self.mBookDebrisList = {}
    self.mHorseDebrisList = {}
    self.mIdList = {}
    self.mModelList = {}
    self.mBookModelIdList = {}
    self.mHorseModelIdList = {}

    self.mNewIdObj:clearNewId()
end

-- 刷新神兵碎片辅助缓存，主要用于数据获取时效率优化
function CacheTreasureDebris:refreshAssistCache()
    self.mBookDebrisList = {}
    self.mHorseDebrisList = {}
    self.mIdList = {}
    self.mModelList = {}
    self.mBookModelIdList = {}
    self.mHorseModelIdList = {}

    for index, item in pairs(self.mTreasureDebrisList) do
        self.mIdList[item.Id] = item
        self.mModelList[item.TreasureDebrisModelId] = self.mModelList[item.TreasureDebrisModelId] or {}
        table.insert(self.mModelList[item.TreasureDebrisModelId], item)

        local tempModel = TreasureDebrisModel.items[item.TreasureDebrisModelId]
        if tempModel.typeID == ResourcetypeSub.eBookDebris then
            table.insert(self.mBookDebrisList, item)
            self.mBookModelIdList[tempModel.treasureModelID] = true
        elseif tempModel.typeID == ResourcetypeSub.eHorseDebris then
            table.insert(self.mHorseDebrisList, item)
            self.mHorseModelIdList[tempModel.treasureModelID] = true
        end
    end

    self:refreshCompundState()
end

-- 刷新可合成状态
function CacheTreasureDebris:refreshCompundState()
    self.mBookStateList = {}
    self.mHorseStateList = {}
    self.mTreasureStateList = {}

    for index, item in pairs(self.mTreasureDebrisList) do
        local debrisModel = TreasureDebrisModel.items[item.TreasureDebrisModelId]
        local treasureModelID = debrisModel.treasureModelID
        if self.mTreasureStateList[treasureModelID] == nil then
            -- 计算是否足够
            local debrisModelIds = TreasureModel.items[treasureModelID].debrisModelIds
            local isEnough = true
            for i, debrisModelId in ipairs(debrisModelIds) do
                -- 拥有数量
                local num = self:getCountByModelId(debrisModelId)
                if num <= 0 then
                    isEnough = false
                    break
                end
            end

            -- 保存数据
            self.mTreasureStateList[treasureModelID] = isEnough
            if debrisModel.typeID == ResourcetypeSub.eBookDebris then
                self.mBookStateList[treasureModelID] = isEnough
            elseif debrisModel.typeID == ResourcetypeSub.eHorseDebris then
                self.mHorseStateList[treasureModelID] = isEnough
            end
        end
    end

    -- 通知
    Notification:postNotification(EventsName.eRedDotPrefix .. ModuleSub.eChallengeGrab)
end

-- 计算合成状态
function CacheTreasureDebris:getCompoundState(resourcetypeSub)
    function getState(states)
        local canCompound = false
        for i, state in pairs(states) do
            if state == true then
                canCompound = true
                break
            end
        end
        return canCompound
    end

    if resourcetypeSub == ResourcetypeSub.eBookDebris then
        return getState(self.mBookStateList)
    elseif resourcetypeSub == ResourcetypeSub.eHorseDebris then
        return getState(self.mHorseStateList)
    else
        return getState(self.mTreasureStateList)
    end
end

-- 设置神兵碎片列表
function CacheTreasureDebris:setTreasureDebrisList(debrisList)
    self.mTreasureDebrisList = debrisList or self.mTreasureDebrisList
    self:refreshAssistCache()
end

-- 神兵碎片数据改变
--[[
-- 参数
    modifyItems: 神兵碎片修改部分的数据列表，其中每条数据的内容参考文件头处的 “神兵碎片数据说明”
]]
function CacheTreasureDebris:modifyTreasureDebris(modifyItems)
    -- 更具模型Id删除道具列表中对应条目
    local function deleteGoodsByModel(modelId)
        local ret = {}
        for index = #self.mTreasureDebrisList, 1, -1 do
            local tempItem = self.mTreasureDebrisList[index]

            if tempItem.TreasureDebrisModelId == modelId then
                table.insert(ret, tempItem)
                table.remove(self.mTreasureDebrisList, index)
            end
        end

        return ret
    end

    for key, itemList in pairs(modifyItems or {}) do
        local modelId = tonumber(key)
        local tempModel = TreasureDebrisModel.items[modelId]
        -- 先删除缓存数据中相关模型Id的数据
        local delItemList = deleteGoodsByModel(modelId)

        -- 把请求到的数据更新到缓存中
        for index, item in pairs(itemList) do
            table.insert(self.mTreasureDebrisList, item)
        end

        -- 神兵碎片信息改变通知
        Notification:postNotification(EventsName.eTreasureDebrisRedDotPrefix .. tostring(modelId))
    end
    -- 
    self:refreshAssistCache()
end

-- 获取是否有需要提示小红点的神兵碎片
function CacheTreasureDebris:haveRedDotTreasureDebris(returnModelId)
    local ret, retModelId, retModelColor = false, nil, 0

    for _, debris in ipairs(self.mTreasureDebrisList) do
        local tempModel = TreasureDebrisModel.items[debris.TreasureDebrisModelId]
        local tempColorLv = tempModel and Utility.getQualityColorLv(tempModel.quality) or 0
        local treasureModel = TreasureModel.items[tempModel and tempModel.treasureModelID or 0]

        if treasureModel and treasureModel.maxLV > 0 and tempColorLv > 3 then
            ret = true
            if not returnModelId then
                break
            end
            if tempColorLv > retModelColor then
                retModelColor, retModelId = tempColorLv, tempModel.treasureModelID
            end
        end
    end

    return ret, retModelId
end

-- 判断玩家是否拥有某神兵的碎片
function CacheTreasureDebris:haveTreasureOfDebris(treasureModelID)
    return self.mBookModelIdList[treasureModelID] or self.mHorseModelIdList[treasureModelID] or false
end

-- 获取神兵碎片模型Id对应的神兵碎片
--[[
-- 参数
    modelId: 神兵碎片模型Id
-- 返回值
    {
        {
            神兵碎片信息
        }
        ...
    }
]]
function CacheTreasureDebris:findByModelId(modelId)
    return self.mModelList[modelId] or {}
end

-- 根据神兵碎片模型Id获取神兵碎片的数量
function CacheTreasureDebris:getCountByModelId(modelId)
    local ret = 0
    for _, item in pairs(self.mModelList[modelId] or {}) do
        ret = ret + item.Num
    end

    return ret
end

-- 获取神兵碎片对应的神兵模型列表
--[[
-- 参数 
    resourcetypeSub: 取值为 ResourcetypeSub.eBook 或 ResourcetypeSub.eHorse, 默认为 eHorse
    needBaseTreasure: 是否需要基础神兵模型Id
-- 返回值
    {
        treasureModelID,
        ...
    }
]]
function CacheTreasureDebris:getTreasureModelId(resourcetypeSub, needBaseTreasure)
    local modelIdList = (resourcetypeSub == ResourcetypeSub.eBook) and self.mBookModelIdList or self.mHorseModelIdList
    local ret = table.keys(modelIdList)
    if needBaseTreasure then
        local baseList = (resourcetypeSub == ResourcetypeSub.eBook) and self.mBaseBookModelIdList or self.mBaseHorseModelIdList
        for _, baseId in pairs(baseList) do
            if not modelIdList[baseId] then
                table.insert(ret, baseId)
            end
        end
    end

    return ret
end

return CacheTreasureDebris
