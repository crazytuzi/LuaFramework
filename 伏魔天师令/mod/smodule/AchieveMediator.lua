AchieveMediator = classGc( mediator, function( self, _view )
          self.name = "AchieveMediator"
          self.view = _view
          self : regSelf()
end)

AchieveMediator.protocolsList={
    _G.Msg.ACK_ACHIEVE_ANS_POINT,    -- 角标数值返回
    _G.Msg.ACK_ACHIEVE_RELPY,        -- 成就数据返回
}   

AchieveMediator.commandsList={
    -- CloseWindowCommand.TYPE,
}

-- function AchieveMediator.processCommand( self, _command )
--     local commamdData=_command:getData()
    -- if commamdData==_G.Const.CONST_FUNC_OPEN_REBATE then
    --     self : getView() : CloseWindow()
    -- end
-- end

function AchieveMediator.ACK_ACHIEVE_ANS_POINT( self, _ackMsg )
    print("ACK_ACHIEVE_ANS_POINT", _ackMsg.count,_ackMsg.msg_xxx)
    self : getView() : LeftBtnView(_ackMsg.count,_ackMsg.msg_xxx)
end

function AchieveMediator.ACK_ACHIEVE_RELPY( self, _ackMsg )
    print("ACK_ACHIEVE_RELPY", _ackMsg.count,_ackMsg.data)
    self : getView() : pushData(_ackMsg)
end

return AchieveMediator