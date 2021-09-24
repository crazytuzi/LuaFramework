local NO_PRINT_MSG_ARRAY={
    [_G.Msg.ACK_WAR_PVP_TIME_BACK]=true,
    [_G.Msg.ACK_WAR_PVP_FRAME_MSG]=true,
}

local controlBase = classGc(function(self)
    self:unMediatorAll()
end)

local __TimeUtil=_G.TimeUtil

--注册协议
function controlBase.regMediatorMsg(self, mediator, protocolsList)
    if mediator==nil then return end

    local msgArray=protocolsList or mediator.protocolsList
    if msgArray~=nil and type(msgArray)=="table"  and #msgArray>0 then
        -- CCLOG("registerProtocol========>> mediator.name="..mediator.name)
        for _,msg in pairs(msgArray) do
            if self._msg[msg]==nil then
                self._msg[msg]=mediator
            else
                if self._msg[msg].protocolsList~=nil then
                    local oldMediator = self._msg[msg]
                    self._msg[msg]={}
                    self._msg[msg][oldMediator] = oldMediator
                    self._msg[msg][mediator]    = mediator
                else
                    self._msg[msg][mediator]    = mediator
                end
            end
        end
    end
end

--注册命令
function controlBase.regMediatorComm(self, mediator, commandsList)
    if mediator==nil then return end

    local comArray=commandsList or mediator.commandsList
    if comArray~=nil and type(comArray)=="table" and #comArray>0  then
        -- CCLOG("1commType=",commType)
        for _,commType in pairs(comArray) do
            -- CCLOG("registerCommand======>mediator.name="..mediator.name..",commType="..commType)
            if self._comm[commType]==nil then
                self._comm[commType]=mediator
            else
                if self._comm[commType].commandsList~=nil then
                    local oldMediator   = self._comm[commType]
                    self._comm[commType]= {}
                    self._comm[commType][oldMediator] = oldMediator
                    self._comm[commType][mediator]    = mediator
                else
                    self._comm[commType][mediator]    = mediator
                end
            end
        end
    end
end

function controlBase.regMediator(self, mediator, protocolsList, commandsList)
    if mediator==nil then
        GCLOG("ERROR registerMediator Mediator==nil||||||||||||||||||||||||||||||||||||||||>>")
        return 
    end
    GCLOG("registerMediator=======>"..mediator.name)
    self:regMediatorMsg(mediator,protocolsList)
    self:regMediatorComm(mediator,commandsList)
end

--------------------------------------------------------------------
--注册协议
function controlBase.regPMediatorMsg(self, mediator, protocolsList)
    if mediator==nil then return end

    local msgArray=protocolsList or mediator.protocolsList
    if msgArray~=nil and type(msgArray)=="table" and #msgArray>0 then
        -- CCLOG("registerLongMediatorProtocol========>> mediator.name="..mediator.name )
        for _,msg in pairs(msgArray) do
            if self._pmsg[msg]==nil then
                self._pmsg[msg]=mediator
            else
                if self._pmsg[msg].protocolsList~=nil then
                    local oldMediator = self._pmsg[msg]
                    self._pmsg[msg]   = {}
                    self._pmsg[msg][oldMediator]= oldMediator
                    self._pmsg[msg][mediator]   = mediator
                else
                    self._pmsg[msg][mediator]   = mediator
                end
            end
        end
    end
end

--注册命令
function controlBase.regPMediatorComm(self, mediator, commandsList)
    if mediator==nil then return end

    local comArray=commandsList or mediator.commandsList
    if comArray~=nil and type(comArray)=="table" and #comArray>0  then
        -- CCLOG("1commType=",commType)
        for _,commType in pairs(comArray) do
            -- CCLOG("registerLongMediatorCommand======>mediator.name="..mediator.name..",commType="..commType)
            if self._pcomm[commType]==nil then
                self._pcomm[commType]=mediator
            else
                if self._pcomm[commType].commandsList~=nil then
                    local oldMediator    = self._pcomm[commType]
                    self._pcomm[commType]= {}
                    self._pcomm[commType][oldMediator]= oldMediator
                    self._pcomm[commType][mediator]   = mediator
                else
                    self._pcomm[commType][mediator]   = mediator
                end
            end
        end
    end
end

function controlBase.regPMediator(self, mediator, protocolsList, commandsList)
    if mediator==nil then
        GCLOG("ERROR registerLongMediator Mediator==nil||||||||||||||||||||||||||||||||||||||||>>")
        return 
    end
    GCLOG("registerLongMediator=======>"..mediator.name)
    self:regPMediatorMsg(mediator,protocolsList)
    self:regPMediatorComm(mediator,commandsList)
end


function controlBase.unMediator(self, mediator, protocolsList, commandsList)
    if mediator==nil then 
        print("ERROR unregisterMediator Mediator==nil||||||||||||||||||||||||||||||||||||||||>>")
        return 
    end
    print("unregisterMediator=======>"..mediator.name,protocolsList,commandsList)
    
    local msgArray=protocolsList or mediator.protocolsList
    if msgArray~=nil and type(msgArray)=="table" then
        for _,msg in pairs(msgArray) do
            if self._msg[msg]~=nil then
                if self._msg[msg].protocolsList~=nil then
                    if mediator==self._msg[msg] then
                        self._msg[msg]=nil
                    end
                else
                    self._msg[msg][mediator]=nil
                    if next(self._msg[msg])==nil then
                        self._msg[msg]=nil
                    end
                end
            end
        end
    end
    
    local comArray=commandsList or mediator.commandsList
    if comArray~=nil and type(comArray)=="table" then
        for _,commType in pairs(comArray) do
            if self._comm[commType] ~= nil then
                if self._comm[commType].commandsList~=nil then
                    if self._comm[commType]==mediator then
                        self._comm[commType]=nil
                    end
                else
                    self._comm[commType][mediator]=nil
                    if next(self._comm[commType])==nil then
                        self._comm[commType]=nil
                    end
                end
            end
        end
    end
end

function controlBase.unPMediator(self, mediator)
    if mediator==nil then 
        GCLOG("ERROR unregisterMediator Mediator==nil||||||||||||||||||||||||||||||||||||||||>>")
        return 
    end
    GCLOG("unregisterMediator=======>"..mediator.name)
    
    if mediator.protocolsList~=nil and type(mediator.protocolsList)=="table" then
        for _,msg in pairs(mediator.protocolsList) do
            if self._pmsg[msg]~= nil then
                if self._pmsg[msg].protocolsList~=nil then
                    if mediator==self._pmsg[msg] then
                        self._pmsg[msg]=nil
                    end
                else
                    self._pmsg[msg][mediator]=nil
                    if next(self._pmsg[msg])==nil then
                        self._pmsg[msg]=nil
                    end
                end
            end
        end
    end
    
    if mediator.commandsList~=nil and type(mediator.commandsList)=="table" then
        for _,commType in pairs(mediator.commandsList) do
            if self._pcomm[commType] ~= nil then
                if self._pcomm[commType].commandsList~=nil then
                    if self._pcomm[commType]==mediator then
                        self._pcomm[commType]=nil
                    end
                else
                    self._pcomm[commType][mediator]=nil
                    if next(self._pcomm[commType])==nil then
                        self._pcomm[commType]=nil
                    end
                end
            end
        end
    end
end


function controlBase.unMediators(self)
    self._msg   = {}
    self._comm  = {}
end

function controlBase.unPMediators(self)
    GCLOG("unPMediators====>>>>")
    self._pmsg  = {}
    self._pcomm = {}
    if _G.Util~=nil then
        _G.Util:regLogMediatorAgain()
    end
end

function controlBase.unMediatorAll(self)
    GCLOG("unMediatorAll====>>>>")
    -- 一般mediator
    self._msg       = {}
    self._comm      = {}
    -- 长久mediator
    self._pmsg      = {}
    self._pcomm     = {}

    if _G.Util~=nil then
        _G.Util:regLogMediatorAgain()
    end
end

function controlBase.sendCommand(self, _comm)
    if not _comm.isCommand then
        GCLOG("ERROR 参数不是command||||||||||||||||||||||||||||||||||||||||>>")
        return
    end

    GCLOG("••••••••••>>sendCommand  ".._comm.type)
    local hasListen    = nil
    local commMediator = self._pcomm[_comm.type]
    if commMediator~=nil then
        if commMediator.commandsList~=nil then
            if commMediator.processCommand~=nil then
                GCLOG("command派发成功===========>>"..commMediator.name..".".._comm.type)
                commMediator:processCommand(_comm)
            else
                GCLOG("ERROR "..commMediator.name.."没有实现processCommand方法||||||||||||||||||||||||||||||||||||||||>>")
            end
        else
            for _,commandMediator in pairs(commMediator) do
                if commandMediator.processCommand~=nil then
                    GCLOG("command派发成功===========>>"..commandMediator.name..".".._comm.type)
                    commandMediator:processCommand(_comm)
                else
                    GCLOG("ERROR "..commandMediator.name.."没有实现processCommand方法||||||||||||||||||||||||||||||||||||||||>>")
                end
            end
        end
        hasListen = true
    end
    
    local commMediator = self._comm[_comm.type]
    if commMediator~=nil then
        if commMediator.commandsList~=nil then
            if commMediator.processCommand~=nil then
                GCLOG("command派发成功===========>>"..commMediator.name..".".._comm.type)
                commMediator:processCommand(_comm)
            else
                GCLOG("ERROR "..commMediator.name.."没有实现processCommand方法||||||||||||||||||||||||||||||||||||||||>>")
            end
        else
            for _,commandMediator in pairs(commMediator) do
                if commandMediator.processCommand~=nil then
                    GCLOG("command派发成功===========>>"..commandMediator.name..".".._comm.type)
                    commandMediator:processCommand(_comm)
                else
                    GCLOG("ERROR "..commandMediator.name.."没有实现processCommand方法||||||||||||||||||||||||||||||||||||||||>>")
                end
            end
        end
        hasListen = true
    end
    if not hasListen then
        GCLOG("ERROR controller没有找到commMediator||||||||||||||||||||||||||||||||||||||||>>")
    end
end

local controller = classGc(controlBase,function(self)
    self:unMediatorAll()
    
    local function processMessage(eventType, ackMessage)
        if eventType=="DISCONNECT_MESSAGE" then
            local com=CNetworkCommand(CNetworkCommand.ACT_DISCONNECT)
            self:sendCommand(com)
            
            self:connectServer()
        elseif eventType=="NETWORK_MESSAGE" then
            self:onNetworkMsg(ackMessage)
        end
    end
    
    self.m_isCanNotConnect     = nil
    -- self._timeout       = 0
    self.m_hasShortLink  = 0

    local handler = gc.ScriptHandlerControl:create(processMessage)
    gc.TcpClient:getInstance():registerScriptHandler(handler)

    if _G.SysInfo:isYayaImSupport() then
        local function processVoice(eventType,arg1,arg2,arg3)
            if eventType=="RECORD_SUCCESS" then
                local msgT={szUrl=arg1,szMean=arg2,second=arg3}
                local com=CVoiceCommand(CVoiceCommand.RECORD_SUCCESS)
                com.msgT=msgT
                self:sendCommand(com)
            elseif eventType=="PLAY_FINISH" then
                local com=CVoiceCommand(CVoiceCommand.PLAY_FINISH)
                self:sendCommand(com)
            elseif eventType=="ERROR_CPLOGIN" then
                print("【语音lua回调】===>>>>",eventType,arg1)
            elseif eventType=="ERROR_YYLOGIN" then
                print("【语音lua回调】===>>>>",eventType,arg1)
            end
        end
        local handler = gc.ScriptHandlerControl:create(processVoice)
        gc.VoiceManager:getInstance():registerScriptHandler(handler)
        -- gc.VoiceManager:getInstance():loginVoiceYY(1239238,"035453")
        -- gc.VoiceManager:getInstance():loginVoiceYY(123456,"123456")
        -- gc.VoiceManager:getInstance():loginVoiceCP("1239238")
    end
end)

function controller.stopConnect(self)
    self.m_isCanNotConnect=true
    self.m_isLongConnecting=nil

    if cc.Director:getInstance():getRunningScene():getChildByTag(888887) then
        cc.Director:getInstance():getRunningScene():removeChildByTag(888887)
    else
        _G.Util:hideOffLineLoadCir()
    end

    if _G.Network:isConnected() then
        _G.Network:disconnect()
    end
end

function controller.showExitGameNotic(self,_szNotic)
    self:stopConnect()
    ScenesManger.isExitGame=true

    local function exitGame()
        cc.Director:getInstance():endToLua()
    end

    local view=require("mod.general.TipsBox")()
    local layer=view:create(_szNotic,exitGame)
    view:setSureBtnText("退出")
    view:hideCancelBtn()

    local nowScene = cc.Director:getInstance():getRunningScene()
    nowScene:addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC+10)
end

-- 清除重连数据
function controller.connectDataClear(self)
    self.m_connectData=nil
    self.m_hasShortLink=0
    _G.Scheduler:unschedule(self.m_schedulerHandle)
    self.m_schedulerHandle=nil

    if not cc.Director:getInstance():getRunningScene():getChildByTag(888887) then
        self.m_isLongConnecting=nil
    end
end

-- 重连,外部调用重连
function controller.connectServer(self)
    -- do return end
    GCLOG("processCCNotificationCenterMessage=======================================>")
    if _G.GPropertyProxy:getMainPlay() == nil then
        _G.Util:hideOffLineLoadCir()
        return 
    end
    
    GCLOG("processCCNotificationCenterMessage=======================================>1")
    if self.m_isCanNotConnect==true or self.m_isLongConnecting then
        GCLOG("processCCNotificationCenterMessage=======================================>forbid")
        return
    end
    
    if self.m_connectData then
        GCLOG("processCCNotificationCenterMessage=======================================> had connected data")
        self:connectTipsShow()
        return
    end
    self.m_connectData={}
    
    if _G.g_Stage~=nil and self.m_aiState==nil then
        self.m_aiState=_G.g_Stage.m_stopAI
        _G.g_Stage.m_stopAI=true        
    end
    
    self:connectServerInside()
end

function controller.connectServerInside(self)
    GCLOG("controller.connectServerInside=======================================>1")
    
    if self.m_connectData==nil then
        self:connectTipsShow()
        return
    end
    
    self.m_hasShortLink=self.m_hasShortLink+1
    if self.m_hasShortLink<=4 then
        GCLOG("short connect================================>>>")
        self:onConnectionDisconnected()
        return
    end
    
    GCLOG("processCCNotificationCenterMessage long connect==============================>>>")
    
    if self.m_isLongConnecting then
        self:onConnectionDisconnected()
        return
    end
    self:connectTipsHide()
    self.m_isLongConnecting=true
    
    local function exitGame()
        cc.Director:getInstance():endToLua()
    end
    local function reConnect()
        self.m_isLongConnecting=nil
        self:connectDataClear()
        self:connectServer()
    end

    local view=require("mod.general.TipsBox")()
    local layer=view:create("与服务器已经断开连接请重新登录",reConnect,exitGame)
    view:setSureBtnText("重连")
    view:setCancelBtnText("退出")

    local nowScene = cc.Director:getInstance():getRunningScene()
    layer:setTag(888887)
    nowScene:addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC+10)

    if _G.g_Stage~=nil then
        _G.g_Stage:cancelJoyStickTouch()
    end
end

function controller.connectFinish(self)
    if _G.g_Stage~=nil then
        if self.m_aiState~=nil then
            _G.g_Stage.m_stopAI=self.m_aiState
            self.m_aiState=nil
        end
    end
    self.m_hasShortLink=0
    self:connectTipsHide()
    
    self.m_isLongConnecting=nil
    self.m_connectData=nil
end

-- 有重连数据,直接重连
function controller.connectServerTry(self)
    GCLOG("controller.connectServerTry=========>>")
    if self.m_isConnectServerTry then return end


    GCLOG("controller.connectServerTry  gc.TcpClient:getInstance():close()=========>>")

    if _G.Network:isConnected() then
        if __TimeUtil.m_beatCount<3 then
            self:connectFinish()
            return
        end
        gcprint("__TimeUtil.m_beatCount=",__TimeUtil.m_beatCount)
    end
    
    gc.TcpClient:getInstance():close()
    self.m_isConnectServerTry=true

    local lpHandler=nil
    local lpScheduler=cc.Director:getInstance():getScheduler()
    local function nConnect()
        self.m_isConnectServerTry=nil
        if lpHandler~=nil then
            lpScheduler:unscheduleScriptEntry(lpHandler)
            lpHandler=nil
        end
        if self.m_connectData==nil or self.m_connectData.jsonObj==nil then return end

        local jsonObj = self.m_connectData.jsonObj
        local ret     = _G.Network:connect(tostring(jsonObj.host),tonumber(jsonObj.port))
        if ret~=0 then
            local msg = REQ_ROLE_LOGIN()
            msg.uid = _G.SysInfo:getUid()  -- {用户ID}
            msg.uuid= _G.SysInfo:getUuid()  -- {用户UUID}
            msg.sid = _G.SysInfo:getSid()  -- {用户SID}
            msg.cid = _G.SysInfo:getCID()  -- {用户CID}
            msg.os  = _G.SysInfo:getOS()  -- {系统}
            msg.pwd = jsonObj.pwd  -- {密码}
            msg.versions = tonumber(_G.SysInfo.m_versionRes)  -- {版本号}
            msg.fcm_init = 0  -- {防沉迷(0:已解除 n>0:已在线时长)}
            msg.relink = true  -- {登录类型（true:短线重连 false:正常登录）}
            msg.hide=true
            msg.debug = false  -- {是否调试 （web:false fb:true）}
            msg.login_time = tonumber(jsonObj.login_time) -- {时间}
            _G.Network :send(msg)
            self:connectFinish()

            __TimeUtil.m_beatCount=0
        else
            local function onDelayConnect()
                self:connectServerTry()
            end
            _G.Scheduler:unschedule(self.m_schedulerHandle)
            self.m_schedulerHandle=_G.Scheduler:performWithDelay(4, onDelayConnect)
        end
    end

    lpHandler=lpScheduler:scheduleScriptFunc(nConnect, 0.2, false)
end




function controller.connectTipsShow(self)
    if self.m_isLongConnecting then return end
    _G.Util:showOffLineLoadCir()

    if _G.g_Stage~=nil then
        _G.g_Stage:cancelJoyStickTouch()
    end
end
function controller.connectTipsHide(self)
    -- print("CCCCCCCCCSSSSSSSSS=====>>>",_G.Network:isConnected(),debug.traceback())
    _G.Util:hideOffLineLoadCir()
end
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------

function controller.parse(self,_ackMessage,_cls)
    local cls=_G[_cls]
    if cls==nil then return end
    local ackMsg = cls()
    _ackMessage:resetStream()
    local reader = gc.MsgRead:create(_ackMessage:getStreamData())
    ackMsg:decode(reader)
    return ackMsg
end

local __Msg=_G.Msg
local __ACK_SYSTEM_TIME=__Msg.ACK_SYSTEM_TIME
local __ACK_SYSTEM_TIME_GM=__Msg.ACK_SYSTEM_TIME_GM
function controller.onNetworkMsg(self, ackMessage)
    local ackMsgId=ackMessage:getMsgID()
    local protocolFunctionKey=__Msg[ackMsgId]
    if protocolFunctionKey==nil then 
        GCLOG("lua ERROR 协议未定义||||||||||||||||||||||||||||||||||||||||>> ackMsgId=%d",ackMsgId)
        return 
    end

    local hasListen=nil
    local isParse=false
    local msgParse=nil
    local function l_parse()
        if isParse then
            return msgParse
        end
        isParse=true
        msgParse = self:parse(ackMessage,protocolFunctionKey)
        -- CCLOG("========================>>ackMessage parse!!!")
        return msgParse
    end

    if ackMsgId==__ACK_SYSTEM_TIME then
        local ackMsg=l_parse()
        __TimeUtil:ACK_SYSTEM_TIME(ackMsg)
        return
    elseif ackMsgId==__ACK_SYSTEM_TIME_GM then
        local ackMsg=l_parse()
        __TimeUtil:ACK_SYSTEM_TIME_GM(ackMsg)
        return
    end

    if not NO_PRINT_MSG_ARRAY[ackMsgId] then
        GCLOG("【SOCKET ACK】=============>>msgName="..protocolFunctionKey..",ackMsgID="..ackMsgId)
    end

    local protocolMediators = self._pmsg[ackMsgId]
    if protocolMediators~=nil then
        if protocolMediators.protocolsList~=nil then
            local protocolFunction=protocolMediators[protocolFunctionKey]
            if protocolFunction~=nil then
                local ackMsg=l_parse()
                protocolFunction(protocolMediators,ackMsg)
                if not NO_PRINT_MSG_ARRAY[ackMsgId] then
                    GCLOG("protocol派发成功===========>>"..protocolMediators.name.."."..protocolFunctionKey)
                end
            else
                GCLOG("ERROR Mediator协议方法未定义||||||||||||||||||||||||||||||||||||||||>>")
            end
            if not NO_PRINT_MSG_ARRAY[ackMsgId] then
                print("")
            end
        else
            local ackMsg=nil
            for _,protocolMediator in pairs(protocolMediators) do
                local protocolFunction=protocolMediator[protocolFunctionKey]
                if protocolFunction~=nil then
                    ackMsg=ackMsg or l_parse()
                    protocolFunction(protocolMediator,ackMsg)
                    if not NO_PRINT_MSG_ARRAY[ackMsgId] then
                        GCLOG("protocol派发成功===========>>"..protocolMediator.name.."."..protocolFunctionKey)
                    end
                else
                    GCLOG("ERROR Mediator协议方法未定义||||||||||||||||||||||||||||||||||||||||>>")
                end
                if not NO_PRINT_MSG_ARRAY[ackMsgId] then
                    print("")
                end
            end
        end
        hasListen=true
    end
    
    local protocolMediators = self._msg[ackMsgId]
    if protocolMediators~=nil then
        if protocolMediators.protocolsList~=nil then
            local protocolFunction=protocolMediators[protocolFunctionKey]
            if protocolFunction~=nil then
                local ackMsg=l_parse()
                protocolFunction(protocolMediators,ackMsg)
                if not NO_PRINT_MSG_ARRAY[ackMsgId] then
                    GCLOG("protocol派发成功===========>>"..protocolMediators.name.."."..protocolFunctionKey)
                end
            else
                GCLOG("ERROR Mediator协议方法未定义||||||||||||||||||||||||||||||||||||||||>>")
            end
            if not NO_PRINT_MSG_ARRAY[ackMsgId] then
                print("")
            end
        else
            local ackMsg=nil
            for _,protocolMediator in pairs(protocolMediators) do
                local protocolFunction=protocolMediator[protocolFunctionKey]
                if protocolFunction~=nil then
                    ackMsg=ackMsg or l_parse()
                    protocolFunction(protocolMediator,ackMsg)
                    if not NO_PRINT_MSG_ARRAY[ackMsgId] then
                        GCLOG("protocol派发成功===========>>"..protocolMediator.name.."."..protocolFunctionKey)
                    end
                else
                    GCLOG("ERROR Mediator协议方法未定义||||||||||||||||||||||||||||||||||||||||>>")
                end
                if not NO_PRINT_MSG_ARRAY[ackMsgId] then
                    print("")
                end
            end
        end
        
        hasListen=true
    end
    if not hasListen and not NO_PRINT_MSG_ARRAY[ackMsgId] then
        GCLOG("ERROR 未找到Mediator，被忽略||||||||||||||||||||||||||||||||||||||||>>")
    end
end

-- 获取重连数据
function controller.onConnectionDisconnected(self)
    GCLOG(" controller.onConnectionDisconnected================>>>1")
    if self.m_connectData==nil then

    elseif self.m_connectData.jsonObj~=nil then
        GCLOG("controller.onConnectionDisconnected================>>>已经获得重连接信息")
        self:connectServerTry()
        return
    end
    
    self:connectTipsShow()

    local szUrl=_G.SysInfo:urlLoginRelink()
    local szPostData=_G.SysInfo:urlLoginRelinkSignData()
    print("szUrl====>>"..szUrl)
    print("szPostData====>>"..szPostData)

    local xhrRequest = cc.XMLHttpRequest:new()
    xhrRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhrRequest:open("POST", szUrl)

    local function http_res()
        if self.m_connectData==nil then return end

        if xhrRequest.readyState==4 and (xhrRequest.status>=200 and xhrRequest.status<207) then
            local response = xhrRequest.response
            local jsonObj = json.decode(response,1)
            print("http_res response="..response)

            if jsonObj.ref==1 then
                self.m_connectData.jsonObj=jsonObj
                self:connectServerTry()
                return
            else
                -- CCMessageBox(jsonObj.msg or "请求重连数据失败","Error"..tostring(jsonObj.error))
                gcprint("codeError!!!! from command "..tostring(jsonObj.error))
                -- _G.Util:showTipsBox(string.format("重连失败:%s(%d)",jsonObj.msg,jsonObj.error))
            end
        else
            local szMsg=string.format("网络异常,请检查网络")
            gcprint("codeError!!!! ",szMsg)
            CCMessageBox(szMsg,"网络")
            -- _G.Util:showTipsBox()
        end

        local function onDelayConnect()
            self:connectServerInside()
        end
        _G.Scheduler:unschedule(self.m_schedulerHandle)
        self.m_schedulerHandle=_G.Scheduler:performWithDelay(3, onDelayConnect)
    end
    
    xhrRequest:registerScriptHandler(http_res)
    xhrRequest:send(szPostData)

    GCLOG(" controller.onConnectionDisconnected================>>>2")
end

return controller