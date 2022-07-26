require"Lang"
UIAllianceWar = {
    STATE =
    {
        NONE = 0,
        OUTER_PREPARE = 1,
        OUTER_FIGHT = 2,
        OUTER_FINISH = 5,
        INNER_PREPARE = 3,
        INNER_FIGHT = 4,
        INNER_FINISH = 6,
    }
}

local ui = UIAllianceWar
local countdownTime = 0

function ui.init()
    local btn_help = ccui.Helper:seekNodeByName(ui.Widget, "btn_help")
    local btn_back = ccui.Helper:seekNodeByName(ui.Widget, "btn_back")
    local btn_shou = ccui.Helper:seekNodeByName(ui.Widget, "btn_shou")
    local btn_gong = ccui.Helper:seekNodeByName(ui.Widget, "btn_gong")
    local btn_garrison = ccui.Helper:seekNodeByName(ui.Widget, "btn_garrison")

    btn_help:setPressedActionEnabled(true)
    btn_back:setPressedActionEnabled(true)
    btn_shou:setPressedActionEnabled(true)
    btn_gong:setPressedActionEnabled(true)
    btn_garrison:setPressedActionEnabled(true)

    local function onBtnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            if sender == btn_help then
                UIAllianceHelp.show( { titleName = Lang.ui_alliance_war1, name = "allianceWar" })
            elseif sender == btn_back then
                ui.exitOverlordWar()
            elseif sender == btn_shou then
                UIAllianceWarRank.show(2)
            elseif sender == btn_gong then
                UIAllianceWarRank.show(3)
            elseif sender == btn_garrison then
                if not ui.isDefend then return end

                if ui.state == ui.STATE.OUTER_PREPARE then
                    UIManager.showWidget("ui_alliance_war_info")
                else
                    UIManager.showWidget("ui_alliance_war_info_nei")
                end
            end
        end
    end

    btn_help:addTouchEventListener(onBtnEvent)
    btn_back:addTouchEventListener(onBtnEvent)
    btn_shou:addTouchEventListener(onBtnEvent)
    btn_gong:addTouchEventListener(onBtnEvent)
    btn_garrison:addTouchEventListener(onBtnEvent)
end

function ui.exitOverlordWar()
    UIManager.hideWidget("ui_alliance_war")
    WidgetManager.delete(ui)

    UIManager.hideWidget("ui_alliance_war_info")
    WidgetManager.delete(UIAllianceWarInfo)

    UIManager.showWidget("ui_notice", "ui_alliance")

    ui.enter = false
    ui.outerStartTime = nil
    ui.outerEndTime = nil
    ui.innerStartTime = nil
    ui.innerEndTime = nil
    ui.defendInfo = nil
    ui.isDefend = nil
    ui.welfareInfo = nil
    ui.lastAllianceRank = nil
    ui.defendAddCfg = nil
    ui.cooldown = nil
    ui.state = nil
    ui.warInfo = nil
    ui.curUI = nil

    for i, obj in ipairs(UIAllianceWarInfo.pool) do
        obj:release()
    end
    UIAllianceWarInfo.pool = { }

    netSendPackage( { header = StaticMsgRule.exitOverLord, msgdata = { } })
end

local function timeCountdown()
    countdownTime = countdownTime - 1
    if countdownTime < 0 then
        countdownTime = 0
    end
    local text_time = ccui.Helper:seekNodeByName(ui.Widget, "text_time")

    text_time:getParent():setVisible(countdownTime > 0)
    if countdownTime > 0 then
        local hour = math.floor(countdownTime / 3600)
        local minute = math.floor(countdownTime / 60 % 60)
        local second = math.floor(countdownTime % 60)
        text_time:setString(string.format(Lang.ui_alliance_war2, hour, minute, second))
    end
end

function ui.setup()
    ui.curUI = ui

    local image_basemap = ccui.Helper:seekNodeByName(ui.Widget, "image_basemap")
    local image_di_win = ccui.Helper:seekNodeByName(ui.Widget, "image_di_win")
    local image_flag = image_di_win:getChildByName("image_flag")
    local text_name = image_di_win:getChildByName("text_name")
    local text_win = image_di_win:getChildByName("text_win")
    local text_hint = image_di_win:getChildByName("text_hint")

    image_flag:loadTexture("image/" .. DictUI[tostring(DictUnionFlag[tostring(ui.defendInfo.unionFlagId)].bigUiId)].fileName)
    text_name:setString(ui.defendInfo.unionName)
    if ui.defendInfo.victoryCount > 0 then
        text_win:show():setString(Lang.ui_alliance_war3 .. ui.defendInfo.victoryCount)
    else
        text_win:hide()
    end

    local image_di_winer = image_di_win:getChildByName("image_di_winer")
    local image_card = ccui.Helper:seekNodeByName(ui.Widget, "image_card")
    text_name = image_di_winer:getChildByName("text_name")
    image_card:loadTexture("image/" .. DictUI[tostring(DictCard[tostring(ui.defendInfo.overlordIconId)].bigUiId)].fileName)
    text_name:setString(ui.defendInfo.overlordName)

    if ui.defendInfo.propAdd > 0 then
        text_hint:show():setString(string.format(Lang.ui_alliance_war4, ui.defendInfo.propAdd))
    else
        text_hint:hide()
    end

    local btn_shou = ccui.Helper:seekNodeByName(ui.Widget, "btn_shou")
    local btn_gong = ccui.Helper:seekNodeByName(ui.Widget, "btn_gong")

    btn_shou:setVisible(ui.state == ui.STATE.NONE)
    btn_gong:setVisible(ui.state == ui.STATE.NONE)

    local btn_garrison = ccui.Helper:seekNodeByName(ui.Widget, "btn_garrison")
    btn_garrison:setVisible(ui.isDefend and(ui.state == ui.STATE.OUTER_PREPARE or ui.state == ui.STATE.INNER_PREPARE))

    local image_di_rank = ccui.Helper:seekNodeByName(ui.Widget, "image_di_rank")
    for i = 1, 5 do
        local text_name = image_di_rank:getChildByName("text_name" .. i)
        local text_integral = image_di_rank:getChildByName("text_integral" .. i)

        local rank = ui.lastAllianceRank[i]
        if rank then
            text_name:show():setString(i .. "、" .. rank[1])
            text_integral:show():setString(rank[2])
        else
            text_name:hide()
            text_integral:hide()
        end
    end

    local image_di_info = ccui.Helper:seekNodeByName(ui.Widget, "image_di_info")

    if ui.state == ui.STATE.NONE or ui.state == ui.STATE.OUTER_PREPARE then
        image_di_info:getChildByName("text_info"):setString(Lang.ui_alliance_war5)
        image_di_info:getChildByName("text_info1"):setString(ui.welfareInfo[1] or "")
        image_di_info:getChildByName("text_info2"):setString(ui.welfareInfo[2] or "")

        countdownTime = ui.outerStartTime - ui.getCurrentTime()

        image_basemap:loadTexture("ui/bz_di.png")
    else
        image_di_info:getChildByName("text_info"):setString(Lang.ui_alliance_war6)
        image_di_info:getChildByName("text_info1"):setString(string.format(Lang.ui_alliance_war7, ui.warInfo.attackScore))
        image_di_info:getChildByName("text_info2"):setString(string.format(Lang.ui_alliance_war8, ui.warInfo.defendScore))

        countdownTime = ui.innerStartTime - ui.getCurrentTime()

        image_basemap:loadTexture("ui/bz_nei.png")
    end

    dp.addTimerListener(timeCountdown)
end

function ui.free()
    dp.removeTimerListener(timeCountdown)
end

function ui.getCurrentTime()
    return ui.systimes + dp.curTimerNumber - ui.curTimerNumber
end

function ui.show(msgdata)
    ui.enter = true
    ui.outerStartTime = msgdata.long.outerStartTime
    ui.outerEndTime = msgdata.long.outerEndTime
    ui.innerStartTime = msgdata.long.innerStartTime
    ui.innerEndTime = msgdata.long.innerEndTime
    ui.systimes = msgdata.long.systimes or 0
    ui.curTimerNumber = dp.curTimerNumber or 0

    cclog("UIAllianceWar outerStartTime " .. os.date("%x %X", ui.outerStartTime))
    cclog("UIAllianceWar outerEndTime " .. os.date("%x %X", ui.outerEndTime))
    cclog("UIAllianceWar innerStartTime " .. os.date("%x %X", ui.innerStartTime))
    cclog("UIAllianceWar innerEndTime " .. os.date("%x %X", ui.innerEndTime))

    local defendInfo = utils.stringSplit(msgdata.string.defendInfo or "", "|")
    ui.defendInfo = {
        unionId = tonumber(defendInfo[1] or 0),
        unionFlagId = tonumber(defendInfo[2] or 0),
        unionName = defendInfo[3] or "",
        victoryCount = tonumber(defendInfo[4] or 0),
        overlordIconId = tonumber(defendInfo[5] or 0),
        overlordName = defendInfo[6] or "",
        propAdd = tonumber(defendInfo[7] or 0),
    }

    ui.isDefend = ui.defendInfo.unionId == net.InstUnionMember.int["2"]

    local welfareInfo = utils.stringSplit(msgdata.string.welfareInfo or "", "|")

    if welfareInfo[1] == "1" then
        welfareInfo = { string.format(Lang.ui_alliance_war9, welfareInfo[2]) }
    elseif welfareInfo[1] == "2" then
        welfareInfo = {
            string.format(Lang.ui_alliance_war10,welfareInfo[2]),
            --            string.format("商城道具%s折",welfareInfo[2])
        }
    else
        welfareInfo = { }
    end

    ui.welfareInfo = welfareInfo

    local lastAllianceRank = utils.stringSplit(msgdata.string.lastAllianceRank or "", "/")
    for i = 1, #lastAllianceRank do
        lastAllianceRank[i] = utils.stringSplit(lastAllianceRank[i], "|");
    end
    ui.lastAllianceRank = lastAllianceRank

    local defendAddCfg = utils.stringSplit(msgdata.string.defendAddCfg or "", "|")
    for i = 1, #defendAddCfg do
        defendAddCfg[i] = tonumber(defendAddCfg[i] or 0)
    end
    ui.defendAddCfg = defendAddCfg

    ui.cooldown = msgdata.int.cooldown
    ui.cooldownCost = msgdata.int.cooldownCost

    ui.state = msgdata.int.state
    local warInfo = { }
    ui.warInfo = warInfo

    warInfo.defendScore = msgdata.int.defendScore or 0
    warInfo.attackScore = msgdata.int.attackScore or 0
    warInfo.occupy = msgdata.int.occupy or 0
    warInfo.canAttackTime = msgdata.long.canAttackTime or 0

    local defendAdd = utils.stringSplit(msgdata.string.defendAdd or "", "|")
    warInfo.defendAdd = { tonumber(defendAdd[1] or 0), tonumber(defendAdd[2] or 0), tonumber(defendAdd[3] or 0) }

    ui.defendIDs = { }
    local defendPointInfo = utils.stringSplit(msgdata.string.defendPointInfo or "", "/")
    warInfo.defendPointInfo = { }
    for i = 1, UIAllianceWarInfo.DEFEND_COUNT do
        local info = utils.stringSplit(defendPointInfo[i] or "", "|")

        local id = tonumber(info[1] or i)
        local unionId = tonumber(info[2] or 0)

        local side = 0
        if unionId > 0 then
            side = unionId == ui.defendInfo.unionId and 1 or 2
        end

        local name = info[3] or ""

        warInfo.defendPointInfo[id] = { id = id, side = side, unionId = unionId, name = name }
        table.insert(ui.defendIDs, id)
    end

    ui.attackIDs = { }
    local attackPointInfo = utils.stringSplit(msgdata.string.attackPointInfo or "", "/")
    warInfo.attackPointInfo = { }
    for i = 1, UIAllianceWarInfo.ATTACK_COUNT do
        local info = utils.stringSplit(attackPointInfo[i] or "", "|")

        local id = tonumber(info[1] or(i + UIAllianceWarInfo.DEFEND_COUNT))
        local durability = tonumber(info[2] or 10)
        local maxDurability = tonumber(info[3] or 10)

        warInfo.attackPointInfo[id] = { id = id, durability = durability, maxDurability = maxDurability }
        table.insert(ui.attackIDs, id)
    end

    ui.open()
end

local function showFinishDialog(isWin)
    local ui_middle = ccui.Layout:create()
    ui_middle:setContentSize(display.size)
    ui_middle:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    ui_middle:setBackGroundColor(display.COLOR_BLACK)
    ui_middle:setBackGroundColorOpacity(255 * 0.4)
    ui_middle:setTouchEnabled(true)

    local image_basemap = ccui.ImageView:create(isWin and "ui/bz_win.png" or "ui/bz_fail.png")
    image_basemap:setPosition(display.width / 2, display.height / 2)
    ui_middle:addChild(image_basemap)

    local size = image_basemap:getContentSize()

    local text1 = ccui.Text:create(Lang.ui_alliance_war11, dp.FONT, 24)
    text1:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    text1:setPosition(size.width / 2, -30)
    image_basemap:addChild(text1)

    ui_middle:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            image_basemap:runAction(cc.ScaleTo:create(0.1, 0.1))
            ui_middle:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create( function()
                ui.enter = false
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.exitOverLord, msgdata = { } }, function(pack)
                    UIManager.showLoading()
                    netSendPackage( { header = StaticMsgRule.openOverlord, msgdata = { } }, function(pack)
                        ui.show(pack.msgdata)
                    end )
                end )
            end ), cc.RemoveSelf:create()))
        end
    end )

    image_basemap:setScale(0.1)
    UIManager.uiLayer:addChild(ui_middle, 10000)
    image_basemap:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.1), cc.ScaleTo:create(0.06, 1)))
end

local function getTargetUIName(changeState)
    local targetUIName
    if ui.state == ui.STATE.NONE then
        targetUIName = "ui_alliance_war"
    elseif ui.state == ui.STATE.OUTER_PREPARE or ui.state == ui.STATE.INNER_PREPARE then
        if ui.isDefend then
            if ui.state == ui.STATE.OUTER_PREPARE then
                if ui.curUI and ui.curUI.Widget:getName() == "ui_alliance_war_info" then
                    targetUIName = "ui_alliance_war_info"
                else
                    targetUIName = "ui_alliance_war"
                end
            else
                if ui.curUI and ui.curUI.Widget:getName() == "ui_alliance_war_info_nei" then
                    targetUIName = "ui_alliance_war_info_nei"
                else
                    targetUIName = "ui_alliance_war"
                end
            end
        else
            targetUIName = "ui_alliance_war"
        end
    elseif ui.state == ui.STATE.OUTER_FIGHT or ui.state == ui.STATE.OUTER_FINISH then
        targetUIName = "ui_alliance_war_info"
    elseif ui.state == ui.STATE.INNER_FIGHT or ui.state == ui.STATE.INNER_FINISH then
        targetUIName = "ui_alliance_war_info_nei"
    end

    return targetUIName
end

function ui.refresh(msgdata)
    if not ui.enter then return end

    local warInfo = ui.warInfo or { }
    local state = msgdata.int and msgdata.int.state

    if ui.state == ui.STATE.INNER_FINISH and state and state == ui.STATE.NONE then
        local isWin = false
        if ui.isDefend then
            isWin = warInfo.defendScore > warInfo.attackScore
        else
            isWin = warInfo.attackScore >= warInfo.defendScore
        end
        showFinishDialog(isWin)
        return
    end

    local changeState = state and state ~= ui.state

    if ui.state == ui.STATE.OUTER_FINISH and state and state == ui.STATE.INNER_PREPARE then
        for id, info in pairs(warInfo.attackPointInfo) do
            info.durability = info.maxDurability
        end
        for id, info in pairs(warInfo.defendPointInfo) do
            info.side = 0
            info.unionId = 0
            info.name = ""
        end
        warInfo.occupy = 0
        warInfo.canAttackTime = 0
    end

    ui.state = state or ui.state

    warInfo.defendScore =(msgdata.int and msgdata.int.defendScore) or warInfo.defendScore or 0
    warInfo.attackScore =(msgdata.int and msgdata.int.attackScore) or warInfo.attackScore or 0

    if msgdata.string and msgdata.string.freshDefend then
        local info = utils.stringSplit(msgdata.string.freshDefend, "|")

        local id = tonumber(info[1] or 0)
        local unionId = tonumber(info[2] or 0)

        local side = 0
        if unionId > 0 then
            side = unionId == ui.defendInfo.unionId and 1 or 2
        end

        local name = info[4] or ""
        local oldInfo = warInfo.defendPointInfo[id]
        warInfo.defendPointInfo[id] = { id = id, side = side, unionId = unionId, name = name }

        if (oldInfo.side or 0) * warInfo.defendPointInfo[id].side > 0 then
            UIAllianceWarInfo.playChangePointEffect(id)
        end

        if tonumber(info[3] or 0) == net.InstPlayer.int["1"] then
            warInfo.occupy = id
        elseif id == warInfo.occupy then
            warInfo.occupy = 0
        end

        if UIAllianceWarCheck.Widget and UIAllianceWarCheck.Widget:getParent() and UIAllianceWarCheck.id == id then
            UIManager.showLoading()
            netSendPackage( { header = StaticMsgRule.showMatrix, msgdata = { int = { id = UIAllianceWarCheck.id } } }, function(pack)
                UIAllianceWarCheck.id = tag
                table.merge(UIAllianceWarCheck, msgdata.int)
                table.merge(UIAllianceWarCheck, msgdata.string)
                UIManager.flushWidget(UIAllianceWarCheck)
            end )
        end
    end

    if msgdata.string and msgdata.string.freshAttack then
        local info = utils.stringSplit(msgdata.string.freshAttack, "|")

        local id = tonumber(info[1] or 0)
        local durability = tonumber(info[2] or 0)
        local maxDurability = tonumber(info[3] or 10)

        warInfo.attackPointInfo[id] = { id = id, durability = durability, maxDurability = maxDurability }
    end

    if msgdata.int and msgdata.int.buff1 then
        warInfo.defendAdd[1] = msgdata.int.buff1
    end
    if msgdata.int and msgdata.int.buff2 then
        warInfo.defendAdd[2] = msgdata.int.buff2
    end
    if msgdata.int and msgdata.int.buff3 then
        warInfo.defendAdd[3] = msgdata.int.buff3
    end

    local targetUIName = getTargetUIName(changeState)

    if not ui.curUI or ui.curUI.Widget:getName() ~= targetUIName then
        UIManager.showScreen("ui_notice", targetUIName)
    else
        UIManager.flushWidget(ui.curUI)
    end
end

function ui.open()
    local targetUIName = getTargetUIName()
    UIManager.showScreen("ui_notice", targetUIName)
end

function ui.updateTimer(interval)
    if not ui.Widget or not countdownTime then return end
    countdownTime = countdownTime - interval
    if countdownTime < 0 then
        countdownTime = 0
    end
end
