require"Lang"
UIAllianceWarCheck = { }

local ui = UIAllianceWarCheck

local scrollViewItem

local function netCallbackFunc(pack)
    local code = tonumber(pack.header)

    if code == StaticMsgRule.deportMatrix then
        UIManager.popScene()
        UIManager.showToast(Lang.ui_alliance_war_check1)
    elseif code == StaticMsgRule.enemyPlayerInfo then
        pvp.loadGameData(pack)
        UIManager.pushScene("ui_arena_check")
    end
end

local function setScrollViewItem(item, data)
    local image_card = item:getChildByName("image_card")
    item:loadTexture(utils.getQualityImage(dp.Quality.card, tonumber(data[2]), dp.QualityImageType.small))
    image_card:loadTexture("image/" .. DictUI[tostring(DictCard[data[1]].smallUiId)].fileName)
    utils.showThingsInfo(image_card, StaticTableType.DictCard, tonumber(data[1]))
end

function ui.init()
    local btn_close = ccui.Helper:seekNodeByName(ui.Widget, "btn_close")
    local btn_look = ccui.Helper:seekNodeByName(ui.Widget, "btn_look")
    local btn_check = ccui.Helper:seekNodeByName(ui.Widget, "btn_check")

    btn_close:setPressedActionEnabled(true)
    btn_look:setPressedActionEnabled(true)
    btn_check:setPressedActionEnabled(true)

    local isPrepare = UIAllianceWar.state == UIAllianceWar.STATE.OUTER_PREPARE or UIAllianceWar.state == UIAllianceWar.STATE.INNER_PREPARE

    if ui.isAttackPoint then
        if isPrepare then
            btn_look:hide()
        else
            btn_look:setTitleText(Lang.ui_alliance_war_check2)
        end
    else
        local canKick = isPrepare and UIAllianceWar.isDefend and net.InstUnionMember.int["4"] == 1
        btn_look:setTitleText(canKick and Lang.ui_alliance_war_check3 or Lang.ui_alliance_war_check4)
    end

    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")

            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_check then
                netSendPackage( { header = StaticMsgRule.enemyPlayerInfo, msgdata = { int = { playerId = ui.playerId } } }, netCallbackFunc)
            elseif sender == btn_look then
                if btn_look:getTitleText() == Lang.ui_alliance_war_check5 then
                    if ui.isAttackPoint then
                        UIAllianceWarInfo.tryAttack(ui.id)
                    else
                        if net.InstUnionMember.int["2"] == UIAllianceWar.warInfo.defendPointInfo[ui.id].unionId then
                            UIManager.showToast(Lang.ui_alliance_war_check6)
                            return
                        end

                        UIAllianceWarInfo.tryAttack(ui.id)
                    end
                else
                    UIManager.showLoading()
                    netSendPackage( { header = StaticMsgRule.deportMatrix, msgdata = { int = { id = ui.id, type = 0 } } }, netCallbackFunc)
                end
            end
        end
    end

    btn_close:addTouchEventListener(onButtonEvent)
    btn_look:addTouchEventListener(onButtonEvent)
    btn_check:addTouchEventListener(onButtonEvent)
end

function ui.setup()
    local view_card = ccui.Helper:seekNodeByName(ui.Widget, "view_card")
    local label_fight = ccui.Helper:seekNodeByName(ui.Widget, "label_fight")
    local image_frame_card = ccui.Helper:seekNodeByName(ui.Widget, "image_frame_card")
    local image_card = image_frame_card:getChildByName("image_card")
    local text_name = image_frame_card:getChildByName("text_name")
    local text_lv = image_frame_card:getChildByName("text_lv")
    local text_add = image_frame_card:getChildByName("text_add")
    local text_point = image_frame_card:getChildByName("text_point")

    label_fight:setString(tostring(math.round(ui.fightValue * (1 + ui.propAdd / 100))))

    image_frame_card:loadTexture(utils.getQualityImage(dp.Quality.card, DictCard[tostring(ui.iconId)].qualityId, dp.QualityImageType.small))
    image_card:loadTexture("image/" .. DictUI[tostring(DictCard[tostring(ui.iconId)].smallUiId)].fileName)
    utils.showThingsInfo(image_card, StaticTableType.DictCard, tonumber(ui.iconId))

    text_name:setString(ui.name)
    text_lv:setString("LV." .. ui.level)
    text_add:setString(string.format(Lang.ui_alliance_war_check7, ui.propAdd))
    text_point:setString(Lang.ui_alliance_war_check8 .. ui.point)

    scrollViewItem = view_card:getChildByName("image_frame_card")
    scrollViewItem:retain()

    local cardData = utils.stringSplit(ui.cards, "|")
    for i = 1, #cardData do
        cardData[i] = utils.stringSplit(cardData[i], "_")
    end
    utils.updateHorzontalScrollView(ui, view_card, scrollViewItem, cardData, setScrollViewItem, { space = 2 })
end

function ui.free()
    if scrollViewItem and scrollViewItem:getReferenceCount() >= 1 then
        scrollViewItem:release()
        scrollViewItem = nil
    end
    ui.isAttackPoint = nil
    ui.fightValue = nil
    ui.level = nil
    ui.name = nil
    ui.iconId = nil
    ui.propAdd = nil
    ui.point = nil
    ui.cards = nil
end
