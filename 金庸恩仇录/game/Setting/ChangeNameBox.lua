local data_item_item = require("data.data_item_item")

local ChangeNameBox = class("ChangeNameBox", function()
	return require("utility.ShadeLayer").new()
end)

function ChangeNameBox:ctor(param)
	dump(param)
	local name = param.name
	local listener = param.listener
	local expend = param.expend
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("formation/changename_popup.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	rootnode.cancelBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:onClose()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:onClose()
	end,
	CCControlEventTouchUpInside)
	
	local editBoxNode = rootnode.mBottom
	local width = editBoxNode:getContentSize().width
	local height = editBoxNode:getContentSize().height
	self._editBox = ui.newEditBox({
	image = "#win_base_inner_bg_black.png",
	size = editBoxNode:getContentSize(),
	x = width / 2,
	y = height / 2
	})
	editBoxNode:addChild(self._editBox, 80)
	self._editBox:setFont("fonts/FZCuYuan-M03S.ttf", 22)
	self._editBox:setFontColor(cc.c3b(255, 208, 124))
	self._editBox:setMaxLength(50)
	self._editBox:setPlaceHolder(common:getLanguageString("@NameLengthLimit"))
	self._editBox:setPlaceholderFont("fonts/FZCuYuan-M03S.ttf", 22)
	self._editBox:setPlaceholderFontColor(cc.c3b(255, 208, 124))
	self._editBox:setReturnType(1)
	self._editBox:setInputMode(0)
	
	rootnode.confirmBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self._editBox ~= nil and self._editBox:getText() ~= "" then
			local name = self._editBox:getText()
			local length = string.utf8len(name)
			if length > 9 or length < 2 then
				show_tip_label(common:getLanguageString("@PlayerNameError"))
				return
			elseif common:checkSensitiveWord(name) == true or ResMgr.checkSensitiveWord(name) == true then
				show_tip_label(common:getLanguageString("@ContentSensitive"))
				self._editBox:setText("")
			elseif name == game.player.m_name then
				show_tip_label(common:getLanguageString("@CreateNewPlayerName"))
			else
				self:showTip(listener, name)
			end
		else
			show_tip_label(common:getLanguageString("@NameIsNull"))
		end
	end,
	CCControlEventTouchUpInside)
	
end

function ChangeNameBox:showTip(listener, name)
	local useCountBox = require("game.Setting.ChangeNameTips").new({
	name = name,
	listener = listener,
	closeListener = function()
		self:onClose()
	end
	})
	game.runningScene:addChild(useCountBox, 1000)
end

function ChangeNameBox:onClose()
	self:removeSelf()
end

return ChangeNameBox