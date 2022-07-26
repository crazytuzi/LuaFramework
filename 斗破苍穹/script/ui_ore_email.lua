require"Lang"
UIOreEmail = { }

local ui = UIOreEmail
local _svItem = nil

function ui.init()
    _svItem = ccui.Helper:seekNodeByName(ui.Widget, "image_base_email")
    _svItem:retain()

    local btn_closed = ccui.Helper:seekNodeByName(ui.Widget, "btn_closed")
    btn_closed:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            UIManager.popScene()
        end
    end )
end

function ui.getEmailInfo(obj)
    local name, description = "", ""
    local results = obj.int["6"]
    local enemyName = obj.string["3"]
    local content = utils.stringSplit(obj.string["7"], "|")
    local hour, min, sec = 0, 0, 0
    if content[1] then
        local t = tonumber(content[1])
        hour = math.floor(t / 3600)
        min = math.floor(t % 3600 / 60)
        sec = math.floor(t % 60)
    end

    if results == 2 then
        name = Lang.ui_ore_email1
        description = string.format(Lang.ui_ore_email2, hour, min, sec, content[2], content[3])
    elseif results == 3 then
        name = Lang.ui_ore_email3
        description = string.format(Lang.ui_ore_email4, hour, min, sec, content[2], content[3])
    elseif results == 4 then
        name = Lang.ui_ore_email5
        description = string.format(Lang.ui_ore_email6, enemyName, hour, min, sec, content[2], content[3])
    elseif results == 5 then
        name = Lang.ui_ore_email7
        description = string.format(Lang.ui_ore_email8, enemyName, hour, min, sec, content[2], content[3])
    elseif results == 6 then
        name = Lang.ui_ore_email9
        description = string.format(Lang.ui_ore_email10, hour, min, sec, content[2], content[3])
    elseif results == 7 then
        name = Lang.ui_ore_email11
        description = string.format(Lang.ui_ore_email12, hour, min, sec, content[2], content[3])
    elseif results == 8 then
        name = Lang.ui_ore_email13
        description = string.format(Lang.ui_ore_email14, enemyName, hour, min, sec, content[2], content[3])
    elseif results == 9 then
        name = Lang.ui_ore_email15
        description = string.format(Lang.ui_ore_email16, enemyName, hour, min, sec, content[2], content[3])
    end

    if content[4] then
        local itemProp = utils.getItemProp(content[4])
        description = string.gsub(description, "。", ",")
        description = description .. string.format(Lang.ui_ore_email17, itemProp.name, itemProp.count)
    end

    return name, description
end

local function netErrorCallbackFunc(pack)
    local protocol = tonumber(pack.header)
    local msgdata = pack.msgdata
    if protocol == StaticMsgRule.mineFightWin then
        UIOre.showFightResult(ui, -1, msgdata)
    elseif protocol == StaticMsgRule.mineFail then
        UIOre.showFightResult(ui, 0)
    end
end

local function netCallbackFunc(pack)
    local protocol = tonumber(pack.header)
    local msgdata = pack.msgdata
    if protocol == StaticMsgRule.mineBeatBack then
        if msgdata.int.fightType == 0 or msgdata.int.fightType == 1 then
            pvp.loadGameData(pack)
            UIOreInfo.warParam = { msgdata.int.fightType, msgdata.int.playerId, msgdata.int.mineId }
            utils.sendFightData(nil, dp.FightType.FIGHT_MINE, function(isWin)
                if isWin then
                    netSendPackage( {
                        header = StaticMsgRule.mineFightWin,
                        msgdata =
                        {
                            int = { fightType = UIOreInfo.warParam[1], id = UIOreInfo.warParam[2], mineId = UIOreInfo.warParam[3] },
                            string = { coredata = GlobalLastFightCheckData }
                        }
                    } , netCallbackFunc, netErrorCallbackFunc)
                else
                    netSendPackage( { header = StaticMsgRule.mineFail, msgdata = { int = { mineId = UIOreInfo.warParam[3] } } }, netCallbackFunc, netErrorCallbackFunc)
                end
            end )
            if not UIFightMain.Widget or not UIFightMain.Widget:getParent() then
                UIFightMain.loading()
            else
                UIFightMain.setup()
            end
        end
    elseif protocol == StaticMsgRule.mineFightWin then
        UIOre.showFightResult(ui, 1, msgdata)
    elseif protocol == StaticMsgRule.mineFail then
        UIOre.showFightResult(ui, 0)
    end
end

local function setScrollViewItem(item, obj)
    local text_title = item:getChildByName("text_title")
    local text_time = item:getChildByName("text_time")
    local btn_go = item:getChildByName("btn_go")
    local image_di = item:getChildByName("image_di")
    local image_di_long = item:getChildByName("image_di_long")
    local name, description = ui.getEmailInfo(obj)

    text_title:setString(name)

    local serverTime = utils.GetTimeByDate(obj.string["9"])
    local currentTime = utils.getCurrentTime()
    local subTime = currentTime - serverTime
    local timeText = nil

    if math.floor(subTime /(3600 * 24)) > 0 then
        timeText = math.floor(subTime /(3600 * 24)) .. Lang.ui_ore_email18
    elseif math.floor(subTime / 3600) > 0 then
        timeText = math.floor(subTime / 3600) .. Lang.ui_ore_email19
    elseif math.floor(subTime / 60) > 0 then
        timeText = math.floor(subTime / 60) .. Lang.ui_ore_email20
    elseif math.floor(subTime % 60) > 0 then
        timeText = math.floor(subTime % 60) .. Lang.ui_ore_email21
    end
    text_time:setString(timeText)

    if obj.int["6"] == 4 then
        image_di:show():getChildByName("text_info"):setString(description)
        image_di_long:hide()
        btn_go:show():addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                audio.playSound("sound/button.mp3")
                if UIOre.mineId and UIOre.mineId ~= 0 then
                    utils.PromptDialog( function()
                        UIManager.showLoading()
                        local packet = { header = UIOre.mineOp == UIOre.MINE_OP_OCCUPY and StaticMsgRule.giveUpOccupy or StaticMsgRule.giveUpAssist, msgdata = { int = { mineId = UIOre.mineId } } }
                        local function giveUpCallback(pack)
                            UIManager.showLoading()
                            netSendPackage( { header = StaticMsgRule.mineBeatBack, msgdata = { int = { minerId = obj.int["5"] } } }, netCallbackFunc)
                        end
                        netSendPackage(packet, giveUpCallback, giveUpCallback)
                    end , string.format(Lang.ui_ore_email22, UIOre.mineOp == UIOre.MINE_OP_OCCUPY and Lang.ui_ore_email23 or Lang.ui_ore_email24, UIOre.mineOp == UIOre.MINE_OP_OCCUPY and "" or Lang.ui_ore_email25))
                else
                    UIManager.showLoading()
                    netSendPackage( { header = StaticMsgRule.mineBeatBack, msgdata = { int = { minerId = obj.int["5"] } } }, netCallbackFunc)
                end
            end
        end )
    else
        btn_go:hide()
        image_di:hide()
        image_di_long:show():getChildByName("text_info"):setString(description)
    end
end

local function compareMail(value1, value2)
    local iTime1 = utils.GetTimeByDate(value1.string["9"])
    local iTime2 = utils.GetTimeByDate(value2.string["9"])
    return iTime1 < iTime2
end

function ui.setup()
    ui.mail = { }
    if net.InstPlayerMail then
        for key, value in pairs(net.InstPlayerMail) do
            if value.int["4"] == 5 then
                table.insert(ui.mail, value)
            end
        end
        utils.quickSort(ui.mail, compareMail)
    end

    local view_success = ccui.Helper:seekNodeByName(ui.Widget, "view_success")
    view_success:removeAllChildren()
    if next(ui.mail) then
        utils.updateScrollView(UIOreEmail, view_success, _svItem, ui.mail, setScrollViewItem)
    end
end

function ui.free()
    local view_success = ccui.Helper:seekNodeByName(ui.Widget, "view_success")
    view_success:removeAllChildren()
    if _svItem and _svItem:getReferenceCount() >= 1 then
        _svItem:release()
        _svItem = nil
    end
end
