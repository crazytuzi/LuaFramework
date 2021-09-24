require("cfg.Msg")
-- require("net.voMsgAsync")
-- require "model/VO_NetworkAsyncObject"
require("cfg.MsgAck")
require("cfg.MsgReq")

local Network=classGc()

function Network.connect(self, ip, port )
    print("Network.connect  ip=",ip,"port=",port)

    _G.SysInfo:setSid(_G.GLoginPoxy:getServerId())
    _G.SysInfo:setUid(_G.GLoginPoxy:getUid())

    local ret=gc.TcpClient:getInstance():connect(ip, port)
    if ret==_G.Const.kSocketConnectSuccess then
        _G.TimeUtil:setIsHeartBeat(true)
    end
    return ret
end

function Network.disconnect(self)
    print("disconnect=====>>>>>>>9999999 \n",debug.traceback())
    gc.TcpClient:getInstance():close()
    _G.TimeUtil:setIsHeartBeat(false)
    _G.SysInfo:setSid(0)
    _G.SysInfo:setUid(0)
end

function Network.isConnected(self)
    return gc.TcpClient:getInstance():isConnected()
end

function Network.setHandleAckCountOneTimes(self,_count)
    if gc.TcpClient.setHandleAckCountOneTimes then
        gc.TcpClient:getInstance():setHandleAckCountOneTimes(_count)
    end
end

local NOT_PRINT_ARRAY={
    [_G.Msg.REQ_SYSTEM_HEART]=true,
    [_G.Msg.REQ_SCENE_MOVE]=true,
    [_G.Msg.REQ_WAR_PVP_TIME]=true,
    [_G.Msg.REQ_WAR_PVP_STATE_UPLOAD]=true
}
function Network.send(self, reqMsg)
    if reqMsg.MsgID~=nil then
        local req    = gc.ReqMessage:create(reqMsg.MsgID)--(reqMsg.MsgID)
        local data   = req:getStreamData()
        local writer = gc.MsgWrite:create(data,false)
        req:serialize(writer)
        reqMsg:encode(writer)
        req:setLength(writer:getPosition())
        gc.TcpClient:getInstance():send(req)

        local szMsg=string.format("【SOCKET REQ】requestMsgName=%s,,msgId=%d",_G.Msg[reqMsg.MsgID],reqMsg.MsgID)
        if not NOT_PRINT_ARRAY[reqMsg.MsgID] then
            gcprint(szMsg)
        -- else
        --     print(szMsg)
        end
    else
        gcprint("【SOCKET REQ】        error!! not base class!")
    end
    -- if not self:isConnected() then
    --     gcprint("Network.send not self:isConnected()=====================>>>>")
    --     _G.controller:connectServer()
    -- end
end

return Network
