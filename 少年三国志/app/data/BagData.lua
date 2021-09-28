require("app.cfg.item_info")
require("app.cfg.fragment_info")
require("app.cfg.equipment_info")
require("app.cfg.treasure_info")
require("app.cfg.treasure_fragment_info")
require("app.cfg.treasure_compose_info")
require "app.cfg.knight_info"
require "app.cfg.pet_info"
require("app.cfg.item_awaken_info")
require("app.cfg.item_awaken_compose")
require("app.cfg.treasure_advance_info")

local BagConst = require("app.const.BagConst")
local BagData =  class("BagData")
local MergeEquipment = require("app.data.MergeEquipment")
local BagDataSort = require("app.data.BagDataSort")
function BagData:ctor()
    --道具
    self.propList = require("app.scenes.bag.BagTable").new("id")
    
    self.fragmentList = require("app.scenes.bag.BagTable").new("id")
    
    self.knightsData = require("app.data.KnightsData").new()
    
    self.equipmentList = require("app.scenes.bag.BagTable").new("id")
    
    self.treasureFragmentList = require("app.scenes.bag.BagTable").new("id")
    
    self.treasureList = require("app.scenes.bag.BagTable").new("id")
    
    -- 觉醒道具
    self.awakenList = require("app.scenes.bag.BagTable").new("id")

    -- 战宠数据, 战宠碎片存放在fragmentList中
    self.petData = require("app.data.PetData").new()
end

function BagData:addToPropList(prop)
    if prop ~= nil then
        if prop.num == 0 then
            --服务器为0也有可能推过来,我了个去
            return
        end
        --判断是否过期了
        local item = item_info.get(prop.id) 
        if item then
            if item.destroy_time > 0 then
                print("-item.destroy_time = " .. item.destroy_time)
                local leftSeconds = G_ServerTime:getLeftSeconds(item.destroy_time)
                if leftSeconds > 0 then
                    self.propList:addItem(prop)
                end
            else
                self.propList:addItem(prop)
            end
        end
    end
end

function BagData:updatePropList(prop)
    self.propList:updateItem(prop)
end

function BagData:removeFromPropList(id)
    self.propList:removeItemByKey(id)
end

function BagData:sortPropList()
    BagDataSort.sortPropList()
end

function BagData:hasEnoughProp( id, count )
    if not id then
        return false
    end
    
    --    local propInfo = self.propList[id]
    local propInfo = self.propList:getItemByKey(id)
    if not propInfo then 
        return false
    end
    
    count = count or 0
    return propInfo["num"] >= count 
end


function BagData:addToFragmentList(fragment)
    self.fragmentList:addItem(fragment)
end

function BagData:updateFragmentList(fragment)
    self.fragmentList:updateItem(fragment)
end

function BagData:removeFromFragmentList(id)
    self.fragmentList:removeItemByKey(id)
end

function BagData:getEquipmentFragmentList()
    local list = {}
    for i,v in ipairs(G_Me.bagData.fragmentList:getList()) do
        local fragment = fragment_info.get(v.id)
        v["checked"] = false
        v["money"] = fragment.sale_num
        if fragment.fragment_type == BagConst.FRAGMENT_TYPE_EQUIPMENT then
            list[#list+1] = v
        end
    end
    return list
end

-- 可出售碎片列表
function BagData:getFragmentListForSell( fragmentType )
    local list = {}
    for i,v in ipairs(G_Me.bagData.fragmentList:getList()) do
        local fragment = fragment_info.get(v.id)
        v["checked"] = false
        v["money"] = fragment.sale_num
        if fragment.fragment_type == fragmentType then
            list[#list+1] = v
        end
    end

    local sortFunc = function ( a, b )
        local fragA = fragment_info.get(a.id)
        local fragB = fragment_info.get(b.id)
        if fragA.quality ~= fragB.quality then
            return fragA.quality < fragB.quality
        end

        return fragA.id < fragB.id
    end

    table.sort( list, sortFunc )

    return list
end

function BagData:getKnightFragmentList()
    local list = {}
    for i,v in ipairs(G_Me.bagData.fragmentList:getList()) do
        local fragment = fragment_info.get(v.id)
        --knight碎片
        v["checked"] = false
        v["money"] = fragment.sale_num
        if fragment.fragment_type == BagConst.FRAGMENT_TYPE_KNIGHT then
            list[#list+1] = v
        end
    end
    return list
end

-- 战宠碎片
function BagData:getPetFragmentList()
    local list = {}
    for i,v in ipairs(G_Me.bagData.fragmentList:getList()) do
        local fragment = fragment_info.get(v.id)
        --战宠碎片
        if fragment.fragment_type == BagConst.FRAGMENT_TYPE_PET then
            list[#list+1] = v
        end
    end
    return list
end


function BagData:addToTreasureFragmentList(fragment)
    self.treasureFragmentList:addItem(fragment)
end

function BagData:updateTreasureFragmentList(fragment)
    self.treasureFragmentList:updateItem(fragment)
end

function BagData:removeTreasureFromFragmentList(id)
    self.treasureFragmentList:removeItemByKey(id)
end



--碎片合成的种类List
function BagData:getTreasureFragmentListByComposeId()
    local list = {}
    --根据compose_id区分
    local tmpList = {}
    for i,v in ipairs(self.treasureFragmentList:getList()) do
        local fragment = treasure_fragment_info.get(v.id)
        --__LogTag(TAG,"----------------------fragment.compose_id = %s",fragment.compose_id)
        if tmpList[fragment.compose_id] == nil then
            list[#list+1] = fragment.compose_id
            tmpList[fragment.compose_id]  = {}
        end
    end

    
    return list;
end 


--obj is equipment or treasure
local function extendMergeEquipment(obj, subtype)
    setmetatable(obj, MergeEquipment)
    obj.subtype = subtype
end

function BagData:addToTreasureList(treasure)
    extendMergeEquipment(treasure, MergeEquipment.SUBTYPE.TREASURE)
    self.treasureList:addItem(treasure)
end

function BagData:updateTreasureList(treasure)
    extendMergeEquipment(treasure, MergeEquipment.SUBTYPE.TREASURE)
    self.treasureList:updateItem(treasure)

    -- 宝物铸造会使宝物的品质改变，因此这里需要将原来的baseInfo置空
    self:getTreasureById(treasure.id):resetInfo()

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVNET_BAG_UPDATE_TREASURE, nil, false, treasure)
end

function BagData:removeTreasureFromList(id)
    self.treasureList:removeItemByKey(id)
end

function BagData:sortTreasureFragmentList()
    BagDataSort.sortTreasureFragmentList()
end

--获取不同类型宝物List
function BagData:getTreasureListByType(_type)
    local list = {}
    for i,v in ipairs(self.treasureList:getList()) do
        local treasure = treasure_info.get(v.base_id or 0)
        if treasure and treasure.type == _type then
            list[#list+1] = v
        end
    end
    return list
end

--可强化和精炼宝物List
function BagData:getTreasureStrengthAvailableList()
    local list = {}
    for i,v in ipairs(self.treasureList:getList()) do
        local treasure = treasure_info.get(v.base_id or 0)
        if treasure and treasure.is_strength == 1 then
            list[#list+1] = v
        end
    end
    return list
end


--获取 宝物List按精炼排序
function BagData:getTreasureListByRefine()
    local list = self.treasureList:getList()
    local sortFunc = function(a,b)
        if a.level ~= b.level then
            return a.level > b.level
        end
        local treasureA = treasure_info.get(a.base_id)
        local treasureB = treasure_info.get(b.base_id)
        if treasureA.star ~= treasureB.star then
            return treasureA.star > treasureB.star
        end
        if treasureA.quality ~= treasureB.quality then
            return treasureA.quality > treasureB.quality
        end
    end
    table.sort(list, sortFunc)
    return list;
end

--检查宝物是否可以精炼
function BagData:checkTreasureRefine(treasure_id)
    --判断等级是否达到
    local FunctionLevelConst = require("app.const.FunctionLevelConst")
    if not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.TREASURE_TRAINING) then 
        return false
    end

    local treasure = self.treasureList:getItemByKey(treasure_id)
    if not treasure then
        return false
    end

    local knightId = G_Me.formationData:getWearTreasureKnightId(treasure_id)
    --未穿戴
    if knightId == 0 then
        return false
    end

    --不可精炼
    local info = treasure_info.get(treasure.base_id)
    if not info or info.is_strength ~= 1 then
        return false
    end

    --判断是否到达最高精炼等级
    local level = treasure.refining_level
    local maxLevel = treasure:getMaxRefineLevel()
    if level >= maxLevel then
        return false
    end

    local list = self:getTreasureListByTreasure(treasure)
    local refineList = {}
    for i,t in pairs(list) do
        --判断是否已精炼
        if t.refining_level == 0 then
            --判断是否已上阵
            local knightId = G_Me.formationData:getWearTreasureKnightId(t.id)
            --未上阵
            if knightId == 0 then
                refineList[#refineList+1] = t
            end
        end
    end

    --判断下一精炼 所需
    local nextRefineLevel = treasure:getNextRefineLevel()
    local advance_info = treasure_advance_info.get(nextRefineLevel)
    if not advance_info then return false end


    --银两不足
    if G_Me.userData.money < advance_info["cost_num_" .. 1] then
        return false
    end

    --道具数量
    if advance_info["cost_num_" .. 2] > 0 and advance_info["cost_value_" .. 2] > 0 then
        local num = self:getPropCount(advance_info["cost_value_" .. 2])
        if num < advance_info["cost_num_" .. 2] then
            return false
        end
    end

    --宝物数量
    if advance_info["cost_num_" .. 3] > 0 then
        if #refineList < advance_info["cost_num_" .. 3] then
            return false 
        end
    end

    return true

end


function BagData:sortTreasureList()
    BagDataSort.sortTreasureList()
end


function BagData:sortFragmentList()
    BagDataSort.sortFragmentList()
end


-------以下处理-----装备
function BagData:addToEquipmentList(equipment)
    extendMergeEquipment(equipment, MergeEquipment.SUBTYPE.EQUIP)
    self.equipmentList:addItem(equipment)
end

function BagData:updateEquipmentList(equipment)
    extendMergeEquipment(equipment, MergeEquipment.SUBTYPE.EQUIP)
    self.equipmentList:updateItem(equipment)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVNET_BAG_UPDATE_EQUIPMENT, nil, false, equipment)
end

--获取未穿戴的装备列表
function BagData:getNotWearEquipmentList()
    local list = {}
    for i,v in ipairs(self.equipmentList:getList()) do
        if not v:isWearing() then
            table.insert(list,v)
        end
    end
    return list
end

-- 获取符合分解条件的装备列表
function BagData:getRebornEquipmentList(  )
    local list = {}
    for i,v in ipairs(self.equipmentList:getList()) do
        if not v:isWearing() then
            local equipment = equipment_info.get(v.base_id)
            if equipment.quality > 2 then
                table.insert(list, v)
            elseif v.level > 1 or v.refining_level >= 1 or (v.star and v.star >= 1) then
                table.insert(list, v)
            end
        end
    end

    return list
end

function BagData:removeFromEquipmentList(id)
    self.equipmentList:removeItemByKey(id)
end

--获取不同类型装备List
function BagData:getEquipmentListByType(_type)
    local list = {}
    for i,v in ipairs(self.equipmentList:getList()) do
        local equipment = equipment_info.get(v.base_id)
        if equipment and equipment.type == _type then
            list[#list+1] = v
        end
    end
    return list
end

--直接用id做索引
function BagData:sortEquipmentList()
    BagDataSort.sortEquipmentList()
end

function BagData:getItemListByType(item_type)
    local list = {}
    for i,v in ipairs(self.propList:getList()) do
        if item_type == v.item_type then
            table.insert(list.v)
        end
    end
    return list
end

function BagData:getItemCount( id )
    if not id or type(id) ~= "number" then 
        return 0
    end

    local prop = self.propList:getItemByKey(id)
    if prop then
        return prop.num
    end
    return 0
end

--良将令数量
function BagData:getGoodKnightTokenCount()
    --    写死的,从表里读取
    local ItemConst = require("app.const.ItemConst")
    local prop = self.propList:getItemByKey(ItemConst.ITEM_ID.LIANG_JIANG_LING)
    if prop then
        return prop.num
    end
    return 0
end

--神将令数量
function BagData:getGodlyKnightTokenCount()
    --    写死的,从表里读取
    local ItemConst = require("app.const.ItemConst")
    local prop = self.propList:getItemByKey(ItemConst.ITEM_ID.SHEN_JIANG_LING)
    if prop then
        return prop.num
    end
    return 0
end

--三国志残卷数量
function BagData:getSanguozhiFragmentCount()
    --    写死的,从表里读取
    local ItemConst = require("app.const.ItemConst")
    local prop = self.propList:getItemByKey(ItemConst.ITEM_ID.SAN_GUO_ZHI_CAN_JUAN)
    if prop then
        return prop.num
    end
    return 0
end


--根据等级判断包裹卡牌最大容量
function BagData:getMaxKnightNumByLevel(level)
    require("app.cfg.role_info")
    local data = role_info.get(level)
    if not data then
        return -1;
    end
    -- 1.7.0版本开始，根据VIP等级增加相应容量
    local vipExtrNum = G_Me.vipData:getData(require("app.const.VipConst").KNIGHTBAGVIPEXTRA).value
    if vipExtrNum < 0 or type(vipExtrNum) ~= "number" then vipExtrNum = 0 end
    local maxNum = data.knight_bag_num_client + vipExtrNum
    return maxNum
end

--判断包裹Knight是否满了
function BagData:isKnightFull()
    require("app.cfg.role_info")
    local maxNum = self:getMaxKnightNumByLevel(G_Me.userData.level)
    __Log("---------maxNum = %s",maxNum)
    if maxNum == -1 then
        -- 坑了等级不存在
        return true
    end
    return self.knightsData:getKnightCount() >= maxNum
end

--根据等级判断包裹战宠最大容量
function BagData:getMaxPetNumByLevel(level)
    require("app.cfg.role_info")
    local data = role_info.get(level)
    if not data then
        return -1;
    end
    local maxNum = data.pet_bag_num_client
    return maxNum
end

--判断包裹战宠是否满了
function BagData:isPetFull()
    require("app.cfg.role_info")
    local maxNum = self:getMaxPetNumByLevel(G_Me.userData.level)
    __Log("---------maxNum = %s",maxNum)
    if maxNum == -1 then
        -- 坑了等级不存在
        return true
    end
    return self.petData:getPetCount() >= maxNum
end

--根据等级获得包裹装备最大容量
function BagData:getMaxEquipmentNumByLevel(level)
    local data = role_info.get(level)
    if not data then
        return -1
    end
    local maxNum = data.equipment_bag_num_client
    return maxNum
end

function BagData:getMaxTreasureNum()
    local data = role_info.get(G_Me.userData.level)
    if not data then
        return -1
    end
    -- 1.7.0版本开始，根据VIP等级增加相应容量    
    local vipExtrNum = G_Me.vipData:getData(require("app.const.VipConst").TREASUREBAGVIPEXTRA).value
    if vipExtrNum < 0 or type(vipExtrNum) ~= "number" then vipExtrNum = 0 end
    local maxNum = data.treasure_bag_num_client + vipExtrNum
    return maxNum
end

--判断包裹equipment是否满了
function BagData:isEquipmentFull()
    local maxNum = self:getMaxEquipmentNumByLevel(G_Me.userData.level)
    if maxNum == -1 then
        --等级超出了
        return true
    end
    return self.equipmentList:getCount() >= maxNum
end


--检测碎片合成是否包裹满了
function BagData:checkFragmentCompound(id)
    require("app.cfg.fragment_info")
    local fragment = fragment_info.get(id)
    if fragment.fragment_type == BagConst.FRAGMENT_TYPE_KNIGHT then
        return self:isKnightFull()
    elseif fragment.fragment_type == BagConst.FRAGMENT_TYPE_EQUIPMENT then
        return self:isEquipmentFull()
    elseif fragment.fragment_type == BagConst.FRAGMENT_TYPE_PET then
        return self:isPetFull()

    end
end

--根据Id获取宝物List,但除去本身

function BagData:getTreasureListByTreasure(treasure)
    local list = {}
    for i,v in ipairs(self.treasureList:getList()) do
        if v.base_id == treasure.base_id and treasure.id ~= v.id then
            list[#list+1] = v
        end
    end
    return list
end


--排序, 上阵, 星级, 潜质
local sortMergeEquipmentFunc = function(a,b)
    local weara = a:isWearing()
    local wearb = b:isWearing()
    if weara and not wearb then
        return true
    end

    if wearb and not weara then
        return false
    end

    local stra = a:isForStrength()
    local strb = b:isForStrength()
    if strb and not stra then
        return true
    end

    if stra and not strb then
        return false
    end

    local infoa = a:getInfo()
    local infob = b:getInfo()

    if infoa.quality ~= infob.quality then
        return infoa.quality > infob.quality
    end

    if infoa.potentiality ~= infob.potentiality then
        return infoa.potentiality > infob.potentiality
    end

    if a.refining_level ~= b.refining_level then
        return a.refining_level > b.refining_level
    end

    if a.star ~= b.star then
        return a.star > b.star
    end

    return a.level > b.level
end

function BagData:getSortedEquipmentList(needSort)
    local equipmentList = self.equipmentList:getList()
    local list = {}
    for i,v in ipairs(equipmentList) do
        table.insert(list, v)
    end
 
    --sort
    if needSort == nil then
        needSort = true
    end
    if needSort then
        table.sort(list, sortMergeEquipmentFunc)
    end
    return list
end

function BagData:getSortedTreasureList(needSort)
    local treasureList = self.treasureList:getList()

    local list = {}
    for i,v in ipairs(treasureList) do
        table.insert(list, v)
    end

    --sort
    if needSort == nil then
        needSort = true
    end
    if needSort then
        table.sort(list, sortMergeEquipmentFunc)
    end
    return list
end


--------------获取数量 START-------------------------
function BagData:getPropCount( propId )
    if not propId then
        return 0
    end
    
    --    local propInfo = self.propList[propId]
    local propInfo = self.propList:getItemByKey(propId)
    if not propInfo then 
        return 0
    end
    
    return propInfo["num"]
end

--获取碎片数量
function BagData:getFragmentNumById(fragment_id)
    local fragment = self.fragmentList:getItemByKey(fragment_id)
    if fragment == nil then return 0 end
    return fragment["num"]
end

function BagData:getTreasureFragmentNumById(fragment_id)
    local fragment = self.treasureFragmentList:getItemByKey(fragment_id)
    if fragment == nil then return 0 end
    return fragment["num"]
end

function BagData:getKnightNumByBaseId(base_id)
    local num = 0
    local knightList = G_Me.bagData.knightsData:getKnightsList()
    for i,v in pairs(knightList) do
        if v.base_id == base_id then
            num = num + 1
        else
            local knightInfo = knight_info.get(v.base_id)
            if knightInfo and knightInfo.advance_code == base_id then 
                num = num + 1
            end
        end
    end
    return num 
end


function BagData:getEquipmentNumByBaseId(base_id)
    local num = 0
    for i,v in ipairs(self.equipmentList:getList()) do
        if v["base_id"] == base_id then
            num = num + 1
        end
    end
    return num
end

function BagData:getTreasureNumByBaseId(base_id)
    local num = 0
    for i,v in ipairs(self.treasureList:getList()) do
        if v["base_id"] == base_id then
            num = num + 1
        end
    end
    return num
end

function BagData:getPetNumByBaseId(base_id)
    local num = 0
    for k,v in pairs(self.petData:getPetList()) do
        if v["base_id"] == base_id then
            num = num + 1
        else
            local petInfo = pet_info.get(v.base_id)
            if petInfo and petInfo.advanced_id == base_id then 
                num = num + 1
            end
        end
    end
    return num
end


--[[
获取武将数量 for 兑换活动
要求兑换物武将id>10000（即非狗粮卡），等级不超过5级，突破不超过1阶，天命不超过1级，没经过培养
]]

function BagData:getKnightNumByBaseIdForExchange(base_id)
    local num = 0
    local knightList = G_Me.bagData.knightsData:getKnightsList()
    for i,knightInfo in pairs(knightList) do
        --是否上阵
        local teamId = G_Me.formationData:getKnightTeamId(knightInfo.id)
        if teamId == 0 and knightInfo.level <=5 and base_id > 10000 and knightInfo.base_id == base_id then
            local knightBaseInfo = knight_info.get(base_id)
            --未突破，未天命,
            if knightBaseInfo and knightBaseInfo.advanced_level ==0 and knightInfo.halo_level <= 1 then
                 ----未培养
                local trainingData = knightInfo and knightInfo["training"] or nil
                if trainingData and trainingData.hp == 0 and trainingData.at == 0 and trainingData.pd == 0 and trainingData.md == 0 then
                    num = num + 1
                end
            end
        end
    end
    return num 
end

--[[
    获取装备数量 for 兑换活动
    要求兑换物装备等级不超过5级，精炼不超过1阶
]]

function BagData:getEquipmentNumByBaseIdForExchange(base_id)
    local num = 0
    for i,equip in ipairs(self.equipmentList:getList()) do
        if equip:getWearingKnightId()==0 and equip["base_id"] == base_id and equip.level <=5 and equip.refining_level <= 1 then
            num = num + 1
        end
    end
    return num
end


--[[
    获取宝物数量 for 兑换活动
    要求兑换物id>100（即非狗粮卡），等级不超过5级，精炼不超过1阶
]]

function BagData:getTreasureNumByBaseIdForExchange(base_id)
    local num = 0
    for i,treasure in ipairs(self.treasureList:getList()) do
        if treasure:getWearingKnightId()==0 and treasure["base_id"] > 100 and treasure["base_id"] == base_id and treasure.level <= 5 and treasure.refining_level <= 1 then
            num = num + 1
        end
    end
    return num
end


-- Goods.TYPE_SHENGWANG = 9
-- Goods.TYPE_EXP  = 10
-- Goods.TYPE_TILI  = 11
-- Goods.TYPE_JINGLI  = 12
-- Goods.TYPE_WUHUN  = 13
-- Goods.TYPE_JINENGDIAN  = 14
-- Goods.TYPE_MOSHEN = 15
-- Goods.TYPE_CHUANGUAN  = 16
-- Goods.TYPE_CHUZHENGLING  = 17
-- Goods.TYPE_DROP  = 18
-- Goods.TYPE_VIP_EXP = 19
function BagData:getNumByTypeAndValue(_type,_value)
    local good = G_Goods.convert(_type,_value)
    if not good then
        return 0
    end
    if _type == G_Goods.TYPE_EQUIPMENT then   --装备
        return self:getEquipmentNumByBaseId(_value)
    elseif _type == G_Goods.TYPE_KNIGHT then   --武将
        return self:getKnightNumByBaseId(_value)
    elseif _type == G_Goods.TYPE_FRAGMENT then  --碎片
        return self:getFragmentNumById(_value)
    elseif _type == G_Goods.TYPE_TREASURE then  --宝物
        return self:getTreasureNumByBaseId(_value)
    elseif _type == G_Goods.TYPE_TREASURE_FRAGMENT then --宝物碎片
        return self:getTreasureFragmentNumById(_value)
    elseif _type == G_Goods.TYPE_ITEM then    --道具
        return self:getPropCount(_value)
    elseif _type == G_Goods.TYPE_GOLD then
        return G_Me.userData.gold,good.name
    elseif _type == G_Goods.TYPE_MONEY then
        return G_Me.userData.money,good.name
    elseif _type == G_Goods.TYPE_SHENGWANG then   --声望
        return G_Me.userData.prestige,good.name
    elseif _type == G_Goods.TYPE_EXP then    --经验
        return G_Me.userData.exp,good.name
    elseif _type == G_Goods.TYPE_TILI then
        return G_Me.userData.vit,good.name
    elseif _type == G_Goods.TYPE_JINGLI then
        return G_Me.userData.spirit,good.name
    elseif _type == G_Goods.TYPE_WUHUN then
        return G_Me.userData.essence,good.name
    elseif _type == G_Goods.TYPE_JINENGDIAN then
        return 0,good.name
    elseif _type == G_Goods.TYPE_MOSHEN then
        return G_Me.userData.medal,good.name
    elseif _type == G_Goods.TYPE_CHUANGUAN then
        return G_Me.userData.tower_score,good.name
    elseif _type == G_Goods.TYPE_CHUZHENGLING then
        return G_Me.userData.battle_token,good.name
    elseif _type == G_Goods.TYPE_VIP_EXP then
        return G_Me.vipData:getExp(),good.name
    elseif _type == G_Goods.TYPE_CORP_DISTRIBUTION then --军团贡献
        return G_Me.userData.corp_point,good.name
    elseif _type == G_Goods.TYPE_SHI_ZHUANG then --时装 只能有1套
        return G_Me.dressData:getDressByBaseId(_value) and 1 or 0 ,good.name
    elseif _type == G_Goods.TYPE_AWAKEN_ITEM then --觉醒道具
        return self:getAwakenItemNumById(_value),good.name
    elseif _type == G_Goods.TYPE_SHENHUN then --神魂
        return G_Me.userData.god_soul,good.name
    elseif _type == G_Goods.TYPE_ZHUAN_PAN_SCORE then --转盘积分
        return G_Me.wheelData.score,good.name
    elseif _type == G_Goods.TYPE_CROSSWAR_MEDAL then --演武勋章
        return G_Me.userData.contest_point,good.name
    elseif _type == G_Goods.TYPE_INVITOR_SCORE then --推广积分
        return G_Me.userData.invitor_score,good.name
    elseif _type == G_Goods.TYPE_PET_SCORE then --兽魂
        return G_Me.userData.pet_points,good.name
    elseif _type == G_Goods.TYPE_DAILY_PVP_SCORE then
        return G_Me.userData.dailyPVPScore, good.name
    elseif _type == G_Goods.TYPE_QIYU_POINT then
        return G_Me.userData.qiyu_point
    elseif _type == G_Goods.TYPE_HERO_SOUL then
        return G_Me.heroSoulData:getSoulNum(_value)
    end    
    return 0
end


--[[
    function BagSellLayer:_getDataPrice(data)
        if self._sellType == G_Goods.TYPE_KNIGHT then
            local kni = knight_info.get(data.base_id)
            local advanceInfo = knight_advance_info.get(data.advanced_level)
            local recycleMoney = 0
            if advanceInfo ~= nil then
                recycleMoney = advanceInfo.recycle_money
            end
            return kni.price + recycleMoney + data.exp
        elseif self._sellType == G_Goods.TYPE_EQUIPMENT then
            local equip = equipment_info.get(data.base_id)
            return data.money+equip.price
        else

        end
    end
]]

--获取武将出售列表
function BagData:getKnightSellList()
    -- require("app.cfg.knight_info")
    local list = self.knightsData:getSellKnightsList()
    if list ~= nil and #list ~= 0 then
        local sortFunc = function(a,b)
            local kniA = knight_info.get(a.base_id)
            local kniB = knight_info.get(b.base_id)
            if kniA.quality ~= kniB.quality then
                return kniA.quality < kniB.quality
            end
            if a.level ~= b.level then
                return a.level < b.level
            end
            if kniA.advanced_level ~= kniB.advanced_level then 
                return kniA.advanced_level < kniB.advanced_level 
            end
            return a.base_id < b.base_id
        end
        table.sort(list,sortFunc)
    end
    return list
end

--获取装备出售列表
function BagData:getEquipmentSellList()
    local list = {}
    for i,v in ipairs(self.equipmentList:getList()) do
        if v:isWearing() == false and v:getInfo().is_sold == 1 then
            local equip = equipment_info.get(v.base_id)
            local data = clone(v)
            data.money = data.money + equip.price
            data["checked"] = false
            table.insert(list,data)
        end
    end
    if list ~= nil and #list ~= 0 then
        local sortFunc = function(a,b) 
            local equipA = equipment_info.get(a.base_id)
            local equipB = equipment_info.get(b.base_id)
            if equipA.quality ~= equipB.quality then
                return equipA.quality < equipB.quality
            end
            if a.level ~= b.level then
                return a.level < b.level
            end 
            return equipA.id < equipB.id
        end
        table.sort(list,sortFunc)
    end
    return list
end

--获取单个宝物
function BagData:getTreasureById(id)
    for i,v in ipairs(self.treasureList:getList()) do
        if v.id == id then
            return v
        end
    end

    return nil
end

--获取宝物出售列表
function BagData:getTreasureSellList()
    local list = {}
    for i,v in ipairs(self.treasureList:getList()) do
        if v:isWearing() == false and v:getInfo().is_sold == 1 then
            local treasure = treasure_info.get(v.base_id)
            local data = clone(v)
            data.money = data.exp + treasure.price
            data["checked"] = false
            table.insert(list,data)
        end
    end
    if list ~= nil and #list ~= 0 then
        local sortFunc = function(a,b) 
            local treasureA = treasure_info.get(a.base_id)
            local treasureB = treasure_info.get(b.base_id)
            
            if treasureA.quality ~= treasureB.quality then
                return treasureA.quality < treasureB.quality
            end
            if a.level ~= b.level then
                return a.level < b.level
            end
            return a.id < b.id
        end
        table.sort(list,sortFunc)
    end
    return list
end

function BagData:getTreasureComposeList()
    local composeList = {}
    local composeListIndex = {}
    local list = self.treasureFragmentList:getList()
    for i,v in ipairs(list) do
        local fragmentInfo = treasure_fragment_info.get(v.id)
        local compose = treasure_compose_info.get(fragmentInfo.compose_id)
        if composeList[compose.id] == nil then
            composeList[compose.id] = compose
            composeListIndex[#composeListIndex+1] = compose.id
        end
    end
    --再遍历basic是否已经存在了
    for i=1,treasure_compose_info.getLength() do
        local compose = treasure_compose_info.indexOf(i)
        if compose then
            local treasure = treasure_info.get(compose.treasure_id)
            if treasure and treasure.is_basic == 1 then
                if composeList[compose.id] == nil then
                    composeList[compose.id] = compose
                    composeListIndex[#composeListIndex+1] = compose.id
                end
            end
        end 
    end
    
    --[[
        第1优先级：经验宝物          
                    
        第2优先级：宝物品质          
               橙色＞紫色＞蓝色＞绿色＞白色       
             书-->防御     马---攻击      
        第3优先级：书＞马         

        type:1 攻击型
        type:2 防御型
        type:3 经验
    ]]
    local sortFunc = function(a,b)
        
        local composeA =  treasure_compose_info.get(a)
        local composeB =  treasure_compose_info.get(b)
        local treasureA = treasure_info.get(composeA.treasure_id)
        local treasureB = treasure_info.get(composeB.treasure_id)
        if treasureA.type ~=  treasureB.type then
            if treasureA.type == 3 or treasureB.type == 3 then  --3 表示经验宝物
                return treasureA.type > treasureB.type
            end
        end
        if treasureA.quality ~= treasureB.quality then
            return treasureA.quality > treasureB.quality
        end
        
        --防御型号<攻击型
        if treasureA.type ~= treasureB.type then
            return treasureA.type < treasureB.type
        end
        return treasureA.id < treasureB.id
    end
    table.sort(composeListIndex,sortFunc)
    return composeList,composeListIndex
end

-- 获取可以被熔炼的宝物列表：
-- 可熔炼的宝物条件：1. 橙色  2. 未强化和精炼  3. 未穿在身上
function BagData:getTreasureSmeltMaterials()
    local smeltList = {}
    for i, v in ipairs(self.treasureList:getList()) do
        if not v:isWearing() then
            local info = treasure_info.get(v.base_id)
            if info.quality == BagConst.QUALITY_TYPE.ORANGE and v.level == 1 and v.refining_level == 0 then
                smeltList[#smeltList + 1] = v
            end
        end 
    end

    return smeltList
end

-- 获取任意一个可以被熔炼的宝物
-- 可熔炼的宝物条件：1. 橙色  2. 未强化和精炼  3. 未穿在身上
function BagData:getTreasureSmeltMaterial()
    for i, v in ipairs(self.treasureList:getList()) do
        if not v:isWearing() then
            local info = treasure_info.get(v.base_id)
            if info.quality == BagConst.QUALITY_TYPE.ORANGE and v.level == 1 and v.refining_level == 0 then
                return v
            end
        end 
    end

    return nil
end

--[[
    ownType 拥有司马法碎片的种类 
]]
function BagData:_checkTreasureForGuide(ownType)
    local _,list = self:getTreasureComposeList()
    if list == nil or #list == 0 then
        return false
    end
    local idNames = {"fragment_id_1","fragment_id_2","fragment_id_3","fragment_id_4","fragment_id_5","fragment_id_6",}
    local compose_id = list[1]
    if type(compose_id) ~= "number" or  compose_id ~= 101 then
        --非司马法
        return false
    end
    local compose = treasure_compose_info.get(compose_id)
    if not compose then
        return false
    end
    --拥有碎片种类
    local typeNum = 0
    --合成所需碎片数量
    local composeNum = 0
    for i,v in ipairs(idNames) do
        local fragmentId = compose[v]
        if fragmentId~= nil and fragmentId > 0 then
            composeNum = composeNum + 1
            local fragment = G_Me.bagData.treasureFragmentList:getItemByKey(fragmentId)
            if fragment ~= nil and fragment["num"]>0 then
                typeNum = typeNum + 1
            end 
        end
    end
    __Log("合成所需数量=%s,拥有碎片种类=%s",composeNum,typeNum)
    return composeNum == 3 and typeNum == ownType
end

--[[
    判断第一个为司马法，且已经有2片了。
    司马法Id为 101
    引导时检查碎片,首先,必须是3个碎片合成的宝物,并且只有2种类碎片
    true 只有2种
]]
function BagData:checkFragmentForGuide()
   return self:_checkTreasureForGuide(2)
end

--[[
    检查司马法
    判断第一个为司马法，且有3片了
]]
function BagData:checkSiMaFaForGuide( ... )
    -- body
    return self:_checkTreasureForGuide(3)
end

---------------获取数量 END--------------------


---检查是否有武将碎片可以合成了
function BagData:CheckKnightFragmentCompose()
    local list = self:getKnightFragmentList()
    for i,v in ipairs(list) do
        local fragment = fragment_info.get(v["id"])
        if v["num"] >= fragment.max_num  and v["num"] < fragment.max_num * 2 then
            return true
        end
    end
    return false
end

---检查是否有装备碎片可以合成了
function BagData:CheckEquipmentFragmentCompose()
    local list = self:getEquipmentFragmentList()
    for i,v in ipairs(list) do
        local fragment = fragment_info.get(v["id"])
        if v["num"] >= fragment.max_num and v["num"] < fragment.max_num * 2 then
            return true
        end
    end
    return false
end

---检查是否有宠物碎片可以合成了
function BagData:CheckPetFragmentCompose()
    local list = self:getPetFragmentList()
    for i,v in ipairs(list) do
        local fragment = fragment_info.get(v["id"])
        if v["num"] >= fragment.max_num then
            return true
        end
    end
    return false
end

---检查是否有宝物可以合成了
function BagData:CheckTreasureFragmentCompose()
    -- 遍历宝物合成表
    for i = 1, treasure_compose_info.getLength() do
        local composeInfo = treasure_compose_info.indexOf(i)
        local canCompose = true

        -- 遍历一项合成所需的碎片列表,碎片ID最多有8个
        for fragIndex = 1, 8 do
            local needId = composeInfo["fragment_id_" .. fragIndex]

            --有某一个碎片缺失，该项不能合成
            if needId ~= 0 and self:getTreasureFragmentNumById(needId) == 0 then
                canCompose = false
                break
            end
        end

        if canCompose then
            --所有碎片都有，能合成，返回true
            return true
        end
    end

    return false
end

-- [[=================觉醒道具=================]]

function BagData:addToAwakenList(item)
    self.awakenList:addItem(item)
end

function BagData:updateAwakenList(item)
    self.awakenList:updateItem(item)
end

function BagData:removeFromAwakenList(id)
    self.awakenList:removeItemByKey(id)
end

function BagData:containAwakenItem(id)
    
    local items = self.awakenList:getList()
    
    for i=1, #items do
        local item = items[i]
        if item.id == id then
            return true
        end
    end
    
    return false
end

function BagData:getAwakenItemNumById(id)
    
    local items = self.awakenList:getList()
    
    for i=1, #items do
        local item = items[i]
        if item.id == id then
            return item.num
        end
    end
    
    return 0
    
end

-- 返回最多能合成expectNum  只往下找2层
function BagData:awakenItemCanBeFastComposed(itemId, expectNum)
    -- 需要考虑同一个道具被不同道具合成需要  用一个table记录每个道具需要的数目
    local arr = {}
    local totalMoney = 0
    local noMoney = false 
    local function _canBeComposed(_itemId, _expectNum ,depth)

        local num = self:getAwakenItemNumById(_itemId)
        if depth == 1 then 
            arr = {}
            totalMoney = 0
            noMoney = false 
            -- depth为1的时候不考虑现有多少道具
            num = 0
        else 
            -- 处理多个地方需要同一个道具的情况  如果已经有记录了则增加
            if arr[_itemId] then 
                _expectNum = _expectNum + arr[_itemId]
            else 
                arr[_itemId] = 0
            end 
            arr[_itemId] = arr[_itemId] + _expectNum
            if num >= _expectNum then
                return true
            end
        end 

        local itemInfo = item_awaken_info.get(_itemId)
        -- 不可被合成的道具自然是不行了   到了第三步还不够就不往下看了
        if itemInfo.compose_id == 0 or depth == 3 then
            return false
        end
        local itemComposeInfo = item_awaken_compose.get(itemInfo.compose_id)

        -- 判断银两是否足够
        totalMoney = totalMoney + itemComposeInfo.compose_cost * _expectNum
        if totalMoney > G_Me.userData.money then 
            noMoney = true
            return false 
        end 

        -- 最多4个部件合成
        for i=1, 4 do
            local composePartId = itemComposeInfo["compose_part_"..i]
            if composePartId ~= 0 then
                -- 递归检查子道具是否可被合成
                local canBe = _canBeComposed(composePartId, itemComposeInfo["compose_num_"..i] * _expectNum - num ,depth + 1)
                if not canBe then
                    return false
                end
            end
        end
        -- 部件都返回true才行
        return true
    end

    -- 能满足多少是多少,所以从大到小循环
    for i=expectNum,1,-1 do
        if _canBeComposed(itemId, i , 1) then 
            return i
        end
    end
    if noMoney then return -1 end 
    return 0
end


function BagData:awakenItemCanBeComposed(itemId, expectNum)

    local function _canBeComposed(_itemId, _expectNum)
        
        -- 如果数量够了，表示可以合成
        if self:getAwakenItemNumById(_itemId) >= _expectNum then
            return true
        end
        
        -- 否则我们再看其是否可以被合成
        local itemInfo = item_awaken_info.get(_itemId)
        assert(itemInfo, "Could not find the awaken item with id: "..tostring(_itemId))
        
        -- 不可被合成的道具自然是不行了
        if itemInfo.compose_id == 0 then
            return false
        end

        local itemComposeInfo = item_awaken_compose.get(itemInfo.compose_id)
        assert(itemComposeInfo, "Could not find the awaken item with id: "..itemInfo.compose_id)
        
        -- 最多4个部件合成
        for i=1, 4 do
            local composePartId = itemComposeInfo["compose_part_"..i]
            if composePartId ~= 0 then
                -- 递归检查子道具是否可被合成, 注意这里子道具合成父道具只是合成一个父道具，所以要把期望数量=期望父道具数量*单个子道具期望数量才对
                local canBe = _canBeComposed(composePartId, itemComposeInfo["compose_num_"..i] * _expectNum)
                if not canBe then
                    return false
                end
            end
        end
        
        return true
    end
    
    return _canBeComposed(itemId, expectNum)
    
end

-- [[=================武将/装备回收=================]]

function BagData:hasKnightToRecycle()

    local _knights = {}
    local knightList = self.knightsData:getKnightsList()
    
    for key, knight in pairs(knightList) do
        -- 绿将和蓝将（大于8小于18）且未上阵
        local knightConfig = knight_info.get(knight.base_id)
        if knightConfig.potential > 8 and knightConfig.potential < 18 and
            G_Me.formationData:getKnightTeamId(knight.id) == 0 then
            _knights[#_knights+1] = knight
        end
    end
    
    return #_knights >= 5
    
end

function BagData:hasEquipmentToRecycle()

    local _equipments = {}
    local equipmentList = self:getNotWearEquipmentList()
    
    for i=1, #equipmentList do
        local equipment = equipmentList[i]
        local equipmentConfig = equipment_info.get(equipment.base_id)
        -- 取绿装和蓝装的统计
        if equipmentConfig.potentiality >= 12 and equipmentConfig.potentiality <= 13 then
            _equipments[#_equipments+1] = equipment
        end
    end
    
    return #_equipments >= 5
    
end

-- 判断称号是否处于过期状态
function BagData:isTitleOutOfDate( titleId )
    local ret = true

    local activeTitleList = G_Me.userData.title_list

    for i, v in pairs(activeTitleList) do 
        if v.id == titleId and G_ServerTime:getLeftSeconds(v.time) > 0 then
            ret = false
        end
    end

    return ret
end

-- 检查是否有称号可激活
function BagData:hasTitleToActivate( ... )
    local ret = false

    local titleItemList = {}
    local activeTitleList = G_Me.userData.title_list


    local propList = self.propList:getList()
    for i, v in pairs(propList) do
        local item = item_info.get(v.id)
        if item.item_type == 24 then
            -- 多个同一种道具
            require ("app.cfg.title_info")
            local titleInfo = title_info.get(item.item_value) 
            -- TODO: 暂时屏蔽第三种类型的道具
            -- if titleInfo.type1 ~= 3 then
            table.insert(titleItemList, item)  
            -- end                     
        end
    end

    -- 如果该道具对应的称号已被激活，则不给提示
    for x, y in pairs(activeTitleList) do 
        for j, k in pairs(titleItemList) do 
            if k.item_value == y.id and G_ServerTime:getLeftSeconds(y.time) > 0 then  
                table.remove(titleItemList, j)
            end
        end
    end

    ret = #titleItemList > 0

    -- __Log("BagData:hasTitleToActivate %d", #titleItemList)

    return ret
end

return BagData
