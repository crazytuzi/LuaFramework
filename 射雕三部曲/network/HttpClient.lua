--[[
    文件名: HttpClient.lua
    描述：Http请求和响应模块封装
    创建人：liaoyuangang
    创建时间：2016.4.1
-- ]]

require("data.Player")
require("network.NetworkStates")

-- http 请求服务器类型
HttpSvrType = {
    eGame = 0, -- 游戏业务服务器，
    eMqkkAccount = 1, -- 摩奇卡卡账户服务器
    eManageCenter = 2, -- ManageCenter 服务器，用于获取服务器列表
}

HttpClient = {
    mIsRequesting = false, -- 当前是否正在请求网络
    mRequestQueue = {}, -- 缓存网络http请求数据
}

-- Android只在Debug下才输出，不会影响性能
function httpDataDump(description, response)
    --if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
    --    dump(response, description)
    --end

    local file = io.open(cc.FileUtils:getInstance():getWritablePath() .. "httpDataDump.txt", "a+")
    file:write(description)
    file:write(cjson.encode(response) .. "\n")
    file:close()
end

-- 页面提示错误
local function showHintLayer(hintStr, jumpLogin)
    local okBtnInfo = {
        text = TR("确定"),
        clickAction = function(layerObj, btnObj)
            if jumpLogin then
                -- 通知渠道已登出游戏
                IPlatform:getInstance():logout()
                -- 跳转到登录页面
                LayerManager.addLayer({name = "login.GameLoginLayer", data = {notAutoLogin = true}})
            else
                LayerManager.removeLayer(layerObj)
            end
        end,
    }
    LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = {
            title = TR("提示"),
            msgText = hintStr,
            btnInfos = {okBtnInfo},
        },
        zOrder = Enums.ZOrderType.eNetErrorMsg,
        cleanUp = false
    })
end

-- 处理游戏服务器网络请求回调数据
--[[
-- 参数
    statusCode: http请求返回的状态码
    response: http请求返回的数据
    needModifyCache: 是否需要修改缓存，默认为: true
]]
local function dealGameResponse(statusCode, response, needModifyCache)
    if statusCode == 200 then
        local svrStatus = response.Status -- 服务器返回的状态码，0 表示成功，其他负数表示失败
        if svrStatus == 0 then
            if needModifyCache ~= false then
                HttpClient:modifyCache(response)
            end

            -- 更新为服务器当前时间
            if response.TimeTick then
                Player:updateTimeTick(response.TimeTick)
            end
        elseif svrStatus == -1118 then -- 金币不足
            HttpClient.mRequestQueue = {}
            MsgBoxLayer.addGetGoldHintLayer()
        elseif svrStatus == -1101 or -- "已经登录", 登录已过期，需要重新登录
                svrStatus == -1102 or -- 玩家账号被锁定
                svrStatus == -46 or --SessionId 已经过期
                svrStatus == -2 or -- 服务器在维护中
                svrStatus == -3 then -- 系统错误
            HttpClient.mRequestQueue = {}
            if svrStatus == -2 and not Player.mIsLogin then -- 如果在玩家未登录时服务器维护，不需要弹出到账户登录页面
                showHintLayer(ErrorcodeRelation.items[svrStatus].description)
            else
                showHintLayer(ErrorcodeRelation.items[svrStatus].description, true)
            end
        elseif svrStatus == -1103 then -- 玩家数据错误
        elseif svrStatus == -9103 then -- 玩家数据错误
        elseif svrStatus == -10003 then -- 玩家数据错误(桃花岛不存在队伍)
        elseif svrStatus == -9704 then -- 不存在拜师信息(特殊需求处理)
        elseif svrStatus == -14400 or svrStatus == -14418 then -- 江湖杀队伍不存在
            -- todo 暂时不处理这种错误状态
        elseif svrStatus == -3444 then -- 有玩家先出价了，请重新出价竞拍
        elseif svrStatus == -11003 then -- 少侠手慢了，该商品已被别人拍走
        elseif svrStatus == -8 then -- "有新的资源版本"\
            HttpClient.mRequestQueue = {}

            local okBtnInfo = {
                text = TR("确定"),
                clickAction = function(layerObj, btnObj)
                    IPlatform:getInstance():openUrl(response.Value)
                end,
            }
            local cancelBtnInfo = {
                text = TR("退出"),
                clickAction = function(layerObj, btnObj)
                    IPlatform:getInstance():destroy()
                end,
            }
            LayerManager.addLayer({
                name = "commonLayer.MsgBoxLayer",
                data = {
                    title = TR("提示"),
                    msgText = TR("您的客户端需要升级，是否前往下载？"),
                    bgSize = cc.size(570, 400),
                    btnInfos = {okBtnInfo, cancelBtnInfo},
                },
                zOrder = Enums.ZOrderType.eNetErrorMsg,
                cleanUp = false
            })
        elseif svrStatus == -9 then -- "有在线更新的资源"， 跳转到开始游戏页面
            HttpClient.mRequestQueue = {}  
            LayerManager.addLayer({name = "login.StartGameLayer", data = {}})
            -- 清空缓存数据
            Player:cleanCache()
            --清空聊天按钮
            ChatBtnLayer:clearBtn()
        else
            local hintStr = ErrorcodeRelation.items[svrStatus] and ErrorcodeRelation.items[svrStatus].description
            if not hintStr then
                hintStr = string.format(TR("未知错误,错误码(%d)"), svrStatus)
            end
            ui.showFlashView({text = TR("提示:")..hintStr})
        end
    elseif statusCode == -1 then
        ui.showFlashView({text = TR("请检查当前网络连接是否可用。")})
    elseif statusCode == 403 then
        HttpClient.mRequestQueue = {}
        ui.showFlashView({text = TR("当前服务器暂未开放，敬请期待~")})
    elseif (statusCode == 503 or statusCode == 404) or (statusCode == 302) or (statusCode == 500) then
        HttpClient.mRequestQueue = {}
        showHintLayer(TR("服务器正在维护或已关闭，请重新登录"), true)
    else
        HttpClient.mRequestQueue = {}
        showHintLayer(TR("服务器未知错误，请联系客服！"), true)
    end
end

-- 处理摩奇卡卡账户服务器网络请求回调数据
--[[
-- 参数
    statusCode: http请求返回的状态码
    response: http请求返回的数据
]]
local function dealMqkkAccountResponse(statusCode, response)
    if statusCode ~= 200 then
        ui.showFlashView(TR("请检查当前网络连接是否可用。"))
        return
    end

    local svrStatus = response and response.State or 0
    if svrStatus ~= 1 then
        local tempStr = NetworkStates.account[svrStatus] or string.format(TR("未知错误,错误码(%d)"), svrStatus)
        ui.showFlashView(tempStr)
        return
    end
end

-- 处理服务器列表服务器网络请求回调数据
--[[
-- 参数
    statusCode: http请求返回的状态码
    response: http请求返回的数据
]]
local function dealServerListResponse(statusCode, response)

end

-- 获取游戏业务请求的 "post" url 和 数据
--[[
-- 参数 params HttpClient:request 接口的参数
-- 返回值 为
    第一个返回值：cc.XMLHttpRequest 对象 post 的url
    第二个返回值：cc.XMLHttpRequest 对象 send 的数据
]]
local function getGameSvrPostData(params)
    local userLoginInfo = Player:getUserLoginInfo()
    local platform = IPlatform:getInstance()
    local serverInfo = Player:getSelectServer()

    local postData = {PlayerId = "", Session = ""}
    -- 如果不是游戏登录接口
    if "Player" ~= params.moduleName or "Login" ~= params.methodName then
        local playerInfo = PlayerAttrObj:getPlayerInfo()
        if playerInfo then
            postData.PlayerId = playerInfo.PlayerId
            postData.Session = playerInfo.Session
        end
    end
    postData.PartnerId = userLoginInfo and userLoginInfo.PartnerId or platform:getConfigItem("PartnerID")
    postData.ServerId = serverInfo.ServerID
    postData.GameVersionId = platform:getConfigItem("Version")
    postData.ResourceVersionName = LocalData:getResourceName()
    postData.MAC = platform:getDeviceMAC()
    postData.IDFA = platform:getDeviceUUID()
    postData.ModuleName = params.moduleName
    postData.MethodName = params.methodName
    postData.Data = params.svrMethodData
    postData.SendTick = Player:getCurrentTime()
    postData.ExtensionString = params.guideInfo and {GuideInfo = params.guideInfo} or ""

    local retUrl = serverInfo.ServerUrl.."/client.aspx" .. "?" .. math.random(99, 9999)
    local retData = json.encode(postData)
    print("GameSvrPost url:", retUrl)
    print("PostData:", retData)

    return retUrl, retData
end

-- 获取服务器列表请求的 "post" url 和 数据
--[[
-- 参数 params HttpClient:request 接口的参数
-- 返回值 为
    第一个返回值：cc.XMLHttpRequest 对象 post 的url
    第二个返回值：cc.XMLHttpRequest 对象 send 的数据
]]
local function getServerListPostData(params)
    --local retUrl = IPlatform:getInstance():getConfigItem("ManageCenter")
    local retUrl = "http://49.232.79.93:88/login_tw/API/ServerList_Client.ashx"
    local tempList = {}
    for key, value in pairs(params.svrMethodData or {}) do
        table.insert(tempList, string.format("%s=%s", key, tostring(value)))
    end
    local retData = table.concat(tempList, "&")
    print("ServerListPost url:", retUrl)
    print("PostData:", retData)

    return retUrl, retData
end

-- 获取摩奇卡卡账户服务器请求的 “get” url
--[[
-- 参数 params HttpClient:request 接口的参数
-- 返回值 为
    第一个返回值：cc.XMLHttpRequest 对象 post 的url
]]
local function getMqkkAccountUrl(params)
    HttpClient:initEncodeKey("shenmo" .. "_moqikaka_" .. "shenmo")

    local tempList = {"appid=99"}
    for key, value in pairs(params.svrMethodData or {}) do
        table.insert(tempList, string.format("%s=%s", key, value))
    end
    local tempStr = table.concat(tempList, "&")
    local signString = HttpClient.DataEncodeClass:EncryptDataAndBase64(tempStr, string.len(tempStr))
    signString = string.gsub(signString, "\r\n", "") --替换掉回车换行
    signString = string.md5Content(signString) --MD5签名

    local retUrl = string.format("http://passport.moqikaka.com/sdk/%s?%s&sign=%s", params.urlName, tempStr, signString)
    print("MqkkAccountUrl:", retUrl)

    return retUrl
end

-- 设置请求的加密key
function HttpClient:initEncodeKey(key)
    if not self.DataEncodeClass then
        self.DataEncodeClass = CommunicationDataEncodeClass:new()
        self.DataEncodeClass:SetKey(key)
    end
end

--- 发起网络请求
--[[
-- 参数 params 中各个字段为
    {
        svrType: 请求服务器类型, 默认为游戏业务服务器(HttpSvrType.eGame)
        urlName: 摩奇卡卡账户服务器请求名称(比如："Register", "login", "Default", ...)，当svrType == HttpSvrType.eMqkkAccount 时有效
        moduleName:模块接口名称, 参看PS1
        methodName: 对应moduleName下的方法名,参见PS1
        svrMethodData:服务器端接口需要的参数表，以table方式打包传入即可
        useUnzip: 是否使用解压缩内容，默认true. 摩奇卡卡账户登录时才需要设置为false
        useDecrypt: 是否使用解密，默认为true, 服务器列表获取时需要设置为false
        callback: 网络响应的回调处理
        callbackNode: 网络响应的回调处理的Node对象，如果该参数不为nil，在调用callback时需要检查该对象是否被销毁
        needWait: 是否需要屏蔽等待页，默认为使用true, 仅该参数为false时禁用
        autoModifyCache: 是否把物品掉落信息和avatar信息自动修改到本地缓存中，默认为true，如果为false则需要调用者在适当的时候调用 HttpClient:modifyCache 接口
        guideInfo: 引导信息
    }
]]
function HttpClient:request(params)
    if not params then
        return
    end
    params.svrType = params.svrType or HttpSvrType.eGame

    -- 如果当前有网络请求未返回，则缓存网络请求数据
    if self.mIsRequesting then
        table.insert(self.mRequestQueue, params)
        return
    end

    -- 整理 http 请求的 url 和 post data
    local url, postData, openType, responseType
    if params.svrType == HttpSvrType.eGame then
        url, postData = getGameSvrPostData(params)
        openType = "POST"
        responseType = cc.XMLHTTPREQUEST_RESPONSE_BLOB
    elseif params.svrType == HttpSvrType.eManageCenter then
        url, postData = getServerListPostData(params)
        openType = "POST"
        responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    elseif params.svrType == HttpSvrType.eMqkkAccount then
        url = getMqkkAccountUrl(params)
        openType = "GET"
        responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    end

    if params.needWait ~= false then
        ui.lockLayer()
    end
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = responseType
    xhr:open(openType, url)
    xhr:setUnzip(params.useUnzip ~= false)
    xhr.timeout = 30
    xhr:registerScriptHandler(function(event)
        if params.needWait ~= false then
            ui.unlockLayer()
        end
        self.mIsRequesting = false

        local statusCode, response = xhr.status, {Status = -99999, Message = TR("请检查当前网络连接是否成功")}
        if event == "SUCCESS" and statusCode == 200 then
            -- 检查是否应该加密
            if params.svrType == HttpSvrType.eGame then
                response = cjson.decode(xhr.response)
                httpDataDump("Response1: ", response)
                local modifyCach = params.autoModifyCache ~= false
                if not params.callback or params.callbackNode and tolua.isnull(params.callbackNode) then
                    modifyCach = true
                end
                dealGameResponse(statusCode, response, modifyCach)
            else
                local responsecontent = xhr.response
                if params.useDecrypt ~= false then
                    HttpClient:initEncodeKey("shenmo" .. "_moqikaka_" .. "shenmo")
                    responsecontent = self.DataEncodeClass:DecryptDataWithBase64(xhr.response)
                end
                response = cjson.decode(responsecontent)
                httpDataDump("Response2: ", response)
                if params.svrType == HttpSvrType.eMqkkAccount then
                    dealMqkkAccountResponse(statusCode, response)
                end
            end
        else
            ui.showFlashView(response.Message)
            httpDataDump("Response3: ", response)
        end

        -- 调用回调函数
        local tempNode = params.callbackNode
        if params.callback and (tempNode and not tolua.isnull(tempNode) or not tempNode) then
            params.callback(response)
        end

        if #self.mRequestQueue > 0 then
            local reqInfo = self.mRequestQueue[1]
            table.remove(self.mRequestQueue, 1)
            if reqInfo then
                self:request(reqInfo)
            end
        end
    end)
    xhr:send(postData)
    self.mIsRequesting = true
    
    httpDataDump("Url: ", url)
    httpDataDump("Data: ", postData)
end

-- 根据服务器返回的数据修改本地缓存数据，比如把掉落物品和avatar信息
--[[
-- 参数 
    response: http请求返回的数据
]]
function HttpClient:modifyCache(response)
    if not response or response.Status ~= 0 then
        return 
    end

    -- 统一处理Avatar数据更新
    if response.Avatar then
        Player:updateAvatar(response.Avatar)
    end

    -- 处理帮派Avatar数据更新
    if response.GuildAvatar then
        GuildObj:updateGuildAvatar(response.GuildAvatar)
    end

    -- 统一处理物品掉落物品添加到缓存数据（不处理在Avatar中已经更新缓存的数据）
    if response.Value and type(response.Value) == "table" then
        Player:addDropToResData({
            BaseGetResource = response.Value.BaseGetGameResourceList,
            ChiceResource = response.Value.ChoiceGetGameResource,
            ExtraGetResource = response.Value.ExtraGetGameResource,
        })
    end
end

--[[
   key:
   value:
-- ]]
function HttpClient:hitPoint(key, value)
    HttpClient:request({
        moduleName = "Player",
        methodName = "HitPoint",
        svrMethodData = {key, value},
        needWait = false,
        callback = function(data)
        end,
    })
end