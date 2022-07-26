require"Lang"
UIBossShop = { }

local userData = nil

local ui_scrollView = nil
local ui_svItem = nil

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
    if type(_listData) ~= "table" then
        _listData = { }
    end

    utils.updateScrollView(UIBossShop, ui_scrollView, ui_svItem, _listData, _initItemFunc, { space = 10 })
end

local function setScrollViewItem(_item, _data)
    local ui_name = _item:getChildByName("text_chip_name")
    local ui_frame = _item:getChildByName("image_frame_chip")
    local ui_icon = ui_frame:getChildByName("image_chip")
    local ui_flag = ui_frame:getChildByName("image_sui")
    local ui_count = ui_frame:getChildByName("text_number")
    local ui_price = _item:getChildByName("image_fire"):getChildByName("text_number")
    local ui_nums = _item:getChildByName("text_number")
    ui_flag:setVisible(false)
    ui_nums:setString("")
    ui_price:setString("×" .. _data.needbossIntegral)
    local itemProps = utils.getItemProp(_data.things)
    if itemProps then
        utils.showThingsInfo(ui_icon, itemProps.tableTypeId, itemProps.tableFieldId)
        if itemProps.name then
            if itemProps.qualityColor then
                ui_name:setTextColor(itemProps.qualityColor)
            end
            ui_name:setString(itemProps.name)
        end
        if itemProps.frameIcon then
            ui_frame:loadTexture(itemProps.frameIcon)
            if itemProps.tableTypeId == StaticTableType.DictCardSoul then
                local _soulCount = 0
                if net.InstPlayerCardSoul then
                    for key, obj in pairs(net.InstPlayerCardSoul) do
                        if obj.int["4"] == itemProps.tableFieldId then
                            _soulCount = obj.int["5"]
                            break
                        end
                    end
                end
                local _cardId = DictCardSoul[tostring(itemProps.tableFieldId)].cardId
                local soulNum = DictQuality[tostring(DictCard[tostring(_cardId)].qualityId)].soulNum
                ui_nums:setString("(" .. _soulCount .. "/" .. soulNum .. ")")
            elseif itemProps.tableTypeId == StaticTableType.DictThing then
                local dictData = DictThing[tostring(itemProps.tableFieldId)]
                if dictData and dictData.id >= 200 and dictData.id < 300 then
                    local tempData = DictEquipment[tostring(dictData.equipmentId)]
                    if tempData then
                        local itemCountDesc = "(" .. utils.getThingCount(dictData.id) .. "/" .. DictEquipQuality[tostring(tempData.equipQualityId)].thingNum .. ")"
                        ui_nums:setString(itemCountDesc)
                    end
                end
            end
        end
        if itemProps.smallIcon then
            ui_icon:loadTexture(itemProps.smallIcon)
        end
        if itemProps.flagIcon then
            ui_flag:loadTexture(itemProps.flagIcon)
            ui_flag:setVisible(true)
        end
        if itemProps.count then
            ui_count:setString("×" .. itemProps.count)
        end
    end
    local btn_lineup = _item:getChildByName("btn_lineup")
    btn_lineup:setPressedActionEnabled(true)
    btn_lineup:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if userData.bossIntergral >= _data.needbossIntegral then
                local _paramData = _data
                _paramData.bossIntergral = userData.bossIntergral
                UISellProp.setData(_paramData, UIBossShop, function(_num)
                    UIManager.showToast(Lang.ui_boss_shop1)
                    userData.bossIntergral = userData.bossIntergral - _num * _data.needbossIntegral
                    UIManager.flushWidget(UIBossShop)
                    UIBoss.refreshIntegral(userData.bossIntergral)
                end )
                UIManager.pushScene("ui_sell_prop")
            else
                UIManager.showToast(Lang.ui_boss_shop2)
            end
        end
    end )
end

function UIBossShop.init()
    local image_basemap = UIBossShop.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    btn_close:setPressedActionEnabled(true)
    btn_close:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
        end
    end )
    ui_scrollView = image_basemap:getChildByName("view_award_lv")
    ui_svItem = ui_scrollView:getChildByName("image_base_good"):clone()
end

function UIBossShop.setup()
    local _prevUIBtn = nil
    local image_basemap = UIBossShop.Widget:getChildByName("image_basemap")
    image_basemap:getChildByName("image_fire_all"):getChildByName("text_number"):setString(tostring(userData.bossIntergral))
    local btn_card = image_basemap:getChildByName("btn_card")
    local btn_equipment = image_basemap:getChildByName("btn_equipment")
    local btn_material = image_basemap:getChildByName("btn_material")
    local function onTabEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if _prevUIBtn == sender then
                return
            end
            _prevUIBtn = sender
            btn_card:getChildByName("text_card"):setTextColor(cc.c4b(255, 255, 255, 255))
            btn_card:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
            btn_equipment:getChildByName("text_equipment"):setTextColor(cc.c4b(255, 255, 255, 255))
            btn_equipment:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
            btn_material:getChildByName("text_material"):setTextColor(cc.c4b(255, 255, 255, 255))
            btn_material:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
            sender:loadTextures("ui/yh_btn02.png", "ui/yh_btn02.png")
            if sender == btn_card then
                userData._index = 1
                sender:getChildByName("text_card"):setTextColor(cc.c4b(51, 25, 4, 255))
            elseif sender == btn_equipment then
                userData._index = 2
                sender:getChildByName("text_equipment"):setTextColor(cc.c4b(51, 25, 4, 255))
            elseif sender == btn_material then
                userData._index = 3
                sender:getChildByName("text_material"):setTextColor(cc.c4b(51, 25, 4, 255))
            end
            layoutScrollView(userData.ShopData[userData._index], setScrollViewItem)
        end
    end
    btn_card:addTouchEventListener(onTabEvent)
    btn_equipment:addTouchEventListener(onTabEvent)
    btn_material:addTouchEventListener(onTabEvent)
    if userData._index == 2 then
        btn_equipment:releaseUpEvent()
    elseif userData._index == 3 then
        btn_material:releaseUpEvent()
    else
        btn_card:releaseUpEvent()
    end
end

function UIBossShop.free()
    cleanScrollView(true)
    userData = nil
end

function UIBossShop.show(_tableParams)
    userData = _tableParams
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.sendBossShop, msgdata = { } }, function(_msgData)
        if _msgData then
            local _msgString = _msgData.msgdata.string["1"]
            local data = utils.stringSplit(_msgString, ";")
            for key, obj in pairs(data) do
                local _temp = utils.stringSplit(obj, "/")
                if userData.ShopData == nil then
                    userData.ShopData = { }
                end
                local type = tonumber(_temp[6])
                if userData.ShopData[type] == nil then
                    userData.ShopData[type] = { }
                end
                userData.ShopData[type][#userData.ShopData[type] + 1] = {
                    id = tonumber(_temp[1]),
                    things = _temp[3],
                    needbossIntegral = tonumber(_temp[4]),
                    rank = tonumber(_temp[5])
                }
            end
            if userData.ShopData then
                for key, obj in pairs(userData.ShopData) do
                    utils.quickSort(userData.ShopData[key], function(obj1, obj2) if obj1.rank > obj2.rank then return true end end)
                end
            end
            UIManager.pushScene("ui_boss_shop")
        end
    end )
end
