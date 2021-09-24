local StriveMediator = classGc(mediator, function(self, _view)
    self.name = "StriveMediator"
    self.view = _view

    self:regSelf()
end)

StriveMediator.protocolsList={
    _G.Msg["ACK_WRESTLE_REPLY"],	   --三界争锋界面返回
    _G.Msg["ACK_WRESTLE_BOOK_SUCCESS"],--报名成功
}

StriveMediator.commandsList=nil

function StriveMediator.processCommand(self, _command)
end

function StriveMediator.ACK_WRESTLE_REPLY(self, _ackMsg)
    print( "-- ACK_WRESTLE_REPLY","   type: ",_ackMsg.type,_ackMsg.turn,_ackMsg.count)

    if _ackMsg.type == 1 then
    	self.view : initSignUp(_ackMsg)
    else
        self.view : __closeWindow()
    	_G.GLayerManager : startOpenLayer(_G.Cfg.UI_SubStriveView,nil,_ackMsg,nil,nil)
    end
end

function StriveMediator.ACK_WRESTLE_BOOK_SUCCESS( self,_ackMsg )
	self.view : updateBtnState()
end

return StriveMediator