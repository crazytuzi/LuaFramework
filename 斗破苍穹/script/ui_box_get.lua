require"Lang"
UIBoxGet = {
    STATE_NONE = 0,
    STATE_RADIO = 1,
    state = 0,
}

local ui_scrollView = nil
local ui_svItem = nil
local _thingData = nil

local function cleanScrollView()
    -- if ui_svItem:getReferenceCount() == 1 then
    -- 	ui_svItem:retain()
    -- end
    ui_scrollView:removeAllChildren()
end

local function setScrollViewItem(item, data)
    local ui_itemIcon = item:getChildByName("image_good")
    local ui_itemNum = item:getChildByName("num")
    local ui_itemType = ui_itemIcon:getChildByName("image_type")
    local ui_itemName = ccui.Helper:seekNodeByName(item, "text_name")
    local box_choose = ccui.Helper:seekNodeByName(item, "box_choose")
    local itemProps = utils.getItemProp(data.tableTypeId, data.tableFieldId)
    if itemProps.frameIcon then
        item:loadTexture(itemProps.frameIcon)
    end
    if itemProps.smallIcon then
        ui_itemIcon:loadTexture(itemProps.smallIcon)
    end
    if itemProps.name then
        ui_itemName:setString(itemProps.name)
    end
    if itemProps.flagIcon then
        ui_itemType:loadTexture(itemProps.flagIcon)
        ui_itemType:setVisible(true)
    else
        ui_itemType:setVisible(false)
    end
    if data.value > 1 then
        ui_itemNum:setVisible(true)
        ui_itemNum:setFontName(dp.FONT)
        ui_itemNum:setString("x" .. data.value)
    else
        ui_itemNum:setVisible(false)
    end
    if UIBoxGet.state == UIBoxGet.STATE_RADIO then
        box_choose:show():setSelected(false)
        box_choose:addEventListener( function(sender, eventType)
            if eventType == ccui.CheckBoxEventType.selected then
                local childs = ui_scrollView:getChildren()
                for i, child in ipairs(childs) do
                    if child ~= item then
                        local box_choose = child:getChildByName("box_choose")
                        if box_choose:isSelected() then
                            box_choose:setSelected(false)
                        end
                    end
                end
                UIBoxGet.selectIndex = item:getTag()
                local btn_sure = ccui.Helper:seekNodeByName(UIBoxGet.Widget, "btn_sure")
                utils.GrayWidget(btn_sure, false)
                btn_sure:setEnabled(true)
            elseif eventType == ccui.CheckBoxEventType.unselected then
                if UIBoxGet.selectIndex == item:getTag() then
                    UIBoxGet.selectIndex = nil
                    local btn_sure = ccui.Helper:seekNodeByName(UIBoxGet.Widget, "btn_sure")
                    utils.GrayWidget(btn_sure, true)
                    btn_sure:setEnabled(false)
                end
            end
        end )
    else
        box_choose:hide()
    end
end

function UIBoxGet.init()
    local btn_close = ccui.Helper:seekNodeByName(UIBoxGet.Widget, "btn_close")
    local btn_sure = ccui.Helper:seekNodeByName(UIBoxGet.Widget, "btn_sure")
    btn_close:setPressedActionEnabled(true)
    btn_sure:setPressedActionEnabled(true)
    local function onBtnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_sure then
                if UIBoxGet.state == UIBoxGet.STATE_RADIO then
                    local sendData = {
                        header = StaticMsgRule.openBox,
                        msgdata =
                        {
                            int =
                            {
                                instPlayerThingId = UIBoxGet.extraData,
                                num = 1,
                                index = UIBoxGet.selectIndex
                            }
                        }
                    }
                    UIManager.showLoading()
                    netSendPackage(sendData, function(pack)
                        UIManager.popScene()
                        local data = _thingData[UIBoxGet.selectIndex]
                        utils.showGetThings(string.format("%d_%d_%d", data.tableTypeId, data.tableFieldId, data.value))
                        UIManager.flushWidget(UITeamInfo)
                        UIManager.flushWidget(UIBag)
                    end )
                else
                    UIManager.popScene()
                end
            end
        end
    end
    btn_close:addTouchEventListener(onBtnEvent)
    btn_sure:addTouchEventListener(onBtnEvent)

    ui_scrollView = ccui.Helper:seekNodeByName(UIBoxGet.Widget, "view_good")
    ui_svItem = ui_scrollView:getChildByName("image_frame_good")
end

function UIBoxGet.setup()
    cleanScrollView()

    ccui.Helper:seekNodeByName(UIBoxGet.Widget, "text_get"):setString(UIBoxGet.state == UIBoxGet.STATE_RADIO and Lang.ui_box_get1 or Lang.ui_box_get2)
    local btn_sure = ccui.Helper:seekNodeByName(UIBoxGet.Widget, "btn_sure")

    if _thingData and #_thingData > 0 then
        local tag = 1
        for key, obj in pairs(_thingData) do
            local thingItem = ui_svItem:clone()
            thingItem:setTag(tag)
            setScrollViewItem(thingItem, obj)
            ui_scrollView:addChild(thingItem)
            tag = tag + 1
        end

        local innerHeight, space, row = 0, 10, 4
        local extraHeight = 0
        if UIBoxGet.state == UIBoxGet.STATE_RADIO then
            extraHeight = ui_svItem:getChildByName("box_choose"):getContentSize().height
            utils.GrayWidget(btn_sure, true)
            btn_sure:setEnabled(false)
        end

        local svItemHeight = ui_svItem:getContentSize().height + ui_svItem:getChildByName("image_di_name"):getContentSize().height + extraHeight
        local childs = ui_scrollView:getChildren()
        if #childs < row then
            innerHeight = svItemHeight + space
        elseif #childs % row == 0 then
            innerHeight =(#childs / row) *(svItemHeight + space) + space
        else
            innerHeight = math.ceil(#childs / row) *(svItemHeight + space) + space
        end
        innerHeight = innerHeight + space
        if innerHeight < ui_scrollView:getContentSize().height then
            innerHeight = ui_scrollView:getContentSize().height
        end
        ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, innerHeight))

        local prevChild = nil
        local _tempI, x, y = 1, 0, 0
        for i = 1, #childs do
            x = _tempI *(ui_scrollView:getContentSize().width / row) -(ui_scrollView:getContentSize().width / row) / 2
            _tempI = _tempI + 1
            if i < row then
                y = ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - space
                prevChild = childs[i]
                childs[i]:setPosition(cc.p(x, y))
            elseif i % row == 0 then
                childs[i]:setPosition(cc.p(x, y))
                y = prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - childs[i]:getChildByName("image_di_name"):getContentSize().height - extraHeight - space
                _tempI = 1
                prevChild = childs[i]
            else
                y = prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - childs[i]:getChildByName("image_di_name"):getContentSize().height - extraHeight - space
                childs[i]:setPosition(cc.p(x, y))
            end
        end
    end
end

function UIBoxGet.setData(data, state, extraData)
    _thingData = data
    UIBoxGet.state = state or UIBoxGet.STATE_NONE
    UIBoxGet.extraData = extraData
end

function UIBoxGet.free()
    cleanScrollView()
    _thingData = nil
    UIBoxGet.state = nil
    UIBoxGet.extraData = nil
    UIBoxGet.selectIndex = nil
end
