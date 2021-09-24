local ChatViewMediator = classGc(mediator,function(self,_view)
	self.name = "ChatViewMediator"
	self.view = _view
	self:regSelf()
end)

ChatViewMediator.protocolsList={
	_G.Msg.ACK_TEAM_LIVE_REP,
}
ChatViewMediator.commandsList={
	ChatMsgCommand.TYPE,
	CVoiceCommand.TYPE
}

function ChatViewMediator.processCommand(self, _command)
	if _command:getType()==ChatMsgCommand.TYPE then
		self.view:insertOneChatMsg(_command.chatMsg)
	elseif _command:getType()==CVoiceCommand.TYPE then
		local nData=_command:getData()
		print("[接收到语音回调命令]------->>>>>",nData)
		if nData==CVoiceCommand.RECORD_SUCCESS then
			self.view:__sendVoiceMsg(_command.msgT)
		elseif nData==CVoiceCommand.PLAY_FINISH then
			self.view:playVoiceFinish()
		end
	end
end

function ChatViewMediator.ACK_TEAM_LIVE_REP(self,_ackMsg)
	if _ackMsg.type==3 then
		self.view:teamCheckBack(_ackMsg.rep)
	end
end

return ChatViewMediator

