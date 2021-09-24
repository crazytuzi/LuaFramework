local ChatProxyMediator = classGc(mediator,function(self,_view)
	self.name = "ChatProxyMediator"
	self.view = _view
	self:regSelfLong()
end)

ChatProxyMediator.protocolsList={
	_G.Msg.ACK_CHAT_RECE,
	_G.Msg.ACK_SYSTEM_BROADCAST, -- [810]游戏广播 -- 系统
	_G.Msg.ACK_SYSTEM_NOTICE, -- (手动) -- [800]系统通知 -- 系统 跑马灯
	_G.Msg.ACK_CHAT_RECE_YUYIN, --[9525]收到语音聊天
	_G.Msg.ACK_CHAT_RECE_PM, --[9530]收到私聊
}

ChatProxyMediator.commandsList=nil

-- (手动) -- [800]系统通知 -- 系统 
function ChatProxyMediator.ACK_SYSTEM_NOTICE( self, _ackMsg )
    -- print("ChatProxyMediator.ACK_SYSTEM_NOTICE======>>>")
    _ackMsg.channel_id=_ackMsg.position
    
    -- for k,v in pairs(_ackMsg) do
    -- 	print(k,v)
    -- end
    self.view:handleSystemNetworkMsg(_ackMsg.msg_data)
end

function ChatProxyMediator.ACK_CHAT_RECE(self, _ackMsg)
	-- print("ChatProxyMediator.ACK_CHAT_RECE======>>>")
	-- for k,v in pairs(_ackMsg) do
	-- 	print(k,v)
	-- end

	if _G.GPropertyProxy:getMainPlay()==nil then return end

	self.view:handleUserNetworkMsg(_ackMsg)
end

function ChatProxyMediator.ACK_CHAT_RECE_YUYIN(self, _ackMsg)
	print("ChatProxyMediator.ACK_CHAT_RECE_YUYIN======>>>")
	if not _G.SysInfo:isYayaImSupport() then return end

	if _G.GPropertyProxy:getMainPlay()==nil then return end
	
	for k,v in pairs(_ackMsg) do
		print(k,v)
	end
	self.view:handleVoiceMsg(_ackMsg)
end

function ChatProxyMediator.ACK_CHAT_RECE_PM(self, _ackMsg)
	-- print("ChatProxyMediator.ACK_CHAT_RECE_PM======>>>")

	if _G.GPropertyProxy:getMainPlay()==nil then return end
	
	-- for k,v in pairs(_ackMsg) do
	-- 	print(k,v)
	-- end
	_ackMsg.channel_id=_G.Const.CONST_CHAT_PM
	self.view:handleUserNetworkMsg(_ackMsg)
end

function ChatProxyMediator.ACK_SYSTEM_BROADCAST(self, _ackMsg)
	-- print("ChatProxyMediator.ACK_SYSTEM_BROADCAST======>>>")

	-- for k,v in pairs(_ackMsg) do
	-- 	print(k,v)
	-- end
	-- if _ackMsg.data then
	-- 	print("==================")
	-- 	for kk,vv in pairs(_ackMsg.data) do
	-- 		for k,v in pairs(vv) do
	-- 			print(k,v)
	-- 		end
	-- 	end
	-- 	print("==================")
	-- end

	-- _ackMsg.channel_id=_G.Const.CONST_CHAT_SYSTEM
	self.view:handleBroadcastNetworkMsg(_ackMsg)
end

return ChatProxyMediator

