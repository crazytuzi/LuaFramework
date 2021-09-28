local CheckFunc = {}
require("app.cfg.item_info")
require("app.cfg.basic_figure_info")
require("app.cfg.role_info")
--[[
	使用体力丹(大,小)时
	判断是否超出上线
]]
function CheckFunc.checkVitByItemId(itemId)
	local item = item_info.get(itemId)
	local max = basic_figure_info.get(1).max_limit
	return (G_Me.userData.vit + item.item_value) > max
end

--领取精力时
function CheckFunc.checkSpiritFromFriend()
    local max = basic_figure_info.get(2).time_limit
    return (G_Me.userData.spirit + 1) > max
end

--[[
	使用精力力丹(大,小)时
	判断是否超出上线
]]
function CheckFunc.checkSpiritByItemId(itemId)
	local item = item_info.get(itemId)
	local max = basic_figure_info.get(2).max_limit
	return (G_Me.userData.spirit + item.item_value) > max
end


--[[
	检查是否处于免战时间
]]
function CheckFunc.checkForbiddenBattle( ... )
	local leftTime = G_ServerTime:getLeftSeconds(G_Me.userData.forbid_battle_time)
	return leftTime > 0
end


--[[
	判断武将包裹是否满了
]]

function CheckFunc.checkKnightFull(scenePack)
    local isFull = G_Me.bagData:isKnightFull()
    if isFull then
        require("app.scenes.bag.BagFullDialogForKnightAndTreasure").show(G_Goods.TYPE_KNIGHT, scenePack)
    end
	return isFull
end

--[[
	判断装备包裹是否满了
]]
function CheckFunc.checkEquipmentFull(scenePack)
    local isFull = G_Me.bagData:isEquipmentFull()
    if isFull then
        require("app.scenes.bag.BagFullDialog").show(G_Goods.TYPE_EQUIPMENT, scenePack)
    end
	return isFull
end

--[[
	判断宝物包裹是否满了
]]
function CheckFunc.checkTreasureFull(scenePack)
    local data = role_info.get(G_Me.userData.level)
    if not data then
        --已经满了
        return true
    end
    -- 1.7.0版本开始，根据VIP等级增加相应容量
    local vipExtrNum = G_Me.vipData:getData(require("app.const.VipConst").TREASUREBAGVIPEXTRA).value
    if vipExtrNum < 0 or type(vipExtrNum) ~= "number" then vipExtrNum = 0 end
	local max = data.treasure_bag_num_client + vipExtrNum
    local isFull = G_Me.bagData.treasureList:getCount() >= max

    if isFull then
        require("app.scenes.bag.BagFullDialogForKnightAndTreasure").show(G_Goods.TYPE_TREASURE, scenePack)
    end
	return isFull
end

--[[
    判断战宠包裹是否满了
]]
function CheckFunc.checkPetFull()
    local isFull = G_Me.bagData:isPetFull()
    if isFull then
        require("app.scenes.bag.BagFullDialog").show(G_Goods.TYPE_PET)
    end
    return isFull
end



function CheckFunc.checkBagFullByType(_type, scenePack)
    if _type == nil or type(_type) ~= "number" then
        assert("传入类型不对")
        return true
    end
    if _type == G_Goods.TYPE_KNIGHT then              --武将
        return CheckFunc.checkKnightFull(scenePack)
    elseif _type == G_Goods.TYPE_EQUIPMENT then       --装备
        return CheckFunc.checkEquipmentFull(scenePack)
    elseif _type == G_Goods.TYPE_TREASURE then        --宝物
        return CheckFunc.checkTreasureFull(scenePack)
    elseif _type == G_Goods.TYPE_PET then             --宠物
        return CheckFunc.checkPetFull()
    end 
    --[[
        其他类型无上限
    ]]
    return false
end

--使用道具之前判断某个包裹是否满了
function CheckFunc.checkBeforeUseItem(item_id, scenePack)
    if not item_id or type(item_id) ~= "number" then
        return false
    end
    require("app.cfg.item_info")
    local item = item_info.get(item_id)
    --礼包类item_type = 1
    if not item or item.item_type ~= 1 then
        return false
    end

    return CheckFunc.checkBagWithDropId(item.item_value, scenePack)
end

function CheckFunc.checkBagWithDropId(drop_id, scenePack)
    if not drop_id or type(drop_id) ~= "number" then
        return false
    end

    require("app.cfg.drop_info")
    local drop = drop_info.get(drop_id)
    if not drop then
        return false
    end

    --将掉落库里的所有道具读出来,不管是全掉落还是N选1
    local index = 1
    local type_key = string.format("type_%d",index)

    local _typeList = {}
    while drop_info.hasKey(type_key) do
        table.insert(_typeList,G_Drops.convertType(drop[type_key]))
        index = index + 1
        type_key = string.format("type_%d",index)
    end
    for i,v in ipairs(_typeList) do
        local isFull = CheckFunc.checkBagFullByType(v, scenePack)
        if isFull then
            return true
        end
    end
    return false

end


--购买前检查 包裹

--[[
	_type:类型
	addNum :要增加的数量
]]
function CheckFunc.checkDiffByType(_type,addNum,scenePack)
    if _type == nil or type(_type) ~= "number" then
        assert("传入类型不对")
        return true
    end
    if not addNum or type(addNum) ~= "number" then
        addNum = 1
    end
    local data = role_info.get(G_Me.userData.level)
    if not data then
        return false
    end

    if _type == G_Goods.TYPE_KNIGHT then              --武将
    	local num = G_Me.bagData.knightsData:getKnightCount()
        -- 1.7.0版本开始，根据VIP等级增加相应容量
        local vipExtrNum = G_Me.vipData:getData(require("app.const.VipConst").KNIGHTBAGVIPEXTRA).value
        if vipExtrNum < 0 or type(vipExtrNum) ~= "number" then vipExtrNum = 0 end
    	local maxNum = data.knight_bag_num_client + vipExtrNum
        if num + addNum > maxNum then
            require("app.scenes.bag.BagFullDialogForKnightAndTreasure").show(_type, scenePack)
        end
        return num+addNum > maxNum
    elseif _type == G_Goods.TYPE_EQUIPMENT then       --装备
    	local num = G_Me.bagData.equipmentList:getCount()
    	local maxNum = data.equipment_bag_num_client
        if num + addNum > maxNum then
            require("app.scenes.bag.BagFullDialog").show(_type, scenePack)
        end
        return num+addNum > maxNum
    elseif _type == G_Goods.TYPE_TREASURE then        --宝物
    	local num = G_Me.bagData.treasureList:getCount()
        -- 1.7.0版本开始，根据VIP等级增加相应容量
        local vipExtrNum = G_Me.vipData:getData(require("app.const.VipConst").TREASUREBAGVIPEXTRA).value
        if vipExtrNum < 0 or type(vipExtrNum) ~= "number" then vipExtrNum = 0 end
    	local maxNum = data.treasure_bag_num_client + vipExtrNum
        if num + addNum > maxNum then
            require("app.scenes.bag.BagFullDialogForKnightAndTreasure").show(_type)
        end
        return num+addNum > maxNum
    end 

    return false
end

--检查是否有宝物碎片可以合成
function CheckFunc.checkTreasureComposeEnabled()
    require("app.cfg.treasure_compose_info")
    require("app.cfg.treasure_fragment_info")
    local composeList = {}
    local idNames = {"fragment_id_1","fragment_id_2","fragment_id_3","fragment_id_4","fragment_id_5","fragment_id_6",}
    local list = G_Me.bagData.treasureFragmentList:getList()
    for i,v in ipairs(list)do
        local fragmentInfo = treasure_fragment_info.get(v.id)
        if not fragmentInfo then
            return false
        end
        local compose = treasure_compose_info.get(fragmentInfo.compose_id)
        if not compose then
            return false
        end
        if composeList[fragmentInfo.compose_id] == nil then
            composeList[fragmentInfo.compose_id] = compose
            --检查一遍
            local fragmentIdList = {}
            for k,n in ipairs(idNames) do
                local fragmentId = compose[n]
                if fragmentId ~= 0  then
                   fragmentIdList[#fragmentIdList+1] = fragmentId
                end
            end
            if CheckFunc.checkFragmentEnough(fragmentIdList) then
                return true
            end
        end
    end
    return false
end

--检查碎片是否足够合成
function CheckFunc.checkFragmentEnough(_fragmentIdList)
   if _fragmentIdList == nil or #_fragmentIdList == 0 then
        return false
   end
   for i,v in ipairs(_fragmentIdList) do
        local fragment = G_Me.bagData.treasureFragmentList:getItemByKey(v)
        if fragment == nil or fragment["num"]==0 then
            return false
        end 
   end
   return true
end

--[[
    检查是composeId是否可合成
]]

function CheckFunc.checkTreasureComposeByComposeId(compose_id)
    require("app.cfg.treasure_compose_info")
    local idNames = {"fragment_id_1","fragment_id_2","fragment_id_3","fragment_id_4","fragment_id_5","fragment_id_6",}
    require("app.cfg.treasure_fragment_info")
    local compose = treasure_compose_info.get(compose_id)
    local idList = {}
    for i,v in ipairs(idNames)do
        if compose[v] > 0 then
            table.insert(idList,compose[v])
        end
    end
    return CheckFunc.checkFragmentEnough(idList)
end

--[[
    检查某一类型的宝物是否有碎片，用于夺宝
]]
function CheckFunc.checkTreasureFragmentExist(_treasureId)
    require("app.cfg.treasure_compose_info")
    require("app.cfg.treasure_info")
    local treasure = treasure_info.get(_treasureId)
    local compose = treasure_compose_info.get(treasure.compose_id)
    local i = 0
    local key = ""
    repeat 
        i = i + 1
        key = string.format("fragment_id_%s",i)
        local fragment_id = compose[key]
        if G_Me.bagData.treasureFragmentList:getItemByKey(fragment_id) ~= null then
            return true
        end
    until compose[key] == nil or compose[key] == 0
    return false
end

function CheckFunc.checkVipGiftbagEnabled()
    --检查是否进入过vipshop
    if not G_Me.shopData:checkEnterScoreShop() then
        return false
    end
    require("app.cfg.shop_score_info")
    require("app.const.ShopType")
    for i=1, shop_score_info.getLength() do
        local v = shop_score_info.indexOf(i)
        if v.shop == SCORE_TYPE.VIP and v.tab == 2 then
            local purchaseEnabled= G_Me.shopData:checkGiftItemPurchaseEnabled(v)
            --表示未购买过
            if purchaseEnabled == true then
                --再判断vip等级，这表配的真操蛋
                local vip = -1
                repeat 
                    vip = vip+1
                    key =string.format("vip%s_num",vip)
                until v[key] ~= nil and v[key] >0
                vip = vip>=0 and vip or 0
                if vip <= G_Me.userData.vip then
                    return true
                end
            end
        end
    end
    return false
end

return CheckFunc

