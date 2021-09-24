local FriendViewMediator = classGc(mediator,function(self, _view)
	-- here??
	self.name = "FriendViewMediator"
	self.view = _view
	self:regSelf() 
end)

FriendViewMediator.commandsList = nil

FriendViewMediator.protocolsList = {
	_G.Msg.ACK_FRIEND_SEARCH_REPLY, 

	_G.Msg.ACK_FRIEND_BLESS_REPLY,
	_G.Msg.ACK_FRIEND_BLESS_FAIL,
	_G.Msg.ACK_FRIEND_BLESS_GET_REPLY,

	-- 4260 剩余次数
	_G.Msg.ACK_FRIEND_REMAIN_TIMES,


	_G.Msg.ACK_FRIEND_INFO,  
	_G.Msg.ACK_FRIEND_DEL_OK,  
	-- _G.Msg.ACK_FRIEND_ADD_NOTICE,  
	_G.Msg.ACK_FRIEND_ADD_SUCCESS, 
	_G.Msg.ACK_FRIEND_GET_FRIEND_CB,
	_G.Msg.ACK_FRIEND_TIMES_REPLY, --角标返回

	_G.Msg.ACK_WAR_PK_REPLY_SELF, --pk
}

function FriendViewMediator.ACK_FRIEND_REMAIN_TIMES( self, _ackMsg)
	print("4260 -get-->",_ackMsg.times)
	self:getView():setLeftTime(_ackMsg.times)
end

function FriendViewMediator.ACK_FRIEND_INFO( self, _ackMsg)
	gcprint("ACK_FRIEND_INFO2 --->",_ackMsg.type)
    self:getView():updatedata(_ackMsg.type)
end

function FriendViewMediator.ACK_FRIEND_DEL_OK(self, _ackMsg)
	gcprint("ACK_FRIEND_DEL_OK --->",_ackMsg.uid,_ackMsg.type)
	self:getView():tabOperate(_ackMsg.type,10,_ackMsg.uid)
end

function FriendViewMediator.ACK_FRIEND_ADD_SUCCESS(self,_ackMsg)
	print("ACK_FRIEND_ADD_SUCCESS -->",_ackMsg.uid,_ackMsg.type)
	if _ackMsg.type == 5 then 
		self:getView():tabOperate(1,10,_ackMsg.uid)
	-- elseif _ackMsg.type == 1 then
	-- 	self:getView():tabOperate(3,10,_ackMsg.uid)
	else
		self:getView():returntabid(3,10,_ackMsg.uid)
	end
end

function FriendViewMediator.ACK_FRIEND_SEARCH_REPLY( self, _ackMsg)
	gcprint("ACK_FRIEND_SEARCH_REPLY --->",_ackMsg.count)
	self:getView():selectView(_ackMsg.data)
end

function FriendViewMediator.ACK_FRIEND_GET_FRIEND_CB( self, _ackMsg)
	gcprint("ACK_FRIEND_GET_FRIEND_CB --->",_ackMsg.count)
	self:getView():selectView(_ackMsg.msg_role_xxx)
end

function FriendViewMediator.ACK_FRIEND_BLESS_REPLY( self, _ackMsg)
	print("4215 -bless-->",_ackMsg.uid)
	self:getView():returntabid(1,10,_ackMsg.uid)
end
function FriendViewMediator.ACK_FRIEND_BLESS_GET_REPLY( self, _ackMsg)
	print("4235 -get-->",_ackMsg.uid)
	self:getView():returntabid(4,10,_ackMsg.uid)
end

function FriendViewMediator.ACK_FRIEND_TIMES_REPLY( self, _ackMsg)
	print("ACK_FRIEND_TIMES_REPLY-->",_ackMsg.times2)
	self:getView():returnTimes(_ackMsg.times2)
end

function FriendViewMediator.ACK_WAR_PK_REPLY_SELF(self,_ackMsg)
	if _ackMsg.type==0 then
		self:getView():__showWaitPKView()
	else
		local command=CErrorBoxCommand(_ackMsg.type)
		controller:sendCommand(command)
	end
end

return FriendViewMediator