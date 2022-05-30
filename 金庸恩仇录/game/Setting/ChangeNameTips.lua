local ChangeNameTips = class("ChangeNameTips", function()
	return require("utility.ShadeLayer").new()
end)

function ChangeNameTips:ctor(param)
	dump(param)
	local name = param.name
	local listener = param.listener
	local closeListener = param.closeListener
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("formation/changename_popup.ccbi", proxy, rootnode)
	node:setPosition(display.width / 2, display.height / 2)
	self:addChild(node)
	
	rootnode.tag_close:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:onClose()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.cancelBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:onClose()
	end,
	CCControlEventTouchUpInside)
	
	rootnode.mNickname:setString(name)
	rootnode.mThetitle:setVisible(false)
	rootnode.mPrompt:setVisible(true)
	rootnode.edit_node:setVisible(false)
	rootnode.mThetext:setVisible(true)
	rootnode.confirmBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		listener(1, name)
		self:onClose()
		closeListener()
	end,
	CCControlEventTouchUpInside)
	
end

function ChangeNameTips:onClose()
	self:removeSelf()
end
return ChangeNameTips