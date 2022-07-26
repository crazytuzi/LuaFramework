require"Lang"
UIFightPreView = { }

local scrollView = nil
local listItem = nil
local start_x, start_y = nil, nil
local dropThing = { }
local chapter = { }
UIFightPreView.wingTo = false
local function netCallbackFunc(pack)
    if tonumber(pack.header) == StaticMsgRule.buyEliteFightNum then
        UIManager.flushWidget(UIFight)
        UIManager.flushWidget(UITeamInfo)
        UIManager.flushWidget(UIBagWing)
    end
    -- UIMenu.showUIFightDot()
end

--- 重置精英关卡挑战次数
local function sendEliteBarrierTimeRequest(_instPlayerChapterTypeId)
    local sendData = {
        header = StaticMsgRule.buyEliteFightNum,
        msgdata =
        {
            int =
            {
                instPlayerChapterTypeId = _instPlayerChapterTypeId,
            }
        }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end

local function setScrollViewItem(_item, objTable)
    local thingIcon = _item:getChildByName("image_good")
    local thingName = thingIcon:getChildByName("text_good_name")
    local tableTypeId, tableFieldId, thingNum = objTable[1], objTable[2], objTable[3]
    local name, Icon = utils.getDropThing(tableTypeId, tableFieldId)
    thingName:setString(name)
    thingIcon:loadTexture(Icon)
    utils.addBorderImage(tableTypeId, tableFieldId, _item)
    utils.showThingsInfo(thingIcon, tableTypeId, tableFieldId) --zy 精英副本奖励预览中查看详细
end

  

local function scrollviewUpdate()
    for key, obj in pairs(dropThing) do
        local Item = listItem:clone()
        setScrollViewItem(Item, obj)
        scrollView:addChild(Item)
    end
end

function UIFightPreView.init()
    local btn_close = ccui.Helper:seekNodeByName(UIFightPreView.Widget, "btn_close")
    local btn_fight = ccui.Helper:seekNodeByName(UIFightPreView.Widget, "btn_fight")
    local function TouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                AudioEngine.playEffect("sound/button.mp3")
                UIManager.popScene()
                if UIFightPreView.wingTo then
                    UIManager.showWidget("ui_notice", "ui_lineup")
                    UIManager.showWidget("ui_menu")
                    UILineup.toWingInfo()
                end
            elseif sender == btn_fight then
                AudioEngine.playEffect("sound/fight.mp3")
                if UIFight.EliteBarrierTimes > 0 then
                    local nowLevel = net.InstPlayer.int["4"]
                    for key, obj in pairs(DictBarrierLevel) do
                        if obj.barrierId == chapter.barrierId then
                            if nowLevel >= chapter.openLevel then
                                chapter.barrierLevelId = obj.id
                                -----进入战斗---------------
                                local barrierId = nil
                                local chapterId = nil
                                for key, obj_lv in pairs(DictBarrierLevel) do
                                    if obj_lv.id == chapter.barrierLevelId then
                                        barrierId = obj_lv.barrierId
                                    end
                                end
                                for key, obj_barrier in pairs(DictBarrier) do
                                    if obj_barrier.id == barrierId then
                                        chapterId = obj_barrier.chapterId
                                    end
                                end

                                UIManager.popScene()
                                chapter.chapterId = chapterId
                                chapter.barrierId = barrierId
                                --xzli todo more
                                local chapterIdInt = tonumber(chapterId)
                                -- 神羽溶洞 关卡取值范围
                                if chapterIdInt >= 300 and chapterIdInt < 400 then
                                    utils.sendFightData(chapter, dp.FightType.FIGHT_WING)
                                else
                                    utils.sendFightData(chapter, dp.FightType.FIGHT_TASK.ELITE)
                                end
                                UIFightMain.loading()
                            else
                                UIManager.showToast(Lang.ui_fight_preview1)
                            end
                        end
                    end
                else
                    local eliteBarrierNum = 0
                    local eliteBuyNum = 0
                    if net.InstPlayerChapterType then
                        for key, obj in pairs(net.InstPlayerChapterType) do
                            if UIFight.selectedPickFlag == 1 then
                                if obj.int["3"] == 2 then
                                    eliteBarrierNum = obj.int["4"]
                                    eliteBuyNum = obj.int["6"]
                                end
                            elseif UIFight.selectedPickFlag == 2 then
                                if obj.int["3"] == 4 then
                                    eliteBarrierNum = obj.int["4"]
                                    eliteBuyNum = obj.int["6"]
                                end
                            end
                        end
                    end
                    if eliteBarrierNum == nil then
                        eliteBarrierNum = 0
                    end
                    if eliteBuyNum == nil then
                        eliteBuyNum = 0
                    end
                    local baseMoney = DictSysConfig[tostring(StaticSysConfig.chapterEliteBuyGold)].value
                    local oneAddMoney = DictSysConfig[tostring(StaticSysConfig.chapterEliteBuyGoldAdd)].value
                    local eliteBuyBarrierTimeMoney = baseMoney + eliteBuyNum * oneAddMoney
                    local _instPlayerChapterTypeId = nil
                    for key,obj in pairs(net.InstPlayerChapterType) do
                        if UIFight.selectedPickFlag == 1 then
                            if obj.int["3"] == 2 then
                                  _instPlayerChapterTypeId = obj.int["1"]
                            end
                        elseif UIFight.selectedPickFlag == 2 then
                            if obj.int["3"] == 4 then
                                  _instPlayerChapterTypeId = obj.int["1"]
                            end
                        end
                    end
                    local VipNum = net.InstPlayer.int["19"]
                    local VipTime = 0
                    local prompt = ""
                    if UIFight.selectedPickFlag == 2 then
                        --fiendChapterNum
                        VipTime = DictVIP[tostring(VipNum+1)].fiendChapterNum - DictSysConfig[ tostring(StaticSysConfig.chapterEliteNum)].value
                        prompt = Lang.ui_fight_preview2 .. eliteBuyBarrierTimeMoney ..Lang.ui_fight_preview3 .. eliteBuyNum .. Lang.ui_fight_preview4 .. VipNum .. Lang.ui_fight_preview5 .. VipTime ..Lang.ui_fight_preview6
                    else
                        VipTime = DictVIP[tostring(VipNum+1)].eliteChapterBuyTimes - DictSysConfig[ tostring(StaticSysConfig.chapterEliteNum)].value
                        prompt = Lang.ui_fight_preview7 .. eliteBuyBarrierTimeMoney ..Lang.ui_fight_preview8 .. eliteBuyNum .. Lang.ui_fight_preview9 .. VipNum .. Lang.ui_fight_preview10 .. VipTime ..Lang.ui_fight_preview11
                    end
                    if _instPlayerChapterTypeId ~= nil then
                        if eliteBuyNum < VipTime then
                            utils.PromptDialog(sendEliteBarrierTimeRequest, prompt, _instPlayerChapterTypeId)
                        else
                            UIManager.showToast(Lang.ui_fight_preview12)
                        end
                    else
                        UIManager.showToast(Lang.ui_fight_preview13)
                    end
                end
            end
        end
    end
    btn_close:addTouchEventListener(TouchEvent)
    btn_fight:addTouchEventListener(TouchEvent)
    scrollView = ccui.Helper:seekNodeByName(UIFightPreView.Widget, "view_preview")
    listItem = scrollView:getChildByName("image_frame_good"):clone()
    start_x, start_y = scrollView:getChildByName("image_frame_good"):getPosition()
    if listItem:getReferenceCount() == 1 then
        listItem:retain()
    end
end

function UIFightPreView.setup()
    UIGuidePeople.isGuide(nil, UIFightPreView)
    scrollView:removeAllChildren()
    local image_boss = ccui.Helper:seekNodeByName(UIFightPreView.Widget, "image_boss")
    local text_boss_name = ccui.Helper:seekNodeByName(UIFightPreView.Widget, "text_boss_name")
    local text_exp = ccui.Helper:seekNodeByName(UIFightPreView.Widget, "text_vigour")
    local text_gold = ccui.Helper:seekNodeByName(UIFightPreView.Widget, "text_gold")
    dropThing = { }
    if chapter.barrierId ~= nil then
        local cardId = DictBarrier[tostring(chapter.barrierId)].cardId
        cclog(chapter.barrierId)
        local bigUiId = DictCard[tostring(cardId)].bigUiId
        local imageName = DictUI[tostring(bigUiId)].fileName
        local bossName = DictBarrier[tostring(chapter.barrierId)].name
        local things = DictBarrier[tostring(chapter.barrierId)].things
        local thingsTable = utils.stringSplit(things, ";")

        local soulSourceCount = 0
        local key1, key2 = tostring(StaticTableType.DictThing), tostring(StaticThing.soulSource)
        for key, obj in pairs(thingsTable) do
            local thing = utils.stringSplit(obj, "_")

            if thing[1] == key1 and thing[2] == key2 then
                soulSourceCount = soulSourceCount + tonumber(thing[3])
            else
                dropThing[#dropThing + 1] = thing
            end
        end
        local exp = DictLevelProp[tostring(net.InstPlayer.int["4"])].oneEliteWarExp
        if UIFight.selectedPickFlag == 2 then
            exp = 0
        end
        image_boss:loadTexture("image/" .. imageName)
        text_boss_name:setString(bossName)

        text_exp:setString("×" .. exp)
        text_gold:setString("×" .. soulSourceCount)
    end
    if next(dropThing) then
        scrollviewUpdate()
        local innerHeight, space = 0, 40
        local childs = scrollView:getChildren()
        local line = 0

        if #childs % 4 ~= 0 then
            line = math.floor(#childs / 4) + 1
        else
            line = #childs / 4
        end
        innerHeight =(listItem:getContentSize().height + space) * line
        if innerHeight < scrollView:getContentSize().height then
            innerHeight = scrollView:getContentSize().height
        end
        scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, innerHeight))
        local preChild = nil
        local pos_x, pos_y = start_x, innerHeight - listItem:getContentSize().height / 2
        for j = 1, line do
            for k = 1, 4 do
                if (4 *(j - 1) + k) <= #childs then
                    childs[4 *(j - 1) + k]:setPosition(cc.p(pos_x, pos_y))
                    if k == 4 then
                        preChild = childs[4 *(j - 1) + k - 3]
                        pos_y = preChild:getBottomBoundary() - space - listItem:getContentSize().height / 2
                        pos_x = start_x
                    else
                        preChild = childs[4 *(j - 1) + k]
                        pos_x = preChild:getRightBoundary() + space + listItem:getContentSize().width / 2
                    end
                end
            end
        end
    end
end

function UIFightPreView.setChapterId(_chapterId)
    chapter.chapterId = _chapterId
    for key, obj in pairs(DictBarrier) do
        if chapter.chapterId == obj.chapterId then
            chapter.barrierId = obj.id
            chapter.openLevel = obj.openLevel
        end
    end
end

function UIFightPreView.free(...)
    if listItem and listItem:getReferenceCount() >= 1 then
        listItem:release()
        listItem = nil
    end
    if scrollView then
        scrollView:removeAllChildren()
        scrollView = nil
    end
end
