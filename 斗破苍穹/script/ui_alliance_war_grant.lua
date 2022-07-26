require"Lang"
UIAllianceWarGrant = { }

local ui = UIAllianceWarGrant

local image_box
local text_name

function ui.init()
    local btn_close = ccui.Helper:seekNodeByName(ui.Widget, "btn_close")

    local view_box = ccui.Helper:seekNodeByName(ui.Widget, "view_box")
    image_box = view_box:getChildByName("image_box")

    local scrollViewSize = view_box:getContentSize()
    local listItemSize = image_box:getContentSize()

    local item = ccui.Layout:create()
    item:setAnchorPoint(display.CENTER)
    item:setContentSize(cc.size(scrollViewSize.width, listItemSize.height))
    item:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    item:setBackGroundColor(cc.c3b(0, 0, 0))
    item:setBackGroundColorOpacity(0)

    local space =(scrollViewSize.width - 3 * listItemSize.width) / 4

    image_box:retain()
    image_box:removeFromParent()

    image_box:setPosition(space + listItemSize.width / 2, listItemSize.height / 2)
    item:addChild(image_box)
    image_box:release()

    image_box = image_box:clone()
    image_box:setPositionX(2 *(space + listItemSize.width) - listItemSize.width / 2)
    item:addChild(image_box)

    image_box = image_box:clone()
    image_box:setPositionX(3 *(space + listItemSize.width) - listItemSize.width / 2)
    item:addChild(image_box)

    image_box = item
    item:retain()

    view_box:removeAllChildren()

    local view_list = ccui.Helper:seekNodeByName(ui.Widget, "view_list")
    text_name = view_list:getChildByName("text_name")
    text_name:retain()

    btn_close:setPressedActionEnabled(true)

    local function touchevent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            if sender == btn_close then
                UIManager.popScene()
            end
        end
    end

    btn_close:addTouchEventListener(touchevent)
end

local function refresh(msgdata)
    ui.maxReward = msgdata.int.maxReward

    local rewardInfo = utils.stringSplit(msgdata.string.rewardInfo, "/")
    local info = { }
    ui.curReward = 0
    for i = 1, #rewardInfo do
        local data = utils.stringSplit(rewardInfo[i], "|")
        data[1] = tonumber(data[1] or 0)

        if not data[3] or data[3] == "" then
            ui.curReward = ui.curReward + 1
        end

        local j = math.floor((i - 1) / 3) + 1
        local pos =(i - 1) % 3 + 1

        local group = info[j] or { }
        group[pos] = data
        info[j] = group
    end

    if not next(info) then
        info[1] = { { 0 } }
    end

    ui.rewardInfo = info

    local distributionRecord = utils.stringSplit(msgdata.string.distributionRecord, "/")
    for i = 1, #distributionRecord do
        distributionRecord[i] = utils.stringSplit(distributionRecord[i], "|")
    end
    ui.distributionRecord = distributionRecord

    UIManager.flushWidget(ui)
end

local function netCallbackFunc(pack)
    local code = tonumber(pack.header)
    local msgdata = pack.msgdata
    if code == StaticMsgRule.freshAward then
        refresh(msgdata)
    elseif code == StaticMsgRule.adminAward then
        UIAlliance.show()
        local btn_assigned = ccui.Helper:seekNodeByName(UIAlliance.Widget, "btn_assigned")
        btn_assigned:releaseUpEvent()
    elseif code == StaticMsgRule.freshBoxInfo then
        UIAwardGet.setOperateType(UIAwardGet.operateType.dailyTaskBox, {
            btnTitleText = Lang.ui_alliance_war_grant1,
            enabled = true,
            things = msgdata.string.things
        } , ui)
        UIManager.pushScene("ui_award_get")
    end
end

local function setViewListItem(item, data)
    local itemProp = utils.getItemProp(data[3])
    item:setString(data[1] .. Lang.ui_alliance_war_grant2 ..(itemProp.name or "") .. Lang.ui_alliance_war_grant3 .. data[2])
end

local function setViewBoxItem(item, group)
    local childs = item:getChildren()
    for i = 1, #childs do
        local data = group[i]
        local child = childs[i]
        if data then
            child:show()
            local image_frame_box = child:getChildByName("image_frame_box")
            local image_give = child:getChildByName("image_give")
            local text_info = child:getChildByName("text_info")
            local btn_give = child:getChildByName("btn_give")
            local text_hint = child:getChildByName("text_hint")

            if data[1] == 0 then
                image_frame_box:hide()
                image_give:hide()
                text_info:hide()
                btn_give:hide()
                text_hint:show()
            else
                local itemProp = utils.getItemProp(data[2])
                image_frame_box:loadTexture(itemProp.frameIcon)
                local image_box = image_frame_box:getChildByName("image_box")
                local text_name = image_frame_box:getChildByName("text_name")

                image_box:loadTexture(itemProp.smallIcon)
                text_name:setString(itemProp.name)

                utils.showThingsInfo(image_box, itemProp.tableTypeId, itemProp.tableFieldId)

                text_hint:hide()
                if data[3] and data[3] ~= "" then
                    image_give:show()
                    text_info:show():setString(data[3])
                    btn_give:hide()
                else
                    image_give:hide()
                    text_info:hide()
                    btn_give:show():setPressedActionEnabled(true)
                    btn_give:addTouchEventListener( function(sender, eventType)
                        if eventType == ccui.TouchEventType.ended then
                            local gradeId = net.InstUnionMember.int["4"]
                            if gradeId ~= 1 and gradeId ~= 2 then
                                UIManager.showToast(Lang.ui_alliance_war_grant4)
                                return
                            end
                            audio.playSound("sound/button.mp3")
                            ui.posY = ccui.Helper:seekNodeByName(ui.Widget, "view_box"):getInnerContainer():getPositionY()
                            UIAlliance.showMemberForAllianceWarGrant( function(playerId)
                                UIManager.showLoading()
                                netSendPackage( { header = StaticMsgRule.adminAward, msgdata = { int = { thingId = data[1], who = playerId } } }, netCallbackFunc)
                            end )
                        end
                    end )
                end
            end
        else
            child:hide()
        end
    end
end

function ui.setup()
    if not ui.isFlush then
        UIManager.showLoading()
        netSendPackage( { header = StaticMsgRule.freshAward, msgdata = { } }, netCallbackFunc)
        return
    end

    local view_box = ccui.Helper:seekNodeByName(ui.Widget, "view_box")
    local scrollevent = utils.updateScrollView(ui, view_box, image_box, ui.rewardInfo, setViewBoxItem)
    if ui.posY then
        local minY = view_box:getContentSize().height - view_box:getInnerContainerSize().height
        local h = - minY
        local percent =(ui.posY - minY) * 100 / h
        percent = math.max(0, math.min(100, percent))
        view_box:jumpToPercentVertical(percent)
        ui.posY = nil
        scrollevent(true)
    end

    local view_list = ccui.Helper:seekNodeByName(ui.Widget, "view_list")
    utils.updateScrollView(ui, view_list, text_name, ui.distributionRecord, setViewListItem, { space = 2 })

    local text_left = ccui.Helper:seekNodeByName(ui.Widget, "text_left")
    text_left:setString(string.format(Lang.ui_alliance_war_grant5, ui.curReward, ui.maxReward))
end

function ui.free()
    if image_box and image_box:getReferenceCount() >= 1 then
        image_box:release()
        image_box = nil
    end
    if text_name and text_name:getReferenceCount() >= 1 then
        text_name:release()
        text_name = nil
    end
    ui.maxReward = nil
    ui.curReward = nil
    ui.rewardInfo = nil
    ui.distributionRecord = nil
end
