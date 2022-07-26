require"Lang"
UIWar = {
    BATTLE_FIELD_NAMES = { Lang.ui_war1, Lang.ui_war2, Lang.ui_war3, Lang.ui_war4 },
    STATE_NONE = 0,
    STATE_EMBATTLE = 1,
    STATE_BATTLE = 2,
    STATE_FINISH = 3,

    BF_STATE =
    {
        PREPARE = 1,
        FIGHTING = 2,
        FAIL = 3,
        WIN = 4,
        DRAW = 5,
    },

    MEMBER_STATE =
    {
        NO_QUALIFICATION = - 2,
        AMBUSH = - 1,
        NONE = 0,
        BF1 = 1,
        BF2 = 2,
        BF3 = 3,
        BF4 = 4,
    },

    REPORT_TYPE =
    {
        FIGHT = 0,
        AMBUSH = 1,
        BATTLEFIELD = 2,
        BATTLEFIELD_DRAW = 3,
    },

    EVENT =
    {
        INIT = 0,
        SIGN_UP = 1,
        CANCEL_SIGN_UP = 2,
        ORDER = 3,
        SET_AMBUSH = 4,
        DESET_AMBUSH = 5,
        AMBUSH_ENTER = 6,
        START = 7,
        BATTLE_FIELD_START = 8,
        FIGHT = 9,
        BATTLE_FIELD_FINISH = 10,
        FINISH = 11,
        CLOSE = 12,
    },

    myColor = cc.c3b(0x00,0xF5,0xFF),
    enemyColor = cc.c3b(0xFF,0x25,0x25),
    commonColor = cc.c3b(0xFF,0xD0,0x7D),
}

local ui = UIWar

function ui.getAmbushRewardStr()
    local reward = Lang.ui_war5
    if ui.ambushReward and #ui.ambushReward > 0 then
        reward = utils.stringSplit(ui.ambushReward[1], ";")
        for i, s in ipairs(reward) do
            local r = utils.getItemProp(s)
            reward[i] = r.name .. "x" .. r.count
        end
        reward = table.concat(reward, ", ", 1, #reward)
    end
    return reward
end

local function showFinishDialog(isWin)
    local ui_middle = ccui.Layout:create()
    ui_middle:setContentSize(display.size)
    ui_middle:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    ui_middle:setBackGroundColor(display.COLOR_BLACK)
    ui_middle:setBackGroundColorOpacity(255 * 59)
    ui_middle:setTouchEnabled(true)

    local image_basemap = ccui.ImageView:create("ui/tk_di_xiao.png")
    local size = cc.size(632 * 0.8, 566 * 0.8)
    image_basemap:ignoreContentAdaptWithSize(false)
    image_basemap:setContentSize(size)
    image_basemap:setPosition(display.width / 2, display.height / 2)
    utils.GrayWidget(image_basemap, not isWin)
    ui_middle:addChild(image_basemap)

    local animationId = isWin and 11 or 12
    local armature = ActionManager.getUIAnimation(animationId)
    armature:setPosition(size.width / 2, size.height)
    image_basemap:addChild(armature)

    local text1 = ccui.Text:create(isWin and Lang.ui_war6 or Lang.ui_war7, dp.FONT, 24)
    text1:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    text1:setPosition(size.width / 2, size.height * 0.75)
    image_basemap:addChild(text1)

    local text2 = ccui.Text:create(ui.myUnionBattle.name, dp.FONT, 28)
    text2:setTextColor(ui.myColor)
    text2:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    text2:setPosition(size.width / 2, size.height * 0.75 -(96 + 24) / 2)
    image_basemap:addChild(text2)

    local text3 = ccui.RichText:create()
    text3:setAnchorPoint(display.CENTER)
    if isWin then
        text3:pushBackElement(ccui.RichElementText:create(1, display.COLOR_WHITE, 255, Lang.ui_war8, dp.FONT, 24))
        text3:pushBackElement(ccui.RichElementText:create(2, ui.enemyColor, 255, ui.enemyUnionBattle.name, dp.FONT, 24))
    else
        text3:pushBackElement(ccui.RichElementText:create(1, display.COLOR_WHITE, 255, Lang.ui_war9, dp.FONT, 24))
        text3:pushBackElement(ccui.RichElementText:create(2, ui.enemyColor, 255, ui.enemyUnionBattle.name, dp.FONT, 24))
        text3:pushBackElement(ccui.RichElementText:create(3, display.COLOR_WHITE, 255, Lang.ui_war10, dp.FONT, 24))
    end
    text3:setPosition(size.width / 2, size.height * 0.75 - 96 - 24)
    image_basemap:addChild(text3)

    local text4 = ccui.Text:create(isWin and Lang.ui_war11 or Lang.ui_war12, dp.FONT, 24)
    text4:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    text4:setPosition(size.width / 2, size.height * 0.75 - 144 - 36)
    image_basemap:addChild(text4)

    local btn_sure = ccui.Button:create("ui/tk_btn_purple.png")
    btn_sure:setTitleColor(display.COLOR_WHITE)
    btn_sure:setTitleFontName(dp.FONT)
    btn_sure:setTitleFontSize(24)
    btn_sure:setPosition(size.width / 2, 48)
    btn_sure:setTitleText(Lang.ui_war13)
    btn_sure:ignoreContentAdaptWithSize(false)
    btn_sure:setContentSize(cc.size(199 * 0.8, 72 * 0.8))
    image_basemap:addChild(btn_sure)
    btn_sure:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            image_basemap:runAction(cc.ScaleTo:create(0.2, 0.1))
            ui_middle:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.RemoveSelf:create()))
        end
    end )

    image_basemap:setScale(0.1)
    UIManager.uiLayer:addChild(ui_middle, 10000)
    image_basemap:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.06, 1)))
end

local function buildText(color, str)
    return ccui.RichElementText:create(1, color, 255, str, dp.FONT, 20)
end

local function buildBlank(size)
    local node = cc.Node:create()
    node:setContentSize(size)
    return ccui.RichElementCustomNode:create(1, display.COLOR_WHITE, 255, node)
end

local function setScrollViewItem(item, data)
    item:show():removeChildByName("text_info")

    local text_info = ccui.RichText:create()
    text_info:ignoreContentAdaptWithSize(false)
    text_info:setContentSize(cc.size(481, 90))
    text_info:setPosition(250.5, 69)
    text_info:setName("text_info")
    text_info:setVerticalSpace(8)
    item:addChild(text_info)

    local btn_look = item:getChildByName("btn_look")
    if data[1] == ui.REPORT_TYPE.AMBUSH then
        btn_look:hide()

        local report = data[2]
        text_info:pushBackElement(buildText(report.unionId == net.InstUnionMember.int["2"] and ui.myColor or ui.enemyColor, string.format("【%s】%s", report.unionName, report.name)))
        text_info:pushBackElement(buildText(ui.commonColor, string.format(Lang.ui_war14, ui.BATTLE_FIELD_NAMES[report.state])))
    elseif data[1] == ui.REPORT_TYPE.BATTLEFIELD_DRAW then
        btn_look:hide()
        local fieldId = data[2]
        text_info:pushBackElement(buildText(ui.commonColor, string.format(Lang.ui_war15, ui.BATTLE_FIELD_NAMES[fieldId])))
    elseif data[1] == ui.REPORT_TYPE.BATTLEFIELD then
        btn_look:hide()

        local report = data[2]
        local fieldId = data[3]
        local battleField = data[2].battleFields[fieldId]
        local str = ""

        local color = report.id == net.InstUnionMember.int["2"] and ui.myColor or ui.enemyColor
        local size = cc.size(481, 0)
        text_info:setVerticalSpace(4)
        if battleField.state == ui.BF_STATE.WIN then
            text_info:pushBackElement(buildText(color, string.format("【%s】", report.name)))
            text_info:pushBackElement(buildText(ui.commonColor, string.format(Lang.ui_war16, ui.BATTLE_FIELD_NAMES[fieldId])))
            text_info:pushBackElement(buildText(color, tostring(ui.battlefieldIntros[fieldId].point)))
            text_info:pushBackElement(buildText(ui.commonColor, Lang.ui_war17))
            text_info:pushBackElement(buildBlank(size))

            text_info:pushBackElement(buildText(ui.commonColor, Lang.ui_war18))
            text_info:pushBackElement(buildText(color, tostring(battleField.killCount)))
            text_info:pushBackElement(buildText(ui.commonColor, Lang.ui_war19))
            text_info:pushBackElement(buildText(color, tostring(battleField.killPoint)))
            text_info:pushBackElement(buildText(ui.commonColor, Lang.ui_war20))
            text_info:pushBackElement(buildBlank(size))

            text_info:pushBackElement(buildText(ui.commonColor, Lang.ui_war21))
            text_info:pushBackElement(buildText(color, tostring(battleField.surviveCount)))
            text_info:pushBackElement(buildText(ui.commonColor, Lang.ui_war22))
            text_info:pushBackElement(buildText(color, tostring(battleField.survivePoint)))
            text_info:pushBackElement(buildText(ui.commonColor, Lang.ui_war23))
        elseif battleField.state == ui.BF_STATE.FAIL then
            text_info:pushBackElement(buildText(color, string.format("【%s】", report.name)))
            text_info:pushBackElement(buildText(ui.commonColor, string.format(Lang.ui_war24, ui.BATTLE_FIELD_NAMES[fieldId])))
            text_info:pushBackElement(buildBlank(size))

            text_info:pushBackElement(buildText(ui.commonColor, Lang.ui_war25))
            text_info:pushBackElement(buildText(color, tostring(battleField.killCount)))
            text_info:pushBackElement(buildText(ui.commonColor, Lang.ui_war26))
            text_info:pushBackElement(buildText(color, tostring(battleField.killPoint)))
            text_info:pushBackElement(buildText(ui.commonColor, Lang.ui_war27))
            text_info:pushBackElement(buildBlank(size))

            text_info:pushBackElement(buildText(ui.commonColor, Lang.ui_war28))
            text_info:pushBackElement(buildText(color, tostring(battleField.surviveCount)))
            text_info:pushBackElement(buildText(ui.commonColor, Lang.ui_war29))
            text_info:pushBackElement(buildText(color, tostring(battleField.survivePoint)))
            text_info:pushBackElement(buildText(ui.commonColor, Lang.ui_war30))
        end
    elseif data[1] == ui.REPORT_TYPE.FIGHT then
        btn_look:show()

        local report = data[2]

        btn_look:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                audio.playSound("sound/button.mp3")
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.unionReplay, msgdata = { int = { instVideoId = report[4] } } }, function(pack)
                    local video = pack.msgdata.string.video
                    local Fight_INIT_DATA = loadstring(video)()

                    if UITalkFly.layer then
                        UITalkFly.hide()
                    end
                    UIFightMain.setData(Fight_INIT_DATA, nil, dp.FightType.FIGHT_UNION_REPLAY, function(isWin)
                        if ui.myKey == "b" then
                            isWin = not isWin
                        end
                        local info = Lang.ui_war31
                        info = string.format(info, ui.BATTLE_FIELD_NAMES[report[2].state], report[5], report[2].unionName, report[2].name, report[3].unionName, report[3].name)
                        local animationId = isWin and 11 or 12
                        local armature = ActionManager.getUIAnimation(animationId)
                        UITowerWinSmall.show( {
                            isWin = isWin,
                            fightType = dp.FightType.FIGHT_UNION_REPLAY,
                            animation = armature,
                            info = info,
                            callbackfunc = function()
                                audio.playMusic("sound/bg_music.mp3", true)
                                if armature and armature:getParent() then armature:removeFromParent() end
                                ui.scrollToFight = report[1]
                                UIManager.showScreen("ui_war", "ui_menu")
                                local text_hint = ccui.Helper:seekNodeByName(ui.Widget, "text_hint")
                                text_hint:releaseUpEvent()
                            end
                        } )
                    end )
                    if not UIFightMain.Widget or not UIFightMain.Widget:getParent() then
                        UIFightMain.loading()
                    else
                        UIFightMain.setup()
                    end
                    WidgetManager.delete(ui)
                end )
            end
        end )

        text_info:pushBackElement(buildText(ui.commonColor, string.format(Lang.ui_war32, ui.BATTLE_FIELD_NAMES[report[2].state], report[5])))
        text_info:pushBackElement(buildText(report[2].unionId == net.InstUnionMember.int["2"] and ui.myColor or ui.enemyColor, string.format("【%s】%s", report[2].unionName, report[2].name)))
        text_info:pushBackElement(buildText(ui.commonColor, Lang.ui_war33))
        text_info:pushBackElement(buildText(report[3].unionId == net.InstUnionMember.int["2"] and ui.myColor or ui.enemyColor, string.format("【%s】%s", report[3].unionName, report[3].name)))
    end
end

function ui.canModify()
    local selfGradeId = net.InstUnionMember.int["4"]
    return ui.state == ui.STATE_EMBATTLE and(selfGradeId == 1 or selfGradeId == 2)
end

local function netCallbackFunc(pack)
    local code = tonumber(pack.header)
    if code == StaticMsgRule.unionMember then
        local unionMember = pack.msgdata.message.unionMember
        local memberList = { }
        for key, obj in pairs(unionMember.message) do
            local id = obj.int["3"]
            local fightValue = obj.int["15"]
            local member = ui.myUnionMemberBattle[id]
            if member then
                member.fightValue = fightValue
            end
        end
        ui.hasSetFightValue = true
        UIManager.pushScene("ui_war_ambush")
    end
end

function ui.init()
    local btn_back = ccui.Helper:seekNodeByName(ui.Widget, "btn_back")
    local btn_schedule = ccui.Helper:seekNodeByName(ui.Widget, "btn_schedule")
    local btn_soldier = ccui.Helper:seekNodeByName(ui.Widget, "btn_soldier")
    btn_soldier:setPressedActionEnabled(true)
    local btn_rank = ccui.Helper:seekNodeByName(ui.Widget, "btn_rank")
    btn_rank:setPressedActionEnabled(true)
    local btn_help = ccui.Helper:seekNodeByName(ui.Widget, "btn_help")
    btn_help:setPressedActionEnabled(true)

    local text_hint = ccui.Helper:seekNodeByName(ui.Widget, "text_hint")
    text_hint:setTouchEnabled(true)
    text_hint:setTouchScaleChangeEnabled(true)

    local btn_collect = ccui.Helper:seekNodeByName(ui.Widget, "btn_collect")

    local image_hint_situation = ccui.Helper:seekNodeByName(ui.Widget, "image_hint_situation")
    local width = image_hint_situation:getContentSize().width
    local px = image_hint_situation:getPositionX()
    image_hint_situation:setPositionX(- width + px)

    local view_situation = image_hint_situation:getChildByName("view_situation")
    local panel = view_situation:getChildByName("panel")
    panel:getChildByName("btn_look"):setLocalZOrder(2)
    panel:retain()
    panel:removeFromParent()
    panel:hide()
    btn_collect:addChild(panel)
    panel:release()

    local function setCascadeOpacityEnabled(node, enabled)
        node:setCascadeOpacityEnabled(enabled)
        for i, child in ipairs(node:getChildren()) do
            setCascadeOpacityEnabled(child, enabled)
        end
    end

    local image_basemap = image_hint_situation:getParent()
    for i = 1, 4 do
        local panel_battlefield = image_basemap:getChildByName("panel_battlefield" .. i)
        local image_look = panel_battlefield:getChildByName("image_look")
        local image_seize = panel_battlefield:getChildByName("image_seize")
        local image_fight = panel_battlefield:getChildByName("image_fight")

        setCascadeOpacityEnabled(image_look, true)
        setCascadeOpacityEnabled(image_seize, true)
        setCascadeOpacityEnabled(image_fight, true)
    end

    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            if sender == btn_back then
                UIManager.hideWidget("ui_war")
                UIManager.hideWidget("ui_menu")
                WidgetManager.delete(ui)
                UIManager.showWidget("ui_notice", "ui_alliance")
            elseif sender == btn_schedule then
                UIManager.pushScene("ui_war_schedule")
            elseif sender == btn_soldier then
                if ui.state ~= ui.STATE_NONE then
                    if ui.hasSetFightValue then
                        UIManager.pushScene("ui_war_ambush")
                    else
                        UIManager.showLoading()
                        netSendPackage( {
                            header = StaticMsgRule.unionMember,
                            msgdata = { int = { instUnionMemberId = net.InstUnionMember.int["1"] } }
                        } , netCallbackFunc)
                    end
                else
                    UIManager.showToast(Lang.ui_war34)
                end
            elseif sender == btn_rank then
                UIManager.pushScene("ui_war_rank")
            elseif sender == btn_help then
                UIAllianceHelp.show( { titleName = Lang.ui_war35, type = 13 })
                local text_war1 = ccui.Helper:seekNodeByName(UIAllianceHelp.Widget, "text_war1")
                text_war1:setString(string.format(text_war1:getString(), ui.getAmbushRewardStr()))
            elseif sender == text_hint then
                image_hint_situation:stopAllActions()
                image_hint_situation:runAction(cc.MoveTo:create(math.abs(px - image_hint_situation:getPositionX()) * 0.6 / width, cc.p(px, image_hint_situation:getPositionY())))
            elseif sender == btn_collect then
                image_hint_situation:stopAllActions()
                image_hint_situation:runAction(cc.MoveTo:create(math.abs(px - width - image_hint_situation:getPositionX()) * 0.6 / width, cc.p(px - width, image_hint_situation:getPositionY())))
            end
        end
    end

    btn_back:addTouchEventListener(onButtonEvent)
    btn_schedule:addTouchEventListener(onButtonEvent)
    btn_soldier:addTouchEventListener(onButtonEvent)
    btn_rank:addTouchEventListener(onButtonEvent)
    btn_help:addTouchEventListener(onButtonEvent)
    text_hint:addTouchEventListener(onButtonEvent)
    btn_collect:addTouchEventListener(onButtonEvent)
end

local function bounceNumberAction()
    return cc.Sequence:create(cc.ScaleTo:create(0.2, 1.3), cc.ScaleTo:create(0.2, 1))
end

local function refreshPoint(text, unionBattle)
    if ui.state == ui.STATE_BATTLE and unionBattle.playPointAni and #unionBattle.playPointAni > 0 then
        local points = unionBattle.playPointAni[1]
        local curPoint = points[2]
        local oldPoint = points[1]
        table.remove(unionBattle.playPointAni, 1)
        if curPoint ~= oldPoint then
            text:setString(tostring(oldPoint))
            local step =(curPoint - oldPoint) /(2000 * cc.Director:getInstance():getAnimationInterval())
            step = math.ceil(step)
            text:scheduleUpdate( function()
                local minMax = step > 0 and math.min or math.max
                local point = minMax(tonumber(text:getString()) + step, curPoint)
                text:setString(tostring(point))

                if step > 0 then
                    if point >= curPoint then refreshPoint(text, unionBattle) end
                else
                    if point <= curPoint then refreshPoint(text, unionBattle) end
                end
            end )
            return
        end
    end
    text:unscheduleUpdate()
    text:show():setString(unionBattle.point)
end

local function refreshImage_fight(image_frame, image, fighter)
    image_frame:show():setTouchEnabled(true)
    image:loadTexture("image/" .. DictUI[tostring(DictCard[tostring(fighter.iconId)].smallUiId)].fileName)
end

function ui.setup()
    local image_basemap = ccui.Helper:seekNodeByName(ui.Widget, "image_basemap")
    local image_time = ccui.Helper:seekNodeByName(ui.Widget, "image_time")

    local btn_soldier = image_basemap:getChildByName("btn_soldier")

    local image_situation = image_basemap:getChildByName("image_situation")
    local image_hint_situation = image_basemap:getChildByName("image_hint_situation")

    local image_base_title = image_basemap:getChildByName("image_base_title")
    local image_blue = image_base_title:getChildByName("image_blue")
    local text_number_blue = image_blue:getChildByName("text_number")

    local image_red = image_base_title:getChildByName("image_red")
    local text_name_red = image_red:getChildByName("text_name")
    local text_number_red = image_red:getChildByName("text_number")

    image_blue:getChildByName("text_name"):setString(ui.allianceName)

    local myUnionBattle = ui.myUnionBattle
    local enemyUnionBattle = ui.enemyUnionBattle
    local myUnionMemberBattle = ui.myUnionMemberBattle
    local enemyUnionMemberBattle = ui.enemyUnionMemberBattle

    ui.state = myUnionBattle and myUnionBattle.state or(ui.state or ui.STATE_NONE)

    image_time:setVisible(ui.state ~= ui.STATE_BATTLE and ui.state ~= ui.STATE_FINISH)

    if ui.state == ui.STATE_NONE then
        text_number_blue:setString(0)
        text_name_red:hide()
        text_number_red:hide()
        image_situation:hide()
        image_hint_situation:hide()
        btn_soldier:getChildByName("text_number"):hide()
        btn_soldier:getChildByName("text_number_0"):hide()

        for i, name in ipairs(ui.BATTLE_FIELD_NAMES) do
            local panel_battlefield = image_basemap:getChildByName("panel_battlefield" .. i)
            local image_look = panel_battlefield:getChildByName("image_look")
            local image_seize = panel_battlefield:getChildByName("image_seize")
            local image_fight = panel_battlefield:getChildByName("image_fight")
            local image_join = panel_battlefield:getChildByName("image_join")
            local image_frame_good = panel_battlefield:getChildByName("image_frame_good")

            panel_battlefield:setTouchEnabled(false)
            image_look:setOpacity(255)
            image_look:show()
            image_look:getChildByName("text_name"):setString(name)
            image_look:getChildByName("text_number"):setString(Lang.ui_war36)
            image_seize:hide()
            image_fight:hide()
            image_join:hide()
            image_frame_good:hide()
        end

        if not UIWarSchedule.Widget then
            UIManager.pushScene("ui_war_schedule")
        end
    else
        text_name_red:show():setString(enemyUnionBattle.name)
        refreshPoint(text_number_blue, myUnionBattle)
        refreshPoint(text_number_red, enemyUnionBattle)
        btn_soldier:getChildByName("text_number"):show():setString(myUnionBattle.ambushCount)
        btn_soldier:getChildByName("text_number_0"):setVisible(ui.my.state == ui.MEMBER_STATE.AMBUSH or ui.my.enterFight >= 0)

        for i, name in ipairs(ui.BATTLE_FIELD_NAMES) do
            local panel_battlefield = image_basemap:getChildByName("panel_battlefield" .. i)
            local image_look = panel_battlefield:getChildByName("image_look")
            local image_seize = panel_battlefield:getChildByName("image_seize")
            local image_fight = panel_battlefield:getChildByName("image_fight")
            local image_join = panel_battlefield:getChildByName("image_join")
            local image_frame_good = panel_battlefield:getChildByName("image_frame_good")

            image_look:setOpacity(255)
            image_seize:setOpacity(255)
            image_fight:setOpacity(255)
            for k = 1, 2 do
                local color = k == 1 and "blue" or "red"
                local image_frame = image_fight:getChildByName("image_frame_" .. color)
                local image = image_frame:getChildByName("image_" .. color)
                image_frame:setOpacity(255)
                image:setOpacity(255)
            end

            panel_battlefield:setTouchEnabled(true)

            local myBattleField = myUnionBattle.battleFields[i]
            local enemyBattleField = enemyUnionBattle.battleFields[i]

            if ui.state == ui.STATE_EMBATTLE or myBattleField.state == ui.BF_STATE.WIN then
                local reward = ui.battlefieldIntros[i].reward
                if string.len(reward) > 0 then
                    if image_frame_good:getNumberOfRunningActions() <= 0 then
                        image_frame_good:show()
                        local itemProp = utils.getItemProp(reward)
                        utils.addBorderImage(itemProp.tableTypeId, itemProp.tableFieldId, image_frame_good)
                        image_frame_good:getChildByName("image_good"):loadTexture(itemProp.smallIcon)
                        local text_number = image_frame_good:getChildByName("text_number")
                        if itemProp.count > 1 then
                            text_number:show():setString("×" .. itemProp.count)
                        else
                            text_number:hide()
                        end
                        image_frame_good:getChildByName("text_name"):setString(itemProp.name)
                        utils.showThingsInfo(image_frame_good, itemProp.tableTypeId, itemProp.tableFieldId)
                    end
                else
                    image_frame_good:hide()
                end
            else
                image_frame_good:hide()
            end

            image_join:setVisible(ui.my.state == i)

            panel_battlefield:addTouchEventListener( function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    audio.playSound("sound/button.mp3")
                    UIWarInfo.show(i)
                end
            end )

            if ui.state == ui.STATE_EMBATTLE then
                panel_battlefield:removeChildByName("ani_kill")

                image_look:show()
                image_look:getChildByName("text_name"):setString(name)
                image_look:getChildByName("text_number"):setString(Lang.ui_war37 .. #myBattleField.survive)
                image_seize:hide()
                image_fight:hide()
            elseif myBattleField.state == ui.BF_STATE.WIN or myBattleField.state == ui.BF_STATE.FAIL or myBattleField.state == ui.BF_STATE.DRAW then
                local image_last = image_look:isVisible() and image_look or image_fight

                image_look:hide()
                local text_me = image_seize:show():getChildByName("text_me")
                if myBattleField.state == ui.BF_STATE.WIN then
                    text_me:setTextColor(ui.myColor)
                    text_me:setString(Lang.ui_war38)
                elseif myBattleField.state == ui.BF_STATE.FAIL then
                    text_me:setTextColor(ui.enemyColor)
                    text_me:setString(Lang.ui_war39)
                else
                    text_me:setTextColor(display.COLOR_WHITE)
                    text_me:setString(Lang.ui_war40)
                end
                image_seize:getChildByName("text_name"):setString(name)
                image_fight:hide()

                if ui.playSeizeAni and ui.playSeizeAni[i] then
                    ui.playSeizeAni[i] = nil
                    image_frame_good:hide()
                    image_seize:scheduleUpdate( function()
                        image_last:show()
                        image_seize:setOpacity(0)
                        image_frame_good:hide()
                        if image_fight:getChildByName("ani_kill") then return end
                        if image_fight:getChildByName("image_frame_blue"):getNumberOfRunningActions() > 0 then return end
                        if image_fight:getChildByName("image_frame_red"):getNumberOfRunningActions() > 0 then return end

                        if not(ui.playKillAni and ui.playKillAni[i] and #ui.playKillAni[i] > 0) then
                            local t = 0.4

                            image_last:runAction(cc.Sequence:create(cc.FadeOut:create(t / 2), cc.Hide:create()))
                            image_seize:runAction(cc.EaseExponentialOut:create(cc.FadeIn:create(t / 2)))

                            local flag = image_seize:getChildByName("image_seize")
                            flag:setScale(8)
                            flag:runAction(cc.EaseExponentialOut:create(cc.ScaleTo:create(t, 1.0)))
                            if myBattleField.state == ui.BF_STATE.WIN and string.len(ui.battlefieldIntros[i].reward) > 0 then
                                image_frame_good:runAction(cc.Sequence:create(cc.DelayTime:create(t), cc.Show:create()))
                            end
                            image_seize:unscheduleUpdate()
                        end
                    end )
                end
            else
                image_look:hide()
                image_seize:hide()
                image_fight:show()

                local text_number_blue = image_fight:getChildByName("text_number_blue")
                local text_number_red = image_fight:getChildByName("text_number_red")
                local text_name = image_fight:getChildByName("text_name")
                local text_title = image_fight:getChildByName("text_title")
                local image_frame_blue = image_fight:getChildByName("image_frame_blue")
                local image_frame_red = image_fight:getChildByName("image_frame_red")

                text_name:setString(name)
                text_number_blue:setString(Lang.ui_war41 .. #myBattleField.survive)
                text_number_red:setString(Lang.ui_war42 .. #enemyBattleField.survive)

                if myBattleField.state == ui.BF_STATE.PREPARE then
                    text_title:show()
                    image_frame_blue:hide()
                    image_frame_red:hide()
                    local ani_fight = image_fight:getChildByName("ani_fight")
                    if ani_fight then ani_fight:hide() end
                elseif myBattleField.state == ui.BF_STATE.FIGHTING then
                    text_title:hide()

                    if myBattleField.playBounceAction and myBattleField.playBounceAction ~= 0 then
                        myBattleField.playBounceAction = nil
                        text_number_blue:stopAllActions()
                        text_number_blue:runAction(bounceNumberAction())
                    end
                    if enemyBattleField.playBounceAction and enemyBattleField.playBounceAction ~= 0 then
                        enemyBattleField.playBounceAction = nil
                        text_number_red:stopAllActions()
                        text_number_red:runAction(bounceNumberAction())
                    end

                    image_fight:scheduleUpdate( function(dt)
                        if image_fight:getChildByName("ani_kill") then return end
                        if image_fight:getChildByName("image_frame_blue"):getNumberOfRunningActions() > 0 then return end
                        if image_fight:getChildByName("image_frame_red"):getNumberOfRunningActions() > 0 then return end

                        local hideFightAni = false
                        local hasKillAni = ui.playKillAni and ui.playKillAni[i] and #ui.playKillAni[i] > 0

                        local hasPlayKillAniBefore = false
                        if hasKillAni then
                            for k = 1, i - 1 do
                                local panel_battlefield = image_basemap:getChildByName("panel_battlefield" .. k)
                                local image_fight = panel_battlefield:getChildByName("image_fight")

                                local result = image_fight:getChildByName("ani_kill") ~= nil
                                result = result or image_fight:getChildByName("image_frame_blue"):getNumberOfRunningActions() > 0
                                result = result or image_fight:getChildByName("image_frame_red"):getNumberOfRunningActions() > 0

                                if result or(ui.playKillAni and ui.playKillAni[k] and #ui.playKillAni[k] > 0) then
                                    hasPlayKillAniBefore = true
                                    break
                                end
                            end
                        end

                        if hasKillAni and not hasPlayKillAniBefore then
                            local data = ui.playKillAni[i][1]
                            table.remove(ui.playKillAni[i], 1)

                            local x, y = image_fight:getPosition()
                            for k, fighter in pairs(data.fighters) do
                                local color = k == 1 and "blue" or "red"
                                local image_frame = image_fight:getChildByName("image_frame_" .. color)
                                local image = image_frame:getChildByName("image_" .. color)

                                if data[k] then
                                    local x1, y1 = image_frame:getPosition()
                                    local t1 = 75 * cc.Director:getInstance():getAnimationInterval()
                                    local t2 =(93 - 75) * cc.Director:getInstance():getAnimationInterval()

                                    local ani_kill = ActionManager.getEffectAnimation(23, function() panel_battlefield:removeChildByName("ani_kill") end, 0)
                                    ani_kill:setName("ani_kill")
                                    ani_kill:getBone("Layer73"):addDisplay(ccs.Skin:create("image/" .. DictUI[tostring(DictCard[tostring(data[k].iconId)].bigUiId)].fileName), 0)
                                    ani_kill:setScale(0.3)
                                    ani_kill:setPosition(x - 170 + x1, y - 30 + y1)
                                    panel_battlefield:addChild(ani_kill)

                                    if fighter then
                                        image_frame:runAction(cc.Sequence:create(cc.FadeOut:create(t1), cc.CallFunc:create( function() refreshImage_fight(image_frame, image, fighter) end), cc.FadeIn:create(t2)))
                                    else
                                        image_frame:runAction(cc.FadeOut:create(t1))
                                    end
                                else
                                    if fighter then
                                        refreshImage_fight(image_frame, image, fighter)
                                    else
                                        hideFightAni = true
                                        image_frame:hide()
                                    end
                                end
                            end
                        else
                            local fighters = { myBattleField.survive[1] or false, enemyBattleField.survive[1] or false }

                            for k = 1, 2 do
                                local fighter = fighters[k]
                                local color = k == 1 and "blue" or "red"
                                local image_frame = image_fight:getChildByName("image_frame_" .. color)
                                local image = image_frame:getChildByName("image_" .. color)

                                if fighter then
                                    refreshImage_fight(image_frame, image, fighter)
                                else
                                    hideFightAni = true
                                    image_frame:hide()
                                end
                            end
                        end

                        local ani_fight = image_fight:getChildByName("ani_fight")
                        if not hideFightAni then
                            if not ani_fight then
                                ani_fight = ActionManager.getEffectAnimation(24)
                                ani_fight:setName("ani_fight")
                                ani_fight:setScale(0.3)
                                ani_fight:getAnimation():playWithIndex(0)
                                image_fight:addChild(ani_fight)
                            end
                            ani_fight:show()

                            local x1, y1 = image_fight:getChildByName("image_frame_blue"):getPosition()
                            local x2, y2 = image_fight:getChildByName("image_frame_red"):getPosition()
                            ani_fight:setPosition((x1 + x2) / 2 - 4,(y1 + y2) / 2 - 8)
                        elseif ani_fight then
                            ani_fight:hide()
                        end

                        if not hasKillAni then
                            image_fight:unscheduleUpdate()
                        end
                    end )
                end

                if not panel_battlefield:getChildByName("ani_ambush") then
                    if ui.playAmbushAni and ui.playAmbushAni[i] then
                        for k = 1, 2 do
                            local ambushs = ui.playAmbushAni[i][k]

                            if #ambushs > 0 then
                                local x, y = image_fight:getPosition()

                                local uiAnimId = 58
                                local animPath = "ani/ui_anim/ui_anim" .. uiAnimId .. "/"
                                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
                                ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")

                                local animation = ccs.Armature:create("ui_anim" .. uiAnimId)
                                animation:setName("ani_ambush")
                                panel_battlefield:addChild(animation)
                                if k == 1 then
                                    animation:setPosition(x - 170 + 45, y - 30 + 45)
                                else
                                    animation:setPosition(x + 170 - 45, y - 30 + 45)
                                end
                                animation:getAnimation():playWithIndex(k - 1)

                                local function onMovementEvent(armature, movementType, movementID)
                                    if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
                                        table.remove(ui.playAmbushAni[i][k], 1)
                                        if #ui.playAmbushAni[i][k] <= 0 or myBattleField.state ~= ui.BF_STATE.FIGHTING then
                                            ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
                                            ccs.ArmatureDataManager:getInstance():removeArmatureData(movementID)
                                            animation:removeFromParent()
                                        else
                                            animation:getAnimation():playWithIndex(k - 1)
                                        end
                                    end
                                end

                                animation:getAnimation():setMovementEventCallFunc(onMovementEvent)
                            end
                        end
                    end
                end
            end
        end

    end

    if ui.state == ui.STATE_EMBATTLE or ui.state == ui.STATE_NONE then
        image_situation:hide()
        image_hint_situation:hide()
    else
        image_situation:show()
        image_hint_situation:show()

        if ui.lastReportCount ~= #ui.reports then
            local panel_situation = image_situation:getChildByName("panel_situation")
            panel_situation:setClippingEnabled(true)
            local text_hint = image_situation:getChildByName("text_hint")

            local view_situation = image_hint_situation:getChildByName("view_situation")
            local panel = image_hint_situation:getChildByName("btn_collect"):getChildByName("panel")
            view_situation:removeAllChildren()
            UIWar.isFlush = true
            local scrollingEvent = utils.updateScrollView(UIWar, view_situation, panel, ui.reports, setScrollViewItem, { space = 3, setTag = true })

            local order
            if ui.scrollToFight then
                for i, report in ipairs(ui.reports) do
                    if report[1] == ui.REPORT_TYPE.FIGHT then
                        if report[2][1] == ui.scrollToFight then
                            order = i
                            break
                        end
                    end
                end
                ui.scrollToFight = nil
            end

            if order then
                local innerHeight = view_situation:getInnerContainerSize().height
                local scrollViewSize = view_situation:getContentSize()
                local size = panel:getContentSize()

                local max = innerHeight - scrollViewSize.height
                local thumb = order *(size.height + 3) - size.height / 2 - scrollViewSize.height / 2
                local percent = 100 * math.min(1, math.max(0, thumb / max))
                view_situation:jumpToPercentVertical(percent)
                scrollingEvent(true)
            else
                view_situation:scrollToBottom(1.0, true)
            end

            local i = ui.lastReportCount and ui.lastReportCount + 1 or math.max(1, #ui.reports)

            if i <= #ui.reports and ui.reports[i][1] == ui.REPORT_TYPE.BATTLEFIELD then
                local report = ui.reports[i]
                local fieldId = report[3]
                local battleField = report[2].battleFields[fieldId]
                if battleField.state == ui.BF_STATE.FAIL then
                    i = i - 1
                end
            end

            while i <= #ui.reports do
                local report = ui.reports[i]

                local str = ""
                if report[1] == ui.REPORT_TYPE.FIGHT then
                    report = report[2]
                    str = string.format(Lang.ui_war43, ui.BATTLE_FIELD_NAMES[report[2].state], report[5], report[2].unionName, report[2].name, report[3].unionName, report[3].name)
                elseif report[1] == ui.REPORT_TYPE.AMBUSH then
                    report = report[2]
                    str = string.format(Lang.ui_war44, report.unionName, report.name, ui.BATTLE_FIELD_NAMES[report.state])
                elseif report[1] == ui.REPORT_TYPE.BATTLEFIELD_DRAW then
                    local fieldId = report[2]
                    str = string.format(Lang.ui_war45, ui.BATTLE_FIELD_NAMES[fieldId])
                elseif report[1] == ui.REPORT_TYPE.BATTLEFIELD then
                    str = Lang.ui_war46
                    for k = 0, 1 do
                        local report = ui.reports[k + i]
                        local fieldId = report[3]
                        local battleField = report[2].battleFields[fieldId]
                        if battleField.state == ui.BF_STATE.WIN then
                            str = str .. string.format(Lang.ui_war47, report[2].name, ui.BATTLE_FIELD_NAMES[fieldId], ui.battlefieldIntros[fieldId].point, battleField.killCount, battleField.killPoint, battleField.surviveCount, battleField.survivePoint)
                        else
                            str = str .. string.format(Lang.ui_war48, report[2].name, ui.BATTLE_FIELD_NAMES[fieldId], battleField.killCount, battleField.killPoint, battleField.surviveCount, battleField.survivePoint)
                        end
                    end
                    i = i + 1
                end

                ui.realReports = ui.realReports or { }
                table.insert(ui.realReports, str)
                i = i + 1
            end

            if ui.realReports and #ui.realReports > 0 then
                local text_report = panel_situation:getChildByName("text_report")
                if not text_report then
                    local size = panel_situation:getContentSize()

                    text_report = ccui.Text:create("", dp.FONT, 20)
                    text_report:setTextColor(ui.commonColor)
                    text_report:setName("text_report")
                    panel_situation:addChild(text_report)

                    local function resetTextReport()
                        if ui.realReports and #ui.realReports > 0 then
                            local str = ui.realReports[1]
                            text_report:setString(str)
                            local distance = size.width + text_report:getContentSize().width
                            text_report:stopAllActions()
                            text_report:setPosition(size.width + text_report:getContentSize().width / 2, size.height / 2)
                            local action = cc.Sequence:create(cc.MoveBy:create(distance / 120, cc.p(- distance, 0)), cc.CallFunc:create(resetTextReport))
                            text_report:runAction(cc.RepeatForever:create(action))
                            table.remove(ui.realReports, 1)
                        else
                            text_report:setPosition(size.width + text_report:getContentSize().width / 2, size.height / 2)
                        end
                    end

                    resetTextReport()
                end
            end

            ui.lastReportCount = #ui.reports
        end
    end

    UIManager.flushWidget(UIWarInfo)
    UIManager.flushWidget(UIWarAmbush)
end

local function calAmbushCount(unionBattle, unionMemberBattle)
    if not unionMemberBattle or not unionBattle then return end
    local ambushCount = 0
    for id, member in pairs(unionMemberBattle) do
        if member.state == ui.MEMBER_STATE.AMBUSH then
            ambushCount = ambushCount + 1
        end
    end
    unionBattle.ambushCount = ambushCount
end

local function addMemberlist(memberlist, s, mState, unionBattle, setOrder)
    local s = utils.stringSplit(s, "/")
    for i, data in ipairs(s) do
        data = utils.stringSplit(data, "|")
        local member = {
            id = tonumber(data[1] or 0),
            name = data[2] or "",
            level = tonumber(data[3] or 0),
            fightValue = tonumber(data[4] or 0),
            iconId = tonumber(data[5] or 0),
            gradeId = tonumber(data[6] or 0),
            isVIP = tonumber(data[7] or "0") > 0,
            state = mState or 0,
            unionId = unionBattle.id or 0,
            unionName = unionBattle.name or "",
            order = setOrder and i or 0,
            enterFight = - 1,
            survive = data[8] == "1",
            latestFight = 0,
            fights = 0,
        }
        memberlist[member.id] = member

        if member.state >= 1 then
            local battleField = unionBattle.battleFields[member.state]
            if member.survive then
                table.insert(battleField.survive, member)
            else
                table.insert(battleField.dead, member)
            end
        end
    end
end

local function buildUnionMember(obj, side, unionBattle)
    obj = obj or { int = { }, string = { } }

    local t = { }

    local aNoQualification = obj.string[side .. "NoQualification"] or ""
    local aNotRegistered = obj.string[side .. "NotRegistered"] or ""
    local aAmbush = obj.string[side .. "Ambush"] or ""

    addMemberlist(t, aNoQualification, ui.MEMBER_STATE.NO_QUALIFICATION, unionBattle)
    addMemberlist(t, aNotRegistered, ui.MEMBER_STATE.NONE, unionBattle)
    addMemberlist(t, aAmbush, ui.MEMBER_STATE.AMBUSH, unionBattle)

    for i = 1, 4 do
        local battfield = obj.string[side .. "Battfield" .. i] or ""
        addMemberlist(t, battfield, i, unionBattle, true)
    end

    return t
end

local function buildUnionBattle(obj, side)
    obj = obj or { int = { }, string = { } }

    local t = { }
    t.id = obj.int[side .. "Id"] or 0
    t.pos = obj.int.againstIndex or 0
    t.name = obj.string[side .. "Name"] or ""
    t.state = obj.int.state

    local battle = utils.stringSplit(obj.string["4"] or "", "|")
    local battleFields = { }
    for i = 1, 4 do
        local bf = obj.message[tostring(i)] or { int = { }, string = { } }
        local state = bf.int.state or ui.BF_STATE.PREPARE
        local isAWin = bf.int.isAWin

        local battleField = {
            state = state ~= 3 and state or(isAWin == 1 and ui.BF_STATE.WIN or(isAWin == 0 and ui.BF_STATE.FAIL or ui.BF_STATE.DRAW)),
            killCount = 0,
            killPoint = 0,
            surviveCount = 0,
            survivePoint = 0,
            survive = { },
            dead = { },
        }
        battleField.killPoint = bf.int[side .. "KillScore"] or 0
        battleField.survivePoint = bf.int[side .. "AliveScore"] or 0
        table.insert(battleFields, battleField)
    end
    t.battleFields = battleFields
    t.point = obj.int[side .. "Score"] or 0
    t.ambushCount = 0

    return t
end

local function checkPoint(unionBattle, point, ignoreAni)
    point = 0

    if ui.myUnionBattle.state >= ui.STATE_BATTLE then
        local otherUnionBattle = unionBattle == ui.myUnionBattle and ui.enemyUnionBattle or ui.myUnionBattle
        for i = 1, 4 do
            local bf = unionBattle.battleFields[i]
            local otherBf = otherUnionBattle.battleFields[i]
            local bfIntro = ui.battlefieldIntros[i]

            if bf.state == ui.BF_STATE.FIGHTING then
                point = point + bfIntro.killScore * #otherBf.dead
            elseif bf.state == ui.BF_STATE.FAIL or bf.state == ui.BF_STATE.WIN then
                point = point + bfIntro.killScore * #otherBf.dead + bfIntro.aliveScore * #bf.survive +(bf.state == ui.BF_STATE.WIN and bfIntro.point or 0)
            elseif bf.state ~= ui.BF_STATE.DRAW then
                break
            end
        end
    end

    if point and point ~= unionBattle.point then
        if not ignoreAni then
            unionBattle.playPointAni = unionBattle.playPointAni or { }
            table.insert(unionBattle.playPointAni, { unionBattle.point, point })
        end
        unionBattle.point = point
    end
end

local function getUnionData(unionId)
    if unionId == ui.myUnionBattle.id then
        return ui.myUnionBattle, ui.myUnionMemberBattle
    elseif unionId == ui.enemyUnionBattle.id then
        return ui.enemyUnionBattle, ui.enemyUnionMemberBattle
    end
end

function ui.onWarEvent(msgdata)
    local ignoreAni = not ui.Widget or not ui.Widget:getParent()

    local event = msgdata.int.event
    if event == ui.EVENT.INIT then
        local battlefieldIntros = { }
        for i = 1, 4 do
            local battleField = msgdata.message[tostring(i)]
            table.insert(battlefieldIntros, { point = tonumber(battleField.int.score or 0), reward = battleField.string.reward or "", aliveScore = battleField.int.aliveScore or 0, killScore = battleField.int.killScore or 0 })
        end
        ui.battlefieldIntros = battlefieldIntros

        if msgdata.int.aId == net.InstUnionMember.int["2"] then
            ui.myKey = "a"
            ui.enemyKey = "b"
        else
            ui.myKey = "b"
            ui.enemyKey = "a"
        end

        ui.ambushMax = msgdata.int[ui.myKey .. "Limit"] or 0

        ui.lastReportCount = nil
        ui.realReports = nil
        ui.maxFightId = 0

        ui.myUnionBattle = buildUnionBattle(msgdata, ui.myKey)
        ui.myUnionMemberBattle = buildUnionMember(msgdata, ui.myKey, ui.myUnionBattle)
        ui.enemyUnionBattle = buildUnionBattle(msgdata, ui.enemyKey)
        ui.enemyUnionMemberBattle = buildUnionMember(msgdata, ui.enemyKey, ui.enemyUnionBattle)

        UIWar.my = ui.myUnionMemberBattle[net.InstPlayer.int["1"]] or { id = net.InstPlayer.int["1"], state = ui.MEMBER_STATE.NO_QUALIFICATION, enterFight = 0 }

        ui.reports = { }

        for i = 1, math.huge do
            local report = msgdata.message["report" .. i]
            if not report then break end
            local event = report.int.event
            if event == ui.EVENT.AMBUSH_ENTER then
                local id = report.int.playerId
                local unionBattle, unionMemberBattle

                if ui.myUnionMemberBattle[id] then
                    unionBattle = ui.myUnionBattle
                    unionMemberBattle = ui.myUnionMemberBattle
                else
                    unionBattle = ui.enemyUnionBattle
                    unionMemberBattle = ui.enemyUnionMemberBattle
                end

                local member = unionMemberBattle[id]
                member.enterFight = ui.maxFightId

                table.insert(ui.reports, { ui.REPORT_TYPE.AMBUSH, member })
            elseif event == ui.EVENT.BATTLE_FIELD_FINISH then
                local fieldId = report.int.battlefieldId
                local myBattleField = ui.myUnionBattle.battleFields[fieldId]
                local enemyBattleField = ui.enemyUnionBattle.battleFields[fieldId]

                local flag = ui.myKey == "a" and 1 or -1
                local flag2 = report.int.isAWin == 1 and 1 or(report.int.isAWin == 0 and -1 or 0)
                flag = flag * flag2

                if flag > 0 then
                    myBattleField.state = ui.BF_STATE.WIN
                    enemyBattleField.state = ui.BF_STATE.FAIL
                elseif flag < 0 then
                    myBattleField.state = ui.BF_STATE.FAIL
                    enemyBattleField.state = ui.BF_STATE.WIN
                else
                    myBattleField.state = ui.BF_STATE.DRAW
                    enemyBattleField.state = ui.BF_STATE.DRAW
                end

                myBattleField.killCount = #enemyBattleField.dead
                myBattleField.surviveCount = #myBattleField.survive
                enemyBattleField.killCount = #myBattleField.dead
                enemyBattleField.surviveCount = #enemyBattleField.survive

                if flag ~= 0 then
                    table.insert(ui.reports, { ui.REPORT_TYPE.BATTLEFIELD, myBattleField.state == ui.BF_STATE.WIN and ui.myUnionBattle or ui.enemyUnionBattle, fieldId })
                    table.insert(ui.reports, { ui.REPORT_TYPE.BATTLEFIELD, myBattleField.state == ui.BF_STATE.FAIL and ui.myUnionBattle or ui.enemyUnionBattle, fieldId })
                else
                    table.insert(ui.reports, { ui.REPORT_TYPE.BATTLEFIELD_DRAW, fieldId })
                end
            elseif event == ui.EVENT.FIGHT then
                local fieldId = report.int.battlefieldId
                local fightId = report.int.fightCount
                local recordId = report.int.instVideoId

                local winner = ui.myUnionMemberBattle[report.int[ui.myKey .. "Id"]]
                local failer = ui.enemyUnionMemberBattle[report.int[ui.enemyKey .. "Id"]]

                local flag = ui.myKey == "a" and 1 or -1
                local flag2 = report.int.isAWin == 1 and 1 or -1

                if flag * flag2 < 0 then
                    winner, failer = failer, winner
                end

                local myBattleField = ui.myUnionBattle.battleFields[fieldId]
                local enemyBattleField = ui.enemyUnionBattle.battleFields[fieldId]

                winner.latestFight = fightId
                winner.fights =(winner.fights or 0) + 1

                failer.survive = false
                failer.latestFight = fightId
                failer.fights =(failer.fights or 0) + 1

                if not myBattleField.fromFight then
                    myBattleField.fromFight = fightId
                end

                ui.maxFightId = math.max(ui.maxFightId, fightId)
                table.insert(ui.reports, { ui.REPORT_TYPE.FIGHT, { fightId, winner, failer, recordId, fightId - myBattleField.fromFight + 1 } })
            end
        end
        checkPoint(ui.myUnionBattle, 0, true)
        checkPoint(ui.enemyUnionBattle, 0, true)
    elseif event == ui.EVENT.SIGN_UP then
        local id = msgdata.int.playerId
        local fieldId = msgdata.int.battlefieldId
        local unionBattle, unionMemberBattle = getUnionData(msgdata.int.unionId)

        local survive = unionBattle.battleFields[fieldId].survive
        local member = unionMemberBattle[id]
        if member.state >= ui.MEMBER_STATE.BF1 then
            table.removebyvalue(unionBattle.battleFields[member.state].survive, member)
        end
        table.insert(survive, member)
        member.state = fieldId
        member.order = #survive
    elseif event == ui.EVENT.CANCEL_SIGN_UP then
        local id = msgdata.int.playerId
        local fieldId = msgdata.int.battlefieldId
        local unionBattle, unionMemberBattle = getUnionData(msgdata.int.unionId)

        local survive = unionBattle.battleFields[fieldId].survive
        local member = unionMemberBattle[id]
        table.removebyvalue(survive, member)
        member.state = ui.MEMBER_STATE.NONE
        member.order = 0
    elseif event == ui.EVENT.ORDER then
        local fieldId = msgdata.int.battlefieldId
        local unionBattle, unionMemberBattle = getUnionData(msgdata.int.unionId)

        local survive = utils.stringSplit(msgdata.string.idList, "_")
        for i = 1, #survive do
            local member = unionMemberBattle[tonumber(survive[i])]
            member.state = fieldId
            member.order = i
            survive[i] = member
        end
        unionBattle.battleFields[fieldId].survive = survive
    elseif event == ui.EVENT.SET_AMBUSH then
        local id = msgdata.int.playerId
        local unionBattle, unionMemberBattle = getUnionData(msgdata.int.unionId)
        local member = unionMemberBattle[id]
        member.order = 0
        if member.state >= ui.MEMBER_STATE.BF1 and member.state <= ui.MEMBER_STATE.BF4 then
            table.removebyvalue(unionBattle.battleFields[member.state].survive, member)
        end
        member.state = ui.MEMBER_STATE.AMBUSH
    elseif event == ui.EVENT.DESET_AMBUSH then
        local id = msgdata.int.playerId
        local unionBattle, unionMemberBattle = getUnionData(msgdata.int.unionId)
        local member = unionMemberBattle[id]
        member.state = msgdata.int.lastType or ui.MEMBER_STATE.NONE
        if member.state >= ui.MEMBER_STATE.BF1 and member.state <= ui.MEMBER_STATE.BF4 then
            local survive = unionBattle.battleFields[member.state].survive
            table.insert(survive, member)
            member.order = #survive
        end
    elseif event == ui.EVENT.AMBUSH_ENTER then
        local id = msgdata.int.playerId
        local fieldId = msgdata.int.battlefieldId
        local unionBattle, unionMemberBattle

        if ui.myUnionMemberBattle[id] then
            unionBattle = ui.myUnionBattle
            unionMemberBattle = ui.myUnionMemberBattle
        else
            unionBattle = ui.enemyUnionBattle
            unionMemberBattle = ui.enemyUnionMemberBattle
        end

        checkPoint(unionBattle, msgdata.int.score, ignoreAni)

        local member = unionMemberBattle[id]
        local battleField = unionBattle.battleFields[fieldId]
        table.insert(battleField.survive, member)
        member.state = fieldId
        member.enterFight = ui.maxFightId
        member.order = #battleField.survive

        ui.reports = ui.reports or { }
        table.insert(ui.reports, { ui.REPORT_TYPE.AMBUSH, member })

        if not ignoreAni then
            ui.playAmbushAni = ui.playAmbushAni or { }
            ui.playAmbushAni[fieldId] = ui.playAmbushAni[fieldId] or { { }, { } }
            table.insert(ui.playAmbushAni[fieldId][unionBattle == ui.myUnionBattle and 1 or 2], member)

            battleField.playBounceAction =(battleField.playBounceAction or 0) + 1

            if UIWarInfo.fieldId == fieldId and battleField.state == ui.BF_STATE.FIGHTING then
                UIWarInfo.playAmbushAni = UIWarInfo.playAmbushAni or { false, false }
                local k = ui.myUnionMemberBattle[id] and 1 or 2
                UIWarInfo.playAmbushAni[k] = member
            end
        end
    elseif event == ui.EVENT.START then
        ui.myUnionBattle.state = ui.STATE_BATTLE
        ui.enemyUnionBattle.state = ui.STATE_BATTLE
        ui.lastReportCount = 0
        ui.reports = { }
        ui.maxFightId = 0
    elseif event == ui.EVENT.BATTLE_FIELD_START then
        local fieldId = msgdata.int.battlefieldId
        ui.myUnionBattle.battleFields[fieldId].state = ui.BF_STATE.FIGHTING
        ui.enemyUnionBattle.battleFields[fieldId].state = ui.BF_STATE.FIGHTING
    elseif event == ui.EVENT.FIGHT then
        local fieldId = msgdata.int.battlefieldId
        local fightId = msgdata.int.fightCount
        local recordId = msgdata.int.instVideoId

        local winner = ui.myUnionMemberBattle[msgdata.int[ui.myKey .. "Id"]]
        local failer = ui.enemyUnionMemberBattle[msgdata.int[ui.enemyKey .. "Id"]]

        local flag = ui.myKey == "a" and 1 or -1
        local flag2 = msgdata.int.isAWin == 1 and 1 or -1

        if flag * flag2 < 0 then
            winner, failer = failer, winner
        end

        local myBattleField = ui.myUnionBattle.battleFields[fieldId]
        local enemyBattleField = ui.enemyUnionBattle.battleFields[fieldId]

        winner.latestFight = fightId
        winner.fights =(winner.fights or 0) + 1
        failer.survive = false
        failer.latestFight = fightId
        failer.fights =(failer.fights or 0) + 1

        if not ignoreAni then
            ui.playKillAni = ui.playKillAni or { }
            ui.playKillAni[fieldId] = ui.playKillAni[fieldId] or { }
        end

        if ui.myUnionMemberBattle[failer.id] then
            table.removebyvalue(myBattleField.survive, failer)
            table.insert(myBattleField.dead, failer)
            table.removebyvalue(enemyBattleField.survive, winner)
            table.insert(enemyBattleField.survive, winner)
            myBattleField.playBounceAction =(myBattleField.playBounceAction or 0) -1
        else
            table.removebyvalue(enemyBattleField.survive, failer)
            table.insert(enemyBattleField.dead, failer)
            table.removebyvalue(myBattleField.survive, winner)
            table.insert(myBattleField.survive, winner)
            enemyBattleField.playBounceAction =(enemyBattleField.playBounceAction or 0) -1
        end

        checkPoint(ui.myUnionBattle, msgdata.int[ui.myKey .. "Score"], ignoreAni)
        checkPoint(ui.enemyUnionBattle, msgdata.int[ui.enemyKey .. "Score"], ignoreAni)

        if not ignoreAni then
            table.insert(ui.playKillAni[fieldId], { [ui.myUnionMemberBattle[failer.id] and 1 or 2] = failer, fighters = { [1] = myBattleField.survive[1] or false, [2] = enemyBattleField.survive[1] or false } })
        end

        if not myBattleField.fromFight then
            myBattleField.fromFight = fightId
        end

        ui.maxFightId = math.max(ui.maxFightId, fightId)
        ui.reports = ui.reports or { }
        table.insert(ui.reports, { ui.REPORT_TYPE.FIGHT, { fightId, winner, failer, recordId, fightId - myBattleField.fromFight + 1 } })

        if UIWarInfo.fieldId == fieldId and myBattleField.state == ui.BF_STATE.FIGHTING then
            if ui.myUnionMemberBattle[winner.id] then
                UIWarInfo.playFightAni = { winner, failer }
            else
                UIWarInfo.playFightAni = { failer, winner }
            end
        end
    elseif event == ui.EVENT.BATTLE_FIELD_FINISH then
        local fieldId = msgdata.int.battlefieldId
        local myBattleField = ui.myUnionBattle.battleFields[fieldId]
        local enemyBattleField = ui.enemyUnionBattle.battleFields[fieldId]

        local flag = ui.myKey == "a" and 1 or -1
        local flag2 = msgdata.int.isAWin == 1 and 1 or(msgdata.int.isAWin == 0 and -1 or 0)
        flag = flag * flag2

        if flag > 0 then
            myBattleField.state = ui.BF_STATE.WIN
            enemyBattleField.state = ui.BF_STATE.FAIL
        elseif flag < 0 then
            myBattleField.state = ui.BF_STATE.FAIL
            enemyBattleField.state = ui.BF_STATE.WIN
        else
            myBattleField.state = ui.BF_STATE.DRAW
            enemyBattleField.state = ui.BF_STATE.DRAW
        end

        myBattleField.killCount = #enemyBattleField.dead
        myBattleField.killPoint = msgdata.int[ui.myKey .. "KillScore"] or 0
        myBattleField.surviveCount = #myBattleField.survive
        myBattleField.survivePoint = msgdata.int[ui.myKey .. "AliveScore"] or 0

        enemyBattleField.killCount = #myBattleField.dead
        enemyBattleField.killPoint = msgdata.int[ui.enemyKey .. "KillScore"] or 0
        enemyBattleField.surviveCount = #enemyBattleField.survive
        enemyBattleField.survivePoint = msgdata.int[ui.enemyKey .. "AliveScore"] or 0

        checkPoint(ui.myUnionBattle, msgdata.int[ui.myKey .. "Score"], ignoreAni)
        checkPoint(ui.enemyUnionBattle, msgdata.int[ui.enemyKey .. "Score"], ignoreAni)

        ui.reports = ui.reports or { }
        if flag ~= 0 then
            table.insert(ui.reports, { ui.REPORT_TYPE.BATTLEFIELD, myBattleField.state == ui.BF_STATE.WIN and ui.myUnionBattle or ui.enemyUnionBattle, fieldId })
            table.insert(ui.reports, { ui.REPORT_TYPE.BATTLEFIELD, myBattleField.state == ui.BF_STATE.FAIL and ui.myUnionBattle or ui.enemyUnionBattle, fieldId })
        else
            table.insert(ui.reports, { ui.REPORT_TYPE.BATTLEFIELD_DRAW, fieldId })
        end

        if not ignoreAni then
            ui.playSeizeAni = ui.playSeizeAni or { }
            ui.playSeizeAni[fieldId] = true
        end
    elseif event == ui.EVENT.FINISH then
        local isAWin = msgdata.int.isAWin
        ui.myUnionBattle.state = ui.STATE_FINISH
        ui.enemyUnionBattle.state = ui.STATE_FINISH
        ui.lastReportCount = #ui.reports

        local isWin =(isAWin == 1 and 1 or -1) *(ui.myKey == "a" and 1 or -1) > 0
        if not ignoreAni then
            showFinishDialog(isWin)
        end
    elseif event == ui.EVENT.CLOSE then
        if not ignoreAni then
            UIManager.hideWidget("ui_war")
            WidgetManager.delete(ui)
            UIManager.showWidget("ui_alliance")
            ui.myUnionBattle = nil
            ui.myUnionMemberBattle = nil
            ui.enemyUnionBattle = nil
            ui.enemyUnionMemberBattle = nil
            ui.my = nil
            ui.reports = nil
            ui.state = nil
            UIManager.showToast(msgdata.string and msgdata.string.strerror or Lang.ui_war49)
        end
        return
    end

    calAmbushCount(ui.myUnionBattle, ui.myUnionMemberBattle)
    calAmbushCount(ui.enemyUnionBattle, ui.enemyUnionMemberBattle)
    UIManager.flushWidget(ui)
    UIWarInfo.playFightAni = nil
    UIWarInfo.playAmbushAni = nil
end

function ui.free()
    ui.state = nil
    ui.lastReportCount = nil
    ui.realReports = nil
    ui.playAmbushAni = nil
    ui.playKillAni = nil
    ui.playSeizeAni = nil
    ui.hasSetFightValue = nil
end
