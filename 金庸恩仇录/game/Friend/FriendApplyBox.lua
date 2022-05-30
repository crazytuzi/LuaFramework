local FriendApplyBox = class("FriendApplyBox", function(param)
	return require("utility.ShadeLayer").new()
end)

function FriendApplyBox:ctor(param)
	self.acc = param.account
	self._confirmFunc = param.confirmFunc
	local cancelFunc = param.cancelFunc
	local size = cc.size(560, 200)
	local baseNode = display.newNode()
	self:addChild(baseNode)
	baseNode:setContentSize(size)
	local rootProxy = CCBProxy:create()
	self._rootnode = {}
	local rootnode = CCBuilderReaderLoad("public/window_msgBoxEx", rootProxy, self._rootnode)
	baseNode:setPosition(display.cx, display.cy)
	baseNode:addChild(rootnode, 1)
	display.addSpriteFramesWithFile("ui/ui_friend.plist", "ui/ui_friend.png")
	local function closeFunc()
		if cancelFunc ~= nil then
			cancelFunc()
		end
		self:removeSelf()
	end
	
	ResMgr.setControlBtnEvent(self._rootnode.confirm_btn, function()
		self:onConfirm()
	end)
	
	ResMgr.setControlBtnEvent(self._rootnode.backBtn, function()
		closeFunc()
	end,
	SFX_NAME.u_guanbi)
	
	ResMgr.setControlBtnEvent(self._rootnode.cancel_btn, function()
		closeFunc()
	end)
	self._rootnode.title:setString(common:getLanguageString("@FriendsAC"))
	self:initEditBox()
end

function FriendApplyBox:initEditBox()
	local boxSize = self._rootnode.inner_board:getContentSize()
	self._editBox = ui.newEditBox({
	image = "#text_frame.png",
	size = boxSize
	})
	self._rootnode.inner_board:addChild(self._editBox)
	self._editBox:setPosition(boxSize.width / 2, boxSize.height / 2)
	self._editBox:setFont(FONTS_NAME.font_fzcy, 24)
	self._editBox:setFontColor(FONT_COLOR.WHITE)
	self._editBox:setMaxLength(FriendModel.MAX_TEXT_LEN)
	self._editBox:setPlaceHolder(common:getLanguageString("@ContentTxt"))
	self._editBox:setPlaceholderFont(FONTS_NAME.font_fzcy, 24)
	self._editBox:setPlaceholderFontColor(FONT_COLOR.WHITE)
	self._editBox:setReturnType(1)
	self._editBox:setInputMode(0)
	self._editBox:setText(common:getLanguageString("@ContentTxt"))
end

function FriendApplyBox:onConfirm()
	local curContent = self._editBox:getText()
	local length = string.utf8len(curContent)
	if length < 2 then
		ResMgr.showErr(FRIEND_KEY.CANNOT_EMPTY_KEY)
		return
	end
	if length > FriendModel.MAX_TEXT_LEN then
		ResMgr.showErr(FRIEND_KEY.TOO_MUCH_CHAR_KEY)
		local text = string.gsub(curContent, 1, FriendModel.MAX_TEXT_LEN)
		self._editBox:setText(text)
		return
	end
	if self._confirmFunc ~= nil then
		self._confirmFunc(self, curContent)
	else
		FriendModel.applyFriendReq({
		content = curContent,
		account = self.acc
		})
		self:removeSelf()
	end
end

function FriendApplyBox:onExit()
	display.removeSpriteFramesWithFile("ui/ui_friend.plist", "ui/ui_friend.png")
end

return FriendApplyBox