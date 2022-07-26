require"Lang"
UIBagWinSmall = {}

local userData = nil

function UIBagWinSmall.init()
    local image_basemap = UIBagWinSmall.Widget:getChildByName("image_basemap")
    local btn_sure = image_basemap:getChildByName("btn_sure")
    btn_sure:setPressedActionEnabled(true)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIBag.reset()
            UIManager.showScreen("ui_notice", "ui_team_info", "ui_bag","ui_menu")
        end
    end)
end

function UIBagWinSmall.setup()
    local armature = ActionManager.getUIAnimation((userData.isWin == 1) and 11 or 12)
    armature:setPosition(cc.p(320, 760))
    UIBagWinSmall.Widget:addChild(armature, 100, 100)
    local image_basemap = UIBagWinSmall.Widget:getChildByName("image_basemap")
    local ui_descText = image_basemap:getChildByName("image_base_name"):getChildByName("text_fight_name")
    local ui_itemFrame = image_basemap:getChildByName("image_get_di"):getChildByName("image_frame_good")
    local ui_itemIcon = ui_itemFrame:getChildByName("image_good")
    local ui_itemName = ui_itemFrame:getChildByName("text_name")
    local ui_doubleFlag = ui_itemFrame:getChildByName("image_double")
    if userData.isWin == 0 then
        ui_doubleFlag:setVisible(false)
        utils.GrayWidget(image_basemap:getChildByName("image_basedi"), true)
        ui_descText:setString(Lang.ui_bag_win_small1)
    else
        ui_doubleFlag:setVisible(true)
        ui_descText:setString(Lang.ui_bag_win_small2)
    end
    ui_itemName:setString("")
    if userData.thingData then
        local itemProps = utils.getItemProp(userData.thingData.tableTypeId .. "_" .. userData.thingData.tableFieldId .. "_" .. userData.thingData.value)
        if itemProps then
            if itemProps.frameIcon then
                ui_itemFrame:loadTexture(itemProps.frameIcon)
            end
            if itemProps.smallIcon then
                ui_itemIcon:loadTexture(itemProps.smallIcon)
            end
            if itemProps.name then
                ui_itemName:setString(itemProps.name .. "×" .. itemProps.count)
            end
        end
    end
end

function UIBagWinSmall.free()
    userData = nil
end

function UIBagWinSmall.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_bag_win_small")
end
