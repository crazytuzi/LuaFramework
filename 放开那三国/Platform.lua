-- Filename: Platform.lua
-- Author: fang
-- Date: 2013-09-22
-- Purpose: 该文件用于处理平台相关接口

-- 调试级别(游戏发布时该level必须为0)

module("Platform", package.seeall)

require "script/ui/login/ServerList"
require "script/Util"
require "script/Logger"

local _pid
-- g_debug_mode = true
-- _debug = g_debug_mode
_isAppStore = false
_isZYXSdk = false
_isDNYSdk = false
_appVersion = NSBundleInfo:getAppVersion()
local protocol
local name = nil
--登录后返回的用户信息
sdkLoginInfo = nil
--appstore审核渠道广告开关,以及需要屏蔽的开关
--广告屏蔽开关，即提审时候打开
isAdShow     = false   
--礼包开关，有时候要打开，有时候要关闭，台湾有病，不解释 
isGiftBagShow  = true  
-- local config = nil
isChangeAccount = false

function isPlatform( ... )
    return BTUtil:getPlStatus()
end

function isAppStore( ... )
    return _isAppStore
end
function isZYXSdk( ... )
    return _isZYXSdk
end

function isDNYSdk( ... )
    return _isDNYSdk
end

function isDebug( ... )
    return g_debug_mode
end

function getSdk( ... )
    if(isPlatform() == false)then
        return
    end
    return protocol
end
function getConfig( ... )
    return config
end

function getPlatformFlag( ... )
    if(isPlatform() == false)then
        return "babeltime"
    end
    return protocol:callStringFuncWithParam("getPlatformName",nil)
end
-- 初始化平台相关SDK
function initSDK()
    if(isPlatform() == false)then
        require "script/config/config_debug"
        return
    end
    protocol = PluginManager:getInstance():loadPlugin()
    registerCrashHandler()
    registerLoginHandlers()
    local platformName = protocol:callStringFuncWithParam("getPlatformName",nil)
    print("platformName is",platformName);
    if(platformName == "IOS_91")then
        require "script/config/config_91"
    elseif(platformName == "IOS_PP")then
        require "script/config/config_PP"
        --打开充值
        local dict = CCDictionary:create()
        dict:setObject(CCString:create(1),"isOpenRecharge")
        protocol:callOCFunctionWithName_oneParam_noBack("setIsOpenRecharge",dict)
    elseif(platformName == "IOS_PP2")then
        require "script/config/config_PP2"
        --打开充值
        local dict = CCDictionary:create()
        dict:setObject(CCString:create(1),"isOpenRecharge")
        protocol:callOCFunctionWithName_oneParam_noBack("setIsOpenRecharge",dict)
    elseif(platformName == "IOS_PGY")then
        require "script/config/config_PGY"
        --打开充值
        local dict = CCDictionary:create()
        dict:setObject(CCString:create(1),"isOpenRecharge")
        protocol:callOCFunctionWithName_oneParam_noBack("setIsOpenRecharge",dict)
    elseif(platformName == "IOS_TBT")then
        require "script/config/config_TBT"
    elseif(platformName == "IOS_ITOOLS")then
        require "script/config/config_itools"
    elseif(platformName == "IOS_APPSTORE") then
        require "script/config/config_apple"
        _isAppStore = true
    elseif(platformName == "IOS_KUAIYONG")then
        require "script/config/config_kuaiyong"
    elseif(platformName == "IOS_DANGLE")then
        require "script/config/config_ios_dangle"


    elseif(platformName == "Android_360")then
        require "script/config/config_360"
    elseif(platformName == "Android_91")then
        require "script/config/config_91Android"
    elseif(platformName == "Android_uc") then
        require "script/config/config_uc"
    elseif(platformName == "Android_kg") then
        require "script/config/config_kugou"
    elseif(platformName == "Android_dl") then
        require "script/config/config_dangle"
    elseif(platformName == "Android_dk") then
        require "script/config/config_duoku"
    elseif(platformName == "Android_wdj")then
        require "script/config/config_wandoujia"
    elseif(platformName == "Android_jf")then
        require "script/config/config_jifeng"
    elseif(platformName == "Android_37wan") then
        require "script/config/config_37wan"
    elseif(platformName == "Android_xm") then
        require "script/config/config_xiaomi"
    elseif(platformName == "Android_az") then
        require "script/config/config_anzhi"
    elseif(platformName == "Android_baofeng") then
        require "script/config/config_baofeng"
    elseif(platformName == "IOS_zyx") then
        _isZYXSdk = true
        require ("script/config/config_"..platformName)
    elseif(platformName == "Android_zyx" or platformName == "Android_amazon" or platformName == "wp8_zyx") then
        _isZYXSdk = true
        require ("script/config/config_"..platformName)
    elseif(platformName == "ios_english")then
        require ("script/config/config_"..platformName)
        _isDNYSdk = true
    elseif(platformName == "Android_eng")then
        require ("script/config/config_"..platformName)
        _isDNYSdk = true
    elseif(platformName == "ios_vietnam")then
        require ("script/config/config_"..platformName)
        _isDNYSdk = true
    elseif(platformName == "Android_vn")then
        require ("script/config/config_"..platformName)
        _isDNYSdk = true
    elseif(platformName == "ios_hw_fb")then
        require ("script/config/config_"..platformName)
        _isZYXSdk = true
    else
        require ("script/config/config_"..platformName)
    end

    if(platformName == "Android_az") then
        local dict = CCDictionary:create()
        dict:setObject(CCString:create(config.getAppId()),"appId")
        dict:setObject(CCString:create(config.getAppKey()),"appKey")
        protocol:callOCFunctionWithName_oneParam_noBack("initialize",dict)
        return

    elseif(platformName == "Android_youmi" or platformName == "IOS_haima" or platformName == "Android_gamesky" or platformName == "Android_zhangyue" or platformName == "Android_renren" or platformName == "Android_ledou" or  platformName == "Android_37wan" or platformName=="Android_xm") then
        local dict = CCDictionary:create()
        dict:setObject(CCString:create(config.getAppId()),"appId")
        dict:setObject(CCString:create(config.getAppKey()),"appKey")
        protocol:callOCFunctionWithName_oneParam_noBack("initialize",dict)
        return

    elseif(platformName == "Android_pipa") then
        local dict = CCDictionary:create()
        dict:setObject(CCString:create(config.getAppId()),"appId")
        dict:setObject(CCString:create(config.getAppKey()),"appKey")
        dict:setObject(CCString:create(config.getMerchantId()),"merchantId")
        dict:setObject(CCString:create(config.getMerchantAppId()),"merchantAppId")
        dict:setObject(CCString:create(config.getPrivateKey()),"privateKey")
        protocol:callOCFunctionWithName_oneParam_noBack("initialize",dict)
        return
    elseif(platformName == "Android_huaqing" or platformName == "Android_huaqing2" or platformName == "Android_huaqing3" )then
        local dict = config.getInitParam()
        protocol:callOCFunctionWithName_oneParam_noBack("initialize",dict)
        protocol:registerScriptHandlers("qqLogin",function( ... )
            print("android logcat registerScriptHandlers qqLogin")
            require "script/ui/login/QQLoginLayer"
            QQLoginLayer.showLayer()
        end)
        return
    elseif(platformName == "Android_baofeng") then
        local dict = CCDictionary:create()
        dict:setObject(CCString:create(config.getAppId()),"appId")
        dict:setObject(CCString:create(config.getAppKey()),"appKey")
        dict:setObject(CCString:create(config.getGameId()),"gameId")
        dict:setObject(CCString:create(config.getServerId()),"serverId")
        dict:setObject(CCString:create(config.getChannelId()),"channelId")
        protocol:callOCFunctionWithName_oneParam_noBack("initialize",dict)
        return
    elseif(platformName == "changwan") then
        local dict  = config.getInitParam()
        return
    else
        print("")
    end

    if(not isDebug())then
        --线上环境 
        if(type(config.getInitParam) == "function" 
            and config.getInitParam() ~= nil 
            and config.getInitParam() ~= "")then
            local dict = config.getInitParam()
            protocol:callOCFunctionWithName_oneParam_noBack("initialize",dict)
        else
            protocol:setAppId(config.getAppId())
            protocol:setAppKey(config.getAppKey())
            protocol:initialize()
        end
    else
        --线下环境  
        if(type(config.getInitParam) == "function" 
            and config.getInitParam() ~= nil 
            and config.getInitParam() ~= "")then
            local dict = config.getInitParam()
            protocol:callOCFunctionWithName_oneParam_noBack("initialize",dict)
        else
            protocol:setAppId(config.getAppId_debug())
            protocol:setAppKey(config.getAppKey_debug())
            protocol:initialize()
        end
    end

    --启动防沉迷
    antiAddictionSchedule()
    --审核广告与屏蔽
    if(type(config.isNeedAdShow) == "function" 
        and config.isNeedAdShow() == true)then
        fnAdShow()
    end

end

function getPlName( ... )
    if protocol == nil then
        return "chphone_test"
    end
    local name = protocol:callStringFuncWithParam("getPlatformName",nil)
    if name == "IOS_TBT" then
        return "tbtphone"
    elseif name == "IOS_APPSTORE" then
        return "appstore"
    elseif name == "IOS_91" then
        return "91phone"
    elseif name == "IOS_PP" then
        return "ppphone"
    elseif name == "IOS_PP2" then
        return "pp2phone"
    elseif name == "IOS_ITOOLS" then
        return "itoolsphone"
    elseif name == "IOS_DANGLE" then
        return "dlphone"
    elseif name == "IOS_KUAIYONG" then
        return "kyphone"
    elseif name == "IOS_PGY" then
        return "pgyphone"
    else
        -- 在这增加android的平台名称
        return config.getFlag()
    end
end

-- 进入用户中心
function enterUserCenter()
    if(isPlatform() == false)then
        -- 测试自动断开链接功能
        require "script/network/Network"
        Network.rpc(function ( ... )
            -- body
            end, "user.closeMe", "user.closeMe", nil, true)

        return
    end

    if(Platform.getCurrentPlatform() == kPlatform_AppStore) then
        -- require "script/ui/tip/AlertTip"
        -- AlertTip.showAlert(GetLocalizeStringBy("key_2734"), nil)
        PlatformUtil:openUrl("http://sg.zuiyouxi.com/")
        return
    end
    if(Platform.getCurrentPlatform() == kPlatform_AppStore
        or Platform.getCurrentPlatform() == kPlatform_chukong
        or Platform.getCurrentPlatform() == kPlatform_chukong_dx
        or Platform.getCurrentPlatform() == kPlatform_chukong_lt
        or Platform.getCurrentPlatform() == kPlatform_chukong_ydm
        or Platform.getCurrentPlatform() == kPlatform_chukong_ydg
        or Platform.getCurrentPlatform() == kPlatform_lenovo
        or Platform.getCurrentPlatform() == kPlatform_lenovoPush
        or Platform.getCurrentPlatform() == kPlatform_xunlei
        or Platform.getCurrentPlatform() == kPlatform_vivo
        or Platform.getCurrentPlatform() == kPlatform_3g
        or Platform.getCurrentPlatform() == kPlatform_pptv
        or Platform.getCurrentPlatform() == kPlatform_4399
        or Platform.getCurrentPlatform() == kPlatform_chaohaowan 
        or Platform.getCurrentPlatform() == kPlatform_shouyouba
        or Platform.getCurrentPlatform() == kPlatform_baofeng
        or Platform.getCurrentPlatform() == kPlatform_renren
        or Platform.getCurrentPlatform() == kPlatform_duoku
        or Platform.getCurrentPlatform() == kPlatform_zhangyue
        or Platform.getCurrentPlatform() == kPlatform_gamesky
        or Platform.getCurrentPlatform() == kPlatform_kuaiwan
        or Platform.getCurrentPlatform() == kPlatform_37wan
        or Platform.getCurrentPlatform() == kPlatform_skysea) then
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert("暂未开放", nil)
        return
    end
    if(type(config.isNeedUserSenter) == "function" 
        and config.isNeedUserSenter() == false)then
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert(GetLocalizeStringBy("key_2734"), nil)
        return
    end
    protocol:enterPlatform(0)

end

-- 播放背景音乐

function playMusicBmg( url ,isrepeat )
    if(url == nil)then
        return
    else
        local dict = CCDictionary:create()
        dict:setObject(CCString:create(url),"url")
        if isrepeat == true then 
            dict:setObject(CCString:create("true"),"isrepeat")
        elseif isrepeat == nil then 
            dict:setObject(CCString:create("false"),"isrepeat")
        else
            dict:setObject(CCString:create("false"),"isrepeat")
        end

        protocol:callOCFunctionWithName_oneParam_noBack("playMusicBmg",dict)
    end
end

-- 停止背景音乐
function stopMusicBmg()
    print("stopmusic:",stop)
    -- local dict = CCDictionary:create()
    -- dict:setObject(CCString:create(stop),"stop")
    protocol:callOCFunctionWithName_oneParam_noBack("stopMusicBmg",nil)
end

function setMusicVolume( volume )
    -- body
    local dict = CCDictionary:create()
    dict:setObject(CCString:create(volume),"volume")
    protocol:callOCFunctionWithName_oneParam_noBack("setMusicVolume",dict)
end
-- 泰国LINE的特殊要求
function gotoLineLogin( ... )
  -- body
  print("泰国line登陆页")
  protocol:callOCFunctionWithName_oneParam_noBack("gotoLineLogin",nil)
  protocol:registerScriptHandlers("gotoMain",function( ... )
    require "script/ui/login/LoginScene"
    LoginScene.enter()
  end)
end
-- 取得平台相关名字
function getPlatformName( ... )
    if(isPlatform() == false)then
        return "测试中心"
    end
    return config.getName()
end

function getPlatformUrlName( ... )
    if protocol then
        return protocol:callStringFuncWithParam("getPlatformName",nil)
    else
        return "test"
    end
end

function isLogin( ... )
    if(isPlatform() == false)then
        return
    end
    return protocol:isLogin()
end

_loginBackCall = nil
function registerLoginHandlers( ... )
  Platform.registerLoginScriptHandler(function ( dict )
    require "script/utils/LuaUtil"
    print_t("login back",dict)
    local loginState = tonumber(dict.state)
    local session_id = dict.sid
    print("loginState =",loginState,"session_id=",session_id)
    print(type(loginState))
    print("loginState =" .. loginState)
    if Platform.isDNYSdk() then
      if loginState == 0 then
        local userName = dict.userName
        local userId = dict.userId
        require "script/ui/login/DNY_english/DnyLoginLayer"
        DnyLoginLayer.loginSeccessCallBack(session_id,userId,userName)
      elseif loginState == -1 then
        require "script/ui/login/DNY_english/DnyLoginLayer"
        DnyLoginLayer.loginFailedCallBack(tostring(dict.msg))
        print("loginFailed:",dict.msg)
      else
        print("loginFailed:",dict.msg)
      end
    --为了兼容英文1.1.8版本，先保留，换底包后可删除上面东南亚部分
    else
      if(loginState == 0) then
          print("platform sdk 登陆成功")
          printB("..................Platform.getPidBySessionId...................001")
          Platform.sdkLoginInfo=dict
          Platform.getPidBySessionId(session_id)
          Platform.showToolBar()
      else
        print("登陆失败")
        return;
      end
    end
  end)
end

--登陆
function login( loginBackCall )
  _loginBackCall = loginBackCall
  print("set _loginBackCall",_loginBackCall)
  -- registerLoginHandlers()

    if(isPlatform() == false)then
      return
    end
    print("platform=",Platform.getCurrentPlatform() )
    if(true or Platform.getCurrentPlatform() == kPlatform_AppStore or isZYXSdk() or isDNYSdk()) then
        print("login state=",Platform.getConfig().getLoginState())

        if(Platform.getConfig().getLoginState() == Platform.getConfig().kLoginsStateNotLogin)then
            if (isDNYSdk()) then
              require "script/ui/tip/AlertTip"
              AlertTip.showAlert(GetLocalizeStringBy("key_1393"), nil)

              require "script/ui/login/DNY_english/DnyLoginLayer"
              DnyLoginLayer.createLoginLayer();
            else
              require "script/ui/tip/AlertTip"
              AlertTip.showAlert(GetLocalizeStringBy("key_1393"), nil)

              require "script/ui/login/AppLoginLayer"
              AppLoginLayer.createLoginLayer();
            end

            return
        elseif(Platform.getConfig().getLoginState() == Platform.getConfig().kLoginsStateUDIDLogin)then
            -- require "script/ui/login/AppLoginLayer"
            -- local username = CCUserDefault:sharedUserDefault():getStringForKey("username")
            -- local password = CCUserDefault:sharedUserDefault():getStringForKey("password")
            -- AppLoginLayer.loginWithUserNameInfo(username,password,true);
        elseif(Platform.getConfig().getLoginState() == Platform.getConfig().kLoginsStateZYXLogin)then
            if (isDNYSdk()) then
              require "script/ui/login/DNY_english/DnyLoginLayer"
              if Platform.getConfig().getLoginType() == Platform.getConfig().kLoginsTypeFBLogin then
                --FB登陆
                DnyLoginLayer.facebookLogin()
              elseif Platform.getConfig().getLoginType() == Platform.getConfig().kLoginsTypeFTLogin then
                --游客登陆
                DnyLoginLayer.freeTrialLogin()
              else
                --账号登陆
                local username = CCUserDefault:sharedUserDefault():getStringForKey("username")
                local password = CCUserDefault:sharedUserDefault():getStringForKey("password")
                DnyLoginLayer.loginWithUserNameInfo(username, password, false);
              end
            else
              require "script/ui/login/AppLoginLayer"
              local username = CCUserDefault:sharedUserDefault():getStringForKey("username")
              local password = CCUserDefault:sharedUserDefault():getStringForKey("password")
              -- AppLoginLayer.loginWithUserNameInfo(username, password, true);
              AppLoginLayer.loginWithUserNameInfo(username, password, false);
            end
        end

        -- if(_pid == nil or _pid == 0)then
        --     require "script/ui/tip/AlertTip"
        --     AlertTip.showAlert(GetLocalizeStringBy("key_1582"), nil)
        --     return
        -- end

        -- if(not Platform.isDebug())then
        --     LoginScene.loginLogicServer(_pid)
        -- else
        --     local serverInfo = ServerList.getLastLoginServer()
        --     serverInfo.pid = _pid
        --     LoginScene.loginInServer(serverInfo)
        -- end
    else
        protocol:login()
    end
end

function fnAdShow( ... )

    -- local version = CCUserDefault:sharedUserDefault():getStringForKey("GameVersion")
    -- if version == nil or string.len(version) == 0 then
    --   version = g_game_version
    -- end

    --local adUrl =  config.getAdShowUrl() .. version
    local adUrl =  config.getAdShowUrl() .. _appVersion
    print("adUrl: ", adUrl)

    local imgHttpClient = CCHttpRequest:open(adUrl, kHttpGet)
    imgHttpClient:sendWithHandler(function (res, hnd)
        if res:getResponseCode() == 200 then
            local cjson = require("cjson")
            local json = cjson.decode(res:getResponseData())
            printB("isshow: ", json.isshow)
            if json and json.isshow then
                if json.isshow == 1 then
                    local dict = CCDictionary:create()
                    isAdShow   = true
                    protocol:callOCFunctionWithName_oneParam_noBack("adShow",dict)
                    printB("打开广告且屏蔽isAdShow:",isAdShow)
                elseif json.isshow == 2 then
                    isAdShow   = true
                    printB("不开广告但屏蔽isAdShow:",isAdShow)
                elseif json.isshow == 3 then
                    local dict = CCDictionary:create()
                    protocol:callOCFunctionWithName_oneParam_noBack("adShow",dict)
                    printB("打开广告但不屏蔽isAdShow:",isAdShow)
                end
            end
            if json and json.isgiftshow then
                if json.isgiftshow == 0 then
                    isGiftBagShow = false
                    printB("屏蔽礼包兑换isGiftBagShow:",isGiftBagShow)
                elseif json.isgiftshow == 1 then
                    isGiftBagShow = true
                    printB("开启礼包兑换isGiftBagShow:",isGiftBagShow)
                end
            end
        end
    end)
    -- isGiftBagShow = true
    -- isGiftBagShow = false
end

--注销
function loginOut( ... )
    if(isPlatform() == false)then
        return
    end
    isChangeAccount = true
    protocol:loginOut()
end

--平台登录回调
function registerLoginScriptHandler(pFunc)
    if(isPlatform() == false)then
        return
    end
    protocol:registerLoginScriptHandler(pFunc)
    registerLogoutScriptHandler()
end

--平台注销回调
function registerLogoutScriptHandler(pFunc)
    if(isPlatform() == false)then
        return
    end
    print("registerLogoutHandler")
    protocol:registerScriptHandlers("logout",function( ... )
        print(GetLocalizeStringBy("key_2382"))
        logout()
    end)
end

function showToolBar( ... )
    if(isPlatform() == false)then
        return
    end
    protocol:showToolBar()
end

function getUin( ... )
    if(isPlatform() == false)then
        return
    end
    return protocol:callStringFuncWithParam("getUin",nil)
end

local _unlockPay = "true"

-- 解禁充值功能
function fnLockPay( lock )
    _unlockPay = lock
end

-- 支付类型枚举(payType)
kPay_GoldCoins  =  "00"
kPay_MonthCard  =  "01"

-- 商品购买统一接口,默认 充值金币 (参数单价,类型,数量)
function pay(price, payType, amount)
    if(isPlatform() == false)then
        return
    end
    local coins = price
    if( amount ~= nil and amount ~= 0 )then
        coins = price * amount
    end
    -- if(isDebug() == true and getPlatformFlag() ~= "Android_91")then
    --   require "script/ui/tip/AlertTip"
    --   AlertTip.showAlert("debug模式不支持充值.", nil)
    -- end
    -- --android封测不开放充值
    -- if g_system_type ~= kBT_PLATFORM_IOS and _unlockPay == "false" then
    --     require "script/ui/tip/AlertTip"
    --     AlertTip.showAlert("封测期间不开放充值.", nil)
    --     return
    -- end

    local platformName = protocol:callStringFuncWithParam("getPlatformName",nil)
    if(platformName == "Android_vivo")then
        --调用平台推送接口，返回充值所需参数，如果有用到，请重构
        local requestCallback = function(res, hnd)
            LoadingUI.reduceLoadingUI()
            if(res:getResponseCode()~=200)then
                require "script/ui/tip/AlertTip"
                AlertTip.showAlert( "网络异常，请稍后再试", nil, false, nil)
                return
            end

            local xml = require "script/utils/LuaXml"
            local orderXmlString = res:getResponseData()
            print("pushInterface Call:" .. orderXmlString)
            local xmlTable = LuaXML.eval(orderXmlString)

            --保存登录数据
            if(xmlTable == nil) then
                -- AlertTip.showAlert("连接已断开，请重新登录！", loginAgain)
                require "script/ui/tip/AlertTip"
                AlertTip.showAlert("创建失败。", nil)
                return
            end
            local param = setPayParam(coins ,payType ,amount)
            -- local param = setPayParam(10 ,payType ,amount)
            -- print("param:",param)
            -- print("xmlTable:",xmlTable:find("vivoSignature")[1])
            param:setObject(CCString:create(xmlTable:find("vivoSignature")[1]),"vivoSignature")
            param:setObject(CCString:create(xmlTable:find("vivoOrder")[1]),"vivoOrder")
            protocol:pay(param)

        end

        local requestUrl
        local m_payType = payType
        local m_amount  = amount
        if payType == nil or payType == "" then
            m_payType = "00"
        end
        if amount == nil or amount == "" then
            m_amount = "1"
        end
        if(isDebug())then
            requestUrl = config.getOrderUrl_debug(coins,m_payType,m_amount)
            -- requestUrl = config.getOrderUrl_debug(10,m_payType,m_amount)
        else
            requestUrl = config.getOrderUrl(coins,m_payType,m_amount)
        end
        print("getOrderURL:",requestUrl)

        require "script/ui/network/LoadingUI"
        LoadingUI.addLoadingUI()
        local httpClent = CCHttpRequest:open(requestUrl, kHttpGet)
        httpClent:sendWithHandler(requestCallback)

    else

        local param = setPayParam(coins ,payType ,amount)
        protocol:pay(param)

    end 
end

function setPayParam(coins, payType, amount)
    local param = config.getPayParam(coins, payType, amount)
    local m_payType = "00"
    local m_amount  = "1"
    local otherInfo = ""
    if( payType ~= nil and payType == kPay_MonthCard )then
        --月卡购买
        if( amount ~= nil )then
            m_amount = amount
        else
            m_amount  = "1"
        end
        m_payType = kPay_MonthCard
        otherInfo = ""
        --printB("kPay_MonthCard:",m_payType)
    elseif ( payType ~= nil and payType == kPay_GoldCoins ) then
        --金币充值
        m_amount  = "0"
        m_payType = kPay_GoldCoins
        otherInfo = ""
        --printB("kPay_GoldCoins:",m_payType)
    else
        --金币充值
        m_amount  = "0"
        m_payType = "00"
        otherInfo = ""
        --printB("金币充值")
    end
    param:setObject(CCString:create(m_payType),"payType")
    param:setObject(CCString:create(m_amount),"amount")
    param:setObject(CCString:create(otherInfo),"otherInfo")
    return param
end

--初始化平台Server(登录成功后)
function initPlGroup( ... )
    if(type(config.isNeedInitPlGroup) == "function" 
        and config.isNeedInitPlGroup() == true)then
        protocol:callOCFunctionWithName_oneParam_noBack("initServer",config.getGroupParam())
    end
end
-- 解禁充值功能
function fnUnlockPay( ... )
    _lockPay = false
end

function getSessionId()
    if(isPlatform() == false)then
        return
    end
    return protocol:callStringFuncWithParam("getSessionId",nil)
end

--获取服务器列表
function getServerList()
    local platformName = getPlatformFlag()
    if(platformName ~= "IOS_91" 
        and platformName ~= "Android_91" 
        and platformName ~= "IOS_KUAIYONG"
        and platformName ~= "IOS_PP"
        and platformName ~= "IOS_PGY"
        and platformName ~= "IOS_TBT"
        and platformName ~= "IOS_haima"
        and platformName ~= "Android_youmi") then
        if isChangeAccount and platformName ~= "IOS_APPSTORE" then
          print("getServerList()isChangeAccount:",isChangeAccount)
        else
          login()
        end
    end
    --通知SDK程序进入选服主页面
    Platform.sendInformationToPlatform(kComeInMainLayer)
    local httpClent = nil
    require "script/ui/network/LoadingUI"
    -- LoadingUI.addLoadingUI()
    if(not isDebug())then
        httpClent = CCHttpRequest:open(config.getServerListUrl(), kHttpGet)
        print("url",config.getServerListUrl())
    else
        httpClent = CCHttpRequest:open(config.getServerListUrl_debug(), kHttpGet)
        print("url",config.getServerListUrl_debug())
    end

    httpClent:sendWithHandler(function(res, hnd)
        -- LoadingUI.reduceLoadingUI()
        local function resultCallback(resultTable)
            if(resultTable == nil) then
                print("get serverlist failed!!")
                require "script/ui/tip/AlertTip"
                AlertTip.showAlert(GetLocalizeStringBy("key_2847"), function ( ... )
                    require "script/Platform"
                    Platform.quit()
                end)
                return
            end
            for i=1, #resultTable do
                local v = resultTable[i]
                if v.desc and v.open then
                    require "script/ui/login/LoginScene"
                    LoginScene.setNotice(v.open, v.desc)
                    resultTable[i] = nil
                    break
                end
            end

            ServerList.serverListData = resultTable
            LoginScene.createSelectServer()
        end

        --判断http状态是否合法
        if(res:getResponseCode() ~= 200) then
            print("error responseCode :", res:getResponseCode())
            require "script/ui/tip/AlertTip"
            AlertTip.showAlert(GetLocalizeStringBy("key_2847"), function ( ... )
                require "script/Platform"
                Platform.quit()
            end)
        end

        if(res:getResponseData() == "")then
            require "script/ui/tip/AlertTip"
            AlertTip.showAlert(GetLocalizeStringBy("key_3354"), function()
                require "script/Platform"
                Platform.quit()
            end)
            return
        end
        BTUtil:parseServerList(res:getResponseData(), resultCallback)
    end)
end

--登录成功后获取pid
function getPidBySessionId( session_id )
    -- if _pid then
    --   LoginScene.loginLogicServer(_pid)
    --   return
    -- end
    local loginUrl = nil
    if(not isDebug())then
        loginUrl = config.getPidUrl(session_id)
    else
        loginUrl = config.getPidUrl_debug(session_id)
    end
    print("loginUrl=",loginUrl)
    local httpClent = CCHttpRequest:open(loginUrl, kHttpGet)
    require "script/ui/network/LoadingUI"
    LoadingUI.addLoadingUI()
    httpClent:sendWithHandler(

            function(res, hnd)
                require "script/ui/network/LoadingUI"
                LoadingUI.reduceLoadingUI()

                if(res:getResponseCode()~=200)then
                    require "script/ui/tip/AlertTip"
                    AlertTip.showAlert( GetLocalizeStringBy("key_1810"), nil, false, nil)
                    return
                end

                local xml = require "script/utils/LuaXml"
                print("res:getResponseData()=",res:getResponseData())
                local xmlTable = LuaXML.eval(res:getResponseData())
                --保存登录数据

                if(xmlTable == nil or xmlTable:find("uid") == nil) then
                    Platform.loginOut()
                    -- AlertTip.showAlert(GetLocalizeStringBy("key_1889"), loginAgain)
                    require "script/ui/tip/AlertTip"
                    AlertTip.showAlert(GetLocalizeStringBy("key_3194"), nil)
                    CCLuaLog("swap user info error -> uid is nill")
                    return
                end

                local uid = xmlTable:find("uid")[1]
                local errornu = xmlTable:find("errornu")[1]

                if(errornu == "0") then
                    _pid = uid
                    print("_pid=",_pid)
                    if(type(config.setLoginInfo) == "function")then
                        config.setLoginInfo(xmlTable)
                    end
                    if(_loginBackCall)then
                        print("_loginBackCall",_loginBackCall)
                        _loginBackCall()
                        _loginBackCall=nil
                    end

                elseif(errornu == "3") then
                    require "script/ui/tip/AlertTip"
                    AlertTip.showAlert(GetLocalizeStringBy("key_1411"), nil)
                    CCLuaLog("swap user info error errornu is not 0")
                    return

                else
                    -- SDK91Share:shareSDK91():loginOut()
                    require "script/ui/tip/AlertTip"
                    AlertTip.showAlert(GetLocalizeStringBy("key_1414"), nil)
                    CCLuaLog("swap user info error errornu is not 0")
                    return
                end
            end)
end

function getHashUrl( ... )
    local url
    if(type(config.getHashUrl) == "function") then
        url = config.getHashUrl()
    end

    if url == "" or url == nil then
        url = "http://mapifknsg.zuiyouxi.com/phone/getHash/"
    end

    return url
end

function getDomain( ... )
    local url
    if(type(config.getDomain) == "function") then
        url = config.getDomain()
    end

    if url == "" or url == nil then
        url = "http://mapifknsg.zuiyouxi.com/"
    end

    return url
end

function getDomain_debug( ... )
    local url
    if(type(config.getDomain_debug) == "function") then
        url = config.getDomain_debug()
    end

    if url == "" or url == nil then
        url = "http://124.205.151.82/"
    end

    return url
end

function getDownUrl( ... )
    local url
    if(type(config.getDownUrl) == "function") then
        url = config.getDownUrl()
    end

    if url == "" or url == nil then
        url = "http://static1.zuiyouxi.com/sanguo/"
    end

    return url
end

function getLayout( ... )
  if(config.getLayout ~= nil) then
    return config.getLayout()
  else
    return "cnLayout"
  end
end
-----------------------------与Platform_SDK的信息交互------------------------createByBaoXu
--Platform_SDK 对应的 接口 Teyp 类型
kEnterGameServer      = 0      --从Web端获取到Pid后开始登录游戏服务器   //Platform           490行  调用
kCreateNewRole        = 1      --创建新角色                          //UserHandler         72行  调用
kEnterTheGameHall     = 2      --进入游戏大厅                        //BulletinLayer       61行  调用
kOutOfStoryLine       = 3      --新手剧情之后(即进入首个副本)          //LoginScene         663行  调用
kRoleLevelInfo        = 4      --游戏内部玩家等级信息                 //UserModel          169行  调用
kShareButtonClick     = 5      --调用分享按钮
kComeInMainLayer      = 6      --进入选服主页面
kNewPlatformAccount   = 7      --新账号注册
kLeaveTheGameHall     = 8      --离开主页面

local beforeGame  = 0      --进入游戏之前
local inTheGame   = 1      --已经进入游戏

--统一接收游戏内部传过来的消息--messageType是上面定义的方法类型,param是附加参数(可传随意参数)
function sendInformationToPlatform(messageType, param)
    if(isPlatform() == false or messageType == nil)then
        return
    end

    local platformName = protocol:callStringFuncWithParam("getPlatformName",nil)
    local dict = CCDictionary:create()

    if (messageType == kComeInMainLayer) then
        dict:setObject(CCString:create(messageType),"type")
        protocol:callOCFunctionWithName_oneParam_noBack("receiveInformationFromLua",dict)
        return
    end

    --没有方法getPlatformName的平台 结束调用,意味着不需要 统计相关数据  
    if(type(config.getUserInfoParam) == "function")then
        --刚进入逻辑服务器的时候 有获取不到的参数 因此做下区分
        if(messageType == kEnterGameServer)then
            dict = config.getUserInfoParam(beforeGame)
        else
            dict = config.getUserInfoParam(inTheGame)
        end
    end

    --监听角色升级,添加等级参数
    if(messageType == kRoleLevelInfo)then
        local level = param
        dict:setObject(CCString:create(level),"level")
    end

    --注册分享后的方法回调, 并设置分享的内容
    if(messageType == kShareButtonClick)then
        print("registerShareCallback")
        protocol:registerScriptHandlers("shareCallBack",function( param )
            print(GetLocalizeStringBy("key_3190"),param.code)
            require "script/ui/share/ShareLayer"
            ShareLayer.shareCallback(param.code)
        end)
        dict = config.getShareInfoParam( dict )
    end
    if(Platform.getConfig().getFlag() == "huaqing")then
        if(messageType == kEnterTheGameHall) then
            local dict = CCDictionary:create()
            dict:setObject(CCString:create(CCUserDefault:sharedUserDefault():getStringForKey("lastLoginGroup")),"group")
            protocol:callOCFunctionWithName_oneParam_noBack("loginGame",dict)
        end
    end
    
    dict:setObject(CCString:create(messageType),"type")
    protocol:callOCFunctionWithName_oneParam_noBack("receiveInformationFromLua",dict)

end
-----------------------------与Platform_SDK的信息交互------------------------createByBaoXu

--android 点击back接口

function exitSDK( ... )
    if(getPlatformName() == "Android_uc") then
        protocol:callStringFuncWithParam("exitUCSDK",nil)
    else
        exit()
    end
end

function release( ... )
-- body
end

function exit()
    if(isPlatform() == false)then
        return
    end
    protocol:registerScriptHandlers("luaQuit",quit)
    protocol:callOCFunctionWithName_oneParam_noBack("exit",nil)
end

--启动防沉迷倒计时
local beginSchedule = false
local minute = 0
function antiAddictionSchedule( time )
    if(antiAddictionSchedule == false) then
        antiAddictionSchedule = true
        CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(antiAddictionSchedule, 60, false)
    end

    minute = minute + 1
    if(minute >= 3*60)then
        if((minute - 3*60)%15 == 0)then
            antiAddictionQuery(3)
        end
    elseif(minute >= 5*60)then
        if((minute - 3*60)%5 == 0)then
            antiAddictionQuery(5)
        end
    end

end

--防沉迷
--type类型:小时,3或5 
function antiAddictionQuery(type)
    --暂时只有360有
    if not (platformName == "Android_360")then
        return
    end
    if(isPlatform() == false)then
        return
    end
    local param = config.getPayParam(0)
    param:setObject(CCString:create(type),"type")
    protocol:callOCFunctionWithName_oneParam_noBack("antiAddictionQuery",param)
end

-- 注销平台用户
function logout( ... )
    require "script/ui/login/LoginScene"
    print("_bLoginInServerStatus：",LoginScene._bLoginInServerStatus)
    if LoginScene._bLoginInServerStatus == false then
        print("游戏角色已经退出情况下 调用平台注销")
        setPid(nil)
        return
    end
    Network.re_rpc(netWorkFailed, "failed") 
    Network.re_rpc(function ( ... )
        local scene = CCDirector:sharedDirector():getRunningScene()
        local node = CCNode:create()
        scene:addChild(node)
        node:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.1), CCCallFunc:create(function ( ... )
            LoginScene.enter()
        end)))
    end, "failed")
    require "script/network/Network"
    Network.rpc(function ( ... )
        print("...........rpc................logout")
    end, "user.closeMe", "user.closeMe", nil, true)
    setPid(nil)
end

--android 点击menu接口
function clickMenu( ... )
    local platformName = protocol:callStringFuncWithParam("getPlatformName",nil)
    if not (platformName == "Android_360" or platformName == "Android_dl" or platformName == "Android_xm" or platformName == "Android_renren")then
        return
    end
    function doRevive( flag,hid)
        if(flag==false)then

        else
            logout()
            protocol:callOCFunctionWithName_oneParam_noBack("switchAccount",nil)
        end
    end
    require "script/ui/tip/AlertTip"
    AlertTip.showAlert( "您要执行哪个操作", doRevive, false, hid,GetLocalizeStringBy("key_2204"))
end


--[[
add by lichenyang
@des:   得到当前平台标识
@ret:   返回GlobalVars 里面的常量
]]
function getCurrentPlatform( ... )

    if(isDebug() and isPlatform() == false) then
        return kPlatform_debug
    end

    local platformName = protocol:callStringFuncWithParam("getPlatformName",nil)
    if(platformName == "IOS_91")then
        return kPlatform_91_ios
    elseif(platformName == "IOS_PP")then
        return kPlatform_pp
    elseif(platformName == "IOS_TBT")then
        return kPlatform_tbt
    elseif(platformName == "ios_pps")then
        return kPlatform_pps
    elseif(platformName == "Android_360")then
        return kPlatform_360
    elseif(platformName == "Android_91")then
        return kPlatform_91_android
    elseif(platformName == "Android_uc") then
        return kPlatform_uc
    elseif(platformName == "Android_dl") then
        return kPlatform_dangle
    elseif(platformName == "Android_dk") then
        return kPlatform_dk
    elseif(platformName == "Android_wdj")then
        return kPlatform_wandoujia
    elseif(platformName == "Android_jf")then
        return kPlatform_jifeng
    elseif(platformName == "Android_kg")then
        return kPlatform_kugou
    elseif(platformName == "Android_pps")then
        return kPlatform_pps 
    elseif(platformName == "Android_jinshan")then
        return kPlatform_jinshan 
    elseif(platformName == "Android_37wan") then
        return kPlatform_37wan
    elseif(platformName == "Android_xm") then
        return kPlatform_xiaomi
    elseif(platformName == "Android_az") then
        return kPlatform_anzhi
    elseif(platformName == "IOS_APPSTORE") then
        return kPlatform_AppStore
    elseif(platformName == "IOS_PGY") then
        return kPlatform_pingguoyuan
    elseif(platformName == "IOS_DANGLE") then
        return kPlatform_dangleios
    elseif(platformName == "IOS_PP2") then
        return kPlatform_pp2
    elseif(platformName == "IOS_ITOOLS") then
        return kPlatform_iTools
    elseif(platformName == "IOS_KUAIYONG") then
        return kPlatform_kuaiyong
    elseif(platformName == "ios_kldny") then
        return kPlatform_kldny
    elseif(platformName == "Android_ck") then
        return kPlatform_chukong
    elseif(platformName == "Android_oppo") then
        return kPlatform_oppo
    elseif(platformName == "Android_pptv") then
        return kPlatform_pptv
    elseif(platformName == "Android_kuwo") then
        return kPlatform_kuwo
    elseif(platformName == "Android_huawei") then
        return kPlatform_huawei
    elseif(platformName == "Android_sogou") then
        return kPlatform_sogou
    elseif(platformName == "Android_youmi") then
        return kPlatform_youmi
    elseif(platformName == "Android_mumayi") then
        return kPlatform_mumayi
    elseif(platformName == "Android_yyh") then
        return kPlatform_yingyonghui
    elseif(platformName == "Android_xl") then
        return kPlatform_xunlei
    elseif(platformName == "Android_lenovo") then
        return kPlatform_lenovo
    elseif(platformName == "Android_vivo") then
        return kPlatform_vivo
    elseif(platformName == "Android_ck_dianxin") then
        return kPlatform_chukong_dx
    elseif(platformName == "Android_ck_liantong") then
        return kPlatform_chukong_lt
    elseif(platformName == "Android_ck_yidongMM") then
        return kPlatform_chukong_ydm
    elseif(platformName == "Android_ck_yidongGame") then
        return kPlatform_chukong_ydg
    elseif(platformName == "Android_3g") then
        return kPlatform_3g
    elseif(platformName == "Android_lenovoPush") then
        return kPlatform_lenovoPush
    elseif(platformName == "Android_chaohaowan") then
        return kPlatform_chaohaowan
    elseif(platformName == "Android_4399") then
        return kPlatform_4399
    elseif(platformName == "Android_shouyouba") then
        return kPlatform_shouyouba
    elseif(platformName == "Android_renren") then
        return kPlatform_renren
    elseif(platformName == "Android_baofeng") then
        return kPlatform_baofeng
    elseif(platformName == "Android_duoku") then
        return kPlatform_duoku
    elseif(platformName == "Android_zhangyue") then
        return kPlatform_zhangyue
    elseif(platformName == "Android_gamesky") then
        return kPlatform_gamesky
    elseif(platformName == "Android_kuaiwan") then
        return kPlatform_kuaiwan
    elseif(platformName == "Android_37wan") then
        return kPlatform_37wan
    elseif(platformName == "Android_skysea") then
        return kPlatform_skysea
    else
        return kPlatform_91_ios
    end



end


--[[
@des:得到用户pid
]]
function getPid( ... )
    return _pid
        -- return "d66d39b609e16384"
end

--[[
@des:设置pid
]]
function setPid( pidStr )
    if(isPlatform() == false)then
        _pid = pidStr
        return
    end
    _pid = pidStr
    local platformName = protocol:callStringFuncWithParam("getPlatformName",nil)
    if(platformName == "Android_amazon")then
        local dict = CCDictionary:create()
        dict:setObject(CCString:create(pidStr),"pid")
        protocol:callOCFunctionWithName_oneParam_noBack("onLogin",dict)
    elseif( platformName == "IOS_APPSTORE" )then
        print("IOS_APPSTORE—-setPid:",_pid)
        config.creatZxyMenuButton(_pid)
    elseif(platformName == "Android_zyx" and _pid ~= nil and config.getFlag() == "gwphone") then
        local dict = config.getWebViewUrl(_pid)
        protocol:callOCFunctionWithName_oneParam_noBack("showZxyMenuButton",dict)
    else
        print("setPid:",_pid)
    end
    if _pid ~= nil then
        isChangeAccount = false
    end
    print("Platform.getPlatformFlag()==", Platform.getPlatformFlag())
    if(_pid ~= nil and Platform.isAppStore() == true )then

        sendPushDeviceToken()
    end
end


local AppPurchaseDebugUrl  = "http://192.168.1.38/phone/exchange?pl=appstore&os=ios&gn=sanguo"
local AppPurchaseRelaseUrl = "http://mapifknsg.zuiyouxi.com/phone/exchange?pl=appstore&os=ios&gn=sanguo"

--[[
@des:支付监听头
]]
function addPurchaseListener( ... )
    local orderId    = CCUserDefault:sharedUserDefault():getStringForKey("purchase_orderId")
    local serverInfo = ServerList.getSelectServerInfo()
    --支付失败平台数据处理
    local failRequestCallback = function ( res,hnd )
        if(res:getResponseCode()~=200)then
            require "script/ui/tip/AlertTip"
            AlertTip.showAlert( GetLocalizeStringBy("key_1810"), nil, false, nil)
            return
        end
        removeWaiteLayer()
        local loginJsonString = res:getResponseData()
        print("purchase failedCall:" , loginJsonString)
        local cjson = require "cjson"
        local cancelInfo = cjson.decode(loginJsonString)
        print_t(cancelInfo)
    end

    --支付失败事件处理
    local failedCall = function ( ... )
        local requestUrl = ""
        if(BTUtil:getDebugStatus()) then
            requestUrl = AppPurchaseDebugUrl
            requestUrl = requestUrl .. "&issandbox=1"
        else
            requestUrl = AppPurchaseRelaseUrl
            requestUrl = requestUrl .. "&issandbox=0"
        end
        requestUrl = requestUrl .. "&pid="            .. getPid()
        requestUrl = requestUrl .. "&orderId="        .. orderId
        requestUrl = requestUrl .. "&action=cancel"
        requestUrl = requestUrl .. "&serverKey="      .. serverInfo.group

        local newUrl = nil
        require "script/ui/login/LoginScene"
        local bIsLarger = LoginScene.fnVersionCmp(_appVersion, "1.1.8")
        if bIsLarger then
            newUrl = addMd5ForVerifyUrl(requestUrl)
        end
        if newUrl == nil then
            newUrl = requestUrl
        end
        local httpClent = CCHttpRequest:open(newUrl, kHttpGet)

        httpClent:sendWithHandler(failRequestCallback)
        print("requestUrl:", requestUrl)
    end

    BTApplePurchase:shareApplePurchse():regisertPurchaseHandle(function ( pruchaseType, data )
        print(GetLocalizeStringBy("key_1764"))
        if(pruchaseType == "successed") then
            CCMessageBox( GetLocalizeStringBy("key_1377"), GetLocalizeStringBy("key_3301"))
            removeWaiteLayer()
        elseif(pruchaseType == "failed") then
            CCMessageBox(GetLocalizeStringBy("key_1917"), GetLocalizeStringBy("key_3301"))
            failedCall()
            removeWaiteLayer()
        elseif(pruchaseType == "purchaseCallback") then
            local oldUrl = BTApplePurchase:shareApplePurchse():getVerifyUrl()
            local newUrl = addMd5ForVerifyUrl(oldUrl)
            BTApplePurchase:shareApplePurchse():setMd5VerifyUrl(newUrl) 
        end
        print(pruchaseType, data)
    end)
end

local function fnSortUrlParams(pUrl)
    require "script/utils/LuaUtil"
    local result = ""
    local fullUrl = pUrl --.. "&BabeltimeSanguo"
    print("fullUrl : ", fullUrl)
    local aData01 = string.splitByChar(fullUrl, "?")
    if #aData01 > 1 then
        local params = ""
        for i=2, #aData01 do
            params = params .. aData01[i]
        end
        local aData02 = string.splitByChar(params, "&")
        if #aData02 > 1 then
            table.sort(aData02, function (p01, p02)
                return p01 < p02
            end)
        end
        result = table.concat(aData02, "")
    end

    return result
end

--local str = "action=create&gn=sanguo&pid=90f34efb71454d0d&pl=appstore&product_id=com.babeltime.cardSango.6rmb&time=201401271010&BabeltimeSanguo"

-- oldUrl="http://www.zuiyouxi.com/?action=confirm&key01=value01"
-- newUrl="http://www.zuiyouxi.com/?action=confirm&key01=value01&sign=xxxxxxxx"

--[[
@des:   检测支付数据是否正常
--]]
function addMd5ForVerifyUrl(pOldUrl)
    pOldUrl = pOldUrl .. "&uuid=" .. g_dev_udid
    local sortedParams = fnSortUrlParams (pOldUrl)
    sortedParams = sortedParams .. "BabeltimeSanguo"
    print("sortedParams = ", sortedParams)
    local sign = BTUtil:getMd5SumByString(sortedParams)
    --以下计算md5码
    local newUrl = pOldUrl .. "&sign=" .. sign
    print("lua new url:", newUrl)
    return newUrl
end

--[[
@des: app store 支付
]]
function payOfAppStore( product_id )
    showWaitLayer()

    require "db/DB_Apple_iap"
    local iapInfo = DB_Apple_iap.getDataById(product_id)
    local serverInfo = ServerList.getSelectServerInfo()
    local createOrderCallback = function ( res,hnd )
        if(res:getResponseCode()~=200)then
            require "script/ui/tip/AlertTip"
            AlertTip.showAlert( GetLocalizeStringBy("key_1810"), nil, false, nil)
            return
        end
        -- removeWaiteLayer()
        local loginJsonString = res:getResponseData()
        print("purchase create Call:" .. loginJsonString)
        local cjson = require "cjson"
        local createOrderInfo = cjson.decode(loginJsonString)
        if(createOrderInfo == nil) then
            print(GetLocalizeStringBy("key_2648"))
            LoadingUI.setVisiable(false)
            return
        end

        if(createOrderInfo.status == "0") then
            print(GetLocalizeStringBy("key_2114"), createOrderInfo.msg)

            CCUserDefault:sharedUserDefault():setStringForKey("purchase_orderId", createOrderInfo.orderId)
            CCUserDefault:sharedUserDefault():flush()

            print("开始app store 支付")
            BTApplePurchase:shareApplePurchse():buyProduct(iapInfo.productId)
        else
            print(GetLocalizeStringBy("key_2254"), createOrderInfo.status, GetLocalizeStringBy("key_3366"), createOrderInfo.msg)
        end
    end

    local requestUrl = ""
    if(BTUtil:getDebugStatus()) then
        requestUrl = AppPurchaseDebugUrl
        requestUrl = requestUrl .. "&issandbox=1"
    else
        requestUrl = AppPurchaseRelaseUrl
        requestUrl = requestUrl .. "&issandbox=0"
    end
    requestUrl = requestUrl .. "&pid="            .. getPid()
    requestUrl = requestUrl .. "&action=create"
    requestUrl = requestUrl .. "&serverKey="      .. serverInfo.group
    requestUrl = requestUrl .. "&product_id="     .. iapInfo.productId

    local newUrl = nil
    require "script/ui/login/LoginScene"
    local bIsLarger = LoginScene.fnVersionCmp(_appVersion, "1.1.8")
    if bIsLarger then
        newUrl = addMd5ForVerifyUrl(requestUrl)
    end
    if newUrl == nil then
        newUrl = requestUrl
    end
    local httpClent = CCHttpRequest:open(newUrl, kHttpGet)
    httpClent:sendWithHandler(createOrderCallback)
    print("requestUrl:", requestUrl)
end




local waitLayer = nil
function showWaitLayer( ... )
    require "script/utils/BaseUI"
    waitLayer =  BaseUI.createMaskLayer(-5000)
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(waitLayer,999999999,90901)

    local loadingSprite = CCSprite:create("images/common/bg/connectbg.png")
    loadingSprite:setAnchorPoint(ccp(0.5, 0.5))
    loadingSprite:setPosition(ccp(runningScene:getContentSize().width/2 , runningScene:getContentSize().height/2))
    loadingSprite:setScale(g_fScaleX) 
    waitLayer:addChild(loadingSprite)
    -- 动画
    local loadEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/load/load4"), -1,CCString:create(""));
    loadEffectSprite:retain()
    loadEffectSprite:setAnchorPoint(ccp(0.5, 0.5))
    loadEffectSprite:setPosition(ccp(loadingSprite:getContentSize().width*0.45, loadingSprite:getContentSize().height*0.5))
    loadEffectSprite:setScale(0.4)
    loadingSprite:addChild(loadEffectSprite)
    loadEffectSprite:release()
end

function removeWaiteLayer( ... )
    if(waitLayer ~= nil) then
        waitLayer:removeFromParentAndCleanup(true)
        waitLayer=nil
    end

end

function openUrl( url )
    if(url == nil)then
        return
    end 
    print("url=",url)
    if(g_system_type == kBT_PLATFORM_IOS )then
        PlatformUtil:openUrl(url)
    else
        local dict = CCDictionary:create()
        dict:setObject(CCString:create(url),"url")
        protocol:callOCFunctionWithName_oneParam_noBack("openUrl",dict)
    end
end

function registerCrashHandler( ... )
    print("registerCrashHandler")
    protocol:registerScriptHandlers("handleCrash",function( param )
        print("handleCrash")
        print("param",param)
        -- local cjson = require "cjson"
        -- local dict = cjson.decode(param)
        local param = ""
        local dumpPath=""
        param = param .. "&pid=" .. (_pid or 0)
        param = param .. "&env=lua"
        param = param .. "&gn=sanguo"
        param = param .. "&os="..getOS()
        param = param .. "&pl="..getPlName()

        local serverInfo = ServerList.getSelectServerInfo()
        param = param .. "&server="..serverInfo.host .. ":" .. serverInfo.port
        param = param .. "&server_group="..serverInfo.group
        -- for k,v in pairs(dict) do
        --     if(k == "functionName")then

        --     else
        --         print(k .. "=" .. v)
        --         param = param .. "&" .. k .. "=" .. v
        --     end
        -- end

        local url = "http://debug.zuiyouxi.com:17801/index.php?" .. param .. "&lua_traceback=" ..debug.traceback() .. "&lua_tracebackex=" .. tracebackex()
        url1 = string.gsub(url,"\n","<br>")
        url = nil
        url2 = string.gsub(url1,"\r","<br>")
        url1 = nil

        print("url=",url2)
        local dict = CCDictionary:create()
        dict:setObject(CCString:create(url2),"url")
        protocol:callOCFunctionWithName_oneParam_noBack("sendToServer",dict)
    end)
end

function tracebackex()  
    local ret = ""  
    local level = 3  
    ret = ret .. "stack traceback:\n"  
    while true do  
        --get stack info  
        local info = debug.getinfo(level, "Sln")  
        if not info then break end  
        local is_get_var = true
        if info.what == "C" then                -- C function  
            ret = ret .. tostring(level) .. "\tC function\n"  
        else           -- Lua function  
            ret = ret .. string.format("\t[%s]:%d in function `%s`\n", info.short_src, info.currentline, info.name or "") 

            if(string.find(info.source, "db/DB_") == 1)then
                is_get_var = false
            end 
        end  
        --get local vars  
        local i = 1  
        while is_get_var == true do  
            local name, value = debug.getlocal(level, i)  
            if not name then break end  
            ret = ret .. "\t\t" .. name .. " =\t" .. tostringex(value, 3) .. "\n"  
            i = i + 1  
        end    
        level = level + 1  
    end  
    return ret  
end  

function tostringex(v, len)  
    if len == nil then len = 0 end  
    local pre = string.rep('\t', len)  
    local ret = ""  
    if type(v) == "table" then  
        if len > 5 then return "\t{ ... }" end  
        local t = ""  
        for k, v1 in pairs(v) do  
            t = t .. "\n\t" .. pre .. tostring(k) .. ":"  
            t = t .. tostringex(v1, len + 1)  
        end  
        if t == "" then  
            ret = ret .. pre .. "{ }\t(" .. tostring(v) .. ")"  
        else  
            if len > 0 then  
                ret = ret .. "\t(" .. tostring(v) .. ")\n"  
            end  
            ret = ret .. pre .. "{" .. t .. "\n" .. pre .. "}"  
        end  
    else  
        ret = ret .. pre .. tostring(v) .. "\t(" .. type(v) .. ")"  
    end  
    return ret  
end    

OS_IOS="ios"
OS_ANDROID="android"

function getOS( ... )
    local OS = "android"
    if g_system_type == kBT_PLATFORM_IOS then
        OS = "ios"
    elseif g_system_type == kBT_PLATFORM_WP8 then
        OS = "wp"
    end
    return OS
end

function getGameName( ... )
    return "sanguo"
end

function getUrlParam( ... )
    return "&pl=" .. config.getFlag() .. "&gn=" .. getGameName() .. "&os=" .. getOS()
end

--用于只要这3个参数的首位
function getUrlParam2( ... )
    return "pl=" .. config.getFlag() .. "&gn=" .. getGameName() .. "&os=" .. getOS()
end


-- added by hechao
function quit( ... )
    if g_system_type == kBT_PLATFORM_ANDROID then
        local dict = CCDictionary:create()
        protocol:callOCFunctionWithName_oneParam_noBack("quit",dict)
    else
        CCDirector:sharedDirector():endToLua()
        os.exit()
    end
    BTUtil:exitNow()
end

function getOperatorsFlag( ... )
    local platformName = protocol:callStringFuncWithParam("getPlatformName",nil)
    if(platformName == "Android_ck")then
        return protocol:callStringFuncWithParam("getOperatorsFlag",nil)
    end

    return ""
end

-- add by chengliang
function sendPushDeviceToken()
    local sendDeviceKey = "isSendDeviceToken_" .. getPid()
    -- CCUserDefault:sharedUserDefault():setBoolForKey(sendDeviceKey, false)
    -- 是否已经发送过
    local isSend = CCUserDefault:sharedUserDefault():getBoolForKey(sendDeviceKey)
    if( isSend == nil or isSend == false )then
        local deviceToken = NSBundleInfo:getValueFromKeyChain("push_token")
        print("deviceTokendeviceToken=", deviceToken)
        if(deviceToken ~= nil and deviceToken ~= "")then

            require "script/utils/TimeUtil"
            local encrypt_key = "9c98948d313ccdAE962e899a60692c_russia"
            local str_url = "http://mapifknsg.zuiyouxi.com/phone/sendnotifications?"

            if(g_debug_mode == true)then
                str_url = "http://119.255.38.86/phone/sendnotifications?"
            end

            local str_param = "action=addtoken&devicetoken=".. deviceToken .. "&pid=" .. getPid() .. "&time=" .. TimeUtil.getSvrTimeByOffset()
            local md5_str = "action=addtokendevicetoken=".. deviceToken .. "pid=" .. getPid() .. "time=" .. TimeUtil.getSvrTimeByOffset() .. encrypt_key
            local str_sign = BTUtil:getMd5SumByString( md5_str )
            str_url = str_url .. str_param .. "&sign=" .. str_sign

            local sendDeviveTokenCallback = function ( res, hnd )
                local ret_str = res:getResponseData()
                local retCode = res:getResponseCode()
                print("ret_str, retCode= ", ret_str, retCode)

                if(tonumber(retCode) == 200)then
                    local cjson = require "cjson"
                    local ret_info = cjson.decode(ret_str)
                    if( ret_info.errcode ~= nil and ( tonumber(ret_info.errcode)==0 or tonumber(ret_info.errcode)==3 )  )then
                        print("send Ok~~")
                        CCUserDefault:sharedUserDefault():setBoolForKey(sendDeviceKey, true)
                    end
                end
            end
            print("str_url：", str_url)
            local httpClient = CCHttpRequest:open(str_url, kHttpGet)
            httpClient:sendWithHandler(sendDeviveTokenCallback)
        end
    end
end

