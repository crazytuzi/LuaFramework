require"Lang"
UIAllianceWarRank = { }

local NAMES = { Lang.ui_alliance_war_rank1, Lang.ui_alliance_war_rank2, Lang.ui_alliance_war_rank3, Lang.ui_alliance_war_rank4 }

local ui = UIAllianceWarRank

local listItem = nil

function ui.init()
    local btn_close = ccui.Helper:seekNodeByName(ui.Widget, "btn_close")

    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            if sender == btn_close then
                UIManager.popScene()
            end
        end
    end

    btn_close:addTouchEventListener(onButtonEvent)
end

local function setScrollViewItem(item, data)
    local text_rank = item:getChildByName("text_rank")
    local text_name = item:getChildByName("text_name")
    local text_number = item:getChildByName("text_number")

    text_rank:setString(tostring(item:getTag()))
    text_name:setString(data[1])
    text_number:setString(data[2])
end

function ui.setup()
    local view_list = ccui.Helper:seekNodeByName(ui.Widget, "view_list")
    listItem = view_list:getChildByName("panel_info")
    listItem:retain()
    view_list:removeAllChildren()
end

function ui.show(type)
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.showScoreRank, msgdata = { int = { side = type % 2, type = type >= 2 and 1 or 0 } } }, function(pack)
        UIManager.pushScene("ui_alliance_war_rank")
        local list = pack.msgdata.string.rank
        list = utils.stringSplit(list, "/")
        for i = 1, #list do
            list[i] = utils.stringSplit(list[i], "|")
        end
        local view_list = ccui.Helper:seekNodeByName(ui.Widget, "view_list")
        utils.updateScrollView(ui, view_list, listItem, list, setScrollViewItem, { space = 4, setTag = true })

        local text_title = ccui.Helper:seekNodeByName(ui.Widget, "text_title")
        text_title:setString(NAMES[type + 1] or "")
    end )
end

function ui.free()
    ccui.Helper:seekNodeByName(ui.Widget, "view_list"):removeAllChildren()
    if listItem and listItem:getReferenceCount() >= 1 then
        listItem:release()
        listItem = nil
    end
end
