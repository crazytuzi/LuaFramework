--[[
文件名:CacheGoods.lua
描述：物品数据抽象类型(道具、人物碎片、内功碎片、外功碎片...)
创建人：liaoyuangang
创建时间：2016.05.09
--]]

-- 道具数据说明
--[[
-- 服务器返回的道具数据中，每个条目包含的字段如下
    {
        Id:实体Id
        ModelId:道具模型Id
        Num:数量
        Crdate:最近获得时间
        LastTime:有效持续时间(小时)
        BeginTime:有效起始时间
        EndTime:有效结束时间
    }, 
]]

local CacheGoods = class("CacheGoods", {})

-- 需要显示New标识的道具模型Id列表
local showNewGoodsModelId = {
    -- Todo
}

-- 需要判断小红点点道具
local reddotGoodsModelid = {
    [16050003] = true, -- 招募令
    [16050241] = true, -- 单抽令
    [16050047] = true, -- 十连招募令
    [16050001] = true, -- 突破丹
    [16050041] = true, -- 金锤 
    [16050048] = true, -- 往生丹
    [16050016] = true, -- 佣兵牌
    [16050034] = true, -- 洗练石
    [16050046] = true, -- 重洗令
    [16050091] = true, -- 江湖令
    [16050234] = true, -- 除魔令
    [16050023] = true, -- 内力
    [16050063] = true, -- 群雄争霸道具
    [16050100] = true, --外功灵玉
}

--[[
]]
function CacheGoods:ctor()
    -- 道具列表的原始数据
	self.mPropsList = {}
    -- 人物碎片列表原始数据
    self.mHeroDebris = {}
    -- 装备碎片原始数据
    self.mEquipDebris = {}
    -- 内功碎片原始数据
    self.mZhenjueDebris = {}
    -- 外功碎片原始数据
    self.mPetDebris = {}
    -- 药材丹药
    self.mQuenchList = {}
    -- 时装碎片
    self.mFashionDebris = {}
    -- 幻化碎片
    self.mIllusionDebris = {}
    -- 珍兽碎片
    self.mZhenshouDebris = {}
    -- Q版时装碎片
    self.mShiZhuangDebris = {}

    -- 以实例Id为key的道具列表
    self.mPropsIdList = {}
    -- 以实例Id为key的人物碎片列表
    self.mHeroDebrisIdList = {}
    -- 以实例Id为key的装备碎片列表
    self.mEquipDebrisIdList = {}
    -- 以实例Id为key的内功碎片列表
    self.mZhenjueDebrisIdList = {}
    -- 以实例Id为key的外功碎片列表
    self.mPetDebrisIdList = {}
    -- 以实例Id为key的药材丹药列表
    self.mQuenchIdList = {}
    -- 以实例Id为key的时装碎片列表
    self.mFashionDebrisIdList = {}
    -- 以实例Id为key的幻化碎片列表
    self.mIllusionDebrisIdList = {}
    -- 以实例Id为key的珍兽碎片列表
    self.mZhenshouDebrisIdList = {}
    -- 以实例Id为key的Q版时装碎片列表
    self.mShiZhuangDebrisIdList = {}

    -- 以模型Id为key的物品列表
    self.mModelList = {}
    -- 已资源类型为Key的物品列表
    self.mTypeIdList = {}

    -- 新得到道具Id列表对象
    self.mNewPropsIdObj = require("data.NewIdList"):create()
    -- 新得到人物碎片Id列表对象
    self.mNewHeroDebrisIdObj = require("data.NewIdList"):create()
    -- 新得到装备碎片Id列表对象
    self.mNewEquipDebrisIdObj = require("data.NewIdList"):create()
    -- 新得到内功碎片Id列表对象
    self.mNewZhenjueDebrisIdObj = require("data.NewIdList"):create()
    -- 新得到外功碎片Id列表对象
    self.mNewPetDebrisIdObj = require("data.NewIdList"):create()
    -- 新得到药材丹药Id列表对象
    self.mNewQuenchIdObj = require("data.NewIdList"):create()
    -- 新得到时装碎片Id列表对象
    self.mNewFashionDebrisIdObj = require("data.NewIdList"):create()
    -- 新得到幻化碎片Id列表对象
    self.mNewIllusionDebrisIdObj = require("data.NewIdList"):create()
    -- 新得到珍兽碎片Id列表对象
    self.mNewZhenshouDebrisIdObj = require("data.NewIdList"):create()
    -- 新得到Q版碎片Id列表对象
    self.mNewShiZhuangDebrisIdObj = require("data.NewIdList"):create()

end

-- 清空管理对象中的数据
function CacheGoods:reset()
    self.mPropsList = {}
    self.mHeroDebris = {}
    self.mEquipDebris = {}
    self.mZhenjueDebris = {}
    self.mPetDebris = {}
    self.mQuenchList = {}
    self.mFashionDebris = {}
    self.mIllusionDebris = {}
    self.mZhenshouDebris = {}
    self.mShiZhuangDebris = {}

    self.mPropsIdList = {}
    self.mHeroDebrisIdList = {}
    self.mEquipDebrisIdList = {}
    self.mZhenjueDebrisIdList = {}
    self.mPetDebrisIdList = {}
    self.mQuenchIdList = {}
    self.mFashionDebrisIdList = {}
    self.mIllusionDebrisIdList = {}
    self.mZhenshouDebrisIdList = {}
    self.mShiZhuangDebrisIdList = {}

    self.mModelList = {}
    self.mTypeIdList = {}

    self.mNewPropsIdObj:clearNewId()
    self.mNewHeroDebrisIdObj:clearNewId()
    self.mNewEquipDebrisIdObj:clearNewId()
    self.mNewZhenjueDebrisIdObj:clearNewId()
    self.mNewPetDebrisIdObj:clearNewId()
    self.mNewQuenchIdObj:clearNewId()
    self.mNewFashionDebrisIdObj:clearNewId()
    self.mNewIllusionDebrisIdObj:clearNewId()
    self.mNewZhenshouDebrisIdObj:clearNewId()
    self.mNewShiZhuangDebrisIdObj:clearNewId()

end

-- 刷新道具辅助缓存，主要用于数据获取时效率优化
function CacheGoods:refreshAssistCache()
    self.mPropsIdList = {}
    self.mHeroDebrisIdList = {}
    self.mEquipDebrisIdList = {}
    self.mZhenjueDebrisIdList = {}
    self.mPetDebrisIdList = {}
    self.mQuenchIdList = {}
    self.mFashionDebrisIdList = {}
    self.mIllusionDebrisIdList = {}
    self.mZhenshouDebrisIdList = {}
    self.mShiZhuangDebrisIdList = {}
    self.mModelList = {}   
    self.mTypeIdList = {}
    local function dealOneType(goodsList, IdList)
        for _, item in pairs(goodsList) do
            local itemModelId = item.ModelId or item.GoodsModelId
            IdList[item.Id] = item
            self.mModelList[itemModelId] = self.mModelList[itemModelId] or {}
            table.insert(self.mModelList[itemModelId], item)

            local tempModel
            if math.floor(itemModelId / 100000) == 169 then
                tempModel = GoodsVoucherModel.items[item.ModelId]
            else
                tempModel = GoodsModel.items[item.ModelId]
            end
            
            if tempModel then
                self.mTypeIdList[tempModel.typeID] = self.mTypeIdList[tempModel.typeID] or {}
                table.insert(self.mTypeIdList[tempModel.typeID], item)
            else
                print("not found goods model id:", itemModelId)
            end
        end
    end

    -- 处理道具数据
    dealOneType(self.mPropsList, self.mPropsIdList)
    -- 处理人物碎片数据
    dealOneType(self.mHeroDebris, self.mHeroDebrisIdList)
    -- 处理装备碎片数据
    dealOneType(self.mEquipDebris, self.mEquipDebrisIdList)
    -- 处理内功碎片数据
    dealOneType(self.mZhenjueDebris, self.mZhenjueDebrisIdList)
    -- 处理外功碎片数据
    dealOneType(self.mPetDebris, self.mPetDebrisIdList)
    -- 处理药材丹药数据
    dealOneType(self.mQuenchList, self.mQuenchIdList)
    -- 处理时装碎片数据
    dealOneType(self.mFashionDebris, self.mFashionDebrisIdList)
    -- 处理幻化碎片数据
    dealOneType(self.mIllusionDebris, self.mIllusionDebrisIdList)
    -- 处理珍兽碎片数据
    dealOneType(self.mZhenshouDebris, self.mZhenshouDebrisIdList)
    -- 处理Q版时装碎片数据
    dealOneType(self.mShiZhuangDebris, self.mShiZhuangDebrisIdList)

end

-- 设置道具列表
function CacheGoods:setGoodsList(goodsList)
	self.mPropsList = goodsList and goodsList.PropsInfo or {}
    self.mHeroDebris = goodsList and goodsList.HeroDebrisInfo or {}
    self.mEquipDebris = goodsList and goodsList.EquipDebrisInfo or {}
    self.mZhenjueDebris = goodsList and goodsList.ZhenjueDebrisInfo or {}
    self.mPetDebris = goodsList and goodsList.PetDebrisInfo or {}
    self.mQuenchList = goodsList and goodsList.GoodsQuenchInfo or {}
    self.mFashionDebris = goodsList and goodsList.GoodsFashionDebrisInfo or {}
    self.mIllusionDebris = goodsList and goodsList.GoodsIllusionDebrisInfo or {}
    self.mZhenshouDebris = goodsList and goodsList.GoodsZhenshouDebrisInfo or {}
    self.mShiZhuangDebris = goodsList and goodsList.GoodsShizhuangDebrisInfo or {}

    self:refreshAssistCache()
end

-- 道具数据改变
--[[
-- 参数
    modifyItems: 道具修改部分的数据列表，其中每条数据的内容参考文件头处的 “道具数据说明”
]]
function CacheGoods:modifyGoods(modifyItems)
    -- 更具模型Id删除道具列表中对应条目
    local function deleteGoodsByModel(dataList, modelItem)
        local ret = {}
        for index = #dataList, 1, -1 do
            if dataList[index].ModelId == modelItem.ID then
                table.insert(ret, dataList[index])
                table.remove(dataList, index)
            end
        end

        return ret
    end

    -- 获取条目原来的数量
    local function getOldItemNum(id, itemList)
        for _, item in pairs(itemList) do
            if item.Id == id then
                return item.Num
            end
        end
        return 0
    end

    -- 需要通知道具和人物碎片数量改变的模型Id列表
    local modelIdList = {}

    for key, itemList in pairs(modifyItems or {}) do
        local modelId = tonumber(key)
        local tempModel
        if math.floor(modelId / 100000) == 169 then
            tempModel = GoodsVoucherModel.items[modelId]
        else
            tempModel = GoodsModel.items[modelId]
        end
        modelIdList[modelId] = tempModel
        --
        local dataList = {}
        if tempModel.typeID == ResourcetypeSub.eHeroDebris then  -- 人物碎片
            dataList = self.mHeroDebris
        elseif tempModel.typeID == ResourcetypeSub.eEquipmentDebris then  -- 装备碎片
            dataList = self.mEquipDebris
        elseif tempModel.typeID == ResourcetypeSub.eNewZhenJueDebris then  -- 内功碎片
            dataList = self.mZhenjueDebris
        elseif tempModel.typeID == ResourcetypeSub.ePetDebris then  -- 外功碎片
            dataList = self.mPetDebris
        elseif tempModel.typeID == ResourcetypeSub.eQuench then -- 药材丹药
            dataList = self.mQuenchList
        elseif tempModel.typeID == ResourcetypeSub.eFashionDebris then --时装碎片
            dataList = self.mFashionDebris
        elseif tempModel.typeID == ResourcetypeSub.eIllusionDebris then --幻化碎片
            dataList = self.mIllusionDebris
        elseif tempModel.typeID == ResourcetypeSub.eZhenshouDebris then --珍兽碎片
            dataList = self.mZhenshouDebris
        elseif tempModel.typeID == ResourcetypeSub.eShiZhuangDebris then --Q版时装碎片
            dataList = self.mShiZhuangDebris
        else
            dataList = self.mPropsList
        end

        -- 先删除缓存数据中相关模型Id的数据
        local delItemList = deleteGoodsByModel(dataList, tempModel)

        -- 把请求到的数据更新到缓存中
        for index, item in pairs(itemList) do
            local oldNum = getOldItemNum(item.Id, delItemList)
            table.insert(dataList, item)

            if showNewGoodsModelId[item.ModelId] and item.Num > oldNum then
                self.mNewPropsIdObj:insertNewId(item.Id)
            end
        end
    end

    -- 
    self:refreshAssistCache()

    -- 通知对应相关模块道具的更新情况
    local heroDebrisChange = false
    for modelId, modelItem in pairs(modelIdList) do
        if modelItem.typeID == ResourcetypeSub.eHeroDebris then
            heroDebrisChange = true

            -- 人物碎片信息改变通知
            Notification:postNotification(EventsName.eHeroDebrisRedDotPrefix .. tostring(modelId))
        end

        -- 
        if reddotGoodsModelid[modelId] then 
            Notification:postNotification(EventsName.ePropRedDotPrefix .. tostring(modelId))
        end
    end

    -- 有人物碎片修改，需要通知相关小红点修改
    if heroDebrisChange then
        Notification:postNotification(EventsName.eHeroDebrisRedDotPrefix)
    end
end

--- 获取道具列表
--[[
-- 参数
    needClone：是否需要返回克隆数据，如果为True，调用者可以对返回值做任何操作而不会影响缓存的物品列表,如果为false，则不能对返回值做任何修改
    needIndex: 是否需要实例Id索引条目, 当needClone为false时，该参数无效
-- 返回值，返回道具列表，每个记录数据的内容参考文件头处的 “道具数据说明”
 ]]
function CacheGoods:getPropsList(needClone, needIndex)
    if needClone then
        return needIndex and clone(self.mPropsIdList) or clone(self.mPropsList)
    else
        return needIndex and self.mPropsIdList or self.mPropsList
    end
end

--- 获取人物碎片列表
--[[
-- 参数
    needClone：是否需要返回克隆数据，如果为True，调用者可以对返回值做任何操作而不会影响缓存的物品列表,如果为false，则不能对返回值做任何修改
    needIndex: 是否需要实例Id索引条目, 当needClone为false时，该参数无效
-- 返回值，返回人物碎片列表，每个记录数据的内容参考文件头处的 “道具数据说明”
 ]]
function CacheGoods:getHeroDebrisList(needClone, needIndex)
    if needClone then
        return needIndex and clone(self.mHeroDebrisIdList) or clone(self.mHeroDebris)
    else
        return needIndex and self.mHeroDebrisIdList or self.mHeroDebris
    end
end

--- 获取装备碎片列表
--[[
-- 参数
    needClone：是否需要返回克隆数据，如果为True，调用者可以对返回值做任何操作而不会影响缓存的物品列表,如果为false，则不能对返回值做任何修改
    needIndex: 是否需要实例Id索引条目, 当needClone为false时，该参数无效
-- 返回值，返回装备碎片列表，每个记录数据的内容参考文件头处的 “道具数据说明”
 ]]
function CacheGoods:getEquipDebrisList(needClone, needIndex)
    if needClone then
        return needIndex and clone(self.mEquipDebrisIdList) or clone(self.mEquipDebris)
    else
        return needIndex and self.mEquipDebrisIdList or self.mEquipDebris
    end
end

--- 获取内功碎片列表
--[[
-- 参数
    needClone：是否需要返回克隆数据，如果为True，调用者可以对返回值做任何操作而不会影响缓存的物品列表,如果为false，则不能对返回值做任何修改
    needIndex: 是否需要实例Id索引条目, 当needClone为false时，该参数无效
-- 返回值，返回内功碎片列表，每个记录数据的内容参考文件头处的 “道具数据说明”
 ]]
function CacheGoods:getZhenjueDebrisList(needClone, needIndex)
    if needClone then
        return needIndex and clone(self.mZhenjueDebrisIdList) or clone(self.mZhenjueDebris)
    else
        return needIndex and self.mZhenjueDebrisIdList or self.mZhenjueDebris
    end
end

--- 获取外功碎片列表
--[[
-- 参数
    needClone：是否需要返回克隆数据，如果为True，调用者可以对返回值做任何操作而不会影响缓存的物品列表,如果为false，则不能对返回值做任何修改
    needIndex: 是否需要实例Id索引条目, 当needClone为false时，该参数无效
-- 返回值，返回外功碎片列表，每个记录数据的内容参考文件头处的 “道具数据说明”
 ]]
function CacheGoods:getPetDebrisList(needClone, needIndex)
    if needClone then
        return needIndex and clone(self.mPetDebrisIdList) or clone(self.mPetDebris)
    else
        return needIndex and self.mPetDebrisIdList or self.mPetDebris
    end
end

--- 获取药材丹药列表
--[[
-- 参数
    needClone：是否需要返回克隆数据，如果为True，调用者可以对返回值做任何操作而不会影响缓存的物品列表,如果为false，则不能对返回值做任何修改
    needIndex: 是否需要实例Id索引条目, 当needClone为false时，该参数无效
-- 返回值，返回药材丹药列表，每个记录数据的内容参考文件头处的 “道具数据说明”
 ]]
function CacheGoods:getQuenchList(needClone, needIndex)
    if needClone then
        return needIndex and clone(self.mQuenchIdList) or clone(self.mQuenchList)
    else
        return needIndex and self.mQuenchIdList or self.mQuenchList
    end
end

--- 获取时装碎片列表
--[[
-- 参数
    needClone：是否需要返回克隆数据，如果为True，调用者可以对返回值做任何操作而不会影响缓存的物品列表,如果为false，则不能对返回值做任何修改
    needIndex: 是否需要实例Id索引条目, 当needClone为false时，该参数无效
-- 返回值，返回药材丹药列表，每个记录数据的内容参考文件头处的 “道具数据说明”
 ]]
function CacheGoods:getFashionDebrisList(needClone, needIndex)
    if needClone then
        return needIndex and clone(self.mFashionDebrisIdList) or clone(self.mFashionDebris)
    else
        return needIndex and self.mFashionDebrisIdList or self.mFashionDebris
    end
end

--- 获取幻化碎片列表
--[[
-- 参数
    needClone：是否需要返回克隆数据，如果为True，调用者可以对返回值做任何操作而不会影响缓存的物品列表,如果为false，则不能对返回值做任何修改
    needIndex: 是否需要实例Id索引条目, 当needClone为false时，该参数无效
-- 返回值，返回药材丹药列表，每个记录数据的内容参考文件头处的 “道具数据说明”
 ]]
function CacheGoods:getIllusionDebrisList(needClone, needIndex)
    if needClone then
        return needIndex and clone(self.mIllusionDebrisIdList) or clone(self.mIllusionDebris)
    else
        return needIndex and self.mIllusionDebrisIdList or self.mIllusionDebris
    end
end

--- 获取珍兽碎片列表
--[[
-- 参数
    needClone：是否需要返回克隆数据，如果为True，调用者可以对返回值做任何操作而不会影响缓存的物品列表,如果为false，则不能对返回值做任何修改
    needIndex: 是否需要实例Id索引条目, 当needClone为false时，该参数无效
-- 返回值，返回药材丹药列表，每个记录数据的内容参考文件头处的 “道具数据说明”
 ]]
function CacheGoods:getZhenshouDebrisList(needClone, needIndex)
    if needClone then
        return needIndex and clone(self.mZhenshouDebrisIdList) or clone(self.mZhenshouDebris)
    else
        return needIndex and self.mZhenshouDebrisIdList or self.mZhenshouDebris
    end
end

--- 获取Q版时装碎片列表
--[[
-- 参数
    needClone：是否需要返回克隆数据，如果为True，调用者可以对返回值做任何操作而不会影响缓存的物品列表,如果为false，则不能对返回值做任何修改
    needIndex: 是否需要实例Id索引条目, 当needClone为false时，该参数无效
-- 返回值，返回药材丹药列表，每个记录数据的内容参考文件头处的 “道具数据说明”
 ]]
function CacheGoods:getShiZhuangDebrisList(needClone, needIndex)
    if needClone then
        return needIndex and clone(self.mShiZhuangDebrisIdList) or clone(self.mShiZhuangDebris)
    else
        return needIndex and self.mShiZhuangDebrisIdList or self.mShiZhuangDebris
    end
end

--- 获取道具信息（人物碎片）
--[[
-- 参数：
    goodsId:道具实例id
-- 返回值参考文件头部的 “道具数据说明” 
--]]
function CacheGoods:getGoods(goodsId)
    return self.mPropsIdList[goodsId] or self.mHeroDebrisIdList[goodsId] or self.mEquipDebrisIdList[goodsId] or self.mZhenjueDebrisIdList[goodsId] or self.mPetDebrisIdList[goodsId] or self.mQuenchIdList[goodsId] or self.mFashionDebrisIdList[goodsId] or self.mIllusionDebrisIdList[goodsId] or self.mShiZhuangDebrisIdList[goodsId]
end

--- 判断玩家是否拥有某种类型的道具（人物碎片）
--[[
-- 参数
    modelId: 道具的模型Id
-- 返回值
    返回该道具模型Id的实例列表，单个道具的信息参考文件头部的 “道具数据说明” 
 ]]
function CacheGoods:findByModelId(modelId)
    return self.mModelList[modelId]
end

--- 获取玩家拥有某种道具的数量
function CacheGoods:getCountByModelId(modelId)
    local ret = 0
    local tempList = self.mModelList[modelId] or {}
    for _, item in pairs(tempList) do
        ret = item.Num + ret
    end
    return ret
end

--- 根据资源类型获取相应的道具列表
--[[
-- 参数：
     resourcetypeSub: 资源子类型（定义在枚举ResourcetypeSub中的道具部分）
-- 返回值为过滤后的道具列表
 ]]
function CacheGoods:getPropsByResourceTypeSub(resourcetypeSub)
    return self.mTypeIdList[resourcetypeSub]
end

-- 获取新道具Id列表对象
--[[
-- 返回值
    返回值提供的接口查看 "data/NewidList.lua" 文件
]]
function CacheGoods:getNewPropsIdObj()
    return self.mNewPropsIdObj
end

-- 获取新人物碎片Id列表对象
--[[
-- 返回值
    返回值提供的接口查看 "data/NewidList.lua" 文件
]]
function CacheGoods:getNewHeroDebrisIdObj()
    return self.mNewHeroDebrisIdObj
end

-- 获取新得到装备碎片Id列表对象
--[[
-- 返回值
    返回值提供的接口查看 "data/NewidList.lua" 文件
]]
function CacheGoods:getNewEquipDebrisIdObj()
    return self.mNewEquipDebrisIdObj
end

-- 获取新得到内功碎片Id列表对象
--[[
-- 返回值
    返回值提供的接口查看 "data/NewidList.lua" 文件
]]
function CacheGoods:getNewZhenjueDebrisIdObj()
    return self.mNewZhenjueDebrisIdObj
end

-- 获取新得到外功碎片Id列表对象
--[[
-- 返回值
    返回值提供的接口查看 "data/NewidList.lua" 文件
]]
function CacheGoods:getNewPetDebrisIdObj()
    return self.mNewPetDebrisIdObj
end

-- 获取新得到药材丹药Id列表对象
--[[
-- 返回值
    返回值提供的接口查看 "data/NewidList.lua" 文件
]]
function CacheGoods:getNewQuenchIdObj()
    return self.mNewQuenchIdObj
end

-- 获取新得到时装碎片Id列表对象
--[[
-- 返回值
    返回值提供的接口查看 "data/NewidList.lua" 文件
]]
function CacheGoods:getNewFashionDebrisIdObj()
    return self.mNewFashionDebrisIdObj
end

-- 获取新得到幻化碎片Id列表对象
--[[
-- 返回值
    返回值提供的接口查看 "data/NewidList.lua" 文件
]]
function CacheGoods:getNewIllusionDebrisIdObj()
    return self.mNewIllusionDebrisIdObj
end

-- 获取新得到珍兽碎片Id列表对象
--[[
-- 返回值
    返回值提供的接口查看 "data/NewidList.lua" 文件
]]
function CacheGoods:getNewZhenshouDebrisIdObj()
    return self.mNewZhenshouDebrisIdObj
end

-- 获取新得到珍兽碎片Id列表对象
--[[
-- 返回值
    返回值提供的接口查看 "data/NewidList.lua" 文件
]]
function CacheGoods:getNewShiZhuangDebrisIdObj()
    return self.mNewShiZhuangDebrisIdObj
end



return CacheGoods
