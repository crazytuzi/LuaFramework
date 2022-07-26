require"Lang"
UIAllianceHint = { }

-- 联盟公告字数限制
local NOTICE_MAX_LENGTH = 50

-- 联盟宣言字数限制
local MANIFESTO_MAX_LENGTH = 20

local userData = nil

local function netCallbackFunc(msgData)
    UIManager.popScene()
    if userData.callbackFunc then
        userData.callbackFunc(msgData)
    end
end

function UIAllianceHint.init()
end

function UIAllianceHint.setup()
    local panel = UIAllianceHint.Widget:getChildByName("image_hint")
    local ui_titleText = panel:getChildByName("text_title")
    local ui_descText = panel:getChildByName("text_number")
    local ui_textBg = panel:getChildByName("image_hint")
    local ui_textLabel = ui_textBg:getChildByName("text_hint")
    local btn_close = panel:getChildByName("btn_closed")
    local btn_cancel = panel:getChildByName("btn_cancel")
    local btn_ok = panel:getChildByName("btn_ok")
    btn_close:setPressedActionEnabled(true)
    btn_cancel:setPressedActionEnabled(true)
    btn_ok:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_cancel or sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_ok then
                UIManager.showLoading()
                netSendPackage( {
                    header = StaticMsgRule.writeUnion,
                    msgdata =
                    {-- 1-公告 2-宣言
                        int = { instUnionMemberId = net.InstUnionMember.int["1"], type = userData.title == Lang.ui_alliance_hint1 and 1 or 2 },
                        string = { detail = ui_textLabel:getString() }
                    }
                } , netCallbackFunc)
            end
        end
    end
    btn_close:addTouchEventListener(onButtonEvent)
    btn_cancel:addTouchEventListener(onButtonEvent)
    btn_ok:addTouchEventListener(onButtonEvent)
    ui_titleText:setString(Lang.ui_alliance_hint2 .. userData.title)
    ui_descText:setString(string.format(Lang.ui_alliance_hint3, userData.title == Lang.ui_alliance_hint4 and NOTICE_MAX_LENGTH or MANIFESTO_MAX_LENGTH))

    local ui_editBox = cc.EditBox:create(ui_textLabel:getContentSize(), cc.Scale9Sprite:create())
    ui_editBox:setAnchorPoint(ui_textLabel:getAnchorPoint())
    ui_editBox:setPosition(ui_textLabel:getPosition())
    ui_editBox:setFont(ui_textLabel:getFontName(), ui_textLabel:getFontSize())
    ui_editBox:setFontColor(ui_textLabel:getColor())
    ui_editBox:setPlaceHolder(Lang.ui_alliance_hint5 .. userData.title)
    ui_editBox:setMaxLength(userData.title == Lang.ui_alliance_hint6 and NOTICE_MAX_LENGTH or MANIFESTO_MAX_LENGTH)
    ui_textLabel:getParent():addChild(ui_editBox, -1)
    if userData.desc then
        ui_editBox:setText(userData.desc)
        ui_textLabel:setString(userData.desc)
    end
    ui_editBox:registerScriptEditBoxHandler( function(eventType, sender)
        if eventType == "return" then
            ui_textLabel:setString(ui_editBox:getText())
        end
    end )
end

function UIAllianceHint.free()
    userData = nil
end

function UIAllianceHint.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_alliance_hint")
end
