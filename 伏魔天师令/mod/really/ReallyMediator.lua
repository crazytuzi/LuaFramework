local ReallyMediator = classGc(mediator, function(self, _view)
    self.name = "ReallyMediator"
    self.view = _view

    self:regSelf()
end)

ReallyMediator.protocolsList={
    _G.Msg["ACK_WING_RIDE_BACK"],
    _G.Msg["ACK_WING_REPLAY"],
    _G.Msg["ACK_WING_CUL_RESULT"],
    _G.Msg["ACK_WING_ACTIVATE_BACK"],
    _G.Msg["ACK_WING_JH_BACK"],
}

ReallyMediator.commandsList={
	CProxyUpdataCommand.TYPE,
}

function ReallyMediator.getView(self)
    return self.view
end

function ReallyMediator.processCommand(self, _command)
    if _command:getType() == 1111111 then
    	
    elseif _command:getType()==CProxyUpdataCommand.TYPE then
        self.view:bagGoodsUpdate()
    end
    return false
end

function ReallyMediator.ACK_WING_RIDE_BACK(self, _ackMsg)
    print("ACK_WING_RIDE_BACK ---> 穿戴|卸下成功")
    self:getView():setRole(_ackMsg.wing_id)
end

function ReallyMediator.ACK_WING_REPLAY(self, _ackMsg)
    print("ACK_WING_REPLAY",_ackMsg.uid,_ackMsg.pro,_ackMsg.wing_id,_ackMsg.count,_ackMsg.data,_ackMsg.counts,_ackMsg.datas)
    -- for k,v in pairs(_ackMsg.data) do
    --     print("sahdjkashjkhdsa",k,v.wing_id,_ackMsg.wing_id)
    -- end
    self:getView():setReallyData(_ackMsg.data,_ackMsg.wing_id,_ackMsg.datas,_ackMsg.dat)
end

function ReallyMediator.ACK_WING_CUL_RESULT(self, _ackMsg)
    print("ACK_WING_CUL_RESULT --->result ",_ackMsg.data)
    self:getView():setReallyCul(_ackMsg.data,_ackMsg.dat)
    _G.Util:playAudioEffect("ui_skill_upgrade")
    if _ackMsg.data~=nil then
        local property=_G.GPropertyProxy:getMainPlay()
        if property:getWingSkin()==_ackMsg.data.wing_id then
            property:setWingLv(_ackMsg.data.grade)
        end
    end
end

function ReallyMediator.ACK_WING_ACTIVATE_BACK(self)
    print("ACK_WING_ACTIVATE_BACK ----> 激活成功")
    self:getView():Wing_Succ()
end

function ReallyMediator.ACK_WING_JH_BACK(self,_ackMsg)
    print("ACK_WING_JH_BACK ----> 技能开启")
    self:getView():Skill_Succ(_ackMsg.data)
end

return ReallyMediator