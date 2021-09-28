--[[
文件名:CacheIllusion.lua
描述：幻化数据抽象类型
创建人：peiyaoqiang
创建时间：2017.09.09
--]]

-- 幻化数据说明
--[[
    服务器返回的幻化数据，每条格式格式为：
    {
        Id:        实体ID
        ModelId:   模型ID
    },
--]]

-- 过滤条件说明
--[[
    {
        alwaysIdList = {}, -- 始终包含的条目Id列表
        excludeIdList = {}, -- 需要排除掉实体Id
        notInFormation = false, -- 是否需要过滤掉上阵的幻化将，默认为false
    }
-- ]]

local CacheIllusion = class("CacheIllusion", {})

-- 检查一个条目是否满足条件
--[[
-- 参数
    illuItem: 幻化将信息，参考 “幻化数据说明”
    filter: 过滤条件 参考 “过滤条件说明”
-- ]]
local function checkOneItem(illuItem, filter)
    if (filter == nil) then
        return true
    end

    -- 判断是否是始终需要的记录
    if table.indexof(filter.alwaysIdList or {}, illuItem.Id) then
        return true
    end

    -- 判断需要排除的实体Id
    if table.indexof(filter.excludeIdList or {}, illuItem.Id) then
        return false
    end

    -- 过滤掉已上阵的幻化将
    if filter.notInFormation and IllusionObj:getOneItemInFormation(illuItem.Id) then
        return false
    end
    
    return true
end

--[[
--]]
function CacheIllusion:ctor()
    self.myIllusionList = {}

    -- 新得到幻化Id列表对象
    self.mNewIdObj = require("data.NewIdList"):create()
end

-- 清空管理对象中的数据
function CacheIllusion:reset()
    self.myIllusionList = {}
    self.mNewIdObj:clearNewId()
    Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagIllusionDebris)

end

-- 获取玩家拥有的时装列表
function CacheIllusion:setIllusionList(illusionList)
    self.myIllusionList = illusionList or {}
end

--- 返回玩家拥有的幻化列表的原始数据
function CacheIllusion:getIllusionList(filter)
    local tempList = clone(self.myIllusionList)
    local tempNeedList = {}
    if filter then
        for i,v in ipairs(tempList) do
            if checkOneItem(v, filter) then
                table.insert(tempNeedList, v)
            end
        end
    end
    return tempNeedList
end

-- 根据modelId统计玩家拥有该幻化的数量
function CacheIllusion:getCountByModelId(modelId, filter)
    local num = 0
    for k,v in pairs(self.myIllusionList) do
        if (v.ModelId == modelId) and checkOneItem(v, filter) then 
            num = num + 1
        end 
    end

    return num
end

-- 判断某种幻化是否已拥有
function CacheIllusion:getOneItemOwned(modelId)
    if (modelId == nil) then
        return false
    end

    -- 只要拥有任意一个即可
    local retOwned = false
    for _, v in pairs(self.myIllusionList) do
        if v.ModelId == modelId then 
            retOwned = true
            break
        end 
    end

    return retOwned
end

-- 判断某种幻化是否已上阵InFormation
function CacheIllusion:getOneTypeInFormation(modelId)
    if (modelId == nil) then
        return false
    end

    -- 只要有任意一个上阵即可
    local retFormationIn = false
    -- 是否上阵需要根据玩家学员信息里面的IllusionModelId判断 如果存在就说明已经上阵在某hero身上
    for _, info in pairs(HeroObj:getHeroList()) do
        if (info.IllusionModelId ~= nil) and (info.IllusionModelId == modelId) then 
            retFormationIn = true
            break
        end 
    end

    return retFormationIn
end

-- 判断某个幻化是否已上阵
function CacheIllusion:getOneItemInFormation(itemId)
    if (itemId == nil) then
        return false
    end

    local retFormationIn = false
    for _, info in pairs(HeroObj:getHeroList()) do
        if (info.IllusionId ~= nil) and (info.IllusionId == itemId) then 
            retFormationIn = true
            break
        end 
    end

    return retFormationIn
end

-- 根据幻化modelId获取对应的上阵hero的heroId(如果没有上阵返回EMPTY_ENTITY_ID)
function CacheIllusion:getInFormationHeroId(modelId)
    if (modelId == nil) then
        return EMPTY_ENTITY_ID
    end

    local heroId = EMPTY_ENTITY_ID
    local heroData = HeroObj:getHeroList()
    for _, info in pairs(heroData) do
        if info.IllusionModelId == modelId then 
            heroId = info.Id
            break
        end 
    end

    return heroId
end

-- 根据modelId获取某一个幻化的所有实体Id集合
function CacheIllusion:getOneTypeIdList(modelId, filter)
    if (modelId == nil) then
        return {}
    end

    local idList = {}
    for _, v in pairs(self.myIllusionList) do
        if (v.ModelId == modelId) and checkOneItem(v, filter) then 
            table.insert(idList, v)
        end 
    end

    return idList
end

-- 根据实例id获取对应幻化信息
--[[
-- 参数
    illusionId: 幻化的实例id
]]
function CacheIllusion:getIllusion(illusionId)
    if not Utility.isEntityId(illusionId) then
        return
    end

    for i,v in ipairs(self.myIllusionList) do
        if (v.Id == illusionId) then
            return clone(v)
        end
    end
end

-- 添加幻化数据
--[[
-- 参数
    illusionItem: 需要插入的数据
    格式：服务器返回的幻化数据，每条格式格式为：
    {
        Id:        实体ID
        ModelId:   模型ID
    },
]]
function CacheIllusion:insertIllusion(illusionItem)
    if not illusionItem or not Utility.isEntityId(illusionItem.Id) then
        return
    end
    self.mNewIdObj:insertNewId(illusionItem.Id)
    table.insert(self.myIllusionList, illusionItem)
end

-- 删除幻化数据
--[[
-- 参数
    illusionId: 需要删除的id
]]
function CacheIllusion:deleteIllusion(illusionId)
    if not Utility.isEntityId(illusionId) then
        return
    end

    for i,v in ipairs(self.myIllusionList) do
        if (v.Id == illusionId) then
            table.remove(self.myIllusionList, i)
            break
        end
    end
end

-- 获取新人物Id列表对象
--[[
-- 返回值
    返回值提供的接口查看 "data/NewidList.lua" 文件
]]
function CacheIllusion:getNewIdObj()
    return self.mNewIdObj
end

-- 
function CacheIllusion:clearNewId(instanceId)
    self.mNewIdObj:clearNewId(instanceId)
    Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagIllusionDebris)
end

-- -- 获取新得到物品的模型Id列表
-- function CacheIllusion:getNewModelIdList()
--     local tempList = {}
--     for _, newId in pairs(self.mNewIdObj:getNewIdList()) do
--         local tempHero = self.mIdList[newId]
--         tempList[tempHero.ModelId] = true
--     end

--     return table.keys(tempList)
-- end

return CacheIllusion