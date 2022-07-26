require"Lang"
UIBagChange = {}

local _type = nil

function UIBagChange.init()
    local panel = UIBagChange.Widget:getChildByName("image_hint")
    local ui_textBg = panel:getChildByName("image_name_new")
    local text_new = ui_textBg:getChildByName("text_new")  
    text_new:setString("")
    text_new:setPlaceHolder("")
    text_new:setOpacity( 0 )
    local ui_editBox = cc.EditBox:create(text_new:getContentSize(), cc.Scale9Sprite:create())
    ui_editBox:setAnchorPoint(text_new:getAnchorPoint())
    ui_editBox:setPosition(text_new:getPosition())
    ui_editBox:setFont(text_new:getFontName(), text_new:getFontSize())
    ui_editBox:setFontColor(text_new:getColor())
    ui_editBox:setPlaceHolder(Lang.ui_bag_change1)
    ui_editBox:setMaxLength(8)
    local btn_out = ccui.Helper:seekNodeByName(UIBagChange.Widget, "btn_out")
    local btn_sure= ccui.Helper:seekNodeByName(UIBagChange.Widget,"btn_sure")
    btn_out:setPressedActionEnabled(true)
    btn_sure:setPressedActionEnabled(true)
    local function onBtnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_out then
                UIManager.popScene()
            elseif sender == btn_sure then
                local content = ui_editBox:getText()
                if content and content ~= "" then
                    UIManager.showLoading()
                    netSendPackage( { header = StaticMsgRule.changeName , msgdata = { int = { type = _type } ,string = { name = content } } } , function ( pack )
                        UIManager.showToast( Lang.ui_bag_change2 )
                        UIManager.popScene()
                        UIManager.flushWidget(UIBag)
                        UIManager.flushWidget(UITeamInfo)
                    end )
                else
                    UIManager.showToast( Lang.ui_bag_change3 )
                end
            end
        end
    end
    btn_out:addTouchEventListener(onBtnEvent)
    btn_sure:addTouchEventListener(onBtnEvent)


    text_new:getParent():addChild(ui_editBox, text_new:getLocalZOrder() + 1 )
    ui_editBox:registerScriptEditBoxHandler( function(eventType, sender)
        if eventType == "return" then
            text_new:setString(ui_editBox:getText())
        end
    end )
end

function UIBagChange.setup()
    local image_name_old = ccui.Helper:seekNodeByName( UIBagChange.Widget , "image_name_old" )
    local text_name = image_name_old:getChildByName("text_name")
    local text_title = ccui.Helper:seekNodeByName( UIBagChange.Widget , "text_title" )
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.clickChangeNameCard , msgdata = { int = { type = _type } } } , function ( pack )
        local name = pack.msgdata.string["1"]
        text_name:setString(Lang.ui_bag_change4..name)
    end )
    if _type == 1 then
        text_title:setString( Lang.ui_bag_change5 )
    elseif _type == 2 then
        text_title:setString( Lang.ui_bag_change6 )
    end
end
function UIBagChange.setType( type1 )
	_type = type1
end
function UIBagChange.free()
    _type = nil
end
