local HandlerBase = require("app.network.message.HandlerBase")
local BagHandler = class("BagHandler",HandlerBase)
local BagConst = require("app.const.BagConst")
function BagHandler:ctor(...)
    
end

function BagHandler:initHandler( ... )
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetItem, self._recvItemsMsg, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetFragment, self._recvFragmentMsg, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetEquipment, self._recvEquipmentMsg, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_UseItem, self._recvUseItemMsg, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Sell, self._recvSellMsg, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetTreasureFragment, self._recvTreasureFragmentMsg, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetTreasure, self._recvTreasureMsg, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_OpObject, self._recvOpObjectMsg, self)
    --碎片合成
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FragmentCompound, self._revFragmentCompoundMsg, self)

    --礼品码
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GiftCode, self._revGiftCode, self)
    
    -- 觉醒道具
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetAwakenItem, self._revAwakenItem, self)
    -- 合成觉醒道具
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ComposeAwakenItem, self._revComposeAwakenItem, self)
    -- 装备觉醒道具
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_PutonAwakenItem, self._revPutonAwakenItem, self)
    -- 觉醒武将
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_AwakenKnight, self._revAwakenKnight, self)

    -- 碎片出售
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FragmentSale, self._recvSellFragmentMsg, self)

    -- 道具合成
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ItemCompose, self._recvItemComposeMsg, self)
    -- 一键合成觉醒道具
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FastComposeAwakenItem, self._revFastComposeAwakenItem, self)
end

--腾讯礼包
function BagHandler:sendTencentAward(awardId,serverId)
    local Awards = {
        award_id = awardId,
        server_id = serverId
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetTencentReward", Awards) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetTencentReward, msgBuffer)
end


-- 获取背包数据
function BagHandler:_recvItemsMsg( msgId, msg, len)
    local buff = self:_decodeBuf("cs.S2C_GetItem", msg, len)
    if type(buff) ~= "table" then 
        return 
    end
    if type(buff.items) ~= "table" then
        __LogError("_recvItemsMsg data error ")
        return 
    end
    self:_onGetBagProp(buff.items)
end

function BagHandler:_recvFragmentMsg(msgId, msg, len)
    local buff = self:_decodeBuf("cs.S2C_GetFragment", msg, len)
    if type(buff) ~= "table" then 
        return 
    end
    if type(buff.fragments) ~= "table" then
        __LogError("_recvFragmentMsg data error ")
        return 
    end
    self:_onGetBagFragment(buff.fragments)
end

--获取宝物碎片
function BagHandler:_recvTreasureFragmentMsg(msgId, msg, len)
    local buff = self:_decodeBuf("cs.S2C_GetTreasureFragment", msg, len)
    if type(buff) ~= "table" then 
        return 
    end
    --dump(buff)
    if type(buff.treasure_fragments) ~= "table" then
        __LogError("_recvTreasureFragmentMsg data error ")
        return 
    end
    self:_onGetTreasureFragment(buff.treasure_fragments)
end

--获取宝物
function BagHandler:_recvTreasureMsg(msgId, msg, len)
    local buff = self:_decodeBuf("cs.S2C_GetTreasure", msg, len)
    if type(buff) ~= "table" then 
        return 
    end
    if type(buff.treasures) ~= "table" then
        __LogError("_recvTreasureMsg data error ")
        return 
    end
    self:_onGetTreasure(buff.treasures)
end


function BagHandler:_recvEquipmentMsg(msgId, msg, len)
    local buff = self:_decodeBuf("cs.S2C_GetEquipment", msg, len)
    if type(buff) ~= "table" then 
        return 
    end
    if type(buff.equipments) ~= "table" then
        __LogError("_recvFragmentMsg data error ")
        return 
    end
    self:_onGetBagEquipment(buff.equipments)

end


function BagHandler:_onGetBagProp(data)
    if data == nil then
        return
    end
    for i,v in ipairs(data) do 
        G_Me.bagData:addToPropList(v)
    end
    G_Me.bagData:sortPropList()
end

 
function BagHandler:_onGetBagFragment(data)
    --__LogTag(TAG,"BagHandler:_onGetBagFragment")
    if data == nil then
        return
    end
    for i,v in ipairs(data) do 
        --__LogTag(TAG,"v.id = %d,v.num = %s",v.id,v.num)
        G_Me.bagData:addToFragmentList(v)
    end
    G_Me.bagData:sortFragmentList()
end

function BagHandler:_onGetBagEquipment(data)
    --__LogTag(TAG,"BagHandler:_onGetBagEquipment")
    if data == nil then
        return
    end
    for i,v in ipairs(data) do 
        G_Me.bagData:addToEquipmentList(v)
    end
    
    G_Me.bagData:sortEquipmentList()

    -- 更新下装备的幸运值信息（如果日期不同则清零）
    G_Me.equipmentData:resetLuckData()
end

function BagHandler:_onGetTreasureFragment(data)
    --__LogTag(TAG,"BagHandler:_onGetBagEquipment")
    if data == nil then
        return
    end
    for i,v in ipairs(data) do 
        G_Me.bagData:addToTreasureFragmentList(v)
    end
    G_Me.bagData:sortTreasureFragmentList()
end

function BagHandler:_onGetTreasure(data)
    --__LogTag(TAG,"BagHandler:_onGetBagEquipment")
    if data == nil then
        return
    end
    for i,v in ipairs(data) do 
        G_Me.bagData:addToTreasureList(v)
    end
    G_Me.bagData:sortTreasureList()    
end

--发送使用道具消息
function BagHandler:sendUseItemInfo(item_id, index, useNum)
    --使用之前先检查
    local CheckFunc = require("app.scenes.common.CheckFunc")
    if CheckFunc.checkBeforeUseItem(item_id) then
        -- __Log("[BagHandler:sendUseItemInfo] CheckFunc.checkBeforeUseItem(item_id)")
        return
    end
    local UseItemInfo = {
        id = item_id,
    }
    if index then
        UseItemInfo.index = index
    end
    if useNum then
        UseItemInfo.num = useNum
    end
   -- __LogTag(TAG,"BagHandler:sendUseItemInfo")
    local msgBuffer = protobuf.encode("cs.C2S_UseItem", UseItemInfo) 
    self:sendMsg(NetMsg_ID.ID_C2S_UseItem, msgBuffer)
end

-- 接收使用道具消息
function BagHandler:_recvUseItemMsg( msgId, msg, len)
    local buff = self:_decodeBuf("cs.S2C_UseItem", msg, len)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVNET_BAG_USE_ITEM, nil, false, buff)
end


function BagHandler:_recvOpObjectMsg(msgId, msg, len)
    local buff = self:_decodeBuf("cs.S2C_OpObject", msg, len)
    if rawget(buff, "equipment") ~= nil then
        __LogTag(TAG,"equipment changed")
        self:_equipmentDataChange(buff.equipment)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, nil, false,BagConst.CHANGE_TYPE.EQUIPMENT,buff)
    end
    if rawget(buff, "knight") ~= nil then
        __LogTag(TAG,"knight changed")
        self:_knightDataChange(buff.knight)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, nil, false,BagConst.CHANGE_TYPE.KNIGHT,buff)
    end
    if rawget(buff, "item") ~= nil then
        __LogTag(TAG,"item changed")
        self:_propDataChange(buff.item)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, nil, false,BagConst.CHANGE_TYPE.PROP,buff)
    end
    if rawget(buff, "fragment") ~= nil then
        __LogTag(TAG,"fragment changed")
        self:_fragmentDataChange(buff.fragment)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, nil, false,BagConst.CHANGE_TYPE.FRAGMENT,buff)
    end
    if rawget(buff, "treasure_fragment") ~= nil then
        __LogTag(TAG,"treasure fragment changed")
        self:_treasureFragmentDataChange(buff.treasure_fragment)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, nil, false,BagConst.CHANGE_TYPE.TREASURE_FRAGMENT,buff)
    end
    if rawget(buff, "treasure") ~= nil then
        __LogTag(TAG,"treasure changed")
        self:_treasureDataChange(buff.treasure)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, nil, false,BagConst.CHANGE_TYPE.TREASURE,buff)
    end
    if rawget(buff, "dress") ~= nil then
        __LogTag(TAG,"dress changed")
        dump(buff.dress)
        self:_dressDataChange(buff.dress)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, nil, false,BagConst.CHANGE_TYPE.DRESS,buff)
    end
    if rawget(buff, "awaken_item") ~= nil then
        __LogTag(TAG,"awaken_item changed")
        -- dump(buff.awaken_item)
        self:_awakenItemDataChange(buff.awaken_item)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, nil, false,BagConst.CHANGE_TYPE.AWAKEN_ITEM,buff)
    end
    if rawget(buff, "pet") ~= nil then
        __LogTag(TAG,"pet changed")
        dump(buff.pet)
        self:_petDataChange(buff.pet)
        --
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, nil, false, BagConst.CHANGE_TYPE.PET, buff)
    end
    if rawget(buff, "ksoul") ~= nil then
        G_Me.heroSoulData:updateSoulNum(buff.ksoul)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, nil, false, BagConst.CHANGE_TYPE.HERO_SOUL)
    end
end

--装备变化
function BagHandler:_equipmentDataChange(data)
    if rawget(data, "insert_equipments") then
        for i,v in ipairs(data.insert_equipments) do
            G_Me.bagData:addToEquipmentList(v)
        end
        G_Me.bagData:sortEquipmentList()

        G_HandlersManager.fightResourcesHandler:checkEffectEquip(1, "insert_equipments")
    end
    
    if rawget(data, "update_equipments") then
        for i,v in ipairs(data.update_equipments) do
            G_Me.bagData:updateEquipmentList(v)
        end
    end
    
    if rawget(data, "delete_equipments") then
        for i,v in ipairs(data.delete_equipments) do
            --这里v是Id
            G_Me.bagData:removeFromEquipmentList(v)
        end

        G_HandlersManager.fightResourcesHandler:checkEffectEquip(1, "delete_equipments")
    end
end
--道具变化
function BagHandler:_propDataChange(data)
--    if data.insert_items ~= nil then 
    if rawget(data, "insert_items") then
        for i,v in ipairs(data.insert_items) do
            G_Me.bagData:addToPropList(v)
        end
        G_Me.bagData:sortPropList()
    end
    
--    if data.update_items ~= nil then 
    if rawget(data, "update_items") then
        for i,v in ipairs(data.update_items) do
            G_Me.bagData:updatePropList(v)
        end
    end
    
--    if data.delete_items ~= nil then 
    if rawget(data, "delete_items") then
        for i,v in ipairs(data.delete_items) do
            --这里v是Id
            G_Me.bagData:removeFromPropList(v)
        end
    end
end
--knight变化
function BagHandler:_knightDataChange(data)
--    if data.insert_knights ~= nil then        
    if rawget(data, "insert_knights") then
        __LogTag(TAG,"_knightDataChange insert_knights")
        for i,v in ipairs(data.insert_knights) do
            G_Me.bagData.knightsData:addKnightToList(v)
        end
    G_Me.bagData.knightsData:sortKnights()
    end
    
--    if data.update_knights ~= nil then 
    if rawget(data, "update_knights") then
        __LogTag(TAG,"_knightDataChange update_knights")
        for i,v in ipairs(data.update_knights) do
            G_Me.bagData.knightsData:updateKnight(v)
        end
    end
    
--    if data.delete_knights ~= nil then 
    if rawget(data, "delete_knights") then
        __LogTag(TAG,"_knightDataChange delete_knights")
        for i,v in ipairs(data.delete_knights) do
           G_Me.bagData.knightsData:removeKnightByIndex(v)
        end
    end
end

--碎片变化
function BagHandler:_fragmentDataChange(data)
    
    if rawget(data,"insert_fragments") ~= nil then 
        __LogTag(TAG,"insert_fragments")
        for i,v in ipairs(data.insert_fragments) do
            G_Me.bagData:addToFragmentList(v)
        end
        G_Me.bagData:sortFragmentList()
    end
    
    if rawget(data,"update_fragments") ~= nil then 
        __LogTag(TAG,"update_fragments")
        for i,v in ipairs(data.update_fragments) do
            G_Me.bagData:updateFragmentList(v)
        end
        --因为数量变化了，60/50--->10/50 
        G_Me.bagData:sortFragmentList()
    end
    
    if rawget(data,"delete_fragments") ~= nil then 
        __LogTag(TAG,"delete_fragments")
        --dump(data.delete_fragments)
        for i,v in ipairs(data.delete_fragments) do
            --这里v是Id
            __LogTag(TAG,"delete_fragments----->")
            G_Me.bagData:removeFromFragmentList(v)
        end
        G_Me.bagData:sortFragmentList()
    end
end

--宝物碎片变化
function BagHandler:_treasureFragmentDataChange(data)
    if rawget(data,"insert_treasure_fragments") ~= nil then 
        __LogTag(TAG,"insert_treasure_fragments")
        for i,v in ipairs(data.insert_treasure_fragments) do
            G_Me.bagData:addToTreasureFragmentList(v)
        end
        G_Me.bagData:sortTreasureFragmentList()
    end
    
    if rawget(data,"update_treasure_fragments") ~= nil then 
        __LogTag(TAG,"update_treasure_fragments") 
        for i,v in ipairs(data.update_treasure_fragments) do
            G_Me.bagData:updateTreasureFragmentList(v)
        end
    end
    
    if rawget(data,"delete_treasure_fragments") ~= nil then 
        __LogTag(TAG,"delete_treasure_fragments")
        --dump(data.delete_treasure_fragments)
        for i,v in ipairs(data.delete_treasure_fragments) do
            --这里v是Id
            __LogTag(TAG,"delete_fragments----->")
            G_Me.bagData:removeTreasureFromFragmentList(v)
        end
    end
end

--宝物变化
function BagHandler:_treasureDataChange(data)
    -- dump(data)
    if rawget(data,"insert_treasures") ~= nil then 
        __LogTag(TAG,"insert_treasures")
        for i,v in ipairs(data.insert_treasures) do
            G_Me.bagData:addToTreasureList(v)
        end
        G_Me.bagData:sortTreasureList()

        G_HandlersManager.fightResourcesHandler:checkEffectEquip(5, "insert_treasures")
    end
    
    if rawget(data,"update_treasures") ~= nil then 
        __LogTag(TAG,"update_treasures")
        for i,v in ipairs(data.update_treasures ) do
            G_Me.bagData:updateTreasureList(v)
        end
    end
    
    if rawget(data,"delete_treasures") ~= nil then 
        __LogTag(TAG,"delete_treasures")
        --dump(data.delete_treasures)
        for i,v in ipairs(data.delete_treasures) do
            --这里v是Id
            __LogTag(TAG,"delete_treasures----->")
            G_Me.bagData:removeTreasureFromList(v)
        end

        G_HandlersManager.fightResourcesHandler:checkEffectEquip(5, "delete_treasures")
    end
end

--时装变化
function BagHandler:_dressDataChange(data)
    if rawget(data, "insert_dresses") then
        for i,v in ipairs(data.insert_dresses) do
            G_Me.dressData:addToDressList(v)
        end
    end
    
    if rawget(data, "update_dresses") then
        for i,v in ipairs(data.update_dresses) do
            G_Me.dressData:updateDressList(v)
        end
    end
    
    if rawget(data, "delete_dresses") then
        for i,v in ipairs(data.delete_dresses) do
            --这里v是Id
            G_Me.dressData:removeFromDressList(v)
        end
    end
end

function BagHandler:_awakenItemDataChange(data)
--    if data.insert_items ~= nil then 
    if rawget(data, "insert_items") then
        for i,v in ipairs(data.insert_items) do
            G_Me.bagData:addToAwakenList(v)
        end
    end
    
--    if data.update_items ~= nil then 
    if rawget(data, "update_items") then
        for i,v in ipairs(data.update_items) do
            G_Me.bagData:updateAwakenList(v)
        end
    end
    
--    if data.delete_items ~= nil then 
    if rawget(data, "delete_items") then
        for i,v in ipairs(data.delete_items) do
            --这里v是Id
            G_Me.bagData:removeFromAwakenList(v)
        end
    end
end

--pet变化
function BagHandler:_petDataChange(data) 
    if rawget(data, "insert_pets") then
        __LogTag(TAG,"_petDataChange insert_pets")
        for i,v in ipairs(data.insert_pets) do
            G_Me.bagData.petData:addPetToList(v)
        end
        G_Me.bagData.petData:sortPetList()
    end
    
    if rawget(data, "update_pets") then
        __LogTag(TAG,"_petDataChange update_pets")
        for i,v in ipairs(data.update_pets) do
            G_Me.bagData.petData:updatePet(v)
        end
    end
    
    if rawget(data, "delete_pets") then
        __LogTag(TAG,"_petDataChange delete_pets")
        for i,v in ipairs(data.delete_pets) do
           G_Me.bagData.petData:removePetById(v)
        end
    end
end


--发送出售消息
function BagHandler:sendSellMsg(objects)
    local Awards = {
        info = objects
    }
    local msgBuffer = protobuf.encode("cs.C2S_Sell", Awards) 
    self:sendMsg(NetMsg_ID.ID_C2S_Sell, msgBuffer)
end

-- 接收出售消息
function BagHandler:_recvSellMsg( msgId, msg, len)
    local buff = self:_decodeBuf("cs.S2C_Sell", msg, len)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVNET_BAG_SELL_RESULT, nil, false,buff)
end

-- 发送出售碎片的消息
function BagHandler:sendSellFragmentMsg( fragmentIds )
    local msg = {
        frgids = fragmentIds
    }
    local msgBuffer = protobuf.encode("cs.C2S_FragmentSale", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_FragmentSale, msgBuffer)
end

-- 接收碎片出售结果消息
function BagHandler:_recvSellFragmentMsg( msgId, msg, len )
    local message = self:_decodeBuf("cs.S2C_FragmentSale", msg, len)
    if type(message) ~= "table" then
        return
    end

    if message.ret == NetMsg_ERROR.RET_OK then
        -- uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_BAG_FRAGMENT_SELL_RESULT, nil, false, message)
        -- 与出售装备和武将结果统一处理
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVNET_BAG_SELL_RESULT, nil, false, message)
    end
end

--发送 装备碎片合成 num 为可选字段表示本次合成多少个
function BagHandler:sendFragmentCompoundMsg(_id, _num)
    if _num == nil or _num == 0 then
        _num = 1
    end
    local compound = {
        id = _id,
        num = _num
    }
    local msgBuffer = protobuf.encode("cs.C2S_FragmentCompound", compound) 
    self:sendMsg(NetMsg_ID.ID_C2S_FragmentCompound, msgBuffer)
end

function BagHandler:_revFragmentCompoundMsg(msgId, msg, len)
    local buff = self:_decodeBuf("cs.S2C_FragmentCompound", msg, len)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_BAG_FRAGMENT_COMPOUND, nil, false, buff)
end


--发送礼品码
function BagHandler:sendGiftCode(code)
    local code = {
        code = code
    }
    local msgBuffer = protobuf.encode("cs.C2S_GiftCode", code) 
    self:sendMsg(NetMsg_ID.ID_C2S_GiftCode, msgBuffer)
end

function BagHandler:_revGiftCode(msgId, msg, len)
    local buff = self:_decodeBuf("cs.S2C_GiftCode", msg, len)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GIFT_CODE_INFO, nil, false,buff)
end

-- 觉醒道具
function BagHandler:_revAwakenItem(msgId, msg, len)
    
    local message = self:_decodeBuf("cs.S2C_GetAwakenItem", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    
    if rawget(message, "awaken_items") then
        for i,v in ipairs(message.awaken_items) do 
            --__LogTag(TAG,"v.id = %d,v.num = %s",v.id,v.num)
            G_Me.bagData:addToAwakenList(v)
        end
    end
end

function BagHandler:sendComposeAwakenItem(itemId)
    
    local msgBuffer = protobuf.encode("cs.C2S_ComposeAwakenItem", {id=itemId}) 
    self:sendMsg(NetMsg_ID.ID_C2S_ComposeAwakenItem, msgBuffer)
    
end

function BagHandler:sendFastComposeAwakenItem(itemId , _num)
    -- print("send sendFastComposeAwakenItem")
    local msgBuffer = protobuf.encode("cs.C2S_FastComposeAwakenItem", {id=itemId,num=_num}) 
    self:sendMsg(NetMsg_ID.ID_C2S_FastComposeAwakenItem, msgBuffer)
    
end

function BagHandler:sendPutonAwakenItem(knightId, position, itemId)
    
    local msgBuffer = protobuf.encode("cs.C2S_PutonAwakenItem", {kid=knightId, pos=position, id=itemId}) 
    self:sendMsg(NetMsg_ID.ID_C2S_PutonAwakenItem, msgBuffer)
    
end

function BagHandler:sendAwakenKnight(mainKnightId, knightList)
    
    local msgBuffer = protobuf.encode("cs.C2S_AwakenKnight", {kid=mainKnightId, knight_list=knightList}) 
    self:sendMsg(NetMsg_ID.ID_C2S_AwakenKnight, msgBuffer)
    
end

function BagHandler:_revFastComposeAwakenItem(msgId, msg, len)
    -- print("rev _revFastComposeAwakenItem")
    dump(message)
    local message = self:_decodeBuf("cs.S2C_FastComposeAwakenItem", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FAST_AWAKEN_COMPOSE_ITEM_NOTI, nil, false, message)
    
end

function BagHandler:_revComposeAwakenItem(msgId, msg, len)
    
    local message = self:_decodeBuf("cs.S2C_ComposeAwakenItem", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_AWAKEN_COMPOSE_ITEM_NOTI, nil, false, message)
    
end

function BagHandler:_revPutonAwakenItem(msgId, msg, len)
    
    local message = self:_decodeBuf("cs.S2C_PutonAwakenItem", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_AWAKEN_PUTON_ITEM_NOTI, nil, false, message)
    
end

function BagHandler:_revAwakenKnight(msgId, msg, len)
    
    local message = self:_decodeBuf("cs.S2C_AwakenKnight", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_AWAKEN_KNIGHT_NOTI, nil, false, message)
    
end

function BagHandler:sendItemCompose( itemIdx )
    local msgBuffer = protobuf.encode("cs.C2S_ItemCompose", {index = itemIdx})
    self:sendMsg(NetMsg_ID.ID_C2S_ItemCompose, msgBuffer)
end

function BagHandler:_recvItemComposeMsg( msgId, msg, len )
    local message = self:_decodeBuf("cs.S2C_ItemCompose", msg, len)
    if type(message) ~= "table" then
        return
    end
    if message.ret == NetMsg_ERROR.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ITEM_COMPOSE_RESULT, nil, false, message)
    end
end

return BagHandler
