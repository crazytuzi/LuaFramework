
local zlib = require("zlib")
local QWebSocket = class("QWebSocket")

local QUIViewController = import("..ui.QUIViewController")
local QUIWidgetLoading = import("..ui.widgets.QUIWidgetLoading")
local QErrorInfo = import("..utils.QErrorInfo")

local PING_INTERVAL = 10
local RETRY_INTERVAL = 1
local CONNECT_TIMEOUT = 15
local SEND_TIMEOUT = 10

local NETWORK_ERROR = {code = "NETWORK_ERROR"}

QWebSocket.TEXT_MESSAGE = 0
QWebSocket.BINARY_MESSAGE = 1
QWebSocket.BINARY_ARRAY_MESSAGE = 2

QWebSocket.STATUS_WAITING = 0
QWebSocket.STATUS_SENDING = 1
QWebSocket.STATUS_RETRY = 2
QWebSocket.STATUS_COMPLETED = 3

QWebSocket.EVENT_CONNECTED = "CONNECTED"
QWebSocket.EVENT_DISCONNECTED = "DISCONNECTED"

function QWebSocket:ctor(url)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self.url = url

    self.isFrist = true

    self:_connect()
    self._timer = scheduler.scheduleGlobal(handler(self, QWebSocket._onTimer), 0.5)

    self._lastPing = q.time()
    self._lastRetry = q.time()

    self._connSuccess = success
    self._connFail = fail
    
    self.sending = {}
    self.pingOK = false

    self._timeAlign = 0 -- 用于与服务器的时间校准
    self._uuid = UUID()
end

function QWebSocket:_connect()
    if self.socket ~= nil and self.socket:getReadyState() == kStateConnecting and q.time() - self._lastConnect > CONNECT_TIMEOUT then
        -- close, self.socket will be nil, and then retry
        printInfo("connect timeout")
        self:_closeLoading()
        self:close()
    end

    if self.socket == nil then
        printInfo("connecting: "..self.url)
        self.socket = WebSocket:create(self.url)
        self._lastConnect = q.time()
        if self.isFrist == false then
            self:_showLoading()
        else    
            self.isFrist = true
        end
        if self.socket then
            self.socket:registerScriptHandler(handler(self, self._onOpen), kWebSocketScriptHandlerOpen)
            self.socket:registerScriptHandler(handler(self, self._onMessage), kWebSocketScriptHandlerMessage)
            self.socket:registerScriptHandler(handler(self, self._onClose), kWebSocketScriptHandlerClose)
            self.socket:registerScriptHandler(handler(self, self._onError), kWebSocketScriptHandlerError)
        end
    end
end

function QWebSocket:isReady()
    return self.socket and self.socket:getReadyState() == kStateOpen and self.pingOK
end

--[[
通过websocket发送数据，参数如下：
invoke - 需要调用的远程API的入口
data - 发送过去的数据，table类型或者nil，数据进来后会被转换为json字符串
retry - 数字，是否需要重试
success - 发送成功后接收到的返回回调，毁掉函数接收参数为一个json数据包
fail - 发送失败的回调
isShow - 是否显示转菊花
--]]
function QWebSocket:send(invoke, data, retry, success, fail, status, isShow, isProtobuf)
    if isShow == nil then
        isShow = true
    end
    meta = { invoke = invoke, isShow = isShow }
    meta.compressed = false
    meta.id = self._uuid .. "-" .. tostring(uuid()) --tostring(q.time())
    meta.length = 0
    if self.session then
        meta.session = self.session
    end

    local strData = nil
    if isProtobuf == true then
        strData = data
        meta.binary = true
    else
        strData = json.encode(data)
        meta.binary = false
    end

    local rawData = ""
    if data ~= nil and strData ~= nil then
        rawData = strData
        meta.length = string.len(strData)
        if meta.length > 200 then
            local deflated, eof, rawLength, length = zlib.deflate()(strData, "finish")
            strData = deflated
            meta.length = length
            meta.compressed = true
        end
    else
        strData = ""
    end

    local strMeta = json.encode(meta)
    local len = string.len(strMeta)

    local str = string.char(len % 255, math.floor((len / 255)) % 255, math.floor((len / 255 / 255)) % 255, math.floor((len / 255 / 255 / 255)) % 255)

    local pkg =  str .. strMeta .. strData
    local cipher = QUtility:encrypt(pkg, string.len(pkg))
    if cipher ~= nil then
        pkg = 'E' .. cipher
    else
        pkg = 'P' .. pkg
    end

    if retry == nil then retry = 0 end

    self.sending[meta.id] = { data = pkg, meta = meta, retry = retry, send = 1, time = q.time(), success = success, fail = fail, status = status }

    if DEBUG_NETWORK and meta.invoke ~= "ping" then
        if isProtobuf == true then
            printInfo("<<< self.sending data:" .. strMeta)
        else
            printInfo("<<< self.sending data:" .. strMeta .. ", " .. rawData)
        end
    end

    if meta.invoke ~= "ping" and meta.isShow == true then
        if QUIWidgetLoading.sharedLoading() ~= nil then
            QUIWidgetLoading.sharedLoading():Show()
        end
    end

    if self:isReady() then
        self.sending[meta.id].result = true
        self.sending[meta.id].send = 0

        if status ~= nil then
            status(QWebSocket.STATUS_SENDING)
        end



        self.socket:sendBinaryStringMsg(pkg)
    else
        if status ~= nil then
            status(QWebSocket.STATUS_WAITING)
        end
        if self.sending[meta.id].retry == 0 then self.sending[meta.id].retry = 1 end
        self.sending[meta.id].result = false -- will be handled later by retry process
    end
end

function QWebSocket:_onTimer()
    self:_ping()
    self:_checkTimeOut()
    self:_retry()
end

function QWebSocket:_checkTimeOut()
    local now = q.time()
    for id, send in pairs(self.sending) do
        if now - send.time > SEND_TIMEOUT then
            send.result = false -- mark as failed and wait for next retry
        end
    end
end

function QWebSocket:_retry()
    if q.time() - self._lastRetry < RETRY_INTERVAL then return end

    if not self:isReady() then return end
    
    self._lastRetry = q.time()

    for id, send in pairs(self.sending) do
        if send.result == false then
            if send.retry == 0 then
                self.sending[id] = nil
            else
                send.retry = send.retry - 1
                send.send = send.send + 1
                send.time = q.time()
                send.result = true -- avoid next retry
                printInfo("retrying invoke:" .. send.meta.invoke .. ", sent: " .. send.send)

                if send.status ~= nil then
                    if send.send <= 1 then
                        send.status(QWebSocket.STATUS_SENDING)
                    else
                        send.status(QWebSocket.STATUS_RETRY)
                    end
                end

                self.socket:sendBinaryStringMsg(send.data)
                return -- just retry self.sending the first one
            end
        end
    end
end

function QWebSocket:_ping()
    if not (self.socket and self.socket:getReadyState() == kStateOpen) then
        self:_connect()
        return
    end

    if q.time() - self._lastPing < PING_INTERVAL then return end

    self._lastPing = q.time()

    self:send("ping", nil, 0, function()
        self.pingOK = true
    end, function()
        self.pingOK = false
    end)
end

function QWebSocket:close()
    if self.socket then
        self.socket:close()
        self.socket = nil
    end
    self:removeAllEventListeners()

    self:dispatchEvent({name = QWebSocket.EVENT_DISCONNECTED})
end

function QWebSocket:clearTime()
    if self._timer ~= nil then
        scheduler.unscheduleGlobal(self._timer)
        self._timer = nil
    end
end

function QWebSocket:_onOpen()
    printInfo("Websocket open")
    self.pingOK = true

    -- if self._alert ~= nil then
    --     self._alert:close()
    --     self._alert = nil
    -- end
    self:dispatchEvent({name = QWebSocket.EVENT_CONNECTED})
end

function QWebSocket:_onMessage(message, messageLength)
    local msgType = string.sub(message, 1, 1)
    if msgType == 'E' then
        -- 经过加密的传输
        message = QUtility:decrypt(string.sub(message, 2), messageLength - 1)
        messageLength = string.len(message)
    elseif msgType == 'P' then
        -- 没有加密的传输
        message = string.sub(message, 2)
        messageLength = messageLength - 1
    else
        printError("ERROR data protocol: %s", message)
        return
    end

    local a, b, c, d = string.byte(message, 1, 4)
    local metaLength = a + b * 255 + c * 255 * 255 + d * 255 * 255 * 255

    local strMeta = string.sub(message, 5, metaLength + 4);
    local meta = json.decode(strMeta)

    local strData = string.sub(message, metaLength + 5);
    if string.len(strData) ~= meta.length then
        printError("error on received message: " .. message)
    else 
        if meta.compressed == true then
            local inflated, eof = zlib.inflate()(strData)
            if eof == true and inflated ~= nil then
                strData = inflated
            else
                printError("decompress error: " .. strData)
            end
        end
    end

    local data = json.decode(strData)
    local send = self.sending[meta.id]

    if send ~= nil and send.meta.invoke ~= "ping" then
        if DEBUG_NETWORK and meta.invoke ~= "ping" then
            local reducedStr = strData
            if string.len(strData) > 4 * 1024 then
                reducedStr = string.sub(strData, 1, 4 * 1024) .. " ..."
            end
            printInfo(">>> recevied data:" .. strMeta .. ", " .. reducedStr)
        end
        printInfo(send.meta.invoke .. " time elapsed(s): %.3f second(s)", (q.time() - send.time))
    else
        self._timeAlign = (meta.serverTime + 0.5) - q.time() -- 服务器时间 + 0.5(估计的网络传输时间)
    end

    if meta.succeeded == true then
        -- 统一处理数据更新，然后发出event，让observer进行修改
        print("laytest 10003")
        remote:updateData(data)
    end

    if send ~= nil then
        self.sending[meta.id] = nil

        --校准服务器时间
        local currTime = q.time()
        if (currTime - send.time) < 500 then
            remote.serverTime = meta.serverTime
            remote.serverResTime = currTime
        end

        if send.status ~= nil then
            send.status(QWebSocket.STATUS_COMPLETED)
        end
        if QUIWidgetLoading.sharedLoading() then
            QUIWidgetLoading.sharedLoading():Hide()
        end
        if meta.succeeded == true and send.success ~= nil then
            send.success(data)
        end
        if meta.succeeded ~= true then
            if send.fail ~= nil then
                send.fail(data)
            elseif app ~= nil then
                QErrorInfo:handle(data.code)
            end
        end
    end
end

function QWebSocket:timeAlign()
    return self._timeAlign
end

function QWebSocket:_showLoading()
    if QUIWidgetLoading.sharedLoading() and self._alert == nil then
        QUIWidgetLoading.sharedLoading():Show()
    end
end

function QWebSocket:_closeLoading()
    if QUIWidgetLoading.sharedLoading() then
        QUIWidgetLoading.sharedLoading():Hide()
    end
end

function QWebSocket:_onClose()
    printInfo("websocket close")
    self:_closeLoading()
    self.pingOK = false
    self.socket = nil
    self:close()
    self:_handleSendQueueOnError()
end

function QWebSocket:_onError(error)
    printInfo("websocket error")
    self:_closeLoading()
    printInfo(error)
    self.pingOK = false
    self.socket = nil

    self:_handleSendQueueOnError()
end

function QWebSocket:_handleSendQueueOnError()
    local sendingRetry = {}
    for id, send in pairs(self.sending) do
        if send.retry > 0 then
            send.result = false -- so retry can handle it later
            sendingRetry[id] = send
        else
            if send.fail ~= nil then
                if send.status ~= nil then
                    send.status(QWebSocket.STATUS_COMPLETED)
                end
                send.fail(NETWORK_ERROR)
            end
        end
    end

    self.sending = sendingRetry
    self:dispatchEvent({name = QWebSocket.EVENT_DISCONNECTED})
end

return QWebSocket
