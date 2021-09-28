--[[
文件名:CacheZhenshou.lua
描述：珍兽数据抽象类型
创建人：lengjiazhi
创建时间：2018.11.26
--]]

local CacheZhenshou = class("CacheZhenyuan", {})


--[[
 	珍兽数据说明
--[[
-- 服务器返回的珍兽数据中，每个条目包含的字段如下
	{
        "Step" = 0, --进阶数
        "Lv" = 0, --珍兽等级
        "ModelId" = 21010001, --模型id
        "Id" = "af945377-d0f7-44f5-a3fb-ab6216388390", --实例id
        "IsCombat" = false,	--是否上阵
    },
--]]

-- 过滤条件说明
--[[
-- 珍兽过滤条件项如下
    { 

        notInFormation = false, -- 是否需要过滤掉上阵的，默认为false
        isResolve = true,   -- 选择可分解的
        isRebirth = true,   -- 选择可重生的，升级或进阶过
    }
]]

-- 检查一个条目是否满足条件
--[[
-- 参数
    zhenshouItem: 珍兽信息，参考 “珍兽数据说明”
    filter: 过滤条件 参考 “过滤条件说明”
]]
local function checkOneItem(zhenshouItem, filter)
    
    -- 选择可分解的珍兽
    if filter.isResolve then  
        if ZhenshouSlotObj:isCombat(zhenshouItem.Id) then  -- 过滤掉已上阵的
            return false
        end
        if zhenshouItem.Step ~= 0 or zhenshouItem.Lv ~= 0 then
        	return false
        end
        return true
    end
    -- 选择可重生的珍兽
    if filter.isRebirth then
        if ZhenshouSlotObj:isCombat(zhenshouItem.Id) then  -- 过滤掉已上阵的
            return false
        end
        -- -- 过滤掉紫色以下的珍兽
        -- if Utility.getQualityColorLv(ConfigFunc:getItemBaseModel(zhenshouItem.ModelId).quality) < 4 then
        --     return false
        -- end
        -- 过滤掉既没有进阶的珍兽
        if zhenshouItem.Step == 0 and zhenshouItem.Lv == 0 then
            return false
        end

        return true
    end

    -- 过滤其他规则的珍兽
    if filter.notInFormation and ZhenshouSlotObj:isCombat(zhenshouItem.Id) then  -- 过滤掉已上阵的
        return false
    end

    return true
end 


function CacheZhenshou:ctor()
	--珍兽列表的原始数据
	self.mZhenshouList = {}
	-- 以珍兽实例Id为key的珍兽列表
	self.mIdList = {}
	-- 以珍兽模型Id为key的珍兽列表
	self.mModelList = {}

	-- 新得到珍兽Id列表对象
	self.mNewIdObj = require("data.NewIdList"):create()
end

-- 清空管理对象中的数据
function CacheZhenshou:reset()
    self.mZhenshouList = {}
    self.mIdList = {}
    self.mModelList = {}

    self.mNewIdObj:clearNewId()
    -- Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagHero)
end

-- 刷新珍兽辅助缓存，主要用于数据获取时效率优化
function CacheZhenshou:refreshAssistCache()
	self.mIdList = {}
	self.mModelList = {}
    for _, item in pairs(self.mZhenshouList) do
        self.mIdList[item.Id] = item

        self.mModelList[item.ModelId] = self.mModelList[item.ModelId] or {}
        table.insert(self.mModelList[item.ModelId], item)
    end
end

-- 设置珍兽列表
function CacheZhenshou:setZhenshouList(zhenshouList)
	self.mZhenshouList = zhenshouList or {}
    self:refreshAssistCache()
end

-- 添加珍兽数据
--[[
-- 参数
    ZhenshouItem: 需要插入的数据
    onlyInsert: 是否只是插入数据，默认为false，如果设置为true，则需要在适当的地方调用 refreshAssistCache 接口
]]
function CacheZhenshou:insertZhenshou(ZhenshouItem, onlyInsert)
	if not ZhenshouItem or not Utility.isEntityId(ZhenshouItem.Id) then
		return
	end

	table.insert(self.mZhenshouList, ZhenshouItem)
    if not onlyInsert then
        self:refreshAssistCache()
    end

    -- 同时把实例Id存入新得到的Id列表中
    -- local tempModel = ZhenshouModel.items[ZhenshouItem.ModelId]
    -- local colorLv = Utility.getQualityColorLv(tempModel and tempModel.quality)
    -- if colorLv > 2 then
    -- 	self.mNewIdObj:insertNewId(ZhenshouItem.Id)
    --     Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagHero)
    -- end
end

-- 修改珍兽数据
function CacheZhenshou:modifyZhenshouItem(ZhenshouItem)
	if not ZhenshouItem or not Utility.isEntityId(ZhenshouItem.Id) then
        return
    end

    for index, item in pairs(self.mZhenshouList) do
        if item.Id == ZhenshouItem.Id then
            self.mZhenshouList[index] = clone(ZhenshouItem)
            break
        end
    end
    self:refreshAssistCache()
end

-- 删除珍兽列表中的一批数据
function CacheZhenshou:deleteZhenshouItems(needDelItemList)
	for _, item in pairs(needDelItemList) do
		self:deleteZhenshouById(item.Id, true)
	end
    self:refreshAssistCache()
end

-- 根据珍兽事例Id删除列表中对应的数据
--[[
-- 参数
	zhenshouId: 珍兽实例Id
	onlyDelete: 是否只是删除珍兽缓存列表中的数据，默认为false, 外部调用者一般使用默认参数
]]
function CacheZhenshou:deleteZhenshouById(zhenshouId, onlyDelete)
	for index, item in pairs(self.mZhenshouList) do
		if zhenshouId == item.Id then
			table.remove(self.mZhenshouList, index)
			break
		end
	end
	if not onlyDelete then
		self:refreshAssistCache()
	end
	self:clearNewId(zhenshouId)
end

--- 返回珍兽列表数据
--[[
-- 参数：
    filter: 过滤条件 参考 “过滤条件说明”
-- 返回值单个珍兽的信息参考文件头部的 “珍兽数据说明”   
--]]
function CacheZhenshou:getZhenshouList(filter)
    if not filter or not next(filter) then  -- 不需要过滤，直接就返回所有列表数据
        return self.mZhenshouList
    end

    local ret = {}
    for _, item in ipairs(self.mZhenshouList) do
        if checkOneItem(item, filter) then
            table.insert(ret, item)
        end
    end

    return ret
end

--- 获取珍兽信息,
--[[
-- 获取珍兽信息,
-- 参数：
    zhenshouId:珍兽实例id
-- 返回值参考文件头部的 “珍兽数据说明” 
--]]
function CacheZhenshou:getZhenshou(zhenshouId)
    return self.mIdList[zhenshouId]
end

--- 判断玩家是否拥有某种类型的珍兽
--[[
-- 参数
    modelId: 珍兽的模型Id
    filter: 过滤条件 参考 “过滤条件说明”
-- 返回值
    返回该珍兽模型Id的实例列表，单个珍兽的信息参考文件头部的 “珍兽数据说明” 
 ]]
function CacheZhenshou:findZhenshouByModelId(modelId, filter)
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

--- 获取玩家拥有某种珍兽的数量
--[[
-- 参数：
    modelId: 珍兽模型Id
    filter: 过滤条件 参考 “过滤条件说明”
]]
function CacheZhenshou:getCountByModelId(modelId, filter)
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

-- 获取新珍兽Id列表对象
--[[
-- 返回值
	返回值提供的接口查看 "data/NewidList.lua" 文件
]]
function CacheZhenshou:getNewIdObj()
	return self.mNewIdObj
end

function CacheZhenshou:clearNewId(instanceId)
    self.mNewIdObj:clearNewId(instanceId)
    -- Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagHero)
end

-- 获取新得到物品的模型Id列表
function CacheZhenshou:getNewModelIdList()
    local tempList = {}
    for _, newId in pairs(self.mNewIdObj:getNewIdList()) do
        local tempZhenshou = self.mIdList[newId]
        tempList[tempZhenshou.ModelId] = true
    end

    return table.keys(tempList)
end

-- 获取珍兽属性（进阶属性除外）
--[[
    zhenshouId: 珍兽实例Id
    zhenshouModelId: 珍兽模型Id, 如果 zhenshouId 为有效值，该参数失效
]]
function CacheZhenshou:getZhenshouAttrList(zhenshouId, zhenshouModelId)
    local attrList = {}

    if (not zhenshouId) and (not zhenshouModelId) then return attrList end

    if zhenshouId and Utility.isEntityId(zhenshouId) then
        local zhenshouInfo = self:getZhenshou(zhenshouId)
        zhenshouModelId = zhenshouInfo.ModelId

        local function getFormAddAttr(dataTabel, curLv)
            local lvList = table.keys(dataTabel)
            table.sort(lvList, function (lv1, lv2)
                return lv1 < lv2
            end)
            for _, lv in ipairs(lvList) do
                if lv > curLv then break end
                local attrData = Utility.analysisStrAttrList(dataTabel[lv].addAttrStr)
                for _, attrInfo in pairs(attrData) do
                    attrList[attrInfo.fightattr] = attrList[attrInfo.fightattr] or 0
                    attrList[attrInfo.fightattr] = attrList[attrInfo.fightattr] + attrInfo.value
                end
            end
        end
        -- 等级属性
        getFormAddAttr(ZhenshouLvupModel.items[zhenshouModelId], zhenshouInfo.Lv)
        -- 进阶属性
        -- getFormAddAttr(ZhenshouStepupModel.items[zhenshouModelId], zhenshouInfo.Step)
    end
    -- 基础属性
    local attrData = Utility.analysisStrAttrList(ZhenshouModel.items[zhenshouModelId].baseAttrStr)
    for _, attrInfo in pairs(attrData) do
        attrList[attrInfo.fightattr] = attrList[attrInfo.fightattr] or 0
        attrList[attrInfo.fightattr] = attrList[attrInfo.fightattr] + attrInfo.value
    end

    -- 序列化
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

-- 获取该珍兽培养消耗的资源
--[[
    zhenshouId: 珍兽实例Id
]]
function CacheZhenshou:getZhenshouUseResList(zhenshouId)
    local zhenshouInfo = self:getZhenshou(zhenshouId)
    local useResList = {}
    if not zhenshouInfo then return useResList end

    -- 等级消耗资源
    if zhenshouInfo.Lv > 0 then
        for lv = zhenshouInfo.Lv-1, 0, -1 do
            local useResStr = ZhenshouLvupModel.items[zhenshouInfo.ModelId][lv].lvupNeedStr
            local resList = Utility.analysisStrResList(useResStr)
            for _, resInfo in pairs(resList) do
                local resKey = resInfo.resourceTypeSub..resInfo.modelId
                if useResList[resKey] then
                    useResList[resKey].num = useResList[resKey].num + resInfo.num
                else
                    useResList[resKey] = resInfo
                end
            end
        end
    end
    -- 进阶消耗资源
    if zhenshouInfo.Step > 0 then
        for step = zhenshouInfo.Step-1, 0, -1 do
            local useResStr = ZhenshouStepupModel.items[zhenshouInfo.ModelId][step].stepUpNeedStr
            local resList = Utility.analysisStrResList(useResStr)
            for _, resInfo in pairs(resList) do
                local resKey = resInfo.resourceTypeSub..resInfo.modelId
                if useResList[resKey] then
                    useResList[resKey].num = useResList[resKey].num + resInfo.num
                else
                    useResList[resKey] = resInfo
                end
            end
        end
    end

    return table.values(useResList)
end

-- 获取珍兽技能描述
--[[
参数
    zhenshouId: 珍兽实例Id
    zhenshouModelId: 珍兽模型Id, 如果 zhenshouId 为有效值，该参数失效
返回
    ordinaryIntro       普攻描述
    specialIntro        技攻描述
]]
function CacheZhenshou:getZhenshouSkillIntro(zhenshouId, zhenshouModelId)
    local ordinaryIntro, specialIntro = "", ""

    if (not zhenshouId) and (not zhenshouModelId) then return ordinaryIntro, specialIntro end

    local zhenshouInfo = zhenshouId and Utility.isEntityId(zhenshouId) and self:getZhenshou(zhenshouId)
    if zhenshouInfo then
        zhenshouModelId = zhenshouInfo.ModelId
    end

    local zsLvModel = ZhenshouLvupModel.items[zhenshouModelId][zhenshouInfo and zhenshouInfo.Lv or 0]
    local zsStepModel = ZhenshouStepupModel.items[zhenshouModelId][zhenshouInfo and zhenshouInfo.Step or 0]

    -- 普攻
    local atkStr = (zsStepModel.baseAtkFactor/10).."%"
    atkStr = atkStr .. "+" .. math.ceil(zsLvModel.baseDamageAdd*zsStepModel.baseAtkAddR/10000)
    ordinaryIntro = string.format(zsStepModel.baseAtkIntro, atkStr)
    -- buff特效
    if zsStepModel.baseAtkEffectBuffID ~= "" then
        ordinaryIntro = ordinaryIntro .. "，" .. zsStepModel.baseAtkEffectIntro
    end
    -- 触发概率
    ordinaryIntro = ordinaryIntro .. TR("（每回合开始有%s%%概率释放）", zsStepModel.baseOddsR/100)

    -- 技攻
    local atkStr = (zsStepModel.skillAtkFactor/10).."%"
    atkStr = atkStr .. "+" .. math.ceil(zsLvModel.baseDamageAdd*zsStepModel.skillAtkAddR/10000)
    specialIntro = string.format(zsStepModel.skillAtkIntro, atkStr)
    if zsStepModel.skillAtkEffectBuffID ~= "" then
        specialIntro = specialIntro .. "，" .. zsStepModel.skillAtkEffectIntro
    end
    -- 触发概率
    specialIntro = specialIntro .. TR("（每回合开始有%s%%概率释放）", zsStepModel.skillOddsR/100)

    return ordinaryIntro, specialIntro
end

return CacheZhenshou