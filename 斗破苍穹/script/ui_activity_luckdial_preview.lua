require"Lang"
UIActivityLuckdialPreview = {
    rankAwards = nil
}

local ui = UIActivityLuckdialPreview

function ui.init()
    local btn_close = ccui.Helper:seekNodeByName(ui.Widget, "btn_close")
    local btn_closed = ccui.Helper:seekNodeByName(ui.Widget, "btn_closed")

    local function touchevent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            if sender == btn_close or sender == btn_closed then
                UIManager.popScene()
            end
        end
    end

    btn_close:addTouchEventListener(touchevent)
    btn_closed:addTouchEventListener(touchevent)

    local scrollView = ccui.Helper:seekNodeByName(ui.Widget, "view_award_lv")
    local item = scrollView:getChildByName("image_base_gift")

    local curItem = item
    local index = 1
    local isFirst = true

    ui.rankAwards = ui.rankAwards or { }
    for i, obj in ipairs(ui.rankAwards) do
        local mark = utils.stringSplit(obj.mark, "-")

        local title = string.format(Lang.ui_activity_luckdial_preview1,(mark[1] == mark[2]) and mark[1] or obj.mark)
        local text_lv = ccui.Helper:seekNodeByName(curItem, "text_lv")

        if (text_lv:getString() ~= title) then
            if not isFirst then
                curItem = item:clone()
                text_lv = ccui.Helper:seekNodeByName(curItem, "text_lv")
            end
            text_lv:setString(title)

            index = 1
            for i = 1, math.huge do
                local image_frame_good = curItem:getChildByName("image_frame_good" .. i)
                if not image_frame_good then break end
                image_frame_good:setVisible(false)
            end

            if not isFirst then
                scrollView:addChild(curItem)
            end
        end

        local image_frame_good = curItem:getChildByName("image_frame_good" .. index)
        if image_frame_good then
            image_frame_good:setVisible(true)

            local itemProps = utils.getItemProp(obj.data)
            utils.addBorderImage(itemProps.tableTypeId, itemProps.tableFieldId, image_frame_good)

            if itemProps.smallIcon then
                local image_good = image_frame_good:getChildByName("image_good")
                image_good:loadTexture(itemProps.smallIcon)
                utils.addThingParticle(obj.data, image_good, true)
                utils.showThingsInfo(image_good, itemProps.tableTypeId, itemProps.tableFieldId)
            end
            
            local text_name = image_frame_good:getChildByName("text_name")
            text_name:setTextColor(itemProps.qualityColor)
            text_name:setString(itemProps.name)
            image_frame_good:getChildByName("text_number"):setString("×" .. itemProps.count)
        end
        isFirst = false
        index = index + 1
    end

    local childs = scrollView:getChildren()
    local scrollViewWidth = scrollView:getContentSize().width
    local size = item:getContentSize()
    local space = 20
    scrollView:setInnerContainerSize(cc.size(scrollViewWidth, #childs *(size.height + space) + 8))
    for i = #childs, 1, -1 do
        childs[i]:setPosition((scrollViewWidth - size.width) / 2,(#childs - i) *(size.height + space) + size.height / 2)
    end
end

function ui.setup()
    local text_integral_number = ccui.Helper:seekNodeByName(ui.Widget, "text_integral_number")
    local text_rank_number = ccui.Helper:seekNodeByName(ui.Widget, "text_rank_number")

    text_integral_number:setString(ccui.Helper:seekNodeByName(UIActivityLuckdial.Widget, "text_integral_number"):getString())
    text_rank_number:setString(ccui.Helper:seekNodeByName(UIActivityLuckdial.Widget, "text_rank_number"):getString())
    ActionManager.ScrollView_SplashAction(ccui.Helper:seekNodeByName(ui.Widget, "view_award_lv"))
end
