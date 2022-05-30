local data_message_message = require("data.data_message_message")

local LimitHeroDescLayer = class("LimitHeroDescLayer", function()
	return require("utility.ShadeLayer").new()
end)

function LimitHeroDescLayer:ctor()
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("friend/friend_desc.ccbi", proxy, rootnode)
	self:addChild(node)
	node:setPosition(display.cx, display.cy)
	rootnode.titleLabel:setString(common:getLanguageString("@ActivityHelpTitle"))
	rootnode.descLabel:setString(data_message_message[17].text)
	local preferSize = cc.size(rootnode.content_node:getContentSize().width, rootnode.content_node:getContentSize().height)
	rootnode.tag_bg:setContentSize(preferSize)
	
	--¹Ø±Õ
	rootnode.tag_close:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
end

return LimitHeroDescLayer