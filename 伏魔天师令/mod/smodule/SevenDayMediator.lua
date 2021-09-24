local SevenDayMediator = classGc(mediator,function(self, _view)
	self.name = "SevenDayMediator"
	self.view = _view
	self:regSelf() 
end)

SevenDayMediator.protocolsList={
	_G.Msg.ACK_OPEN_REPLY, 
	_G.Msg.ACK_OPEN_SERVER,
	_G.Msg.ACK_OPEN_ALLLOGO,
	_G.Msg.ACK_OPEN_OPEN_RANK,
	_G.Msg.ACK_OPEN_OPEN_GET_CB,
	_G.Msg.ACK_OPEN_DAY_CB,
	_G.Msg.ACK_SYSTEM_ERROR,
}

SevenDayMediator.commandsList = nil

function SevenDayMediator.ACK_OPEN_REPLY( self, _ackMsg )
	print( "接收到开服返回_16112！",_ackMsg.endtime)
	self : getView() : Net_Open_Reply( _ackMsg )
end

function SevenDayMediator.ACK_OPEN_SERVER( self, _ackMsg)
	print( "接收到服务器次数_16130！" )
	self : getView() : Net_Open_Server( _ackMsg )
end

function SevenDayMediator.ACK_OPEN_ALLLOGO( self , _ackMsg)
	print( "接收到返回所有类型上标次数_16142！" )
	self : getView() : Net_Open_Allloge( _ackMsg )
end


function SevenDayMediator.ACK_OPEN_OPEN_RANK( self, _ackMsg )
	print( "接收到排行榜_16160！" )
	self : getView() : Net_Open_Rank( _ackMsg )
end

function SevenDayMediator.ACK_OPEN_OPEN_GET_CB( self )
	self : getView() : Net_Open_Get_Cb()
end

function SevenDayMediator.ACK_OPEN_DAY_CB( self, _ackMsg )
	self : getView() : Net_Day_CB( _ackMsg )
end

function SevenDayMediator.ACK_SYSTEM_ERROR( self, _ackMsg )
	self : getView() : Net_SYSTEM_ERROR( _ackMsg )
end

return SevenDayMediator