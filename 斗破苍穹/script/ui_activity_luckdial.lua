require"Lang"
UIActivityLuckdial = {
    OPEN_TYPE_OPEN_ACTIVITY = 1,
    OPEN_TYPE_REFRESH = 2,
    OPEN_TYPE_START_ONE = 3,
    OPEN_TYPE_START_TEN = 4,
    open = false,
    refreshOrStartOneOrTen = false,
}

local ui = UIActivityLuckdial

local ANI_LUNPAN_PATH = "ani/ui_anim/ui_anim_lunpan/ui_anim_lunpan.ExportJson"

local function addParticleEffect(node)
    local size = node:getContentSize()
    local anchorSize = 15
    local offset = 7
    for _i = 1, 2 do
        local effect = cc.ParticleSystemQuad:create("particle/ui_anim8_effect.plist")
        node:addChild(effect)
        effect:setPositionType(cc.POSITION_TYPE_RELATIVE)
        if _i == 1 then
            effect:setPosition(anchorSize + offset, offset)
            effect:runAction(utils.MyPathFun(anchorSize + offset, size.height - 2 * offset, size.width - 2 * anchorSize - 2 * offset, 0.3, 1))
        else
            effect:setPosition(size.width - anchorSize - offset, size.height - offset)
            effect:runAction(utils.MyPathFun(anchorSize + offset, size.height - 2 * offset, size.width - 2 * anchorSize - 2 * offset, 0.3, 0))
        end
    end
end

local function refreshTime(start, stop)
    local startTime = os.date("*t", math.floor(start / 1000))
    local endTime = os.date("*t", math.floor(stop / 1000))

    local text_time = ccui.Helper:seekNodeByName(ui.Widget, "text_time")
    local time = Lang.ui_activity_luckdial1 .. startTime.month .. Lang.ui_activity_luckdial2 .. startTime.day .. Lang.ui_activity_luckdial3 .. startTime.hour .. Lang.ui_activity_luckdial4

    local time = string.format(Lang.ui_activity_luckdial5, startTime.month, startTime.day, startTime.hour)
    if (startTime.min > 0) then
        time = time .. startTime.min .. Lang.ui_activity_luckdial6
    end
    time = time .. string.format(Lang.ui_activity_luckdial7, endTime.month, endTime.day, endTime.hour)
    if (endTime.min > 0) then
        time = time .. endTime.min .. Lang.ui_activity_luckdial8
    end

    text_time:setString(time)
end

local function setIcon(item, itemProps, prefix, flag)
    if itemProps.frameIcon then
        item:loadTexture(itemProps.frameIcon)
    end
    if itemProps.smallIcon then
        local image_good = item:getChildByName("image_good")
        image_good:loadTexture(itemProps.smallIcon)
        utils.showThingsInfo(image_good, itemProps.tableTypeId, itemProps.tableFieldId)
        if flag then
            utils.addFrameParticle(image_good, true)
        end
    end

    local ui_itemFlag = item:getChildByName("image_sui")
    if itemProps.flagIcon then
        if not ui_itemFlag then
            ui_itemFlag = ccui.Helper:seekNodeByName(ui.Widget, "image_sui"):clone()
            item:addChild(ui_itemFlag)
        end
        ui_itemFlag:loadTexture(itemProps.flagIcon)
        ui_itemFlag:setVisible(true)
    elseif ui_itemFlag then
        ui_itemFlag:setVisible(false)
    end
    item:getChildByName("text_number"):setString(prefix .. itemProps.count)
end

local function refreshCommon(common)
    local image_basemap_l = ui.Widget:getChildByName("image_basemap_l")
    common = utils.stringSplit(common, ";")
    local copy = ccui.Helper:seekNodeByName(image_basemap_l, "image_title")
    for i, thing in ipairs(common) do
        local itemProps = utils.getItemProp(thing)
        local item = image_basemap_l:getChildByName("image_frame_good" .. i)
        setIcon(item, itemProps, "×")
        local limitTag = item:getChildByName("image_title")
        if utils.stringSplit(thing, "_")[4] == "1" then
            if not limitTag then
                limitTag = copy:clone()
                limitTag:setLocalZOrder(100)
                item:addChild(limitTag)
            end
            limitTag:setVisible(true)
        elseif limitTag then
            limitTag:setVisible(false)
        end
    end
end

local function refreshLimit(limit)
    local image_rank_title = ccui.Helper:seekNodeByName(ui.Widget, "image_rank_title")
    local view_good = image_rank_title:getChildByName("view_good")
    limit = utils.stringSplit(limit, ";")

    local scrollViewItem = view_good:getChildByName("image_frame_good")

    local childs = view_good:getChildren()
    while #childs <= #limit do
        local item = scrollViewItem:clone()
        childs[#childs + 1] = item
        view_good:addChild(item)
    end

    local size = scrollViewItem:getContentSize()
    local scrollViewSize = view_good:getContentSize()

    local vspace = 5
    local hspace = 0
    local height = math.ceil(#limit / 3) *(size.height + vspace) + 10
    if height < scrollViewSize.height then
        height = scrollViewSize.height
    end
    view_good:setInnerContainerSize(cc.size(scrollViewSize.width, height))

    for i, item in ipairs(childs) do
        local thing = limit[i]
        if thing then
            item:show()
            local itemProps = utils.getItemProp(thing)
            setIcon(item, itemProps, Lang.ui_activity_luckdial9, true)
            local j =(i - 1) % 3
            local k = math.floor((i - 1) / 3)
            item:setPosition(j *(size.width + hspace) + size.width / 2, height -(k *(size.height + vspace) + size.height / 2))
        else
            item:hide()
        end
    end
end

local function refreshRank(rank, order)
    local view_people = ccui.Helper:seekNodeByName(ui.Widget, "view_people")
    local children = view_people:getChildren()

    rank = utils.stringSplit(rank, ";")

    if (#children > #rank) then
        for i = #rank + 1, #children do
            children[i]:setVisible(false)
        end
    elseif (#children < #rank) then
        for i = #children + 1, #rank do
            view_people:addChild(children[1]:clone())
        end
    end

    local size = children[1]:getContentSize()
    local scrollViewSize = view_people:getContentSize()
    view_people:setInnerContainerSize(cc.size(scrollViewSize.width, #rank * size.height))
    local innerHeight = view_people:getInnerContainerSize().height
    children = view_people:getChildren()

    for i = 1, #rank do
        local child = children[i]
        local record = utils.stringSplit(rank[i], "|")
        local name = record[2]
        local index = record[3]
        local point = record[4]

        child:getChildByName("text_name1"):setString(string.format("%s.%s", index, name))
        child:getChildByName("text_integral1"):setString(point)
        child:setVisible(true)
        child:setPosition((scrollViewSize.width - size.width) / 2, innerHeight - i * size.height)
    end

    if order <= #rank and order > 3 then
        local max = #rank * size.height - scrollViewSize.height
        local thumb = order * size.height - size.height / 2 - scrollViewSize.height / 2
        local percent = 100 * math.min(1, math.max(0, thumb / max))
        view_people:scrollToPercentVertical(percent, 1.0, true)
    else
        view_people:scrollToTop(1.0, true)
    end
end

local function showTenReward(awards)
    awards = utils.stringSplit(awards, ";")

    local openBoxData = { }

    for i, award in ipairs(awards) do
        local data = utils.stringSplit(award, "_")
        data.tableTypeId = tonumber(data[1])
        data.tableFieldId = data[2]
        data.value = tonumber(data[3])
        data.isLimit = data[4] == "1"
        openBoxData[#openBoxData + 1] = data
    end

    local copy = ccui.Helper:seekNodeByName(ui.Widget, "image_title")

    UIBoxGet.setData(openBoxData)
    UIManager.pushScene("ui_box_get")
    ccui.Helper:seekNodeByName(UIBoxGet.Widget, "text_get"):setString(Lang.ui_activity_luckdial10)
    local scrollView = ccui.Helper:seekNodeByName(UIBoxGet.Widget, "view_good")
    local children = scrollView:getChildren()
    for i, child in ipairs(children) do
        utils.showThingsInfo(child, openBoxData[i].tableTypeId, openBoxData[i].tableFieldId)
        if openBoxData[i].isLimit then
            child:addChild(copy:clone():show())
        end
        local text_num = child:getChildByName("num")
        text_num:setFontName(dp.FONT)
        text_num:setFontSize(22)
    end
end

local function netCallbackFunc(pack)
    local code = tonumber(pack.header)
    if code == StaticMsgRule.activityLuck then
        local msgdata = pack.msgdata
        local type = msgdata.int.type
        local common = msgdata.string.common
        local limit = msgdata.string.limit
        local rank = msgdata.string.rank
        local order = msgdata.int.order
        local point = msgdata.int.point
        local start = msgdata.long.start
        local stop = msgdata.long.stop
        local oneCost = msgdata.int.oneCost
        local tenCost = msgdata.int.tenCost
        local refreshCost = msgdata.int.refreshCost
        local refreshRemain = msgdata.int.refreshRemain
        local startRemain = msgdata.int.startRemain
        local awards = msgdata.string.awards
        local awardIndex = msgdata.int.awardIndex

        ui.oneCost = oneCost
        ui.tenCost = tenCost
        ui.refreshCost = refreshCost
        ui.refreshRemain = refreshRemain
        ui.startRemain = startRemain

        -- cclog("oneCost=%d,tenCost=%d,refreshCost=%d,refreshRemain=%d,startRemain=%d", oneCost, tenCost, refreshCost, refreshRemain, startRemain)
        -- cclog("point=%d,order=%d,awardIndex=%d", point, order,awardIndex)
        refreshTime(start, stop)

        local btn_one = ccui.Helper:seekNodeByName(ui.Widget, "btn_one")
        local btn_ten = ccui.Helper:seekNodeByName(ui.Widget, "btn_ten")
        local image_basemap_l = ui.Widget:getChildByName("image_basemap_l")
        local text_price = image_basemap_l:getChildByName("text_price")
        if startRemain > 0 then
            btn_one:getChildByName("text_hint"):show():setString(string.format(Lang.ui_activity_luckdial11, startRemain))
            btn_one:getChildByName("image_jin"):setVisible(false)
        else
            ccui.Helper:seekNodeByName(btn_one, "image_jin"):show():getChildByName("text_cost"):setString(tostring(oneCost))
            btn_one:getChildByName("text_hint"):setVisible(false)
        end

        ccui.Helper:seekNodeByName(btn_ten, "text_cost"):setString(tostring(tenCost))
        text_price:setString(refreshRemain > 0 and string.format(Lang.ui_activity_luckdial12, refreshRemain) or string.format(Lang.ui_activity_luckdial13, refreshCost))

        local text_integral_number = ccui.Helper:seekNodeByName(ui.Widget, "text_integral_number")
        local text_rank_number = ccui.Helper:seekNodeByName(ui.Widget, "text_rank_number")
        local image_zz = image_basemap_l:getChildByName("image_zz")
        local image_xz = image_basemap_l:getChildByName("image_xz")

        text_rank_number:setString(tostring(order))
        refreshRank(rank, order)

        ui.open = true
        if type == ui.OPEN_TYPE_OPEN_ACTIVITY then
            local rankAwards = msgdata.string.rankAwards
            rankAwards = utils.stringSplit(rankAwards, ";")
            for i = 1, #rankAwards do
                local rankAward = utils.stringSplit(rankAwards[i], ",");
                rankAwards[i] = { mark = rankAward[1], data = rankAward[2] }
            end
            UIActivityLuckdialPreview.rankAwards = rankAwards
            text_integral_number:setString(tostring(point))
            refreshCommon(common)
            refreshLimit(limit)
            image_zz:setRotation(0)
            image_xz:setVisible(false)
            ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(ANI_LUNPAN_PATH)
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(ANI_LUNPAN_PATH)
        elseif type == ui.OPEN_TYPE_REFRESH then
            local animation = ActionManager.getUIAnimation("_lunpan", function()
                text_integral_number:setString(tostring(point))
                refreshCommon(common)
                refreshLimit(limit)
                image_zz:setRotation(0)
                image_xz:setVisible(false)
                ui.refreshOrStartOneOrTen = false
            end )
            animation:setScale(1.5)
            animation:setPosition(image_zz:getPosition())
            image_zz:getParent():addChild(animation, 10000)
        else
            local curPoint = tonumber(text_integral_number:getString())
            local step =(point - curPoint) / 2000 * cc.Director:getInstance():getAnimationInterval()
            step = step < 1 and 1 or math.ceil(step)
            text_integral_number:scheduleUpdate( function()
                curPoint = math.min(tonumber(text_integral_number:getString()) + step, point)
                text_integral_number:setString(tostring(curPoint))
                if curPoint >= point then
                    text_integral_number:unscheduleUpdate()
                end
            end )

            local rotation = image_zz:getRotation()

            if rotation < 0 then rotation = math.ceil(- rotation / 360) * 360 + rotation end
            rotation = math.fmod(rotation, 360)

            local fullRotationCount = 5

            local dstRotation = fullRotationCount * 360 +(awardIndex + math.random(25, 75) / 100) * 360 / 8
            local rotateAction = cc.RotateBy:create(3, dstRotation - rotation)

            local morethenone = #utils.stringSplit(awards, ";") > 1
            local delayTime = morethenone and 0.8 * 9 or 1.4

            image_zz:runAction(cc.Sequence:create(
            cc.EaseCubicActionOut:create(rotateAction),
            cc.CallFunc:create( function()
                image_xz:unscheduleUpdate()

                local function walkImage(image, thing)
                    thing = utils.stringSplit(thing, "_")
                    if thing[4] == "1" then addParticleEffect(image) end
                end

                if morethenone then
                    utils.showGetThings(awards, 0.2, 0.6, 0.2, walkImage)
                else
                    utils.showGetThings(awards, 0.3, 0.8, 0.3, walkImage)
                end
                UIManager.flushWidget(UIBag)
                UIManager.flushWidget(UITeamInfo)
            end ),
            cc.DelayTime:create(delayTime),
            cc.CallFunc:create( function()
                refreshCommon(common)
                refreshLimit(limit)
                ui.refreshOrStartOneOrTen = false
            end )
            ))
            image_xz:scheduleUpdate( function()
                rotation = image_zz:getRotation()
                if rotation < 0 then rotation = math.ceil(- rotation / 360) * 360 + rotation end
                local index = math.floor(math.fmod(rotation, 360) * 8 / 360)
                image_xz:show():setRotation((index - 4) * 360 / 8)
            end )
        end
    end
end

local function sendPacket(openType)
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.activityLuck, msgdata = { int = { type = openType } } }, netCallbackFunc)
end

function ui.init()
    ui.open = false
    local btn_help = ccui.Helper:seekNodeByName(ui.Widget, "btn_help")
    local btn_recharge = ccui.Helper:seekNodeByName(ui.Widget, "btn_recharge")
    local btn_one = ccui.Helper:seekNodeByName(ui.Widget, "btn_one")
    local btn_ten = ccui.Helper:seekNodeByName(ui.Widget, "btn_ten")
    local btn_reward = ccui.Helper:seekNodeByName(ui.Widget, "btn_reward")
    local image_basemap_l = ui.Widget:getChildByName("image_basemap_l")
    local panel = image_basemap_l:getChildByName("panel")

    local function touchevent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            if not ui.open then return end
            if sender == btn_recharge then
                utils.checkGOLD(1)
            elseif sender == btn_help then
                UIAllianceHelp.show( { titleName = Lang.ui_activity_luckdial14, type = 3 })
            elseif sender == btn_reward then
                UIManager.pushScene("ui_activity_luckdial_preview")
            elseif sender == btn_one or sender == btn_ten then
                local image_zz = ccui.Helper:seekNodeByName(ui.Widget, "image_zz")
                if ui.refreshOrStartOneOrTen or image_zz:getNumberOfRunningActions() > 0 then
                    UIManager.showToast(Lang.ui_activity_luckdial15)
                    return
                end
                ui.refreshOrStartOneOrTen = true
                local openType, cost
                if sender == btn_one then
                    openType = ui.OPEN_TYPE_START_ONE
                    cost = ui.oneCost
                else
                    openType = ui.OPEN_TYPE_START_TEN
                    cost = ui.tenCost
                end

                local freeStart = sender == btn_one and ui.startRemain > 0

                if freeStart or net.InstPlayer.int["5"] >= cost then
                    sendPacket(openType)
                else
                    UIManager.showToast(Lang.ui_activity_luckdial16)
                    ui.refreshOrStartOneOrTen = false
                end
            elseif sender == panel then
                local image_zz = ccui.Helper:seekNodeByName(ui.Widget, "image_zz")
                if ui.refreshOrStartOneOrTen or image_zz:getNumberOfRunningActions() > 0 then
                    UIManager.showToast(Lang.ui_activity_luckdial17)
                    return
                end
                ui.refreshOrStartOneOrTen = true
                if ui.refreshRemain > 0 or net.InstPlayer.int["5"] >= ui.refreshCost then
                    sendPacket(ui.OPEN_TYPE_REFRESH)
                else
                    UIManager.showToast(Lang.ui_activity_luckdial18)
                    ui.refreshOrStartOneOrTen = false
                end
            end
        end
    end

    btn_help:addTouchEventListener(touchevent)
    btn_recharge:addTouchEventListener(touchevent)
    btn_reward:addTouchEventListener(touchevent)
    panel:addTouchEventListener(touchevent)
    btn_one:addTouchEventListener(touchevent)
    btn_ten:addTouchEventListener(touchevent)
end

function ui.setup()
    ui.open = false
    sendPacket(ui.OPEN_TYPE_OPEN_ACTIVITY)
    local text_jin_number = ccui.Helper:seekNodeByName(ui.Widget, "text_jin_number")
    text_jin_number:scheduleUpdate( function()
        local gold = net.InstPlayer.int["5"]
        text_jin_number:setString(tostring(gold))
    end )
    UIHomePage.luckyFlag = false
    UIActivityPanel.addImageHint(UIHomePage.luckyFlag, "lucky")
end

function ui.free()
    ui.open = false
    ui.refreshOrStartOneOrTen = false
    local view_people = ccui.Helper:seekNodeByName(ui.Widget, "view_people")
    local item = view_people:getChildByName("panel_people")
    if (item:getReferenceCount() == 1) then
        item:retain()
    end
    view_people:removeAllChildren()
    view_people:addChild(item)
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(ANI_LUNPAN_PATH)
end




