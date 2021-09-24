local ChallengeMediator = classGc(mediator, function(self, _view)
    self.name = "ChallengeMediator"
    self.view = _view

    self:regSelf()
end)

ChallengeMediator.protocolsList={
    _G.Msg.ACK_XMZL_REPLY,
    _G.Msg.ACK_XMZL_WING_CHEER_REPLY,
    _G.Msg.ACK_WING_REPLAY,
    _G.Msg.ACK_XMZL_ATTR_POINT,
    _G.Msg.ACK_XMZL_ATTR_XXX,
    _G.Msg.ACK_XMZL_COPYS,
}

ChallengeMediator.commandsList=nil

function ChallengeMediator.ACK_XMZL_REPLY(self,_ackMsg)
    print("floor,hp,wing_id,attr_point,attr_point_all",
    _ackMsg.floor,_ackMsg.hp,_ackMsg.wing_id,_ackMsg.attr_point,_ackMsg.attr_point_all)
    self.view:msgCallBack(_ackMsg)
end

function ChallengeMediator.ACK_XMZL_WING_CHEER_REPLY(self,_ackMsg)
    print("ACK_XMZL_WING_CHEER_REPLY",_ackMsg.wing_id)
    self.view:WingReply(_ackMsg.wing_id)
end

function ChallengeMediator.ACK_WING_REPLAY(self,_ackMsg)
    print("ACK_WING_REPLAY",_ackMsg.data)
    self.view:WingTipsView(_ackMsg.data)
end

function ChallengeMediator.ACK_XMZL_ATTR_POINT(self,_ackMsg)
    print("ACK_XMZL_ATTR_POINT",_ackMsg.point,_ackMsg.point_all)
    self.view:AttrPoint(_ackMsg.point,_ackMsg.point_all)
end

function ChallengeMediator.ACK_XMZL_ATTR_XXX(self,_ackMsg)
    print("ACK_XMZL_ATTR_XXX",_ackMsg.type,_ackMsg.value)
    self.view:updateAttrData(_ackMsg.type,_ackMsg.value)
end

function ChallengeMediator.ACK_XMZL_COPYS(self,_ackMsg)
    print("ACK_XMZL_COPYS",_ackMsg.count,_ackMsg.msg_xxx)
    self.view:updateCopy(_ackMsg.msg_xxx)
end

return ChallengeMediator