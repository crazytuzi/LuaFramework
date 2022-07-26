require"Lang"
UIWarInfo = { }

local ui = UIWarInfo
local panel_war
local text_state

ui.TIME = 0.8

local function setCascadeOpacityEnabled(node, enabled)
    node:setCascadeOpacityEnabled(enabled)
    for i, child in ipairs(node:getChildren()) do
        setCascadeOpacityEnabled(child, enabled)
    end
end

local function netCallbackFunc(pack)
    local code = tonumber(pack.header)
    if code == StaticMsgRule.join or code == StaticMsgRule.disjoin then
        UIManager.showToast(Lang.ui_war_info1 ..(code == StaticMsgRule.join and Lang.ui_war_info2 or Lang.ui_war_info3) .. UIWar.BATTLE_FIELD_NAMES[ui.fieldId])
    elseif code == StaticMsgRule.sort then
        UIManager.showToast(Lang.ui_war_info4 .. UIWar.BATTLE_FIELD_NAMES[ui.fieldId] .. Lang.ui_war_info5)
    end
end

local function setBattleImageColor(image_color, peer, unknown)
    if peer then
        image_color:show()
        local text_lv = image_color:getChildByName("text_lv")
        local text_name = image_color:getChildByName("text_name")
        local image_frame_card = image_color:getChildByName("image_frame_card")
        local image_card = image_frame_card:getChildByName("image_card")
        local image_move = image_color:getChildByName("image_move")
        local btn_move = image_color:getChildByName("btn_move")

        text_lv:setLocalZOrder(3)
        text_name:setLocalZOrder(3)
        image_frame_card:setLocalZOrder(3)

        if image_move then image_move:hide() end
        if btn_move then btn_move:hide() end

        if unknown then
            image_frame_card:hide()
            text_lv:setString("LV.??")
            text_name:setString("????")
            text_lv:setVisible(not UIWar.canModify())
            text_name:setVisible(not UIWar.canModify())
        else
            text_lv:show():setString("LV." .. peer.level)
            text_name:show():setString(peer.name)
            local imagePath
            if peer.id == net.InstPlayer.int["1"] then
                imagePath = "ui/lm_zb_me.png"
            elseif peer.unionId == net.InstUnionMember.int["2"] then
                imagePath = "ui/lm_zb_blue.png"
            else
                imagePath = "ui/lm_zb_red.png"
            end
            image_color:loadTexture(imagePath)
            image_color:getVirtualRenderer():show()

            local text_damp = image_color:getChildByName("text_damp")
            local graySpriteFactor = image_color:getChildByName("graySpriteFactor")
            local spriteFactor = image_color:getChildByName("spriteFactor")
            if peer.survive and peer.latestFight > 0 then
                image_color:getVirtualRenderer():hide()
                local size = image_color:getContentSize()
                if not graySpriteFactor then
                    graySpriteFactor = cc.Sprite:create()
                    graySpriteFactor:setName("graySpriteFactor")
                    graySpriteFactor:setTexture(imagePath)
                    graySpriteFactor:setScaleX(size.width / graySpriteFactor:getContentSize().width)
                    graySpriteFactor:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName("ShaderUIGrayScale"))
                    graySpriteFactor:setLocalZOrder(2)
                    image_color:addChild(graySpriteFactor)

                    spriteFactor = cc.Sprite:create()
                    spriteFactor:setName("spriteFactor")
                    spriteFactor:setTexture(imagePath)
                    spriteFactor:setScaleX(size.width / graySpriteFactor:getContentSize().width)
                    spriteFactor:setLocalZOrder(2)
                    image_color:addChild(spriteFactor)
                else
                    graySpriteFactor:show():setTexture(imagePath)
                    spriteFactor:show():setTexture(imagePath)
                end

                local factor = math.min(0.8, peer.fights * 0.2)
                local width = size.width * factor
                text_damp:show()
                text_damp:setLocalZOrder(3)
                text_damp:setString(string.format("-%d%%", math.floor(factor * 100)))
                if image_color:getName() == "image_blue" then
                    graySpriteFactor:setAnchorPoint(display.LEFT_BOTTOM)
                    graySpriteFactor:setPosition(0, 0)
                    graySpriteFactor:setTextureRect(cc.rect(0, 0, width / graySpriteFactor:getScaleX(), size.height))

                    spriteFactor:setAnchorPoint(display.RIGHT_BOTTOM)
                    spriteFactor:setPosition(size.width, 0)
                    spriteFactor:setTextureRect(cc.rect(width / graySpriteFactor:getScaleX(), 0,(size.width - width) / graySpriteFactor:getScaleX(), size.height))
                else
                    graySpriteFactor:setAnchorPoint(display.RIGHT_BOTTOM)
                    graySpriteFactor:setPosition(size.width, 0)
                    graySpriteFactor:setTextureRect(cc.rect((size.width - width) / graySpriteFactor:getScaleX(), 0, width / graySpriteFactor:getScaleX(), size.height))

                    spriteFactor:setAnchorPoint(display.LEFT_BOTTOM)
                    spriteFactor:setPosition(0, 0)
                    spriteFactor:setTextureRect(cc.rect(0, 0,(size.width - width) / graySpriteFactor:getScaleX(), size.height))
                end
            else
                text_damp:hide()
                if graySpriteFactor then
                    graySpriteFactor:hide()
                    spriteFactor:hide()
                end
            end

            image_card:loadTexture("image/" .. DictUI[tostring(DictCard[tostring(peer.iconId)].smallUiId)].fileName)
            image_frame_card:show():setTouchEnabled(true)
            image_frame_card:addTouchEventListener( function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    audio.playSound("sound/button.mp3")
                    UIManager.showLoading()
                    netSendPackage( { header = StaticMsgRule.enemyPlayerInfo, msgdata = { int = { playerId = peer.id } } }, function(pack)
                        if pack.msgdata.message then
                            pvp.loadGameData(pack)
                            UIManager.pushScene("ui_arena_check")
                        end
                    end )
                end
            end )

            utils.GrayWidget(image_color, not peer.survive)
            utils.GrayWidget(image_frame_card, not peer.survive)
            utils.GrayWidget(image_card, not peer.survive)
        end
    else
        image_color:hide()
    end
end

local function setEmbattleScrollViewItem(item, data)
    local tag = item:getTag()
    item:getChildByName("image_number"):getChildByName("text_number"):setString(tostring(tag))

    for i = 1, 2 do
        local color = i == 1 and "blue" or "red"
        local image_color = item:getChildByName("image_" .. color)
        setBattleImageColor(image_color, data, i == 2)
        image_color:getChildByName("text_damp"):hide()
    end

    local image_color = item:getChildByName("image_red")

    local btn_move = image_color:getChildByName("btn_move")
    local image_move = image_color:getChildByName("image_move")
    if UIWar.canModify() then
        btn_move:show():addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                audio.playSound("sound/button.mp3")
                local image_basemap = ui.Widget:getChildByName("image_basemap")
                local image_move_cover = image_basemap:getChildByName("image_move_cover"):show()
                local view_card = image_basemap:getChildByName("view_card")
                local image_move = image_basemap:getChildByName("image_move"):show()
                local btn_war_fubing = image_move:getChildByName("btn_war_fubing")

                btn_move:loadTextureNormal("ui/tk_btn_big_pur.png")

                local x, y = btn_move:getPosition()
                local pos = image_basemap:convertToNodeSpace(image_color:convertToWorldSpace(cc.p(x, y)))
                local size = image_move:getContentSize()
                local viewCardSize = view_card:getContentSize()

                pos.x = pos.x - size.width / 2 - btn_move:getContentSize().width / 2 * 0.7

                if pos.y + size.height / 2 > view_card:getPositionY() + viewCardSize.height then
                    pos.y = view_card:getPositionY() + viewCardSize.height - size.height / 2
                end
                if pos.y - size.height / 2 < view_card:getPositionY() then
                    pos.y = view_card:getPositionY() + size.height / 2
                end

                image_move:setPosition(pos)
                image_move_cover:setSwallowTouches(false)
                local function onButtonEvent(sender, eventType)
                    if sender == image_move_cover then
                        image_move_cover:hide()
                        image_move:hide()
                        btn_move:loadTextureNormal("ui/tk_btn_big_red.png")
                        return
                    end
                    if eventType == ccui.TouchEventType.ended then
                        audio.playSound("sound/button.mp3")
                        if sender == btn_war_fubing then
                            local ambushCount = 0
                            for id, member in pairs(UIWar.myUnionMemberBattle) do
                                if member.state == UIWar.MEMBER_STATE.AMBUSH then
                                    ambushCount = ambushCount + 1
                                end
                            end
                            if ambushCount >= UIWar.ambushMax then
                                UIManager.showToast(Lang.ui_war_info6)
                                return
                            end

                            UIManager.showLoading()
                            netSendPackage( { header = StaticMsgRule.ambush, msgdata = { int = { playerId = data.id } } }, function(pack)
                                UIManager.showToast(data.name .. Lang.ui_war_info7)
                                image_move_cover:releaseUpEvent()
                            end )
                        else
                            UIManager.showLoading()
                            netSendPackage( { header = StaticMsgRule.join, msgdata = { int = { playerId = data.id, battlefieldId = sender:getTag() } } }, function(pack)
                                UIManager.showToast(string.format(Lang.ui_war_info8, data.name, UIWar.BATTLE_FIELD_NAMES[sender:getTag()]))
                                image_move_cover:releaseUpEvent()
                            end )
                        end
                    end
                end

                local btnIdx = 1
                for i, name in ipairs(UIWar.BATTLE_FIELD_NAMES) do
                    if i ~= ui.fieldId then
                        local btn_war = image_move:getChildByName("btn_war" .. btnIdx)
                        btn_war:setTitleText(name)
                        btn_war:setTag(i)
                        btn_war:addTouchEventListener(onButtonEvent)
                        btnIdx = btnIdx + 1
                    end
                end
                image_move_cover:addTouchEventListener(onButtonEvent)
                btn_war_fubing:addTouchEventListener(onButtonEvent)
            end
        end )

        image_move:show():setTouchEnabled(true)
        image_move:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then return end
            if not ui.canDragItem then
                local view_card = ccui.Helper:seekNodeByName(ui.Widget, "view_card")
                local dragItem = view_card:getChildByName("dragItem")
                if not dragItem then
                    ui.touchStartY = item:getPositionY() + view_card:getInnerContainer():getPositionY()

                    local dragItem = cc.Node:create()
                    local x, y = item:getPosition()
                    dragItem:setPosition(x, y)
                    local size = item:getContentSize()
                    dragItem:setContentSize(size)
                    dragItem:setTag(item:getTag())
                    dragItem:setLocalZOrder(100)
                    dragItem:setName("dragItem")

                    local function setOpacity(item, alpha)
                        item:setOpacity(alpha)
                        local chs = item:getChildren()
                        for k, ch in ipairs(chs) do
                            setOpacity(ch, alpha)
                        end
                    end

                    local dragChild = item:clone()
                    dragChild:setPosition(0, 0)
                    dragItem:addChild(dragChild)

                    setOpacity(dragChild, 150)
                    dragChild:setScale(1.05)

                    local drawNode = cc.DrawNode:create()
                    drawNode:setName("line")
                    local size = dragChild:getContentSize()
                    drawNode:setLocalZOrder(-1)

                    drawNode:setPosition(- size.width / 2, - size.height / 2)
                    drawNode:drawLine(cc.p(-2, 3), cc.p(size.width + 4, 3), cc.c4f(1, 1, 1, 1))
                    drawNode:drawLine(cc.p(-2, -3), cc.p(size.width + 4, -3), cc.c4f(1, 1, 1, 1))
                    drawNode:hide()
                    dragItem:addChild(drawNode)

                    view_card:addChild(dragItem)
                end

                ui.canDragItem = true
            end
        end )
    else
        image_move:hide()
        btn_move:hide()
    end
end

local function setBattleScrollViewItem(item, data, resetPosition)
    local tag = item:getTag()
    local battleField = UIWar.myUnionBattle.battleFields[ui.fieldId]
    local image_number = item:getChildByName("image_number")

    setCascadeOpacityEnabled(image_number, true)
    image_number:setOpacity(255)

    for i = 1, 2 do
        local color = i == 1 and "blue" or "red"
        local image_color = item:getChildByName("image_" .. color)
        setBattleImageColor(image_color, data[i])
        image_color:getChildByName("text_name"):show()
        image_color:getChildByName("text_lv"):show()
        if resetPosition then
            image_color:setPosition(i == 1 and 153.5 or 460.5, 37.5)
        end
    end

    if battleField.state == UIWar.BF_STATE.WIN or battleField.state == UIWar.BF_STATE.FAIL or battleField.state == UIWar.BF_STATE.DRAW then
        image_number:hide()
    else
        local left = data[1] and data[1].survive
        local right = data[2] and data[2].survive
        if left and right then
            if battleField.state == UIWar.BF_STATE.FIGHTING and tag == ui.start + 1 then
                image_number:hide()
            else
                image_number:show()
            end
            local text_number = image_number:getChildByName("text_number")
            if battleField.fromFight then
                text_number:setString(tostring(tag - battleField.fromFight + 1))
            else
                text_number:setString(tostring(tag - ui.start))
            end
        else
            image_number:hide()
        end
    end
end

function ui.init()
    local btn_close = ccui.Helper:seekNodeByName(ui.Widget, "btn_close")
    local btn_in = ccui.Helper:seekNodeByName(ui.Widget, "btn_in")
    local btn_out = ccui.Helper:seekNodeByName(ui.Widget, "btn_out")
    local image_di = ccui.Helper:seekNodeByName(ui.Widget, "image_di")

    text_state = ccui.Helper:seekNodeByName(ui.Widget, "text_state")
    panel_war = ccui.Helper:seekNodeByName(ui.Widget, "panel_war")
    panel_war:setClippingEnabled(false)
    text_state:retain()
    panel_war:retain()

    local view_card = ccui.Helper:seekNodeByName(ui.Widget, "view_card")
    if UIWar.canModify() then
        local panel = ccui.Layout:create()
        panel:setName("cover")
        panel:setContentSize(view_card:getContentSize())
        panel:setTouchEnabled(true)
        local x, y = view_card:getPosition()
        panel:setPosition(x, y)
        view_card:getParent():addChild(panel)

        panel:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.moved then
                if ui.canDragItem then
                    local dragItem = view_card:getChildByName("dragItem")
                    if dragItem then
                        local movePosition = panel:getTouchMovePosition()
                        local container = view_card:getInnerContainer()
                        local containerSize = container:getContentSize()
                        local scrollViewSize = panel:getContentSize()
                        local h = containerSize.height - scrollViewSize.height
                        local size = dragItem:getContentSize()
                        local line = dragItem:getChildByName("line"):hide()
                        local tag = dragItem:getTag()

                        local localMovePosition = panel:convertToNodeSpace(movePosition)

                        if localMovePosition.y > scrollViewSize.height then
                            local percent = math.min(1, math.max(0,(container:getPositionY() - size.height + h) / h))
                            view_card:jumpToPercentVertical(percent * 100)
                            ui.list.scrollingevent()
                        elseif localMovePosition.y < 0 then
                            local percent = math.min(1, math.max(0,(container:getPositionY() + size.height + h) / h))
                            view_card:jumpToPercentVertical(percent * 100)
                            ui.list.scrollingevent()
                        end

                        local y = ui.touchStartY + movePosition.y - panel:getTouchBeganPosition().y - container:getPositionY()
                        dragItem:setPositionY(y)

                        local children = view_card:getChildren()
                        ui.insertPos = nil
                        for i, child in ipairs(children) do
                            local k = child:getTag()
                            if child:getName() == "panel_war" and k ~= tag then
                                if localMovePosition.y > ui.touchStartY and k - 1 ~= tag then
                                    local top = child:getPositionY() + size.height / 2 + 3
                                    if (k == 1 and y - size.height / 2 >= top) or y + size.height / 2 >= top and top > y - size.height / 2 then
                                        line:show():setPositionY(top - y)
                                        ui.insertPos = k
                                    end
                                elseif localMovePosition.y <= ui.touchStartY and k + 1 ~= tag then
                                    local bottom = child:getPositionY() - size.height / 2 - 3
                                    if (k == #ui.list and y + size.height / 2 <= bottom) or y + size.height / 2 > bottom and bottom >= y - size.height / 2 then
                                        line:show():setPositionY(bottom - y)
                                        ui.insertPos = k + 1
                                    end
                                end
                            end
                        end
                        panel:setSwallowTouches(true)
                        return
                    end
                end
                ui.canDragItem = nil
            else
                ui.canDragItem = nil
                ui.touchStartY = nil
                panel:setSwallowTouches(false)
                if ui.insertPos then
                    local tag = view_card:getChildByName("dragItem"):getTag()
                    table.insert(ui.list, ui.insertPos, ui.list[tag])
                    table.remove(ui.list, ui.insertPos <= tag and tag + 1 or tag)
                    view_card:removeAllChildren()
                    ui.isFlush = true
                    ui.list.scrollingevent = utils.updateScrollView(ui, view_card, panel_war, ui.list, setEmbattleScrollViewItem, { space = 6, setTag = true })

                    local idList = { }
                    for i, member in ipairs(ui.list) do
                        idList[i] = tostring(member.id)
                    end
                    idList = table.concat(idList, "_", 1, #idList)
                    netSendPackage( { header = StaticMsgRule.sort, msgdata = { int = { battlefieldId = ui.fieldId }, string = { idList = idList } } })
                    ui.insertPos = nil
                end
                view_card:removeChildByName("dragItem")
            end
        end )
    end

    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            if sender == btn_close or sender == btn_out then
                ui.fieldId = nil
                UIManager.popScene()
            elseif sender == image_di then
                UIAllianceHelp.show( { titleName = Lang.ui_war_info9, type = 15 })
            elseif sender == btn_in then
                local text = btn_in:getTitleText()
                if Lang.ui_war_info10 == text then
                    if UIWar.my.state == UIWar.MEMBER_STATE.NO_QUALIFICATION then
                        UIManager.showToast(Lang.ui_war_info11)
                        return
                    elseif UIWar.my.state == UIWar.MEMBER_STATE.AMBUSH then
                        if UIWar.state ~= UIWar.STATE_BATTLE then
                            UIManager.showToast(Lang.ui_war_info12)
                            return
                        elseif UIWar.myUnionBattle.battleFields[ui.fieldId].state == UIWar.BF_STATE.PREPARE then
                            UIManager.showToast(Lang.ui_war_info13)
                            return
                        end
                    end
                    local fId = nil
                    if UIWar.my.state > 0 then fId = UIWar.my.state end

                    local function callfunc()
                        UIManager.showLoading()
                        netSendPackage( { header = UIWar.state == UIWar.STATE_EMBATTLE and StaticMsgRule.join or StaticMsgRule.fight, msgdata = { int = { playerId = net.InstPlayer.int["1"], battlefieldId = ui.fieldId } } }, netCallbackFunc)
                    end

                    if fId then
                        utils.showDialog(string.format(Lang.ui_war_info14, UIWar.BATTLE_FIELD_NAMES[fId], UIWar.BATTLE_FIELD_NAMES[ui.fieldId]), callfunc)
                    else
                        callfunc()
                    end
                elseif Lang.ui_war_info15 == text then
                    utils.showDialog(Lang.ui_war_info16 .. UIWar.BATTLE_FIELD_NAMES[ui.fieldId] .. "？", function()
                        UIManager.showLoading()
                        netSendPackage( { header = StaticMsgRule.disjoin, msgdata = { int = { battlefieldId = ui.fieldId } } }, netCallbackFunc)
                    end )
                end
            end
        end
    end

    btn_close:addTouchEventListener(onButtonEvent)
    btn_in:addTouchEventListener(onButtonEvent)
    btn_out:addTouchEventListener(onButtonEvent)
    image_di:addTouchEventListener(onButtonEvent)
end

function ui.setup()
    local text_integral = ccui.Helper:seekNodeByName(ui.Widget, "text_integral")
    local text_reward = ccui.Helper:seekNodeByName(ui.Widget, "text_reward")
    local text_title = ccui.Helper:seekNodeByName(ui.Widget, "text_title")

    text_title:setString(UIWar.BATTLE_FIELD_NAMES[ui.fieldId])
    text_integral:setString(Lang.ui_war_info17 .. UIWar.battlefieldIntros[ui.fieldId].point)
    local reward = UIWar.battlefieldIntros[ui.fieldId].reward
    if string.len(reward) > 0 then
        local itemProp = utils.getItemProp(reward)
        text_reward:setString(string.format(Lang.ui_war_info18, itemProp.name, itemProp.count))
    else
        text_reward:setString(Lang.ui_war_info19)
    end

    for i = 1, 2 do
        local color = i == 1 and "blue" or "red"
        local unionBattle = i == 1 and UIWar.myUnionBattle or UIWar.enemyUnionBattle
        local text_name = ccui.Helper:seekNodeByName(ui.Widget, "text_name_" .. color)
        local text_number = ccui.Helper:seekNodeByName(ui.Widget, "text_number_" .. color)
        local battleField = unionBattle.battleFields[ui.fieldId]

        text_name:setString(unionBattle.name)
        if i == 2 and(UIWar.state == UIWar.STATE_EMBATTLE or battleField.state == UIWar.BF_STATE.PREPARE) then
            text_number:setString(Lang.ui_war_info20)
        else
            text_number:setString(Lang.ui_war_info21 .. #battleField.survive)
            if ui.playAmbushAni and ui.playAmbushAni[i] then
                ui.isPlayingCount = ui.isPlayingCount or { 0, 0 }
                ui.isPlayingCount[i] = ui.isPlayingCount[i] + 1

                text_number:setString(Lang.ui_war_info22 ..(#battleField.survive - ui.isPlayingCount[i]))

                text_number:scheduleUpdate( function(dt)
                    local sprite = text_number:getChildByName("add")
                    if sprite then return end
                    if ui.isPlayingCount and ui.isPlayingCount[i] > 0 then
                        local sprite = cc.Sprite:create("image/+1.png")
                        sprite:setName("add")
                        sprite:setPosition(150, 0)
                        sprite:setAnchorPoint(display.LEFT_BOTTOM)
                        sprite:setScale(29 / sprite:getContentSize().height)
                        text_number:addChild(sprite)

                        local t = ui.TIME / ui.isPlayingCount[i]
                        local moveAction = cc.EaseCubicActionInOut:create(cc.MoveBy:create(t, cc.p(0, 40)))
                        moveAction = cc.Sequence:create(moveAction, cc.RemoveSelf:create())
                        sprite:runAction(cc.Spawn:create(cc.FadeOut:create(t), moveAction))
                        text_number:setString(Lang.ui_war_info23 ..(#battleField.survive - ui.isPlayingCount[i]))
                        ui.isPlayingCount[i] = ui.isPlayingCount[i] -1
                    else
                        text_name:unscheduleUpdate()
                    end
                end )
            end
        end
    end

    local view_card = ccui.Helper:seekNodeByName(ui.Widget, "view_card")
    local battleField = UIWar.myUnionBattle.battleFields[ui.fieldId]

    local btn_in = ccui.Helper:seekNodeByName(ui.Widget, "btn_in")
    local btn_out = ccui.Helper:seekNodeByName(ui.Widget, "btn_out")

    if UIWar.state == UIWar.STATE_BATTLE then
        if UIWar.my.state == UIWar.MEMBER_STATE.AMBUSH and battleField.state ~= UIWar.BF_STATE.WIN and battleField.state ~= UIWar.BF_STATE.FAIL and battleField.state ~= UIWar.BF_STATE.DRAW then
            btn_in:show():setTitleText(Lang.ui_war_info24)
            btn_in:setPositionX(181.26)
            btn_out:setPositionX(452.56)
        else
            btn_in:hide()
            btn_out:setPositionX((181.26 + 452.56) / 2)
        end
    elseif UIWar.state == UIWar.STATE_EMBATTLE then
        btn_in:show():setTitleText(UIWar.my.state == ui.fieldId and Lang.ui_war_info25 or Lang.ui_war_info26)
        btn_in:setPositionX(181.26)
        btn_out:setPositionX(452.56)
    else
        btn_in:hide()
        btn_out:setPositionX((181.26 + 452.56) / 2)
    end

    view_card:getParent():getChildByName("image_move_cover"):hide()
    view_card:getParent():getChildByName("image_move"):hide()

    local panel_title = ccui.Helper:seekNodeByName(ui.Widget, "panel_title")
    if UIWar.canModify() then
        panel_title:show()
        if view_card:getContentSize().height ~= 658 then
            view_card:setContentSize(cc.size(614, 658))
        end
    else
        panel_title:hide()
        if view_card:getContentSize().height ~= 658 + 28 then
            view_card:setContentSize(cc.size(614, 658 + 28))
        end
    end

    if UIWar.state == UIWar.STATE_EMBATTLE then
        local start = 0
        for i = 1, ui.fieldId - 1 do
            start = start + #UIWar.myUnionBattle.battleFields[i].survive
        end
        ui.start = start
        ui.list = { }
        table.merge(ui.list, battleField.survive)
        view_card:removeAllChildren()
        ui.list.scrollingevent = utils.updateScrollView(UIWarInfo, view_card, panel_war, ui.list, setEmbattleScrollViewItem, { space = 6, setTag = true })
    elseif UIWar.state == UIWar.STATE_BATTLE or UIWar.state == UIWar.STATE_FINISH then
        if battleField.state == UIWar.BF_STATE.FIGHTING then
            ui.start = UIWar.maxFightId
        elseif battleField.state == UIWar.BF_STATE.PREPARE then
            local start = UIWar.maxFightId
            for i = 1, ui.fieldId - 1 do
                local battleField = UIWar.myUnionBattle.battleFields[i]
                if battleField.state == UIWar.BF_STATE.PREPARE then
                    start = start + #battleField.survive
                elseif battleField.state == UIWar.BF_STATE.FIGHTING then
                    start = start + math.min(#battleField.survive, #UIWar.enemyUnionBattle.battleFields[i].survive)
                end
            end
            ui.start = start
        else
            local start = 0
            for i, dead in ipairs(battleField.dead) do
                start = math.max(start, dead.latestFight)
            end
            for i, dead in ipairs(UIWar.enemyUnionBattle.battleFields[ui.fieldId].dead) do
                start = math.max(start, dead.latestFight)
            end
            ui.start = start
        end

        local titleHeight = text_state:getContentSize().height

        if battleField.state == UIWar.BF_STATE.PREPARE then
            local topSpace = #battleField.survive > 0 and titleHeight + 4 or 0
            view_card:removeAllChildren()
            utils.updateScrollView(UIWarInfo, view_card, panel_war, battleField.survive, setEmbattleScrollViewItem, { topSpace = topSpace, space = 4, setTag = true })
            if #battleField.survive > 0 then
                local waitFightTitle = text_state:clone()
                waitFightTitle:setName("waitFightTitle")
                waitFightTitle:setString(Lang.ui_war_info27)
                waitFightTitle:setPosition(view_card:getContentSize().width / 2, view_card:getInnerContainerSize().height - titleHeight / 2)
                view_card:addChild(waitFightTitle)
            end
        else
            local enemyBattleField = UIWar.enemyUnionBattle.battleFields[ui.fieldId]

            local list = { }
            for i = 1, math.max(#battleField.survive, #enemyBattleField.survive) do
                table.insert(list, { battleField.survive[i] or false, enemyBattleField.survive[i] or false })
            end
            for i = 1, math.max(#battleField.dead, #enemyBattleField.dead) do
                table.insert(list, { battleField.dead[i] or false, enemyBattleField.dead[i] or false })
                if i == 1 then
                    list.deadStart = #list
                end
            end

            local topSpace = #list > 0 and titleHeight + 4 or 0
            local bottomSpace =(#list > 0 and battleField.state ~= UIWar.BF_STATE.PREPARE) and 2 * titleHeight + 8 or 0
            local function getPositionOffsetY(i)
                if battleField.state == UIWar.BF_STATE.PREPARE then
                    return 0
                else
                    local data = list[i]
                    if not data then return -2 * titleHeight - 8 end

                    local left = data[1] and data[1].survive
                    local right = data[2] and data[2].survive
                    if left or right then
                        if battleField.state == UIWar.BF_STATE.FIGHTING and i == 1 and left and right then
                            return 0
                        else
                            return - titleHeight - 4
                        end
                    else
                        return -2 * titleHeight - 8
                    end
                end
            end

            local space = 4
            local listItemSize = panel_war:getContentSize()
            local scrollViewSize = view_card:getContentSize()
            local innerHeight = topSpace +(listItemSize.height + space) * #list - space + bottomSpace
            innerHeight = innerHeight < scrollViewSize.height and scrollViewSize.height or innerHeight
            local container = view_card:getInnerContainer()
            local containerY = container:getPositionY()
            view_card:setInnerContainerSize(cc.size(scrollViewSize.width, innerHeight))

            local function getPositionY(i)
                return innerHeight - topSpace -(i - 1) *(listItemSize.height + space) - listItemSize.height / 2 + getPositionOffsetY(i)
            end

            list.getPositionY = getPositionY
            list.innerHeight = innerHeight

            if ui.oldList then
                container:setPositionY(math.min(innerHeight, ui.oldList.innerHeight + containerY) - innerHeight)

                local ani_fight = view_card:getChildByName("ani_fight")
                if battleField.state == UIWar.BF_STATE.FIGHTING then
                    local y = list.getPositionY(1)
                    ani_fight:setPosition(panel_war:getPositionX() -4, y - 8)
                elseif ani_fight then
                    view_card:removeChildByName("ani_fight")
                end

                local needMoveUpSurvive = false
                if ui.playFightAni then
                    needMoveUpSurvive = true
                    local item = view_card:getChildByTag(ui.start)
                    setBattleScrollViewItem(item, ui.playFightAni, true)
                    ui.isPlayingKillAni = true
                    for k, fighter in ipairs(ui.playFightAni) do
                        local key = k == 1 and "leftAdd" or "rightAdd"
                        if fighter then
                            for i, data in ipairs(list) do
                                if data[k] == fighter then
                                    data[key] = true
                                    if fighter.survive and i == 1 then
                                        data[key] = 2
                                        ui.playFightAni[key] = true
                                    end
                                    if not data[3 - k] then
                                        data.isNewLine = true
                                    end
                                    break
                                end
                            end
                        end
                    end

                    for k, fighter in ipairs(ui.playFightAni) do
                        local color = k == 1 and "blue" or "red"
                        local sideAdd = k == 1 and "leftAdd" or "rightAdd"
                        local image_color = item:getChildByName("image_" .. color)
                        local image_frame_card = image_color:getChildByName("image_frame_card")
                        if not ui.playFightAni[sideAdd] then
                            image_color:runAction(cc.MoveTo:create(ui.TIME, cc.p(k == 1 and -153.5 or 767.5, 37.5)))
                        end
                        image_color:pause()
                        if fighter.survive then
                            local lastFactor = math.min(0.8,(fighter.fights - 1) * 0.2)
                            local curFactor = math.min(0.8, fighter.fights * 0.2)

                            if curFactor > lastFactor then
                                local size = image_color:getContentSize()
                                local graySpriteFactor = image_color:getChildByName("graySpriteFactor")
                                local spriteFactor = image_color:getChildByName("spriteFactor")
                                local scaleX = spriteFactor:getScaleX()

                                local dist =(curFactor - lastFactor) * size.width
                                local node = cc.Node:create()
                                image_color:addChild(node)

                                local t1 = 0.5
                                local t2 = 0.2
                                local t3 = 0.2

                                local width = lastFactor * size.width
                                if k == 1 then
                                    graySpriteFactor:setTextureRect(cc.rect(0, 0, width / scaleX, size.height))
                                    spriteFactor:setTextureRect(cc.rect(width / scaleX, 0,(size.width - width) / scaleX, size.height))

                                    node:setPositionX(0)
                                    node:runAction(cc.Sequence:create(cc.EaseSineOut:create(cc.MoveBy:create(t1, cc.p(dist, 0)))))
                                    node:scheduleUpdate( function(dt)
                                        local d = node:getPositionX()
                                        if d > 0 then
                                            graySpriteFactor:setTextureRect(cc.rect(0, 0,(width + d) / scaleX, size.height))
                                            spriteFactor:setTextureRect(cc.rect((width + d) / scaleX, 0,(size.width - width - d) / scaleX, size.height))
                                        end
                                        if d >= dist then
                                            node:unscheduleUpdate()
                                        end
                                    end )
                                else
                                    graySpriteFactor:setTextureRect(cc.rect((size.width - width) / scaleX, 0, width / scaleX, size.height))
                                    spriteFactor:setTextureRect(cc.rect(0, 0,(size.width - width) / scaleX, size.height))

                                    node:setPositionX(0)
                                    node:runAction(cc.Sequence:create(cc.EaseSineOut:create(cc.MoveBy:create(t1, cc.p(dist, 0)))))
                                    node:scheduleUpdate( function(dt)
                                        local d = node:getPositionX()
                                        if d > 0 then
                                            graySpriteFactor:setTextureRect(cc.rect((size.width - width - d) / scaleX, 0,(width + d) / scaleX, size.height))
                                            spriteFactor:setTextureRect(cc.rect(0, 0,(size.width - width - d) / scaleX, size.height))
                                        end
                                        if d >= dist then
                                            node:unscheduleUpdate()
                                        end
                                    end )
                                end
                            end

                        else
                            local x, y = image_frame_card:getPosition()
                            local ani_kill = ActionManager.getEffectAnimation(23, function()
                                ui.isPlayingKillAni = false
                                item:removeChildByName("ani_kill")
                                local children = view_card:getChildren()
                                for i, child in ipairs(children) do
                                    if child:getName() == "panel_war" then
                                        if child:getNumberOfRunningActions() > 0 then
                                            child:resume()
                                        end
                                        for k = 1, 2 do
                                            local color = k == 1 and "blue" or "red"
                                            local image_color = child:getChildByName("image_" .. color)
                                            if image_color:getNumberOfRunningActions() > 0 then
                                                image_color:resume()
                                            end
                                        end
                                        local image_number = child:getChildByName("image_number")
                                        if image_number:getNumberOfRunningActions() > 0 then
                                            image_number:resume()
                                        end
                                    end
                                end
                            end , 0)
                            ani_kill:setName("ani_kill")
                            ani_kill:getBone("Layer73"):addDisplay(ccs.Skin:create("image/" .. DictUI[tostring(DictCard[tostring(fighter.iconId)].bigUiId)].fileName), 0)
                            ani_kill:setScale(0.3)
                            ani_kill:setPosition(item:convertToNodeSpace(image_color:convertToWorldSpace(cc.p(x, y))))
                            item:addChild(ani_kill)
                        end
                    end
                    item:runAction(cc.Sequence:create(cc.DelayTime:create(ui.TIME), cc.RemoveSelf:create()))
                    item:pause()

                    item:setPositionY(list.getPositionY(1))
                end

                if ui.playAmbushAni then
                    for k, ambush in ipairs(ui.playAmbushAni) do
                        local key = k == 1 and "leftAdd" or "rightAdd"
                        if ambush then
                            for i, data in ipairs(list) do
                                if data[k] == ambush then
                                    data[key] = true
                                    if not data[3 - k] then
                                        data.isNewLine = true
                                    end
                                    break
                                end
                            end
                        end
                    end
                end

                local currentTitle = view_card:getChildByName("currentTitle")
                currentTitle:setPositionY(innerHeight - titleHeight / 2)

                local waitFightTitle = view_card:getChildByName("waitFightTitle")
                waitFightTitle:setPositionY(innerHeight - titleHeight - 4 +(getPositionOffsetY(1) == 0 and - panel_war:getContentSize().height or 0) - titleHeight / 2)

                currentTitle:scheduleUpdate( function(dt)
                    local children = view_card:getChildren()
                    local upSpd = 2.5

                    local count = 0
                    if ui.isPlayingCount then
                        count = math.max(ui.isPlayingCount[1], ui.isPlayingCount[2])
                    end

                    local downSpd = 2.5 + count * 2.5
                    local spd = 2.5
                    local canUnschedule = not ui.isPlayingKillAni
                    for i, child in ipairs(children) do
                        if child:getName() == "panel_war" then
                            local idx = child:getTag()
                            if idx >= 20000 then
                                idx = idx - 20000 + list.deadStart
                            else
                                idx = idx - ui.start
                            end
                            if idx == 0 then
                                child:setPositionY(list.getPositionY(1))
                            elseif idx >= 1 and idx <= #list then
                                local y = child:getPositionY()
                                local dstY = list.getPositionY(idx)
                                local d = math.abs(y - dstY)

                                if y > dstY then
                                    spd = downSpd
                                else
                                    spd = upSpd
                                end

                                if d > spd then
                                    canUnschedule = false
                                    if dstY > y then
                                        y = y + spd
                                    else
                                        y = y - spd
                                    end
                                else
                                    y = dstY
                                end
                                if y > dstY or not ui.isPlayingKillAni then
                                    child:setPositionY(y)
                                end
                            end
                        end
                    end

                    local deadTitle = view_card:getChildByName("deadTitle")
                    local deadIdx = list.deadStart or(#list + 1)
                    local dstY = innerHeight - topSpace + 4 -(deadIdx - 1) *(listItemSize.height + 4) + getPositionOffsetY(deadIdx)
                    local y = deadTitle:getPositionY()
                    if y > dstY then
                        spd = downSpd
                    else
                        spd = upSpd
                    end
                    if math.abs(y - dstY) > spd then
                        canUnschedule = false
                        if dstY > y then
                            y = y + spd
                        else
                            y = y - spd
                        end
                    else
                        y = dstY
                    end
                    if y > dstY or not ui.isPlayingKillAni then
                        deadTitle:setPositionY(y)
                    end

                    if canUnschedule then
                        currentTitle:unscheduleUpdate()
                        if battleField.state ~= UIWar.BF_STATE.FIGHTING then
                            ui.oldList = nil
                        end
                    end
                end )

                local deadTitle = view_card:getChildByName("deadTitle")

                deadTitle:setPositionY(innerHeight - ui.oldList.innerHeight + deadTitle:getPositionY())

                local lastY = list.getPositionY(1)
                for i, data in ipairs(list) do
                    local isDead = list.deadStart and i >= list.deadStart
                    local tag = isDead and(i - list.deadStart + 20000) or(ui.start + i)

                    local fadeInFightId = false
                    local item
                    data.isNewLine = data.isNewLine or(data.leftAdd and data.rightAdd)
                    if data.isNewLine then
                        item = panel_war:clone()
                        item:setTag(tag)
                        item:setPositionY(lastY - listItemSize.height)
                        view_card:addChild(item)
                        fadeInFightId = not isDead and data.leftAdd and data.rightAdd
                    else
                        item = view_card:getChildByTag(tag)
                        fadeInFightId = not isDead and(data.leftAdd or data.rightAdd)
                    end

                    if not item then
                        cclog("unexpected item isDead %s start %d, i %d, tag %d left %[s] right [%s], leftAdd %s rightAdd %s", isDead and "true" or "false", ui.start, i, tag, data[1] and data[1].name or "", data[2] and data[2].name or "", data.leftAdd and "true" or "false", data.rightAdd and "true" or "false")
                    end

                    item:setLocalZOrder(#list - i)

                    if data.isNewLine or data.leftAdd or data.rightAdd then
                        setBattleScrollViewItem(item, data, data.isNewLine)
                    end

                    if data.leftAdd then
                        local image_blue = item:getChildByName("image_blue")
                        if data.leftAdd == 2 then
                            image_blue:hide()
                            image_blue:runAction(cc.Sequence:create(cc.DelayTime:create(ui.TIME), cc.Show:create()))
                        else
                            image_blue:show()
                            image_blue:setPositionX(-153.5)
                            image_blue:runAction(cc.MoveTo:create(ui.TIME, cc.p(153.5, 37.5)))
                        end
                        if ui.isPlayingKillAni then
                            image_blue:pause()
                        end
                    end

                    if data.rightAdd then
                        local image_red = item:getChildByName("image_red")
                        if data.rightAdd == 2 then
                            image_red:hide()
                            image_red:runAction(cc.Sequence:create(cc.DelayTime:create(ui.TIME), cc.Show:create()))
                        else
                            image_red:show()
                            image_red:setPositionX(767.5)
                            image_red:runAction(cc.MoveTo:create(ui.TIME, cc.p(460.5, 37.5)))
                        end
                        if ui.isPlayingKillAni then
                            image_red:pause()
                        end
                    end

                    if fadeInFightId then
                        local image_number = item:getChildByName("image_number")
                        if data.leftAdd == 2 or data.rightAdd == 2 then
                            image_number:hide()
                        else
                            image_number:show()
                            image_number:setOpacity(0)
                            image_number:runAction(cc.FadeIn:create(ui.TIME))
                            if ui.isPlayingKillAni then
                                image_number:pause()
                            end
                        end
                    end

                    lastY = item:getPositionY()
                    local y = innerHeight - ui.oldList.innerHeight + lastY
                    item:setPositionY(y)

                    if needMoveUpSurvive and(not isDead) and data[1] and data[2] then
                        needMoveUpSurvive = false

                        local image_number = item:getChildByName("image_number")
                        if data.leftAdd == 2 or data.rightAdd == 2 then
                            image_number:hide()
                        else
                            image_number:show()
                            image_number:setOpacity(255)
                            image_number:runAction(cc.FadeOut:create(ui.TIME))
                            if ui.isPlayingKillAni then
                                image_number:pause()
                            end
                        end
                    end
                end
                ui.oldList = list
            else
                local children = view_card:getChildren()
                for i, child in ipairs(children) do
                    if child:getName() ~= "panel_war" then
                        child:removeFromParent()
                    end
                end
                children = view_card:getChildren()

                while #children > #list do
                    children[#children]:removeFromParent()
                    children[#children] = nil
                end
                while #children < #list do
                    children[#children + 1] = panel_war:clone()
                    view_card:addChild(children[#children])
                end

                for i = 1, #list do
                    local child = children[i]
                    child:setPosition(scrollViewSize.width / 2, getPositionY(i))
                    child:setLocalZOrder(#list - i)

                    if list.deadStart and i >= list.deadStart then
                        child:setTag(20000 + i - list.deadStart)
                    else
                        child:setTag(i + ui.start)
                    end
                    child:getChildByName("image_blue"):stopAllActions()
                    child:getChildByName("image_red"):stopAllActions()
                    setBattleScrollViewItem(child, list[i], true)
                end

                if battleField.state == UIWar.BF_STATE.FIGHTING then
                    ui.oldList = list
                else
                    ui.oldList = nil
                end

                if #list > 0 then
                    local ani_fight = view_card:getChildByName("ani_fight")
                    if battleField.state == UIWar.BF_STATE.FIGHTING then
                        if not ani_fight then
                            ani_fight = ActionManager.getEffectAnimation(24)
                            ani_fight:setName("ani_fight")
                            ani_fight:setScale(0.3)
                            ani_fight:getAnimation():playWithIndex(0)
                            ani_fight:setLocalZOrder(1000)
                            view_card:addChild(ani_fight)
                        end
                        local y = list.getPositionY(1)
                        ani_fight:setPosition(panel_war:getPositionX() -4, y - 8)
                    elseif ani_fight then
                        view_card:removeChildByName("ani_fight")
                    end

                    local x = scrollViewSize.width / 2

                    local currentTitle = text_state:clone()
                    currentTitle:setName("currentTitle")
                    currentTitle:setString(Lang.ui_war_info28)
                    currentTitle:setPosition(x, innerHeight - titleHeight / 2)
                    view_card:addChild(currentTitle)

                    local waitFightTitle = text_state:clone()
                    waitFightTitle:setName("waitFightTitle")
                    waitFightTitle:setString(Lang.ui_war_info29)
                    waitFightTitle:setLocalZOrder(1000)
                    waitFightTitle:setPosition(x, innerHeight - titleHeight - 4 +(getPositionOffsetY(1) == 0 and - panel_war:getContentSize().height or 0) - titleHeight / 2)
                    view_card:addChild(waitFightTitle)

                    local deadTitle = text_state:clone()
                    deadTitle:setAnchorPoint(display.CENTER_BOTTOM)
                    deadTitle:setName("deadTitle")
                    deadTitle:setString(Lang.ui_war_info30)
                    local curY = 0
                    local deadIdx = list.deadStart or(#list + 1)
                    curY = innerHeight - topSpace + 4 -(deadIdx - 1) *(panel_war:getContentSize().height + 4) + getPositionOffsetY(deadIdx)
                    deadTitle:setPosition(x, curY)
                    view_card:addChild(deadTitle)
                end
            end
        end
    end

    ui.playFightAni = nil
    ui.playAmbushAni = nil
end

function ui.free()
    ui.fieldId = nil
    ui.list = nil
    ui.start = nil
    ui.oldList = nil
    ui.canDragItem = nil
    ui.insertPos = nil
    ui.isPlayingCount = nil
    ui.isPlayingKillAni = nil
    if text_state and text_state:getReferenceCount() >= 1 then
        text_state:release()
        text_state = nil
    end
    if panel_war and panel_war:getReferenceCount() >= 1 then
        panel_war:release()
        panel_war = nil
    end
end

function ui.show(fieldId)
    ui.fieldId = fieldId
    UIManager.pushScene("ui_war_info")
end
