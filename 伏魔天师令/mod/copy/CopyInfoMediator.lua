local CopyInfoMediator = classGc(mediator, function(self, _view)
	self.name = "CopyInfoMediator"
	self.view = _view
	self:regSelf()
end)

CopyInfoMediator.protocolsList={
	_G.Msg.ACK_COPY_COPY_DATA,
	_G.Msg.ACK_COPY_UP_REWARD_REPLY,
}
CopyInfoMediator.commandsList={
	CPropertyCommand.TYPE,
	CCopyMapCommand.TYPE,
}

function CopyInfoMediator.processCommand(self, _command)
    local commandType = _command :getType()
    if commandType == CPropertyCommand.TYPE then
        if _command :getData() == CPropertyCommand.ENERGY then
            self.view:updateMyEnergy()
        end
	elseif commandType == CCopyMapCommand.TYPE then
        local commandData = _command :getData()
        if commandData == CCopyMapCommand.HUANGUP_END3 then
            self:destroy()
        end
    end
end

function CopyInfoMediator.ACK_COPY_COPY_DATA(self, _ackMsg)
	self.view:showRightInfo(_ackMsg)
end

-- 7860	 挂机完成
function CopyInfoMediator.ACK_COPY_UP_OVER(self, _ackMsg)
	print("ACK_COPY_UP_OVER--->".._ackMsg.type)
	self.view :ACK_COPY_UP_OVER(_ackMsg)
end

 -- 7865	 登陆提醒挂机
function CopyInfoMediator.ACK_COPY_LOGIN_NOTICE(self,_ackMsg)
	for k,v in pairs(_ackMsg) do
        print(k,v)
    end
    
	for i=1,#_ackMsg.data do
		local v=_ackMsg.data[i]
		self.view:addOneReward(v)
	end
end

function CopyInfoMediator.ACK_COPY_UP_REWARD_REPLY(self,_ackMsg)
	self.view:getRewardCallBack()
end

return CopyInfoMediator

