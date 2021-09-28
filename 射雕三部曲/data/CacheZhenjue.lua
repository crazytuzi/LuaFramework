--[[
文件名:CacheZhenjue.lua
描述：内功心法数据抽象类型
创建人：liaoyuangang
创建时间：2016.05.09
--]]

-- 内功心法数据说明
--[[
-- 服务器返回的内功心法数据中，每个条目包含的字段如下
	{
        Id:实体Id
        ModelId:内功心法模型Id
        TalId:
        TempTalId:
        Step:
        StepAttrData:
        UpAttrData:
        UpAttrRecord:
        TempUpAttrData:
    },
]]

-- 过滤条件说明
--[[
    { 
        alwaysIdList = {}, -- 始终包含的条目Id列表
        excludeIdList = {}, -- 需要排除掉实体Id
        excludeModelIdList = {}, -- 需要排除的模型Id
        notInFormation = false, -- 是否需要过滤掉上阵的内功心法，默认为false
        typeId = nil,  -- 需要获取的内功心法类型, 取值为 ZhenjueModel配置表的typeID字段, 默认为nil
        colorLV = nil,  -- 需要获取的内功心法的颜色品级
        maxColorLv = nil, -- 最大颜色等级
        minColorLv = nil, -- 最小颜色等级
        noStepUp = false, -- 是否过滤掉已进阶的内功，默认为false
        noExtraUp = false, -- 是否过滤掉已洗炼的内功，默认为false
        
        isResolve = true,   -- 选择可分解的内功心法
        isRebirth = true,   -- 选择可重生的内功心法
    }
]]

local CacheZhenjue = class("CacheZhenjue", {})

-- 检查一个条目是否满足条件
--[[
-- 参数
    zhenjueItem: 内功心法信息，参考 “内功心法数据说明”
    filter: 过滤条件 参考 “过滤条件说明”
]]
local function checkOneItem(zhenjueItem, filter)
    -- 判断是否是始终需要的记录
    if table.indexof(filter.alwaysIdList or {}, zhenjueItem.Id) then
        return true
    end
    
    -- 判断需要排除的实体Id
    if table.indexof(filter.excludeIdList or {}, zhenjueItem.Id) then
        return false
    end
 
    -- 需要排除的模型Id
    if table.indexof(filter.excludeModelIdList or {}, zhenjueItem.ModelId) then
        return false
    end

    -- 选择可分解的内功心法
    if filter.isResolve then
        if FormationObj:zhenjueInFormation(zhenjueItem.Id) then
            return false
        end
    end

    -- 判断是否已经进阶和洗炼
    local isAlreadyExtra = false
    for _, value in pairs(zhenjueItem.UpAttrData or {}) do
        if (value > 0) then
            isAlreadyExtra = true
            break
        end
    end
    local nStep = zhenjueItem.Step or 0
    local isAlreadyStep = (nStep > 0)

    -- 选择可重生的内功心法
    if filter.isRebirth then
        -- 去掉已上阵的
        if FormationObj:zhenjueInFormation(zhenjueItem.Id) then
            return false
        end

        -- 去掉蓝色以下的
        if ZhenjueModel.items[zhenjueItem.ModelId].colorLV < 3 then
            return false
        end

        -- 去掉没有洗炼且没有进阶过的
        if (isAlreadyStep == false) and (isAlreadyExtra == false) then
            return false
        end

        return true
    end

    -- 过滤掉已上阵的内功心法
    if filter.notInFormation and FormationObj:zhenjueInFormation(zhenjueItem.Id) then
        return false
    end

    -- 过滤掉已进阶的内功心法
    if filter.noStepUp and (isAlreadyStep == true) then
        return false
    end

    -- 过滤掉已洗炼的内功心法
    if filter.noExtraUp and (isAlreadyExtra == true) then
        return false
    end

    -- 需要的指定内功心法类型
    if filter.typeId or filter.colorLv or filter.maxColorLv or filter.minColorLv then
        local tempModel = ZhenjueModel.items[zhenjueItem.ModelId]
        local colorLv = tempModel.colorLV

        if filter.typeId and filter.typeId ~= tempModel.typeID then
            return false
        end

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
function CacheZhenjue:ctor()
    -- 内功心法列表的原始数据
	self.mZhenjueList = {}
    -- 以实例Id为key的内功心法列表
    self.mIdList = {}
    -- 以模型Id为key的内功心法列表
    self.mModelList = {}
    -- 以内功心法类型Id为key的内功心法列表
    self.mTypeIdList = {}

    -- 新得到神兵Id列表对象
    self.mNewIdObj = require("data.NewIdList"):create()
end

-- 清空管理对象中的数据
function CacheZhenjue:reset()
    self.mZhenjueList = {}
    self.mIdList = {}
    self.mModelList = {}
    self.mTypeIdList = {}

    self.mNewIdObj:clearNewId()
end

-- 刷新内功心法辅助缓存，主要用于数据获取时效率优化
function CacheZhenjue:refreshAssistCache()
    self.mIdList = {}
    self.mModelList = {}
    self.mTypeIdList = {}
    for _, item in pairs(self.mZhenjueList) do
        self.mIdList[item.Id] = item
        self.mModelList[item.ModelId] = self.mModelList[item.ModelId] or {}
        table.insert(self.mModelList[item.ModelId], item)

        local tempModel = ZhenjueModel.items[item.ModelId]
        self.mTypeIdList[tempModel.typeID] = self.mTypeIdList[tempModel.typeID] or {}
        table.insert(self.mTypeIdList[tempModel.typeID], item)
    end
end

-- 设置内功心法列表
function CacheZhenjue:setZhenjueList(zhenjueList)
	self.mZhenjueList = zhenjueList
    self:refreshAssistCache()
end

-- 添加内功心法数据
--[[
-- 参数
    zhenjueItem: 需要插入的数据
    onlyInsert: 是否只是插入数据，默认为false，如果设置为true，则需要在适当的地方调用 refreshAssistCache 接口
]]
function CacheZhenjue:insertZhenjue(zhenjueItem, onlyInsert)
	if not zhenjueItem or not Utility.isEntityId(zhenjueItem.Id) then
        return
    end
    table.insert(self.mZhenjueList, zhenjueItem)
    if not onlyInsert then
        self:refreshAssistCache()
    end

    local tempModel = ZhenjueModel.items[zhenjueItem.ModelId]
    if tempModel and tempModel.colorLV > 3 then    
        self.mNewIdObj:insertNewId(zhenjueItem.Id)
    end
end

-- 修改内功心法数据
function CacheZhenjue:modifyZhenjueItem(zhenjueItem)
	if not zhenjueItem or not Utility.isEntityId(zhenjueItem.Id) then
        return
    end

    for index, item in pairs(self.mZhenjueList) do
        if item.Id == zhenjueItem.Id then
            self.mZhenjueList[index] = clone(zhenjueItem)
            break
        end
    end
    self:refreshAssistCache()
end

-- 删除内功心法列表中的一批数据
function CacheZhenjue:deleteZhenjueItems(needDelItemList)
	for _, item in pairs(needDelItemList) do
        self:deleteZhenjueById(item.Id, true)
    end
    self:refreshAssistCache()
end

-- 根据内功心法事例Id删除列表中对应的数据
--[[
-- 参数
    zhenjueId: 内功心法实例Id
    onlyDelete: 是否只是删除内功心法缓存列表中的数据，默认为false, 外部调用者一般使用默认参数
]]
function CacheZhenjue:deleteZhenjueById(zhenjueId, onlyDelete)
	for index, item in pairs(self.mZhenjueList) do
        if zhenjueId == item.Id then
            table.remove(self.mZhenjueList, index)
            break
        end
    end
    if not onlyDelete then
        self:refreshAssistCache()
    end
    self.mNewIdObj:clearNewId(zhenjueId)
end

--- 返回内功心法列表数据
--[[
-- 参数：
    filter: 过滤条件 参考 “过滤条件说明”
-- 返回值单个内功心法的信息参考文件头部的 “内功心法数据说明”   
--]]
function CacheZhenjue:getZhenjueList(filter)
    if not filter or not next(filter) then  -- 不需要过滤，直接就返回所有列表数据
        return self.mZhenjueList
    end

    local typeId = filter.typeId
    local tempList = typeId and self.mTypeIdList[typeId] or not typeId and self.mZhenjueList or {}
    -- 判断是否只过内功心法类型
    local function onlyFilterType()
        for key, value in pairs(filter) do
            if key ~= "typeId" then
                return false
            end
        end
        return true
    end
    if onlyFilterType() then
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

--- 获取内功心法信息,
--[[
-- 获取内功心法信息,
-- 参数：
    zhenjueId:内功心法实例id
-- 返回值参考文件头部的 “内功心法数据说明” 
--]]
function CacheZhenjue:getZhenjue(zhenjueId)
    return self.mIdList[zhenjueId]
end

--- 根据内功心法模型Id获取内功心法列表
--[[
-- 参数
    modelId: 内功心法的模型Id
    filter: 过滤条件 参考 “过滤条件说明”
-- 返回值
    返回该内功心法模型Id的实例列表，单个内功心法的信息参考文件头部的 “内功心法数据说明” 
 ]]
function CacheZhenjue:findByModelId(modelId, filter)
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

-- 根据内功心法类型获取内功心法列表
--[[
-- 参数
    typeId: 内功心法的类型Id
    filter: 过滤条件 参考 “过滤条件说明”
-- 返回值
    返回该内功心法模型Id的实例列表，单个内功心法的信息参考文件头部的 “内功心法数据说明” 
 ]]
function CacheZhenjue:findByTypeId(typeId, filter)
    local tempList = self.mTypeIdList[typeId] or {}
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

--- 获取玩家拥有某种内功心法的数量
--[[
-- 参数：
    modelId: 内功心法模型Id
    filter: 过滤条件 参考 “过滤条件说明”
]]
function CacheZhenjue:getCountByModelId(modelId, filter)
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
function CacheZhenjue:getZhenjueListAsModelId()
    return self.mModelList
end

-- 获取某类型内功心法的数量
--[[
-- 参数
    typeId: 内功心法的类型Id
    filter: 过滤条件 参考 “过滤条件说明”
 ]]
function CacheZhenjue:getCountByTypeId(typeId, filter)
    local tempList = self.mTypeIdList[typeId] or {}
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

-- 获取内功心法上阵卡槽的人物信息
--[[
-- 参数
    zhenjueId: 内功心法实例Id
-- 返回值
    第一个返回值：如果该内功心法已上阵，则返回该内功心法所在的阵容卡槽Id, 否则为nil
    第二个返回值：如果该内功心法已上阵，则返回该内功心法所在阵容卡槽人物的信息， 否则为nil
]]
function CacheZhenjue:getZhenjueSlotInfo(zhenjueId)
    local inFormation, slotId = FormationObj:zhenjueInFormation(zhenjueId)
    if not inFormation then
        return 
    end
    local slotInfo = FormationObj:getSlotInfoBySlotId(slotId)
    local heroInfo = HeroObj:getHero(slotInfo.HeroId)
    
    return slotId, heroInfo
end

-- 获取新得到内功心法Id列表对象
--[[
-- 返回值
    返回值提供的接口查看 "data/NewidList.lua" 文件
]]
function CacheZhenjue:getNewIdObj()
    return self.mNewIdObj
end

-- 计算内功心法的洗炼进度百分比
--[[
-- 参数:
    zhenjueId: 阵诀ID
    info: 阵诀信息，为空则计算当前玩家
    plv: 玩家信息，为空则计算当前玩家
-- 返回值
    进度百分比数字（未处理过）
]]
function CacheZhenjue:calcPercent(zhenjueId, info, plv)
    if (zhenjueId == nil) then
        return 0
    end
    
    local zhenjueInfo = info or (self:getZhenjue(zhenjueId) or {})
    local zhenjueModel = ZhenjueModel.items[zhenjueInfo.ModelId or 0]
    if (zhenjueModel == nil) or (zhenjueModel.upOddsClass == 0) then
        return 0
    end

    -- 计算系数
    local playerLv = plv or PlayerAttrObj:getPlayerAttrByName("Lv")
    local mUpMaxItem = nil
    for key, item in pairs(ZhenjueUpmaxLvRelation.items) do
        if (not mUpMaxItem) or (key <= playerLv) and (mUpMaxItem.playerLv < item.playerLv) then
            mUpMaxItem = item
        end
    end

    -- 计算百分比
    local tmpPercent, tmpCount = 0, 0
    local attrList = Utility.analysisStrAttrList(zhenjueModel.initAttrStr)
    local upUnitAttrList = Utility.analysisStrAttrList(zhenjueModel.upUnitAttrStr)
    for index, item in pairs(attrList) do
        local tmpMaxValue = math.floor(upUnitAttrList[index].value * mUpMaxItem.upAttrR * self:getTimesOfStep(zhenjueInfo))
        local tmpCurValue = 0
        for key, value in pairs(zhenjueInfo.UpAttrData) do
            if tonumber(key) == item.fightattr then
                tmpCurValue = value
                break
            end
        end
        tmpCount = tmpCount + 1
        tmpPercent = tmpPercent + (tmpCurValue/tmpMaxValue)
    end
    if (tmpCount == 0) then
        return 0
    end
    return tmpPercent/tmpCount
end

-- 获取内功心法进阶后的基础属性加成倍数
function CacheZhenjue:getTimesOfStep(info)
    if (info == nil) or (info.ModelId == nil) then
        return 1
    end
    
    -- 进阶系数
    local nStepTimes = 1
    local stepConfig = ZhenjueStepRelation.items[info.ModelId] or {}
    local currConfig = stepConfig[info.Step or 0]
    if (currConfig ~= nil) then
        nStepTimes = currConfig.stepAttrRAdd / 10000
    end

    return nStepTimes
end

-- 返回内功心法的进阶名字图片
--[[
-- 返回值
    进阶时候使用的名字图片，如果返回nil，表明该内功心法不能进阶
]]
function CacheZhenjue:getNameImgOfStep(modelId)
    local nameImgList = {
        [18015101] = "ng_29.png", [18015102] = "ng_33.png", [18015201] = "ng_34.png", 
        [18015202] = "ng_32.png", [18015301] = "ng_30.png", [18015302] = "ng_31.png", 
    } 
    return nameImgList[modelId]
end

return CacheZhenjue
