local BagMediator = classGc(mediator, function(self, _view)
    self.name = "BagMediator"
    self.view = _view

    self:regSelf()
end)

BagMediator.protocolsList={
    _G.Msg["ACK_GOODS_P_EXP_OK"],
    _G.Msg["ACK_GOODS_HUAFEI_SUCCESS"],
    _G.Msg["ACK_MAKE_COMPOSE_OK"],
    _G.Msg["ACK_GOODS_SELL_OK"],
    _G.Msg["ACK_ROLE_CHANGE_PRO_REPLY"],
}

BagMediator.commandsList={
    CProxyUpdataCommand.TYPE,
    CloseWindowCommand.TYPE,
    BagOpenHCCommand.TYPE,
    CFunctionOpenCommand.TYPE
}

function BagMediator.processCommand(self, _command)
    print("背包接收到的命令-------",_command:getType())
    if _command:getType() == CProxyUpdataCommand.TYPE then
        print("命令 背包数据更新",CProxyUpdataCommand.TYPE)
        self :getView() :updateBagData()
    elseif _command :getType() == CloseWindowCommand.TYPE then
        if _command :getData() == _G.Const.CONST_FUNC_OPEN_BAG then
            self :getView() : closeViewByCommand()
        end
    elseif _command:getType() == BagOpenHCCommand.TYPE then
        self :getView() : OpenHeCheng()
    elseif _command:getType()==CFunctionOpenCommand.TYPE then
        if _command:getData()==CFunctionOpenCommand.TIMES_UPDATE then
            self.view:chuangIconNum(_command.sysId,_command.number)
        end
    end
    return false
end

function BagMediator.ACK_ROLE_CHANGE_PRO_REPLY(self)
    print( "转职成功")
    self:getView():TransferSuccess()
end

function BagMediator.ACK_GOODS_P_EXP_OK(self, _ackMsg)
    print( "-- [2081]伙伴经验丹使用成功 -- 物品/背包")
    -- self :getView() :setUsePExpOK()
end
function BagMediator.ACK_GOODS_HUAFEI_SUCCESS(self, _ackMsg)
    print( "-- [2097]使用充值卡成功 -- 物品/背包")
    -- local msg = _G.Language.ERROR_N[142]
    -- local command = CErrorBoxCommand( msg )
    -- controller :sendCommand( command ) 
end

function BagMediator.ACK_MAKE_COMPOSE_OK( self )
    self :getView() : heChengOK(true)
    -- self :getView() : HeChengSuccEffect()
end
function BagMediator.ACK_GOODS_SELL_OK( self )
    self :getView() : heChengOK(false)
end
return BagMediator