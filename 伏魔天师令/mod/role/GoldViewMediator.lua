--属性面板--------------------------------------------------------------------------------------------------
local GoldViewMediator = classGc(mediator, function(self, _view)
    self.name = "GoldViewMediator"
    self.view = _view

    self:regSelf()
end)

GoldViewMediator.protocolsList={
    _G.Msg["ACK_MATRIX_REPLY"], -- 当前阵法信息
    _G.Msg["ACK_MATRIX_UP_GRADE_BACK"], -- 升阶返回
    _G.Msg["ACK_MATRIX_LIGHTS_OK"], -- 点亮节点
}
    

function GoldViewMediator.ACK_MATRIX_REPLY( self, _ackMsg)
    print("ACK_MATRIX_REPLY",_ackMsg.uid,_ackMsg.grade,_ackMsg.node,_ackMsg.stone)
    self : getView() : pushData(_ackMsg)
end

function GoldViewMediator.ACK_MATRIX_UP_GRADE_BACK( self, _ackMsg)

end

function GoldViewMediator.ACK_MATRIX_LIGHTS_OK( self, _ackMsg)
    print("ACK_MATRIX_LIGHTS_OK",_ackMsg.grade,_ackMsg.node,_ackMsg.stone)
    self : getView() : lightok(_ackMsg)
end

return GoldViewMediator