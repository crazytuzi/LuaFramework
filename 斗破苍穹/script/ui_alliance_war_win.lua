require"Lang"
UIAllianceWarWin = { }

local ui = UIAllianceWarWin

function ui.init()
    local btn_report = ccui.Helper:seekNodeByName(ui.Widget, "btn_report")
    btn_report:setPressedActionEnabled(true)

    local function touchevent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            UIAllianceWar.open()

            if ui.reward then
                utils.showGetThings(ui.reward)
                ui.reward = nil
            end
        end
    end

    btn_report:addTouchEventListener(touchevent)
end

function ui.show(isWin, resultCode, attBuff, defBuff, reward)
    local info
    if resultCode == 1 then
        info = Lang.ui_alliance_war_win1 .. pvp.InstPlayer.string["3"]
    elseif resultCode == 0 then
        info = Lang.ui_alliance_war_win2 .. pvp.InstPlayer.string["3"] .. Lang.ui_alliance_war_win3
    else
        info = Lang.ui_alliance_war_win4
    end
    local animationId = isWin and 11 or 12
    local armature = ActionManager.getUIAnimation(animationId)

    ui.param = { info = info, animation = armature, attBuff = attBuff, defBuff = defBuff }
    ui.reward = reward
    UIManager.pushScene("ui_alliance_war_win")
end

function ui.setup()
    local text_hint = ccui.Helper:seekNodeByName(ui.Widget, "text_hint")
    text_hint:setString(ui.param.info)

    local image_basemap = ccui.Helper:seekNodeByName(ui.Widget, "image_basemap")
    local size = image_basemap:getContentSize()
    ui.param.animation:setPosition(size.width / 2, size.height)
    image_basemap:addChild(ui.param.animation)

    local image_frame_player = ccui.Helper:seekNodeByName(ui.Widget, "image_frame_player")
    local label_fight = ccui.Helper:seekNodeByName(image_frame_player, "label_fight")
    local text_name = ccui.Helper:seekNodeByName(image_frame_player, "text_name")
    local image_player = image_frame_player:getChildByName("image_player")

    image_player:loadTexture("image/" .. DictUI[tostring(DictCard[tostring(net.InstPlayer.int["32"])].smallUiId)].fileName)
    text_name:setString(net.InstPlayer.string["3"])
    label_fight:setString(tostring(math.round(utils.getFightValue() * (1 + ui.param.attBuff / 100))))

    image_frame_player = ccui.Helper:seekNodeByName(ui.Widget, "image_frame_player_rival")
    local label_fight = ccui.Helper:seekNodeByName(image_frame_player, "label_fight")
    local text_name = ccui.Helper:seekNodeByName(image_frame_player, "text_name_rival")
    local image_player = image_frame_player:getChildByName("image_player")

    image_player:loadTexture("image/" .. DictUI[tostring(DictCard[tostring(pvp.InstPlayer.int["32"])].smallUiId)].fileName)
    text_name:setString(pvp.InstPlayer.string["3"])
    label_fight:setString(tostring(math.round(pvp.getFightValue() * (1 + ui.param.defBuff / 100))))
end

function ui.free()
    ui.param = nil
end
