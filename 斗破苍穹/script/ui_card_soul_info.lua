require"Lang"
UICardSoulInfo = {
    TYPE =
    {
        BARRIER = 1,
        HEIJIAOYU = 2,
        ARENA = 3,
        MINE_WAR = 4,
        BOSS_SHOP = 5,
        ALLIANCE_SHOP = 6,
        RECRUIT = 7,
        ACTIVITY = 8,
    },
}

local ui = UICardSoulInfo

local scrollViewItem

function ui.init()
    local cardJumpData = UICardInfo.getCardJumpMap()[ui.dictCardId]
    local jumpPosIds = cardJumpData.jumpPosIds
    local cardData = DictCard[tostring(ui.dictCardId)]
    local cardSoulData = DictCardSoul[tostring(ui.dictCardId)]

    local image_base_card = ccui.Helper:seekNodeByName(ui.Widget, "image_base_card")
    local image_frame_card = image_base_card:getChildByName("image_frame_card")
    local text_name_card = image_base_card:getChildByName("text_name_card")
    local text_number = image_base_card:getChildByName("text_number")
    local text_card_number = image_base_card:getChildByName("image_base_di"):getChildByName("text_card_number")
    local image_card = image_frame_card:getChildByName("image_card")
    local image_tj = image_base_card:getChildByName("imagt_tj")

    image_frame_card:loadTexture(utils.getQualityImage(dp.Quality.card, cardData.qualityId, dp.QualityImageType.small))
    image_card:loadTexture("image/" .. DictUI[tostring(cardData.smallUiId)].fileName)
    text_name_card:setTextColor(utils.getQualityColor(cardData.qualityId))
    local oldWidth = text_name_card:getContentSize().width
    text_name_card:setString(cardSoulData.name)

    if cardJumpData.commendType > 0 then
        local newWidth = text_name_card:getContentSize().width
        image_tj:show():loadTexture(cardJumpData.commendType == 1 and "ui/tj.png" or "ui/qltj.png")
        image_tj:setPositionX(image_tj:getPositionX() + newWidth - oldWidth)
    else
        image_tj:hide()
    end

    text_card_number:setString(cardSoulData.description)
    text_number:setString(Lang.ui_card_soul_info1 .. utils.getCardSoulCount(cardData.id))

    local view = ccui.Helper:seekNodeByName(ui.Widget, "view")
    scrollViewItem = view:getChildByName("image_term")
    scrollViewItem:retain()
    view:removeAllChildren()

    ui.Widget:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
        end
    end )

    local list = { }
    local requestServerList = nil
    jumpPosIds = utils.stringSplit(jumpPosIds, ";")
    for i, strId in ipairs(jumpPosIds) do
        local obj = DictCardJumpPos[strId]
        local data = { }
        table.insert(list, data)
        data.imagePath = "image/" .. DictUI[tostring(obj.uiId)].fileName
        data.open = true
        data.type = obj.type
        data.rank = obj.rank
        if obj.type == ui.TYPE.BARRIER then
            data.title1 = Lang.ui_card_soul_info2
            local barrier = DictBarrier[tostring(obj.value)]
            local chapter = DictChapter[tostring(barrier.chapterId)]
            data.title2 = string.format(Lang.ui_card_soul_info3, chapter.name, barrier.name)
            data.open = net.InstPlayer.int["4"] >= chapter.openLeve
            if net.InstPlayerChapter and data.open and DictChapter[tostring(chapter.id - 1)] then
                for key, obj in pairs(net.InstPlayerChapter) do
                    if obj.int["3"] == chapter.id - 1 then
                        data.open = obj.int["6"] == 1
                        break
                    end
                end
            end

            if data.open then
                data.open = false
                if net.InstPlayerBarrier then
                    for key, obj in pairs(net.InstPlayerBarrier) do
                        if obj.int["5"] == barrier.chapterId then
                            local barrierId = obj.int["3"]
                            if barrierId == barrier.id then
                                data.open = true
                                break
                            end
                        end
                    end
                else
                    local DictMinBarrierId = 10000
                    for key, obj in pairs(DictBarrier) do
                        if obj.chapterId == barrier.chapterId then
                            if DictMinBarrierId > obj.id then
                                DictMinBarrierId = obj.id
                            end
                        end
                    end
                    data.open = DictMinBarrierId == barrier.id
                end
            end

            if data.open then
                data.barrier = barrier
                data.chapterId = barrier.chapterId
                for key, obj in pairs(net.InstPlayerBarrier) do
                    if obj.int["5"] == barrier.chapterId and obj.int["3"] == barrier.id then
                        data.barrier = obj
                        break
                    end
                end
            end
        else
            data.title1 = obj.title1 or ""
            data.title2 = obj.title2 or ""
            if obj.type == ui.TYPE.ARENA then
                data.open = net.InstPlayer.int["4"] >= DictFunctionOpen[tostring(StaticFunctionOpen.area)].level

                for key, obj in pairs(DictArenaConvert) do
                    if obj.tableTypeId == StaticTableType.DictCardSoul and obj.tableFieldId == ui.dictCardId then
                        data.cur = 0
                        data.max = obj.convertNum
                        if net.InstPlayerArenaConvert then
                            for k, o in pairs(net.InstPlayerArenaConvert) do
                                if obj.id == o.int["3"] then
                                    data.cur = o.int["4"]
                                    break
                                end
                            end
                        end
                        break
                    end
                end
            elseif obj.type == ui.TYPE.MINE_WAR then
                data.open = net.InstPlayer.int["4"] >= DictFunctionOpen[tostring(StaticFunctionOpen.mine)].level
            elseif obj.type == ui.TYPE.BOSS_SHOP then
                data.open = net.InstPlayer.int["4"] >= DictFunctionOpen[tostring(StaticFunctionOpen.worldBoss)].level
            elseif obj.type == ui.TYPE.HEIJIAOYU then
                data.open = net.InstPlayer.int["4"] >= DictFunctionOpen[tostring(StaticFunctionOpen.hJYStoreLevel)].level
            elseif obj.type == ui.TYPE.ALLIANCE_SHOP then
                data.open = net.InstUnionMember ~= nil
                if data.open then
                    requestServerList = requestServerList or { }
                    requestServerList[strId] = data
                end
            end
        end
    end

    utils.quickSort(list, function(key, other) return key.rank > other.rank end)
    ui.list = list
    ui.requestServerList = requestServerList
end

local function setScrollViewItem(item, data)
    local image_title = item:getChildByName("image_title")
    local text_title1 = item:getChildByName("text_title1")
    local text_title2 = item:getChildByName("text_title2")
    local image_closed = item:getChildByName("image_closed")
    local image_go = item:getChildByName("image_go")
    local text_number = item:getChildByName("text_number")

    text_title1:enableOutline(display.COLOR_WHITE, 2)

    image_title:loadTexture(data.imagePath)
    text_title1:setString(data.title1)
    text_title2:setString(data.title2)
    if data.open then
        image_closed:hide()

        if data.type ~= ui.TYPE.ACTIVITY then
            image_go:setTouchEnabled(true)
            image_go:show():addTouchEventListener( function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    if data.type == ui.TYPE.HEIJIAOYU then
                        UIActivityPanel.scrollByName("hJYStore", "hJYStore")
                        UIManager.showWidget("ui_activity_panel")
                    elseif data.type == ui.TYPE.BARRIER then
                        UIFightTask.setChapterId(data.chapterId)
                        UIManager.showScreen("ui_fight_task")
                        UIFightTaskChoose.setData(data.barrier)
                        UIManager.pushScene("ui_fight_task_choose")
                    elseif data.type == ui.TYPE.ARENA then
                        UIArena.showExchangeFirst = true
                        UIManager.showScreen("ui_notice", "ui_arena", "ui_menu")
                    elseif data.type == ui.TYPE.MINE_WAR then
                        UIManager.showScreen("ui_notice", "ui_ore")
                    elseif data.type == ui.TYPE.BOSS_SHOP then
                        if UIBossShop.Widget and UIBossShop.Widget:getParent() then
                            while UIManager.getPopWindowCount() > 1 do
                                UIManager.popScene(true)
                            end
                            return
                        end
                        
                        UIManager.showScreen("ui_notice", "ui_boss", "ui_menu")
                        local btn_shop = ccui.Helper:seekNodeByName(UIBoss.Widget, "btn_shop")
                        btn_shop:runAction(cc.Sequence:create(cc.DelayTime:create(0.05), cc.CallFunc:create( function()
                            btn_shop:releaseUpEvent()
                        end )))
                    elseif data.type == ui.TYPE.ALLIANCE_SHOP then
                        if UIAllianceShop.Widget and UIAllianceShop.Widget:getParent() then
                            UIManager.popAllScene(true)
                            return
                        end
                        UIManager.showLoading()
                        netSendPackage( {
                            header = StaticMsgRule.unionDetail,
                            msgdata = { int = { instUnionMemberId = net.InstUnionMember.int["1"] } }
                        } , function(pack)
                            UIAllianceShop.showLMLFirst = true
                            UIAllianceShop.showScreen( { unionDetail = UIAlliance.getUnionDetail(pack) })
                        end )
                    elseif data.type == ui.TYPE.RECRUIT then
                        UIManager.showScreen("ui_notice", "ui_shop", "ui_menu")
                    end
                end
            end )
            if image_go:getNumberOfRunningActions() <= 0 then
                local afAction = cc.RepeatForever:create(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.8, cc.p(image_go:getPositionX() + 30, image_go:getPositionY())), cc.FadeOut:create(1)), cc.DelayTime:create(0.1), cc.CallFunc:create( function()
                    image_go:setPositionX(image_go:getPositionX() -30)
                    image_go:setOpacity(255)
                end )))
                image_go:runAction(afAction)
            end
        else
            image_go:hide()
        end

        if data.cur and data.max then
            text_number:show():setString(string.format("（%d/%d）", data.cur, data.max))
        else
            text_number:hide()
        end
    else
        image_closed:show()
        image_go:hide()
        text_number:hide()
    end
end

function ui.setup()
    if ui.requestServerList then
        UIManager.showLoading()
        netSendPackage( { header = StaticMsgRule.exchangeTimes, msgdata = { int = { id = UICardInfo.getCardJumpMap()[ui.dictCardId].id } } }, function(pack)
            local exchangeTimes = utils.stringSplit(pack.msgdata.string["1"], ";")
            for i, obj in ipairs(exchangeTimes) do
                local data = utils.stringSplit(obj, "_")
                local o = ui.requestServerList[data[1]]
                if o then
                    o.cur = tonumber(data[2])
                    o.max = tonumber(data[3])
                end
            end
            ui.requestServerList = nil
            UIManager.flushWidget(ui)
        end )
        return
    end

    local view = ccui.Helper:seekNodeByName(ui.Widget, "view")
    view:removeAllChildren()
    utils.updateScrollView(ui, view, scrollViewItem, ui.list, setScrollViewItem, { space = 4 })

    local image_wing_di = ccui.Helper:seekNodeByName(ui.Widget, "image_wing_di")
    image_wing_di:scheduleUpdate( function(dt)
        if view:isEnabled() then
            local children = view:getChildren()
            for i, child in ipairs(children) do
                if child:getNumberOfRunningActions() > 0 then
                    return
                end
            end
            local size = view:getContentSize()
            size.width = 520
            view:setContentSize(size)
            image_wing_di:unscheduleUpdate()
        end
    end )
end

function ui.free()
    ui.dictCardId = nil
    ui.list = nil
    ui.requestServerList = nil
    if scrollViewItem and scrollViewItem:getReferenceCount() >= 1 then
        scrollViewItem:release()
        scrollViewItem = nil
    end
end
