require"Lang"
UIWarAmbush = {
    NAME_COLOR = cc.c3b(0x33,0x19,0x04),
    LEVEL_COLOR = cc.c3b(0x8B,0x45,0x13),
    NAME_COLOR_GRAY = cc.c3b(0x1a,0x1a,0x1a),
    LEVEL_COLOR_GRAY = cc.c3b(0x4B,0x4B,0x4B),
}

local ui = UIWarAmbush
local memberItem = nil

local function setScrollViewItem(item, data)
    local image_job = item:getChildByName("image_job")
    local btn_look = item:getChildByName("btn_look")
    local btn_ambush = item:getChildByName("btn_ambush")
    local image_ambush = item:getChildByName("image_ambush")

    local image_di_info = item:getChildByName("image_di_info")
    local text_name = image_di_info:getChildByName("text_name")
    local text_state = image_di_info:getChildByName("text_state")
    local text_fight = image_di_info:getChildByName("text_fight")
    local text_lv = image_di_info:getChildByName("text_lv")

    local image_frame_title = image_di_info:getChildByName("image_frame_title")
    local image_title = image_frame_title:getChildByName("image_title")
    local image_vip = image_frame_title:getChildByName("image_vip")

    local grade = UIAlliance.getAllianceGrade(data.gradeId)
    image_job:loadTexture(grade.icon)
    image_job:getChildByName("text_job"):setString(grade.name)

    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            if sender == btn_look then
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.enemyPlayerInfo, msgdata = { int = { playerId = data.id } } }, function(pack)
                    if pack.msgdata.message then
                        pvp.loadGameData(pack)
                        UIManager.pushScene("ui_arena_check")
                    end
                end )
            elseif sender == btn_ambush then
                if btn_ambush:getTitleText() == Lang.ui_war_ambush1 then
                    if ui.ambushCount >= UIWar.ambushMax then
                        UIManager.showToast(Lang.ui_war_ambush2)
                        return
                    elseif data.state == UIWar.MEMBER_STATE.NO_QUALIFICATION then
                        UIManager.showToast(Lang.ui_war_ambush3)
                        return
                    end

                    UIManager.showLoading()
                    netSendPackage( { header = StaticMsgRule.ambush, msgdata = { int = { playerId = data.id } } }, function(pack)
                        data.playSetAmbushAni = true
                    end )
                else
                    UIManager.showLoading()
                    netSendPackage( { header = StaticMsgRule.unambush, msgdata = { int = { playerId = data.id } } })
                end
            end
        end
    end
    btn_look:addTouchEventListener(onButtonEvent)
    if UIWar.canModify() and UIWar.state == UIWar.STATE_EMBATTLE and data.survive then
        btn_ambush:show()
        btn_ambush:addTouchEventListener(onButtonEvent)
        btn_ambush:setTitleText(data.state == UIWar.MEMBER_STATE.AMBUSH and Lang.ui_war_ambush4 or Lang.ui_war_ambush5)
    else
        btn_ambush:hide()
    end

    image_ambush:setVisible(data.state == UIWar.MEMBER_STATE.AMBUSH or data.enterFight >= 0)
    if data.playSetAmbushAni then
        data.playSetAmbushAni = nil
        image_ambush:show():setOpacity(0)
        image_ambush:setScale(5)
        image_ambush:runAction(cc.Spawn:create(
        cc.FadeIn:create(0.1),
        cc.ScaleTo:create(0.1, 1.0)
        ))
    end

    if not data.survive then
        text_state:setString(Lang.ui_war_ambush6)
    elseif data.state > 0 then
        text_state:setString(Lang.ui_war_ambush7 .. UIWar.BATTLE_FIELD_NAMES[data.state])
    elseif data.state == UIWar.MEMBER_STATE.NONE then
        text_state:setString(Lang.ui_war_ambush8)
    elseif data.state == UIWar.MEMBER_STATE.AMBUSH then
        text_state:setString(Lang.ui_war_ambush9)
    else
        text_state:setString(Lang.ui_war_ambush10)
    end

    text_state:setTextColor((data.state > 0 and data.survive) and cc.c3b(0x3b, 0x2a, 0xf2) or display.COLOR_RED)

    text_fight:setString(Lang.ui_war_ambush11 .. data.fightValue)
    text_lv:setString(Lang.ui_war_ambush12 .. data.level)
    text_name:setString(data.name)
    image_vip:setVisible(data.isVIP)
    image_title:loadTexture("image/" .. DictUI[tostring(DictCard[tostring(data.iconId)].smallUiId)].fileName)

    utils.GrayWidget(image_frame_title, not data.survive)
    utils.GrayWidget(image_title, not data.survive)
    utils.GrayWidget(image_vip, not data.survive)
    text_name:setTextColor(data.survive and ui.NAME_COLOR or ui.NAME_COLOR_GRAY)
    text_fight:setTextColor(data.survive and ui.LEVEL_COLOR or ui.LEVEL_COLOR_GRAY)
    text_lv:setTextColor(data.survive and ui.LEVEL_COLOR or ui.LEVEL_COLOR_GRAY)
    utils.GrayWidget(image_job, not data.survive)
    utils.GrayWidget(image_vip, not data.survive)
    utils.GrayWidget(image_ambush, not data.survive)
    utils.GrayWidget(image_di_info, not data.survive)
    utils.GrayWidget(item, not data.survive)
end

function ui.init()
    local btn_close = ccui.Helper:seekNodeByName(ui.Widget, "btn_close")
    local image_di = ccui.Helper:seekNodeByName(ui.Widget, "image_di")
    local btn_sure = ccui.Helper:seekNodeByName(ui.Widget, "btn_sure")
    local btn_out = ccui.Helper:seekNodeByName(ui.Widget, "btn_out")
    memberItem = ccui.Helper:seekNodeByName(ui.Widget, "image_di_menber")
    memberItem:retain()

    local sprite = ccui.ImageView:create("ui/lm_zb_fubing.png")
    sprite:setName("image_ambush")
    sprite:setPosition(228, 34.67)
    memberItem:addChild(sprite)

    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            if sender == btn_close or sender == btn_out then
                UIManager.popScene()
            elseif sender == image_di then
                UIAllianceHelp.show( { titleName = Lang.ui_war_ambush13, type = 14 })
                local text_war2 = ccui.Helper:seekNodeByName(UIAllianceHelp.Widget, "text_war2")
                text_war2:setString(string.format(text_war2:getString(), UIWar.getAmbushRewardStr()))
            elseif sender == btn_sure then
            end
        end
    end

    btn_close:addTouchEventListener(onButtonEvent)
    image_di:addTouchEventListener(onButtonEvent)
    btn_sure:addTouchEventListener(onButtonEvent)
    btn_out:addTouchEventListener(onButtonEvent)
end

function ui.setup()
    local btn_sure = ccui.Helper:seekNodeByName(ui.Widget, "btn_sure")
    local btn_out = ccui.Helper:seekNodeByName(ui.Widget, "btn_out")
    local view_card = ccui.Helper:seekNodeByName(ui.Widget, "view_card")
    local image_hint = ccui.Helper:seekNodeByName(ui.Widget, "image_hint")

    if false and UIWar.canModify() then
        btn_sure:show()
        btn_sure:setPositionX(153.15)
        btn_out:setPositionX(464.45)
        btn_sure:setBright(false)
        btn_sure:setEnabled(false)
    else
        btn_sure:hide()
        btn_out:setPositionX((153.15 + 464.45) / 2)
    end

    local list = { }
    local ambushCount = 0
    for id, member in pairs(UIWar.myUnionMemberBattle) do
        if member.state == UIWar.MEMBER_STATE.AMBUSH then
            ambushCount = ambushCount + 1
        end

        if UIWar.canModify() and UIWar.state == UIWar.STATE_EMBATTLE then
            table.insert(list, member)
        elseif member.state == UIWar.MEMBER_STATE.AMBUSH or member.enterFight >= 0 then
            table.insert(list, member)
        end
    end
    ui.ambushCount = ambushCount
    image_hint:getChildByName("text_number"):setString(string.format(Lang.ui_war_ambush14, ambushCount, UIWar.ambushMax))

    local function getOrder(member)
        if member.gradeId == 1 then return 1 end
        if member.gradeId == 2 then return 2 end

        if UIWar.state == UIWar.STATE_EMBATTLE then
            if member.state == UIWar.MEMBER_STATE.NO_QUALIFICATION then
                return 9, - member.level
            else
                return 3, - member.fightValue, - member.level
            end
        end

        if member.state == UIWar.MEMBER_STATE.AMBUSH then
            return 3, - member.level
        elseif member.state == UIWar.MEMBER_STATE.BF1 or member.state == UIWar.MEMBER_STATE.BF2
            or member.state == UIWar.MEMBER_STATE.BF3 or member.state == UIWar.MEMBER_STATE.BF4 then
            if member.survive then
                return 3 + member.state, member.order
            else
                return 10, - member.level
            end
        elseif member.state == UIWar.MEMBER_STATE.NONE then
            return 8, - member.level
        else
            return 9, - member.level
        end
    end

    utils.quickSort(list, function(key, other)
        local a, a1, a2 = getOrder(key)
        local b, b1, b2 = getOrder(other)

        if a == b and a1 and b1 then
            if a1 == b1 and a2 and b2 then
                return a2 > b2
            end
            return a1 > b1
        else
            return a > b
        end
    end )

    ui.list = list

    view_card:removeAllChildren()
    utils.updateScrollView(ui, view_card, memberItem, list, setScrollViewItem)
end

function ui.free()
    if memberItem and memberItem:getReferenceCount() >= 1 then
        memberItem:release()
        memberItem = nil
    end
end
