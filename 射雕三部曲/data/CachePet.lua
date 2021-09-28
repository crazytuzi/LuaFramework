--[[
文件名:CachePet.lua
描述：外功秘籍数据抽象类型
创建人：liaoyuangang
创建时间：2016.05.09
--]]

-- 外功秘籍数据说明
--[[
-- 服务器返回的外功秘籍数据中，每个条目包含的字段如下
	{
        "Id" = "56c94a49-ad3e-47b4-93c8-9b576f775331",
        "ModelId" = 23010505,
        "BuffId" = "",
        "Lv" = 1,
        "Layer" = 0,
        "TotalNum" = 0,
        "CanUseTalNum" = 0,
        "TalentInfoList" = {
            TalentID : 天赋ID
            TalentName ：天赋名
            TalentNum : 已点天赋点数
        },
    },
]]

-- 过滤条件说明
--[[
    {
        alwaysIdList = {}, -- 始终包含的条目Id列表
        excludeIdList = {}, -- 需要排除掉实体Id
        notInFormation = false, -- 是否需要过滤掉上阵的外功秘籍，默认为false
        maxColorLv = nil, -- 最大颜色等级
        minColorLv = nil, -- 最小颜色等级

        Lv = nil, 需要的外功秘籍等级
        maxLv = nil, 最大等级
        minLv = nil, 最小等级

        isCompare = true,   -- 选择可合成的外功秘籍
        isRebirth = true,   -- 选择可重生的外功秘籍
        isResolve = true,   -- 选择可分解的外功秘籍
    }
]]

local CachePet = class("CachePet", {})

-- 检查一个条目是否满足条件
--[[
-- 参数
    petItem: 外功秘籍信息，参考 “外功秘籍数据说明”
    filter: 过滤条件 参考 “过滤条件说明”
]]
local function checkOneItem(petItem, filter)
    -- 判断是否是始终需要的记录
    if table.indexof(filter.alwaysIdList or {}, petItem.Id) then
        return true
    end

    -- 判断需要排除的实体Id
    if table.indexof(filter.excludeIdList or {}, petItem.Id) then
        return false
    end

    -- 选择可重生的外功秘籍
    if filter.isRebirth then
        if FormationObj:petInFormation(petItem.Id) then
            return false
        end

        -- 排除掉等级为1的
        if petItem.Lv == 1 then
            return false
        end
        -- Todo
    end

    local tempModel = PetModel.items[petItem.ModelId]
    if filter.isCompare then
        if FormationObj:petInFormation(petItem.Id) then
            return false
        end

        -- 排除掉已升级的
        if petItem.Lv > 1 then
            return false
        end

        -- 最高只能合出橙色
        if tempModel.valueLv >= 5 then
            return false
        end
    end

    -- 选择可分解的外功秘籍
    if filter.isResolve then
        if FormationObj:petInFormation(petItem.Id) then
            return false
        end
        -- if petItem.Lv > 1 then
        --     return false
        -- end
        --如果参悟过的，只能去重生
        if (petItem.TotalNum or 0) - (petItem.CanUseTalNum or 0) > 0 then
            return false
        end
    end

    if filter.notInFormation and FormationObj:petInFormation(petItem.Id) then  -- 过滤掉已上阵的外功秘籍
        return false
    end

    if filter.Lv and filter.Lv ~= petItem.Lv then
        return false
    end
    if filter.maxLv and filter.maxLv < petItem.Lv then
        return false
    end
    if filter.minLv and filter.minLv > petItem.Lv then
        return false
    end

    if filter.maxColorLv or filter.minColorLv then  -- 需要的指定外功秘籍类型
        local tmpColorLv = Utility.getQualityColorLv(tempModel.quality)
        if filter.minColorLv and tmpColorLv < filter.minColorLv then
            return false
        end
        if filter.maxColorLv and tmpColorLv > filter.maxColorLv then
            return false
        end
    end

    return true
end

--[[
]]
function CachePet:ctor()
    -- 外功秘籍列表的原始数据
	self.mPetList = {}
    -- 以实例Id为key的外功秘籍列表
    self.mIdList = {}
    -- 以模型Id为key的外功秘籍列表
    self.mModelList = {}
    -- 以外功秘籍颜色为key的外功秘籍列表
    self.mColorLvList = {}

    -- 新得到外功秘籍Id列表对象
    self.mNewIdObj = require("data.NewIdList"):create()
end

-- 清空管理对象中的数据
function CachePet:reset()
    self.mPetList = {}
    self.mIdList = {}
    self.mModelList = {}
    self.mColorLvList = {}
    self.mNewIdObj:clearNewId()
end

-- 刷新外功秘籍辅助缓存，主要用于数据获取时效率优化
function CachePet:refreshAssistCache()
    self.mIdList = {}
    self.mModelList = {}
    self.mColorLvList = {}
    for _, item in pairs(self.mPetList) do
        self.mIdList[item.Id] = item
        self.mModelList[item.ModelId] = self.mModelList[item.ModelId] or {}
        table.insert(self.mModelList[item.ModelId], item)

        -- 以外功秘籍颜色分类
        local tempModel = PetModel.items[item.ModelId]
        self.mColorLvList[tempModel.valueLv] = self.mColorLvList[tempModel.valueLv] or {}
        table.insert(self.mColorLvList[tempModel.valueLv], item)
    end
end

-- 设置外功秘籍列表
function CachePet:setPetList(petList)
    self.mPetList = petList
    self:refreshAssistCache()
end

-- 添加外功秘籍数据
--[[
-- 参数
    petItem: 需要插入的数据
    onlyInsert: 是否只是插入数据，默认为false，如果设置为true，则需要在适当的地方调用 refreshAssistCache 接口
]]
function CachePet:insertPet(petItem, onlyInsert)
    if not petItem or not Utility.isEntityId(petItem.Id) then
        return
    end
    table.insert(self.mPetList, petItem)
    if not onlyInsert then
        self:refreshAssistCache()
    end
end

-- 修改外功秘籍数据
function CachePet:modifyPetItem(petItem)
    if not petItem or not Utility.isEntityId(petItem.Id) then
        return
    end

    for index, item in pairs(self.mPetList) do
        if item.Id == petItem.Id then
            self.mPetList[index] = clone(petItem)
            break
        end
    end
    self:refreshAssistCache()
end

-- 删除外功秘籍列表中的一批数据
function CachePet:deletePetItems(needDelItemList)
    for _, item in pairs(needDelItemList) do
        self:deletePetById(item.Id, true)
    end
    self:refreshAssistCache()
end

-- 根据外功秘籍事例Id删除列表中对应的数据
--[[
-- 参数
    petId: 外功秘籍实例Id
    onlyDelete: 是否只是删除外功秘籍缓存列表中的数据，默认为false, 外部调用者一般使用默认参数
]]
function CachePet:deletePetById(petId, onlyDelete)
    for index, item in pairs(self.mPetList) do
        if petId == item.Id then
            table.remove(self.mPetList, index)
            break
        end
    end
    if not onlyDelete then
        self:refreshAssistCache()
    end
    self.mNewIdObj:clearNewId(petId)
end

--- 返回外功秘籍列表数据
--[[
-- 参数：
    filter: 过滤条件 参考 “过滤条件说明”
-- 返回值单个外功秘籍的信息参考文件头部的 “外功秘籍数据说明”
--]]
function CachePet:getPetList(filter)
    -- dump(self.mPetList, "{}{}{}{}{}")
    if not filter or not next(filter) then  -- 不需要过滤，直接就返回所有列表数据
        return self.mPetList
    end

    local ret = {}
    for _, item in ipairs(self.mPetList) do
        if checkOneItem(item, filter) then
            table.insert(ret, item)
        end
    end

    return ret
end

--- 获取外功秘籍信息,
--[[
-- 获取外功秘籍信息,
-- 参数：
    petId:外功秘籍实例id
-- 返回值参考文件头部的 “外功秘籍数据说明”
--]]
function CachePet:getPet(petId)
    return self.mIdList[petId]
end

--- 根据外功秘籍模型Id获取外功秘籍列表
--[[
-- 参数
    modelId: 外功秘籍的模型Id
    filter: 过滤条件 参考 “过滤条件说明”
-- 返回值
    返回该外功秘籍模型Id的实例列表，单个外功秘籍的信息参考文件头部的 “外功秘籍数据说明”
 ]]
function CachePet:findByModelId(modelId, filter)
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

--- 获取玩家拥有某种外功秘籍的数量
--[[
-- 参数：
    modelId: 外功秘籍模型Id
    filter: 过滤条件 参考 “过滤条件说明”
]]
function CachePet:getCountByModelId(modelId, filter)
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

-- 获取外功秘籍上阵卡槽的人物信息
--[[
-- 参数
    petId: 外功秘籍实例Id
-- 返回值
    第一个返回值：如果该外功秘籍已上阵，则返回该外功秘籍所在的阵容卡槽Id, 否则为nil
    第二个返回值：如果该外功秘籍已上阵，则返回该外功秘籍所在阵容卡槽人物的信息， 否则为nil
]]
function CachePet:getPetSlotInfo(petId)
    local inFormation, slotId = FormationObj:petInFormation(petId)
    if not inFormation then
        return
    end
    local slotInfo = FormationObj:getSlotInfoBySlotId(slotId)
    local heroInfo = HeroObj:getHero(slotInfo.HeroId)

    return slotId, heroInfo
end

-- 获取新得到外功秘籍Id列表对象
--[[
-- 返回值
    返回值提供的接口查看 "data/NewidList.lua" 文件
]]
function CachePet:getNewIdObj()
    return self.mNewIdObj
end

--- 获取以模型Id为key的外功列表
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
function CachePet:getPetListAsModelId()
    return self.mModelList
end

return CachePet
