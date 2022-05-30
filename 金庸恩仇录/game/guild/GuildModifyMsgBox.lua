require("data.data_error_error")
local GameDevice = require("sdk.GameDevice")

local GuildModifyMsgBox = class("GuildModifyMsgBox", function()
	return require("utility.ShadeLayer").new()
end)

function GuildModifyMsgBox:ctor(param)
	local title = param.title
	local text = param.text or ""
	local msgMaxLen = param.msgMaxLen
	local confirmFunc = param.confirmFunc
	local cancelFunc = param.cancelFunc
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/guild/guild_modify_msgBox.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	rootnode.titleLabel:setString(title)
	local editBoxNode = rootnode.editBox_node
	local cntSize = editBoxNode:getContentSize()
	self._editBox = ui.newEditBox({
	image = "#win_base_inner_bg_black.png",
	size = cc.size(cntSize.width, cntSize.height),
	x = cntSize.width / 2,
	y = cntSize.height / 2
	})
	self._editBox:setFont(FONTS_NAME.font_fzcy, 22)
	self._editBox:setFontColor(FONT_COLOR.WHITE)
	self._editBox:setMaxLength(msgMaxLen)
	self._editBox:setPlaceHolder(text)
	self._editBox:setPlaceholderFont(FONTS_NAME.font_fzcy, 22)
	self._editBox:setPlaceholderFontColor(FONT_COLOR.WHITE)
	self._editBox:setReturnType(1)
	self._editBox:setInputMode(0)
	self._editBox:setText(text)
	editBoxNode:addChild(self._editBox)
	local function closeFunc()
		if cancelFunc ~= nil then
			cancelFunc()
		end
		self:removeSelf()
	end
	rootnode.tag_close:addHandleOfControlEvent(function(sender,eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.cancelBtn:addHandleOfControlEvent(function(sender,eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.confirmBtn:addHandleOfControlEvent(function(sender,eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local text = self._editBox:getText()
		local GameDevice = require("sdk.GameDevice")
		if text == "" then
			show_tip_label(data_error_error[2900040].prompt)
		elseif common:checkSensitiveWord(text) == true or ResMgr.checkSensitiveWord(text) == true then
			show_tip_label(data_error_error[2900041].prompt)
		elseif string.utf8len(text) > msgMaxLen then
			show_tip_label(data_error_error[2900042].prompt)
		elseif GameDevice.isContainsEmoji(text) == true then
			show_tip_label(common:getLanguageString("@HintErrorTyping"))
		elseif confirmFunc ~= nil then
			confirmFunc(text, self)
			self._editBox:setText("")
		end
	end,
	CCControlEventTouchUpInside)
	
end

return GuildModifyMsgBox