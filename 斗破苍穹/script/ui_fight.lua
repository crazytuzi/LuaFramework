require"Lang"
UIFight = { }
local btnSelected = nil
local btnSelectedText = nil
local scrollView = nil
local listItem = nil
local selectedFlag = 2
UIFight.selectedPickFlag = 1
local ui_elite_leftNum = nil
local maxDictThing = nil  --- 实例数据中的最大实例id
local lastThing = nil --- 最后一个章节
local justOpenThing = nil --- 刚开启的章节
UIFight.EliteBarrierTimes = 0 ----精英挑战剩余次数
local eliteBuyBarrierTimeMoney = 0 --- 购买精英挑战次数花的钱
local eliteBarrierNum = 0  ---- 精英副本挑战次数
local eliteBuyNum = 0   --- 精英副本购买次数
local function netCallbackFunc(pack)
    if tonumber(pack.header) == StaticMsgRule.buyEliteFightNum then
        UIManager.flushWidget(UIFight)
        UIManager.flushWidget(UITeamInfo)
    elseif tonumber(pack.header) == StaticMsgRule.buyActivityFightNum then
        UIManager.flushWidget(UIFight)
        UIManager.flushWidget(UITeamInfo)
        UIManager.flushWidget(UIFightActivityChoose)
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
--- 重置活动关卡挑战次数
function UIFight.sendActivityBarrierTimeRequest(_instPlayerChapterId)
    local sendData = {
        header = StaticMsgRule.buyActivityFightNum,
        msgdata =
        {
            int =
            {
                instPlayerChapterId = _instPlayerChapterId,
            }
        }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end
local function compare(value1, value2)
    if selectedFlag == 2 then
        return DictChapter[tostring(value1.int["3"])].id < DictChapter[tostring(value2.int["3"])].id
    elseif selectedFlag == 1 then
        return value1.id < value2.id
    end
end
local function selectedBtnChange(flag)
    local btn_fight_elite = ccui.Helper:seekNodeByName(UIFight.Widget, "btn_fight_elite")
    local btn_fight_common = ccui.Helper:seekNodeByName(UIFight.Widget, "btn_fight_common")
    local btn_fight_activity = ccui.Helper:seekNodeByName(UIFight.Widget, "btn_fight_activity")
    btnSelected:loadTextureNormal("ui/tk_j_btn02.png")
    btnSelectedText:setTextColor(cc.c4b(255, 255, 255, 255))
    if flag == 1 then
        btnSelected = btn_fight_elite
        btnSelectedText = btn_fight_elite:getChildByName("text_fight_elite")
        btn_fight_elite:loadTextureNormal("ui/tk_j_btn01.png")
        btn_fight_elite:getChildByName("text_fight_elite"):setTextColor(cc.c4b(51, 25, 4, 255))
    elseif flag == 2 then
        btnSelected = btn_fight_common
        btnSelectedText = btn_fight_common:getChildByName("text_fight_common")
        btn_fight_common:loadTextureNormal("ui/tk_j_btn01.png")
        btn_fight_common:getChildByName("text_fight_common"):setTextColor(cc.c4b(51, 25, 4, 255))
    elseif flag == 3 then
        btnSelected = btn_fight_activity
        btnSelectedText = btn_fight_activity:getChildByName("text_fight_activity")
        btn_fight_activity:loadTextureNormal("ui/tk_j_btn01.png")
        btn_fight_activity:getChildByName("text_fight_activity"):setTextColor(cc.c4b(51, 25, 4, 255))
    end
    UIFight.checkImageHint()
end

local function showUIFightDot(item, chapterId)
    local state = nil
    if net.InstPlayerChapter then
        for key, obj in pairs(net.InstPlayerChapter) do
            local barrierNum = obj.int["5"]
            if chapterId == obj.int["3"] then
                local getThingTable = { }
                local star = { }
                local boxThing = { }
                for _key, _obj in pairs(DictBarrier) do
                    if _obj.chapterId == chapterId and _obj.welfareBox ~= "" then
                        table.insert(boxThing, _obj)
                    end
                end
                for _key, _obj in pairs(boxThing) do
                    if net.InstPlayerBarrier then
                        for _, obj1 in pairs(net.InstPlayerBarrier) do
                            if obj1.int["5"] == chapterId and obj1.int["3"] == _obj.id then
                                if obj1.int["9"] == 1 then
                                    state = true
                                    break
                                end
                            end
                        end
                    end
                    if state then
                        break
                    end
                end
                if state then
                    break
                end
                star[1] = DictChapter[tostring(chapterId)].starOne
                star[2] = DictChapter[tostring(chapterId)].starTwo
                star[3] = DictChapter[tostring(chapterId)].starThree
                if obj.string ~= nil then
                    if obj.string["7"] then
                        getThingTable = utils.stringSplit(obj.string["7"], ";")
                    end
                end
                local num = 0
                for _, _obj in pairs(star) do
                    if _obj ~= 0 then
                        num = num + 1
                    end
                end

                if star[3] ~= 0 and barrierNum >= star[3] and #getThingTable < num then
                    state = true
                elseif star[2] ~= 0 and barrierNum >= star[2] and #getThingTable < num - 1 then
                    state = true
                elseif star[1] ~= 0 and barrierNum >= star[1] and #getThingTable < num - 2 then
                    state = true
                end
                break
            end
        end
    end
    if state then
        item:getChildByName("image_hint"):setVisible(true)
    else
        item:getChildByName("image_hint"):setVisible(false)
    end
end 

local function ItemTouchEvent(sender, eventType)
    sender:retain()
    if eventType == ccui.TouchEventType.began then
        sender:setScale(1.05)
    elseif eventType == ccui.TouchEventType.ended then
        sender:setScale(1)
        AudioEngine.playEffect("sound/bar.mp3")
        local chapterId = sender:getTag()
        local InstPlayerlevel = net.InstPlayer.int["4"]
        --- 玩家等级
        local openLevel = DictChapter[tostring(chapterId)].openLeve
        -- 开启等级
        if InstPlayerlevel < openLevel then
            UIManager.showToast(Lang.ui_fight1 .. openLevel .. Lang.ui_fight2)
            cc.release(sender)
            return
        end
        if selectedFlag == 1 then
            if DictChapter[tostring(chapterId - 1)] and DictChapter[tostring(chapterId - 1)].type == 2 then
                local find = false
                for key, InstPlayerChapterObj in pairs(net.InstPlayerChapter) do
                    if tonumber(InstPlayerChapterObj.int["3"]) ==(chapterId - 1) then
                        -- 判断是否开启
                        find = true
                        if InstPlayerChapterObj.int["6"] == 1 then
                            -- 判断普通章节是否通关
                            UIFightPreView.setChapterId(chapterId)
                            UIManager.pushScene("ui_fight_preview")
                        else
                            UIManager.showToast(Lang.ui_fight3 .. DictChapter[tostring(chapterId - 1)].name)
                        end
                    end
                end
                if find == false then
                    UIManager.showToast(Lang.ui_fight4 .. DictChapter[tostring(chapterId - 1)].name)
                end
            else
                UIFightPreView.setChapterId(chapterId)
                UIManager.pushScene("ui_fight_preview")
            end

        elseif selectedFlag == 2 then
            UIFightTask.setChapterId(chapterId)
            UIManager.showScreen("ui_fight_task")
        elseif selectedFlag == 3 then
            local onEnterChooseUI = function(_things)
                UIFightActivityChoose.setChapter(chapterId, 3, _things)
                UIManager.pushScene("ui_fight_activity_choose")
            end
            if chapterId == DictSysConfig[tostring(StaticSysConfig.wysm)].value then
                local sendData = {
                    header = StaticMsgRule.sendSoulActivityChapterSoul,
                    msgdata = { }
                }
                UIManager.showLoading()
                netSendPackage(sendData, function(_msgData)
                    local _things = { }
                    for _i = 1, 3 do
                        _things[_i] = _msgData.msgdata.string[tostring(_i)]
                    end
                    onEnterChooseUI(_things)
                    _things = nil
                end )
            elseif chapterId == DictSysConfig[tostring(StaticSysConfig.jxcl)].value then
                AudioEngine.playEffect("sound/fight.mp3")
                local DictChapterObj = DictChapter[tostring(chapterId)]
                local haveBarrierNum =0
                if net.InstPlayerChapter then
                    for key,ActivityObj in pairs(net.InstPlayerChapter) do
                        if ActivityObj.int["3"] == DictChapterObj.id then
                            haveBarrierNum = ActivityObj.int["4"]
                            break
                        end
                    end
                end
                local activityBarrierTimes = DictChapterObj.fightNum - haveBarrierNum
                local VipNum = net.InstPlayer.int["19"] 
                if VipNum >= 0 then
                   activityBarrierTimes = activityBarrierTimes + DictVIP[tostring(VipNum + 1)].awareChapterNum
                end
                local chapter = {}
                chapter.chapterId = chapterId
                for key,obj in pairs(DictBarrier) do
                    if chapterId == obj.chapterId then
                        chapter.barrierId = obj.id
                        chapter.openLevel = obj.openLevel
                        break
                    end
                end
                if activityBarrierTimes > 0 then
                    local nowLevel = net.InstPlayer.int["4"]
                    if nowLevel >= chapter.openLevel then 
                        for key,obj in pairs(DictBarrierLevel) do
                            if obj.barrierId == chapter.barrierId then 
                                chapter.barrierLevelId = obj.id
                            end
                        end
                        utils.sendFightData(chapter,dp.FightType.FIGHT_TASK.ACTIVITY)
                        UIFightMain.loading()
                    else
                        UIManager.showToast(string.format(Lang.ui_fight5,chapter.openLevel))
                    end
                else
                    UIManager.showToast(Lang.ui_fight6)
                end
            else
                onEnterChooseUI()
            end
        end
    else
        sender:setScale(1)
    end
    cc.release(sender)
end
----最后一条数据的事件----
local function lastItemTouchEvent(sender, eventType)
    sender:retain()
    if eventType == ccui.TouchEventType.began then
        sender:setScale(1.05)
    elseif eventType == ccui.TouchEventType.ended then
        sender:setScale(1)
        AudioEngine.playEffect("sound/bar.mp3")
        if selectedFlag == 1 then
            local chapterId = lastThing.id
            local InstPlayerlevel = net.InstPlayer.int["4"]
            --- 玩家等级
            local openLevel = DictChapter[tostring(chapterId)].openLeve
            -- 开启等级
            if InstPlayerlevel < openLevel then
                UIManager.showToast(Lang.ui_fight7 .. openLevel .. Lang.ui_fight8)
                cc.release(sender)
                return
            end
            if DictChapter[tostring(chapterId - 1)] and DictChapter[tostring(chapterId - 1)].type == 2 then
                local find = false
                for key, InstPlayerChapterObj in pairs(net.InstPlayerChapter) do
                    if tonumber(InstPlayerChapterObj.int["3"]) ==(chapterId - 1) then
                        -- 判断是否开启
                        find = true
                        if InstPlayerChapterObj.int["6"] == 0 then
                            -- 判断普通章节是否通关
                            UIManager.showToast(Lang.ui_fight9 .. DictChapter[tostring(chapterId - 1)].name .. Lang.ui_fight10)
                        else
                            UIManager.showToast(Lang.ui_fight11 .. DictChapter[tostring(lastThing.chapterId)].name .. Lang.ui_fight12)
                        end
                    end
                end
                if find == false then
                    UIManager.showToast(Lang.ui_fight13 .. DictChapter[tostring(chapterId - 1)].name .. Lang.ui_fight14)
                end
            else
                UIManager.showToast(Lang.ui_fight15 .. DictChapter[tostring(lastThing.chapterId)].name .. Lang.ui_fight16)
            end
        elseif selectedFlag == 2 then
            if justOpenThing ~= nil then
                UIManager.showToast(Lang.ui_fight17 .. justOpenThing.name .. Lang.ui_fight18)
            else
                UIManager.showToast(Lang.ui_fight19 .. maxDictThing.name .. Lang.ui_fight20)
            end

        end
    else
        sender:setScale(1)
    end
    cc.release(sender)
end
local function setScrollViewItem(flag, _Item, _obj)
    local btn_add_number = _Item:getChildByName("btn_add_number")
    --- 剩余次数
    local numberText = _Item:getChildByName("label_left_number")
    --- 剩余次数
    local image_base_star = _Item:getChildByName("image_base_star")
    --- 得星
    local image_base_di = _Item:getChildByName("image_base_di")
    local text_hint = image_base_di:getChildByName("text_hint")
    --- 开启条件
    local image_pass = _Item:getChildByName("image_pass")
    -- 已通关图片
    local image_win_di = _Item:getChildByName("image_win_di")
    local backGroundPictureS = nil
    if _obj.name ~= nil then
        if lastThing ~= nil and _obj.id == lastThing.id then
            _Item:addTouchEventListener(lastItemTouchEvent)
        else
            _Item:setTag(_obj.id)
            _Item:addTouchEventListener(ItemTouchEvent)
        end
        backGroundPictureS = DictChapter[tostring(_obj.id)].backGroundPictureS

    else
        _Item:setTag(_obj.int["3"])
        _Item:addTouchEventListener(ItemTouchEvent)
        backGroundPictureS = DictChapter[tostring(_obj.int["3"])].backGroundPictureS
    end
    _Item:loadTexture("image/" .. backGroundPictureS)
    _Item:getChildByName("image_hint"):setVisible(false)
    if flag == 1 then
        --- 精英副本
        image_pass:hide()
        image_win_di:hide()
        btn_add_number:setVisible(false)
        numberText:setVisible(false)
        image_base_star:setVisible(false)
        if UIFight.selectedPickFlag == 2 then
            local chapterId = _obj.id
            local InstPlayerlevel = net.InstPlayer.int["4"]
            --- 玩家等级
            local openLevel = DictChapter[tostring(chapterId)].openLeve
            -- 开启等级
            if InstPlayerlevel < openLevel then
                utils.GrayWidget(_Item, true)
                image_base_di:setVisible(true)
                text_hint:setString(Lang.ui_fight21 .. openLevel .. Lang.ui_fight22)
                return
            else
                utils.GrayWidget(_Item, false)
                image_base_di:setVisible(false)
            end

        else
            if lastThing ~= nil and _obj.id == lastThing.id then
                utils.GrayWidget(_Item, true)
                image_base_di:setVisible(true)
                local chapterId = lastThing.id
                local InstPlayerlevel = net.InstPlayer.int["4"]
                --- 玩家等级
                local openLevel = DictChapter[tostring(chapterId)].openLeve
                -- 开启等级
                if InstPlayerlevel < openLevel then
                    text_hint:setString(Lang.ui_fight23 .. openLevel .. Lang.ui_fight24)
                    return
                end
                if DictChapter[tostring(chapterId - 1)] and DictChapter[tostring(chapterId - 1)].type == 2 then
                    local find = false
                    for key, InstPlayerChapterObj in pairs(net.InstPlayerChapter) do
                        if tonumber(InstPlayerChapterObj.int["3"]) ==(chapterId - 1) then
                            -- 判断是否开启
                            find = true
                            if InstPlayerChapterObj.int["6"] == 0 then
                                -- 判断普通章节是否通关
                                text_hint:setString(Lang.ui_fight25 .. DictChapter[tostring(chapterId - 1)].name .. Lang.ui_fight26)
                            else
                                text_hint:setString(Lang.ui_fight27 .. DictChapter[tostring(lastThing.chapterId)].name .. Lang.ui_fight28)
                            end
                        end
                    end
                    if find == false then
                        text_hint:setString(Lang.ui_fight29 .. DictChapter[tostring(chapterId - 1)].name .. Lang.ui_fight30)
                    end
                else
                    text_hint:setString(Lang.ui_fight31 .. DictChapter[tostring(lastThing.chapterId)].name .. Lang.ui_fight32)
                end
            else
                image_base_di:setVisible(false)
                utils.GrayWidget(_Item, false)
            end
            if _Item:getTag() == 101 then
                UIGuidePeople.isGuide(_Item, UIFight)
            end
        end
    elseif flag == 2 then
        --- 普通副本
        if _obj.name ~= nil then
            if lastThing ~= nil and _obj.id == lastThing.id then
                image_win_di:setVisible(false)
                btn_add_number:setVisible(false)
                numberText:setVisible(false)
                image_base_star:setVisible(false)
                image_base_di:setVisible(true)
                image_pass:setVisible(false)
                utils.GrayWidget(_Item, true)
                if justOpenThing ~= nil then
                    text_hint:setString(Lang.ui_fight33 .. justOpenThing.name .. Lang.ui_fight34)
                else
                    text_hint:setString(Lang.ui_fight35 .. maxDictThing.name .. Lang.ui_fight36)
                end
            else
                utils.GrayWidget(_Item, false)
                image_base_di:setVisible(false)
                btn_add_number:setVisible(false)
                numberText:setVisible(false)
                image_base_star:setVisible(true)
                if _obj.starNum < 30 then
                    image_win_di:setVisible(false)
                else
                    image_win_di:setVisible(true)
                    image_win_di:getChildByName("label_number"):setString("0")
                end
                image_base_star:getChildByName("image_star_get"):getChildByName("text_number_get"):setString("0")
                image_base_star:getChildByName("image_star_all"):getChildByName("text_number_all"):setString("/" .. _obj.starNum)
                image_pass:setVisible(false)
                UIGuidePeople.isGuide(_Item, UIFight)
            end
        else
            utils.GrayWidget(_Item, false)
            image_base_di:setVisible(false)
            btn_add_number:setVisible(false)
            numberText:setVisible(false)
            image_base_star:setVisible(true)
            if _obj.perfectNum then
                image_win_di:show()
                image_win_di:getChildByName("label_number"):setString(tostring(_obj.perfectNum))
            else
                image_win_di:hide()
            end
            image_base_star:getChildByName("image_star_get"):getChildByName("text_number_get"):setString(_obj.int["5"])
            image_base_star:getChildByName("image_star_all"):getChildByName("text_number_all"):setString("/" .. DictChapter[tostring(_obj.int["3"])].starNum)
            showUIFightDot(_Item, _obj.int["3"])
            if _obj.int["6"] == 0 then
                image_pass:setVisible(false)
                UIGuidePeople.isGuide(_Item, UIFight)
            elseif _obj.int["6"] == 1 then
                image_pass:setVisible(true)
            end
        end


    elseif flag == 3 then
        --- 活动副本
        image_pass:hide()
        image_win_di:hide()
        btn_add_number:setVisible(false)
        numberText:setVisible(true)
        image_base_star:setVisible(false)
        image_base_di:setVisible(false)
        local haveBarrierNum = 0
        local instPlayerChapterId = nil
        if net.InstPlayerChapter then
            for key, ActivityObj in pairs(net.InstPlayerChapter) do
                if ActivityObj.int["3"] == _obj.id then
                    haveBarrierNum = ActivityObj.int["4"]
                end
            end
        end

        local activityBarrierTimes = _obj.fightNum - haveBarrierNum
        local VipNum = net.InstPlayer.int["19"]
        if VipNum >= 0 then
            local VipTime1 = 0
            if _obj.id == DictSysConfig[tostring(StaticSysConfig.slbz)].value then
                VipTime1 = DictVIP[tostring(VipNum + 1)].silverActivityChapterBuyTimes
            elseif _obj.id == DictSysConfig[tostring(StaticSysConfig.tsxc)].value then
                VipTime1 = DictVIP[tostring(VipNum + 1)].talentActivityChapterBuyTimes
            elseif _obj.id == DictSysConfig[tostring(StaticSysConfig.yhgt)].value then
                VipTime1 = DictVIP[tostring(VipNum + 1)].expActivityChapterBuyTimes
            elseif _obj.id == DictSysConfig[tostring(StaticSysConfig.wysm)].value then
                VipTime1 = DictVIP[tostring(VipNum + 1)].soulActivityChapterBuyTimes
            elseif _obj.id == DictSysConfig[tostring(StaticSysConfig.shcx)].value then
                VipTime1 = DictVIP[tostring(VipNum + 1)].wingChapterNum
            elseif _obj.id == DictSysConfig[tostring(StaticSysConfig.jxcl)].value then
                VipTime1 = DictVIP[tostring(VipNum + 1)].awareChapterNum
            end
            activityBarrierTimes = activityBarrierTimes + VipTime1
        end
        numberText:setString(activityBarrierTimes)
        -- btn_add_number:getChildByName("label_left_number"):setString(activityBarrierTimes)
        -- btn_add_number:setEnabled( false )
        -- btn_add_number:setBright( false )
        local function TouchEvent(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if activityBarrierTimes > 0 then
                    UIManager.showToast(Lang.ui_fight37)
                else
                    local VipNum = net.InstPlayer.int["19"]
                    --                    if VipNum == 0 then
                    --                      UIManager.showToast("您还不是Vip，无法购买")
                    --                      return
                    --                    end
                    local buyNum = 0
                    for key, ActivityObj in pairs(net.InstPlayerChapter) do
                        if ActivityObj.int["3"] == _obj.id then
                            haveBarrierNum = ActivityObj.int["4"]
                            if ActivityObj.int["8"] ~= nil then
                                buyNum = ActivityObj.int["8"]
                            end
                            instPlayerChapterId = ActivityObj.int["1"]
                        end
                    end
                    local baseMoney = DictSysConfig[tostring(StaticSysConfig.activityChapterInitGold)].value
                    local oneAddMoney = DictSysConfig[tostring(StaticSysConfig.activityChapterInitGoldAdd)].value
                    local BuyBarrierTimeMoney = baseMoney + buyNum * oneAddMoney
                    local VipTime = 0
                    if _obj.id == DictSysConfig[tostring(StaticSysConfig.slbz)].value then
                        VipTime = DictVIP[tostring(VipNum + 1)].silverActivityChapterBuyTimes
                    elseif _obj.id == DictSysConfig[tostring(StaticSysConfig.tsxc)].value then
                        VipTime = DictVIP[tostring(VipNum + 1)].talentActivityChapterBuyTimes
                    elseif _obj.id == DictSysConfig[tostring(StaticSysConfig.yhgt)].value then
                        VipTime = DictVIP[tostring(VipNum + 1)].expActivityChapterBuyTimes
                    elseif _obj.id == DictSysConfig[tostring(StaticSysConfig.wysm)].value then
                        VipTime = DictVIP[tostring(VipNum + 1)].pillActivityChapterBuyTimes
                    elseif _obj.id == DictSysConfig[tostring(StaticSysConfig.shcx)].value then
                        VipTime = DictVIP[tostring(VipNum + 1)].wingChapterNum
                    elseif _obj.id == DictSysConfig[tostring(StaticSysConfig.jxcl)].value then
                        VipTime = DictVIP[tostring(VipNum + 1)].awareChapterNum
                    end
                    local prompt = Lang.ui_fight38 .. BuyBarrierTimeMoney .. Lang.ui_fight39 .. buyNum .. Lang.ui_fight40 .. VipNum .. Lang.ui_fight41 .. VipTime .. Lang.ui_fight42
                    if instPlayerChapterId ~= nil then
                        if buyNum < VipTime then
                            utils.PromptDialog(UIFight.sendActivityBarrierTimeRequest, prompt, instPlayerChapterId)
                        else
                            UIManager.showToast(Lang.ui_fight43)
                        end
                    else
                        UIManager.showToast(Lang.ui_fight44)
                    end
                end
            end
        end
        -- btn_add_number:addTouchEventListener(TouchEvent)
    end
end



function UIFight.init()
    local btn_fight_elite = ccui.Helper:seekNodeByName(UIFight.Widget, "btn_fight_elite")
    -- 精英副本
    local btn_fight_common = ccui.Helper:seekNodeByName(UIFight.Widget, "btn_fight_common")
    -- 普通副本
    local btn_fight_activity = ccui.Helper:seekNodeByName(UIFight.Widget, "btn_fight_activity")
    -- 活动副本

    local btn_add = ccui.Helper:seekNodeByName(UIFight.Widget, "btn_add")
    ui_elite_leftNum = ccui.Helper:seekNodeByName(UIFight.Widget, "text_number")
    scrollView = ccui.Helper:seekNodeByName(UIFight.Widget, "view_list_card")
    --  滚动层
    listItem = scrollView:getChildByName("image_base_fight"):clone()
    local function TouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_fight_elite then
                if selectedFlag == 1 then
                    return
                end
                selectedFlag = 1
                UIFight.selectedPickFlag = 1
                UIFight.setup()
            elseif sender == btn_fight_common then
                if selectedFlag == 2 then
                    return
                end
                selectedFlag = 2
                UIFight.setup()
            elseif sender == btn_fight_activity then
                if selectedFlag == 3 then
                    return
                end
                selectedFlag = 3
                UIFight.setup()
            elseif sender == btn_add then
                --  cclog( "UIFight.EliteBarrierTimes :"..UIFight.EliteBarrierTimes )
                if UIFight.EliteBarrierTimes > 0 then
                    UIManager.showToast(Lang.ui_fight45)
                else
                    local _instPlayerChapterTypeId = nil
                    for key, obj in pairs(net.InstPlayerChapterType) do
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
                    --                    if VipNum == 0 then
                    --                        UIManager.showToast("您还不是Vip，无法购买")
                    --                        return
                    --                    end

                    local VipTime = 0
                    local prompt = ""
                    if UIFight.selectedPickFlag == 2 then
                        -- fiendChapterNum
                        VipTime = DictVIP[tostring(VipNum + 1)].fiendChapterNum - DictSysConfig[tostring(StaticSysConfig.chapterEliteNum)].value
                        prompt = Lang.ui_fight46 .. eliteBuyBarrierTimeMoney .. Lang.ui_fight47 .. eliteBuyNum .. Lang.ui_fight48 .. VipNum .. Lang.ui_fight49 .. VipTime .. Lang.ui_fight50
                    else
                        VipTime = DictVIP[tostring(VipNum + 1)].eliteChapterBuyTimes - DictSysConfig[tostring(StaticSysConfig.chapterEliteNum)].value
                        prompt = Lang.ui_fight51 .. eliteBuyBarrierTimeMoney .. Lang.ui_fight52 .. eliteBuyNum .. Lang.ui_fight53 .. VipNum .. Lang.ui_fight54 .. VipTime .. Lang.ui_fight55
                    end

                    if _instPlayerChapterTypeId ~= nil then
                        if eliteBuyNum < VipTime then
                            utils.PromptDialog(sendEliteBarrierTimeRequest, prompt, _instPlayerChapterTypeId)
                        else
                            UIManager.showToast(Lang.ui_fight56)
                        end
                    else
                        UIManager.showToast(Lang.ui_fight57)
                    end
                end
            end
        end
    end
    btn_fight_elite:addTouchEventListener(TouchEvent)
    btn_fight_common:addTouchEventListener(TouchEvent)
    btn_fight_activity:addTouchEventListener(TouchEvent)
    btn_add:addTouchEventListener(TouchEvent)
    btnSelected = btn_fight_elite
    btnSelectedText = btn_fight_elite:getChildByName("text_fight_elite")


    local image_fight = ccui.Helper:seekNodeByName(UIFight.Widget, "image_fight")
    local image_devil = ccui.Helper:seekNodeByName(UIFight.Widget, "image_devil")
    image_fight:setTouchEnabled(true)
    image_fight:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if UIFight.selectedPickFlag == 1 then
                return
            end
            UIFight.selectedPickFlag = 1
            UIFight.setup()
        end
    end )
    local srcX = image_fight:getPositionX()
    local afAction = cc.RepeatForever:create(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(1, cc.p(srcX - 30, image_fight:getPositionY())), cc.FadeOut:create(1)), cc.DelayTime:create(0.1), cc.CallFunc:create( function()
        image_fight:setPositionX(srcX)
        image_fight:setOpacity(255)
    end )))
    image_fight:runAction(afAction)

    image_devil:setTouchEnabled(true)
    image_devil:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if UIFight.selectedPickFlag == 2 then
                return
            end
            UIFight.selectedPickFlag = 2
            UIFight.setup()
        end
    end )
    local srcX1 = image_devil:getPositionX()
    local afAction1 = cc.RepeatForever:create(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(1, cc.p(srcX1 + 30, image_devil:getPositionY())), cc.FadeOut:create(1)), cc.DelayTime:create(0.1), cc.CallFunc:create( function()
        image_devil:setPositionX(srcX1)
        image_devil:setOpacity(255)
    end )))
    image_devil:runAction(afAction1)

end

function UIFight.setup()
    if listItem:getReferenceCount() == 1 then
        listItem:retain()
    end
    scrollView:removeAllChildren()
    selectedBtnChange(selectedFlag)
    local FightThing = { }
    lastThing = nil
    local instMaxId = 0
    local instMaxObj = nil
    local first = true
    --- 筛选实例数据---
    if net.InstPlayerChapter then
        for key, obj in pairs(net.InstPlayerChapter) do
            if selectedFlag == 2 and DictChapter[tostring(obj.int["3"])].type == 1 then
                table.insert(FightThing, obj)

                if DictChapter[tostring(obj.int["3"])].starNum >= 30 then
                    obj.perfectNum = 0
                    for k, v in pairs(net.InstPlayerBarrier) do
                        if obj.int["3"] == v.int["5"] and v.int["6"] == 4 then
                            obj.perfectNum = obj.perfectNum + 1
                        end
                    end
                end

                if first == true then
                    instMaxId = obj.int["3"]
                    instMaxObj = obj
                end
                if obj.int["3"] > instMaxId then
                    instMaxId = obj.int["3"]
                    instMaxObj = obj
                end
            end

            first = false
        end
    end
    cclog("instMaxId" .. instMaxId)
    ------------------

    local image_fight = ccui.Helper:seekNodeByName(UIFight.Widget, "image_fight")
    local image_devil = ccui.Helper:seekNodeByName(UIFight.Widget, "image_devil")


    justOpenThing = nil
    --- 刚开启的新章节
    if selectedFlag == 1 then
        if UIFight.selectedPickFlag == 1 then
            image_fight:setVisible(false)
            -- image_devil:setVisible(true)
            image_devil:setVisible(false)

            eliteBarrierNum = 0
            eliteBuyNum = 0
            if net.InstPlayerChapterType then
                for key, obj in pairs(net.InstPlayerChapterType) do
                    if obj.int["3"] == 2 then
                        eliteBarrierNum = obj.int["4"]
                        eliteBuyNum = obj.int["6"]
                    end
                end
            end
            if eliteBarrierNum == nil then
                eliteBarrierNum = 0
            end
            if eliteBuyNum == nil then
                eliteBuyNum = 0
            end

            UIFight.EliteBarrierTimes = DictSysConfig[tostring(StaticSysConfig.chapterEliteNum)].value - eliteBarrierNum
            if UIFight.EliteBarrierTimes < 0 then
                UIFight.EliteBarrierTimes = 0
            end
            ui_elite_leftNum:setString(Lang.ui_fight58 .. UIFight.EliteBarrierTimes)


            local baseMoney = DictSysConfig[tostring(StaticSysConfig.chapterEliteBuyGold)].value
            local oneAddMoney = DictSysConfig[tostring(StaticSysConfig.chapterEliteBuyGoldAdd)].value
            eliteBuyBarrierTimeMoney = baseMoney + eliteBuyNum * oneAddMoney

            local DictMinChapterId = 10000
            -----寻找最小精英章节id------------
            for key, obj in pairs(DictChapter) do
                if obj.type == 2 then
                    if DictMinChapterId > obj.id then
                        DictMinChapterId = obj.id
                    end
                end
            end
            cclog("DictMinChapterId=" .. DictMinChapterId)
            ------------------------------------------
            for key, DictChapterObj in pairs(DictChapter) do
                if DictChapterObj.type == 2 then
                    local commonChapterId = DictChapterObj.chapterId
                    if net.InstPlayerChapter then
                        for key, InstPlayerChapterObj in pairs(net.InstPlayerChapter) do
                            if InstPlayerChapterObj.int["3"] == tonumber(commonChapterId) then
                                -- 判断是否开启
                                if InstPlayerChapterObj.int["6"] == 1 then
                                    -- 判断普通章节是否通关
                                    if DictChapter[tostring(DictChapterObj.id - 1)] and DictChapter[tostring(DictChapterObj.id - 1)].type == 2 then
                                        for key, obj in pairs(net.InstPlayerChapter) do
                                            if tonumber(obj.int["3"]) ==(DictChapterObj.id - 1) then
                                                -- 判断前一关卡是否开启
                                                if obj.int["6"] == 1 then
                                                    -- 判断前一关卡普通章节是否通关
                                                    table.insert(FightThing, DictChapterObj)
                                                else
                                                    lastThing = DictChapterObj
                                                end
                                            end
                                        end
                                    else
                                        if net.InstPlayer.int["4"] >= DictChapter[tostring(DictChapterObj.id)].openLeve then
                                            table.insert(FightThing, DictChapterObj)
                                        else
                                            if not lastThing then
                                                lastThing = DictChapterObj
                                            else
                                                if DictChapterObj.id < lastThing.id then
                                                    lastThing = DictChapterObj
                                                end
                                            end
                                        end
                                    end
                                end
                            end

                        end
                    else
                        lastThing = DictChapter[tostring(DictMinChapterId)]
                        break;
                    end
                end
            end
            if lastThing == nil then
                local maxId = 0
                for key, obj in pairs(FightThing) do
                    if obj.id > maxId then
                        maxId = obj.id
                    end
                end
                if DictChapter[tostring(maxId + 1)] then
                    maxDictThing = DictChapter[tostring(maxId + 1)]
                    --- 从实例表查到的最大字典表
                    if maxDictThing.chapterId ~= 0 then
                        lastThing = maxDictThing
                    end
                end
            end
        elseif UIFight.selectedPickFlag == 2 then
            eliteBarrierNum = 0
            eliteBuyNum = 0
            if net.InstPlayerChapterType then
                for key, obj in pairs(net.InstPlayerChapterType) do
                    if obj.int["3"] == 4 then
                        eliteBarrierNum = obj.int["4"]
                        eliteBuyNum = obj.int["6"]
                    end
                end
            end
            if eliteBarrierNum == nil then
                eliteBarrierNum = 0
            end
            if eliteBuyNum == nil then
                eliteBuyNum = 0
            end

            UIFight.EliteBarrierTimes = DictSysConfig[tostring(StaticSysConfig.chapterEliteNum)].value - eliteBarrierNum
            if UIFight.EliteBarrierTimes < 0 then
                UIFight.EliteBarrierTimes = 0
            end
            ui_elite_leftNum:setString(Lang.ui_fight59 .. UIFight.EliteBarrierTimes)

            local baseMoney = DictSysConfig[tostring(StaticSysConfig.chapterEliteBuyGold)].value
            local oneAddMoney = DictSysConfig[tostring(StaticSysConfig.chapterEliteBuyGoldAdd)].value
            eliteBuyBarrierTimeMoney = baseMoney + eliteBuyNum * oneAddMoney

            image_fight:setVisible(true)
            image_devil:setVisible(false)
            for key, DictChapterObj in pairs(DictChapter) do
                if DictChapterObj.type == 4 then
                    table.insert(FightThing, DictChapterObj)
                end
            end
        end
        ccui.Helper:seekNodeByName(UIFight.Widget, "image_di"):setVisible(true)
        ccui.Helper:seekNodeByName(UIFight.Widget, "btn_add"):setVisible(true)
        ccui.Helper:seekNodeByName(UIFight.Widget, "text_number"):setVisible(true)
    elseif selectedFlag == 2 then
        image_fight:setVisible(false)
        image_devil:setVisible(false)
        if instMaxId ~= 0 then
            maxDictThing = DictChapter[tostring(instMaxId)]
            --- 从实例表查到的最大字典表
            if maxDictThing.chapterId ~= 0 then
                if instMaxObj ~= nil and instMaxObj.int["6"] == 0 then
                    lastThing = DictChapter[tostring(maxDictThing.chapterId)]
                    --- 普通副本按照chapterId查找
                elseif instMaxObj ~= nil and instMaxObj.int["6"] == 1 then
                    justOpenThing = DictChapter[tostring(maxDictThing.chapterId)]
                    --- 普通副本按照chapterId查找
                    lastThing = DictChapter[tostring(justOpenThing.chapterId)]
                end

            else
                lastThing = nil
            end
        else
            local DictMinChapterId = 10000
            for key, obj in pairs(DictChapter) do
                if obj.type == 1 then
                    if DictMinChapterId > obj.id then
                        DictMinChapterId = obj.id
                    end
                end
            end
            justOpenThing = DictChapter[tostring(DictMinChapterId)]
            lastThing = DictChapter[tostring(justOpenThing.chapterId)]
        end

        ccui.Helper:seekNodeByName(UIFight.Widget, "image_di"):setVisible(false)
        ccui.Helper:seekNodeByName(UIFight.Widget, "btn_add"):setVisible(false)
        ccui.Helper:seekNodeByName(UIFight.Widget, "text_number"):setVisible(false)
    elseif selectedFlag == 3 then
        image_fight:setVisible(false)
        image_devil:setVisible(false)
        if net.InstChapterActivity then
            for key, ActivityObj in pairs(net.InstChapterActivity) do
                local DictChapterObj = DictChapter[tostring(ActivityObj.int["2"])]
                table.insert(FightThing, DictChapterObj)
            end
        end
        ccui.Helper:seekNodeByName(UIFight.Widget, "image_di"):setVisible(false)
        ccui.Helper:seekNodeByName(UIFight.Widget, "btn_add"):setVisible(false)
        ccui.Helper:seekNodeByName(UIFight.Widget, "text_number"):setVisible(false)
        utils.quickSort(FightThing, function(obj1, obj2) if obj1.id > obj2.id then return true end end)
    end
    if next(FightThing) then
        utils.quickSort(FightThing, compare)
    end
    if justOpenThing ~= nil then
        table.insert(FightThing, 1, justOpenThing)
    end
    if lastThing ~= nil then
        table.insert(FightThing, 1, lastThing)
    end

    if next(FightThing) then
        local config = { flag = selectedFlag, space = 7 }
        if UIFight.jumpToChapterId then
            for i, obj in ipairs(FightThing) do
                if (obj.int and obj.int["3"] or obj.id) == UIFight.jumpToChapterId then
                    config.jumpTo = i
                    break
                end
            end
        end
        utils.updateScrollView(UIFight, scrollView, listItem, FightThing, setScrollViewItem, config)
    end
    UIFight.jumpToChapterId = nil
    -- UIFight.checkImageHint()
end

function UIFight.checkImageHint()
    local InstPlayerlevel = net.InstPlayer.int["4"]
    --- 玩家等级
    local activityLv = DictBarrier["1001"].openLevel
    if not activityLv then
        activityLv = 0
    end
    local DictMinChapterId = 10000
    -----寻找最小精英章节id------------
    for key, obj in pairs(DictChapter) do
        if obj.type == 2 then
            if DictMinChapterId > obj.id then
                DictMinChapterId = obj.id
            end
        end
    end
    local jingyingLv = DictChapter[tostring(DictMinChapterId)].openLeve
    -- 开启等级
    if not jingyingLv then
        jingyingLv = 0
    end
    local flagOne = false
    local flagThree = false
    if InstPlayerlevel >= jingyingLv then
        ---------------精英副本--------------------------------
        eliteBarrierNum = 0
        if net.InstPlayerChapterType then
            for key, obj in pairs(net.InstPlayerChapterType) do
                if UIFight.selectedPickFlag == 1 then
                    if obj.int["3"] == 2 then
                        eliteBarrierNum = obj.int["4"]
                    end
                elseif UIFight.selectedPickFlag == 2 then
                    if obj.int["3"] == 4 then
                        eliteBarrierNum = obj.int["4"]
                    end
                end
            end
        end
        if eliteBarrierNum == nil then
            eliteBarrierNum = 0
        end

        UIFight.EliteBarrierTimes = DictSysConfig[tostring(StaticSysConfig.chapterEliteNum)].value - eliteBarrierNum
        if UIFight.EliteBarrierTimes <= 0 then
            flagOne = false
        else
            flagOne = true
        end
        if btnSelected then
            local button = ccui.Helper:seekNodeByName(UIFight.Widget, "btn_fight_elite")
            -- 精英副本
            utils.addImageHint(flagOne, button, 100, 15, 10)
        end
    end
    if InstPlayerlevel >= activityLv then
        -----------------活动副本---------------------------------------
        local FightThing = { }
        if net.InstChapterActivity then
            for key, ActivityObj in pairs(net.InstChapterActivity) do
                local DictChapterObj = DictChapter[tostring(ActivityObj.int["2"])]
                table.insert(FightThing, DictChapterObj)
            end
        end
        for key, obj in pairs(FightThing) do
            local haveBarrierNum = 0
            local instPlayerChapterId = nil
            if net.InstPlayerChapter then
                for key, ActivityObj in pairs(net.InstPlayerChapter) do
                    if ActivityObj.int["3"] == obj.id then
                        haveBarrierNum = ActivityObj.int["4"]
                    end
                end
            end
            local activityBarrierTimes = obj.fightNum - haveBarrierNum
            local VipNum = net.InstPlayer.int["19"]
            if VipNum >= 0 then
                local VipTime1 = 0
                if obj.id == DictSysConfig[tostring(StaticSysConfig.slbz)].value then
                    VipTime1 = DictVIP[tostring(VipNum + 1)].silverActivityChapterBuyTimes
                elseif obj.id == DictSysConfig[tostring(StaticSysConfig.tsxc)].value then
                    VipTime1 = DictVIP[tostring(VipNum + 1)].talentActivityChapterBuyTimes
                elseif obj.id == DictSysConfig[tostring(StaticSysConfig.yhgt)].value then
                    VipTime1 = DictVIP[tostring(VipNum + 1)].expActivityChapterBuyTimes
                elseif obj.id == DictSysConfig[tostring(StaticSysConfig.wysm)].value then
                    VipTime1 = DictVIP[tostring(VipNum + 1)].pillActivityChapterBuyTimes
                elseif obj.id == DictSysConfig[tostring(StaticSysConfig.shcx)].value then
                    VipTime1 = DictVIP[tostring(VipNum + 1)].wingChapterNum
                elseif obj.id == DictSysConfig[tostring(StaticSysConfig.jxcl)].value then
                    VipTime1 = DictVIP[tostring(VipNum + 1)].awareChapterNum
                end
                activityBarrierTimes = activityBarrierTimes + VipTime1
            end
            if activityBarrierTimes > 0 then
                flagThree = true
                break
            else
                flagThree = false
            end
        end
        if btnSelected then
            local button = ccui.Helper:seekNodeByName(UIFight.Widget, "btn_fight_activity")
            -- 活动副本
            utils.addImageHint(flagThree, button, 100, 15, 10)
        end
    end
    return flagOne, flagThree
end
-----切换界面------
function UIFight.setFlag(flag, flag1)
    selectedFlag = flag
    if flag1 then
        UIFight.selectedPickFlag = flag1
    end
end

function UIFight.free(...)
    scrollView:removeAllChildren()
end
