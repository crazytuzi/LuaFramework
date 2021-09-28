--[[
文件名:CacheZhenyuan.lua
描述：真元数据抽象类型
创建人：peiyaoqiang
创建时间：2017.12.13
--]]

-- 真元数据说明
--[[
-- 服务器返回的真元数据中，每个条目包含的字段如下
	{
        Id:实体Id
        ModelId:真元模型Id
        Lv:
        Exp:
    },
]]

-- 过滤条件说明
--[[
    { 
        alwaysIdList = {}, -- 始终包含的条目Id列表
        excludeIdList = {}, -- 需要排除掉实体Id
        excludeModelIdList = {}, -- 需要排除的模型Id
        notInFormation = false, -- 是否需要过滤掉上阵的真元，默认为false
        includeExpModel = false, -- 是否包括经验类的真元，默认为false
        colorLv = nil,  -- 需要获取的真元的颜色品级
        maxColorLv = nil, -- 最大颜色等级
        minColorLv = nil, -- 最小颜色等级
        minType = nil, -- 最小类型（主要用于区别天命真元  天命真元type在7-9之间）
        maxType = nil, -- 最大类型（主要用于区别天命真元  天命真元type在7-9之间）
    }
]]

local CacheZhenyuan = class("CacheZhenyuan", {})

-- 检查一个条目是否满足条件
--[[
-- 参数
    zhenyuanItem: 真元信息，参考 “真元数据说明”
    filter: 过滤条件 参考 “过滤条件说明”
]]
local function checkOneItem(zhenyuanItem, filter)
    -- 判断是否是始终需要的记录
    if table.indexof(filter.alwaysIdList or {}, zhenyuanItem.Id) then
        return true
    end
    
    -- 判断需要排除的实体Id
    if table.indexof(filter.excludeIdList or {}, zhenyuanItem.Id) then
        return false
    end
 
    -- 需要排除的模型Id
    if table.indexof(filter.excludeModelIdList or {}, zhenyuanItem.ModelId) then
        return false
    end
    
    -- 过滤掉已上阵的真元
    if filter.notInFormation and FormationObj:zhenyuanInFormation(zhenyuanItem.Id) then
        return false
    end

    -- 过滤掉经验类的真元
    local tempModel = ZhenyuanModel.items[zhenyuanItem.ModelId]
    if (not filter.includeExpModel) and (tempModel.type == 0) then
        return false
    end

    -- 需要的指定真元type
    if filter.minType or filter.maxType then
        if filter.minType and tempModel.type < filter.minType then
            return false
        end

        if filter.maxType and tempModel.type > filter.maxType then
            return false
        end
    end 

    -- 需要的指定真元类型
    if filter.colorLv or filter.maxColorLv or filter.minColorLv then
        local colorLv = Utility.getQualityColorLv(tempModel.quality)

        if filter.colorLv and colorLv ~= filter.colorLv then
            return false
        end

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
function CacheZhenyuan:ctor()
    -- 真元列表的原始数据
	self.mZhenyuanList = {}
    -- 以实例Id为key的真元列表
    self.mIdList = {}
    -- 以模型Id为key的真元列表
    self.mModelList = {}
end

-- 清空管理对象中的数据
function CacheZhenyuan:reset()
    self.mZhenyuanList = {}
    self.mIdList = {}
    self.mModelList = {}
end

-- 刷新真元辅助缓存，主要用于数据获取时效率优化
function CacheZhenyuan:refreshAssistCache()
    self.mIdList = {}
    self.mModelList = {}
    for _, item in pairs(self.mZhenyuanList) do
        self.mIdList[item.Id] = item
        self.mModelList[item.ModelId] = self.mModelList[item.ModelId] or {}
        table.insert(self.mModelList[item.ModelId], item)
    end
end

-- 设置真元列表
function CacheZhenyuan:setZhenyuanList(zhenyuanList)
	self.mZhenyuanList = zhenyuanList
    self:refreshAssistCache()
end

-- 添加真元数据
--[[
-- 参数
    zhenyuanItem: 需要插入的数据
    onlyInsert: 是否只是插入数据，默认为false，如果设置为true，则需要在适当的地方调用 refreshAssistCache 接口
]]
function CacheZhenyuan:insertZhenyuan(zhenyuanItem, onlyInsert)
	if not zhenyuanItem or not Utility.isEntityId(zhenyuanItem.Id) then
        return
    end
    table.insert(self.mZhenyuanList, zhenyuanItem)
    if not onlyInsert then
        self:refreshAssistCache()
    end
end

-- 修改真元数据
function CacheZhenyuan:modifyZhenyuanItem(zhenyuanItem)
	if not zhenyuanItem or not Utility.isEntityId(zhenyuanItem.Id) then
        return
    end

    for index, item in pairs(self.mZhenyuanList) do
        if item.Id == zhenyuanItem.Id then
            self.mZhenyuanList[index] = clone(zhenyuanItem)
            break
        end
    end
    self:refreshAssistCache()
end

-- 删除真元列表中的一批数据
function CacheZhenyuan:deleteZhenyuanItems(needDelItemList)
	for _, item in pairs(needDelItemList) do
        self:deleteZhenyuanById(item.Id, true)
    end
    self:refreshAssistCache()
end

-- 根据真元事例Id删除列表中对应的数据
--[[
-- 参数
    zhenyuanId: 真元实例Id
    onlyDelete: 是否只是删除真元缓存列表中的数据，默认为false, 外部调用者一般使用默认参数
]]
function CacheZhenyuan:deleteZhenyuanById(zhenyuanId, onlyDelete)
	for index, item in pairs(self.mZhenyuanList) do
        if zhenyuanId == item.Id then
            table.remove(self.mZhenyuanList, index)
            break
        end
    end
    if not onlyDelete then
        self:refreshAssistCache()
    end
end

--- 返回真元列表数据
--[[
-- 参数：
    filter: 过滤条件 参考 “过滤条件说明”
-- 返回值单个真元的信息参考文件头部的 “真元数据说明”   
--]]
function CacheZhenyuan:getZhenyuanList(filter)
    if not filter or not next(filter) then  -- 不需要过滤，直接就返回所有列表数据
        return self.mZhenyuanList
    end

    local ret = {}
    for _, item in ipairs(self.mZhenyuanList or {}) do
        if checkOneItem(item, filter) then
            table.insert(ret, item)
        end
    end

    return ret
end

--- 获取真元信息,
--[[
-- 获取真元信息,
-- 参数：
    zhenyuanId:真元实例id
-- 返回值参考文件头部的 “真元数据说明” 
--]]
function CacheZhenyuan:getZhenyuan(zhenyuanId)
    return self.mIdList[zhenyuanId]
end

--- 根据真元模型Id获取真元列表
--[[
-- 参数
    modelId: 真元的模型Id
    filter: 过滤条件 参考 “过滤条件说明”
-- 返回值
    返回该真元模型Id的实例列表，单个真元的信息参考文件头部的 “真元数据说明” 
 ]]
function CacheZhenyuan:findByModelId(modelId, filter)
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

--- 获取玩家拥有某种真元的数量
--[[
-- 参数：
    modelId: 真元模型Id
    filter: 过滤条件 参考 “过滤条件说明”
]]
function CacheZhenyuan:getCountByModelId(modelId, filter)
    local tempList = self.mModelList[modelId] or {}
    if not filter then
        return #tempList
    end
    local ret = 0
    for _, item in pairs(tempList) do
        if checkOneItem(item, filter) then
            ret = ret + 1
        end
    end
    return ret
end

--- 获取以模型Id为key的内功列表
--[[
-- 返回值的格式为：
    {
        [ModelId] = {
            {
            },
            ...
        }
    }
]]
function CacheZhenyuan:getZhenyuanListAsModelId()
    return self.mModelList
end

-- 获取真元上阵卡槽的人物信息
--[[
-- 参数
    zhenyuanId: 真元实例Id
-- 返回值
    第一个返回值：如果该真元已上阵，则返回该真元所在的阵容卡槽Id, 否则为nil
    第二个返回值：如果该真元已上阵，则返回该真元所在阵容卡槽人物的信息， 否则为nil
]]
function CacheZhenyuan:getZhenyuanSlotInfo(zhenyuanId)
    local inFormation, slotId = FormationObj:zhenyuanInFormation(zhenyuanId)
    if not inFormation then
        return 
    end
    local slotInfo = FormationObj:getSlotInfoBySlotId(slotId)
    local heroInfo = HeroObj:getHero(slotInfo.HeroId)
    
    return slotId, heroInfo
end

return CacheZhenyuan
