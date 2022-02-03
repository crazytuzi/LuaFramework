----------------------------------------------------
---- SDK相关调用
---- @author whjing2011@gmail.com
------------------------------------------------------

-- SDK公共调用接口 返回1:成功 其它:失败
function sdkCallFunc(funname, str1, num1, num2, str2)
    if funname == nil or funname == "" then return "" end
    str1 = str1 or ""
    num1 = num1 or 0
    num2 = num2 or 0
    str2 = str2 or ""
    return device.sdkCallFunc(funname, str1, num1, num2, str2)
end

-- SDK登录请求
function sdkOnLogin()
    if DIRECTTOONLOGIN == true then
        if sdkOnLoginBackInfo == nil then -- 如果还没有登录过
            sdkOnLoginFlag = true
            sdkCallFunc("login")
        else
            delayOnce(function() 
                LoginPlatForm:getInstance():onLoginInfo(sdkOnLoginBackInfo)
            end, 0.3)
        end
    else
        sdkOnLoginFlag = true
        sdkCallFunc("login")
    end
end

-- SDK登录回调
function sdkBackLogin(code, msg)
    if DIRECTTOONLOGIN == true then
        if code == 1 then
            sdkOnLoginBackInfo = msg
            if FileUpdate_Instance then
                FileUpdate_Instance:realDownLoadFinishFunc()
            end
        else
            sdkOnLogin()
        end
    else
        if code == 1 then
            LoginPlatForm:getInstance():onLoginInfo(msg)
        else
            sdkOnLogin()
        end
    end
end

-- 判断SDK能否切换账号
function sdkCanSwitchAccount()
    if PLATFORM == cc.PLATFORM_OS_IPHONE or PLATFORM == cc.PLATFORM_OS_MAC then
        return true
    elseif IS_PLATFORM_LOGIN and CALL_SDK_SWITCH_ACCOUNT ~= false then
        return sdkCallFunc("isSwitchAccount") == 1
    else
        return true
    end
end

-- SDK切换账号请求
function sdkOnSwitchAccount()
    if GAME_INITED == nil then return end
    GAME_INITED = nil
    if CALL_SDK_SWITCH_ACCOUNT == 1 then
        sdkCallFunc("switchAccount")
        if not LoginPlatForm then return end
        LoginPlatForm:getInstance():onLogout()
    elseif CALL_SDK_SWITCH_ACCOUNT ~= false and sdkCallFunc("isSwitchAccount") == 1 then
        sdkCallFunc("switchAccount")
    else
        LoginPlatForm:getInstance():onLogout()
    end
end

-- 判断能否显示用户中心 -- gotoCommunity
function sdkCanShowAccountCenter()
    return sdkCallFunc("isShowAccountCenter") == 1
end

-- 显示用户中心请求
function sdkShowAccountCenter()
    sdkCallFunc("showAccountCenter")
end

-- 请求退出应用
function sdkOnExit()
    if NEED_CALL_CLOSE_APP == true then
        callFunc("callBackCloseApp");
    else
        cc.Director:getInstance():endToLua()
    end
    if IS_IOS_PLATFORM == true then
        os.exit()
    end
end

-- SDK数据上报处理
-- 选择服务器 dataType为1；创建角色的时候，dataType为2；进入游戏时，dataType为3；等级提升时，dataType为4；退出游戏时，dataType为5
function sdkSubmitUserData(dataType, rdata)
    local loginData = LoginController:getInstance():getModel():getLoginData() 
    if loginData.srv_id == "" then return end
    if dataType == 1 --[[and log_select_server]] then
        -- log_select_server(loginData.usrName)
        if log_select_flag then return end
        log_select_flag = true
    elseif dataType == 2 --[[ and log_create_role ]] then
        -- log_create_role(loginData.usrName)
    end
    local account = LoginPlatForm:getInstance():getInfo().openid
    local roleVo = RoleController:getInstance():getRoleVo() or rdata
    local serverId = serverId(roleVo and roleVo.srv_id or loginData.srv_id)
    local serverName = loginData.srv_name
    local roleId = roleVo and roleVo.rid or 0
    local roleName = roleVo and roleVo.name or ""
    local roleCTime = roleVo and roleVo.reg_time or 0
    local roleLev = roleVo and roleVo.lev or 1
    local vipLev = roleVo and roleVo.vip_lev or 0
    local gold = roleVo and roleVo.gold or 0
    local power = roleVo and roleVo.power or 0
    local channel = device.getChannel()
    if channel == "66_1" then
        serverId = PLATFORM_NAME.."_"..serverId
    end

    -- 贪玩上报服务器id
    if FINAL_CHANNEL == "tanwan_mixios" and MAKELIFEBETTER == true then
        serverId = 123456789
    end

    -- 如果是9377的
    if IS_IOS_PLATFORM == true and PLATFORM_NAME == "9377ios" and dataType == 2 then
        local info = table.concat({1, serverId, serverName, roleId, roleName, roleCTime, roleLev, gold, vipLev, power, account}, "#")
        sdkCallFunc("submitExtraData", info)
    end

    local info = table.concat({dataType, serverId, serverName, roleId, roleName, roleCTime, roleLev, gold, vipLev, power, account}, "#")
    sdkCallFunc("submitExtraData", info)
end

-- SDK充值处理
function sdkOnPay(money, buyNum, prodId, productName, productDesc)
    -- 游客模式下,且非认证的用户,调用充值,会弹出认证确认面板,如果游客模式允许跳过则不判断,个别渠道允许跳过
    if NEED_CHECK_VISITIOR_STATUS and DO_NOT_REALNAME_STATUS and (not ALLOW_SKIP_RECHARGE) then 
        OPEN_SDK_VISITIOR_WINDOW = true
        callFunc("touristMode", "10")
    else
        local loginData = LoginController:getInstance():getModel():getLoginData()
        local roleVo = RoleController:getInstance():getRoleVo()
        if not roleVo then return end
        local productId = string.format("%s.%s", callFunc("package_name"), prodId)
        if PAY_ID_FUNC then
            productId = PAY_ID_FUNC(prodId, money)
        elseif PAY_ID_NORMAL then
            productId = prodId
        end
        local config = Config.ChargeData.data_charge_data[prodId]
        if config and config.val ~= money then return end
        productName = productName or (money * 10)..TI18N("钻石")
        productDesc = productDesc or productName
        local price = money
        if USE_RMB_FEN then
            price = money * 100
        end
        buyNum = buyNum or 1
        local srvData = loginData
        local channel = LoginPlatForm:getInstance():getChannel()
        local gold = roleVo.gold
        local platform, serverId = unpack(Split(roleVo.srv_id, "_"))
        local serverName = srvData.srv_name
        local roleId = roleVo.rid
        local roleName = roleVo.name
        local roleLev = roleVo.lev
        local vip = "vip"..roleVo.vip_lev
        local ext = roleVo.rid.."$$"..platform.."$$"..serverId.."$$"..channel.."$$"..prodId.."$$"..productName
        local host = srvData.host
        local account_id = LoginPlatForm:getInstance():getUId()

        -- 冰鸟的英灵勇士充值的特殊处理
        if IS_IOS_PLATFORM == true and not MAKELIFEBETTER and FINAL_CHANNEL == "bingniao_bnylys" and ICEBIRD_USERID then
            iceBirdOnPay(productId, productName, productDesc, price, buyNum, gold, serverId, serverName, roleId, roleName, roleLev, vip, ext, host)
        else
            local info = table.concat({productId, productName, productDesc, price, buyNum, gold, serverId, serverName, roleId, roleName, roleLev, vip, ext, host, channel, account_id}, "#")
            if (IS_IOS_PLATFORM == true and FINAL_CHANNEL == "syios_sszgzssx") or (FINAL_CHANNEL == "release2") then   -- 如果是正式包,可能存在第三方
                RoleController:getInstance():requestThirdCharge(prodId, host, info)
            else
                if IS_SY_DAN then
                    sdkCallFunc("dan", info)
                else
                    sdkCallFunc("pay", info)
                end
            end
        end
    end
end

-- 冰鸟的特殊处理,直接吊起第三方支付
function iceBirdOnPay(productId, productName, productDesc, price, buyNum, gold, serverId, serverName, roleId, roleName, roleLev, vip, ext, host)
    -- 这里需要判断一下冰鸟的是否是第三方支付
    local check_url = string.format("https://maomao.aiyunlin.com/api/sw2?app_id=%s&device_id=%s&game_version=%s&money=%s&product_id=%s&user_id=%s&role_level=%s",
                                    "110000957", log_url_encode(getIdFa()), UPDATE_VERSION_MAX, price, productId, ICEBIRD_USERID, roleLev)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("POST", check_url)
    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local response   = xhr.response -- 原json字符串
            if response == "1" then  -- 切支付
                local cp_trade_no = string.format("%s-%s", FINAL_CHANNEL, os.time())
                local exdata = string.format("%s$$%s", ext, FINAL_CHANNEL)
                local notify_url = string.format("http://%s/api.php/pf/bingniao/dan/?extinfo=%s", host, exdata)
                local str_url = string.format("https://maomao.aiyunlin.com/index/web2?app_id=%s&app_role_id=%s&app_role_name=%s&cp_trade_no=%s&device_id=%s&notify_url=%s&os=%s&product=%s&product_id=%s&server_id=%s&total_fee=%s&user_id=%s&bundle_id=%s",
                                             "110000957", roleId, log_url_encode(roleName), log_url_encode(cp_trade_no), log_url_encode(getIdFa()), log_url_encode(notify_url), "ios", log_url_encode(productName), productId, serverId, price, ICEBIRD_USERID, "comylysbnd")
                sdkCallFunc("openSyW", str_url)
            else
                local info = table.concat({productId, productName, productDesc, price, buyNum, gold, serverId, serverName, roleId, roleName, roleLev, vip, ext, host}, "#")
                sdkCallFunc("dan", info)
            end
        else
            local info = table.concat({productId, productName, productDesc, price, buyNum, gold, serverId, serverName, roleId, roleName, roleLev, vip, ext, host}, "#")
            sdkCallFunc("dan", info)
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()
end

-- 打开五星评价页面
function evaluation()
    sdkCallFunc("other_info", "evaluation")
end

-- facebook活动页面
function facebookAct()
    local roleVo = RoleController:getInstance():getRoleVo()
    if not roleVo then return end
    local roleId = roleVo.rid
    local platform, serverId = unpack(Split(roleVo.srv_id, "_"))
    local info = table.concat({serverId, roleId, ""}, "#")
    sdkCallFunc("other_info", "facebookAct", 0, 0, info)
end

-- 更多充值接口
function morePay()
    local roleVo = RoleController:getInstance():getRoleVo()
    if not roleVo then return end
    local roleId = roleVo.rid
    local platform, serverId = unpack(Split(roleVo.srv_id, "_"))
    local info = table.concat({serverId, roleId, ""}, "#")
    sdkCallFunc("other_info", "morePay", 0, 0, info)
end

is_manling_platform = (PLATFORM_NAME == "manling" or PLATFORM_NAME == "mltest")

-- SDK初始化返回
function sdkBackInit(code, msg)
    if WAIT_SDK_INIT_SUC then
        if FileUpdate_Instance then
            FileUpdate_Instance:initConfig()
        end
    elseif sdkOnLoginFlag then
        sdkCallFunc("login")
        sdkOnLoginFlag = nil
    end
end

-- SDK退出游戏回调 要求弹出退出确认界面 回调
function sdkBackGamePopExitDialog(code, msg)
    sdkAlert(TI18N("确定现在退出游戏么?"),TI18N("确定"),function() 
        cc.Director:getInstance():endToLua()
    end, TI18N("取消"))
end

-- SDK切换平台账号回调
function sdkBackSwitchAccount(code, msg) 
    if not LoginPlatForm then return end
    if not restart then return end
    LoginPlatForm:getInstance():onLogout()
end

-- win端登陆完成的回调
function winLoginCallBack(code, output)
    if output == "" or output == nil then 
        cc.Director:getInstance():endToLua()
        return
    end
    local result = json.decode(output,1)
    if result.code ~= 0 then
        cc.Director:getInstance():endToLua()
        return
    end
    local response = string.gsub(result.msg, "\\\"", "\"")
    if string.find(response, "\"") == 1 then
        response = string.sub(response, 2)
    end
    if string.find(response, "\"") == string.len(response) then
        response = string.sub(response, 1, string.len(response) - 1)
    end
    -- 剔除掉可能存在的中文转义
    response = string.gsub(response, "\\\\", "\\")
    response = unicode2utf8(response)
    local login_data = json.decode(response, 1)
    if login_data == nil then 
        cc.Director:getInstance():endToLua()
        return
    end
    local extra_str = string.format("%s#%s#%s#%s#%s#%s#%s#%s#%s#%s#%s",login_data.usrName, login_data.usrName, login_data.zm_tick, "", login_data.zm_ts, login_data.rid, login_data.srv_id, login_data.ip, login_data.port, login_data.host, login_data.srv_name)
    sdkBackLogin(1, extra_str)
end

-- 吊起win端充值
function winOnPayCallBack(core, output)
    if output == "" or output == nil then 
        cc.Director:getInstance():endToLua()
        return
    end
    local result = json.decode(output,1)
    -- code    int 状态返回码
    -- msg string  状态信息
    -- 错误码：

    -- 错误代码    错误提示
    -- 0   成功
    -- -1  战盟未启动
    -- -2  战盟未登录
end

-- 冰鸟sdk登录成功返回
function sdkBackLogin_bingniao(code, msg)
    local sid, extra, gameId, appId, channelId = unpack(Split(msg, "#"))
    local appkey="5687d666f2eb1c22aac9c5e07cbaf173"
    local str = string.format("appId=%schannelId=%sextra=%sgameId=%ssid=%s%s", appId, channelId, extra, gameId, sid, appkey)
    local sign = cc.CCGameLib:getInstance():md5str(str)

    local body = "gameId=" .. gameId
    body = body .. "&appId=" .. appId
    body = body .. "&channelId=" .. channelId
    body = body .. "&extra=" .. log_url_encode(extra)
    body = body .. "&sid=" .. log_url_encode(sid)
    body = body .. "&sign=" .. sign
    ICEBIRD_APPID = appId
    sdkBackLogin_bingniao_req(body, 0)
end

function sdkBackLogin_bingniao_req(body, num, last_xhr) 
    if num > 2 then
        sdkAlert(TI18N("登录验证失败，需要重新登录"),TI18N("确定"),function() 
            LoginPlatForm:getInstance():onLogout()
        end)
        if last_xhr and error_log_report then
            error_log_report(string.format(TI18N("冰鸟二次验证失败,readyState=%s,status=%s,response=%s"), last_xhr.readyState, last_xhr.status, last_xhr.response or "nil"))
        end
        return
    end
    local url = URL_BINGNIAO_TOKEN or "https://token.aiyinghun.com/user/token"
    if IS_IOS_PLATFORM == true or ( not IS_IOS_PLATFORM and BUILD_VERSION > 6 ) then
        url = URL_BINGNIAO_TOKEN or "http://register.sszg.shiyuegame.com/index.php/misc/bingniao_token"
    end
    game_print("push_log==>", url, body)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("POST", url)
    xhr:registerScriptHandler(function()
        game_print("===log_result==>", xhr.readyState, xhr.response)
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local parseJson = function()
                local response = string.gsub(xhr.response, "\\", "")
                game_print("===log_result==>", xhr.readyState, response)
                ICEBIRD_RESP = response
                response = unicode2utf8(response) -- 将其中的unicode \uxxxx转化成正式字符串，不然在原生 json.decode 中会报错
                local jsonObj = json.decode(response,1)
                if jsonObj.ret == 0 and jsonObj.content and jsonObj.content.data and jsonObj.content.data.userId then
                    local userId = jsonObj.content.data.userId
                    ICEBIRD_ACCESSTOKEN = jsonObj.content.data.accessToken
                    ICEBIRD_SY_SIGN = jsonObj.sy_sign
                    ICEBIRD_USERID = userId
                    ICEBIRD_BODY = body
                    if jsonObj.sy_sign and jsonObj.sy_sign ~= cc.CCGameLib:getInstance():md5str(string.format("__sszg_2019__%s%s", userId, ICEBIRD_ACCESSTOKEN)) then
                        sdkBackLogin_bingniao_req(body, num + 1, xhr)
                        return
                    end
                    callFunc("bingxiao_login2", response, 1, 1, userId)
                else
                    sdkBackLogin_bingniao_req(body, num + 1, xhr)
                end
            end
            xpcall(parseJson, function() sdkBackLogin_bingniao_req(body, num + 1, xhr) end)
        else
            sdkBackLogin_bingniao_req(body, num + 1, xhr)
        end
    end)
    xhr:send(body)
end

-- 代金券
function sdkPerfer_prize()
    local appkey="JZ0PJRVzpUctYExk"
    local ts = GameNet:getInstance():getTime()
    local login_data = LoginController:getInstance():getModel():getLoginData()
    local project_id = 11
    local acc_id = login_data.usrName
    local str = string.format("acc_id=%s&project_id=%s&ts=%s%s", acc_id, project_id, ts, appkey)
    local sign = cc.CCGameLib:getInstance():md5str(str)

    local body = "acc_id=" .. acc_id
    body = body .. "&project_id=" .. project_id
    body = body .. "&sign=" .. sign
    body = body .. "&ts=" .. ts
    requestPerferDataList(body, 0)
end

function requestPerferDataList(body, num)
    if num > 2 then
        return
    end
    -- 请求URL返回的数据
    local url = "https://api-common.shiyue.com/cms/getAutoCoupon" --正式
    -- local url = "http://test-common-api.shiyue.com/cms/getAutoCoupon" --测试

    -- game_print("push_log==>", url, body)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("POST", url)
    xhr:registerScriptHandler(function()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local parseJson = function()
                local response = string.gsub(xhr.response, "\\/", "/")
                -- game_print("===log_result==>", xhr.readyState, response)
                response = unicode2utf8(response) -- 将其中的unicode \uxxxx转化成正式字符串，不然在原生 json.decode 中会报错
                local jsonObj = json.decode(response,1)
                if jsonObj.code == 0 and jsonObj.data and jsonObj.data.coupons and jsonObj.data.banner then
                    ActionController:getInstance():getModel():setPerferPrizeByJsonObj(jsonObj)
                    return
                else
                    requestPerferDataList(body, num + 1)
                end
            end
            xpcall(parseJson, function() requestPerferDataList(body, num + 1) end)
        else
            requestPerferDataList(body, num + 1)
        end  
    end)
    xhr:send(body)
end

-- SDK返回提示信息回调
function sdkBackInfo(code, msg)
end

-- eyou活动按钮显示 
function sdkBackEyouShowBtn(type, btn)
    if btn == "isShowFb" then
        EYOU_FB_BTN_STATUS = type -- facebook按钮显示状态(0:不显示 1：显示 2：显示+特效）
    elseif btn == "isMorePayShow" then 
        EYOU_MORE_PAY_BTN_STATUS = type -- 显示第三方更多充值 
    elseif btn == "isEvalShow" then
        EYOU_EVAL_BTN_STATUS = type -- 显示五星好评
    elseif btn == "isShowLive" then
        EYOU_LIVE_BTN_STATUS = type -- 显示直播
    end
end

--切换到后台 
function OnEnterBackground()
end

-- 切回前台
function OnEnterForeground()
end

-- 边玩边下
function OnFileDownloadRes(code, file)
end

function sdkAlert(msg, confirm_label, confirm_callback, cancel_label, cancel_callback)
    local scene = cc.Director:getInstance():getRunningScene()
    if not scene then
        scene = cc.Scene:create()
        cc.Director:getInstance():runWithScene(scene)
    end
    require("util.pathtool")
    require("common.common_function")
    require("game.login.view.sdk_view")
    local view = SdkView:create(scene)
    view:show(msg, confirm_label, confirm_callback, cancel_label, cancel_callback)
end

function test_log(...)
    if _test_log_file == nil then
        _test_log_file = io.open(cc.FileUtils:getInstance():getWritablePath().."test_log.txt","a")
    end
    _test_log_file:write(table.concat({"\r\n", ...}, "  "))
end

-- 包下载地址获取
function get_apk_url(callback)
    if _down_apk_url_ret then
        callback(_down_apk_url_ret)
    elseif DOWN_APK_URL then
        local url = DOWN_APK_URL
        local date_time = os.date("%Y-%m-%d %H:%M:%S")
        local channel = LoginPlatForm:getInstance():getChannel()
        url = url .. "?product_name=" .. GAME_CODE
        url = url .. "&date_time=" .. log_url_encode(date_time)
        url = url .. "&sign=" .. cc.CCGameLib:getInstance():logsign(date_time)
        url = url .. "&channel_name=" .. channel
        local xhr = cc.XMLHttpRequest:new()
        xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
        xhr:open("POST", url)
        xhr:registerScriptHandler(function()
            if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
                local parseJson = function()
                    local response = string.gsub(xhr.response, "\\", "")
                    response = unicode2utf8(response) -- 将其中的unicode \uxxxx转化成正式字符串，不然在原生 json.decode 中会报错
                    local jsonObj = json.decode(response,1)
                    if jsonObj.success == true then
                        _down_apk_url_ret = jsonObj
                    end
                    callback(jsonObj)
                end
                xpcall(parseJson, function() callback({success = false, message = "parse_json_error"}) end)
            else
                callback({success = false, message = "down_load_error"})
            end
        end)
        xhr:send()
    else
        callback({success = false, message = "not found DOWN_APK_URL"})
    end
end

-- 二维码下载处理
function download_qrcode_png(url, callback)
    local filename = "qrcode_"..string.match(url, "[^/]*.png")
    local filepath = cc.FileUtils:getInstance():getWritablePath().."assets/src/"..filename
    if cc.FileUtils:getInstance():isFileExist(filepath) and cc.FileUtils:getInstance():getFileSize(filepath) > 0 then
        callback(0, filepath)
    else
        function OnFileDownloadResult(state, name)
            if state == 0 and cc.FileUtils:getInstance():getFileSize(filepath) > 0 then
                callback(0, filepath)
            else
                cc.FileUtils:getInstance():removeFile(filepath)
                callback(1, filepath)
            end
        end
        cc.FmodexManager:getInstance():downloadOtherFile(url, filename)
    end
end
--代金券的图片
function download_perfer_png(url, callback)
    local pic_format = string.match(url,".+%.(%w+)$")
    local filename = ""
    if pic_format == "jpg" then
        filename = "perfer_"..string.match(url, "[^/]*.jpg")
    else
        filename = "perfer_"..string.match(url, "[^/]*.png")
    end
    local filepath = cc.FileUtils:getInstance():getWritablePath().."assets/src/"..filename
    if cc.FileUtils:getInstance():isFileExist(filepath) and cc.FileUtils:getInstance():getFileSize(filepath) > 0 then
        callback(0, filepath)
    else
        function OnFileDownloadResult(state, name)
            if state == 0 and cc.FileUtils:getInstance():getFileSize(filepath) > 0 then
                callback(0, filepath)
            else
                cc.FileUtils:getInstance():removeFile(filepath)
                callback(1, filepath)
            end
        end
        cc.FmodexManager:getInstance():downloadOtherFile(url, filename)
    end
end

-- 错误日志上传处理
function error_log_report(msg, filepath)
    if (PLATFORM == cc.PLATFORM_OS_WINDOWS or PLATFORM == cc.PLATFORM_OS_MAC) then return end
    if LOG_REPORT == false then return end
    _log_report_msg_list = _log_report_msg_list or {}
    if _log_report_msg_list[msg] then return end
    local filetxt = ""
    if filepath then
        filetxt = readBinaryFile(filepath)
        filetxt = string.sub(filetxt, 1, 500)
        filetxt = string.match(filetxt, "[%s%p%w]*")
    end
    local url = LOG_REPORT_URL or "http://log.sszg.shiyuegame.com/index.php/misc/log"
    local date_time = os.date("%Y-%m-%d %H:%M:%S")
    url = url .. "?product_name=" .. GAME_CODE
    url = url .. "&date_time=" .. log_url_encode(date_time)
    url = url .. "&sign=" .. cc.CCGameLib:getInstance():logsign(date_time)
    url = url .. "&channel_name=" .. get_channel()
    url = url .. "&package=" .. device.callFunc("package_name")
    url = url .. "&name=" .. log_url_encode(device.callFunc("app_name"))
    url = url .. "&idfa=" .. getIdFa()
    url = url .. "&network=" .. (device.isWifiState() and "wifi" or "data")
    url = url .. "&msg=" .. log_url_encode(msg)
    url = url .. "&filetxt=" .. log_url_encode(filetxt)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("POST", url)
    xhr:registerScriptHandler(function() end)
    xhr:send()
    _log_report_msg_list[msg] = 1
end

-- 获取设备号
function getIdFa()
    local idfa = cc.UserDefault:getInstance():getStringForKey("init_idfa", "")
    if idfa == nil or idfa == "" or idfa == "error" then
        idfa = device.getIdFa()
        if idfa == nil or idfa == "" or idfa == "error" then
            idfa = "sszg"..os.time()..randomIdFa("")
        end
        cc.UserDefault:getInstance():setStringForKey("init_idfa", idfa)
        cc.UserDefault:getInstance():flush()
    end
    return idfa
end

function randomIdFa(str)  
    local result = str
    local a = string.char(math.random(65, 90))
    local b = string.char(math.random(97, 122))
    local c = string.char(math.random(48, 57))
    if math.random(3) % 3 == 0 then
        result = result..a
    elseif  math.random(3) % 2 == 0 then
        result = result..b
    else
        result = result..c
    end
    if string.len(result) < 12 then
        result = randomIdFa(result)
    end
    return result
end

-- 一键加群处理
function joinQQGroup()
    if not next(QQ_GROUP_LIST) then return end
    local i = math.random(#QQ_GROUP_LIST)
    local qq_info = QQ_GROUP_LIST[i]
    if not qq_info then return end
    if IS_IOS_PLATFORM or PLATFORM == cc.PLATFORM_OS_IPHONE then
        sdkCallFunc(OPEN_URL_NAME or "openUrl", qq_info.ios)
    else
        sdkCallFunc("openUrl", qq_info.android)
    end
end

-- 渠道
function get_channel()
    local channel = device.getChannel and device.getChannel() or device.callFunc("channel")
    if channel == "" then
        channel = CHANNEL_NAME
    end
    CHANNEL_PRE = CHANNEL_PRE or ""
    channel = CHANNEL_PRE .. channel
    channel = FINAL_CHANNEL or channel
    return channel
end

-- url编码
function log_url_encode(str)  
    str = string.gsub (str, "\n", "\r\n")  
    str = string.gsub (str, "([^%w ])",  
    function (c) return string.format ("%%%02X", string.byte(c)) end)  
    str = string.gsub (str, " ", "+")  
    return str      
end 

-- 官方特殊处理的路径
function syGameSendOtherUrl(code, other_url)
    if other_url == nil or other_url == "" then 
        return
    end
    sdkCallFunc("openSyW", other_url)
end

-- 边玩边下资源可能异常的时候,特殊处理
function spineResErrorLog(code, msg)
    if error_log_report then
        local role_vo = RoleController:getInstance():getRoleVo()
        local rid = role_vo and role_vo.rid or 0
        local sid = role_vo and role_vo.srv_id or 0
        local name =  role_vo and role_vo.name or 0
        error_log_report(string.format("英雄模型资源问题,路径为:%s, 角色为名:%s, 角色id为:%s, 角色服务器id为:%s", msg, name, rid, sid))
        if DELETE_SPINE_ERROR_RES then
            cc.FileUtils:getInstance():removeFile(cc.FileUtils:getInstance():fullPathForFilename(msg))
        end
    end
end

-- 官方sdk认证取消的回调
function userBindFailed(code, msg)
    if error_log_report then
        local role_vo = RoleController:getInstance():getRoleVo()
        error_log_report(string.format("取消认证=====> rid=%s, srv_id=%s, name=%s", role_vo.rid, role_vo.srv_id, role_vo.name))
    end
    OPEN_SDK_VISITIOR_WINDOW = false  -- sdk认证窗体关闭了,这个时候会判断是否有缓存的需要打开认证窗体操作
    if NEED_OPEN_OPEN_SDK_VISITIOR_WINDOW == true then -- 如果之前缓存个了需要打开认证窗体,这个时候需要打开的不可取消的认证窗体
        callFunc("touristMode", "60")
    end
end

