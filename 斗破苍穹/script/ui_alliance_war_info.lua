require"Lang"
UIAllianceWarInfo = {
    BLUE_COLOR = cc.c3b(0,0xFF,0xEF),
    RED_COLOR = display.COLOR_RED,
    DEFEND_COUNT = 13,
    ATTACK_COUNT = 4,

    attackCountdownTime = 0,

    pool = { }
}

local ui = UIAllianceWarInfo

local countdownTime = 0
local inspireType = 0

local function netCallbackFunc(pack)
    local code = tonumber(pack.header)
    if code == StaticMsgRule.enterMatrix then
        UIManager.showToast(Lang.ui_alliance_war_info1)
    elseif code == StaticMsgRule.inspireOverlord then
        UIManager.showToast(Lang.ui_alliance_war_info2)
        UIAllianceWar.refresh(pack.msgdata)
    end
end

function ui.tryAttack(matrixId, emptyDefendPoint)
    local function ok2()
        if UIAllianceWar.isDefend and(UIAllianceWar.state == UIAllianceWar.STATE.OUTER_PREPARE or UIAllianceWar.state == UIAllianceWar.STATE.INNER_PREPARE) then
            UIManager.showLoading()
            netSendPackage( { header = StaticMsgRule.enterMatrix, msgdata = { int = { id = matrixId } } }, netCallbackFunc)
        elseif UIAllianceWar.state == UIAllianceWar.STATE.OUTER_FIGHT or UIAllianceWar.state == UIAllianceWar.STATE.INNER_FIGHT then
            UIManager.showLoading()
            netSendPackage( { header = StaticMsgRule.attackMatrix, msgdata = { int = { id = matrixId } } }, function(pack)
                ui.attackMatrixCallback(pack, matrixId)
            end )
        end
    end

    local function ok()
        if UIAllianceWar.warInfo.occupy > 0 then
            utils.PromptDialog( function()
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.deportMatrix, msgdata = { int = { id = UIAllianceWar.warInfo.occupy, type = 1 } } }, ok2)
            end , Lang.ui_alliance_war_info3)
        else
            ok2()
        end
    end

    if ui.attackCountdownTime > 0--[[ and not(UIAllianceWar.isDefend and emptyDefendPoint)-- ]] then
        utils.PromptDialog( function()
            UIManager.showLoading()
            netSendPackage( { header = StaticMsgRule.freshOverlord, msgdata = { } }, function(pack)
                UIAllianceWar.warInfo.canAttackTime = 0
                UIAllianceWar.cooldownCost = pack.msgdata.int.cooldownCost
                ok()
            end )
        end , Lang.ui_alliance_war_info4 .. UIAllianceWar.cooldownCost .. Lang.ui_alliance_war_info5)
    else
        ok()
    end
end

function ui.attackMatrixCallback(pack, id)
    local msgdata = pack.msgdata

    utils.recursionTab(msgdata, "attackMatrixCallback")

    if msgdata.int.fightType == 0 then return end

    pvp.loadGameData(pack)

    local int = pvp.InstPlayer.int or { }
    int["32"] = msgdata.int.avatarId
    pvp.InstPlayer.int = int

    if int["32"] < 0 then
        for key, obj in pairs(pvp.InstPlayerFormation) do
            if obj.int["4"] == 1 or obj.int["4"] == 2 then
                int["32"] = obj.int["6"]
                break
            end
        end
    end

    local string = pvp.InstPlayer.string or { }
    string["3"] = msgdata.string.playerName or ""
    pvp.InstPlayer.string = string

    ui.warParam = { msgdata.int.fightType, msgdata.int.playerId, id }
    local attBuff = msgdata.int.attBuff or 0
    local defBuff = msgdata.int.defBuff or 0

    utils.sendFightData( { attBuff = attBuff, defBuff = defBuff }, dp.FightType.FIGHT_OVERLORD_WAR, function(isWin)
        UIManager.showLoading()
        netSendPackage( {
            header = StaticMsgRule.resultMatrix,
            msgdata =
            {
                int = { fightType = ui.warParam[1], playerId = ui.warParam[2], id = ui.warParam[3], isWin = isWin and 1 or 0 },
                string = { coredata = GlobalLastFightCheckData }
            }
        } , function(pack)
            UIAllianceWar.warInfo.canAttackTime = pack.msgdata.long.canAttackTime or 0
            UIAllianceWar.systimes = pack.msgdata.long.systimes or 0
            UIAllianceWar.curTimerNumber = dp.curTimerNumber or 0
            UIAllianceWarWin.show(isWin, isWin and 1 or 0, attBuff, defBuff, pack.msgdata.string and pack.msgdata.string.things)
        end , function(pack)
            UIAllianceWar.warInfo.canAttackTime = UIAllianceWar.getCurrentTime() + UIAllianceWar.cooldown
            UIAllianceWarWin.show(isWin, -1, attBuff, defBuff, pack.msgdata.string and pack.msgdata.string.things)
        end )
    end )

    if not UIFightMain.Widget or not UIFightMain.Widget:getParent() then
        UIFightMain.loading()
    else
        UIFightMain.setup()
    end
end

function ui.init()
    local btn_help = ccui.Helper:seekNodeByName(ui.Widget, "btn_help")
    local btn_back = ccui.Helper:seekNodeByName(ui.Widget, "btn_back")
    local btn_rank_me = ccui.Helper:seekNodeByName(ui.Widget, "btn_rank_me")
    local btn_rank_you = ccui.Helper:seekNodeByName(ui.Widget, "btn_rank_you")
    local btn_deployed = ccui.Helper:seekNodeByName(ui.Widget, "btn_deployed")
    local btn_info = ccui.Helper:seekNodeByName(ui.Widget, "btn_info")
    local image_yin = ccui.Helper:seekNodeByName(ui.Widget, "image_yin"):getChildByName("image_yin")
    local image_jin = ccui.Helper:seekNodeByName(ui.Widget, "image_jin"):getChildByName("image_jin")
    local image_all = ccui.Helper:seekNodeByName(ui.Widget, "image_all"):getChildByName("image_all")

    btn_help:setPressedActionEnabled(true)
    btn_back:setPressedActionEnabled(true)
    btn_rank_me:setPressedActionEnabled(true)
    btn_rank_you:setPressedActionEnabled(true)
    btn_deployed:setPressedActionEnabled(true)
    btn_info:setPressedActionEnabled(true)

    image_yin:setTouchEnabled(true)
    image_jin:setTouchEnabled(true)
    image_all:setTouchEnabled(true)

    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            if sender == btn_help then
                UIAllianceHelp.show( { titleName = Lang.ui_alliance_war_info6, name = "allianceWar" })
            elseif sender == btn_back then
                UIAllianceWar.exitOverlordWar()
            elseif sender == btn_rank_me then
                UIAllianceWarRank.show(0)
            elseif sender == btn_rank_you then
                UIAllianceWarRank.show(1)
            elseif sender == btn_deployed then
                UIManager.pushScene("ui_lineup_embattle")
            elseif sender == btn_info then
                UIManager.pushScene("ui_alliance_war_hint")
            elseif sender == image_yin then
                inspireType = 0
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.inspireOverlord, msgdata = { int = { type = 0 } } }, netCallbackFunc)
            elseif sender == image_jin then
                inspireType = 1
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.inspireOverlord, msgdata = { int = { type = 1 } } }, netCallbackFunc)
            elseif sender == image_all then
                inspireType = 2
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.inspireOverlord, msgdata = { int = { type = 2 } } }, netCallbackFunc)
            end
        end
    end

    btn_help:addTouchEventListener(onButtonEvent)
    btn_back:addTouchEventListener(onButtonEvent)
    btn_rank_me:addTouchEventListener(onButtonEvent)
    btn_rank_you:addTouchEventListener(onButtonEvent)
    btn_deployed:addTouchEventListener(onButtonEvent)
    btn_info:addTouchEventListener(onButtonEvent)

    image_yin:addTouchEventListener(onButtonEvent)
    image_jin:addTouchEventListener(onButtonEvent)
    image_all:addTouchEventListener(onButtonEvent)

    local function onDefendEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            if not UIAllianceWar.enter then return end

            local tag = sender:getTag()
            local pointInfo = UIAllianceWar.warInfo.defendPointInfo[tag]
            if pointInfo.side == 0 then
                ui.tryAttack(tag, true)
            else
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.showMatrix, msgdata = { int = { id = tag } } }, function(pack)
                    local msgdata = pack.msgdata
                    UIAllianceWarCheck.id = tag
                    table.merge(UIAllianceWarCheck, msgdata.int)
                    table.merge(UIAllianceWarCheck, msgdata.string)
                    UIManager.pushScene("ui_alliance_war_check")
                end )
            end
        end
    end

    local image_basemap = btn_back:getParent()
    for i = 1, ui.DEFEND_COUNT do
        local image_player = image_basemap:getChildByName("panel" .. i)
        image_player:setTouchEnabled(true)
        image_player:setTag(UIAllianceWar.defendIDs[i])
        image_player:addTouchEventListener(onDefendEvent)
    end

    local function onAttackEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            if not UIAllianceWar.enter then return end

            local tag = sender:getTag()
            local info = UIAllianceWar.warInfo.attackPointInfo[tag]

            if info.durability <= 0 then
                UIManager.showToast(Lang.ui_alliance_war_info7)
                return
            end

            UIManager.showLoading()
            netSendPackage( { header = StaticMsgRule.showMatrix, msgdata = { int = { id = tag } } }, function(pack)
                local msgdata = pack.msgdata
                UIAllianceWarCheck.id = tag
                UIAllianceWarCheck.isAttackPoint = true
                table.merge(UIAllianceWarCheck, msgdata.int)
                table.merge(UIAllianceWarCheck, msgdata.string)
                UIManager.pushScene("ui_alliance_war_check")
            end )
        end
    end
    for i = 1, ui.ATTACK_COUNT do
        local image_enemy = image_basemap:getChildByName("panel_enemy" .. i)
        image_enemy:setTouchEnabled(true)
        image_enemy:setTag(UIAllianceWar.attackIDs[i])
        image_enemy:addTouchEventListener(onAttackEvent)
    end
end

local function playBattleAnimation()
    if not ui.Widget or not ui.Widget:getParent() then return end

    local image_basemap = ccui.Helper:seekNodeByName(ui.Widget, "image_basemap")

    for i = 1, math.random(3, 6) do
        local defendIndex = math.random(1, ui.DEFEND_COUNT)
        local attackIndex = math.random(1, ui.ATTACK_COUNT)

        local image_player = image_basemap:getChildByName("particle_player" .. defendIndex)
        local image_enemy = image_basemap:getChildByName("particle_enemy" .. attackIndex)

        local x1, y1 = image_player:getPositionX(), image_player:getPositionY()
        local x2, y2 = image_enemy:getPositionX(), image_enemy:getPositionY()

        if math.random(0, 100) > 50 then
            x1, y1, x2, y2 = x2, y2, x1, y1
        end
        local x, y = x2 - x1, y2 - y1
        local angle = math.deg(math.atan2(y, x))
        if angle < 0 then
            angle = - angle
        else
            angle = 360 - angle
        end

        angle = angle + 90

        local animation
        if next(ui.pool) then
            animation = ui.pool[1]
            image_basemap:addChild(animation)
            animation:release()
            table.remove(ui.pool, 1)
        else
            animation = ccs.Armature:create("ui_anim75")
            image_basemap:addChild(animation)
        end

        animation:getAnimation():play("ui_anim75_04", -1, 1)
        animation:setRotation(angle)
        animation:setPosition(x1, y1)
        animation:setTag(1)

        animation:runAction(cc.Sequence:create(cc.MoveTo:create(math.sqrt(x * x + y * y) / 800, cc.p(x2, y2)), cc.CallFunc:create( function()
            animation:getAnimation():play("ui_anim75_05")
            animation:setPosition(x2, y2)
            animation:setTag(2)
            local function onMovementEvent(armature, movementType, movementID)
                if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
                    if animation:getTag() ~= 2 then return end

                    animation:retain()
                    table.insert(ui.pool, animation)
                    animation:removeFromParent()
                end
            end
            animation:getAnimation():setMovementEventCallFunc(onMovementEvent)

        end )))
    end
end

local function timeCountdown()
    countdownTime = countdownTime - 1
    if countdownTime < 0 then
        countdownTime = 0
    end

    local text_time = ccui.Helper:seekNodeByName(ui.Widget, "image_basemap"):getChildByName("text_time")
    if countdownTime > 0 then
        local hour = math.floor(countdownTime / 3600)
        local minute = math.floor(countdownTime / 60 % 60)
        local second = math.floor(countdownTime % 60)
        text_time:show():setString(string.format(Lang.ui_alliance_war_info8, hour, minute, second))
    else
        text_time:hide()
    end
end

local function attacktimeCountdown()
    ui.attackCountdownTime = ui.attackCountdownTime - 1
    if ui.attackCountdownTime < 0 then
        ui.attackCountdownTime = 0
    end

    local image_time = ccui.Helper:seekNodeByName(ui.Widget, "image_basemap"):getChildByName("image_time")
    local text_time = image_time:getChildByName("text_time")
    if ui.attackCountdownTime > 0 then
        local hour = math.floor(ui.attackCountdownTime / 3600)
        local minute = math.floor(ui.attackCountdownTime / 60 % 60)
        local second = math.floor(ui.attackCountdownTime % 60)
        text_time:setString(string.format("%02d:%02d:%02d", hour, minute, second))
        image_time:show()
    else
        image_time:hide()
    end
end

function ui.playChangePointEffect(id)
    if not ui.Widget or not ui.Widget:getParent() then return end

    local i = table.indexof(UIAllianceWar.defendIDs, id)
    if not i then return end

    local image_basemap = ccui.Helper:seekNodeByName(ui.Widget, "image_basemap")
    local particle_player = image_basemap:getChildByName("particle_player" .. i)

    local animation
    if next(ui.pool) then
        animation = ui.pool[1]
        image_basemap:addChild(animation)
        animation:release()
        table.remove(ui.pool, 1)
    else
        animation = ccs.Armature:create("ui_anim75")
        image_basemap:addChild(animation)
    end

    local x, y = particle_player:getPositionX(), particle_player:getPositionY()
    animation:setPosition(x, y)
    animation:getAnimation():play("ui_anim75_03")
    animation:setTag(2)
    local function onMovementEvent(armature, movementType, movementID)
        if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
            if animation:getTag() ~= 2 then return end

            animation:retain()
            table.insert(ui.pool, animation)
            animation:removeFromParent()
        end
    end

    animation:getAnimation():setMovementEventCallFunc(onMovementEvent)
end

function ui.setup()
    UIAllianceWar.curUI = ui

    local image_basemap = ccui.Helper:seekNodeByName(ui.Widget, "image_basemap")

    local text_me_defend = image_basemap:getChildByName("image_di_me"):getChildByName("text_me")
    local text_me_attack = image_basemap:getChildByName("image_di_other"):getChildByName("text_me")

    text_me_defend:setVisible(UIAllianceWar.isDefend)
    text_me_attack:setVisible(not UIAllianceWar.isDefend)

    local image_di_loading = image_basemap:getChildByName("image_di_loading")
    local bar_blue = image_di_loading:getChildByName("bar_blue")
    local bar_red = image_di_loading:getChildByName("bar_red")

    local totalScore = UIAllianceWar.warInfo.defendScore + UIAllianceWar.warInfo.attackScore
    bar_blue:setPercent(totalScore == 0 and 50 or UIAllianceWar.warInfo.defendScore * 100 / totalScore)
    image_di_loading:getChildByName("text_number_blue"):setString(tostring(UIAllianceWar.warInfo.defendScore))

    bar_red:setPercent(totalScore == 0 and 50 or UIAllianceWar.warInfo.attackScore * 100 / totalScore)
    image_di_loading:getChildByName("text_number_red"):setString(tostring(UIAllianceWar.warInfo.attackScore))

    local btn_info = image_basemap:getChildByName("btn_info")

    local image_di_property = image_basemap:getChildByName("image_di_property")
    local image_di_alliance = image_basemap:getChildByName("image_di_alliance")
    local panel_shadow = image_basemap:getChildByName("panel_shadow")

    local function onMovementEvent(armature, movementType, movementID)
        if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
            armature:getAnimation():stop()
            armature:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create( function()
                armature:getAnimation():play("ui_anim75_06")
            end )))
        end
    end

    for i = 1, ui.DEFEND_COUNT do
        local defendPointInfo = UIAllianceWar.warInfo.defendPointInfo[UIAllianceWar.defendIDs[i]]

        local image_player = image_basemap:getChildByName("image_player" .. i)
        local text_player = image_player:getChildByName("text_player")
        text_player:setString(defendPointInfo.side == 0 and Lang.ui_alliance_war_info9 or defendPointInfo.name)
        text_player:setTextColor(defendPointInfo.side <= 1 and ui.BLUE_COLOR or ui.RED_COLOR)

        if i >= 2 and i <= 6 then
            local node_player = image_basemap:getChildByName("particle_player" .. i):getChildByName("node_player")
            node_player:getAnimation():setMovementEventCallFunc(onMovementEvent)
        end
    end

    local isPrepare = UIAllianceWar.state == UIAllianceWar.STATE.OUTER_PREPARE or UIAllianceWar.state == UIAllianceWar.STATE.INNER_PREPARE

    ui.attackCountdownTime = UIAllianceWar.warInfo.canAttackTime - UIAllianceWar.getCurrentTime()
    if isPrepare then ui.attackCountdownTime = 0 end
    if ui.attackCountdownTime > 0 then
        dp.addTimerListener(attacktimeCountdown)
    else
        attacktimeCountdown()
    end

    if not isPrepare and UIAllianceWar.state ~= UIAllianceWar.STATE.NONE then
        if not ui.battleScheduleId then
            ui.battleScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(playBattleAnimation, 3, false)
        end
    else
        if ui.battleScheduleId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(ui.battleScheduleId)
            ui.battleScheduleId = nil
        end
    end

    btn_info:setVisible(isPrepare)
    image_di_property:setVisible(isPrepare)
    image_di_alliance:setVisible(isPrepare)
    panel_shadow:setVisible(isPrepare)

    for i = 1, ui.ATTACK_COUNT do
        local image_enemy = image_basemap:getChildByName("image_enemy" .. i)
        local particle_enemy = image_basemap:getChildByName("particle_enemy" .. i)

        if isPrepare then
            image_enemy:setVisible(false)
            particle_enemy:setVisible(false)
        else
            image_enemy:setVisible(true)
            particle_enemy:setVisible(true)
            image_enemy:getChildByName("text_enemy"):setString(Lang.ui_alliance_war_info10)
            local text_number = ccui.Helper:seekNodeByName(image_enemy, "text_number")
            local info = UIAllianceWar.warInfo.attackPointInfo[UIAllianceWar.attackIDs[i]]
            text_number:setString(info.durability .. "/" .. info.maxDurability)
        end
    end

    if isPrepare then
        if UIAllianceWar.state == UIAllianceWar.STATE.OUTER_PREPARE then
            countdownTime = UIAllianceWar.outerStartTime - UIAllianceWar.getCurrentTime()
        else
            countdownTime = UIAllianceWar.innerStartTime - UIAllianceWar.getCurrentTime()
        end

        dp.addTimerListener(timeCountdown)

        local text_add1 = ccui.Helper:seekNodeByName(image_di_property, "text_add1")
        local text_add2 = ccui.Helper:seekNodeByName(image_di_property, "text_add2")
        local text_yin = ccui.Helper:seekNodeByName(image_di_property, "text_yin")
        local text_jin = ccui.Helper:seekNodeByName(image_di_property, "text_jin")

        text_add1:setString(string.format(Lang.ui_alliance_war_info11, UIAllianceWar.warInfo.defendAdd[1]))
        text_add2:setString(string.format(Lang.ui_alliance_war_info12, UIAllianceWar.warInfo.defendAdd[2]))
        text_yin:setString(Lang.ui_alliance_war_info13 .. UIAllianceWar.defendAddCfg[1])
        text_jin:setString(Lang.ui_alliance_war_info14 .. UIAllianceWar.defendAddCfg[2])

        local text_add = ccui.Helper:seekNodeByName(image_di_alliance, "text_add")
        local text_all = ccui.Helper:seekNodeByName(image_di_alliance, "text_all")
        local image_all = image_di_alliance:getChildByName("image_all"):getChildByName("image_all")

        text_add:setString(string.format(Lang.ui_alliance_war_info15, UIAllianceWar.warInfo.defendAdd[3]))
        text_all:setString(Lang.ui_alliance_war_info16 .. UIAllianceWar.defendAddCfg[3])
        local isGray = UIAllianceWar.warInfo.defendAdd[2] < 50
        utils.GrayWidget(image_all, isGray)
        image_all:setEnabled(not isGray)
    else
        if UIAllianceWar.state == UIAllianceWar.STATE.OUTER_FIGHT then
            countdownTime = UIAllianceWar.outerEndTime - UIAllianceWar.getCurrentTime()
        elseif UIAllianceWar.state == UIAllianceWar.STATE.INNER_FIGHT then
            countdownTime = UIAllianceWar.innerEndTime - UIAllianceWar.getCurrentTime()
        else
            countdownTime = 0
        end

        dp.addTimerListener(timeCountdown)
    end
end

function ui.free()
    dp.removeTimerListener(timeCountdown)
    dp.removeTimerListener(attacktimeCountdown)
    ui.attackCountdownTime = 0
    if ui.battleScheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(ui.battleScheduleId)
        ui.battleScheduleId = nil
    end
end

function ui.updateTimer(interval)
    if not ui.Widget or not ui.attackCountdownTime then return end
    ui.attackCountdownTime = ui.attackCountdownTime - interval
    if ui.attackCountdownTime < 0 then
        ui.attackCountdownTime = 0
    end
end
