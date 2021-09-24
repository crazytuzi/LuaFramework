local CopySaoDaoMediator = classGc(mediator, function(self, _view)
	self.name = "CopySaoDaoMediator"
	self.view = _view
	self:regSelf()
end)

CopySaoDaoMediator.protocolsList={
	_G.Msg["ACK_COPY_UP_RESULT"],
	_G.Msg["ACK_COPY_UP_OVER"],
	_G.Msg["ACK_COPY_LOGIN_NOTICE"],
	_G.Msg["ACK_COPY_UP_REWARD_REPLY"],
	_G.Msg["ACK_COPY_COPY_DATA"]
}
CopySaoDaoMediator.commandsList={
	CPropertyCommand.TYPE,
}

function CopySaoDaoMediator.processCommand(self, _command)
    local commandType = _command :getType()
    if commandType == CPropertyCommand.TYPE then
        if _command :getData() == CPropertyCommand.ENERGY then
            self.view:__updateLabel()
        end
    end
end

-- 7850	 挂机返回
function CopySaoDaoMediator.ACK_COPY_UP_RESULT(self, _ackMsg)
	print("------ACK_COPY_UP_RESULT" , _ackMsg.nowtimes)
	local oneTimes = _ackMsg.nowtimes
	if oneTimes == 0 then 
		--挂机开始
		self.view :startHuangup(_ackMsg)
	else
		self.view :addOneReward(_ackMsg)
	end
end

-- 7860	 挂机完成
function CopySaoDaoMediator.ACK_COPY_UP_OVER(self, _ackMsg)
	print("ACK_COPY_UP_OVER--->".._ackMsg.type)
	self.view :ACK_COPY_UP_OVER(_ackMsg)
end

 -- 7865	 登陆提醒挂机
function CopySaoDaoMediator.ACK_COPY_LOGIN_NOTICE(self,_ackMsg)
	for k,v in pairs(_ackMsg) do
        print(k,v)
    end
    
	for i=1,#_ackMsg.data do
		local v=_ackMsg.data[i]
		self.view:addOneReward(v)
	end
end

-- 7877	 领取挂机奖励返回
function CopySaoDaoMediator.ACK_COPY_UP_REWARD_REPLY(self,_ackMsg)
	self.view:getRewardCallBack()
end

function CopySaoDaoMediator.ACK_COPY_COPY_DATA(self,_ackMsg)
	for i=1,#_ackMsg.copy_one_data do
		if _ackMsg.copy_one_data[i].copy_id==self.view.m_copyId then
			self.view:updateSurplusTimes(_ackMsg.times_all-_ackMsg.times)
			return
		end
	end
end

return CopySaoDaoMediator

