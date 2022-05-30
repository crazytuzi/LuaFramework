
local ChatItem = class("ChatItem", function()
	return display.newNode()
end)

function ChatItem:getContentSize()
	if self._contentSz == nil then
		self._contentSz = cc.size(0, 0)
	end
	return self._contentSz
end

function ChatItem:getIsLeft()
	return self._isLeft
end

function ChatItem:ctor(param)
	local msg = param.msg
	local gender = param.gender
	local name = param.name
	local chatListen = param.chatListen
	local bCanTouch = param.bCanTouch
	self._isLeft = param.isLeft
	if param.guildName ~= nil and param.guildName ~= "" and self._isLeft == true then
		name = name .. "【" .. param.guildName .. "】"
	end
	local proxy = CCBProxy:create()
	local rootnode = {}
	local length = string.utf8len(msg)
	if length > 22 then
		self._contentSz = cc.size(500, 80)
	else
		local len = string.len(msg)
		local w = 70 + 20 * len * 0.34
		self._contentSz = cc.size(w, 50)
	end
	local color = cc.c3b(0, 129, 220)
	if self._isLeft and gender == 2 then
		color = cc.c3b(221, 1, 221)
	elseif not self._isLeft then
		color = cc.c3b(1, 170, 48)
	end
	local nameNode, msgNode, pos
	if self._isLeft then
		nameNode = CCBuilderReaderLoad("chat/chat_left_name.ccbi", proxy, rootnode)
		if gender == 1 then
			msgNode = CCBuilderReaderLoad("chat/chat_left_msg_boy.ccbi", proxy, rootnode, self, self._contentSz)
		else
			msgNode = CCBuilderReaderLoad("chat/chat_left_msg_girl.ccbi", proxy, rootnode, self, self._contentSz)
		end
	else
		nameNode = CCBuilderReaderLoad("chat/chat_right_name.ccbi", proxy, rootnode)
		msgNode = CCBuilderReaderLoad("chat/chat_right_msg.ccbi", proxy, rootnode, self, self._contentSz)
	end
	rootnode.nameLbl:setString(name)
	rootnode.nameLbl:setColor(color)
	self._contentSz = cc.size(msgNode:getContentSize().width, msgNode:getContentSize().height + nameNode:getContentSize().height + 10)
	self:addChild(nameNode)
	msgNode:setPosition(0, -nameNode:getContentSize().height - 10)
	self:addChild(msgNode)
	rootnode.msgLbl:setString(msg)
	if bCanTouch ~= nil and bCanTouch == true then
		rootnode.nameLbl:setTouchEnabled(true)
		rootnode.nameLbl:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
			if chatListen ~= nil then
				chatListen()
			end
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		end)
	end
end

return ChatItem