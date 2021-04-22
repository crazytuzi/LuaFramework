
local QClient = class("QClient")

local QTcpSocket = import(".QTcpSocket")
local QErrorInfo = import("..utils.QErrorInfo")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QNavigationController = import("..controllers.QNavigationController")
local QLogFile = import("..utils.QLogFile")
local QPayUtil = import("..utils.QPayUtil")
local QVIPUtil = import("..utils.QVIPUtil")
local QNotificationCenter = import("..controllers.QNotificationCenter")

local retry = 0 -- 缺省情况下不重试

local READ_TIME_OUT_DURATION = 25

QClient.PUSH_NOTIFICATION = "QCLIENT_PUSH_NOTIFICATION"

function QClient:ctor(host, port)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    self.websocket = nil

    self._isReady = false
    self._canSendRequest = false
    
    if NEW_TCP_SOCKET and MsgProcessHandler then
        local widgetClass = import(app.packageRoot .. ".network.QTcpSocketMultithreading")
        self._tcpsocket = widgetClass.new(host, port)
    else
        self._tcpsocket = QTcpSocket.new(host, port)
    end
    self._seq = 0

    self._readTimeoutHandle = nil

    self._sendList = {}
    self._pushReqList = {}

    self:pushReqRegister("USER_KICKED_OFFLINE", function ( ... )
        app:alert({content="您的帐号已在别处登录，请重新登录", title="系统提示", 
            callback=function(state)
                if state == ALERT_TYPE.CONFIRM then
                    app:logout()
                end
            end, isAnimation = false}, false, true)
    end)
end

function QClient:open(success, fail)
    self._tcpProxy = cc.EventProxy.new(self._tcpsocket)
    self._tcpProxy:addEventListener(self._tcpsocket.EVENT_START_CONNECT, handler(self, self._onStartConnect))
    self._tcpProxy:addEventListener(self._tcpsocket.EVENT_CONNECT_SUCCESS, handler(self, self._onConnectSuccess))
    self._tcpProxy:addEventListener(self._tcpsocket.EVENT_CONNECT_FAILED, handler(self, self._onConnectFailed))
    self._tcpProxy:addEventListener(self._tcpsocket.EVENT_CONNECT_CLOSE, handler(self, self._onConnectClose))
    self._tcpProxy:addEventListener(self._tcpsocket.EVENT_RECEIVE_PACKAGE, handler(self, self._onReceivePackage))

    self._connectSuccessCallback = success
    self._connectFaildCallback = fail
    self._tcpsocket:connect()
end

-- Reopen will happen when connection is lost or app enters foreground
-- If there is request left in the list, force relogin to prevent dirty data
function QClient:reopen(host, port, success, fail)
    if not self:sendListEmpty() then
        QLogFile:info("QClient: Send queue is not empty, reopen connection leads to relogin")
        self:printSendlist()
        self._alert = app:alert({content="与服务器断开连接！请重新登录", title="系统提示", 
            callback=function(state)
                if state == ALERT_TYPE.CONFIRM then
                    app:relogin()
                end
            end, isAnimation = false}, true, true)
    else
        -- When integrated with Delivery, no connection to 中心服, so we have to prevent reconnect in that stage
        if (host and host ~= "") or (self._tcpsocket:getHost() and self._tcpsocket:getHost() ~= "") then
            self._reconnecting = true
            if self._tcpProxy ~= nil then
                self:close()
            end

            if host ~= nil then self._tcpsocket:setHost(host) end
            if port ~= nil then self._tcpsocket:setPort(port) end

            QLogFile:debug(function ( ... )
                return string.format("QClient: start reconnecting to %s:%s", self._tcpsocket:getHost(), self._tcpsocket:getPort())
            end)
            self:open(success, fail)
            app:showLoading()    
        end
    end
end

function QClient:close()
    self._tcpsocket:disConnect()

    if self._tcpProxy ~= nil then
        self._tcpProxy:removeAllEventListeners()
        self._tcpProxy = nil
    end

    if self._readTimeoutHandle ~= nil then
        scheduler.unscheduleGlobal(self._readTimeoutHandle)
        self._readTimeoutHandle = nil
    end

    if self._connectionStatusScheduler ~= nil then
        scheduler.unscheduleGlobal(self._connectionStatusScheduler)
        self._connectionStatusScheduler = nil
    end

    self:removeAllEventListeners()
end

-- seq is used to identifiy the uniqueness of package per session
function QClient:seq( ... )
    self._seq = self._seq + 1
    return self._seq
end

function QClient:getSeq( ... )
    return self._seq
end

function QClient:resetSeq( ... )
    self._seq = 0
    return self._seq
end

--[[
服务器连接当前是否可用
--]]
function QClient:isReady()
    return self._isReady
end

function QClient:_onStartConnect()
    
end

-- 判断现在是否允许和服务器进行通讯
function QClient:isServerAuthorized( ... )
    return self._canSendRequest
end

-- 判断TCP连接状态，最好使用下面的checkConnection
function QClient:isConnected()
    return self._tcpsocket:getState() == self._tcpsocket.State_Connected
end

function QClient:checkConnection( ... )
    return self._tcpsocket:checkIfSocketIsConnected()
end

function QClient:_onConnectSuccess()
    app:hideLoading()
    self._isReady = true
    self._reconnecting = false
    self._connectionStatus = CCNetwork:getInternetConnectionStatus()

    if self._alert ~= nil then
        self._alert:close()
        self._alert = nil
    end
    if self._readTimeoutAlert ~= nil then
        self._readTimeoutAlert:close()
        self._readTimeoutAlert = nil
    end
    if self._authTimeoutHandle ~= nil then
        scheduler.unscheduleGlobal(self._authTimeoutHandle)
        self._authTimeoutHandle = nil
    end
    if self._authAlert ~= nil then
        self._authAlert:close()
        self._authAlert = nil
    end

    if remote.user.isLoginFrist == true then
        QLogFile:info("QClient: network connection is re-connected successfully")
        self:userAuthRequest(remote.user.session)
    else
        self._canSendRequest = true
        self:_resendPackages()
    end 

    if self._connectSuccessCallback ~= nil then
        self._connectSuccessCallback()
        self._connectSuccessCallback = nil
    end

    if self._connectionStatusScheduler ~= nil then
        scheduler.unscheduleGlobal(self._connectionStatusScheduler)
        self._connectionStatusScheduler = nil
    end

    self._connectionStatusScheduler = scheduler.scheduleGlobal(function ( ... )
            local status = CCNetwork:getInternetConnectionStatus()
            if self._connectionStatus ~= status then
                QLogFile:info(function ( ... )
                    return string.format("Current connection status changed from %s to %s. Reconnecting ...", self._connectionStatus, status)
                end)
                self._connectionStatus = status

                self:printSendlist()
                self:resetPackageNetworkState()
                self:reopen()
            end
        end, 1)
end

function QClient:_onConnectFailed()
    -- if remote.user.isLoginFrist == true then
    --     self:userAuthRequest(remote.user.session)
    -- end
    if self._connectFaildCallback ~= nil then
        self._connectFaildCallback()
    end
    QLogFile:info("QClient: network connection can't be established")
    app:hideLoading()
    self:showReconnect()
end

function QClient:showReconnect( ... )
    self._alert = app:alert({content="网络异常，请检查网络后重新连接", title="系统提示", btns={ALERT_BTN.BTN_OK, ALERT_BTN.BTN_CANCEL},
        btnDesc={"重新连接"},
        callback=function(state)
            if state == ALERT_TYPE.CONFIRM then
                app:showLoading()
                self._reconnecting = true
                self._tcpsocket:_close()
                self._tcpsocket:connect()
                self._alert = nil
            elseif state == ALERT_TYPE.CANCEL then
                app:relogin()
            end
        end, isAnimation = false}, false, true)
        -- self._alert = app:alert({content="网络异常，请检查网络后重新连接", title="系统提示", btnDesc={"重新连接"},
        --     callback=function(state)
        --         if state == ALERT_TYPE.CONFIRM then
        --             app:showLoading()
        --             self._tcpsocket:connect()
        --             self._alert = nil
        --         elseif state == ALERT_TYPE.CANCEL then
        --             app:relogin()
        --         end
        --     end, isAnimation = false}, true, true)
    -- self._readTimeoutAlert = app:alert({content="网络异常，请检查网络后重新连接", title="系统提示", 
    --     callback=function(state)
    --         if state == ALERT_TYPE.CONFIRM then
    --             app:showLoading()
    --             self._tcpsocket:_close()
    --             self._tcpsocket:connect()
    --             self:_resendPackages()
    --             self._readTimeoutAlert = nil
    --         elseif state == ALERT_TYPE.CANCEL then
    --             self:close()
    --             app:relogin()
    --         end
    --     end, btnDesc={"重新连接"}, isAnimation = false}, true, true)
    -- self._authAlert = app:alert({content="网络异常，请检查网络后重新连接", title="系统提示", 
    --     callback=function(state)
    --         if state == ALERT_TYPE.CONFIRM then
    --             app:showLoading()
    --             self._tcpsocket:connect()
    --             self._authAlert = nil
    --         elseif state == ALERT_TYPE.CANCEL then
    --             app:relogin()
    --         end
    --     end, btnDesc = {"重新连接"}, isAnimation = false}, true, true)
end

-- @qinyuanji, there are two cases connection closed: 1 - network issue, 2 - closed by server
-- For case 1, we reconnect by sending user_auth
-- For case 2, we log out
function QClient:_onConnectClose(event)
    if self._reconnecting then
        return
    end
    
    app:hideLoading()
    self._isReady = false
    self._canSendRequest = false

    if self._alert then
        app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TOP_CONTROLLER)
    end

    if self._connectionStatusScheduler ~= nil then
        scheduler.unscheduleGlobal(self._connectionStatusScheduler)
        self._connectionStatusScheduler = nil
    end

    if remote.user.isLoginFrist == true then
        if event.manually then 
            QLogFile:info("QClient: network connection is closed manually")
            if not self:sendListEmpty() then
                QLogFile:debug("QClient: network connection needs to reconnect automatically")
                
                self._sendList = {}
                app:showLoading()
                self._tcpsocket:connect()
                self._alert = nil
            end
        else
            if not self:sendListEmpty() then
                QLogFile:info("QClient: network connection is closed by server")
                self:printSendlist()
                self._alert = app:alert({content="与服务器断开连接！请重新登录", title="系统提示", 
                    callback=function(state)
                        if state == ALERT_TYPE.CONFIRM then
                            app:relogin()
                        end
                    end, isAnimation = false}, true, true)
            else
                QLogFile:info("QClient: network connection is closed by network issue")
                if (app.battle and not app.battle:isBattleEnded()) then
                    QLogFile:debug("QClient: battle is not over or server is in reconnecting state, don't pop up alert dialog")
                else
                    self:showReconnect()
                end
            end
        end
    end
end

-- If there is any request left in list
-- If request is sent in offline state, not regarded as a normal request
function QClient:sendListEmpty()
    for name, value in pairs(self._sendList) do
        for index, sentValue in pairs(value) do
            if sentValue.networkState then
                return false
            end
        end
    end
    return true
end

function QClient:resetPackageNetworkState()
    for name, value in pairs(self._sendList) do
        for index, sentValue in pairs(value) do
            sentValue.networkState = false
        end
    end
end

function QClient:_onReadTimeout()
    app:hideLoading()
    self:showReconnect()
end

function QClient:_onAuthTimeout()
    app:hideLoading()
    self:showReconnect()
end

function QClient:printSendlist()
    for name, value in pairs(self._sendList) do
        if table.nums(value) > 0 then
            for index, sendValue in pairs(value) do
                QLogFile:debug(function() return "QClient: print send request name " .. name .. " key " .. sendValue.key .. " netstate " .. tostring(sendValue.networkState) end)
            end
        end
    end
end

--[[
/**
 * 用户认证
 * ＃param avatar, 用户从头像组里选择一个
 * ＃return
 *      返回 avatar
 */
--]]
function QClient:userAuthRequest(session)
    app:showLoading()
    local name = "USER_AUTH"

    local resends = self._tcpsocket:getResendRequest()
    for _, sendData in pairs(resends) do
        if sendData ~= nil and sendData.name == "authRequest" then
            QLogFile:info(function () return "QClient: Package " .. sendData.name .. " is duplicate" end)
            return 
        end
    end

    local key = self:resetSeq()
    local userAuthRequest = {session = session}
    local request = {api = name, userAuthRequest = userAuthRequest}
    request.key = key

    if DEBUG_NETWORK == true then
        printInfoWithColor(PRINT_FRONT_COLOR_GREEN, nil, "add request:")
        printTableWithColor(PRINT_FRONT_COLOR_GREEN, nil, request, nil, nil, "DEBUG_NETWORK")
    end
    
    local buffer = app:getProtocol():encodeMessageToBuffer("cc.qidea.wow.protocol.Request", request)
    self._tcpsocket:addRequestToResend(buffer, "authRequest")

    QLogFile:debug("QClient: send USER_AUTH request")

    self._authTimeoutHandle = scheduler.performWithDelayGlobal(handler(self, QClient._onAuthTimeout), READ_TIME_OUT_DURATION)
end

function QClient:_handleErrorCode(error)
    QErrorInfo:handle(error)
end

--[[
  convert package table to bytearray and send to server
  @param1 api name
  @param2 {api = "CT_USER_CREATE", struct name = struct body}
  @param3 success call back function
  @param4 fail call back function
  @param5 show loading for ui
  @param6 can duplicate send
  @param7 can handler error
  @param8 does not have corresponding response, and no retry
]]
function QClient:requestPackageHandler(name, package, success, fail, isShow, isDuplicate, isHandlerError, ignoreResponse)
    if isShow == nil then 
        isShow = true 
    end
    if isHandlerError == nil then
        isHandlerError = true
    end

    if self._sendList[name] == nil then
        self._sendList[name] = {}
    end

    -- check the API is not sending
    if isDuplicate ~= true and table.nums(self._sendList[name]) > 0 and not ignoreResponse then
        QLogFile:info(function () return "QClient: Package " .. name .. " is duplicate" end)
        return
    end

    -- encode message
    local key = self:seq()
    package.key = key
    local buffer = app:getProtocol():encodeMessageToBuffer("cc.qidea.wow.protocol.Request", package)

    if DEBUG_NETWORK == true then
        printInfoWithColor(PRINT_FRONT_COLOR_GREEN, nil, "request:")
        printTableWithColor(PRINT_FRONT_COLOR_GREEN, nil, package, nil, nil, "DEBUG_NETWORK")
        --QLogFile:debug(package)
    end

    if not ignoreResponse then
        -- networkState is to indicate if this request is sent on network connected or disconnected
        -- If connected, network connection lost will re-login. If disconnected, reconnection is allowed --@qinyuanji
        table.insert(self._sendList[name], {api = name, key = key, package = package, sendTime = QUtility:getTime(), 
            isShow = isShow, fail = fail, success = success, networkState = self._canSendRequest, isHandlerError = isHandlerError})

        if not self._canSendRequest then
            app:showLoading()
            QLogFile:debug(function () return "QClient: Add package " .. name .. " key " .. key .. " when disconnected" end)
            self._tcpsocket:connect()
        else
            if isShow == true then
                app:showLoading()
            end
            QLogFile:debug(function () return "QClient: add package " .. name .. " key " .. key .. " when connected" end)

            -- send message
            self._tcpsocket:send(buffer)

            if self._readTimeoutHandle ~= nil then
                scheduler.unscheduleGlobal(self._readTimeoutHandle)
                self._readTimeoutHandle = nil
            end
            self._readTimeoutHandle = scheduler.performWithDelayGlobal(handler(self, QClient._onReadTimeout), READ_TIME_OUT_DURATION)
        end
    else
        -- send message
        self._tcpsocket:send(buffer)
        QLogFile:debug(function () return "QClient: add package " .. name .. " key " .. key .. " ignoring response" end)
    end
end

-- reset true is to reset key sequence
function QClient:_resendPackages(resetKey)
    local resent = false
    for name, value in pairs(self._sendList) do
        for index, sentValue in pairs(value) do
            -- send message
            if resetKey then 
                sentValue.key = self:seq() 
                sentValue.package.key = sentValue.key
            end
            sentValue.networkState = (self._canSendRequest and true or false)
            local buffer = app:getProtocol():encodeMessageToBuffer("cc.qidea.wow.protocol.Request", sentValue.package)
            local issucc = self._tcpsocket:send(buffer)
            if issucc then
                resent = true
            else
                self._tcpsocket:_close()
                self._tcpsocket:connect()
                return
            end

            QLogFile:info(function () return "Resend package " .. sentValue.api .. " key " .. sentValue.key .. " netstate " .. tostring(sentValue.networkState) end)
        end
    end

    if resent then
        if self._readTimeoutHandle ~= nil then
            scheduler.unscheduleGlobal(self._readTimeoutHandle)
            self._readTimeoutHandle = nil
        end
        self._readTimeoutHandle = scheduler.performWithDelayGlobal(handler(self, QClient._onReadTimeout), READ_TIME_OUT_DURATION)
    else
        app:hideLoading()
    end
end

--[[
    返回函数
]]
function QClient:_onReceivePackage(event)
    if event.name == self._tcpsocket.EVENT_RECEIVE_PACKAGE then
        local data = event.package
        -- assert(data ~= nil, " receive empty data")
        if data == nil then
            return
        end
        local response = app:getProtocol():decodeBufferToMessage("cc.qidea.wow.protocol.Response", data)
        if response == nil then
            -- local str = ""
            -- if self._sendList ~= nil then
            --     for key,_ in pairs(self._sendList) do
            --         str = str..key..", "
            --     end
            -- end
            -- assert(response, "receive unknow data, len is "..#data..", list: "..str)
            return
        end
        if DEBUG_NETWORK == true then
            printInfoWithColor(PRINT_FRONT_COLOR_GREEN, nil, "response:")
            printTableWithColor(PRINT_FRONT_COLOR_GREEN, nil, response, nil, nil, "DEBUG_NETWORK")
        end

        --转换Key
        self:covertFun(response)

        local sendData = nil
        for name, value in pairs(self._sendList) do
            if name == response.api and table.nums(value) > 0 then
                for index,sendValue in pairs(value) do
                    if sendValue.key == response.key then
                        sendData = sendValue
                        table.remove(value,index)
                    end
                end
            end
            if table.nums(value) == 0 then
                self._sendList[name] = nil
            end
        end

        if response.api == "SEND_TOKEN_CHANGE" then
            if response.tokenChangeResponse.changeValue and response.tokenChangeResponse.changeValue < 0 then
                app:tokenChangeEvent(GAME_EVENTS.GAME_EVENT_TOKEN_CONSUME, response.tokenChangeResponse.changeValue)
            end
        end

        if response.api == "USER_AUTH" then
            app:hideLoading()
            if self._authTimeoutHandle ~= nil then
                scheduler.unscheduleGlobal(self._authTimeoutHandle)
                self._authTimeoutHandle = nil
            end

            if response.error ~= "NO_ERROR" then
                QLogFile:info(function ( ... )
                    return string.format("QClient: USER_AUTH can't be validated. Error %s", tostring(response.error))
                end)
                self._alert = app:alert({content="与服务器断开连接！请重新登录", title="系统提示", 
                    comfirmBack=function(state)
                        if state == ALERT_TYPE.CONFIRM then
                            app:relogin()
                        end
                    end, isAnimation = false}, true, true)    
            else
                QLogFile:info(function() return string.format("QClient: USER_AUTH is validated, session %s", response.session or "") end)

                if response.staticVersion then
                    if ENABLE_VERSION_CHECK and app.packageVersion and app.packageVersion ~= response.staticVersion then
                        QLogFile:error(function ( ... )
                            return string.format("Version incompatible -- client: %s, server: %s", app.packageVersion, response.staticVersion)
                        end)

                        app:alert({content = "有新版本哦。更多精彩快来体验吧！", title = "系统提示", 
                                callback = function(state)
                                    if state == ALERT_TYPE.CONFIRM then
                                        app:relaunchGame(true)
                                    end
                                end, isAnimation = false}, true, true)   

                        return       
                    end
                end

                if response.session and remote.user then
                    remote.user.session = response.session
                end
                app:showLoading()
                self._canSendRequest = true
                self:_resendPackages(true)
            end

            return
        end

        -- Check if this response is paired with one request sent before
        if sendData then 
            --检查是否关闭转圈
            local isHide = true
            for name,value in pairs(self._sendList) do
                for _,sendValue in pairs(value) do
                    if sendValue.isShow == true then
                        isHide = false
                        break
                    end
                end
                if isHide == false then
                    break
                end
            end
            if isHide == true then
                app:hideLoading()
            end

            --更新时间
            if response.serverTime ~= nil then
                local sendTime = nil
                if sendData ~= nil then 
                    sendTime = sendData.sendTime
                end
                remote:updateServerTime(response.serverTime, sendTime)
            end

            --是否报错
            if response.error == "NO_ERROR" then
                QLogFile:debug(function() return string.format("QClient: Received a response key %s, api %s", response.key, response.api) end)
                remote:updateData(response)
                if sendData ~= nil and sendData.success ~= nil then
                    sendData.success(response)
                end
            else
                QLogFile:debug(function() return string.format("QClient: Received an error %s in response key %s, api %s", tostring(response.error), response.key, response.api) end)
                if sendData ~= nil and sendData.fail ~= nil then
                    sendData.fail(response)
                end
                if sendData.isHandlerError == true then
                    self:_handleErrorCode(response.error)
                end
            end

            if self._readTimeoutHandle ~= nil then
                scheduler.unscheduleGlobal(self._readTimeoutHandle)
                self._readTimeoutHandle = nil
            end
            local isReceiving = false
            for name,value in pairs(self._sendList) do
                if value and #value > 0 then
                    isReceiving = true
                    break
                end
            end
            if isReceiving == true then
                self._readTimeoutHandle = scheduler.performWithDelayGlobal(handler(self, QClient._onReadTimeout), READ_TIME_OUT_DURATION)
            end
        else
            -- This response might be duplicate or a push
            if response.key then
                if response.key <= self:getSeq() then
                    QLogFile:info(function () return string.format("QClient: Received a duplicate or ignore response key %s, api %s", response.key, response.api) end)
                else
                    QLogFile:error(function () return string.format("QClient: Received an invalid response key %s, api %s", response.key, response.api) end)
                end
            else
                -- This is a push
                QLogFile:debug(function () return string.format("QClient: Received a push, api %s", response.api) end)

                --校准本地serverTime时间
                if response.serverTime ~= nil then
                    remote:updateServerTime(response.serverTime, nil)
                end
                print("laytest 10005")
                remote:updateData(response)
                self:_pushReqProcess(response.api, response)

                self:dispatchEvent({name = QClient.PUSH_NOTIFICATION, data = response})
            end 
        end

        -- 不用中心服时间
        if response.api ~= "CT_USER_LOGIN" and response.serverTime ~= nil then
            remote:refreshUserTime(response.serverTime) --根据服务器时间进行整点刷新事件处理
        end
    end
end

-- This function is for registering push process
-- callback receive only one parameter - "data" as the push request body
function QClient:pushReqRegister(api, callback)
    assert(api, "api can't be nil")
    assert(type(api) == "string", "api can only be string")

    QLogFile:debug(function () return string.format("Registered a push %s, callback %s", api, tostring(callback)) end)
    self._pushReqList[api] = callback
end

function QClient:pushReqUnregister(api)
    self:pushReqRegister(api)
end

function QClient:_pushReqProcess(api, data)
    assert(api, "api can't be nil")
    assert(type(api) == "string", "api can only be string")
    assert(data, "push request body can't be nil")
    --尽量少改动 充值代码
    if api == "SEND_RECHARGE_SYNC" then
        if FinalSDK.getChannelID() == "28" then
            app:alert({content="恭喜您充值成功，如有问题请联系客服!",title="系统提示",callBack=nil,comfirmBack=nil})
        end
        if self._pushReqList[api] then
            self._pushReqList[api](data)
        else
            QPayUtil.successCallBackByOffine(data)
        end
    else
        if self._pushReqList[api] then
            self._pushReqList[api](data)
        else
            QLogFile:info(function () return "QClient: " .. api .. " doesn't have a corresponding process" end)
        end
    end

    
end

--[[
    转化指定的ID
]]
function QClient:covertFun(tbl)
    if tbl == nil or type(tbl) ~= "table" then
        return
    end
    for name,value in pairs(tbl) do
        if value ~= nil and type(value) == "table" then
            if name == "skills" then
            elseif name == "dungeons" then
                for _,value in pairs(tbl.dungeons) do
                    value.id = QStaticDatabase:sharedDatabase():convertDungeonID(value.id)
                end
            elseif name == "mapStars" then
                -- for _,value in pairs(tbl.mapStars) do
                --     value.mapId = QStaticDatabase:sharedDatabase():convertMapID(value.mapId)
                -- end           
            end
             self:covertFun(value)
        elseif name == "avatar" then
            tbl[name] = QStaticDatabase:sharedDatabase():convertUserIconToId(value)
        end
    end
end

--[[
估计的与服务器的时间差，做与服务器时间相关的倒计时需要加上改数值
当前时钟滞后服务器时间，该值为正，当前时钟快于服务器时间，改值为负
--]]
function QClient:timeAlign()
    return self.websocket:timeAlign()
end

------------------------------------<<<<<<<<<<<<protocol content>>>>>>>>>>>>--------------------------------
--[[
/**
 * 创建新用户
 * @param uname 新用户的用户名
 * @param password 新用户的密码
 * @param success 回调函数参数包含：data.ctUser datra.serverInfos
 * @param fail
 * @param status
 */
--]]
function QClient:ctUserCreate(uname, password, success, fail, status)
    if password == nil then
        printInfo("Password is nil");
        if fail then fail() end
        return
    end

    if app ~= nil then
        app:resetRemote()
    end

    local ctUserCreateRequest = {name = uname, password = crypto.md5(password), deviceId = QUtility:getAppUUID(), deviceType = INFO_PLATFORM, channel = CHANNEL_NAME}
    local request = {api = "CT_USER_CREATE", ctUserCreateRequest = ctUserCreateRequest}
    self:requestPackageHandler("CT_USER_CREATE", request, success, fail)
end

--[[
/**
 * 使用激活码创建新用户
 * @param uname 新用户的用户名
 * @param password 新用户的密码
 * @param activationCode 激活码
 * @param success 回调函数
 */
--]]
function QClient:ctUserCreateWithActivationCode(uname, password, activationCode, success, fail)
    if password == nil then
        printInfo("Password is nil");
        if fail then fail() end
        return
    end

    if app ~= nil then
        app:resetRemote()
    end

    local ctUserCreateRequest = {name = uname, password = crypto.md5(password), activationCode = activationCode, deviceId = QUtility:getAppUUID(), deviceType = INFO_PLATFORM, channel = CHANNEL_NAME}
    local request = {api = "CT_USER_CREATE", ctUserCreateRequest = ctUserCreateRequest}
    self:requestPackageHandler("CT_USER_CREATE", request, success, fail)
end

--[[
/**
 * 中心服登陆
 * @param uname
 * @param password
 * @param success 回调函数参数包含：data.ctUser
 * @param fail
 * @param status
 */
 --]]
function QClient:ctUserLogin(uname, password, deliveryName, channelID, success, fail, status)
    if password == nil then
        printInfo("Password is nil");
        if fail then fail() end
        return
    end

    local apiName = nil
    local request = nil
    -- if deliveryName == "youzu" then
    --     apiName = "CT_YOUZU_LOGIN"
    --     request = {api = apiName, ctYouzuLoginRequest = {userId = uname, osdkTicket = password, deviceId = FinalSDK.getDeviceUUID(), deviceType = INFO_PLATFORM} }

    -- else
        apiName = "CT_USER_LOGIN"
        request = {api = apiName, ctUserLoginRequest = {name = uname, password = tostring(password), deviceId = QUtility:getAppUUID(), deviceType = INFO_PLATFORM, channel = CHANNEL_NAME} }
        
    -- end

    self:requestPackageHandler(apiName, request, success, fail)
end


--[[
/**
 * 创建测试用户，用一个随机名字
 * @param success 回调函数参数包含：data.user
 * @param fail
 * @param status
 */
--]]
function QClient:userCreateForTest(success, fail, status)
    if app ~= nil then
        app:resetRemote()
    end

    self:ctUserCreate("" .. q.time(), "123456", success, fail)
end


function QClient:dldlUserLogin(env, zone, accessToken, success, fail, status)
    local m_channel = FinalSDK.getChannelID()
    local m_subChannel = FinalSDK.getSubChannelID()
    local idfa = ""
    if device.platform == "ios" then
        idfa = FinalSDK.getDeviceIDFA()
    elseif device.platform == "android" then
        idfa = FinalSDK.getDeviceIMEID()
    end
    local dldlUserLoginRequest = {deviceId = QUtility:getAppUUID(), deviceType = INFO_PLATFORM,deviceModel = INFO_SYSTEM_MODEL, 
                                channel = m_channel,subChannel = m_subChannel, zone = zone, accessToken = accessToken, pkg_mark = DL_CHANNEL_NUMBER, idfa = idfa}

    -- local sharedApplication = CCApplication:sharedApplication()
    -- local target = sharedApplication:getTargetPlatform()
    -- if target == kTargetAndroid and (ENVIRONMENT_NAME == "alpha" or ENVIRONMENT_NAME == "publish") then
    --     dldlUserLoginRequest.platId = "Mac"
    -- elseif target == kTargetAndroid then
    --     dldlUserLoginRequest.platId = "ANDROID"
    -- elseif target == kTargetIphone or target == kTargetIpad then
    --     dldlUserLoginRequest.platId = "IOS"
    -- end

    local request = {api = "DLDL_USER_LOGIN", dldlUserLoginRequest = dldlUserLoginRequest}
    self:requestPackageHandler("DLDL_USER_LOGIN", request, success, fail,nil,nil,false)
end

function QClient:dldlHxUserLogin(env, zone, accessToken, success, fail, status)
    local m_channel = FinalSDK.getChannelID()
    local m_subChannel = FinalSDK.getSubChannelID()
    if device.platform == "ios" then
        idfa = FinalSDK.getDeviceIDFA()
    elseif device.platform == "android" then
        idfa = FinalSDK.getDeviceIMEID()
    end
    local dldlUserLoginRequest = {deviceId = QUtility:getAppUUID(), deviceType = INFO_PLATFORM,deviceModel = INFO_SYSTEM_MODEL, 
                                channel = m_channel,subChannel = m_subChannel, zone = zone, accessToken = accessToken, pkg_mark = DL_CHANNEL_NUMBER, idfa = idfa}

    -- local sharedApplication = CCApplication:sharedApplication()
    -- local target = sharedApplication:getTargetPlatform()
    -- if target == kTargetAndroid and (ENVIRONMENT_NAME == "alpha" or ENVIRONMENT_NAME == "publish") then
    --     dldlUserLoginRequest.platId = "Mac"
    -- elseif target == kTargetAndroid then
    --     dldlUserLoginRequest.platId = "ANDROID"
    -- elseif target == kTargetIphone or target == kTargetIpad then
    --     dldlUserLoginRequest.platId = "IOS"
    -- end

    local request = {api = "DLDL_HX_USER_LOGIN", dldlUserLoginRequest = dldlUserLoginRequest}
    self:requestPackageHandler("DLDL_HX_USER_LOGIN", request, success, fail,nil,nil,false)
end

function QClient:dldHJUserLogin(env, zone, accessToken, success, fail, status)
    local m_channel = FinalSDK.getChannelID()
    local m_subChannel = FinalSDK.getSubChannelID()
    local default = ""
    local m_uid = FinalSDK.getAccoundID()
    if device.platform == "ios" then
        idfa = FinalSDK.getDeviceIDFA()
    elseif device.platform == "android" then
        idfa = FinalSDK.getDeviceIMEID()
    end
    local dldlUserLoginRequest = {deviceId = QUtility:getAppUUID(), deviceType = INFO_PLATFORM,deviceModel = INFO_SYSTEM_MODEL, 
                                channel = m_channel,subChannel = m_subChannel, zone = zone, accessToken = accessToken, pkg_mark = DL_CHANNEL_NUMBER, uid = m_uid, idfa = idfa}

    -- local sharedApplication = CCApplication:sharedApplication()
    -- local target = sharedApplication:getTargetPlatform()
    -- if target == kTargetAndroid and (ENVIRONMENT_NAME == "alpha" or ENVIRONMENT_NAME == "publish") then
    --     dldlUserLoginRequest.platId = "Mac"
    -- elseif target == kTargetAndroid then
    --     dldlUserLoginRequest.platId = "ANDROID"
    -- elseif target == kTargetIphone or target == kTargetIpad then
    --     dldlUserLoginRequest.platId = "IOS"
    -- end

    local request = {api = "DLDL_HJ_USER_LOGIN", dldlUserLoginRequest = dldlUserLoginRequest}
    self:requestPackageHandler("DLDL_HJ_USER_LOGIN", request, success, fail,nil,nil,false)
end

function QClient:userLogin(ctUserId, ctSessionId, env, zone, accessToken, success, fail, status)
    local userLoginRequest = {ctUserId = ctUserId, ctSessionId = ctSessionId, deviceId = QUtility:getAppUUID(), deviceType = INFO_PLATFORM, 
                                deviceModel = INFO_SYSTEM_MODEL, channel = CHANNEL_NAME, env = env, zone = zone, accessToken = accessToken,idfa = ""}

    -- local sharedApplication = CCApplication:sharedApplication()
    -- local target = sharedApplication:getTargetPlatform()
    -- if target == kTargetAndroid then
    --     userLoginRequest.platId = "ANDROID"
    -- elseif target == kTargetIphone or target == kTargetIpad then
    --     userLoginRequest.platId = "IOS"
    -- end

    local request = {api = "USER_LOGIN", userLoginRequest = userLoginRequest}
    self:requestPackageHandler("USER_LOGIN", request, success, fail,nil,nil,false)
end

--[[
/**
 * 修改用户昵称
 * ＃param nickname, 用户可以自己给顶一个昵称，或者空，我们会随机一个昵称出来
 * ＃return
 *      返回 nickname
 *           token
 */
--]]
function QClient:changeNickName(name, success, fail, status)
    local changeNicknameRequest = {nickname = name}
    local request = {api = "USER_NICKNAME", changeNicknameRequest = changeNicknameRequest}
    self:requestPackageHandler("USER_NICKNAME", request, success, fail)
end

--[[
/**
 * 修改用户头像
 * ＃param avatar, 用户从头像组里选择一个
 * ＃return
 *      返回 avatar
 */
--]]
function QClient:changeAvatar(newAvatar, title, success, fail, status)
    local changeAvatarRequest = {avatar = newAvatar, title = title}
    local request = {api = "USER_AVATAR", changeAvatarRequest = changeAvatarRequest}
    self:requestPackageHandler("USER_AVATAR", request, success, fail)
end

--[[
/**
 *  代币购买物品
 *  @param productId, 产品ID，
 *  @return 购买信息会在data.user中
 */
--]]
function QClient:buyProduct(productId, success, fail, status)
    local buyProductRequest = {productId = productId}
    local request = {api = "BUY_PRODUCT", buyProductRequest = buyProductRequest}
    self:requestPackageHandler("BUY_PRODUCT", request, success, fail)
end

--[[
/**
 * 购买体力
 * @param success 回调函数参数包含：data.user
 * @param fail
 * @param status
 */
--]]
function QClient:buyEnergy(count, isSecretary, success, fail, status)
    local buyEnergyRequest = {count = count, isSecretary = isSecretary}
    local request = {api = "BUY_ENERGY", buyEnergyRequest = buyEnergyRequest}
    self:requestPackageHandler("BUY_ENERGY", request, success, fail)
end

--[[
/**
 * 购买金魂币
 * @return 返回购买信息在data.user中
 */
--]]
function QClient:buyMoney(count, success, fail, status)
    if count == nil or count == 0 then count = 1 end
    local buyMoneyRequest = {count = count}
    local request = {api = "BUY_MONEY", buyMoneyRequest = buyMoneyRequest}
    self:requestPackageHandler("BUY_MONEY", request, success, fail, true, true)
end

--[[
/**
 * 获取指定商店信息
 * #param shopId, 商店ID
 * ＃return
 *      返回 stores
 */
--]]
function QClient:getStores(shopId, success, fail, status)
    local shopGetRequest = {shopId = shopId}
    local request = {api = "SHOP_GET", shopGetRequest = shopGetRequest}
    self:requestPackageHandler("SHOP_GET", request, success, fail, true, true)
end

--[[
/**
 * 购买一个物品
 * #param shopId, 商店ID
 * #param pos, 要购买的物品位置， 以 0 开始
 * #param itemId, 要购买的物品ID
 * #param count, 要购买的物品数量
 * #param buyCount, 购买的次数
 * ＃return
 */
--]]
function QClient:buyShopItem(shopId, pos, itemId, count, buyCount, success, fail, status)
    local shopBuyRequest = {shopId = shopId, pos = pos, itemId = itemId, count = count, buyCount = buyCount}
    local request = {api = "SHOP_BUY", shopBuyRequest = shopBuyRequest}
    self:requestPackageHandler("SHOP_BUY", request, success, fail)
end

--[[
/**
 * 刷新一个商店
 *  #param shopId, 商店Id
 *  #return
 *      stores, 对应的store更新
 *      token，扣完代币后台的代币数量
 */
--]]
function QClient:refreshShop(shopId, success, fail, status)
    local shopRefreshRequest = {shopId = shopId}
    local request = {api = "SHOP_REFRESH", shopRefreshRequest = shopRefreshRequest}
    self:requestPackageHandler("SHOP_REFRESH", request, success, fail)
end

--[[
/**
 * 设置自定义标识位
 * @return 参照 data.payloads
 */
--]]
function QClient:putFlag(key, value, success, fail, status)
    local payloadPutRequest = { key = key, value = value}
    local request = {api = "PAYLOAD_PUT", payloadPutRequest = payloadPutRequest}
    self:requestPackageHandler("PAYLOAD_PUT", request, success, fail, true, true)
end

--[[
/**
 * 获取自定义标识位
 * @return 参照 data.payloads
 */
--]]
function QClient:getFlag(key, success, fail, status)
    local payloadReadRequest = { key = key}
    local request = {api = "PAYLOAD_READ", payloadReadRequest = payloadReadRequest}
    self:requestPackageHandler("PAYLOAD_READ", request, success, fail)
end

--[[
/**
 * 开始打副本
 * required string dungeonId = 1;                                              // 开始
 * repeated string heros = 2;                                                  // 参与战斗的魂师
 * @param fail
 * @param status
 */
--]]
function QClient:dungeonFightStart(battleType,dungeonId, battleFormation, success, fail, status)
    dungeonId = QStaticDatabase:sharedDatabase():convertDungeonID(dungeonId)
    local fightStartRequest = {dungeonId = dungeonId}
    -- battleType = battleType, battleFormation = battleFormation, 
    local gfStartRequest = {battleType = battleType, battleFormation = battleFormation, fightStartRequest = fightStartRequest}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    self:requestPackageHandler("GLOBAL_FIGHT_START", request, success, fail)
    
end


function QClient:oneKeyChangeDefenseArmyRequest(battleType, battleFormationList,replayData, success, fail, status)
    local oneKeyChangeDefenseArmyRequest = {battleType = battleType }
    if replayData ~= nil then
        oneKeyChangeDefenseArmyRequest.replayData = replayData
    end
    
    local request = {api = "ONE_KEY_MODIFY_ARMY", oneKeyChangeDefenseArmyRequest = oneKeyChangeDefenseArmyRequest}
    local battleList = {"battleFormation" ,"battleFormation2","battleFormation3" }

    for i,v in ipairs(battleFormationList) do
        request[battleList[i]] = battleFormationList[i]
    end
    self:requestPackageHandler("ONE_KEY_MODIFY_ARMY", request, success, fail)
end

--[[
/**
 * 成功打过一个副本
    optional int64 start_at = 1 [default = 0];                                  // 打斗开始时间
    optional int64 end_at = 2 [default = 0];                                    // 打斗结束时间
    optional string dungeon_id = 3 [default = ""];                              // 打斗的关卡ID
    repeated MonsterStatus monsters = 4;                                        // 打斗中的怪物状态
    repeated HeroStatus heros = 5;                                              // 魂师状态
    repeated FightTime fight_times = 6;                                         // 战斗时间片段
    optional int32 completedId = 7                                              // 星星的具体结果，124进行位运算得知哪些星星已经获得
    optional string  fightReportData              = 9;                          // 战报内容
    optional string  fightersData                 = 10;                         // 战斗魂师数据信息
    optional int32 killEnemyCount = 11;                                         // 杀死怪物的数量(活动本使用)
    optional float bossMinimumHp = 12;                                          // Boss剩余血量百分比(活动本使用)<=1000
 */
--]]
function QClient:dungeonFightSucceed(battleType, battleLog, star, completedId, battleKey, killEnemyCount, bossMinimumHp, success, fail, status)
    battleLog.dungeonId = QStaticDatabase:sharedDatabase():convertDungeonID(battleLog.dungeonId)
    local fightSuccessRequest = {start_at = battleLog.startTime, end_at = battleLog.endTime, dungeon_id = battleLog.dungeonId, star = star, monsters = {}, damage = {damages = battleLog.verifyDamageInfos}, starPos = completedId}
    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)

    for _, state in pairs(battleLog.monsterState) do
        if state.create_time == nil or state.monsterIndex == nil then
        else
            local monster = {}
            monster.monster_id = state.actor_id
            monster.showed_at = state.create_time
            monster.died_at = state.dead_time
            monster.index = state.monsterIndex
            table.insert(fightSuccessRequest.monsters, monster)
        end
    end

    fightSuccessRequest.battleVerify = q.battleVerifyHandler(battleKey)
    fightSuccessRequest.killEnemyCount = killEnemyCount
    fightSuccessRequest.bossMinimumHp = bossMinimumHp

    local gfEndRequest = {battleType = battleType, battleVerify = fightSuccessRequest.battleVerify, isQuick = false, isWin = true, 
                            fightReportData = fightReportData, fightSuccessRequest = fightSuccessRequest}

    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}

    self:requestPackageHandler("GLOBAL_FIGHT_END", request, success, fail, false)
end

--[[
/**
 * api(408), 副本关卡战斗失败
 */
 ]]
function QClient:fightFailRequest(battleType, dungeonId, battleKey, success, fail, status)
    -- local dungeonType = remote.welfareInstance:getDungeonTypeByDungeonID(dungeonId)
    -- if dungeonType == DUNGEON_TYPE.WELFARE then
    --     api = "WELFARE_FIGHT_DUNGEON_FAIL"
    -- else
    --     api = "FIGHT_DUNGEON_FAIL"
    -- end
    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    local battleVerify = q.battleVerifyHandler(battleKey)
    dungeonId = QStaticDatabase:sharedDatabase():convertDungeonID(dungeonId)
    local fightFailRequest = {dungeonId = dungeonId}

    local gfEndRequest = {battleType = battleType, battleVerify = battleVerify, isQuick = false, isWin = false, fightReportData = fightReportData, fightFailRequest = fightFailRequest}
    local api = "GLOBAL_FIGHT_END"
    local request = {api = api, gfEndRequest = gfEndRequest}
    self:requestPackageHandler(api, request, success, fail)
end

--[[
/**
 * 成功扫荡一个副本
 * required string dungeonId = 1;                                            // 关卡ID
 * required int32  count = 2;                                                      // 扫荡次数
 * optional int32 itemId = 3;                                                      // 目标物品ID
 * optional int32 itemCount  = 4;                                              // 需要的物品数量（不是需要的物品总数量，值为：需求总数 － 现有数）
 * @param fail
 * @param status
 */
--]]
function QClient:dungeonFightQuick(battleType, dungeonId, count, itemId, itemCount, isSkip, battleFormation, success, fail, status)
    dungeonId = QStaticDatabase:sharedDatabase():convertDungeonID(dungeonId)
    local fightQuickRequest = {dungeonId = dungeonId, count = count, itemId = itemId, itemCount = itemCount}
    local gfQuickRequest = {battleType = battleType, fightQuickRequest = fightQuickRequest, isSkip = isSkip}
    local request = {api = "GLOBAL_FIGHT_QUICK", gfQuickRequest = gfQuickRequest, battleFormation = battleFormation}
    self:requestPackageHandler("GLOBAL_FIGHT_QUICK", request, success, fail)
end

--[[
    required int32 dungeonId = 1;                                                // 关卡ID
    required int32 count = 2;                                                    // 扫荡次数
    optional bool isSecretary = 2;                                                    // 小舞助手
]]
function QClient:fightActivityDungeonQuickRequest(battleType, dungeonId, count, isSecretary, success, fail, status)
    dungeonId = QStaticDatabase:sharedDatabase():convertDungeonID(dungeonId)
    local fightActivityDungeonQuickRequest = {dungeonId = dungeonId, count = count}
    local gfQuickRequest = {battleType = battleType, isSecretary = isSecretary, fightActivityDungeonQuickRequest = fightActivityDungeonQuickRequest}
    local request = {api = "GLOBAL_FIGHT_QUICK", gfQuickRequest = gfQuickRequest}
    self:requestPackageHandler("GLOBAL_FIGHT_QUICK", request, success, fail)
end

--[[
/**
 * 今日关卡次数重置
 * required string dungeonId = 1;                                              // 关卡ID
 */
--]]
function QClient:buyDungeonTicket(dungeonId, success, fail, status)
    dungeonId = QStaticDatabase:sharedDatabase():convertDungeonID(dungeonId)
    local fightDungeonResetRequest = {dungeonId = dungeonId}
    local request = {api = "FIGHT_DUNGEON_RESET", fightDungeonResetRequest = fightDungeonResetRequest}
    self:requestPackageHandler("FIGHT_DUNGEON_RESET", request, success, fail)
end

--[[
/**
 * 魂师重生
 * required string heroId = 1;                                              // 魂师ID
 */
--]]
function QClient:heroReborn(heroId, success, fail, status)
    local heroReturnRequest = {actorId = heroId}
    local request = {api = "HERO_RETURN", heroReturnRequest = heroReturnRequest}
    self:requestPackageHandler("HERO_RETURN", request, success, fail)
end

--[[
/**
 * 魂师回收
 * required string heroId = 1;                                              // 魂师ID
 */
--]]
function QClient:heroRecycle(heroId, success, fail, status)
    local heroRecoverRequest = {actorId = heroId}
    local request = {api = "HERO_RECOVER", heroRecoverRequest = heroRecoverRequest}
    self:requestPackageHandler("HERO_RECOVER", request, success, fail)
end

--[[
/**
 * 材料碎片回收
 * required int items = 1;                                                  // 物品列表
 * required int type = 1;                                                   // 材料类型(1材料，3碎片)
 */
--]]
function QClient:materialRecycle(items, type, success, fail, status)
    local itemRecoverRequest = {items = items, type = type}
    local request = {api = "ITEM_RECOVER", itemRecoverRequest = itemRecoverRequest}
    self:requestPackageHandler("ITEM_RECOVER", request, success, fail)
end

--[[
/**
 * 觉醒回收
 * required int items = 1;                                                  // 物品列表
 * required int type = 1;                                                   // 材料类型(1材料，3碎片)
 */
--]]
function QClient:enchantRecycle(items, success, fail, status)
    local luckyDrawEnchantRecoverRequest = {items = items}
    local request = {api = "LUCKY_DRAW_ENCHANT_RECOVER", luckyDrawEnchantRecoverRequest = luckyDrawEnchantRecoverRequest}
    self:requestPackageHandler("LUCKY_DRAW_ENCHANT_RECOVER", request, success, fail)
end

-- --[[
-- /**
--  * 宝石回收
--  * repeated string sid = 1;                                                     // 物品id
--  */
-- --]]
-- function QClient:gemRecycle(sid, success, fail, status)
--     local gemstoneRecoverRequest = {sid = sid}
--     local request = {api = "GEMSTONE_RECOVER", gemstoneRecoverRequest = gemstoneRecoverRequest}
--     self:requestPackageHandler("GEMSTONE_RECOVER", request, success, fail)
-- end

-- --[[
-- /**
--  * 宝石重生
--  * required int items = 1;                                                  // 物品列表
--  * required int type = 1;                                                   // 材料类型(1材料，3碎片)
--  */
-- --]]
-- function QClient:gemReborn(sid, success, fail, status)
--     local gemstoneReturnRequest = {sid = sid}
--     local request = {api = "GEMSTONE_RETURN", gemstoneReturnRequest = gemstoneReturnRequest}
--     self:requestPackageHandler("GEMSTONE_RETURN", request, success, fail)
-- end

--[[
/**
 * 魂师突破
 *  required string actorId = 1;                                                // 要突破的魂师actorId
 *  @success 成功回调 包含 data.heros 突破过的魂师
 */
--]]
function QClient:breakthrough(actorId, success, fail, status)
    local heroBreakthroughRequest = {actorId = actorId}
    local request = {api = "HERO_BREAKTHROUGH", heroBreakthroughRequest = heroBreakthroughRequest}
    self:requestPackageHandler("HERO_BREAKTHROUGH", request, success, fail)
end

--[[
    一键突破
]]
function QClient:heroBreakthroughOneKeyRequest(actorId, breaklv, success, fail)
    local heroBreakthroughOneKeyRequest = {actorId = actorId, breaklv = breaklv}
    local request = {api = "HERO_BREAKTHROUGH_ONEKEY", heroBreakthroughOneKeyRequest = heroBreakthroughOneKeyRequest}
    self:requestPackageHandler("HERO_BREAKTHROUGH_ONEKEY", request, success, fail)
end

--[[
/**
 * 魂师升星
 *  required string actorId = 1;                                                // 要进阶的魂师actorId
 *  @success 成功回调 包含 data.heros 进阶后的魂师 和 data.items 消耗物品后的状态
 */
--]]
function QClient:grade(actorId, items, success, fail, status)
    local heroGradeRequest = {actorId = actorId, items = items}
    local request = {api = "HERO_GRADE", heroGradeRequest = heroGradeRequest}
    self:requestPackageHandler("HERO_GRADE", request, success, fail)
end

--[[
/**
 * 神技进阶
 *  required string actorId = 1;                                                // 要进阶的魂师actorId
 *  optional int32 gradeLevel = 2;                                          //要升级到的星级
 *  @success 成功回调 包含 data.heros 进阶后的魂师 和 data.items 消耗物品后的状态
 */
--]]
function QClient:godSkillgrade(actorId, gradeLevel, success, fail, status)
    local heroGodSkillGradeRequest = {actorId = actorId, gradeLevel = gradeLevel}
    local request = {api = "HERO_GOD_SKILL_GRADE", heroGodSkillGradeRequest = heroGodSkillGradeRequest}
    self:requestPackageHandler("HERO_GOD_SKILL_GRADE", request, success, fail)
end
--[[
/**
 *  魂师升级
 *  required string actorId = 1;                                                // 要强化的魂师actorId
    required int32 itemId = 2;                                                  // 强化物品
    required int32 count = 3;                                                   // 物品数量
 *  @return 成功返回 魂师信息 data.heros ,被删除的魂师在 data.remoteHeros 中
 */
--]]
function QClient:intensify(actorId, itemPairs, success, fail, status)
    local heroIntensifyRequest = { actorId = actorId, itemPairs = itemPairs}
    local request = {api = "HERO_INTENSIFY", heroIntensifyRequest = heroIntensifyRequest}
    self:requestPackageHandler("HERO_INTENSIFY", request, success, fail, false, true)
end

--[[
/**
 * 召唤魂师
 * @return 参照 data.payloads
 */
--]]
function QClient:summonHero(actorId, success, fail, status)
    local heroSummonRequest = {actorId = actorId}
    local request = {api = "HERO_SUMMON", heroSummonRequest = heroSummonRequest}
    self:requestPackageHandler("HERO_SUMMON", request, success, fail)
end

--[[
/**
 * 魂师技能强化
 * 
    required int32 actorId = 1;                                                 // 要技能升级的魂师actorID
    required int32 slotId = 2;                                                  // 要升级的技能槽位置
 */
--]]
function QClient:improveSkill(actorId, heroSkill, success, fail, status)
    local heroSkillImproveRequest = { actorId = actorId, heroSkill = heroSkill }
    local request = {api = "HERO_SKILL_IMPROVE", heroSkillImproveRequest = heroSkillImproveRequest}
    self:requestPackageHandler("HERO_SKILL_IMPROVE", request, success, fail, false, true)
end

--[[
/**
 * 魂师所有技能强化
 * 
    optional int32 actorId = 1;         //要技能升级的英雄actorID
 */
--]]
function QClient:improveAllSkill(actorId, success, fail, status)
    local heroSkillOneKeyImproveRequest = { actorId = actorId }
    local request = {api = "HERO_SKILL_ONE_KEY_IMPROVE", heroSkillOneKeyImproveRequest = heroSkillOneKeyImproveRequest}
    self:requestPackageHandler("HERO_SKILL_ONE_KEY_IMPROVE", request, success, fail, false, true)
end

--[[
/**
 * 购买技能点数
 * @return 返回购买信息在data.user中
 */
--]]
function QClient:buySkillTicket(success, fail, status)
    local request = {api = "HERO_SKILL_TICKET_BUY"}
    self:requestPackageHandler("HERO_SKILL_TICKET_BUY", request, success, fail)
end

--[[
    给魂师使用道具
    required string actorId = 1;
    required int32 itemId = 2;
]] 
function QClient:useItemForHero(itemId, actorId, success, fail, status)
    local itemUse4HeroRequest = { actorId = actorId, itemId = itemId}
    local request = {api = "ITEM_USE_FOR_HERO", itemUse4HeroRequest = itemUse4HeroRequest}
    self:requestPackageHandler("ITEM_USE_FOR_HERO", request, success, fail, false, false)
end

--[[
/**
 * 魂师装备突破
 *  required int32 actorId = 1;
 *  required int32 itemId = 1;                                                  // 要合成的装备ID
 * @return money, heros（这个魂师最新状态), Items
 */
--]]
function QClient:heroEquipmentCraftRequest(actorId, itemId, success, fail)
    local heroEquipmentCraftRequest = {actorId = actorId, itemId = itemId}
    local request = {api = "HERO_EQUIPMENT_CRAFT", heroEquipmentCraftRequest = heroEquipmentCraftRequest}
    self:requestPackageHandler("HERO_EQUIPMENT_CRAFT", request, success, fail)
end

--[[
/**
 * 魂师装备合成
 *  required int32 itemId = 1;                                                  // 要合成的装备ID
 * @return money, heros（这个魂师最新状态), Items
 */
--]]
function QClient:itemCraftRequest(itemId, success, fail)
    local itemCraftRequest = {itemId = itemId}
    local request = {api = "ITEM_CRAFT", itemCraftRequest = itemCraftRequest}
    self:requestPackageHandler("ITEM_CRAFT", request, success, fail)
end

--[[
/**
 * 卖物品
 repeated Item items = 1;                                                    // 要出售的物品，包含要多少出售
 * @return 参照 data.items
 */
--]]
function QClient:sellItem(items, success, fail, status)
    local itemSellRequest = {items = items}
    local request = {api = "ITEM_SELL", itemSellRequest = itemSellRequest}
    self:requestPackageHandler("ITEM_SELL", request, success, fail)
end

--[[
/**
 * 打开礼包
 required int32 itemId = 1;
]]
function QClient:openItemPackage(itemId, count, success, fail, status)
    local remainingDays = 0
    local isYUEKA = false
    if itemId == 210001 then
        -- 普通月卡
        remainingDays = (remote.recharge.monthCard1EndTime/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/(DAY)
        isYUEKA = true
    elseif itemId == 210002 then
        -- 至尊月卡
        remainingDays = (remote.recharge.monthCard2EndTime/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/(DAY)
        isYUEKA = true
    end
    if isYUEKA then
        local maxDays = QStaticDatabase:sharedDatabase():getConfigurationValue("month_card_date")
        remainingDays = remainingDays - 1      --显示的时间比实际时间少一天
        if remainingDays >= maxDays then
            app.tip:floatTip(string.format("当前月卡剩余%d天，暂时无法使用道具", (remainingDays or 0)))
            return
        end
    end

    local lastRecharged = QVIPUtil:recharged()
    local lastVIPLevel = QVIPUtil:VIPLevel()
    local successCallback = function (data)
        if data.rechargeInfoResponse and data.rechargeInfoResponse.rechargeInfo then
            app.tip:floatTip("充值成功")
            local rechargeInfo = data.rechargeInfoResponse.rechargeInfo or {}
            remote.recharge = rechargeInfo
            local cash = rechargeInfo.cash or 0
            local cashType = rechargeInfo.cashType or 0
            local itemId = rechargeInfo.itemId or nil
            -- if not isYUEKA and QVIPUtil:recharged() == lastRecharged then
            --     -- 臨時處理一下, 如果使用道具之后，后端没有加（并且不是月卡道具）就前端自己加一下
            --     remote.user.totalRechargeToken = remote.user.totalRechargeToken + cash
            -- end
            print("[ITEM_OPEN]  ", QVIPUtil:recharged(), lastRecharged)
            if QVIPUtil:recharged() > lastRecharged  then
                QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.VIP_RECHARGED, amount = cash, type = cashType})
                remote.task:checkAllTask() -- Monthly recharge has a daily task, check it when recharged
                remote.activity:updateRechargeData(cash, cashType, itemId)
            end
            if QVIPUtil:VIPLevel() > lastVIPLevel then
                QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.VIP_LEVELUP})
            end

            -- 因為月卡道具不算單充和累充，所有充值之後 QVIPUtil:recharged() 不會變化，這個時候，需要單獨拉一下月基金的info，讓月基金可以即時更新
            if isYUEKA then
                if remote.activityMonthFund then
                    remote.activityMonthFund:getActivityInfo()
                end
                -- 拋出這個事件，主要是用於主界面頭像組件的月卡圖標的刷新。因為道具月卡，沒有token的事件推送過來。
                if remote.user then
                    remote.user:dispatchEvent({name = remote.user.EVENT_USER_PROP_CHANGE})
                end
            end  

            if success then
                success(data)
            end
        else
            if success then
                success(data)
            end
        end
    end

    local itemOpenRequest = {itemId = itemId, count = count}
    local request = {api = "ITEM_OPEN", itemOpenRequest = itemOpenRequest}
    self:requestPackageHandler("ITEM_OPEN", request, successCallback, fail)
end

--[[
/**
 * 觉醒
 actorId = 1
 itemId = 2
 repeated Item materials = 4;                                                    // 觉醒材料
 * @return 参照 data.items
 */
--]]
function QClient:enchant(actorId, itemId, success, fail, status)
    local enchantRequest = {actorId = actorId, itemId = itemId}
    local request = {api = "HERO_EQUIPMENT_ENCHANT", heroEquipmentEnchantRequest = enchantRequest}
    self:requestPackageHandler("HERO_EQUIPMENT_ENCHANT", request, success, fail)
end

--[[
  /**
   * 普通宝箱抽奖
    required bool isAdvance = 1;                                                // 是否是高级抽奖
    required int32 count = 2;                                                   // 抽奖次数, 必须为1或是10
   */
--]]
function QClient:luckyDraw(count, success, fail, status)
    local luckyDrawRequest = {isAdvance = false, count = count, isHalf = false}
    local request = {api = "LUCKY_DRAW", luckyDrawRequest = luckyDrawRequest}
    self:requestPackageHandler("LUCKY_DRAW", request, success, fail)
end

--[[
  /**
   *  黄金宝箱抽奖
    required bool isAdvance = 1;                                                // 是否是高级抽奖
    required int32 count = 2;                                                   // 抽奖次数, 必须为1或是10
   */
--]]
function QClient:luckyDrawAdvance(count, isHalf, success, fail, status)
    local luckyDrawRequest = {isAdvance = true, count = count, isHalf = isHalf or false}
    local request = {api = "LUCKY_DRAW", luckyDrawRequest = luckyDrawRequest}
    self:requestPackageHandler("LUCKY_DRAW", request, success, fail)
end

--[[
  /**
   * 酒馆买次数
    required int32 bullCount = 1;                                                // 购买的教皇令的舒凉，如果是10连购买，则必须是10的倍数
    required bool is10Buy = 2;                                                   // 是否为10连购买，10连购买享受9折优惠
   */
--]]
function QClient:luckyDrawBuyBull(bullCount, is10Buy, success, fail, status)
    local luckyDrawBuyBullRequest = {bullCount = bullCount, is10Buy = is10Buy}
    local request = {api = "LUCKY_DRAW_BUY_BULL", luckyDrawBuyBullRequest = luckyDrawBuyBullRequest}
    self:requestPackageHandler("LUCKY_DRAW_BUY_BULL", request, success, fail)
end

--[[
  /**
   * 章节星星抽奖
   *  required int32 index = 1;                                                   // 第几个心心抽奖
    required string mapId = 2;                                                  // 第几章节
   */
--]]
function QClient:luckyDrawMap(mapId, index, success, fail, status)
    -- mapId = QStaticDatabase:sharedDatabase():convertMapID(mapId)
    local luckyDrawMapRequest = { mapId = mapId, index = index}
    local request = {api = "LUCKY_DRAW_MAP", luckyDrawMapRequest = luckyDrawMapRequest}
    self:requestPackageHandler("LUCKY_DRAW_MAP", request, success, fail)
end

--[[
  /**
     * 每日任务完成
     required string task = 1;                                                   // 任务编号
     *
     */
--]]
function QClient:dailyTaskComplete(tasks, isOneKeyOpen, success, fail, status)
    local dailyTaskCompleteRequest = { tasks = tasks, isOneKeyOpen = isOneKeyOpen}
    for k,v in pairs(tasks) do
        if tostring(v) == "100000" or tostring(v) == "100001" or tostring(v) == "100002" then
            remote.user:addPropNumForKey("todaymealTimes")
        end
    end    
    local request = {api = "DAILY_TASK_COMPLETE", dailyTaskCompleteRequest = dailyTaskCompleteRequest}
    self:requestPackageHandler("DAILY_TASK_COMPLETE", request, success, fail)
end

--[[
  /**
     * 每日任务完成
     required string task = 1;                                                   // 任务编号
     *
     */
--]]
function QClient:dailyTaskCompleteByToken(tasks, success, fail, status)
    local dailyTaskCompleteRequest = { tasks = tasks}
    for k,v in pairs(tasks) do
        if tostring(v) == "100000" or tostring(v) == "100001" or tostring(v) == "100002" then
            remote.user:addPropNumForKey("todaymealTimes")
        end
    end

    local request = {api = "DAILY_TASK_COMPLETE_BY_TOKEN", dailyTaskCompleteRequest = dailyTaskCompleteRequest}
    self:requestPackageHandler("DAILY_TASK_COMPLETE_BY_TOKEN", request, success, fail)
end




--[[
  /**
     * 每周任务完成
     message WeekTaskCompleteRequest {
    optional int32 taskIndex = 1;   // 任务编号
    optional bool isOneKeyOpen = 2; // 是否是一键完成
    }
    一键完成 不需要传 taskIndex
    传 taskIndex 只完成一个任务
     *
     */
--]]
function QClient:weeklyTaskComplete(taskIndex, isOneKeyOpen, success, fail, status)
    local weekTaskCompleteRequest = { taskIndex = taskIndex, isOneKeyOpen = isOneKeyOpen}
    local request = {api = "WEEK_TASK_COMPLETE", weekTaskCompleteRequest = weekTaskCompleteRequest}
    self:requestPackageHandler("WEEK_TASK_COMPLETE", request, success, fail)
end

--[[
  /**
     * 成就完成
     required string achievementId = 1;                                          // 量表中的成就ID
     *
     */
--]]
function QClient:achieveComplete(achievementIds, success, fail, status)
    local achievementCompleteRequest = { achievementIds = achievementIds}
    local request = {api = "ACHIEVEMENT_COMPLETE", achievementCompleteRequest = achievementCompleteRequest}
    self:requestPackageHandler("ACHIEVEMENT_COMPLETE", request, success, fail)
end

--[[
/**  
* 使用cdkey兑换码, 使用完成后检查邮箱  
*  #param cdkey, 要使用的cdkey  
*  
*  #return  
*      "{}"  
*  
*/ 
--]]
function QClient:sendCdKey(cdKey, success, fail, status)
    local userRequest = {key = cdKey}
    userRequest["type"] = 0
    local request = {api = "CDKEY_USE", cdkeyUseRequest = userRequest}
    self:requestPackageHandler("CDKEY_USE", request, success, fail)
end

--[[
/**
 * 签到
 required int32 index = 1;                                                   // 签到的次数
 */
 --]]
function QClient:dailySignIn(index, success, fail, status)
    local checkInRequest = {index = index}
    local request = {api = "CHECK_IN", checkInRequest = checkInRequest}
    self:requestPackageHandler("CHECK_IN", request, success, fail)
end

--[[
/**
 * 累积签到
 required int32 index = 1;                                                   // 累计签到奖励次数
 */
 --]]
function QClient:addUpSignIn(index, success, fail, status)
    local checkInAwardRequest = {index = index}
    local request = {api = "CHECK_IN_AWARD", checkInAwardRequest = checkInAwardRequest}
    self:requestPackageHandler("CHECK_IN_AWARD", request, success, fail)
end

--[[
/**
 * 刷新斗魂场信息
repeated string actorIds = 1;                                               // 换防的魂师actor IDs
 */
 --]]
function QClient:arenaRefresh(arenaRefresh, battleFormation, success, fail, status)
    if arenaRefresh == nil then arenaRefresh = false end
    local arenaRefreshRequest = {areanIsManualRefresh = arenaRefresh}
    local request = {api = "ARENA_REFRESH", arenaRefreshRequest = arenaRefreshRequest, battleFormation = battleFormation}
    self:requestPackageHandler("ARENA_REFRESH", request, success, fail)
end

--[[
    刷新斗魂场部分信息 不带对手
]]
function QClient:arenaRefreshFighter(success, fail, status)
    local request = {api = "ARENA_GET_WORSHIP_FIGHTER"}
    self:requestPackageHandler("ARENA_GET_WORSHIP_FIGHTER", request, success, fail)
end

--[[
/**
 * 设置战队
repeated string actorIds = 1;                                               // 换防的魂师actor IDs
 */
 --]]
function QClient:setDefenseHero(battleFormation, success, fail, status)
    local arenaChangeDefenseHeroRequest = {}
    local request = {api = "ARENA_CHANGE_DEFENSE_HEROS", arenaChangeDefenseHeroRequest = arenaChangeDefenseHeroRequest, battleFormation = battleFormation}
    self:requestPackageHandler("ARENA_CHANGE_DEFENSE_HEROS", request, success, fail)
end




function QClient:arenaFightStartRequest(battleType, rivalUserId, battleFormation,success,fail)
    -- body
    local arenaFightStartRequest = {rivalUserId = rivalUserId}
    local gfStartRequest = {battleType = battleType,battleFormation = battleFormation,arenaFightStartRequest = arenaFightStartRequest}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    self:requestPackageHandler("GLOBAL_FIGHT_START", request, success, fail, true)
end
--[[
/**
 * 结束斗魂场
    required string rivalUserId = 1;                                            // 对手UserID
    required ArenaFightResult fightResult = 2;                                  // 挑战结果
 */
 --]]
function QClient:arenaFightEndRequest(rivalUserId, battleFormation, pos, fightResult, verifyDamages, battleKey, success, fail, status, isShow)
    local arenaFightEndRequest = {rivalUserId = rivalUserId, pos = pos, fightResult = fightResult, damage = {damages = verifyDamages}}
    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    local battleVerify = q.battleVerifyHandler(battleKey)

    local gfEndRequest = {battleType = BattleTypeEnum.ARENA,battleVerify = battleVerify,isQuick = false, isWin = nil, 
                        fightReportData  = fightReportData, arenaFightEndRequest = arenaFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest, battleFormation = battleFormation}
    self:requestPackageHandler("GLOBAL_FIGHT_END", request, success, fail, isShow)
end

--[[
/**
 * 扫荡斗魂场
    required string rivalUserId = 1;                                            // 对手UserId
    required int32 pos = 2;                                                     // 对手所在框的位置
 */
 --]]
function QClient:arenaQuickFightRequest(battleType, rivalUserId, pos, success, fail, status)
    local arenaQuickFightRequest = {rivalUserId = rivalUserId, pos = pos}
    local gfQuickRequest = {battleType = battleType,arenaQuickFightRequest = arenaQuickFightRequest}
    local request = {api = "GLOBAL_FIGHT_QUICK", gfQuickRequest = gfQuickRequest}
    self:requestPackageHandler("GLOBAL_FIGHT_QUICK", request, success, fail, false)
end

--[[
/**
 * 下载斗魂场回放
    optional int64   arenaFightReportId           = 1;                        //斗魂场历史记录ID
 */
 --]]
function QClient:arenaReplayDownloadRequest(arenaFightReportId, success, fail, status)
    local fightReportFindRequest = {arenaFightReportId = arenaFightReportId}
    local request = {api = "FIGHT_REPORT_FIND", fightReportFindRequest = fightReportFindRequest}
    self:requestPackageHandler("FIGHT_REPORT_FIND", request, success, fail, false)
end

--[[
/**
 * 下载斗魂场回放信息
    optional int64   arenaFightReportId           = 1;                        //斗魂场历史记录ID
 */
 --]]
function QClient:arenaReplayInfoRequest(arenaFightReportId, success, fail, status)
    local fightReportFighterQueryRequest = {arenaFightReportId = arenaFightReportId}
    local request = {api = "FIGHT_REPORT_FIGHTER_QUERY", fightReportFighterQueryRequest = fightReportFighterQueryRequest}
    self:requestPackageHandler("FIGHT_REPORT_FIGHTER_QUERY", request, success, fail, false)
end

--[[
/**
 * 斗魂场膜拜
repeated string actorIds = 1;                                               // 换防的魂师actor IDs
 */
 --]]
function QClient:arenaWorshipRequest(userId, pos, success, fail, status)
    local arenaWorshipRequest = {userId = userId, pos = pos}
    local request = {api = "ARENA_WORSHIP", arenaWorshipRequest = arenaWorshipRequest}
    self:requestPackageHandler("ARENA_WORSHIP", request, success, fail)
end

--[[
/**
 * 购买斗魂场次数
 */
 --]]
function QClient:buyFightCountRequest(success, fail, status)
    local request = {api = "ARENA_BUY_FIGHT_COUNT"}
    self:requestPackageHandler("ARENA_BUY_FIGHT_COUNT", request, success, fail)
end

--[[
/**
 * 斗魂场查询用户信息
 */
 --]]
function QClient:arenaQueryFighterRequest(user_Id, success, fail, status)
    local request = {api = "ARENA_QUERY_FIGHTER", arenaQueryFighterRequest = {userId = user_Id}}
    self:requestPackageHandler("ARENA_QUERY_FIGHTER", request, success, fail, false)
end

--[[
/**
 * 20次对战记录
 */
 --]]
function QClient:arenaAgainstRecordRequest(success, fail, status)
    local request = {api = "ARENA_FIGHT_HISTORY"}
    self:requestPackageHandler("ARENA_FIGHT_HISTORY", request, success, fail)
end

--[[
/**
 * 清楚斗魂场时间
 */
 --]]
function QClient:arenaClearFrozenTimeRequest(success, fail, status)
    local request = {api = "ARENA_CLEAR_FROZEN_TIME"}
    self:requestPackageHandler("ARENA_CLEAR_FROZEN_TIME", request, success, fail)
end

--[[
    斗魂场设定宣言
]]
function QClient:arenaSetDeclarationRequest(declaration, success, fail, status)
    local request = {api = "ARENA_SET_DECLARATION", arenaSetDeclarationRequest = {declaration = declaration}}
    self:requestPackageHandler("ARENA_SET_DECLARATION", request, success, fail)
end

--[[
/**
 * 排行榜
 */
 --]]
function QClient:top50RankRequest(type, userId, success, fail, status)
    local request = {api = "RANKINGS", rankingsRequest = {kind = type, userId = userId}}
    self:requestPackageHandler("RANKINGS", request, success, fail)
end

--[[
/**
 * 训练关排行榜
 */
 --]]
function QClient:top50RankCollegeTrainRequest(type, userId, collegeTrainId,success, fail, status)
    local request = {api = "RANKINGS", rankingsRequest = {kind = type, userId = userId,collegeTrainId = collegeTrainId}}
    self:requestPackageHandler("RANKINGS", request, success, fail)
end

--[[
/**
 * 排行榜用户查询
 */
 --]]
function QClient:topRankUserRequest(user_Id, success, fail, status)
    local request = {api = "RANKINGS_QUEYR_USER", rankingQueryFighterRequest = {userId = user_Id}}
    self:requestPackageHandler("RANKINGS_QUEYR_USER", request, success, fail)
end

--[[
/**
 * 排行榜用户查询
 */
 --]]
function QClient:topGloryArenaRankUserRequest(user_Id, success, fail, status)
    local request = {api = "GLORY_COMPETITION_QUERY_FIGHTER", gloryCompetitionQueryFighterRequest = {userId = user_Id}}
    self:requestPackageHandler("GLORY_COMPETITION_QUERY_FIGHTER", request, success, fail)
end

--[[
/**
 * 斗魂场用户查询
 */
 --]]
function QClient:arenaQueryDefenseHerosRequest(user_Id, success, fail, status)
    local request = {api = "ARENA_GET_DEFENSE_HERO", arenaQueryDefenseHerosRequest = {userId = user_Id}}
    self:requestPackageHandler("ARENA_GET_DEFENSE_HERO", request, success, fail)
end

--[[
    请求太阳井关卡
]]
function QClient:sunwellQueryRequest(startIndex, endIndex, success, fail, status, isShow)
    if isShow == nil then isShow = false end
    local indexs = {}
    for i=startIndex,endIndex,1 do
        indexs[#indexs + 1] = i
    end
    local sunwellQueryRequest = {index = indexs}
    local request = {api = "SUNWELL_QUERY", sunwellQueryRequest = sunwellQueryRequest}
    self:requestPackageHandler("SUNWELL_QUERY", request, success, fail, isShow)
end

--[[
    请求太阳井战斗开始
]]
function QClient:sunwellFightStartRequest(index, pos, actorIds, success, fail, status)
    local sunwellFightStartRequest = {index = index, pos = pos, actorIds = actorIds} 
    local request = {api = "SUNWELL_FIGHT_START", sunwellFightStartRequest = sunwellFightStartRequest}
    self:requestPackageHandler("SUNWELL_FIGHT_START", request, success, fail)
end

--[[
    请求太阳井重置
]]
function QClient:sunwellResetRequest(success, fail, status)
    local request = {api = "SUNWELL_RESET"}
    self:requestPackageHandler("SUNWELL_RESET", request, success, fail)
end

--[[
    请求太阳井战斗结束
]]
function QClient:sunwellFightEndRequest(index, pos, selfHeros, enemyHeros, verifyDamages, success, fail, status)
    local sunwellFightEndRequest = {index = index, pos = pos, selfHeros = selfHeros, enemyHeros = enemyHeros, damage = {damages = verifyDamages}} 
    local request = {api = "SUNWELL_FIGHT_END", sunwellFightEndRequest = sunwellFightEndRequest}
    self:requestPackageHandler("SUNWELL_FIGHT_END", request, success, fail)
end

--[[
    请求太阳井星级奖励领取
]]
function QClient:sunwellStarRewardLuckyDrawRequest(id, success, fail, status)
    local sunwellStarRewardLuckyDrawRequest = {rewardId = id} 
    local request = {api = "SUNWELL_STAR_REWARD_LUCKYDRAW", sunwellStarRewardLuckyDrawRequest = sunwellStarRewardLuckyDrawRequest}
    self:requestPackageHandler("SUNWELL_STAR_REWARD_LUCKYDRAW", request, success, fail)
end

--[[
    请求领取宝箱
]]
function QClient:sunwellLuckyDrawRequest(index, success, fail, status)
    local sunwellLuckyDrawRequest = {index = index} 
    local request = {api = "SUNWELL_LUCKYDRAW", sunwellLuckyDrawRequest = sunwellLuckyDrawRequest}
    self:requestPackageHandler("SUNWELL_LUCKYDRAW", request, success, fail)
end

--[[
    请求装备强化
]]
function QClient:heroEquipmentStrengthenRequest(actorId, itemIds, targetLevel, isOneKey,success, fail, status)
    local heroEquipmentEnhanceRequest = {actorId = actorId, itemIds = itemIds, targetLevel = targetLevel,isOneKey=isOneKey} 
    local request = {api = "HERO_EQUIPMENT_ENCHANCE", heroEquipmentEnhanceRequest = heroEquipmentEnhanceRequest}
    self:requestPackageHandler("HERO_EQUIPMENT_ENCHANCE", request, success, fail)
end

--[[
    请求饰品强化
]]
function QClient:heroJewelryStrengthenRequest(actorId, itemId, materialItemIds,success, fail, status)
    local heroEquipmentEnhanceAdvancedRequest = {actorId = actorId, itemId = itemId, materialItemIds = materialItemIds} 
    local request = {api = "HERO_EQUIPMENT_ENCHANCE_ADVANCED", heroEquipmentEnhanceAdvancedRequest = heroEquipmentEnhanceAdvancedRequest}
    self:requestPackageHandler("HERO_EQUIPMENT_ENCHANCE_ADVANCED", request, success, fail)
end

--[[
    拉取精彩活动内容
]]
function QClient:activityListRequest(success, fail, status)
    local request = {api = "ACTIVITY_LIST"}
    self:requestPackageHandler("ACTIVITY_LIST", request, success, fail)
end

--[[
    活动完成请求
]]
function QClient:activityCompleteRequest(activityId, targetId, params, count, success, fail, status)
    local activityCompleteRequest = {activityId = activityId , targetId = targetId, params = params, count = count}
    local request = {api = "ACITVITY_COMPLETE", activityCompleteRequest = activityCompleteRequest}
    self:requestPackageHandler("ACITVITY_COMPLETE", request, success, fail)
end

--[[
    新手引导获取指定的物品, guidanceRequest
    int32 index: guidance表的index
]]
function QClient:guidanceRequest(index, success, fail, status)
    local guidanceRequest = {index = index}
    local request = {api = "GUIDANCE", guidanceRequest = guidanceRequest}
    self:requestPackageHandler("GUIDANCE", request, success, fail)
end

-- --[[
--     定向酒馆购买物品,buyDirectionalTavern
--     int count: 购买次数
-- ]]
-- function QClient:buyDirectionalTavern(count, success, fail, status)
--     local luckyDrawDirectionRequest = {count = count}
--     local request = {api = "LUCKY_DRAW_DIRECTIONAL", luckyDrawDirectionRequest = luckyDrawDirectionRequest}
--     self:requestPackageHandler("LUCKY_DRAW_DIRECTIONAL", request, success, fail)
-- end

--[[
    魂师培养,HeroTrainRequest
]]
function QClient:heroTrainRequest(actorId, type, count, success, fail, status)
    local heroTrainRequest = {actorId = actorId, type = type, count = count}
    local request = {api = "HERO_TRAIN", heroTrainRequest = heroTrainRequest}
    self:requestPackageHandler("HERO_TRAIN", request, success, fail)
end

--[[
    魂师培养提交,HeroTrainApplyRequest
]]
function QClient:heroTrainApplyRequest(actorId, success, fail, status)
    local heroTrainApplyRequest = {actorId = actorId}
    local request = {api = "HERO_TRAIN_APPLY", heroTrainApplyRequest = heroTrainApplyRequest}
    self:requestPackageHandler("HERO_TRAIN_APPLY", request, success, fail)
end

--[[
/**
 * 请求公告列表
 * @return int32 id = 1;   //公告ID
 * @return int32  type = 2;  //公告类型
 * @return string content = 3;  //消息内容
 * @return int64 startAt = 4;   //开始时间
 */
]]
function QClient:getNoticeList(success, fail, status)
    local request = {api = "NOTICE_LIST"}
    self:requestPackageHandler("NOTICE_LIST", request, success, fail, false)
end

--[[
/**
 * 请求聚宝龙穴
 */
]]
function QClient:tigerOpenRequest(success, fail, status)
    local request = {api = "JUBAO_OPEN"}
    self:requestPackageHandler("JUBAO_OPEN", request, success, fail)
end

--[[
/**
 * 请求开始聚宝龙穴
 */
]]
function QClient:tigerStartRequest(success, fail, status)
    local request = {api = "JUBAO_START"}
    self:requestPackageHandler("JUBAO_START", request, success, fail)
end

--[[
/**
 * 请求购买开服基金
 */
]]
function QClient:buyFundRequest(success, fail, status)
    local request = {api = "BUY_FUND"}
    self:requestPackageHandler("BUY_FUND", request, success, fail)
end

--[[
/**
 * 请求查询开服基金购买人数
 */
]]
function QClient:buyFundCountRequest(success, fail, status)
    local request = {api = "BUY_FUND_COUNT"}
    self:requestPackageHandler("BUY_FUND_COUNT", request, success, fail)
end

--[[
/**
 * 请求手机号码绑定
 */
]]
function QClient:bindPhoneNumber(phoneNumber, verifyCode, sessionId, success, fail, status)
    local mobileAuthRequest = {mobile = phoneNumber, authCode = verifyCode, sessionId = sessionId}
    local request = {api = "USER_MOBILE_AUTH", mobileAuthRequest = mobileAuthRequest}
    self:requestPackageHandler("USER_MOBILE_AUTH", request, success, fail)
end

--[[
/**
 * 请求领取手机绑定奖励
 */
]]
function QClient:getPhoneBindRewards(success, fail, status)
    local request = {api = "LUCKY_DRAW_MOBILE_AUTH"}
    self:requestPackageHandler("LUCKY_DRAW_MOBILE_AUTH", request, success, fail)
end

--[[
/**
 * 请求领取微信奖励
 */
]]
function QClient:getWechatRewards(verifyCode, success, fail, status)
    local cdkeyUseRequest = {key = verifyCode}
    cdkeyUseRequest["type"] = 1
    local request = {api = "CDKEY_USE", cdkeyUseRequest = cdkeyUseRequest}
    self:requestPackageHandler("CDKEY_USE", request, success, fail)
end

--[[
/**
 * 请求购买次数
 */
]]
function QClient:dungeonBuyCountRequest(type, success, fail, status)
    local dungeonBuyCountRequest = {type = type}
    local request = {api = "DUNGEON_BUY_COUNT", dungeonBuyCountRequest = dungeonBuyCountRequest}
    self:requestPackageHandler("DUNGEON_BUY_COUNT", request, success, fail)
end

--[[
/**
 * 请求打开BOSS宝箱
 */
]]
function QClient:apiDungeonBossBoxRequest(dungeonId, success, fail, status)
    local apiDungeonBossBoxRequest = {dungeonId = dungeonId}
    local request = {api = "DUNGEON_BOSS_BOX", apiDungeonBossBoxRequest = apiDungeonBossBoxRequest}
    self:requestPackageHandler("DUNGEON_BOSS_BOX", request, success, fail)
end

--[[
/**
 * 请求魂师回收的培养
 */
]]
function QClient:heroTrainingCompensationRequest(actorId, success, fail, status)
    local heroGetInfoRequest = {actorId = actorId, infoBits = 16}
    local request = {api = "HERO_GET_INFO", heroGetInfoRequest = heroGetInfoRequest}
    self:requestPackageHandler("HERO_GET_INFO", request, success, fail)
end

--[[
/**
 * 请求聊天历史
 */
]]
function QClient:getChatHistory(success, fail, status)
    local request = {api = "GET_CHAT"}
    self:requestPackageHandler("GET_CHAT", request, success, fail)
end

--[[
/**
 * 请求组队聊天历史
 */
]]
function QClient:getTeamChatHistory(success, fail, status)
    local request = {api = "BLACK_ROCK_CHAT_LIST"}
    self:requestPackageHandler("BLACK_ROCK_CHAT_LIST", request, success, fail)
end

--[[
/**
 * 发送聊天消息
 */
]]
function QClient:sendChatMessage(type, msg, userId, misc, success, fail)
    local chatRequest = {type = type, content = msg, params = misc, toUserId = userId}
    local request = {api = "CHAT", chatRequest = chatRequest}
    self:requestPackageHandler("CHAT", request, success, fail, nil, true, false)
end


--[[
/**
 * 发送组队聊天消息
 * type 1普通聊天 2为气泡聊天
 */
]]
function QClient:sendTeamChatMessage(content, type,success, fail)
    local blackRockChatRequest = {content = content,type = type}
    local request = {api = "BLACK_ROCK_CHAT", blackRockChatRequest = blackRockChatRequest}
    self:requestPackageHandler("BLACK_ROCK_CHAT", request, success, fail, nil, true, false)
end

--[[
/**
 * 检查某用户是否在线
 */
]]
function QClient:checkUserOnline(userId, success, fail, status)
    local checkUserOnlineRequest = {userId = userId}
    local request = {api = "USER_ONLINE_CHECK", checkUserOnlineRequest = checkUserOnlineRequest}
    self:requestPackageHandler("USER_ONLINE_CHECK", request, success, fail)
end

--[[
/**
 * 战斗-攻防双方上阵数据上传Request(没有response)
    required BattleTypeEnum battleType = 1;                                                 //战斗类型
    required int64 reportId = 2;                                                            //战报ID
    required string fightersData = 3;                                                       //攻防双方上阵数据
 */
 --]]
function QClient:globalFightUploadFightersDataRequest(battleType, reportId, fightersData, success, fail, status)
    local gfUploadFightersDataRequest = {battleType = battleType, reportId = reportId, fightersData = fightersData}
    local request = {api = "GLOBAL_FIGHT_UPLOAD_FIGHTERS_DATA", gfUploadFightersDataRequest = gfUploadFightersDataRequest}
    self:requestPackageHandler("GLOBAL_FIGHT_UPLOAD_FIGHTERS_DATA", request, success, fail, false)
end

--[[
/**
 * 战斗-获取战斗的战报,用于回放战斗录像response
    required BattleTypeEnum battleType = 1;                                                 //战斗类型
    required int64 reportId = 2;                                                            //战报ID
    required string fightReportData = 3;                                                    //战报
 */
 --]]
function QClient:globalFightGetFightReportDataRequest(battleType, reportId, success, fail, status)
    local gfGetFightReportDataRequest = {battleType = battleType, reportId = reportId}
    local request = {api = "GLOBAL_FIGHT_GET_FIGHT_REPORT_DATA", gfGetFightReportDataRequest = gfGetFightReportDataRequest}
    self:requestPackageHandler("GLOBAL_FIGHT_GET_FIGHT_REPORT_DATA", request, success, fail, false)
end

--[[
/**
 *  战斗-获取战斗的攻防双方上阵数据,用于显示response GLOBAL_FIGHT_GET_FIGHTERS_DATA
    required BattleTypeEnum battleType = 1;                                                 //战斗类型
    required int64 reportId = 2;                                                            //战报ID
    required string fightersData = 3;                                                       //攻防双方上阵数据
 */
 --]]
function QClient:globalFightGetFightersDataRequest(battleType, reportId, success, fail, status)
    local gfGetFightersDataRequest = {battleType = battleType, reportId = reportId}
    local request = {api = "GLOBAL_FIGHT_GET_FIGHTERS_DATA", gfGetFightersDataRequest = gfGetFightersDataRequest}
    self:requestPackageHandler("GLOBAL_FIGHT_GET_FIGHTERS_DATA", request, success, fail, false)
end

--[[
/**
 * 下载魂师大赛回放
    optional int64   arenaFightReportId           = 1;                        //（斗魂场/魂师大赛）历史记录ID
 */
 --]]
function QClient:towerReplayDownloadRequest(arenaFightReportId, success, fail, status)
    local fightReportFindRequest = {arenaFightReportId = arenaFightReportId}
    local request = {api = "TOWER_FIGHT_REPORT_FIND", fightReportFindRequest = fightReportFindRequest}
    self:requestPackageHandler("TOWER_FIGHT_REPORT_FIND", request, success, fail, false)
end

--[[
/**
 * 下载魂师大赛回放信息
    optional int64   arenaFightReportId = 1;                                  //（斗魂场/魂师大赛）历史记录ID
 */
 --]]
function QClient:towerReplayInfoRequest(arenaFightReportId, success, fail, status)
    local fightReportFighterQueryRequest = {arenaFightReportId = arenaFightReportId}
    local request = {api = "TOWER_FIGHT_REPORT_FIGHTER_QUERY", fightReportFighterQueryRequest = fightReportFighterQueryRequest}
    self:requestPackageHandler("TOWER_FIGHT_REPORT_FIGHTER_QUERY", request, success, fail, false)
end

--[[
/**
 * 请求魂师大赛每日奖励
    optional int32  id  =   1;                                          // 魂师大赛每日奖励id
 */
 --]]
function QClient:towerDailyRewardRequest(ids, success, fail, status)
    local towerGetTodayScoreAwardRequest = {ids = ids}
    local request = {api = "TOWER_GET_TODAY_SCORE_AWARD", towerGetTodayScoreAwardRequest = towerGetTodayScoreAwardRequest}
    app:getClient():requestPackageHandler("TOWER_GET_TODAY_SCORE_AWARD", request, success, fail, false)
end

-- --[[
-- /**
--  * 酒馆星魂兑换魂师
--  */
-- ]]
-- function QClient:tavernExchangeHero(heroId, success, fail, status)
--     local luckyDrawIntegralFeedbackRequest = {heroId = heroId}
--     local request = {api = "LUCKY_DRAW_INTEGRAL_FEEDBACK", luckyDrawIntegralFeedbackRequest = luckyDrawIntegralFeedbackRequest}
--     self:requestPackageHandler("LUCKY_DRAW_INTEGRAL_FEEDBACK", request, success, fail)
-- end

--[[
/**
 *  请求4选1礼包的选择获取
    required int32 itemId = 1;                                                  // 打开的道具id
    required int32 targetItemId = 2;                                            // 选择的道具id
]]
function QClient:chooseItemPackage(itemId, targetResource, count, success, fail, status)
    local itemChooseRequest = {itemId = itemId, targetResource = targetResource, count = count}
    local request = {api = "ITEM_CHOOSE", itemChooseRequest = itemChooseRequest}
    self:requestPackageHandler("ITEM_CHOOSE", request, success, fail)
end

--[[
/**
 * 请求充值历史
 */
]]
function QClient:getRechargetHistory(success, fail, status)
    local successCallback = function (data)
        if data.rechargeInfoResponse and data.rechargeInfoResponse.rechargeInfo then
            remote.recharge = data.rechargeInfoResponse.rechargeInfo
            if success then success(data) end
        end
    end

    local request = {api = "GET_RECHARGE_INFO"}
    self:requestPackageHandler("GET_RECHARGE_INFO", request, successCallback, fail)
end

--[[
/**
 * 充值
 */
]]
function QClient:recharge(rmb, type, itemId,rechargeId,success, fail, status)
    local successCallback = function (data)
        if data.rechargeTokenResponse and data.rechargeTokenResponse.rechargeInfo then
            remote.recharge = data.rechargeTokenResponse.rechargeInfo
            if success then success(data) end
        end
    end

    local rechargeTokenRequest = {targetRmb = rmb, targetType = type , itemId = itemId , id = rechargeId}
    local request = {api = "DO_RECHARGE_TOKEN", rechargeTokenRequest = rechargeTokenRequest}
    self:requestPackageHandler("DO_RECHARGE_TOKEN", request, successCallback, fail)
end

-- 舊首充
function QClient:getFirstRecharge(success, fail, status)
    local successCallback = function (data)
        if data.firstRechargeAwardResponse and data.firstRechargeAwardResponse.rechargeInfo then
            remote.recharge = data.firstRechargeAwardResponse.rechargeInfo
            if success then success(data) end
        end
    end

    local request = {api = "GET_FIRST_RECHARGE_AWARD"}
    self:requestPackageHandler("GET_FIRST_RECHARGE_AWARD", request, successCallback, fail)
end

-- 新首充
-- getFirstRechargeRewardRequest
-- optional int32 rewardIndex = 1; // 首充奖励index
function QClient:getFirstRechargeRewardRequest(rewardIndex, success, fail, status)
    local getFirstRechargeRewardRequest = {rewardIndex = rewardIndex}
    local request = {api = "GET_FIRST_RECHARG_REWARD", getFirstRechargeRewardRequest = getFirstRechargeRewardRequest}
    self:requestPackageHandler("GET_FIRST_RECHARG_REWARD", request, success, fail)
end

--[[
/**
 * 错误报告
 */
]]
function QClient:crashReport(message, stack, success, fail, status)
    local appServer = ""
    if remote.selectServerInfo then
        appServer = remote.selectServerInfo.name or ""
    end

    local crashReport = {_device_id = QUtility:getAppUUID(), _channel = FinalSDK.getChannelID(), _appserver = appServer, 
        _user_id = remote.user.userId or "", _version = QUtility:getSystemVersion(), _message = message, _trace = stack}
    local crashReportRequest = {crashReport = crashReport}
    local request = {api = "SYS_CRASH_REPORT", crashReportRequest = crashReportRequest}
    self:requestPackageHandler("SYS_CRASH_REPORT", request, success, fail)
end

--[[
/**
 * 分拆登录接口 副本详细信息 DUNGEON_INFO（副本通关/星星领取奖励）
 */
]]
function QClient:getDungeonInfo(success, fail, status)
    local request = {api = "DUNGEON_INFO"}
    self:requestPackageHandler("DUNGEON_INFO", request, success, fail)
end

--[[
/**
 * DUNGEON_GET_EASTER_EGG_REWARD               = 407;                      // 副本-领取彩蛋奖励 DungeonGetEasterEggRewardRequest
 * optional int32 mapId = 1;
 * optional int32 easterEggId = 2;  （和後端約定，id參數給1，2，3）
 */
]]
function QClient:dungeonGetEasterEggRewardRequest(mapId, easterEggId, success, fail, status)
    local dungeonGetEasterEggRewardRequest = {mapId = mapId, easterEggId = easterEggId}
    local request = {api = "DUNGEON_GET_EASTER_EGG_REWARD", dungeonGetEasterEggRewardRequest = dungeonGetEasterEggRewardRequest}
    self:requestPackageHandler("DUNGEON_GET_EASTER_EGG_REWARD", request, success, fail)
end

--[[
/**
 * 分拆登录接口 获取所有装备 ITEM_GET
 */
]]
function QClient:getItemGet(success, fail, status)
    local request = {api = "ITEM_GET"}
    self:requestPackageHandler("ITEM_GET", request, success, fail)
end
--[[
/**
 * 分拆登录接口 获得所有商店信息 SHOP_GET_ALL
 */
]]
function QClient:getShopGetAll(success, fail, status)
    local request = {api = "SHOP_GET_ALL"}
    self:requestPackageHandler("SHOP_GET_ALL", request, success, fail)
end

--[[
    请求领取每日任务积分奖励
    optional int32  box_id  =   1;
]]
function QClient:dailyTaskRewardRequest(box_id, success, fail, status)
    local dailyTaskRewardRequest = {box_id = box_id}
    local request = {api = "DAILY_TASK_REWARD", dailyTaskRewardRequest = dailyTaskRewardRequest}
    self:requestPackageHandler("DAILY_TASK_REWARD", request, success, fail)
end


--[[
    请求领取每周任务积分奖励
    optional int32  box_id  =   1;
]]
function QClient:weeklyTaskRewardRequest(box_id, success, fail, status)
    local weekTaskRewardRequest = {box_id = box_id}
    local request = {api = "WEEK_TASK_REWARD", weekTaskRewardRequest = weekTaskRewardRequest}
    self:requestPackageHandler("WEEK_TASK_REWARD", request, success, fail)
end

--[[
    optional int32 actorId = 1;              // 要转换的魂师ID
    optional int32 count = 2;                // 转换次数
]]
function QClient:heroPieceChangeRequest(actorId, count, success, fail, status)
    local heroPieceChangeRequest = {actorId = actorId, count = count}
    local request = {api = "HERO_PIECE_CHANGE", heroPieceChangeRequest = heroPieceChangeRequest}
    self:requestPackageHandler("HERO_PIECE_CHANGE", request, success, fail)
end

--[[
    请求考古信息 无参数
]]
function QClient:archaeologyInfoRequest(success, fail, status)
    local request = {api = "ARCHAEOLOGY_INFO"}
    self:requestPackageHandler("ARCHAEOLOGY_INFO", request, success, fail)
end

--[[
    请求开启历史片段   无参数
]]
function QClient:archaeologyEnableFragmentRequest(success, fail, status)
    local request = {api = "ARCHAEOLOGY_ENABLE_FRAGMENT"}
    self:requestPackageHandler("ARCHAEOLOGY_ENABLE_FRAGMENT", request, success, fail)
end

--[[
    请求领取历史片段奖励 参数 ArchaeologyGetLuckyDrawRequest
    optional int32 archaeologyId = 1;
    optional int32 itemId   = 2;
]]
function QClient:archaeologyGetLuckyDrawRequest(archaeologyId, itemId, success, fail, status)
    local archaeologyGetLuckyDrawRequest = {archaeologyId = archaeologyId, itemId = itemId}
    local request = {api = "ARCHAEOLOGY_GET_LUCKY_DRAW", archaeologyGetLuckyDrawRequest = archaeologyGetLuckyDrawRequest}
    self:requestPackageHandler("ARCHAEOLOGY_GET_LUCKY_DRAW", request, success, fail)
end

--[[
 请求记录埋点数据 API = "LOG_GUIDE_POINT"
    参数 LogGuidePointRequest {
            optional int32 guideId = 1;
        }
]]
function QClient:sendLogGuidePointRequest(guideId)
    local logGuidePointRequest = {guideId = guideId}
    local request = {api = "LOG_GUIDE_POINT", logGuidePointRequest = logGuidePointRequest}
    self:requestPackageHandler("LOG_GUIDE_POINT", request, nil, nil, nil, nil, nil, true)
end

--[[
    // 太阳海神岛初始化数据获取
]]
function QClient:sunwarInfoRequest(success, fail, status)
    local request = {api = "BATTLEFIELD_GET_INFO"}
    self:requestPackageHandler("BATTLEFIELD_GET_INFO", request, success, fail)
end

--[[
    // 太阳海神岛战斗开始 BattlefieldFightStartRequest
    repeated int32 mainActorIds = 1;                        // 参战主将魂师
    repeated int32 subActorIds = 2;                         // 参战副将魂师
    optional int32 activeSubActorId = 3;                    // 激活副将
    optional int32 fightWave = 4;                           // 战斗的关卡ID
]]
function QClient:sunwarFightStartRequest(fightWave, battleFormation, success, fail, status)
    local battlefieldFightStartRequest = {fightWave = fightWave} 
    local gfStartRequest = {battleType = BattleTypeEnum.BATTLEFIELD, battleFormation = battleFormation, battlefieldFightStartRequest = battlefieldFightStartRequest}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    self:requestPackageHandler("GLOBAL_FIGHT_START", request, success, fail)
end

--[[
    // 太阳海神岛战斗结束 BattlefieldFightEndRequest
    optional FightResult fightResult = 1;                  // 挑战结果
    optional VerifyDamage damage = 2;                      // 伤害验证信息
    repeated HeroHpMpInfo herosHpMp = 3;                   // 我方参战魂师当前血量值和怒气值
    repeated HeroHpMpInfo npcsHpMp = 4;                    // NPC各魂师当前血量值和怒气值
    optional string battleVerify = 5;
    optional int32 fightWave = 6;                          // 战斗的关卡ID
]]
function QClient:sunwarFightEndRequest(damage, herosHpMp, npcsHpMp, battleKey, fightWave, isQuickFight, isSecretary, success, fail, status)
    local battleVerify = q.battleVerifyHandler(battleKey)
    local battlefieldFightEndRequest = {damage = {damages = damage}, herosHpMp = herosHpMp, npcsHpMp = npcsHpMp, battleVerify = battleVerify, fightWave = fightWave, isSecretary = isSecretary} 
    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)

    local gfEndRequest = {battleType = BattleTypeEnum.BATTLEFIELD, battleVerify = battleVerify, isQuick = isQuickFight, isWin = nil,
                         fightReportData = fightReportData, battlefieldFightEndRequest = battlefieldFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    self:requestPackageHandler("GLOBAL_FIGHT_END", request, success, fail)
end

--[[
    // 太阳海神岛获取关卡过关之后的宝箱奖励 BattlefieldGetWaveAwardRequest
    optional int32 wave = 1;                                   // 领取过关奖励的关卡ID
]]
function QClient:sunwarGetWaveAwardRequest(wave, isSecretary, success, fail, status)
    local battlefieldGetWaveAwardRequest = {wave = wave, isSecretary = isSecretary}
    local request = {api = "BATTLEFIELD_GET_WAVE_AWARD", battlefieldGetWaveAwardRequest = battlefieldGetWaveAwardRequest}
    self:requestPackageHandler("BATTLEFIELD_GET_WAVE_AWARD", request, success, fail)
end

--[[
    // 太阳海神岛魂师复活
]]
function QClient:sunwarHeroReviveRequest(isSecretary, success, fail, status)
    local battlefieldReviteRequest = {isSecretary = isSecretary}
    local request = {api = "BATTLEFIELD_HEROS_REVIVE", battlefieldReviteRequest = battlefieldReviteRequest}
    self:requestPackageHandler("BATTLEFIELD_HEROS_REVIVE", request, success, fail)
end

--[[
    // 太阳海神岛购买魂师复活次数
]]
function QClient:sunwarBuyReviveCountRequest(isSecretary, success, fail, status)
    local battlefieldBuyReviteCountRequest = {isSecretary = isSecretary}
    local request = {api = "BATTLEFIELD_BUY_REVIVE_COUNT", battlefieldBuyReviteCountRequest = battlefieldBuyReviteCountRequest}
    self:requestPackageHandler("BATTLEFIELD_BUY_REVIVE_COUNT", request, success, fail)
end

--[[
    // 太阳海神岛简单数据，游戏登入时调用
]]
function QClient:sunwarGetSimpleInfoRequest(success, fail, status)
    local request = {api = "BATTLEFIELD_GET_SIMPLE_INFO"}
    self:requestPackageHandler("BATTLEFIELD_GET_SIMPLE_INFO", request, success, fail)
end

--[[
    // 太阳海神岛请求章节奖励 BattleFieldGetChapterAwardRequest
    optional int32 chapterId = 1;                           //章节ID
]]
function QClient:sunwarGetChapterAwardRequest(chapterId, isSecretary, success, fail, status)
    local battleFieldGetChapterAwardRequest = {chapterId = chapterId, isSecretary = isSecretary}
    local request = {api = "BATTLEFIELD_GET_CHAPTER_AWARD", battleFieldGetChapterAwardRequest = battleFieldGetChapterAwardRequest}
    self:requestPackageHandler("BATTLEFIELD_GET_CHAPTER_AWARD", request, success, fail)
end

--[[
    // 太阳海神岛请求章节重置模式更改 BattlefieldSetResetModeRequest
    optional int32 resetMode = 1;                           //模式(0:正常模式,1:重置到上一章节)
]]
function QClient:sunwarSetResetModeRequest(resetMode, success, fail, status)
    local battlefieldSetResetModeRequest = {resetMode = resetMode}
    local request = {api = "BATTLEFIELD_SET_RESET_MODE", battlefieldSetResetModeRequest = battlefieldSetResetModeRequest}
    self:requestPackageHandler("BATTLEFIELD_SET_RESET_MODE", request, success, fail)
end

--[[
    // 觉醒宝箱积分兑换 luckyDrawEnchantRequest
    optional bool is10Times = 1;                           //是否是十连抽
]]
function QClient:luckyDrawEnchantRequest(is10Times, success, fail, status)
    local luckyDrawEnchantRequest = {is10Times = is10Times}
    local request = {api = "LUCKY_DRAW_ENCHANT", luckyDrawEnchantRequest = luckyDrawEnchantRequest}
    self:requestPackageHandler("LUCKY_DRAW_ENCHANT", request, success, fail)
end


--[[
    // 觉醒宝箱积分兑换 luckyDrawEnchantRewardRequest
    optional int32 rewardId = 1;                           //物品位置
]]
function QClient:luckyDrawEnchantRewardRequest(rewardId, success, fail, status)
    local luckyDrawEnchantRewardRequest = {rewardId = rewardId}
    local request = {api = "LUCKY_DRAW_ENCHANT_REWARD", luckyDrawEnchantRewardRequest = luckyDrawEnchantRewardRequest}
    self:requestPackageHandler("LUCKY_DRAW_ENCHANT_REWARD", request, success, fail)
end

--[[
    获取个人战力排行
]]
function QClient:getBattleForceRank(success, fail, status)
    local request = {api = "GET_FORCE_RANK"}
    self:requestPackageHandler("GET_FORCE_RANK", request, success, fail)
end

function QClient:refreshForce(success, fail, status)
    local request = {api = "USER_FORCE_REFRESH"}
    self:requestPackageHandler("USER_FORCE_REFRESH", request, success, fail)
end

--[[
    获取个人等级排名 无参数
]]
function QClient:getUserLevelRank(success, fail, status)
    local request = {api = "GET_LEVEL_RANK"}
    self:requestPackageHandler("GET_LEVEL_RANK", request, success, fail)
end

--[[
    获取热血服的领取vip经验信息
]]
function QClient:getWarmBloodVipExpInfo(success, fail, status)
    local request = {api = "GET_EXTEND_VIP_EXP_INFO"}
    self:requestPackageHandler("GET_EXTEND_VIP_EXP_INFO", request, success, fail)
end

--[[
    领取热血服vip经验
]]
function QClient:getWarmBloodVipExp(success, fail, status)
    local request = {api = "GET_WARM_BLOOD_VIP_EXP"}
    self:requestPackageHandler("GET_WARM_BLOOD_VIP_EXP", request, success, fail)
end

--[[
    //  heroGlyphImproveRequest
    required int32 actorId = 1;                                                 // 要技能升级的魂师actorID
    required int32 glyphId = 2;                                                 // 要升级的雕纹ID
]]
function QClient:heroGlyphImproveRequest(actorId, glyphId, isQuick, success, fail, status)
    local heroGlyphImproveRequest = {actorId = actorId, glyphId = glyphId, quick = isQuick}
    local request = {api = "HERO_GLYPH_IMPROVE", heroGlyphImproveRequest = heroGlyphImproveRequest}
    self:requestPackageHandler("HERO_GLYPH_IMPROVE", request, success, fail)
end

--[[
    //  heroGlyphImproveRequest
    required int32 actorId = 1;                                                 // 要技能升级的魂师actorID
    required int32 glyphId = 2;                                                 // 要升级的雕纹ID
]]
function QClient:heroGlyphImproveFullRequest(actorId, glyphId, success, fail, status)
    local heroGlyphImproveToMaxRequest = {actorId = actorId, glyphId = glyphId}
    local request = {api = "HERO_GLYPH_IMPROVE_TO_MAX", heroGlyphImproveToMaxRequest = heroGlyphImproveToMaxRequest}
    self:requestPackageHandler("HERO_GLYPH_IMPROVE_TO_MAX", request, success, fail)
end

--[[
    魂师培养取消                  
    optional int32 actorId                                                     // 魂师ID                           
]]
function QClient:heroTrainClearRequest(actorId, success, fail, status)
    local heroTrainClearRequest = {actorId = actorId}
    local request = {api = "HERO_TRAIN_CLEAR", heroTrainClearRequest = heroTrainClearRequest}
    self:requestPackageHandler("HERO_TRAIN_CLEAR", request, success, fail)
end

--[[
    快速登陆
    required string osdkUserId = 1;                                             //用户账号(平台编号_平台账号)
    required string gameArea = 2;                                               //游戏区ID
    required string deviceModel = 3;                                            //设备具体型号(IPhone4S,IPhone5等)
    required string deviceId = 4;                                               //设备ID
    optional string channel = 5;                                                //渠道ID
]]
function QClient:userQuickLoginRequest(osdkUserId, gameArea, deviceModel, deviceId, channel, success, fail, status)
    local userQuickLoginRequest = {osdkUserId = osdkUserId, gameArea = gameArea, deviceModel = deviceModel, deviceId = deviceId, channel = channel}
    local request = {api = "USER_QUICK_LOGIN", userQuickLoginRequest = userQuickLoginRequest}
    self:requestPackageHandler("USER_QUICK_LOGIN", request, success, fail)
end

--[[
    保存展示魂师皮肤)
    required int32 skinId                                                      //默认的魂师皮肤ID
]]
function QClient:changeDefaultActorRequest(actorId,skinId, success, fail, status)
    local changeDefaultActorRequest = {actorId = actorId,skinId = skinId}
    local request = {api = "USER_DEFAULT_ACTOR", changeDefaultActorRequest = changeDefaultActorRequest}
    self:requestPackageHandler("USER_DEFAULT_ACTOR", request, success, fail)
end
-- --[[
--     验证激活码
--     required string code                                                      //默认的魂师ID
-- ]]
function QClient:validateActivationCode( code, session, success, fail, status )
    -- body
     local userActivationByCodeRequest = {code = code, osdkTicket = session}
    local request = {api = "USER_ACTIVATION_BY_CODE", userActivationByCodeRequest = userActivationByCodeRequest}
    self:requestPackageHandler("USER_ACTIVATION_BY_CODE", request, success, fail)
end

--[[
/**
 * 下载荣耀斗魂场回放信息
    optional int64   gloryArenaFightReportId           = 1;                        //荣耀斗魂场历史记录ID
 */
 --]]
function QClient:gloryArenaReplayInfoRequest(gloryArenaFightReportId, success, fail, status)
    local fightReportFighterQueryRequest = {arenaFightReportId = gloryArenaFightReportId}
    local request = {api = "GLORY_COMPETITION_FIGHT_REPORT_FIGHTER_QUERY", fightReportFighterQueryRequest = fightReportFighterQueryRequest}
    self:requestPackageHandler("GLORY_COMPETITION_FIGHT_REPORT_FIGHTER_QUERY", request, success, fail, false)
end

--[[
/**
 * 下载风暴斗魂场
    optional int64   gloryArenaFightReportId           = 1;                        //荣耀斗魂场历史记录ID
 */
 --]]
function QClient:stormArenaReplayDownloadRequest(stormArenaFightReportId, success, fail, status)
    local fightReportFindRequest = {arenaFightReportId = stormArenaFightReportId}
    local request = {api = "STORM_FIGHT_REPORT_FIND", fightReportFindRequest = fightReportFindRequest}
    self:requestPackageHandler("STORM_FIGHT_REPORT_FIND", request, success, fail, false)
end


--[[
/**
 * 下载风暴斗魂场回放信息
    optional int64   gloryArenaFightReportId           = 1;                        //荣耀斗魂场历史记录ID
 */
 --]]
function QClient:stormArenaReplayInfoRequest(stormArenaFightReportId, success, fail, status)
    local fightReportFighterQueryRequest = {arenaFightReportId = stormArenaFightReportId}
    local request = {api = "STORM_FIGHT_REPORT_FIGHTER_QUERY", fightReportFighterQueryRequest = fightReportFighterQueryRequest}
    self:requestPackageHandler("STORM_FIGHT_REPORT_FIGHTER_QUERY", request, success, fail, false)
end

function QClient:getXiaoNaNaDianZangTotal(success, fail, status)
    local request = {api = "GAME_TIPS_GET_ALL_TIPS_INFO"}
    self:requestPackageHandler("GAME_TIPS_GET_ALL_TIPS_INFO", request, success, fail)
end

function QClient:XiaoNaNaDianZang(id, success, fail, status)
    local gameTipsLikeTipsRequest = {id = id}
    local request = {api = "GAME_TIPS_LIKE_TIPS", gameTipsLikeTipsRequest = gameTipsLikeTipsRequest}
    self:requestPackageHandler("GAME_TIPS_LIKE_TIPS", request, success, fail)
end

-- 洗练 参考参数 RefineHeroRequest 返回参数 HeroInfo（包含RefineHeroInfo）
-- required int32  actorId = 1;                                                  //魂师ID
-- repeated int32 lockGrid = 2;                                                  //锁住格子
function QClient:refineHeroRequest(actorId, lockGrid, success, fail, status)
    local refineHeroRequest = { actorId = actorId, lockGrid = lockGrid }
    local request = { api = "REFINE_HERO", refineHeroRequest = refineHeroRequest }
    self:requestPackageHandler("REFINE_HERO", request, success, fail)
end

-- 洗练替换 参数 RefineHeroApplyRequest     返回参数 HeroInfo（包含RefineHeroInfo）
-- required int32  actorId = 1;                                                  //魂师ID
function QClient:refineHeroApplyRequest(actorId, success, fail, status)
    local refineHeroApplyRequest = { actorId = actorId }
    local request = { api = "REFINE_HERO_APPLY", refineHeroApplyRequest = refineHeroApplyRequest }
    self:requestPackageHandler("REFINE_HERO_APPLY", request, success, fail)
end

-- 开启新洗练格子 参考参数 RefineHeroOpenGridRequest, 返回参数 HeroInfo（包含RefineHeroInfo）
-- required int32 actorId = 1;                                                    //魂师ID
function QClient:refineHeroOpenGridRequest(actorId, success, fail, status)
    local refineHeroOpenGridRequest = { actorId = actorId }
    local request = { api = "REFINE_HERO_OPEN_GRID", refineHeroOpenGridRequest = refineHeroOpenGridRequest }
    self:requestPackageHandler("REFINE_HERO_OPEN_GRID", request, success, fail)
end

-- 精炼 参考参数 RefineAdvanceHeroRequest, 返回参数 HeroInfo（包含RefineHeroInfo）
-- required int32  actorId = 1;                                                   //魂师ID
-- required int32  grid = 2;                                                      //格子ID
-- required int32  type = 3;                                                      //1祝福石，2高级祝福石
function QClient:refineAdvanceHeroRequest(actorId, grid, type, success, fail, status)
    local refineAdvanceHeroRequest = { actorId = actorId, grid = grid, type = type }
    local request = { api = "REFINE_ADVANCE_HERO", refineAdvanceHeroRequest = refineAdvanceHeroRequest }
    self:requestPackageHandler("REFINE_ADVANCE_HERO", request, success, fail)
end

-- 精炼替换 参数  RefineAdvanceHeroApplyRequest, 返回参数 HeroInfo（包含RefineHeroInfo）
-- required int32 actorId = 1;                                                   //魂师ID
function QClient:refineAdvanceHeroApplyRequest(actorId, success, fail, status)
    local refineAdvanceHeroApplyRequest = { actorId = actorId }
    local request = { api = "REFINE_ADVANCE_HERO_APPLY", refineAdvanceHeroApplyRequest = refineAdvanceHeroApplyRequest }
    self:requestPackageHandler("REFINE_ADVANCE_HERO_APPLY", request, success, fail)
end

-- 清除洗练属性 参考参数 RefineHeroClearRequest, 返回参数 HeroInfo（包含RefineHeroInfo）
-- required int32 actorId = 1;                                                   //魂师ID
function QClient:refineHeroClearRequest(actorId, success, fail, status)
    local refineHeroClearRequest = { actorId = actorId }
    local request = { api = "REFINE_CLEAR", refineHeroClearRequest = refineHeroClearRequest }
    self:requestPackageHandler("REFINE_CLEAR", request, success, fail)
end

-- HERO_REMOVE_ALL_FORMATION = 3803; // 魂师一键移除所有阵容  参考：HeroRemoveAllFormationRequest
-- optional int32 actorId = 1;                                                 // 魂师id
function QClient:heroRemoveAllFormationRequest(actorId, success, fail, status)
    local heroRemoveAllFormationRequest = { actorId = actorId }
    local request = { api = "HERO_REMOVE_ALL_FORMATION", heroRemoveAllFormationRequest = heroRemoveAllFormationRequest }
    self:requestPackageHandler("HERO_REMOVE_ALL_FORMATION", request, success, fail)
end

--[[
/**
 * 请求魂师降星
 */
]]
function QClient:heroReturnGradeRequest(actorId, success, fail, status)
    local heroGradeReturnRequest = {actorId = actorId}
    local request = {api = "HERO_GRADE_RETURN", heroGradeReturnRequest = heroGradeReturnRequest}
    self:requestPackageHandler("HERO_GRADE_RETURN", request, success, fail)
end

-- // 商店购买多个物品
function QClient:requestBuyShopItems(shopBuyRequests, isSecretary, success, fail, status)
    if isSecretary == nil then isSecretary = false end
    local shopOneKeyBuyRequest = { shopBuyRequests = shopBuyRequests, isSecretary = isSecretary}
    local request = { api = "SHOP_ONE_KEY_BUY", shopOneKeyBuyRequest = shopOneKeyBuyRequest }
    self:requestPackageHandler("SHOP_ONE_KEY_BUY", request, success, fail)
end

-- // 商店循环购买多个物品
-- required int32 shopId = 1;                                          // 商店id
-- repeated SelectItem selectItems = 3;                                // 要购买的物品
-- optional bool isSecretary = 3;                                // 小舞助手
function QClient:shopQuickBuyRequest(shopId, selectItems, isSecretary, refushCount,success, fail, status)
    local shopQuickBuyRequest = { shopId = shopId, selectItems = selectItems, isSecretary = isSecretary,refushCount = refushCount}
    local request = { api = "SHOP_QUICK_BUY", shopQuickBuyRequest = shopQuickBuyRequest }
    self:requestPackageHandler("SHOP_QUICK_BUY", request, success, fail)
end


--获取推送 配置
function QClient:getRemoteNotificationSetting(success, fail, status)
    local request = { api = "PUSH_CONFIGURATION_INFO"}
    self:requestPackageHandler("PUSH_CONFIGURATION_INFO", request, function(data)
        -- body
        if data.settingConfigurationInfoResponse then
            remote.notificationSetting = data.settingConfigurationInfoResponse.settings or {}
        end
        if success then
            success()
        end
    end, fail)
end

--获取推送 配置
function QClient:setRemoteNotificationSetting(key, value, success, fail, status)
    local pushSetConfigurationRequest = {setting = {key = key,value = value}}
    local request = { api = "PUSH_SET_CONFIGURATION", pushSetConfigurationRequest = pushSetConfigurationRequest}
    self:requestPackageHandler("PUSH_SET_CONFIGURATION", request, success, fail)
end

-- 魂师觉醒摘除
-- optional int32 actorId = 1;
-- optional int32 equipmentId = 2;
function QClient:heroEquipmentEnchantRecoverRequest(actorId, equipmentId, success, fail, status)
    local heroEquipmentEnchantRecoverRequest = {actorId = actorId, equipmentId = equipmentId}
    local request = { api = "HERO_EQUIPMENT_ENCHANT_RECOVER", heroEquipmentEnchantRecoverRequest = heroEquipmentEnchantRecoverRequest}
    self:requestPackageHandler("HERO_EQUIPMENT_ENCHANT_RECOVER", request, success, fail)
end

-- 嘉年华活动积分奖励领取
--  optional string activityType = 2;                                             // 完成的活动类型 1嘉年华2半月庆典
--  optional int32 prizeId = 3;                                                   // 不同积分对应的奖励Id
function QClient:getSevenActivityIntegralReward(activityType, prizeId, success, fail, status)
    local activityGetIntegralRewardRequest = {activityType = activityType, prizeId = prizeId}
    local request = { api = "ACTIVITY_GET_INTEGRAL_PRIZE", activityGetIntegralRewardRequest = activityGetIntegralRewardRequest}
    self:requestPackageHandler("ACTIVITY_GET_INTEGRAL_PRIZE", request, success, fail)
end

--  七日登录奖励领取
--  optional int32 prizeId = 1;                                                   // 不同天数对应的奖励Id
function QClient:getSevenLoginEntryActivityReward(prizeId, success, fail, status)
    local activityGetEnterRewardRequest = {prizeId = prizeId}
    local request = { api = "ACTIVITY_GET_ENTER_PRIZE", activityGetEnterRewardRequest = activityGetEnterRewardRequest}
    self:requestPackageHandler("ACTIVITY_GET_ENTER_PRIZE", request, success, fail)
end

--  获取封测返利数据
--  无参数，返回RechargeFeedbackInfo
function QClient:getRechargeFeedbackInfo(success, fail, status)
    local request = { api = "RECHARGE_FEEDBACK_GET_INFO"}
    self:requestPackageHandler("RECHARGE_FEEDBACK_GET_INFO", request, success, fail)
end

--  领取封测返利奖励
--  optional int32 rewardId = 1;                    //充值返利奖励ID
function QClient:getRechargeFeedbackGetRewardRequest(rewardId, success, fail, status)
    local rechargeFeedbackGetRewardRequest = {rewardId = rewardId}
    local request = { api = "RECHARGE_FEEDBACK_GET_REWARD", rechargeFeedbackGetRewardRequest = rechargeFeedbackGetRewardRequest}
    self:requestPackageHandler("RECHARGE_FEEDBACK_GET_REWARD", request, success, fail)
end

--  巅峰战报
--  optional int32 battleType = 1;                    //战斗类型
function QClient:globalGetTopFightReportDataRequest(battleType, success, fail, status)
    local globalGetTopFightReportDataRequest = {battleType = battleType}
    local request = { api = "GLOBAL_FIGHT_GET_TOP_FIGHT_REPORT_DATA", globalGetTopFightReportDataRequest = globalGetTopFightReportDataRequest}
    self:requestPackageHandler("GLOBAL_FIGHT_GET_TOP_FIGHT_REPORT_DATA", request, success, fail)
end

--  饰品一键强化
--  optional int32 actorId = 1;                                                   // 突破哪个英雄身上的装备
--  optional int32 targetLevel = 2;                                               // 目标等级
function QClient:jewelryEnchanceOneClickRequest(actorId, targetLevel, success, fail, status)
    local heroEquipmentOneKeyEnhanceAdvancedRequest = {actorId = actorId, targetLevel = targetLevel}
    local request = { api = "HERO_EQUIPMENT_ONE_KEY_ENCHANCE_ADVANCED", heroEquipmentOneKeyEnhanceAdvancedRequest = heroEquipmentOneKeyEnhanceAdvancedRequest}
    self:requestPackageHandler("HERO_EQUIPMENT_ONE_KEY_ENCHANCE_ADVANCED", request, success, fail)
end

--  饰品一键突破
--  optional int32 actorId = 1;                                                   // 突破哪个英雄身上的装备
--  optional int32 targetLevel = 2;                                               // 目标等级
function QClient:jewelryEvolutionOneClickRequest(actorId, targetLevel, success, fail, status)
    local heroEquipmentOneKeyCraftRequest = {actorId = actorId, targetLevel = targetLevel}
    local request = { api = "HERO_EQUIPMENT_ONE_KEY_CRAFT", heroEquipmentOneKeyCraftRequest = heroEquipmentOneKeyCraftRequest}
    self:requestPackageHandler("HERO_EQUIPMENT_ONE_KEY_CRAFT", request, success, fail)
end

--  退出场景;                                               // 目标等级
function QClient:quitScene(scene, success, fail, status)
    local sceneRequest = {isQuit = true, scene = scene}
    local request = { api = "USER_SCENE_ACTION", sceneRequest = sceneRequest}
    self:requestPackageHandler("USER_SCENE_ACTION", request, success, fail)
end

return QClient
