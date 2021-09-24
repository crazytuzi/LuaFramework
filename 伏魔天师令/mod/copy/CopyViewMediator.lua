local CopyViewMediator = classGc(mediator, function(self, _view)
    self.name = "CopyViewMediator"
    self.view = _view
    self:regSelf()

    _G.GCopyProxy=_G.GCopyProxy or require("mod.copy.CopyProxy")()
end)

CopyViewMediator.protocolsList={
    _G.Msg.ACK_COPY_ALL_REPLY, -- (7014手动) -- [7014]请求所有通过副本返回 -- 副本 
    _G.Msg.ACK_COPY_CHAP_REPLY,
    _G.Msg.ACK_COPY_CHAP_RE_REP,

    _G.Msg.ACK_COPY_LOGIN_NOTICE, -- (7865手动) -- [7865]登陆提醒挂机 -- 副本 
    _G.Msg.ACK_COPY_COPY_OPEN_REPLY,

    _G.Msg.ACK_COPY_COPY_DATA,
}

CopyViewMediator.commandsList={
    CCopyMapCommand.TYPE,
    -- CGotoSceneCommand.TYPE,
    -- CPropertyCommand.TYPE
}

function CopyViewMediator.processCommand(self, _command)
    local commandType = _command :getType()
    if commandType == CCopyMapCommand.TYPE then
        local commandData = _command :getData()
        if commandData == CCopyMapCommand.HUANGUP_END1 then
            --挂机关闭
        --     self.view:copyMopFinish(false)
        -- elseif commandData == CCopyMapCommand.HUANGUP_END2 then
        --     self.view:copyMopFinish(true,_command.copyId)
        elseif commandData == CCopyMapCommand.HUANGUP_END3 then
            self.view:closeWindow()
        elseif commandData == CCopyMapCommand.COPYINFO_CLOSE then
            self.view:copyInfoViewClose()
        end
    -- elseif commandType == CPropertyCommand.TYPE then
    --     if _command :getData() == CPropertyCommand.ENERGY then
    --         self.view:updateTimesLabel()
    --     end
    -- elseif commandType == CGotoSceneCommand.TYPE then
    --     self.view:removeCopyTips()
    --     _G.g_CCopyMapLayer = nil
    --     controller :unregisterMediator( self )
    end
end

-- (7014手动) -- [7014]请求所有通过副本返回 -- 副本 
function CopyViewMediator.ACK_COPY_ALL_REPLY( self, _ackMsg)
	print("------->>>>CopyViewMediator.ACK_COPY_ALL_REPLY,",#_ackMsg.chap_data)

    local newData=_ackMsg.chap_data

    local function sort(v1,v2)
        return v1.chap_id<v2.chap_id
    end
    table.sort(newData,sort)

    for i=1,#newData do
        print(i,newData[i].chap_id)
    end

    self.view:copyChapBack(newData)
end

function CopyViewMediator.ACK_COPY_CHAP_REPLY(self,_ackMsg)
    _ackMsg.msg_xxx.box_idx=_ackMsg.box_idx
    self.view:copyChapMsgBack(_ackMsg.chap_id,_ackMsg.msg_xxx)
end
function CopyViewMediator.ACK_COPY_COPY_DATA(self,_ackMsg)
    self.view:updateCopyMsg(_ackMsg)
end

function CopyViewMediator.ACK_COPY_CHAP_RE_REP(self,_ackMsg)
    for k,v in pairs(_ackMsg) do
        print(k,v)
    end
    self.view:getRewardBack(_ackMsg)
end


function CopyViewMediator.ACK_COPY_LOGIN_NOTICE(self,_ackMsg)
    if self.m_isNoFirstCome==true then return end
    self.m_isNoFirstCome=true

    _G.Util:hideLoadCir()
    
    for k,v in pairs(_ackMsg) do
        print(k,v)
    end
    
    self.view:showOffLineMop(_ackMsg)
end

function CopyViewMediator.ACK_COPY_COPY_OPEN_REPLY(self,_ackMsg)
    self.view:ACK_COPY_COPY_OPEN_REPLY(_ackMsg)
end

return CopyViewMediator
