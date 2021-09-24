-- 时间TimeUtil
local TimeUtil = classGc(function(self)
    if self.m_dateTime==nil then
        self.m_dateTime=gc.DateTime:create()
        self.m_dateTime:retain()
    end

    self.m_dateTime:reset()
    self.m_clientSeconds=self.m_dateTime:getTotalSeconds() --客户端时间(秒)
    self.m_clientMilliSeconds=0 --客户端毫秒
    self.m_totalSeconds=0--实际时间
    self.m_microSeconds=0--实际微秒；[计量] 一百万分之一秒
    self.m_milliSeconds=0--实际毫秒；千分之一秒

    self.m_isHeart=false

    self.m_beatCount=0
    self.m_addClientSeconds=0
    self.m_addServerSeconds=0
    self:initServerAdjust()
    self:reset()

    self.m_timeReqMsg=REQ_SYSTEM_HEART()
end)

function TimeUtil.initServerAdjust(self)
    self.m_lastHeartTime=0
    self.m_isAdjustServer=false
end

local _MATH_CEIL=math.ceil
function TimeUtil.reset(self)                        
    self.m_dateTime:reset()

    local curSeconds=self.m_dateTime:getTotalSeconds()
    if self.m_clientSeconds>curSeconds then
        self.m_addClientSeconds=self.m_addClientSeconds+self.m_clientSeconds-curSeconds
        print("TimeUtil   small====>>>>>",curSeconds,self.m_clientSeconds)
    elseif curSeconds-self.m_clientSeconds>2 then
        self:initServerAdjust()
        print("TimeUtil   big====>>>>>",curSeconds,self.m_clientSeconds)
    end

    local preTImes=self.m_totalSeconds
    self.m_clientSeconds=curSeconds
    self.m_totalSeconds=curSeconds+self.m_addClientSeconds+self.m_addServerSeconds
    self.m_microSeconds=self.m_dateTime:getMicroseconds()
    local tempMilli=_MATH_CEIL(self.m_microSeconds*0.001)
    self.m_clientMilliSeconds=self.m_clientSeconds*1000+tempMilli
    self.m_milliSeconds=self.m_totalSeconds*1000+tempMilli

    -- print("TimeUtil.reset==========>>>>>>>>>",tempMilli)
end
function TimeUtil.addBySecond(self,_second)
    self:reset()
    self:heartBeat(self.m_milliSeconds)
    return self.m_milliSeconds
end

function TimeUtil.getClientSeconds(self)
    return self.m_clientSeconds
end

function TimeUtil.getClientMilliSeconds(self)
    return self.m_clientMilliSeconds
end

function TimeUtil.getTotalSeconds(self)
    return self.m_totalSeconds
end

function TimeUtil.getMicroseconds(self)
    return self.m_microSeconds
end

function TimeUtil.getTotalMilliseconds(self)
    return self.m_milliSeconds
end

function TimeUtil.getNowSeconds(self)
    return self.m_totalSeconds
end

function TimeUtil.getNowMicroseconds(self)
    return self.m_microSeconds
end

function TimeUtil.getNowMilliseconds(self)
    return self.m_milliSeconds
end

function TimeUtil.getServerTimeSeconds(self)
    return self:getNowSeconds()
end

function TimeUtil.getServerTimeMilliseconds(self)
    return self:getNowMilliseconds()
end

function TimeUtil.setServerTime(self, value)
    if not self.m_isAdjustServer then
        self.m_addServerSeconds=0
        self:reset()
        self.m_addServerSeconds=value-self.m_totalSeconds
        self.m_isAdjustServer=true
        self:reset()
    end
end

function TimeUtil.setIsHeartBeat(self,_is)
    print("setIsHeartBeat============================>>>>>>>>")
    print(debug.traceback())
    self.m_isHeart=_is

    if _is then
        self.m_beatCount=0
        self.m_lastHeartTime=0
        self.m_addServerSeconds=0
        self.m_isAdjustServer=false
    end
end

local heartTime=_G.Const.CONST_INTERVAL_HEART
function TimeUtil.heartBeat(self,nowTime)
    if not self.m_isHeart then return end
    if nowTime-self.m_lastHeartTime<heartTime then
        -- print("heartBeat======>>>> no times")
        if nowTime<self.m_lastHeartTime then
            self.m_lastHeartTime=nowTime
        end
        return
    end
    self.m_lastHeartTime=nowTime
    if self.m_beatCount>3 then
        -- print("ServerTime.heartBeat=====>>")
        if self.m_beatCount%10==0 then
            _G.controller:connectDataClear()
        end
        _G.controller:connectServer()
    end
    
    _G.Network:send(self.m_timeReqMsg)
    self.m_beatCount=self.m_beatCount+1
    -- print("ServerTime.heartBeat self.m_beatCount=",self.m_beatCount)
end

function TimeUtil.ACK_SYSTEM_TIME(self,_ackMsg)
    -- print("==========>>>>>>>> ACK_SYSTEM_TIME, 501 !!!!",_ackMsg.srv_time)
    self:setServerTime(_ackMsg.srv_time)
    self.m_beatCount=0
end

function TimeUtil.ACK_SYSTEM_TIME_GM(self,_ackMsg)
    -- 修改服务器时间
    print("ACK_SYSTEM_TIME_GM",_ackMsg.srv_time)
    self:initServerAdjust()
    _G.GChatProxy:handleSystemNetworkMsg("他妹的!! 服务器时间被修改..........")
    local msg=REQ_CHAT_GM()
    msg:setArgs("@time")
    _G.Network:send(msg)

    local command=CErrorBoxCommand("服务器时间被修改")
    controller:sendCommand(command)
end
return TimeUtil
