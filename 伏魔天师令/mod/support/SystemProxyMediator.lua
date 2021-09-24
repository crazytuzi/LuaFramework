local SystemProxyMediator = classGc(mediator,function(self,_view)
    self.name="SystemProxyMediator"
    self.view=_view
    self:regSelfLong()
end)

SystemProxyMediator.protocolsList={
    _G.Msg.ACK_SYS_SET_TYPE_STATE,
    _G.Msg.ACK_WAR_PK_RECEIVE,
    _G.Msg.ACK_WAR_PK_CANCEL_REPLY,
}

SystemProxyMediator.commandsList=nil

function SystemProxyMediator.ACK_SYS_SET_TYPE_STATE( self, _ackMsg )
    local sysSettingList = _ackMsg.data

    --排序
    local function sortfunc( setting1, setting2)
        return setting1.type<setting2.type 
    end
    table.sort(sysSettingList,sortfunc)

    print("««««««««««系统设置««««««««««", _ackMsg.count )
    for i,v in ipairs(sysSettingList) do
        print("类型->"..v.type.."     状态->"..v.state)
    end
    print("«««««««««««««««««««««««««««")

    local preSetting=self.view.__settingArray

    self.view:setSysSettingList(sysSettingList)
    self.view:setInited(true)

    for i=1,#sysSettingList do
        local sysData=sysSettingList[i]
        local sysType=sysData.type
        local sysState=sysData.state
        if preSetting[sysType]==nil or preSetting[sysType].state~=sysState then
            print("【系统设置】==============>>>>>>>>>>>>>>",sysType,sysState)
            self.view:handleTypeSetting(sysType)
        end
    end
end


function SystemProxyMediator.ACK_WAR_PK_RECEIVE(self,_ackMsg)
    self.view:addPKInvite(_ackMsg)
end
function SystemProxyMediator.ACK_WAR_PK_CANCEL_REPLY(self,_ackMsg)
    self.view:delPKInvite(_ackMsg.uid)
end

return SystemProxyMediator