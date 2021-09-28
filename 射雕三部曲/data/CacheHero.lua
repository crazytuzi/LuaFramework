--[[
文件名:CacheHero.lua
描述：人物数据抽象类型
创建人：liaoyuangang
创建时间：2016.05.09
--]]

-- 人物数据说明
--[[
-- 服务器返回的人物数据中，每个条目包含的字段如下
	{
        ModelId   = 12012032,  -- 模型Id
        Id            = "87a4d8c3-cda1-4128-b496-4400b92ab264", -- 实体Id
        Lv            = 1, -- 等级
        Step          = 0, -- 进阶数

        -- 转身相关
        RebornId:转身Id,
        RebornNum:激活到的卡槽数

        -- 天赋相关
        Talent = {
            "6" = 10040160,
            "8" = 10040160,
            "10" = 10040160,
        }

        -- 时装信息
        CombatFashionOrder    -- 上阵的时装Id
        ActivatedFashionStr   -- 激活的时装Id
    },
]]

-- 过滤条件说明
--[[
-- 人物过滤条件项如下
    { 
        alwaysIdList = {}, -- 始终包含的条目Id列表
        notInFormation = false, -- 是否需要过滤掉上阵的神兵，默认为false
        excludeModelIds = {}, -- 需要排除的模型Id
        excludeIdList = {}, -- 需要排除掉实体Id
        minColorLv = 1,     -- 最低的颜色等级，默认为1
        maxColorLv = 7,     -- 最高的颜色等级，默认为7，金色
        maxLv = 1000,       -- 最大的强化等级, 默认为 1000
        minLv = 0,          -- 最小的强化等级，默认为0
        maxStep = 1000,     -- 最大的进阶等级， 默认为1000
        minStep = 0,        -- 最小进阶等级
        isResolve = true,   -- 选择可分解的人物，已经进阶和升级的显示在后面并且不可选
        isRebirth = true,   -- 选择可重生的人物，升级或进阶过，不符合条件的不显示
    }
]]

local CacheHero = class("CacheHero", {})

-- 检查一个条目是否满足条件
--[[
-- 参数
    heroItem: 人物信息，参考 “人物数据说明”
    filter: 过滤条件 参考 “过滤条件说明”
]]
local function checkOneItem(heroItem, filter)
    -- 过滤掉主角
    local tempModel = HeroModel.items[heroItem.ModelId]
    if (tempModel ~= nil) and (tempModel.specialType == Enums.HeroType.eMainHero) then
        return false
    end

    -- 判断是否是始终需要的记录
    if table.indexof(filter.alwaysIdList or {}, heroItem.Id) then
        return true
    end
    -- 判断需要排除的模型Id
    if table.indexof(filter.excludeModelIds or {}, heroItem.ModelId) then
        return false
    end
    -- 判断需要排除的实体Id
    if table.indexof(filter.excludeIdList or {}, heroItem.Id) then
        return false
    end

    -- 选择可分解的人物
    if filter.isResolve then  
        if FormationObj:heroInFormation(heroItem.Id) then  -- 过滤掉已上阵的
            return false
        end
        if heroItem.RebornNum and heroItem.RebornId and 
            (heroItem.RebornNum > 0 or (heroItem.RebornId%1000) > 0) then -- 过滤掉已冲脉的
            return false
        end
        return true
    end
    -- 选择可重生的人物
    if filter.isRebirth then
        if FormationObj:heroInFormation(heroItem.Id) then  -- 过滤掉已上阵的
            return false
        end
        -- 过滤掉紫色以下的人物
        if Utility.getQualityColorLv(ConfigFunc:getItemBaseModel(heroItem.ModelId).quality) < 4 then
            return false
        end
        -- 过滤掉既没有升级有没有进阶且没有喝酒的人物
        if heroItem.Step == 0 and heroItem.Lv == 1 and not next(heroItem.FavorInfo) and not next(heroItem.HeroNeiliInfo) then
            return false
        end

        return true
    end

    -- 过滤其他规则的人物
    if filter.notInFormation and FormationObj:heroInFormation(heroItem.Id) then  -- 过滤掉已上阵的
        return false
    end
    if filter.maxLv and filter.maxLv < heroItem.Lv then -- 强化等级小于等于一定值
        return false
    end
    if filter.minLv and heroItem.Lv < filter.minLv then -- 强化等级大于等于一定值
        return false
    end
    if filter.maxStep and filter.maxStep < heroItem.Step then  -- 进阶等级小于等于一定值
        return false
    end
    if filter.minStep and heroItem.Step < filter.minStep then  -- 进阶等级大于等于一定值
        return false
    end

    if filter.minColorLv then  -- 需要的最低颜色等级
        local tempModel = HeroModel.items[heroItem.ModelId]
        local colorLv = Utility.getQualityColorLv(tempModel.quality)
        if colorLv < filter.minColorLv then
            return false
        end
    end

    if filter.maxColorLv then  -- 需要的最高颜色等级
        local tempModel = HeroModel.items[heroItem.ModelId]
        local colorLv = Utility.getQualityColorLv(tempModel.quality)
        if colorLv > filter.maxColorLv then
            return false
        end
    end

    return true
end 

--[[
]]
function CacheHero:ctor()
	-- 人物列表的原始数据
	self.mHeroList = {}
	-- 以人物实例Id为key的人物列表
	self.mIdList = {}
	-- 以人物模型Id为key的人物列表
	self.mModelList = {}
	-- 主角人物的实例Id
	self.mMainHeroId = nil

	-- 新得到人物Id列表对象
	self.mNewIdObj = require("data.NewIdList"):create()
end

-- 清空管理对象中的数据
function CacheHero:reset()
    self.mHeroList = {}
    self.mIdList = {}
    self.mModelList = {}
    self.mMainHeroId = nil
    self.mNewIdObj:clearNewId()
    Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagHero)
end

-- 刷新人物辅助缓存，主要用于数据获取时效率优化
function CacheHero:refreshAssistCache()
	self.mIdList = {}
	self.mModelList = {}
    for _, item in pairs(self.mHeroList) do
        self.mIdList[item.Id] = item

        self.mModelList[item.ModelId] = self.mModelList[item.ModelId] or {}
        table.insert(self.mModelList[item.ModelId], item)

        if not self.mMainHeroId then  -- 主角的实例Id不会变化
        	local tempModel = HeroModel.items[item.ModelId]
        	if tempModel and tempModel.specialType == Enums.HeroType.eMainHero then
        		self.mMainHeroId = item.Id
        	end
        end
    end
    --self.mHeroAssistCache = {modelList = modelList, IdList = IdList }
end

-- 设置人物列表
function CacheHero:setHeroList(heroList)
	self.mHeroList = heroList or {}
    self:refreshAssistCache()
end

-- 添加人物数据
--[[
-- 参数
    heroItem: 需要插入的数据
    onlyInsert: 是否只是插入数据，默认为false，如果设置为true，则需要在适当的地方调用 refreshAssistCache 接口
]]
function CacheHero:insertHero(heroItem, onlyInsert)
	if not heroItem or not Utility.isEntityId(heroItem.Id) then
		return
	end

	table.insert(self.mHeroList, heroItem)
    if not onlyInsert then
        self:refreshAssistCache()
    end

    -- 同时把实例Id存入新得到的Id列表中
    local tempModel = HeroModel.items[heroItem.ModelId]
    local colorLv = Utility.getQualityColorLv(tempModel and tempModel.quality)
    if colorLv > 2 then
    	self.mNewIdObj:insertNewId(heroItem.Id)
        Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagHero)
    end
end

-- 修改人物数据
function CacheHero:modifyHeroItem(heroItem)
	if not heroItem or not Utility.isEntityId(heroItem.Id) then
        return
    end

    for index, item in pairs(self.mHeroList) do
        if item.Id == heroItem.Id then
            self.mHeroList[index] = clone(heroItem)
            break
        end
    end
    self:refreshAssistCache()
end

-- 删除人物列表中的一批数据
function CacheHero:deleteHeroItems(needDelItemList)
	for _, item in pairs(needDelItemList) do
		self:deleteHeroById(item.Id, true)
	end
    self:refreshAssistCache()
end

-- 根据人物事例Id删除列表中对应的数据
--[[
-- 参数
	heroId: 人物实例Id
	onlyDelete: 是否只是删除人物缓存列表中的数据，默认为false, 外部调用者一般使用默认参数
]]
function CacheHero:deleteHeroById(heroId, onlyDelete)
	for index, item in pairs(self.mHeroList) do
		if heroId == item.Id then
			table.remove(self.mHeroList, index)
			break
		end
	end
	if not onlyDelete then
		self:refreshAssistCache()
	end
	self:clearNewId(heroId)
end

--- 返回人物列表数据
--[[
-- 参数：
    filter: 过滤条件 参考 “过滤条件说明”
-- 返回值单个人物的信息参考文件头部的 “人物数据说明”   
--]]
function CacheHero:getHeroList(filter)
    if not filter or not next(filter) then  -- 不需要过滤，直接就返回所有列表数据
        return self.mHeroList
    end

    local ret = {}
    for _, item in ipairs(self.mHeroList) do
        if checkOneItem(item, filter) then
            table.insert(ret, item)
        end
    end

    return ret
end

--- 判断是否拥有符合条件的人物
--[[
-- 参数：
    filter: 过滤条件 参考 “过滤条件说明”
-- 返回值
    true: 有符合条件的人物
    false: 没有找到
--]]
function CacheHero:haveHero(filter)
    if not filter or not next(filter) then  -- 不需要过滤，直接判断所有数据列表是否为空
        return next(self.mHeroList) ~= nil
    end

    local ret = {}
    for _, item in ipairs(self.mHeroList) do
        if checkOneItem(item, filter) then
            return true
        end
    end

    return false
end

--- 获取人物信息,
--[[
-- 获取人物信息,
-- 参数：
    heroId:人物实例id
-- 返回值参考文件头部的 “人物数据说明” 
--]]
function CacheHero:getHero(heroId)
    return self.mIdList[heroId]
end

-- 获取主角人物信息
function CacheHero:getMainHero()
    return self.mIdList[self.mMainHeroId]
end

--- 判断玩家是否拥有某种类型的人物
--[[
-- 参数
    modelId: 人物的模型Id
    filter: 过滤条件 参考 “过滤条件说明”
-- 返回值
    返回该人物模型Id的实例列表，单个人物的信息参考文件头部的 “人物数据说明” 
 ]]
function CacheHero:findHeroByModelId(modelId, filter)
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

--- 获取玩家拥有某种人物的数量
--[[
-- 参数：
    modelId: 人物模型Id
    filter: 过滤条件 参考 “过滤条件说明”
]]
function CacheHero:getCountByModelId(modelId, filter)
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

--- 修改主角的等级
function CacheHero:modifyMainHeroLv(newLv)
	if not self.mMainHeroId then
		return
	end

    local mainHero = self.mIdList[self.mMainHeroId]
    if mainHero then
        mainHero.Lv = newLv
    end
end

--- 修改主角的模型Id
function CacheHero:modifyMainHeroModelId(newModelId)
	if not self.mMainHeroId then
		return
	end

    local mainHero = self.mIdList[self.mMainHeroId]
    if mainHero then
        mainHero.ModelId = newModelId
    end
end

-- 获取人物的显示属性
function CacheHero:getHeroAttrInfo(heroId, heroModelId)
    if Utility.isEntityId(heroId) then
        local inFormation, isMate, slotId = FormationObj:heroInFormation(heroId)
        if inFormation and not isMate then
            return FormationObj:getSlotAttrInfo(slotId)
        else
            local mHeroInfo = self.mIdList[heroId]
            local modelId = mHeroInfo.ModelId
            local tempModel = HeroModel.items[modelId]
            local lvAttr = ConfigFunc:getHeroLvAttr(modelId, mHeroInfo.Lv, true)
            local stepAttr = ConfigFunc:getHeroStepAttr(modelId, mHeroInfo.Step, mHeroInfo.IllusionModelId) or {}

            local tempList = {
                AP = "APBase",
                DEF = "DEFBase",
                HP = "HPBase"
            }
            local ret = {}
            -- 二级属性
            for _, value in pairs({"AP", "DEF", "HP"}) do
                local tempItem = {}
                ret[value] = tempItem
                local tempValue = tempModel[tempList[value]] + (lvAttr[value] or 0) + (stepAttr[value] or 0)

                local attrType = ConfigFunc:getFightAttrEnumByName(value)
                tempItem.attrType = attrType
                tempItem.name = value
                tempItem.viewName = ConfigFunc:getViewNameByFightName(value)
                tempItem.value = tempValue
                tempItem.viewValue = Utility.getAttrViewStr(attrType, tempValue, false)
            end

            -- 等级、
            local tempItem = {}
            ret.Lv = tempItem
            tempItem.name = "Lv"
            tempItem.viewName = TR("等级")
            tempItem.value = mHeroInfo.Lv
            tempItem.viewValue = tostring(mHeroInfo.Lv)
            -- 先手
            local tempItem = {}
            local tempValue = tempModel.FSP + (stepAttr.FSP or 0)
            ret.FSP = tempItem
            tempItem.name = "FSP"
            tempItem.viewName = TR("先手值")
            tempItem.value = tempValue
            tempItem.viewValue = tostring(tempValue)

            -- 资质
            local tempItem = {}
            ret.quality = tempItem
            tempItem.name = "quality"
            tempItem.viewName = TR("资质")
            tempItem.value = tempModel.quality
            tempItem.viewValue = tostring(tempModel.quality)

            return ret
        end
    elseif heroModelId and heroModelId > 0 then
        -- 
        local tempModel = HeroModel.items[heroModelId]
        -- 二级基础属性
        local tempList = {
            AP = "APBase",
            DEF = "DEFBase",
            HP = "HPBase"
        }
        local ret = {}
        for key, value in pairs(tempList) do
            local tempItem = {}
            ret[key] = tempItem

            local attrType = ConfigFunc:getFightAttrEnumByName(key)
            tempItem.attrType = attrType
            tempItem.name = key
            tempItem.viewName = ConfigFunc:getViewNameByFightName(key)
            tempItem.value = tempModel[value]
            tempItem.viewValue = Utility.getAttrViewStr(attrType, tempModel[value], false)
        end

        -- 三级属性名称
        local tempList = {"HIT", "DOD", "CRI", "TEN", "BLO", "BOG", "CRID", "TEND"}
        for _, value in pairs(tempList) do
            local tempItem = {}
            ret[value] = tempItem

            local attrType = ConfigFunc:getFightAttrEnumByName(value)
            tempItem.attrType = attrType
            tempItem.name = value
            tempItem.viewName = ConfigFunc:getViewNameByFightName(value)
            tempItem.value = tempModel[value]
            tempItem.viewValue = Utility.getAttrViewStr(attrType, tempModel[value], false)
        end

        -- 等级、
        local tempItem = {}
        ret.Lv = tempItem
        tempItem.name = "Lv"
        tempItem.viewName = TR("等级")
        tempItem.value = 0
        tempItem.viewValue = "1"
        -- 先手
        local tempItem = {}
        ret.FSP = tempItem
        tempItem.name = "FSP"
        tempItem.viewName = TR("先手值")
        tempItem.value = tempModel.FSP
        tempItem.viewValue = tostring(tempModel.FSP)
        -- 资质
        local tempItem = {}
        ret.quality = tempItem
        tempItem.name = "quality"
        tempItem.viewName = TR("资质")
        tempItem.value = tempModel.quality
        tempItem.viewValue = tostring(tempModel.quality)

        return ret
    end
end

-- 获取人物的技能Id
--[[
-- 返回值
    第一个为普通攻击Id
    第二个为技能攻击Id
]]
function CacheHero:getHeroAttackId(heroModelId, heroInfo, fashionModelId, fashionStep)
    if (heroInfo ~= nil) then
        -- 处理时装
        local heroModel = HeroModel.items[heroInfo.ModelId]
        local fashionModelId = fashionModelId or 0
        if (heroModel.specialType == Enums.HeroType.eMainHero) and (fashionModelId > 0) then
            local fashionModel = FashionStepRelation.items[fashionModelId][fashionStep or 0]
            return fashionModel.NAID, fashionModel.RAID
        end
        -- 处理幻化
        local heroTalModel = HeroTalRelation.items[heroInfo.ModelId] and HeroTalRelation.items[heroInfo.ModelId][heroInfo.Step]
        if heroInfo.IllusionModelId and heroInfo.IllusionModelId > 0 then 
            heroModel = IllusionModel.items[heroInfo.IllusionModelId]
            heroTalModel = IllusionTalRelation.items[heroInfo.IllusionModelId] and IllusionTalRelation.items[heroInfo.IllusionModelId][heroInfo.Step]
        end 
        local heroTalId = heroTalModel and heroTalModel.TALModelID
        local talItem = heroTalId and TalModel.items[heroTalId]
        local NAID = talItem and (talItem.NAID > 0) and talItem.NAID or heroModel.NAID
        local RAID = talItem and (talItem.RAID > 0) and talItem.RAID or heroModel.RAID
        
        return NAID, RAID
    elseif (heroModelId ~= nil) then
       local tempModel = HeroModel.items[heroModelId] or {}
        return tempModel.NAID, tempModel.RAID 
    end
end

-- 获取新人物Id列表对象
--[[
-- 返回值
	返回值提供的接口查看 "data/NewidList.lua" 文件
]]
function CacheHero:getNewIdObj()
	return self.mNewIdObj
end

-- 
function CacheHero:clearNewId(instanceId)
    self.mNewIdObj:clearNewId(instanceId)
    Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagHero)
end

-- 获取新得到物品的模型Id列表
function CacheHero:getNewModelIdList()
    local tempList = {}
    for _, newId in pairs(self.mNewIdObj:getNewIdList()) do
        local tempHero = self.mIdList[newId]
        tempList[tempHero.ModelId] = true
    end

    return table.keys(tempList)
end

-- 读取某个突破次数的天赋ID
function CacheHero:getTalentIdByStep(heroId, nStep)
    local heroItem = self:getHero(heroId)
    if (heroItem == nil) or (heroItem.Talent == nil) then
        return nil
    end

    return heroItem.Talent[tostring(nStep)]
end

-- 修改某个突破次数的天赋ID
function CacheHero:modifyTalentIdByStep(heroId, nStep, newTalentId)
    if (not Utility.isEntityId(heroId)) or (not newTalentId) then
        return false
    end

    for index, item in pairs(self.mHeroList) do
        if item.Id == heroId then
            if (item.Talent == nil) then
                item.Talent = {}
            end
            item.Talent[tostring(nStep)] = newTalentId
            break
        end
    end
    self:refreshAssistCache()
end

return CacheHero
