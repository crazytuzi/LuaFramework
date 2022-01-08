local HeitaoSdk = {}

if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
HeitaoSdk.classname         = "HeitaoManager"
elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
HeitaoSdk.classname         = "org/cocos2dx/TerransForce/HeitaoSdkManager"
end



HeitaoSdk.initcallback 		= nil
HeitaoSdk.logincallback 	= nil
HeitaoSdk.loginoutcallback 	= nil
HeitaoSdk.leavecallback 	= nil
HeitaoSdk.paycallback 		= nil

HeitaoSdk.LOGIN_IN_SUC      = 1
HeitaoSdk.LOGIN_IN_FAIL     = 2
HeitaoSdk.LOGIN_OUT_SUC     = 3
HeitaoSdk.LOGIN_OUT_FAIL    = 4
HeitaoSdk.LOGIN_PAY_SUC     = 5
HeitaoSdk.LOGIN_PAY_FAIL    = 6

HeitaoSdk.bInit             = false
HeitaoSdk.bFirstLogin       = false

HeitaoSdk.servername        = nil
HeitaoSdk.serverid          = nil

-- 母包的channelid = 999999

function HeitaoSDKCallBack(result, msg)
    print("HeitaoSDKCallBack result = ", result)
    -- print("msg    = ", msg)
    if HeitaoSdk then
        HeitaoSdk.callback(tonumber(result), msg)
    end

    print("HeitaoSDKCallBack end")
end

function HeitaoSdk.init()

end



function HeitaoSdk.callback(result, msg)
    -- if result == 100 then
    --     CCDirector:sharedDirector():end()
    --     return
    -- end


    -- 登陆
    if result == HeitaoSdk.LOGIN_IN_SUC or result == HeitaoSdk.LOGIN_IN_FAIL then
        local msg = "登录失败"
        if result == HeitaoSdk.LOGIN_IN_SUC then


            if not  TFPlugins.nTimerHeiTaoInit then
                local function initdata()

                    TFDirector:removeTimer(TFPlugins.nTimerHeiTaoInit)
                    TFPlugins.nTimerHeiTaoInit = nil

                    local userId            = HeitaoSdk.getuserid()
                    local platformUserId    = HeitaoSdk.getplatformUserId()
                    local platformid        = HeitaoSdk.getplatformId()
                    local token             = HeitaoSdk.gettoken()    
                    local sdkVersion        = HeitaoSdk.getSDKVersion()

                    print("______________ long in success ___________________")
                    print("userId           = ", userId)
                    print("platformUserId   = ", platformUserId)
                    print("platformid       = ", platformid)
                    print("token            = ", token)                
                    print("sdkVersion       = ", sdkVersion)
                    print("______________ long in end ___________________")

                    TFPlugins.setSdkVersion(sdkVersion)
                    TFPlugins.setSdkName(platformid)
                    TFPlugins.setUserID(userId)
                    TFPlugins.setToken(token)

                end

                TFPlugins.nTimerHeiTaoInit = TFDirector:addTimer(500, -1, nil, initdata)
            end



            msg = "登录成功"
        end

        if HeitaoSdk.logincallback then
            HeitaoSdk.logincallback(result, msg)
        end
        
    elseif result == HeitaoSdk.LOGIN_OUT_SUC or result == HeitaoSdk.LOGIN_OUT_FAIL then
        if HeitaoSdk.loginoutcallback then
            HeitaoSdk.loginoutcallback()
        end

    elseif result == HeitaoSdk.LOGIN_PAY_SUC or result == HeitaoSdk.LOGIN_PAY_FAIL then
        if HeitaoSdk.paycallback then
            HeitaoSdk.paycallback(result)
        end
        
    end
end

function HeitaoSdk.login()

    if HeitaoSdk.bFirstLogin == true then
        return
    end

    HeitaoSdk.bFirstLogin = true
    local ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "login", nil, "()V")
    
    return HeitaoSdk.checkResult(ok,ret)
end


function HeitaoSdk.loginOut()

    local ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "loginOut", nil, "()V")
    
    return HeitaoSdk.checkResult(ok,ret)
end


function HeitaoSdk.loginExit()

    local ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "loginExit", nil, "()V")
    
    return HeitaoSdk.checkResult(ok,ret)
end

function HeitaoSdk.getuserid()

    local ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "getuserid", nil, "()Ljava/lang/String;")
    
    return HeitaoSdk.checkResult(ok,ret)
end

function HeitaoSdk.getplatformUserId()

    local ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "getplatformUserId", nil, "()Ljava/lang/String;")
    
    return HeitaoSdk.checkResult(ok,ret)
end

function HeitaoSdk.getplatformId()

    local ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "getplatformId", nil, "()Ljava/lang/String;")
    
    return HeitaoSdk.checkResult(ok,ret)
end

function HeitaoSdk.gettoken()

    local ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "gettoken", nil, "()Ljava/lang/String;")
    
    return HeitaoSdk.checkResult(ok,ret)
end

function HeitaoSdk.getcustom()

    local ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "getcustom", nil, "()Ljava/lang/String;")
    
    return HeitaoSdk.checkResult(ok,ret)
end

function HeitaoSdk.checkResult(ok,ret)
    -- body
    if ok then return ret end
    print("lua to java fail")
    return nil
end

-- int price; //单价(元)
-- int rate; //兑换比例
-- int count; //个数
-- int fixedMoney; //是否定额
-- String unitName; //货币单位
-- String productId; //产品 ID
-- String serverId; //服务器 ID（传 null）
-- String name; //商品名称
-- String callbackUrl; //回调地址（传 null）
-- String description; //商品描述
-- String cpExtendInfo; //CP 扩展信息
-- String custom; //自定义信息
function HeitaoSdk.pay(price, rate, count, fixedMoney, unitName, productId, serverId, name, callbackUrl, description, cpExtendInfo, sycee, level, viplevel, month, party)

    local args = nil
    local ok  = false
    local ret = nil

    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then

--     float price         = [[param objectForKey:@"price"] floatValue];                       //单价
--     int rate            = [[param objectForKey:@"rate"] intValue];                          //兑换比例
--     int count           = [[param objectForKey:@"count"] intValue];                     //个数
-- //    BOOL fixedMoney = = [[param objectForKey:@"count"] intValue];;                    //是否定额
--     NSString *unitName  = [param objectForKey:@"unitName"];     //货币单位
--     NSString *productId = [param objectForKey:@"productId"];        //产品ID
--     NSString *serverId  = [param objectForKey:@"serverId"];     //服务器ID
--     NSString *name      = [param objectForKey:@"name"];         //商品名称
--     NSString *callbackUrl = [param objectForKey:@"callbackUrl"];        //回调地址
--     NSString *description = [param objectForKey:@"description"];    //商品描述
--     NSString *cpExtendInfo= [param objectForKey:@"cpExtendInfo"];   //商品描述  //CP扩展信息

        args = {
            price       = string.format("%d", price),
            rate        = string.format("%d", rate), 
            count       = string.format("%d", count),
            fixedMoney  = fixedMoney, 
            unitName    = unitName,
            productId   = productId,
            serverId    = string.format("%d", serverId),
            callbackUrl = callbackUrl,
            description = description,
            cpExtendInfo= cpExtendInfo,
            sycee       = sycee,
            level       = level,
            viplevel    = viplevel,
            month       = month,
            party       = party
            -- sycee, level, viplevel, month, party      = custom
        }

        print("HeitaoSdk.pay" , args)

        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "pay", args)
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then

        local itemName = unitName
        if month == 1 then
            itemName = "月卡"
        end
        
        args = {
            price,
            rate, 
            count,
            1, 
            itemName,
            productId,
            string.format("%d", serverId),
            cpExtendInfo
            -- callbackUrl,
            -- description,
            -- cpExtendInfo,
            -- ""
            -- ""..sycee,
            -- ""..level,
            -- ""..viplevel,
            -- ""..month,
            -- ""..party
            -- sycee, level, viplevel, month, party      = custom
        }


        print("HeitaoSdk.pay" , args)
        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "pay", args, "(IIIILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
        -- ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "pay", {bShow})
        
        -- return HeitaoSdk.checkResult(ok,ret)
    end
end

-- 是否显示悬浮菜单按钮
function HeitaoSdk.ShowFunctionMenu(bShow)
    local ok  = false
    local ret = nil
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "ShowFunctionMenu", {enable = bShow})
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "ShowFunctionMenu", {bShow})
        
        return HeitaoSdk.checkResult(ok,ret)
    end
end

-- 开始游戏
function  HeitaoSdk.startGame()
    -- HTGameProxy.onStartGame();
    local ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "startGame", nil, "()Z")
    
    if ok then 
        if ret == 1 then
            return true
        end 
    end

    return HeitaoSdk.checkResult(ok,ret)
end

-- 3.8.进入游戏
-- HTGameProxy.onEnterGame(Map<String, String> customMap);
-- 参数备注：customMap：参数集
-- 返回值：无
-- 调用级别：必选
-- 描述：在正确游戏进入后调用
-- 必须传入以下参数：
-- Map<String, String> parsMap = new HashMap<String, String>();
-- parsMap.put(HTKeys.KEY_CP_SERVER_ID, "服务器 ID"); //必须整形（某些渠道要求）
-- parsMap.put(HTKeys.KEY_CP_SERVER_NAME, "服务器名称");
-- parsMap.put(HTKeys.KEY_ROLE_ID, "玩家角色 ID");
-- parsMap.put(HTKeys.KEY_ROLE_NAME, "玩家角色名");
-- parsMap.put(HTKeys.KEY_ROLE_LEVEL, "玩家角色等级");
-- parsMap.put(HTKeys.KEY_IS_NEW_ROLE, "是否为新角色");//1:新角色 0:旧角色
-- function HeitaoSdk.enterGame(serverid, servername, roleid, rolename, level, isNewRole)
function HeitaoSdk.enterGame(roleid, rolename, level, isNewRole)
    -- local args = {HeitaoSdk.servername, HeitaoSdk.serverid, roleid, rolename, level, isNewRole}

    local args = nil
    local ok  = false
    local ret = nil

    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        args = {
            serverid    = string.format("%d", HeitaoSdk.serverid),
            servername  = HeitaoSdk.servername, 
            roleid      = string.format("%d", roleid),
            rolename    = rolename, 
            level       = string.format("%d", level),
            isNewRole   = string.format("%d", isNewRole)
        }

        print("----HeitaoSdk.enterGame = ", args)
        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "enterGame", args)

    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        args = {
            string.format("%d", HeitaoSdk.serverid),
            HeitaoSdk.servername, 
            string.format("%d", roleid),
            rolename, 
            string.format("%d", level),
            string.format("%d", isNewRole)
            }
            
        print("----HeitaoSdk.enterGame = ", args)
        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "enterGame", args)
    end


    return HeitaoSdk.checkResult(ok,ret)
end


-- 玩家等级发生变化
function  HeitaoSdk.GameLevelChanged(newLevel)
    local ok  = false
    local ret = nil
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "GameLevelChanged", {level = newLevel})
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "GameLevelChanged", {newLevel}, "(I)V")
        
        return HeitaoSdk.checkResult(ok,ret)
    end
end

-- 设置 APP 更新监听
function  HeitaoSdk.setAppUpdateListener(listener)
    -- HTGameProxy.setAppUpdateListener(listener)调用级别：必选
    -- 描述：发行商服务器端可以配置把更新权给 SDK 或者 CP，如果服务器端把更新权配置给
    -- CP，但是客户端未设置更新监听，该情况会默认走 SDK 的更新。
    -- HTAppUpdateInfo 参数说明：
    -- versionName // 版本名称
    -- versionCode // 版本代码
    -- content // 更新内容
    -- apkURL // APK 下载地址
    -- isForce // 是否强制更新（通常为 TRUE）
end

-- 4.1.获取 SDK 版本号
-- 描述：获取黑桃代理 SDK 版本号
function  HeitaoSdk.getSDKVersion()
    local ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "getSDKVersion", nil)
    
    return HeitaoSdk.checkResult(ok,ret)
end

-- 4.2.获取渠道 SDK 版本号
-- HTGameProxy.getChannelSDKVersion();
-- 描述：获取渠道 SDK 版本号
function  HeitaoSdk.getChannelSDKVersion()
    local ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "getChannelSDKVersion", nil)
    
    return HeitaoSdk.checkResult(ok,ret)
end

-- 4.3.Debug 模式设置
-- HTGameProxy.setDebugEnable(boolean enable);
-- 参数备注：TRUE：开启 FALSE：关闭
-- 描述：设置 Debug 模式，默认关闭。Debug 默认开启时，支付金额会默认为 1 元，关闭则为实际金额。
function  HeitaoSdk.setDebugEnable(enable)

    local ok  = false
    local ret = nil
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "setDebugEnable", {enable = bShow})
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "setDebugEnable", {bShow})
        
        return HeitaoSdk.checkResult(ok,ret)
    end
end

-- 4.4.设置打印日志
-- HTGameProxy.setLogEnable(boolean enable);
function  HeitaoSdk.setLogEnable(enable)

    local ok  = false
    local ret = nil
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "setLogEnable", {enable = bShow})
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "setLogEnable", {bShow})
        
        return HeitaoSdk.checkResult(ok,ret)
    end
end

-- 4.4.打开QQ
function  HeitaoSdk.openQQClient(qqid)
    local ok  = false
    local ret = nil
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "openQQ", {qq = qqid})
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "openQQ", {qqid})
        
        return HeitaoSdk.checkResult(ok,ret)
    end
end

function  HeitaoSdk.onUseGiftCode(giftCode)
    local ok  = false
    local ret = nil
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "onUseGiftCode", {code = giftCode})
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        ok,ret = TFLuaOcJava.callStaticMethod(HeitaoSdk.classname, "onUseGiftCode", {giftCode})
        
        return HeitaoSdk.checkResult(ok,ret)
    end
end


function  HeitaoSdk.setLoginOutCallBack(callback)
    if callback then 
        if type(callback) == 'function' then
            HeitaoSdk.loginoutcallback  = callback
        else
            print("=====init===loginoutcallback=error",callback)
            return
        end
    end
end

function  HeitaoSdk.setLogincallback(callback)
    if callback then 
        if type(callback) == 'function' then
            HeitaoSdk.logincallback  = callback
        else
            print("=====init===logincallback=error",callback)
            return
        end
    end
end


function  HeitaoSdk.setPayCallBack(callback)
    if callback then 
        if type(callback) == 'function' then
            HeitaoSdk.paycallback  = callback
        else
            print("=====init===setPayCallBack=error",callback)
            return
        end
    end
end



function  HeitaoSdk.setServerInfo(serverid, servername)
    HeitaoSdk.servername = servername
    HeitaoSdk.serverid   = serverid
end

return HeitaoSdk
