require"Lang"
UISettingsHint = {}

local ui_editBox = nil

local function netCallbackFunc(data)
	UIManager.showToast(Lang.ui_settings_hint1)
end

function UISettingsHint.init()
	local ui_editBoxBg = ccui.Helper:seekNodeByName(UISettingsHint.Widget, "image_di")
	ui_editBox = cc.EditBox:create(ui_editBoxBg:getContentSize(), cc.Scale9Sprite:create())
  ui_editBox:setAnchorPoint(ui_editBoxBg:getAnchorPoint())
  ui_editBox:setPosition(ui_editBoxBg:getPosition())
  ui_editBox:setFont(dp.FONT, 25)
  ui_editBox:setFontColor(cc.c3b(255, 255, 255))
  ui_editBox:setPlaceHolder(Lang.ui_settings_hint2)
  ui_editBox:setMaxLength(15)
  ui_editBoxBg:getParent():addChild(ui_editBox)

	local btn_cancel = ccui.Helper:seekNodeByName(UISettingsHint.Widget, "btn_cancel")
	local btn_ok = ccui.Helper:seekNodeByName(UISettingsHint.Widget, "btn_ok")
	btn_cancel:setPressedActionEnabled(true)
	btn_ok:setPressedActionEnabled(true)
	local function onBtnEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == btn_cancel then
				UIManager.popScene()
			elseif sender == btn_ok then
				if string.len(ui_editBox:getText()) > 0 then
					UIManager.showLoading()
					netSendPackage({header=StaticMsgRule.cDKeyAward,msgdata={string={cdk=ui_editBox:getText()}}}, netCallbackFunc)
				else
					UIManager.showToast(Lang.ui_settings_hint3)
				end
			end
		end
	end
	btn_cancel:addTouchEventListener(onBtnEvent)
	btn_ok:addTouchEventListener(onBtnEvent)
end

function UISettingsHint.setup()
	if ui_editBox then
		ui_editBox:setText("")
	end
end

function UISettingsHint.free()
end
