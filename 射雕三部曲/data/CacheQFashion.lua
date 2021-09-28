--[[
文件名:CacheQFashion.lua
描述：Q版时装数据抽象类型
创建人：yanghongsheng
创建时间：2019.04.08
--]]

-- 绝学数据说明
--[[
    服务器返回的绝学数据，每条格式格式为：
    {
        Id:        实体ID
        ModelId:   模型ID
        IsDressIn: 是否穿戴
        Step:      进阶信息
    },
--]]

local CacheQFashion = class("CacheQFashion", {})

--[[
--]]
function CacheQFashion:ctor()
    self.myFashionList = {}
end

-- 清空管理对象中的数据
function CacheQFashion:reset()
   self.myFashionList = {}
end

-- 获取玩家拥有的时装列表
function CacheQFashion:getFashionList(callFunc)
	if callFunc then
	    callFunc(clone(self.myFashionList))
	end
    return self.myFashionList
end

-- 刷新玩家拥有的时装列表（学习之后主动调用）
function CacheQFashion:refreshFashionList(callFunc)
    self.myFashionList = {}
    self:getFashionList(callFunc)
end

-- 返回某个特定种类的时装
function CacheQFashion:getGuidByModelId(modelId)
    if (modelId == nil) then
        return nil
    end

    -- 0表示不穿戴任何时装的主角
    if (modelId == 0) then
        return EMPTY_ENTITY_ID
    end

    -- 找到任意一个即可
    local retGuid = nil
    for _,v in pairs(self.myFashionList) do
        if (v.ModelId == modelId) then
            retGuid = v.Id
            break
        end
    end

    return retGuid
end

-- 返回特定种类的全部可用时装ID（保留进阶最高或已上阵）
function CacheQFashion:getFashionGuidList(modelId)
    if (modelId == nil) then
        return nil
    end

    -- 0表示不穿戴任何时装的主角
    if (modelId == 0) then
        return {EMPTY_ENTITY_ID}
    end

    -- 查找该时装需保留的时装
    local fashionInfo = self:getStepFashionInfo(modelId)
    -- 返回全部的未上阵时装
    local retList = {}
    for _,v in pairs(self.myFashionList) do
        if (v.ModelId == modelId) and (fashionInfo.Id ~= v.Id) then
            table.insert(retList, v.Id)
        end
    end

    return retList
end

-- 判断某种时装是否已拥有
function CacheQFashion:getOneItemOwned(modelId)
    if (modelId == nil) then
        return false
    end

    -- 0表示不穿戴任何时装的主角
    if (modelId == 0) then
        -- 永远已存在
        return true
    end

    -- 只要拥有任意一个即可
    local retOwned = false
    for _,v in pairs(self.myFashionList) do
        if (v.ModelId == modelId) then
            retOwned = true
            break
        end
    end

    return retOwned
end

-- 判断某种时装是否已穿戴
--[[
参数：
	modelId 	模型id
	dressType 	上阵类型（1：桃花岛，2：绝情谷 3：其他 默认3）
]]
function CacheQFashion:getOneItemDressIn(modelId, dressType)
    if (modelId == nil) then
        return false
    end

    dressType = dressType or 3

    -- 0表示不穿戴任何时装的主角
    if (modelId == 0) then
        -- 如果所有时装都未穿戴，则视为穿戴了主角
        local isMainHeroDress = true
        for _,v in pairs(self.myFashionList) do
            if self.isDressIn(v.CombatType, dressType) then
                isMainHeroDress = false
                break
            end
        end
        return isMainHeroDress
    end

    -- 只要有任意一个上阵即可
    local retDressIn = false
    for _,v in pairs(self.myFashionList) do
        if (v.ModelId == modelId) and self.isDressIn(v.CombatType, dressType) then
            retDressIn = true
            break
        end
    end

    return retDressIn
end

-- 是否上阵某一个类型
--[[
参数：
	combatStr 	该时装上阵的类型字符串
	dressType 	上阵类型（1：桃花岛，2：绝情谷 3：其他 默认3）
]]
function CacheQFashion.isDressIn(combatStr, dressType)
	local combatList = string.splitBySep(combatStr or "", ",")
	return table.indexof(combatList, tostring(dressType)) and true or false
end

-- 设置某种时装已穿戴
--[[
参数：
	modelId 	模型id
	dressType 	上阵类型（1：桃花岛，2：绝情谷 3：其他 默认3）
]]
function CacheQFashion:setOneItemDressIn(fashionId, dressType)
    if (fashionId == nil) then
        return false
    end

    dressType = dressType or 3

    -- 标记上阵时装并把其他的穿戴标记清空
    for _,v in pairs(self.myFashionList) do
        if v.Id == fashionId then
            v.CombatType = v.CombatType..","..dressType
        elseif self.isDressIn(v.CombatType, dressType) then
            local combatList = string.splitBySep(v.CombatType or "", ",")
            local index = table.indexof(combatList, tostring(dressType))
            table.remove(combatList, index)

            local tempStr = ""
            for _, combatType in pairs(combatList) do
            	tempStr = tempStr .. combatType
            end
            v.CombatType = tempStr
        end
    end
end

-- 判断某种时装的进阶
function CacheQFashion:getOneItemStep(modelId)
    if (modelId == nil) then
        return 0
    end

    -- 0表示不穿戴任何时装的主角
    if (modelId == 0) then
        -- 不能进阶
        return 0
    end

    -- 找出最大的进阶
    local retStep = 0
    for _,v in pairs(self.myFashionList) do
        if (v.ModelId == modelId) and (v.Step > retStep) then
            retStep = v.Step
        end
    end

    return retStep
end

-- 设置某种时装的进阶
--[[
    参数:guid            时装实体id
        newStep         当前进阶
]] 
function CacheQFashion:setOneItemStep(guid, newStep)
    if (guid == nil) then
        return
    end

    -- 先把所有的穿戴标记清空
    for _,v in pairs(self.myFashionList) do
        if (v.Id == guid) then
            v.Step = newStep
            break
        end
    end
end

-- 修改某个时装缓存
function CacheQFashion:modifyFashionItem(fashionItem)
	if not fashionItem or not Utility.isEntityId(fashionItem.Id) then
        return
    end

    for index, item in pairs(self.myFashionList) do
        if item.Id == fashionItem.Id then
            self.myFashionList[index] = clone(fashionItem)
            break
        end
    end
end

-- 获取某个时装的拥有数量
--[[
参数:
	modelId 			模型id
    ignoreDressInType : 忽略已上阵的类型，默认为““（”“不忽略，”1,2,3"忽略桃花岛，绝情谷，其他类型上阵）
--]]
function CacheQFashion:getFashionCount(modelId, ignoreDressInType)
    if (modelId == nil) then
        return 0
    end

    -- 默认的无时装形象，永远存在，且数量为1
    if (modelId == 0) then
        return 1
    end

    ignoreDressInType = ignoreDressInType or ""

    -- 遍历某个时装的数量
    local retNum = 0
    for _,v in pairs(self.myFashionList) do
        if (v.ModelId == modelId) then
            if (ignoreDressInType ~= "") then
            	local isDressIn = false
            	local ignoreTypeList = string.splitBySep(ignoreDressInType, ",")
            	for _, ignoreType in pairs(ignoreTypeList) do
            		if self.isDressIn(v.CombatType, ignoreType) then
            			isDressIn = true
            			break
            		end
            		if not isDressIn then
            			retNum = retNum + 1
            		end
            	end
            else
                retNum = retNum + 1
            end
        end
    end

    return retNum
end

-- 获取某类时装有进阶最高的实体信息(如果该类时装已上阵则返回上阵时装)
function CacheQFashion:getStepFashionInfo(modelId)
    if (modelId == nil) then
        return nil
    end

    -- 默认的无时装形象时阶数0
    if (modelId == 0) then
        return nil
    end

    -- 查找该时装
    local fashionInfo = nil
    local tempStep = 0

    for _,v in pairs(self.myFashionList) do
        if (v.ModelId == modelId) and (v.CombatType ~= "") then
            fashionInfo = clone(v)
            break
        elseif (v.ModelId == modelId) and tempStep < v.Step then
            fashionInfo = clone(v)
            tempStep = v.Step
        elseif (v.ModelId == modelId) and (tempStep == v.Step) and (fashionInfo and fashionInfo.Exp or 0) <= v.Exp then
        	fashionInfo = clone(v)
            tempStep = v.Step
        end
    end

    return fashionInfo
end

-- 获取能分解的时装列表
function CacheQFashion:getRefineFashionList()
    -- 时装分解列表
    local fashionRefineList = {}
    -- 时装计数列表
    local fashionCountList = {}
    -- 拷贝时装列表
    local tempFashionList = {}
    for _,v in pairs(self.myFashionList) do
        table.insert(tempFashionList, v)
    end
    -- 为了方便筛选进行排序
    table.sort(tempFashionList, function (fashion1, fashion2)
    	local isDressIn1 = not (fashion1.CombatType == "")
    	local isDressIn2 = not (fashion2.CombatType == "")
        -- 已上阵的在前面
        if isDressIn1 ~= isDressIn2 then
            return isDressIn1
        end
        -- 进阶等级高的在前面
        if fashion1.Step ~= fashion2.Step then
            return fashion1.Step > fashion2.Step
        end
        -- 经验
        if fashion1.Exp ~= fashion2.Exp then
        	return fashion1.Exp > fashion2.Exp
        end

        return fashion1.ModelId < fashion2.ModelId
    end)

    for _,v in pairs(tempFashionList) do
        -- 计数(经过排序在前面有进阶等级或已上阵的时装会优先最为保底的最后一件)
        fashionCountList[v.ModelId] = fashionCountList[v.ModelId] or 0
        fashionCountList[v.ModelId] = fashionCountList[v.ModelId] + 1
        -- 没有进阶等级且没有被穿戴且不是保底的最后一件
        if v.Step <= 0 and v.Exp <= 0 and v.CombatType == "" and fashionCountList[v.ModelId] > 1 then
            table.insert(fashionRefineList, clone(v))
        end
    end


    return fashionRefineList
end

-- 删除某个指定的时装
function CacheQFashion:delOneItem(guid)
    if (guid == nil) then
        return
    end

    for i,v in ipairs(self.myFashionList) do
        if (v.Id == guid) then
            table.remove(self.myFashionList, i)
            break
        end
    end
end

-- 更新时装列表
function CacheQFashion:updateFashionList(fashionList)
    if (fashionList == nil) then
        return
    end

    self.myFashionList = fashionList
end

-- 添加时装数据
--[[
-- 参数
    ShizhuangItem: 需要插入的数据
]]
function CacheQFashion:insertShizhuang(ShizhuangItem)
	if not ShizhuangItem or not Utility.isEntityId(ShizhuangItem.Id) then
		return
	end

	table.insert(self.myFashionList, ShizhuangItem)
end

-- 获取Q版时装显示模型
--[[
	modelId 	模型id
]]
function CacheQFashion:getQFashionLargePic(modelId)
	local zhengmianLargePic, beimianLargePic = nil, nil
	-- 主角
	if (HeroModel.items[modelId] and HeroModel.items[modelId].specialType == 255) then
		zhengmianLargePic, beimianLargePic = HeroQimageRelation.items[modelId].positivePic, HeroQimageRelation.items[modelId].backPic
	elseif ShizhuangModel.items[modelId] then
		zhengmianLargePic, beimianLargePic = ShizhuangModel.items[modelId].positivePic, ShizhuangModel.items[modelId].backPic
	end

	return zhengmianLargePic, beimianLargePic
end

-- 根据类型获取Q版时装显示模型id
--[[
	dressType 	上阵类型（1：桃花岛，2：绝情谷 3：其他 默认3）
]]
function CacheQFashion:getQFashionModelIdByDressType(dressType)
	dressType = dressType or 3
	local modelId = 0
	for _, v in pairs(self.myFashionList) do
		if self.isDressIn(v.CombatType, dressType) then
			modelId = v.ModelId
			break
		end
	end
	-- 主角模型
	if modelId == 0 then
		modelId = FormationObj:getSlotInfoBySlotId(1).ModelId
	end

	return modelId
end

-- 根据类型获取Q版时装显示模型
--[[
	dressType 	上阵类型（1：桃花岛，2：绝情谷 3：其他 默认3）
]]
function CacheQFashion:getQFashionByDressType(dressType)
	local modelId = self:getQFashionModelIdByDressType(dressType)

	return self:getQFashionLargePic(modelId)
end

-- 获取已有时装模型id
function CacheQFashion:getQFashionModelList()
	local tempModelIdList = {}

	for _, v in pairs(self.myFashionList) do
		tempModelIdList[v.ModelId] = true
	end

	return table.keys(tempModelIdList) or {}
end

return CacheQFashion