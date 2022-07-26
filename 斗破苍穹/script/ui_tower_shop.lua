require"Lang"
UITowerShop = { }

local SCROLLVIEW_ITEM_SPACE = 5

local ui_scrollView = nil
local ui_svItem = nil

local _titleTabButton = nil
local _tag = nil

local function cleanScrollView(_isRelease)
    if _isRelease then
        if ui_svItem and ui_svItem:getReferenceCount() >= 1 then
            ui_svItem:release()
            ui_svItem = nil
        end
        if ui_scrollView then
            ui_scrollView:removeAllChildren()
            ui_scrollView = nil
        end
    else
        if ui_svItem:getReferenceCount() == 1 then
            ui_svItem:retain()
        end
        ui_scrollView:removeAllChildren()
    end
end

local function layoutScrollView(_listData, _initItemFunc)
    cleanScrollView()
    utils.updateScrollView(UITowerShop, ui_scrollView, ui_svItem, _listData, _initItemFunc, { space = SCROLLVIEW_ITEM_SPACE })
end

local function netCallbackFunc(msgData)
    UITowerShop.setup()
    local image_basemap = UITowerShop.Widget:getChildByName("image_basemap")
    local btn_reward = image_basemap:getChildByName("btn_reward")
    if _titleTabButton == btn_reward then
        UIManager.showToast(Lang.ui_tower_shop1)
    else
        UIManager.showToast(Lang.ui_tower_shop2)
    end
    UITowerTest.refreshFire()
end

local function sendPackage(_id)
    local sendData = {
        header = StaticMsgRule.store,
        msgdata =
        {
            int =
            {
                instPlayerPagodaId = net.InstPlayerPagoda.int["1"],
                dictPagodaStoreId = _id,
                num = 1
            }
        }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end

function UITowerShop.init()
    local image_basemap = UITowerShop.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    btn_close:setPressedActionEnabled(true)
    btn_close:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
            UIManager.flushWidget(UITowerTest)
        end
    end )
    ui_scrollView = image_basemap:getChildByName("view_award_lv")
    ui_svItem = ui_scrollView:getChildByName("image_base_good"):clone()
end

function UITowerShop.setup()
    local image_basemap = UITowerShop.Widget:getChildByName("image_basemap")
    local fireCount = image_basemap:getChildByName("image_fire_all"):getChildByName("text_number")
    fireCount:setString(tostring(net.InstPlayer.int["21"]))

    if not UITowerShop.isFlush or not UITowerShop.storeData then
        local storeData = { }
        -- 1-紫装 2-橙装 3-奖励
        for key, obj in pairs(DictPagodaStore) do
            if not storeData[obj.type] then
                storeData[obj.type] = { }
            end
            storeData[obj.type][#storeData[obj.type] + 1] = obj
        end
        for i = 1, 3 do
            if i == 3 then
                utils.quickSort(storeData[i], function(obj1, obj2) if obj1.pagodaStoreyId > obj2.pagodaStoreyId then return true end end)
            else
                utils.quickSort(storeData[i], function(obj1, obj2) if utils.getThingCount(DictThing[tostring(obj1.tableFieldId)].id) < utils.getThingCount(DictThing[tostring(obj2.tableFieldId)].id) then return true end end)
            end
        end

        UITowerShop.storeData = storeData
    end

    local _prevUIBtn = nil
    local btn_purple = image_basemap:getChildByName("btn_purple")
    local btn_orange = image_basemap:getChildByName("btn_orange")
    local btn_reward = image_basemap:getChildByName("btn_reward")
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if _prevUIBtn == sender then
                return
            end
            _prevUIBtn = sender
            local _index = 1
            sender:loadTextures("ui/yh_btn02.png", "ui/yh_btn02.png")
            if sender == btn_purple then
                _index = 1
                sender:getChildByName("text_purple"):setTextColor(cc.c4b(51, 25, 4, 255))
                btn_orange:getChildByName("text_orange"):setTextColor(cc.c4b(255, 255, 255, 255))
                btn_orange:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
                btn_reward:getChildByName("text_reward"):setTextColor(cc.c4b(255, 255, 255, 255))
                btn_reward:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
            elseif sender == btn_orange then
                _index = 2
                sender:getChildByName("text_orange"):setTextColor(cc.c4b(51, 25, 4, 255))
                btn_purple:getChildByName("text_purple"):setTextColor(cc.c4b(255, 255, 255, 255))
                btn_purple:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
                btn_reward:getChildByName("text_reward"):setTextColor(cc.c4b(255, 255, 255, 255))
                btn_reward:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
            elseif sender == btn_reward then
                _index = 3
                sender:getChildByName("text_reward"):setTextColor(cc.c4b(51, 25, 4, 255))
                btn_purple:getChildByName("text_purple"):setTextColor(cc.c4b(255, 255, 255, 255))
                btn_purple:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
                btn_orange:getChildByName("text_orange"):setTextColor(cc.c4b(255, 255, 255, 255))
                btn_orange:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
            end
            ui_svItemButton = nil

            if not UITowerShop.isFlush then
                if _index == 3 then
                    utils.quickSort(UITowerShop.storeData[_index], function(obj1, obj2) if obj1.pagodaStoreyId > obj2.pagodaStoreyId then return true end end)
                else
                    utils.quickSort(UITowerShop.storeData[_index], function(obj1, obj2) if utils.getThingCount(DictThing[tostring(obj1.tableFieldId)].id) < utils.getThingCount(DictThing[tostring(obj2.tableFieldId)].id) then return true end end)
                end
            end

            layoutScrollView(UITowerShop.storeData[_index], function(_item, data)
                local itemProps = utils.getItemProp(data.tableTypeId, data.tableFieldId)
                local ui_itemFrame = _item:getChildByName("image_frame_chip")
                local ui_itemIcon = ui_itemFrame:getChildByName("image_chip")
                local ui_itemValue = ui_itemFrame:getChildByName("text_number")
                local ui_itemFlag = ui_itemFrame:getChildByName("image_sui")
                local ui_itemName = _item:getChildByName("text_chip_name")
                local ui_itemHint = _item:getChildByName("text_hint")
                local ui_itemCount = _item:getChildByName("text_number")
                local ui_fireNums = _item:getChildByName("image_fire"):getChildByName("text_number")

                ui_itemFrame:loadTexture(itemProps.frameIcon)
                ui_itemName:setString(itemProps.name)
                ui_itemIcon:loadTexture(itemProps.smallIcon)
                -- zy   套装加流光
                local equipId = nil
                if data.tableTypeId == StaticTableType.DictEquipment then
                    equipId = DictEquipment[tostring(data.tableFieldId)].id
                elseif data.tableTypeId == StaticTableType.DictThing then
                    equipId = DictThing[tostring(data.tableFieldId)].equipmentId
                end
                local suitEquipData = equipId and utils.getEquipSuit(tostring(equipId)) or false
                utils.addFrameParticle(ui_itemIcon, suitEquipData)
                -- end

                -- zy  查看装备详细
                local function btnTouchEventImg(sender, eventType)
                    if eventType == ccui.TouchEventType.ended then
                        if equipId and equipId > 0 then
                            local dictEquipId = equipId
                            -- 装备字典ID		
                            local suitEquipData = utils.getEquipSuit(tostring(dictEquipId))
                            if suitEquipData then
                                UIEquipmentNew.setDictEquipId(dictEquipId)
                                UIManager.pushScene("ui_equipment_new")
                            else
                                UIEquipmentInfo.setDictEquipId(dictEquipId)
                                UIManager.pushScene("ui_equipment_info")
                            end
                        else
                            local param = { }
                            param.tableTypeId = data.tableTypeId
                            param.tableFieldId = data.tableFieldId
                            UIGoodInfo.setParam(param)
                            UIManager.pushScene("ui_good_info")
                        end
                    end
                end
                ui_itemIcon:setTouchEnabled(true)
                ui_itemIcon:addTouchEventListener(btnTouchEventImg)
                -- end
                if itemProps.flagIcon then
                    ui_itemFlag:loadTexture(itemProps.flagIcon)
                    ui_itemFlag:setVisible(true)
                else
                    ui_itemFlag:setVisible(false)
                end
                ui_itemCount:setString("")
                if itemProps.flagIcon and data.tableTypeId == StaticTableType.DictThing then
                    local dictData = DictThing[tostring(data.tableFieldId)]
                    if dictData and dictData.id >= 200 and dictData.id < 300 then
                        local tempData = DictEquipment[tostring(dictData.equipmentId)]
                        if tempData then
                            local itemCountDesc = "(" .. utils.getThingCount(dictData.id) .. "/" .. DictEquipQuality[tostring(tempData.equipQualityId)].thingNum .. ")"
                            ui_itemCount:setString(itemCountDesc)
                        end
                    end
                end
                ui_itemValue:setString("×" .. data.value)
                ui_itemHint:setString(string.format(Lang.ui_tower_shop3, data.pagodaStoreyId))
                ui_fireNums:setString(tostring(data.culture))

                local _itemBtn = _item:getChildByName("btn_lineup")

                _itemBtn:setPressedActionEnabled(true)
                _itemBtn:addTouchEventListener( function(_sender, _eventType)
                    if _eventType == ccui.TouchEventType.ended then
                        if net.InstPlayerPagoda.int["3"] -1 >= data.pagodaStoreyId then
                            if net.InstPlayer.int["21"] >= data.culture then
                                if sender == btn_reward then
                                    _titleTabButton = sender
                                    sendPackage(data.id)
                                else
                                    _titleTabButton = sender
                                    -- sendPackage(data.id)
                                    UISellProp.setData(data, UITowerShop)
                                    UIManager.pushScene("ui_sell_prop")
                                end
                            else
                                UIManager.showToast(Lang.ui_tower_shop4)
                            end
                        else
                            UIManager.showToast(Lang.ui_tower_shop5)
                        end
                    end
                end )
                if sender == btn_reward then
                    local _btnEnabled = true
                    local _ids = utils.stringSplit(net.InstPlayerPagoda.string["9"], ";")
                    for _key, _id in pairs(_ids) do
                        if data.id == tonumber(_id) then
                            _btnEnabled = false
                            break
                        end
                    end
                    _itemBtn:setTouchEnabled(_btnEnabled)
                    _itemBtn:setBright(_btnEnabled)
                    _itemBtn:setTitleText(_btnEnabled and Lang.ui_tower_shop6 or Lang.ui_tower_shop7)

                else
                    _itemBtn:setBright(true)
                    _itemBtn:setTitleText(Lang.ui_tower_shop8)
                end
                if net.InstPlayerPagoda.int["3"] -1 < data.pagodaStoreyId then
                    _itemBtn:setBright(false)
                    _itemBtn:setTitleText(Lang.ui_tower_shop9)
                end
            end )
        end
    end
    btn_purple:addTouchEventListener(onButtonEvent)
    btn_orange:addTouchEventListener(onButtonEvent)
    btn_reward:addTouchEventListener(onButtonEvent)

    if _tag then
        if _tag == 2 then
            _titleTabButton = btn_orange
        elseif tag == 3 then
            _titleTabButton = btn_reward
        end
        _tag = nil
    end

    if _titleTabButton == btn_orange then
        btn_orange:releaseUpEvent()
    elseif _titleTabButton == btn_reward then
        btn_reward:releaseUpEvent()
    else
        btn_purple:releaseUpEvent()
    end


end

function UITowerShop.free()
    cleanScrollView(true)
    _titleTabButton = nil
    _tag = nil
    UITowerShop.storeData = nil
end

function UITowerShop.setTag(tag)
    _tag = tag
end
