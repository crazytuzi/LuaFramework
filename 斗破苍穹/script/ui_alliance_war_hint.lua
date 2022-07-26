require"Lang"
UIAllianceWarHint = {}

local ui = UIAllianceWarHint

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
    item:setString(data .. Lang.ui_alliance_war_hint1)
end

function ui.setup()
    local view_list = ccui.Helper:seekNodeByName(ui.Widget, "view_list")
    listItem = view_list:getChildByName("text_name")
    listItem:retain()
    view_list:removeAllChildren()
    UIManager.showLoading()
    netSendPackage({ header = StaticMsgRule.showInspireList, msgdata = {}}, function(pack)
        local list = pack.msgdata.string.list
        list = utils.stringSplit(list, "/")
        utils.updateScrollView(ui, view_list, listItem, list, setScrollViewItem, { space = 4 })
    end)
end

function ui.free()
    ccui.Helper:seekNodeByName(ui.Widget, "view_list"):removeAllChildren()
    if listItem and listItem:getReferenceCount() >= 1 then
        listItem:release()
        listItem = nil
    end
end
