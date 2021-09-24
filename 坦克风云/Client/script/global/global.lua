--------以下是全局变量2
----以下代码上线需要检查----
G_Version = 1 --前台C++代码程序版本,强制更新程序使用
G_ifDebug = deviceHelper:ifDebug() --1:本地调试  0:正式地址
G_loginType = 1 --1:第三方平台方式 2:绑定邮箱方式
G_country = "cn" --国服
G_language = "" --简体中文
--获取币种的方法
G_loginAccountType = 2 --登录账号方式  1:绑定的账号方式 2:游客方式
G_chatVip = true --聊天是否显示vip等级:true显示 false不显示
G_chatAllianceName = false --聊天是否显示军团名称:true显示 false不显示
--G_luaVersion=1
G_isShowTip = false
G_blackListNum = 40 --黑名单人数上限
G_mailListNum = 30 --通讯录人数上限
G_encryptionTb = {} --加密之后配置的表
--法语 与 英语 的LV 区分
G_ELV = "LV."
G_FLV = "Niv."
G_LV = nil--根据语言判断 使用哪种LV
G_isStoryAutoHero = false --关卡是否自动选取英雄
G_isAtkAutoHero = false --大地图是否自动选取英雄
G_isBuildingAnim = false -- 建筑是否动画中
G_isLoginGoole = false --专门为阿拉伯谷歌登陆用
G_isNeedLoginGooleF5 = nil --需要刷新
G_privateDataTip = {} --私聊不在线提示取消所用数据
G_privateFlag = 0
G_inBackgroundTs = nil --游戏进入后台的时间戳
G_backgroundOutTime = 3600 --切入后台的超时时间（1个小时）

function G_getBHVersion() --是否为国内版号版本
    
    if base.platformUserId == "QH_498721088" or base.platformUserId == "Mi_64567211" or base.platformUserId == "QH_1378981164" or base.platformUserId == "QH_652491077" or base.platformUserId == "QH_1444240289" or base.platformUserId == "QH_122678114" or base.platformUserId == "UC_1500003861" then
        
        do
            return 2
        end
    end
    
    do
        return 1 --先暂时关闭这个功能
    end
    if G_getCurChoseLanguage() == "cn" and G_curPlatName() ~= "4" and G_curPlatName() ~= "efunandroiddny" then
        return 2
    else
        return 1
    end
end

--版号审核和谐版，关闭部分功能
function G_isHexie()
    -- 本地测试
    -- if(G_curPlatName()=="0" and playerVoApi:getPlayerLevel()<=20)then
    --     return true
    -- end
    --腾讯巨炮
    if(G_curPlatName() == "androidhuli" or G_curPlatName() == "androiddushibao")then
        return true
    end
    if(tostring(G_getDeviceid()) == "861648032436408" --[[or tostring(base.deviceID)=="862708020026519"]])then
        return true
    end
    --益玩
    -- if(G_curPlatName()=="androidewan" and playerVoApi and (playerVoApi:getUid()==1022091 or playerVoApi:getUid()==1022090 or playerVoApi:getUid()==1022089 or playerVoApi:getUid()==1022088 or playerVoApi:getUid()==1022087 or playerVoApi:getUid()==1022086 or playerVoApi:getUid()==1022085 or playerVoApi:getUid()==1022084 or playerVoApi:getUid()==1022082 or playerVoApi:getUid()==1021832 or playerVoApi:getUid()==1021814 or playerVoApi:getUid()==1021813 or playerVoApi:getUid()==1021835 or playerVoApi:getUid()==1021834 or playerVoApi:getUid()==1021833 or playerVoApi:getUid()==1021829 or playerVoApi:getUid()==1021830 or playerVoApi:getUid()==1021815 or playerVoApi:getUid()==1000000023 or playerVoApi:getUid()==1023455 or playerVoApi:getUid()==1023456 or playerVoApi:getUid()==1023457 or playerVoApi:getUid()==1023458 or playerVoApi:getUid()==1023459 or playerVoApi:getUid()==1023460 or playerVoApi:getUid()==1023461 or playerVoApi:getUid()==1023463 or playerVoApi:getUid()==1023464 or playerVoApi:getPlayerLevel()<=15))then
    --     return true
    -- end
    --3k和益玩的提审服
    if G_curPlatName() == "android3ktest" or G_curPlatName() == "androidewantest" then
        return true
    end
    return false
end

function G_luaVersion() --前台lua脚本版本,通知玩家及时更新程序时使用
    local luav = "1"
    if platCfg.platCfgLuaVersion[G_curPlatName()] ~= nil then
        luav = platCfg.platCfgLuaVersion[G_curPlatName()]
    end
    return tonumber(luav)
end

function G_curPlatName() --"0":appstore  "1":快用  "2":yeahmobi "3":efunIOS "googleplay":google  "qihoo":360 "memoriki":memoriki
    if PlatformManage ~= nil then
        return PlatformManage:shared():getPlatformType()
    end
    return "0"
end

--分阶段引导的开关
function G_phasedGuideOnOff()
    if platCfg.platCfgPhasedGuide[G_curPlatName()] and playerVoApi and playerVoApi:getRegdate() > 1426840430 then
        require "luascript/script/game/newguid/phasedGuideMgr"
        require "luascript/script/config/gameconfig/phasedGuideCfg"
        require "luascript/script/game/scene/scene/touchScene"
        
        return true
    else
        return false
    end
end

---以下--根据平台变换参数----
if platCfg.platCfgDefaultLocal[G_curPlatName()] ~= nil then
    G_country = platCfg.platCfgDefaultLocal[G_curPlatName()]
end
if deviceHelper ~= nil and deviceHelper.getCVersion ~= nil then
    G_Version = deviceHelper:getCVersion()
else
    G_Version = 1
end
if platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 8 or platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 9 or platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 10 then
    G_loginType = 2
end
---以下--根据平台变换参数----
function G_isIOS()
    if deviceHelper:getDeviceSystemName() == "iPhone OS" or deviceHelper:getDeviceSystemName() == "iOS" then
        return true
    else
        return false
    end
end

function G_isShowShareBtn()
    if(tonumber(base.curZoneID) > 900 and tonumber(base.curZoneID) < 1000)then
        do return false end
    end
    local curPlatform = G_curPlatName()
    if G_loginType == 1 and platCfg.platCfgShowShareBtn[curPlatform] ~= nil then --facebook显示分享
        return true
    elseif G_loginType == 2 and platCfg.platCfgShowShareBtn[curPlatform] ~= nil then --facebook显示分享
        return true
    end
    return false
end

function G_getCountry()
    local gcountry = ""
    
    if G_isIOS() then
        if G_curPlatName() == "0" or G_curPlatName() == "2" then
            if G_getCurAppstoreLocal() ~= "" then
                local appLocal = G_getCurAppstoreLocal();
                gcountry = Split(Split(appLocal, "=")[1], "@")[1]
            end
        elseif platCfg.platCfgCountry[G_curPlatName()] ~= nil then
            gcountry = platCfg.platCfgCountry[G_curPlatName()]
        end
    else
        gcountry = G_getCurAppstoreLocal()
    end
    
    return gcountry
end

function G_judgeEncryption(type, fee, paramMoney)
    if(G_isArab())then
        return false
    end
    local moneyName
    if(paramMoney)then
        moneyName = paramMoney
        G_encryptionTb = {}
    else
        moneyName = GetMoneyName()
    end
    if #G_encryptionTb == 0 then
        local tmpStoreCfg = G_getPlatStoreCfg()
        for k, v in pairs(tmpStoreCfg["money"][moneyName]) do
            local num = tonumber(v) * 5
            G_encryptionTb[k] = num.."rayjoy"
        end
    end
    
    local isCheating = false
    if type ~= nil and fee ~= nil then
        local num = tonumber(fee) * 5
        if num.."rayjoy" ~= G_encryptionTb[type] then
            isCheating = true
            
        end
    end
    return isCheating
end

function G_getCurAppstoreLocal()
    local curLocal = "zh_TW@currency=TWD";
    if AppStorePayment:shared().getCurAppstoreLocal ~= nil then
        curLocal = AppStorePayment:shared():getCurAppstoreLocal()
    end
    if G_curPlatName() == "1" or G_curPlatName() == "42" then --快用平台
        curLocal = "zh_CN@currency=CNY"
    end
    return curLocal
end

function GetMoneyName()
    local moneyName = "TWD"
    if G_isIOS() then
        
        if platCfg.platCfgMoneyName[G_curPlatName()] ~= nil then
            moneyName = platCfg.platCfgMoneyName[G_curPlatName()]
        else
            if G_getCurAppstoreLocal() ~= "" then
                local appLocal = G_getCurAppstoreLocal();
                moneyName = Split(appLocal, "=")[2]
            end
            local tmpStoreCfg = G_getPlatStoreCfg()
            if tmpStoreCfg["moneyType"][moneyName] == nil then
                moneyName = "TWD"
            end
        end
    else
        --安卓
        if PlatformManage ~= nil then --判断是否存在PlatformManage类
            if platCfg.platCfgMoneyName[G_curPlatName()] ~= nil then
                moneyName = platCfg.platCfgMoneyName[G_curPlatName()]
            else --特殊的平台写在这里
                
            end
        end
        
    end
    
    return moneyName
end

--获取当前设备的毫秒时间戳
function G_getCurDeviceMillTime()
    if(SocketHandler.getMillSecondTime ~= nil and SocketHandler.getCurSecondTime ~= nil and type(SocketHandler.getMillSecondTime) == "function" and type(SocketHandler.getCurSecondTime) == "function")then
        return SocketHandler:getCurSecondTime() * 1000 + SocketHandler:getMillSecondTime()
    else
        if(SocketHandler.getCurTime and type(SocketHandler.getCurTime) == "function")then
            return SocketHandler:getCurTime()
        else
            return 0
        end
    end
end

----以上代码上线需要检查----

G_VisibleSize = CCDirector:sharedDirector():getVisibleSize()
G_VisibleSizeWidth = G_VisibleSize.width
G_VisibleSizeHeight = G_VisibleSize.height

G_MainUIImage = "scene/mainUIImage.plist"
G_newMainUIImage1 = "scene/newMainUI_1.plist"
G_newMainUIImage2 = "scene/newMainUI_2.plist"
G_HomeBuildingImage = "homeBuilding/home_building.plist"
G_BoardUIImage = "scene/boardUI.plist"
G_VSAnimation = "WarImage/VSAnimation.plist"
G_BoomEffect = "WarImage/boomEffect.plist"
G_AllIcon = "public/allIcon.plist"
G_AllIcon2 = "public/AllIcon2.plist"
G_AllIcon3 = "public/allianceSkillIcon_new.plist"
G_AddAttackType_2 = "public/addAttackType_2.plist"
G_BoardExpendUI = "scene/boardExpendUI.plist"
G_LogoImage = "scene/logoImage.plist"
G_BuildingAnimSrc = "homeBuilding/buildingAnim.plist"
G_TankDieAni = "WarImage/tankDieAni.plist"

G_Tank1EffectSrc = "ship/effect_1.plist"
G_TankBulletSrc = "ship/tankbullet.plist"
G_Zawu = "WarImage/zawu.plist"
G_StoryImage = "story/storyImage.plist"
G_ImageSetting = "public/imageSetting.plist"
G_NewHitAni = "WarImage/newHitAni.plist"
G_BirdAndWaterImage = "scene/birdAndWaterImage.plist"
G_Tank1 = "ship/tank1.plist"
G_Tank2 = "ship/tank2.plist"
G_ChatImage = "public/chatImage.plist"
G_AccessoryCommonImage = "public/accessoryCommonImage.plist"
G_NewCommonImage = "public/newCommonImage.plist"
G_NewHitFireBulletAni = "WarImage/newBulletAndHitAndFireImage.plist"

G_ZD1Src = "ship/zd.png"
G_FontSrc = "WarImage/number_attack_new.fnt"
--G_MissSrc="WarImage/miss.fnt"
G_GoldFontSrc = "public/number_Gold.fnt"
G_GoldFontSrcNew = "public/123.fnt"
G_GoldFontSrc3 = "public/number_Gold3.fnt"
G_EmojiFontSrc = "fonts/android_emoji.ttf"
G_TimeFontSrc = "public/number_time.fnt"
G_SocketConnect = true
G_ColorWhite = ccc3(255, 255, 255)
G_ColorBlack = ccc3(50, 50, 50)
G_ColorRed = ccc3(255, 50, 50)
G_ColorRed2 = ccc3(108, 29, 33)
G_ColorRed3 = ccc3(255, 39, 80)
G_ColorYellow = ccc3(255, 235, 164)
G_ColorYellowPro = ccc3(240, 194, 33)
G_ColorYellowPro2 = ccc3(255, 228, 0)
G_ColorBrown = ccc3(140, 75, 66)
--G_ColorGreen=ccc3(70, 181, 125)
G_ColorBlue = ccc3(0, 255, 255)
G_ColorBlue2 = ccc3(16, 63, 251)
G_ColorBlue3 = ccc3(20, 230, 230)
G_ColorPurple = ccc3(218, 112, 214)
G_ColorOrange = ccc3(255, 97, 0)
G_ColorGreen2 = ccc3(14, 182, 97)
G_ColorGreen = ccc3(56, 246, 154)
G_ColorGray = ccc3(96, 96, 96)
G_ColorOrange = ccc3(255, 96, 0)
G_ColorOrange2 = ccc3(255, 145, 0)
--G_ColorGray=ccc3(144,144,144)
G_TabLBColorGreen = ccc3(44, 143, 104)
G_ColorAllianceYellow = ccc3(202, 137, 35)
G_ColorAutoUpgradeTime = ccc3(4, 212, 4)

if platCfg.platUseUIWindow[G_curPlatName()] ~= nil and platCfg.platUseUIWindow[G_curPlatName()] == 2 then
    G_ColorGreen = ccc3(0, 255, 255)
    G_ColorGreen2 = ccc3(0, 255, 255)
    G_TabLBColorGreen = ccc3(0, 255, 255)
end

--聊天高级vip文字变颜色
G_ColorVipChat = ccc3(246, 120, 37)

G_Json = require "cjson"

-- 超级装备：绿色
G_ColorEquipGreen = ccc3(94, 204, 15)
-- 超级装备：蓝色
G_ColorEquipBlue = ccc3(33, 191, 225)
-- 超级装备：紫色
G_ColorEquipPurple = ccc3(175, 92, 255)
-- 超级装备：橙色
G_ColorEquipOrange = ccc3(237, 118, 28)

-----------------推送消息tag类型---------------------
G_BuildUpgradeTag = 1
G_TechUpgradeTag = 2
G_TankProduceTag = 3
G_TankUpgradeTag = 4
G_ItemProduceTag = 5
G_EnergyFullTag = 6
G_timeTag = 7
G_timeTag2 = 8
---------------------------------------------------

-----------------本地缓存的用户信息key----------------
G_local_username = "tank_username" --有效的用户名
G_local_userpassword = "tank_userpassword" --有效的用户密码

G_local_isguest = "tank_isguest" --是否是游客登陆
G_local_payment = "appstorePayment" --支付串
G_local_paymentUid = "appstorePaymentUID" --支付串Uid
G_local_autoDefence = "gameSettings_autoDefence"
G_GameSettings = {"gameSettings_fleetArrive", "gameSettings_musicSetting", "gameSettings_effectSetting", "gameSettings_mainTaskGuide", "gameSettings_miniMapSetting", "gameSettings_buildingDisplay", "gameSettings_chatDisplay"} --设置面板对应的选项
--设置面板对应的选项
G_local_lastLoginSvr = "lastLogin_svr_" --最后登录的服务器
G_local_curLanguage = "languageChoose" --当前选择的语言
G_local_rectLoginSvr = "recent_svr_" --最近登陆过的服务器

G_local_showNoticeTime = "showNoticeTime" --用户点击显示公告的时间
G_local_svrcfg = "tank_serverCfg" --缓存服务器返回的配置
G_local_svrCfgVersion = "tank_serverCfgVersion" --服务器配置的版本信息
G_local_onlinePackage = "onlinePackage_onlineTime" --服务器配置的版本信息
G_local_acOnlineReward = "onlinePackage_acOnlineTime" --在线送好礼活动 在线时间
G_local_acOnlineReward2018 = "onlinePackage_acOnline2018Time" --在线送好礼2018活动 在线时间

G_local_BossAttackSelf = "boss_attackSelf" --世界boss 自动攻击

G_local_rayAccount = "tank_rayaccount" --rayjoy自己的账号
G_local_guestAccount = "tank_guestaccount" --游客账号

----------------------------------------------------
--聊天高级vip文字变颜色起始和截止时间
G_chatVipColorStartTime = 1424188800 --2015年2月18日00:00
G_chatVipColorEndTime = 1425571140 --2015年3月5日23:59

G_noticeStartTime = 1390878000 --显示公告的起始时间 2014年1月28日11:00
--G_noticeStartTime=0     --显示公告的起始时间 2014年1月28日11:00
G_noticeEndTime = 1392429600 --不显示公告的时间 2014年2月15日10:00

G_lastPushMsgFromServerTime = G_getCurDeviceMillTime()
G_CheckMem = {}
setmetatable(G_CheckMem, {__mode = "kv"})
--弱表
G_WeakTb = {}
setmetatable(G_WeakTb, {__mode = "kv"})

--存公会板子的表，每次有板子弹出的时候加入表中，关闭的时候清空，用来被踢出的时候关闭公会板子
G_AllianceDialogTb = {}
setmetatable(G_AllianceDialogTb, {__mode = "kv"})
G_isRefreshAllianceMemberTb = false
G_isRefreshAllianceApplicantTb = false
G_isRefreshAllianceWar = false
G_isRefreshGetpoint = true

--存军团战板子的表，用来判断是否弹出战斗结束结算面板
G_AllianceWarDialogTb = {}
--当前的语言名字，也是加载的语言文件的文件名
G_CurLanguageName = ""
setmetatable(G_AllianceWarDialogTb, {__mode = "kv"})

--存smallDialog板子
G_SmallDialogDialogTb = {}
setmetatable(G_SmallDialogDialogTb, {__mode = "kv"})

G_heroImage = {}
--存放英雄头像和技能图片名字的Tb

--聊天和邮件黑名单
G_blackList = nil
--发送黑名单请求
G_blackCallbackExist = false

--禁言范围 0：未禁言 1：聊天和邮件都禁言 2：聊天禁言 3：邮件禁言
G_forbidType = 0
--禁言是否通知玩家标识  0：不通知 1：通知
G_isNotice = 0
--禁言结束时间
G_forbidEndTime = 0

-- 装备通用面板
G_equipPanelBg = "equipPanelBg.png"
G_equipPanelBg_inRect = CCRect(165, 85, 1, 1)

-- 拖动阵型的对象存储起来，防止多对象调用
G_editLayer = {}

--双11随机表 目前只用于<火拼到底>(双11老版ver5)
gDouble11rTb = {}
gDoubleOnerTb = {}--用于新版双11 字段 ：new112018
--------以上是全局变量

--------以下是全局方法
--获取强制更新包地址的方法
function G_getFLUpdateUrl()
    local strUrl = ""
    
    if platCfg["platCfgUpdateUrl"][G_curPlatName()] ~= nil then
        strUrl = platCfg["platCfgUpdateUrl"][G_curPlatName()]
        if G_curPlatName() == "9" then
            local tmpTb = {}
            tmpTb["action"] = "getFlCoopId"
            local cjson = G_Json.encode(tmpTb)
            local flCoopIdStr = G_accessCPlusFunction(cjson)
            strUrl = strUrl..flCoopIdStr
        end
    end
    
    return strUrl
end

function G_dayin(tmpTb)
    print("打印的TB", G_Json.encode(tmpTb))
end

--释放英雄图片内存的方法
function G_releaseHeroImage()
    for k, v in pairs(G_heroImage) do
        CCTextureCache:sharedTextureCache():removeTextureForKey(v)
    end
    
end

--根据服务器ID获取服务器名称
function GetServerNameByID(id, isOnlyId)
    --if(serverCfg.allserver and serverCfg.allserver[G_country])then
    local oldZoneName, zoneName
    if serverCfg.realAllServer then
        for kk, vv in pairs(serverCfg.realAllServer) do
            for k, v in pairs(vv) do
                if(v.oldzoneid and tonumber(id) == tonumber(v.oldzoneid))then
                    oldZoneName = v.name
                    break
                elseif(tonumber(id) == tonumber(v.zoneid) and (tonumber(v.oldzoneid) == nil or tonumber(v.oldzoneid) == 0))then
                    zoneName = v.name
                    break
                end
            end
        end
    end
    if serverCfg.allserver then
        for kk, vv in pairs(serverCfg.allserver) do
            for k, v in pairs(vv) do
                if(v.oldzoneid and tonumber(id) == tonumber(v.oldzoneid))then
                    oldZoneName = v.name
                    break
                elseif(tonumber(id) == tonumber(v.zoneid) and (tonumber(v.oldzoneid) == nil or tonumber(v.oldzoneid) == 0))then
                    zoneName = v.name
                    break
                end
            end
        end
    end
    if(oldZoneName)then
        return GetServerName(oldZoneName, isOnlyId)
    end
    if(zoneName)then
        return GetServerName(zoneName, isOnlyId)
    end
    return getlocal("world_war_landType_unknow")
end

--获取服务器名称，分平台显示
function GetServerName(serverName, isOnlyId)
    local serverNameStr = serverName
    if serverNameStr and serverNameStr ~= "" then
        local serverNameArr = Split(serverNameStr, "-")
        if serverNameArr then
            if platFormCfg and platFormCfg["serverDesc_" .. (serverNameArr[1] or "") .. (serverNameArr[2] or "")] then
                serverNameStr = platFormCfg["serverDesc_" .. (serverNameArr[1] or "") .. (serverNameArr[2] or "")]
            end
        end
        local tmpServerNameStr = ""
        if type(serverNameStr) ~= "table" then
            tmpServerNameStr = serverNameStr
        else
            tmpServerNameStr = serverNameStr[G_getCurChoseLanguage()]
        end
        
        if G_curPlatName() ~= "androidlongzhong" and G_curPlatName() ~= "androidlongzhong2" and platCfg.platCfgSetStartServerAsFirst[G_curPlatName()] ~= nil then
            local tmpServerIndex = Split(tmpServerNameStr, "-")[1]
            for sidx = 1, string.len(tmpServerIndex) do
                local svrIndex = string.sub(tmpServerIndex, sidx)
                if tonumber(svrIndex) ~= nil then
                    do
                        local tempServerName = string.sub(tmpServerIndex, 1, sidx - 1) .. (tonumber(svrIndex) - tonumber(platCfg.platCfgSetStartServerAsFirst[G_curPlatName()]) + 1) .. "-"..Split(tmpServerNameStr, "-")[2]
                        if isOnlyId and isOnlyId == true then
                            local nameArr = Split(tempServerName, "-")
                            return nameArr[1]
                        end
                        return tempServerName
                    end
                end
            end
        end
        
        do
            if isOnlyId and isOnlyId == true and type(tmpServerNameStr) == "string" then
                local nameArr = Split(tmpServerNameStr, "-")
                return nameArr[1]
            end
            return tmpServerNameStr
        end
    end
    return ""
end

function GetBMLabel(key, src, size)
    local bmLabel = CCLabelBMFont:create(key, src)
    --bmLabel:setScale(size/28)
    bmLabel:setAnchorPoint(CCPointMake(0.5, 0.5))
    return bmLabel
end
--key:显示文字 size:文字大小 ,dimensions:文字显示区域大小,hAlignment:左右中对其,vAlignment:上下对齐
function GetTTFLabelWrap(key, size, dimensions, hAlignment, vAlignment, fontType, removeRichTag)
    if key == nil then
        key = ""
    end
    if G_isIOS() and G_curPlatName() == "11" and G_Version < 10 then
        key = key.."\n"
    end
    if G_isIOS() and G_curPlatName() == "4" and G_Version == 4 then
        key = key.."\n"
    end
    
    if G_getCurChoseLanguage() == "ar" and hAlignment ~= kCCTextAlignmentCenter then
        hAlignment = kCCTextAlignmentRight
    end
    if removeRichTag == true then
        key = string.gsub(key, "<rayimg>", "")
    end
    local bmLabel = CCLabelTTF:create(key, (fontType == nil and "Helvetica" or fontType), size, dimensions, hAlignment, vAlignment)
    if G_isIOS() and G_curPlatName() == "11" and G_Version < 10 then
        local szz = bmLabel:getContentSize()
        
        bmLabel:setContentSize(CCSizeMake(szz.width, szz.height + 10));
    end
    if G_isIOS() and G_curPlatName() == "4" and G_Version == 4 then
        local szz = bmLabel:getContentSize()
        bmLabel:setContentSize(CCSizeMake(szz.width, szz.height + 10));
    end
    
    bmLabel:setAnchorPoint(CCPointMake(0.5, 0.5))
    return bmLabel
end

-- 变颜色的label
function getRichLabel(key, size, dimension)
    if key == nil then
        key = "nil"
    end
    
    -- dimensions lable的面积（宽和高）
    local params = {
        text = key,
        fontSize = size,
        dimensions = dimension,
    }
    
    local testLabel = richLabel:new()
    local label, pureStr = testLabel:init(params)
    
    return label, pureStr
end

function GetTTFLabel(key, size, isBold)
    if key == nil then
        key = "nil"
    end
    local fontName
    if(isBold)then
        fontName = "Helvetica-bold"
    else
        fontName = "Helvetica"
    end
    key = string.gsub(key, "<rayimg>", "")
    local bmLabel = CCLabelTTF:create(key, fontName, size)
    bmLabel:setAnchorPoint(CCPointMake(0.5, 0.5))
    return bmLabel
end

function GetAllTTFLabel(key, size, anchorPoint, position, parent, zOrder, color, dimensions, hAlignment, vAlignment, fontType)
    if key == nil then
        key = "nil"
    end
    local temLabel
    if dimensions then
        temLabel = GetTTFLabelWrap(key, size, dimensions, hAlignment, vAlignment, fontType)
    else
        temLabel = GetTTFLabel(key, size)
    end
    if color then
        temLabel:setColor(color)
    end
    if parent then
        if zOrder then
            parent:addChild(temLabel, zOrder)
        else
            parent:addChild(temLabel)
        end
    end
    if anchorPoint then
        temLabel:setAnchorPoint(anchorPoint)
    end
    if position then
        temLabel:setPosition(position)
    end
    return temLabel
end

function SizeOfTable(tb)
    local size = 0
    if tb then
        for k, v in pairs(tb) do
            size = size + 1
        end
    end
    return size
end

function Split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

--node:父容器 point:坐标 tagPro:proGress tag值  tagLabel: label tag值 labelText:显示的文字 spriteNameBg:背景图帧名 spriteNamePro:前景图帧名 tagBg:背景图tag
-- changeRage 图片是横向还是纵向拉升（0，1）纵向 （1,0）横向
function AddProgramTimer(node, point, tagPro, tagLabel, labelText, spriteNameBg, spriteNamePro, tagBg, scaleX, scaleY, barOpacity, changeRage, labelSize, barPos, zOrder, newMidPoint)
    local psSprite1 = CCSprite:createWithSpriteFrameName(spriteNamePro);
    if barOpacity then
        psSprite1:setOpacity(barOpacity)
    end
    if changeRage == nil then
        changeRage = ccp(1, 0)
    end
    local timerSprite = CCProgressTimer:create(psSprite1);
    timerSprite:setMidpoint(newMidPoint or ccp(0, 1));
    timerSprite:setBarChangeRate(changeRage);
    timerSprite:setType(kCCProgressTimerTypeBar);
    timerSprite:setTag(tagPro);
    timerSprite:setPosition(point);
    if barPos then
        timerSprite:setPosition(barPos);
    end
    if scaleX == nil then
        scaleX = 1
    end
    if scaleY == nil then
        scaleY = 1
    end
    timerSprite:setScaleX(scaleX)
    timerSprite:setScaleY(scaleY)
    if zOrder == nil then
        zOrder = 2
    end
    node:addChild(timerSprite, zOrder);
    timerSprite:setPercentage(0); --设置初始百分比的值
    
    if labelSize == nil then
        labelSize = 24
    end
    if labelText ~= nil then
        local label = GetTTFLabel(labelText, labelSize);
        label:setPosition(ccp(timerSprite:getContentSize().width / 2, timerSprite:getContentSize().height / 2));
        timerSprite:addChild(label, 5);
        label:setTag(tagLabel);
    end
    
    if spriteNameBg ~= nil then
        local loadingBk = CCSprite:createWithSpriteFrameName(spriteNameBg);
        loadingBk:setPosition(point);
        loadingBk:setTag(tagBg);
        
        loadingBk:setScaleX(scaleX)
        loadingBk:setScaleY(scaleY)
        node:addChild(loadingBk, 1);
        
    end
    return timerSprite, psSprite1
end

function FormatNumber(number)
    number = math.floor(number)
    local numLength = string.len(number)
    local strNum = number .. ""
    
    if numLength > 3 and numLength <= 6 then
        strNum = string.format("%." .. (3 - numLength % 3) .. "f", number / (10 ^ 3))
        if numLength == 6 then
            strNum = string.sub(strNum, 0, 3) .. "K"
        else
            strNum = string.sub(strNum, 0, 4) .. "K"
        end
    elseif numLength > 6 and numLength <= 9 then
        strNum = string.format("%." .. (3 - numLength % 3) .. "f", number / (10 ^ 6))
        if numLength == 9 then
            strNum = string.sub(strNum, 0, 3) .. "M"
        else
            strNum = string.sub(strNum, 0, 4) .. "M"
        end
    elseif numLength > 9 and numLength < 12 then
        strNum = string.format("%." .. (3 - numLength % 3) .. "f", number / (10 ^ 9))
        strNum = string.sub(strNum, 0, 4) .. "G"
    elseif numLength >= 12 then
        strNum = string.format("%.0f", number / (10 ^ 9))
        strNum = strNum .. "G"
    end
    
    if numLength > 3 then
        if string.sub(strNum, -2, -2) == "." then
            strNum = string.sub(strNum, 0, -3) .. string.sub(strNum, -1, -1)
        end
    end
    strNum = replaceIllegal(strNum)
    return strNum
end

--str是带%s的语言，value是替换%s的table类型的值{"20","10"}
function FormatLanguage(str, value)
    local strFormat = str
    if value and type(value) == "table" then
        for k, v in pairs(value) do
            strFormat = string.gsub(strFormat, "%%s", v, k)
        end
    end
    return strFormat
end

--取node的中心点
function getCenterPoint(node)
    
    local centerPoint = ccp(node:getContentSize().width / 2, node:getContentSize().height / 2)
    return centerPoint;
end
function G_match(str)
    local pattern = "[%'%.,:;*?~`!@#$%%%^&+=)(<{} %]%[/\"]"
    return string.find(str, pattern)
end

function G_matchNumLetter(str)
    -- 正则表达式检测是否有非字母和数字
    return string.find(str, "[%W]+")
end

--time 秒数
function GetTimeForItemStr(time)
    local timeStr = "0m0s"
    if time < 3600 then
        timeStr = "("..math.floor(time / 60) .. "m"..math.floor(time % 60) .. "s" .. ")"
    elseif time >= 3600 and time < (3600 * 24) then
        timeStr = "("..math.floor(time / 3600) .. "h"..math.floor((time % 3600) / 60) .. "m"..math.floor(time % 60) .. "s" .. ")"
    elseif time >= (3600 * 24) then
        timeStr = "("..math.floor(time / (3600 * 24)) .. "d"..math.floor((time % (3600 * 24)) / 3600) .. "h"..math.floor((time % 3600) / 60) .. "m"..math.floor(time % 60) .. "s" .. ")"
    end
    timeStr = replaceIllegal(timeStr)
    return timeStr
end
--time 秒数
function GetTimeForItemStrState(time)
    local timeStr = "0m0s"
    if time < 3600 then
        timeStr = math.floor(time / 60) .. "m"..math.floor(time % 60) .. "s"
    elseif time >= 3600 and time < (3600 * 24) then
        timeStr = math.floor(time / 3600) .. "h"..math.floor((time % 3600) / 60) .. "m"..math.floor(time % 60) .. "s"
    elseif time >= (3600 * 24) then
        timeStr = math.floor(time / (3600 * 24)) .. "d"..math.floor((time % (3600 * 24)) / 3600) .. "h"..math.floor((time % 3600) / 60) .. "m"..math.floor(time % 60) .. "s"
    end
    timeStr = replaceIllegal(timeStr)
    return timeStr
end

--time 秒数
function GetTimeStr(time, isRemoveZero)
    local timeStr = "0m0s"
    if time < 3600 then
        timeStr = math.floor(time / 60) .. "m"..math.floor(time % 60) .. "s"
        if isRemoveZero == true and math.floor(time % 60) == 0 then
            timeStr = math.floor(time / 60) .. "m"
        end
    elseif time >= 3600 and time < (3600 * 24) then
        timeStr = math.floor(time / 3600) .. "h"..math.floor((time % 3600) / 60) .. "m"
        if isRemoveZero == true and math.floor((time % 3600) / 60) == 0 then
            timeStr = math.floor(time / 3600) .. "h"
        end
    elseif time >= (3600 * 24) then
        timeStr = math.floor(time / (3600 * 24)) .. "d"..math.floor((time % (3600 * 24)) / 3600) .. "h"
        if isRemoveZero == true and math.floor((time % (3600 * 24)) / 3600) == 0 then
            timeStr = math.floor(time / (3600 * 24)) .. "d"
        end
    end
    timeStr = replaceIllegal(timeStr)
    return timeStr
end
--time 秒数
function GetTimeStrForFleetSlot(time)
    -- 将一位数补齐为两位数
    local function addOneNum(num)
        if num < 10 then
            return "0"..num
        else
            return num
        end
    end
    local timeStr
    if time < 3600 and time >= 0 then
        timeStr = "00:"..addOneNum(math.floor(time / 60)) .. ":"..addOneNum(math.floor(time % 60))
    elseif time >= 3600 then
        timeStr = addOneNum(math.floor(time / 3600)) .. ":"..addOneNum(math.floor((time % 3600) / 60)) .. ":"..addOneNum(math.floor(time % 60))
    else
        timeStr = "00:00:00"
    end
    return timeStr
end
--封装按钮 selectNName:正常状态图片名字 selectSName:按下状态名字 selectDName:禁止点击名字 handler:调用方法 menuItemTag:menuitem的tag值 menuLabelText:menu上面文字 传nil为没有 labelsize:字体大小 lbTag:文本tag capInSet:9宫格布局,fullRect:9宫格按钮大小,isgray:是否置灰色
--selectNText 第一帧图上的文字，selectNTextPos 文字的坐标 isSmall 缩小效果
function GetButtonItem(selectNName, selectSName, selectDName, handler, menuItemTag, menuLabelText, labelsize, lbTag, capInSet, fullRect, selectNText, selectNTextPos, isbright, isSmall, btnSpColor)
    
    local selectN = CCSprite:createWithSpriteFrameName(selectNName);
    local selectS = CCSprite:createWithSpriteFrameName(selectSName);
    local selectD = GraySprite:createWithSpriteFrameName(selectDName);
    
    if capInSet then
        selectN = LuaCCScale9Sprite:createWithSpriteFrameName(selectNName, capInSet, function ()end)
        selectS = LuaCCScale9Sprite:createWithSpriteFrameName(selectSName, capInSet, function ()end)
        selectD = LuaCCScale9Sprite:createWithSpriteFrameName(selectDName, capInSet, function ()end)
        if fullRect then
            selectN:setContentSize(fullRect)
            selectS:setContentSize(fullRect)
            selectD:setContentSize(fullRect)
        end
    end
    
    if btnSpColor then
        if selectN and selectN.setColor then
            selectN:setColor(btnSpColor[1])
        end
        if selectS and selectS.setColor then
            selectS:setColor(btnSpColor[2])
        end
    end
    
    if selectNText and labelsize and selectNTextPos then
        local style = kCCTextAlignmentCenter
        
        if isSmall then
            style = kCCTextAlignmentRight
        end
        local selectNLb = GetTTFLabelWrap(selectNText, labelsize, CCSizeMake(selectN:getContentSize().width, 0), style, kCCVerticalTextAlignmentCenter, "Helvetica-bold");
        if isSmall then
            selectNLb:setAnchorPoint(ccp(1, 1))
        end
        if lbTag ~= nil then
            selectNLb:setTag(lbTag)
        end
        if selectNTextPos then
            selectNLb:setPosition(selectNTextPos)
        else
            selectNLb:setPosition(ccp(selectN:getContentSize().width / 2, selectN:getContentSize().height / 2))
        end
        
        local selectNLb1 = GetTTFLabelWrap(selectNText, labelsize, CCSizeMake(selectS:getContentSize().width, 0), style, kCCVerticalTextAlignmentCenter, "Helvetica-bold");
        if isSmall then
            selectNLb1:setAnchorPoint(ccp(1, 1))
        end
        if lbTag ~= nil then
            selectNLb1:setTag(lbTag)
        end
        if selectNTextPos then
            selectNLb1:setPosition(selectNTextPos)
        else
            selectNLb1:setPosition(ccp(selectN:getContentSize().width / 2, selectN:getContentSize().height / 2))
        end
        selectN:addChild(selectNLb, 6)
        selectS:addChild(selectNLb1, 6)
    end
    
    local menuItem3
    if isbright then
        menuItem3 = CCMenuItemImage:create(selectNName, selectSName, selectDName)
    else
        menuItem3 = CCMenuItemSprite:create(selectN, selectS, selectD);
    end
    
    if isSmall and tonumber(isSmall) then
        selectS:setScale(isSmall)
        selectS:setAnchorPoint(ccp(0.5, 0.5))
        selectS:setPosition(getCenterPoint(menuItem3))
    end
    
    if menuItemTag ~= nil then
        menuItem3:setTag(menuItemTag)
    end
    
    if menuLabelText ~= nil then
        
        local titleLb = GetTTFLabelWrap(menuLabelText, labelsize, CCSizeMake(menuItem3:getContentSize().width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter);
        if lbTag ~= nil then
            titleLb:setTag(lbTag)
        end
        titleLb:setPosition(ccp(menuItem3:getContentSize().width / 2, menuItem3:getContentSize().height / 2))
        menuItem3:addChild(titleLb, 6)
        titleLb:setFontName("Helvetica-bold")
        
    end
    
    menuItem3:registerScriptTapHandler(handler)
    
    return menuItem3;
end

function GetButtonItem2(selectNName, selectSName, selectDName, handler, menuItemTag, menuLabelText, labelsize, lbTag)
    
    local selectN = CCSprite:create(selectNName);
    local selectS = CCSprite:create(selectSName);
    local selectD = GraySprite:create(selectDName);
    
    local menuItem3 = CCMenuItemSprite:create(selectN, selectS, selectD);
    if menuItemTag ~= nil then
        menuItem3:setTag(menuItemTag)
    end
    
    if menuLabelText ~= nil then
        
        local titleLb = GetTTFLabelWrap(menuLabelText, labelsize, CCSizeMake(menuItem3:getContentSize().width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter);
        if lbTag ~= nil then
            titleLb:setTag(lbTag)
        end
        titleLb:setPosition(ccp(menuItem3:getContentSize().width / 2, menuItem3:getContentSize().height / 2))
        menuItem3:addChild(titleLb, 6)
        
    end
    
    menuItem3:registerScriptTapHandler(handler)
    
    return menuItem3;
end

--字符串替换方法 str1:目标字符 str2:需要替换的 str3:替换成
function G_stringGsub(str1, str2, str3)
    local str = nil
    str = (string.gsub(str1, str2, str3))
    return str
end
--取出第几个字符
function G_stringGetAt(str, i, j)
    local astring = string.sub(str, i, j)
    return astring
end

--时间换宝石
function TimeToGems(time)
    return math.ceil(time / 60)
end

--充值提示面板
--gemsNum：需要购买的金币数量(needGems-playerVo.gems>0) needGems：进行这项操作需要金币数量
function GemsNotEnoughDialog(title, content, gemsNum, layerNumber, needGems, clickSureCallback, clickCancelCallback)
    local layerNum = 4
    if layerNumber then
        layerNum = layerNumber
    end
    if title == nil then
        title = getlocal("dialog_title_prompt")
    end
    if content == nil then
        content = getlocal("gemNotEnough", {needGems, playerVo.gems, gemsNum})
    end
    local function callBack() --充值
        vipVoApi:showRechargeDialog(layerNum)
        if clickSureCallback then
            clickSureCallback()
        end
    end
    local function onCancel()
        if(clickCancelCallback)then
            clickCancelCallback()
        end
    end
    local tsD = smallDialog:new()
    tsD:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), callBack, title, content, nil, layerNum, nil, nil, onCancel)
    
    return tsD
end

function chatServerConnectSuccessHandler(data)
    if base then
        base.needLoginChatServer = true
    end
end

function chatMsgFromServer(data)
    print("收到服务器的聊天信息", data)
    local sData = G_Json.decode(tostring(data))
    --聊天消息里头加一个服务器id的验证，如果收到的消息不是这个服的，那就return
    if(sData.zid and tonumber(sData.zid) ~= tonumber(base.curZoneID))then
        do return end
    end
    if sData.type == "login" and sData.ret == 0 then
        print("登陆聊天服务器成功")
        --chatVoApi:clearByType(1)
        --chatVoApi:setIsReload(true)
        --chatDialogTab2:reloadChatDialog2WhenChatLogin()
        --chatDialogTab3:reloadChatDialog3WhenChatLogin()
        --socketHelper:sendChatMsg(1,0,"你妹的")
    elseif sData.type == "quit" and sData.ret == 0 then
        print("登出聊天服务器成功")
        --SocketHandler:shared():disConnect()
        
        --[[
        base.needLoginChatServer=false
        local chatSvrTb
        if serverCfg.allChatServer[base.curCountry]~=nil then
            for k,v in pairs(serverCfg.allChatServer[base.curCountry]) do
                if v.name==base.curArea then
                    chatSvrTb=v
                end
            end
        end
        if chatSvrTb~=nil then
            socketHelper:chatSocketConnect(chatSvrTb.ip,chatSvrTb.port) --连接聊天服务器
        end
        
]]
    else
        if sData.ret == -101 then
            
            local function callBack(...)
                -- body
            end
            -- 取消在线提示，伪造服务器数据
            local dataPrivate = {}
            dataPrivate.zoneid = base.curZoneID
            dataPrivate.type = "chat"
            dataPrivate.recivername = G_privateDataTip.reciverName
            dataPrivate.mkey = 18813090563
            dataPrivate.reciver = G_privateDataTip.reciver
            dataPrivate.channel = 0
            dataPrivate.ts = G_privateDataTip.ts
            dataPrivate.sender = G_privateDataTip.sender
            dataPrivate.content = G_privateDataTip.content
            dataPrivate.sendername = G_privateDataTip.senderName
            local data = G_Json.encode(dataPrivate)
            local isUpdate = chatVoApi:addChat(0, G_privateDataTip.sender, G_privateDataTip.senderName, G_privateDataTip.reciver, G_privateDataTip.reciverName, G_privateDataTip.content, G_privateDataTip.ts, callBack)
            if isUpdate == true then
                chatVoApi:savePrivateChatData(data, "18813090563")
            end
        else
            local contentType
            if sData.content and sData.content.contentType then
                contentType = sData.content.contentType
            end
            
            if contentType and contentType <= 3 then
                
                chatVoApi:useDataWithSpecially(sData)--聊天广播的数据 用于特殊处理使用,目前只有双11红包使用
                --{"type":"chat","sender":10000044,"nickname":"玩玩而已","reciver":0,"channel":1,"content":{"contentType":1,"level":7,"message":" ndndj","name":"玩玩而已","pic":2,"power":135,"rank":2,"subType":1,"uid":10000044},"ts":1383897559009}
                local isUpdate = chatVoApi:addChat(sData.channel, sData.sender, sData.sendername, sData.reciver, sData.recivername, sData.content, sData.ts, dataCallback)
                if isUpdate == true then
                    --保存私聊数据
                    if contentType == 1 and sData.content.subType == 2 then
                        chatVoApi:savePrivateChatData(data, sData.mkey)
                    end
                    
                    if base.commonDialogOpened_WeakTb["chatDialog"] ~= nil then
                        base.commonDialogOpened_WeakTb["chatDialog"]:tick()
                        if contentType == 1 and chatVoApi:isChat2_0() then
                            base.commonDialogOpened_WeakTb["chatDialog"]:refreshTabRedPoint()
                        end
                    else
                        if chatVoApi:isMultiLanguage(1) == true then
                            local content = sData.content
                            local language = content.language
                            if language == nil or language == "" then
                                language = "all"
                            end
                            chatVoApi:setNoNewData(1, language)
                        else
                            chatVoApi:setNoNewData(1)
                        end
                        chatVoApi:setNoNewData(2)
                        chatVoApi:setNoNewData(3)
                        -- if chatVoApi:isMultiLanguage(10000)==true then
                        --     local content=sData.content
                        --     local language=content.language
                        --     if language==nil or language=="" then
                        --         language="all"
                        --     end
                        --     chatVoApi:setNoNewData(10000,language)
                        -- else
                        --     chatVoApi:setNoNewData(10000)
                        -- end
                    end
                end
            elseif contentType == 4 then
                chatVoApi:updateGameData(sData.content, sData.channel)
            end
        end
    end
    -- chatVoApi:initLocalPrivateChatData()
end

function pushMsgFromServer(data)
    print("后台推来消息", data)
    local retTb = G_Json.decode(tostring(data))
    if retTb.cmd == "msg.event" then
        
        if retTb.data ~= nil and retTb.data.event ~= nil then
            local eventData = retTb.data.event
            if eventData.m ~= nil then
                local etype = eventData.m
                if etype ~= 3 then
                    G_updateEmailList(etype, nil, false)
                end
            end
            if eventData.f == 1 then
                --if (G_getCurDeviceMillTime()-G_lastPushMsgFromServerTime)>1000 then
                G_lastPushMsgFromServerTime = G_getCurDeviceMillTime()
                local function syncCallBack()
                    local acity = eventData.acity
                    if acity and acity == 1 then --攻打的是军团城市，战斗结束后需要同步一下军团城市的数据
                        allianceCityVoApi:initCity(nil, false)
                    end
                end
                G_SyncData(syncCallBack)
                --end
                --被攻击方收到战斗结束推送，则需要通知AI部队功能同步一下生产队列是否被打断
                if AITroopsVoApi:isOpen() == 1 then
                    if AITroopsVoApi:isFreeProduce() == false then
                        --如果AI部队功能面板没有打开，并且当前没有空闲队列时需要同步AI部队生产状态（主要同步队列有没有被打断的情况）
                        if eventDispatcher:hasEventHandler("aitroops.produce.refresh") == false then
                            AITroopsVoApi:AITroopsGet(0) --重新拉一下数据
                        else
                            eventDispatcher:dispatchEvent("aitroops.produce.refresh", {rtype = 2, ispush = 1})
                        end
                    end
                end
            end
            if eventData.r == 1 then
                local flag = arenaReportVoApi:getFlag()
                local function militaryGetlogCallback(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        if sData.data and sData.data.userarenalog then
                            if flag == -1 then
                                arenaReportVoApi:addReport(sData.data.userarenalog, false)
                            else
                                arenaReportVoApi:addReport(sData.data.userarenalog)
                                arenaReportVoApi:setFlag(0)
                            end
                        end
                    end
                end
                local minrid, maxrid = 0, 0
                local isPage = nil
                if flag ~= -1 then
                    minrid, maxrid = arenaReportVoApi:getMinAndMaxRid()
                    if minrid > 0 or maxrid > 0 then
                        isPage = true
                    end
                end
                socketHelper:militaryGetlog(minrid, maxrid, isPage, militaryGetlogCallback, false, 1)
            end
            if eventData.e and SizeOfTable(eventData.e) > 0 then
                expeditionVoApi:addReport({eventData.e})
            end
            --区域战有新战报
            if eventData.areawar then
                localWarVoApi:setIsNewReport(1, 0)
                localWarVoApi:setIsNewReport(2, 0)
                local selfAlliance = allianceVoApi:getSelfAlliance()
                if selfAlliance and selfAlliance.aid then
                    local aid = selfAlliance.aid
                    local params = {playerVoApi:getUid()}
                    chatVoApi:sendUpdateMessage(23, params, aid + 1)
                end
            end
            -- 处理好友申请相关的推送,好友相关的消息有推送
            if eventData.friends == 1 then
                -- 对方向我发了好友申请
                if eventData.invite then
                    friendInfoVoApi:addbinviteTb(eventData.user)
                    friendInfoVo.friendbiInviteFlag = 1
                end
                -- 对方同意我的好友申请,添加好友
                if eventData.agree then
                    friendInfoVoApi:addFriend(eventData.user)
                    friendInfoVoApi:removebinviteTb(tonumber(eventData.user[1]))
                    friendInfoVo.friendChanegFlag = 1
                    friendInfoVo.friendGiftFlag = 1
                    friendInfoVo.friendbiInviteFlag = 1
                end
                -- 对方拒绝我的好友申请，移除申请列表
                if eventData.reject then
                end
                -- 对方向我送礼
                if eventData.gift then
                    friendInfoVoApi:updateReceiveStatus(eventData.gift, 1)
                    friendInfoVo.friendGiftFlag = 1
                end
                -- 对方从好友别表删除了我
                if eventData.del then
                    friendInfoVoApi:removeFriend(eventData.del)
                    friendInfoVo.friendChanegFlag = 1
                    friendInfoVo.friendGiftFlag = 1
                end
            end
            if eventData.sw == 1 then
                local flag = superWeaponVoApi:getFlag()
                local function weaponGetlogCallback(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        if sData.data and sData.data.weaponroblog then
                            if flag == -1 then
                                superWeaponVoApi:addReport(sData.data.weaponroblog, false)
                            else
                                superWeaponVoApi:addReport(sData.data.weaponroblog)
                                superWeaponVoApi:setFlag(0)
                            end
                        end
                    end
                end
                local minrid, maxrid = 0, 0
                local isPage = nil
                if flag ~= -1 then
                    minrid, maxrid = superWeaponVoApi:getMinAndMaxRid()
                    if minrid > 0 or maxrid > 0 then
                        isPage = true
                    end
                end
                socketHelper:weaponGetlog(minrid, maxrid, isPage, weaponGetlogCallback, false, 1)
            end
            
        end
        if retTb.data.help or retTb.data.helpdel or retTb.data.newbuildings or retTb.data.newtechs then
            allianceHelpVoApi:addHelpData(retTb.data)
        end
    elseif retTb.cmd == "msg.task" then --有任务完成
        
        --if (G_getCurDeviceMillTime()-G_lastPushMsgFromServerTime)>500 then
        G_lastPushMsgFromServerTime = G_getCurDeviceMillTime()
        base:checkServerData(data)
        --G_SyncData()
        -- end
    elseif retTb.cmd == "msg.pay" then --支付
        vipVoApi:onPayment(retTb)
    elseif retTb.cmd == "alliance.memadd" then --军团成员增加
        if retTb.ts ~= nil then
            base.allianceTime = retTb.ts;
        end
        base:formatPlayerData(retTb)--军团成员增加的情况，去走format方法将成员加进去
        if retTb.data.alliance.alliance.members ~= nil then
            for k, v in pairs(retTb.data.alliance.alliance.members) do
                
                for i, j in pairs(allianceApplicantVoApi:getApplicantTab()) do
                    if tonumber(v.uid) == tonumber(j.uid) then
                        --判断如果新加入成员为申请列表里的成员删除该条申请并刷新板子
                        allianceApplicantVoApi:deleteApplicantByUid(v.uid)
                        G_isRefreshAllianceApplicantTb = true
                    end
                    
                end
                if tonumber(v.uid) == tonumber(playerVoApi:getUid()) then
                    --判断 新加入的成员为自己的时候去拉军团数据如果存在板子 关闭板子
                    local function getAlliacenCallback(fn1, data1)
                        local selfAlliance = allianceVoApi:getSelfAlliance()
                        if selfAlliance then
                            playerVoApi:setPlayerAid(selfAlliance.aid) --重置公会id
                            playerVoApi:setPlayerIsATag(0)
                            
                            local params = {allianceName = selfAlliance.name}
                            chatVoApi:sendUpdateMessage(7, params)
                            worldScene:updateAllianceName()
                            worldScene:addAllianceSp()
                            --工会活动刷新数据
                            activityVoApi:updateAc("fbReward")
                            activityVoApi:updateAc("allianceLevel")
                            activityVoApi:updateAc("allianceFight")
                            --刷新军团资金招募活动数据
                            local vo = activityVoApi:getActivityVo("fundsRecruit")
                            if vo ~= nil and activityVoApi:isStart(vo) == true then
                                local function updateCallback(fn, data)
                                    local ret, sData = base:checkServerData(data)
                                    if ret == true then
                                        acFundsRecruitVoApi:updateData(sData.data)
                                    end
                                end
                                socketHelper:activeFundsRecruit("updateTime", updateCallback)
                            end
                        end
                    end
                    if SizeOfTable(G_AllianceDialogTb) > 0 then
                        for k, v in pairs(G_AllianceDialogTb) do
                            v:close()
                        end
                    end
                    
                    allianceVoApi:removeApply()--清空请求
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alliance_jiaruTip"), 30)
                    base.allianceTime = nil
                    G_getAlliance(getAlliacenCallback)
                    allianceVoApi:clearRankAndGoodList()--清空军团列表
                    if serverWarTeamVoApi then
                        serverWarTeamVoApi:setWarInfoExpireTime(0)
                    end
                end
                
            end
        end
        G_isRefreshAllianceMemberTb = true
        
    elseif retTb.cmd == "alliance.memupdate" then --军团成员信息更新
        if retTb.ts ~= nil then
            base.allianceTime = retTb.ts;
        end
        base:formatPlayerData(retTb)--军团成员信息改变的情况，去走format方法将成员信息更新
        G_isRefreshAllianceMemberTb = true
        for k, v in pairs(retTb.data.alliance.alliance.members) do
            if tonumber(v.uid) == tonumber(playerVoApi:getUid()) then
                if tonumber(v.role) == 1 then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alliance_beitibaTip"), 30)
                elseif tonumber(v.role) == 0 then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alliance_beijiangzhiTip"), 30)
                elseif tonumber(v.role) == 2 then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alliance_beitibatuanTip"), 30)
                end
            end
        end
        
    elseif retTb.cmd == "alliance.memquit" then --军团成员信息更新
        if retTb.ts ~= nil then
            base.allianceTime = retTb.ts;
        end
        if retTb.data.alliance.alliance.members ~= nil then
            for k, v in pairs(retTb.data.alliance.alliance.members) do
                if v.uid ~= nil then
                    allianceMemberVoApi:deleteMemberByUid(v.uid)
                    if tonumber(v.uid) == tonumber(playerVoApi:getUid()) then
                        --如果删除的人是自己 关板子 谈tip 清空自己公会信息
                        if SizeOfTable(G_AllianceDialogTb) > 0 then
                            for k, v in pairs(G_AllianceDialogTb) do
                                v:close()
                            end
                        end
                        local str = getlocal("alliance_tichuTip", {v.cName})
                        if tonumber(v.role) == 1 then
                            str = getlocal("alliance_tichufuTip", {v.cName})
                        elseif tonumber(v.role) == 2 then
                            str = getlocal("alliance_tichuTip", {v.cName})
                        end
                        
                        if acDouble11NewVoApi then --用于双11军团红包
                            eventDispatcher:dispatchEvent("closeNewDouble11Dialog.becauseAllianceGetOut", nil)
                        end
                        
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), str, 30)
                        allianceVoApi:clear()--清空自己军团信息
                        allianceMemberVoApi:clear()--清空成员列表
                        allianceApplicantVoApi:clear()--清空
                        playerVoApi:clearAllianceData()
                        socketHelper:chatServerLogout()--聊天退出
                        allianceVoApi:clearRankAndGoodList()--清空军团列表
                        worldScene:removeAllianceSp()--删除同军团图标
                        worldScene:updateAllianceName()
                        --helpDefendVoApi:clear()--清空协防
                        --工会活动刷新数据
                        activityVoApi:updateAc("fbReward")
                        activityVoApi:updateAc("allianceLevel")
                        activityVoApi:updateAc("allianceFight")
                        if serverWarTeamVoApi then
                            serverWarTeamVoApi:setWarInfoExpireTime(0)
                        end
                    end
                end
            end
        end
        G_isRefreshAllianceMemberTb = true
        
    elseif retTb.cmd == "alliance.requestadd" then --申请成员增加
        if retTb.ts ~= nil then
            base.allianceTime = retTb.ts;
        end
        base:formatPlayerData(retTb)--申请成员信息改变的情况，去走format方法将成员信息更新
        G_isRefreshAllianceApplicantTb = true
        
    elseif retTb.cmd == "alliance.requestdeny" then --申请成员减少
        if retTb.ts ~= nil then
            base.allianceTime = retTb.ts;
        end
        if retTb.data.alliance.alliance.requests ~= nil then
            for k, v in pairs(retTb.data.alliance.alliance.requests) do
                if v.uid ~= nil then
                    allianceApplicantVoApi:deleteApplicantByUid(v.uid)
                    if tonumber(v.uid) == tonumber(playerVoApi:getUid()) then
                        local aid = retTb.data.alliance.alliance.aid
                        if tonumber(playerVoApi:getPlayerAid()) > 0 then
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alliance_beijujueTip", {v.cName}), 30)
                        end
                        allianceVoApi:removeApply(aid)
                    end
                end
            end
        end
        G_isRefreshAllianceApplicantTb = true
        
    elseif retTb.cmd == "alliance.update" then --军团成员信息更新
        if retTb.ts ~= nil then
            base.allianceTime = retTb.ts;
        end
        base:formatPlayerData(retTb)--申请成员信息改变的情况，去走format方法将成员信息更新
    elseif retTb.cmd == "alliance.memimpeach" then --弹劾信息推送
        if retTb.ts ~= nil then
            base.allianceTime = retTb.ts;
        end
        base:formatPlayerData(retTb)--申请成员信息改变的情况，去走format方法将成员信息更新
        G_isRefreshAllianceMemberTb = true
        
    elseif retTb.cmd == "alliance.mempromotion" then --晋升信息推送
        if retTb.ts ~= nil then
            base.allianceTime = retTb.ts;
        end
        base:formatPlayerData(retTb)--申请成员信息改变的情况，去走format方法将成员信息更新
        G_isRefreshAllianceMemberTb = true
    elseif retTb.cmd == "push.alliance.setResource" then --军团福利信息更新
        if retTb.data ~= nil then
            allianceVoApi:formatSelfAllianceData(retTb.data)
        end
    elseif retTb.cmd == "msg.helpdefense" then --协防
        helpDefendVoApi:clear()
        helpDefendVoApi:formatData(retTb.data)
    elseif retTb.cmd == "msg.helptroops" then --去协防的部队
        if retTb.data ~= nil then
            for k, v in pairs(retTb.data) do
                attackTankSoltVoApi:updateSlotByIdAndVo(k, v)
            end
            mainUI:clearFleetSlotTv()
        end
    elseif retTb.cmd == "limittask.update" then
        if retTb.data then
            limitChallengeVoApi:updateData(retTb.data.limittask)
        end
        -- 月度回馈推送
    elseif retTb.cmd == "monthgive.update" then
        if retTb.data then
            dailyYdhkVoApi:updateData(retTb.data.monthgive)
        end
    elseif retTb.cmd == "boom.data" then
        if retTb.data ~= nil and retTb.data.boom then
            
            local boomTb = retTb.data.boom
            -- print("here1111????",boomTb.bmd,gloryVo.isGloryOver)
            if boomTb.bmd ~= gloryVo.isGloryOver or gloryVoApi:isUpOrDownAboutLevel(boomTb.boom) == true then
                -- print("gloryVoApi:isUpOrDownAboutLevel(boomTb.boom)--------->",gloryVoApi:isUpOrDownAboutLevel(boomTb.boom))
                local oldx = playerVoApi:getMapX()
                local oldy = playerVoApi:getMapY()
                local params = {uid = playerVoApi:getUid(), boom = boomTb.boom, boomMax = boomTb.boom_max, boomAt = boomTb.boom_ts, boomBmd = boomTb.bmd, oldx = oldx, oldy = oldy}
                chatVoApi:sendUpdateMessage(35, params)
            end
            -- print("here????222222")
            gloryVoApi:refreshAllGlory(boomTb.boom, boomTb.boom_max, boomTb.boom_ts, boomTb.bmd)
        end
    elseif retTb.cmd == "alliance.giftadd" then
        if retTb.data and retTb.data.alliancegift then
            if base.allianceGiftSwitch == 1 and allianceGiftVoApi and allianceGiftVoApi.updateSpecialData then
                allianceGiftVoApi:updateSpecialData(retTb.data.alliancegift)
                allianceGiftVoApi:isCanChangeFlag()
                allianceGiftVoApi:setRefreshType(true)
            end
        end
    elseif retTb.cmd == "active.change" then --活动
        if retTb.data ~= nil then
            if retTb.data.xlpd then
                acXlpdVoApi:updateSpecialData(retTb.data.xlpd)
                acXlpdVoApi:isNewDataGet(true)
            end
            if retTb.data.xssd2019 and acXssd2019VoApi then
                local redid1 = acXssd2019VoApi:redBagId()
                if retTb.data.xssd2019.bf then
                    retTb.data.xssd2019.bf = nil
                end
                acXssd2019VoApi:updateSpecialData(retTb.data.xssd2019)
                local redid2 = acXssd2019VoApi:redBagId()
                if redid1<redid2 then
                    acXssd2019VoApi:redBagSceneGame()
                end
            end
            if retTb.data.znjl then
                acZnjlVoApi:updateSpecialData(retTb.data.znjl)
            end
            if retTb.data.czhk then
                acCzhkVoApi:updateSpecialData(retTb.data.czhk)
            end
            if retTb.data.hljb then
                acHljbVoApi:updateSpecialData(retTb.data.hljb)
            end
            if retTb.data.smcj then
                acSmcjVoApi:updateSpecialData(retTb.data.smcj)
            end
            if retTb.data.tqbj then
                acTqbjVoApi:updateSpecialData(retTb.data.tqbj)
            end
            if retTb.data.wsj2018 then
                acHalloween2018VoApi:updateData(retTb.data.wsj2018)
            end
            if retTb.data.khzr then
                acKhzrVoApi:updateSpecialData(retTb.data.khzr)
            end
            if retTb.data.duanwu then
                acDuanWuVoApi:updateSpecialData(retTb.data.duanwu)
            end
            if retTb.data.yrj then
                acYrjVoApi:updateSpecialData(retTb.data.yrj)
                acYrjVoApi:setRechargeTip(true, retTb.data.yrj.ch)
            end
            if retTb.data.thfb then
                acThfbVoApi:updateSpecialData(retTb.data.thfb)
            end
            if retTb.data.xlys then
                acXlysVoApi:updateSpecialData(retTb.data.xlys)
            end
            if retTb.data.kljz then
                acKljzVoApi:updateData(retTb.data.kljz)
                acKljzVoApi:setCurTaskedTb(retTb.data.kljz.dt)
                acKljzVoApi:setUsedStep(retTb.data.kljz.c)
                acKljzVoApi:setAllSteps(retTb.data.kljz.v)
            end
            if retTb.data.zzrs then
                acThrivingVoApi:setHasBeenRecAwardTb(retTb.data.zzrs.rd)
                acThrivingVoApi:setCompletTaskTb(retTb.data.zzrs.tk)
                acThrivingVoApi:sethadBigAward(retTb.data.zzrs.c)
            end
            if retTb.data.benfuqianxian then
                local point = acBenfuqianxianVoApi:getIntegralCount()
                acBenfuqianxianVoApi:setLastIntegral(tonumber(point))
            end
            
            if retTb.data.xcjh then
                acXcjhVoApi:updateSpecialData(retTb.data.xcjh)
            end
            if retTb.data.jtxlh then --军团喜乐汇接收到推送消息，说明该玩家本次充值解锁了军团奖励，则需要同步军团数据
                if acJtxlhVoApi then
                    acJtxlhVoApi:syncAllianceFlag(retTb.data.jtxlh) --同步军团旗帜数据
                end
            end
            if retTb.data.xsjx2020 then --限时惊喜的特殊处理
                --由于充值成功后，后端没法处理数据，只能前端添加个标识自己再主动请求get接口来获取最新数据
                retTb.data.xsjx2020["_getFlag"] = 1
            end
            
            activityVoApi:updateVoByType(retTb.data)
            if retTb.data.firstRecharge then
                eventDispatcher:dispatchEvent("user.pay", {})
            end
            if retTb.data.firstRechargenew then
                G_SyncData()
            end
            if retTb.data.stormFortress then
                if retTb.data.stormFortress.missile then
                    acStormFortressVoApi:setCurrentBullet(retTb.data.stormFortress.missile)
                end
                if retTb.data.stormFortress.d and retTb.data.stormFortress.d.task then
                    acStormFortressVoApi:setTaskRecedTb(retTb.data.stormFortress.d.task)--重置任务领奖状态
                    acStormFortressVoApi:setFN(retTb.data.stormFortress.d.fn)
                end
                acStormFortressVoApi:updateMissile(nil, retTb.data.stormFortress.t)
                
            end
            if retTb.data.halloween then
                -- print("halloween!!!!!!!!!!!!!!!!!!")
                acSweetTroubleVoApi:setChanData(1, true)
                acSweetTroubleVoApi:setChanData(2, true)
            end
            if retTb.data.ganenjiehuikui then
                acThanksGivingVoApi:setNewData(retTb.data.ganenjiehuikui)
                acThanksGivingVoApi:setAllDataRefresh()
                acThanksGivingVoApi:setRefresh(true)
            end
            if retTb.data.qmcj then
                local aScores = acEatChickenVoApi:getLegionMembersScores()
                if retTb.data.qmcj and retTb.data.qmcj.allipoint and tonumber(retTb.data.qmcj.allipoint) > aScores then
                    local retTbb = {}
                    local newScores = retTb.data.qmcj.allipoint
                    retTbb["scores"] = tonumber(newScores)
                    retTbb["alliance"] = nil --allianceVoApi:getSelfAlliance()
                    if allianceVoApi:isHasAlliance() then
                        retTbb["allianceName"] = allianceVoApi:getSelfAlliance()["name"]
                    end
                    local prams = {retTb = retTbb}
                    
                    chatVoApi:sendUpdateMessage(53, prams)
                end
                acEatChickenVoApi:updateInServer(true, retTb.data.qmcj)
                acEatChickenVoApi:setUpDataState1(true)
            end
            if retTb.data.qmsd and acQmsdVoApi then
                local noData, lastAllRechargeNums = acQmsdVoApi:getAllRechargeNums()
                if retTb.data.qmsd.c and tonumber(retTb.data.qmsd.c) > lastAllRechargeNums then
                    local retTbb = {}
                    local newAllRechargeNums = retTb.data.qmsd.c
                    retTbb["newAllRechargeNums"] = tonumber(newAllRechargeNums)
                    local prams = {retTb = retTbb}
                    chatVoApi:sendUpdateMessage(54, prams)
                end
                acQmsdVoApi:updateInServer(true, retTb.data.qmsd)
            end
            
            if retTb.data.christmasfight then
                acChristmasFightVoApi:updateData(retTb.data.christmasfight)
                if retTb.data.devil then
                    acChristmasFightVoApi:setSnowmanData(retTb.data.devil)
                end
                if retTb.data.send then
                    local status = acChristmasFightVoApi:getSnowmanData()
                    acChristmasFightVoApi:checkSendChat(nil, status, true)
                end
                local prams = {retTb = retTb}
                chatVoApi:sendUpdateMessage(28, prams)
                acChristmasFightVoApi:setFlag(0)
                if retTb.data.res then
                    local method = retTb.data.res[1]
                    local rescount = tonumber(retTb.data.res[2] or 0)
                    -- print("method",method)
                    -- print("rescount",rescount)
                    if method and rescount then
                        local acVo = acChristmasFightVoApi:getAcVo()
                        if method == 1 then --军功
                            if acVo and rescount >= acVo.addBp then
                                local message = {key = "activity_christmasfight_chat_1", param = {playerVoApi:getPlayerName(), FormatNumber(rescount)}}
                                chatVoApi:sendSystemMessage(message)
                            end
                        elseif method == 2 then --资源
                            if acVo and rescount >= acVo.addRes then
                                local message = {key = "activity_christmasfight_chat_2", param = {playerVoApi:getPlayerName(), FormatNumber(rescount)}}
                                chatVoApi:sendSystemMessage(message)
                            end
                        end
                    end
                end
            end
            if retTb.data.shengdanqianxi and retTb.data.shengdanqianxi.g then
                acChrisEveVoApi:setRecGiftTbNoName(retTb.data.shengdanqianxi.g)
                acChrisEveVoApi:setIsNewData(1)
            end
            if retTb.data.anniversaryBless then
                -- print("*************周末狂欢活动推送*************")
                acAnniversaryBlessVoApi:updateData(retTb.data.anniversaryBless)
                acAnniversaryBlessVoApi:setRefreshWordsFlag(true)
                acAnniversaryBlessVoApi:setRefreshRecordFlag(true)
            end
            if retTb.data.rechargebag then
                acRechargeBagVoApi:updateData(retTb.data.rechargebag)
                acRechargeBagVoApi:setAllFlag()
            end
            if retTb.data.benfuqianxian then
                local lastPoint = acBenfuqianxianVoApi:getLastIntegral()
                local curPoint = acBenfuqianxianVoApi:getIntegralCount()
                local noticeCfg = acBenfuqianxianVoApi:getNeedNoticeCfg()
                for k, notice in pairs(noticeCfg) do
                    local noticePoint = tonumber(notice[1])
                    local noticeStr = tostring(notice[2])
                    if lastPoint and curPoint and lastPoint < noticePoint and curPoint >= noticePoint then
                        local paramTab = {}
                        paramTab.functionStr = "benfuqianxian"
                        paramTab.addStr = "i_also_want"
                        message = {key = noticeStr, param = {playerVoApi:getPlayerName(), getlocal("activity_benfuqianxian_title")}}
                        chatVoApi:sendSystemMessage(message, paramTab)
                        
                        local params = {key = noticeStr, param = {{playerVoApi:getPlayerName(), 1}, {"activity_benfuqianxian_title", 2}}}
                        chatVoApi:sendUpdateMessage(41, params)
                    end
                end
                acBenfuqianxianVoApi:setAllFlag()
            end
            if retTb.data.zhanyoujijie then
                if acZhanyoujijieVoApi then
                    if retTb.data.zhanyoujijie.selfbd then
                        local bd = retTb.data.zhanyoujijie.selfbd
                        acZhanyoujijieVoApi:updateData({bd = bd})
                        acZhanyoujijieVoApi:setBdListFlag(1)
                    else
                        acZhanyoujijieVoApi:updateRecharge(retTb.data.zhanyoujijie, retTb.ts)
                    end
                end
            end
            if retTb.data.djrecall then
                if acGeneralRecallVoApi then
                    local player = retTb.data.djrecall.list
                    if player then --添加绑定玩家
                        acGeneralRecallVoApi:addBindPlayer(player)
                    end
                end
            end
        end
    elseif retTb.cmd == "event.radio" then
        if retTb.data.id == "ganenjiehuikui" then--activity_ganenjiehuikui_chat
            local serverData = retTb.data.data["globalServerData"]
            if serverData and tonumber(serverData) then
                print("serverData------>", serverData)
                chatVoApi:sendSystemMessage(getlocal("activity_ganenjiehuikui_chat", {serverData}))
            end
        end
        
    elseif retTb.cmd == "active.calls.push" then
        if retTb.data ~= nil then
            activityVoApi:afterPushCallsData(retTb.data)
        end
    elseif retTb.cmd == "active.shareHappiness.push" then -- 有福同享推送分享礼包
        if retTb.data ~= nil then
            activityVoApi:shareHappinessAddGiftList(retTb.data)
        end
    elseif retTb.cmd == "alliance.challenge" then --军团副本信息更新
        allianceFubenVoApi:updateTank(retTb.data)
        --军团战报名
    elseif retTb.cmd == "alliance.memapplybattle" then
        local selfAlliance = allianceVoApi:getSelfAlliance()
        if(selfAlliance and retTb.data.alliance.alliance.members and retTb.data.alliance.alliance.members[1])then
            selfAlliance.point = tonumber(retTb.data.alliance.alliance.members[1].point)
            allianceWarVoApi.targetCity = tonumber(retTb.data.alliance.alliance.members[1].areaid)
        end
        --新军团战报名
    elseif retTb.cmd == "alliancewarnew.memapplybattle" then
        local selfAlliance = allianceVoApi:getSelfAlliance()
        if(selfAlliance and retTb.data.alliance.alliance.members and retTb.data.alliance.alliance.members[1])then
            selfAlliance.point = tonumber(retTb.data.alliance.alliance.members[1].point)
            allianceWar2VoApi.targetCity = tonumber(retTb.data.alliance.alliance.members[1].areaid)
        end
        --区域战报名,群雄争霸报名
    elseif retTb.cmd == "alliance.memapplyareabattle" or retTb.cmd == "alliance.memapplyareawarbattle" then
        local selfAlliance = allianceVoApi:getSelfAlliance()
        if(selfAlliance and retTb.data.alliance.alliance.members and retTb.data.alliance.alliance.members[1])then
            selfAlliance.point = tonumber(retTb.data.alliance.alliance.members[1].point)
        end
        if retTb.cmd == "alliance.memapplyareawarbattle" then
            serverWarLocalVoApi:setSelfApplyData({apply_at = tonumber(retTb.ts)})
        end
    elseif retTb.cmd == "alliancewar.battle.push" then --军团战战斗
        base:formatPlayerData(retTb)
        G_isRefreshAllianceWar = true
        allianceWarRecordVoApi:setRFlag(-1)
        allianceWarRecordVoApi:setDFlag(-1)
        allianceWarRecordVoApi:setHasNew(true)
        --allianceWarRecordVoApi:setPersonMaxNum(allianceWarRecordVoApi:getPersonMaxNum()+1)
    elseif retTb.cmd == "alliancewarnew.battle.push" then --新军团战战斗
        base:formatPlayerData(retTb)
        allianceWar2VoApi:setCurHero(retTb)
        allianceWar2VoApi:setCurAITroops(retTb)
        allianceWar2VoApi:setCurTroopsSkin(retTb)
        G_isRefreshAllianceWar = true
        allianceWar2RecordVoApi:setRFlag(-1)
        allianceWar2RecordVoApi:setDFlag(-1)
        allianceWar2RecordVoApi:setHasNew(true)
        allianceWar2RecordVoApi:setAFlag(-1)
        allianceWar2RecordVoApi:setAllianceHasNew(true)
        --allianceWar2RecordVoApi:setPersonMaxNum(allianceWarRecordVoApi:getPersonMaxNum()+1)
    elseif retTb.cmd == "alliancewar.regroup.push" then --军团战重新集结
        base:formatPlayerData(retTb)
        G_isRefreshAllianceWar = true
        allianceWarRecordVoApi:setRFlag(-1)
    elseif retTb.cmd == "alliancewarnew.regroup.push" then --新军团战重新集结
        base:formatPlayerData(retTb)
        G_isRefreshAllianceWar = true
        allianceWar2RecordVoApi:setRFlag(-1)
        allianceWar2RecordVoApi:setAFlag(-1)
    elseif retTb.cmd == "alliance.memupqueue" or retTb.cmd == "alliance.memreadybatte" then --军团战成员参战和上下阵成员
        base:formatPlayerData(retTb)
        if retTb.data ~= nil then
            if retTb.data.alliance and retTb.data.alliance.alliance then
                allianceWarVoApi:updateBattleMem(retTb.data.alliance.alliance)
            end
        end
    elseif retTb.cmd == "alliance.buyshop.push" then --有其他成员购买了军团商店的商品
        if(retTb.data and retTb.data.alliancebuyshoppush)then
            allianceShopVoApi:otherPlayerBuyItem(retTb.data.alliancebuyshoppush.id, retTb.data.alliancebuyshoppush.slot)
        end
    elseif retTb.cmd == "alliancewar.over.push" then --军团战结束
        G_isRefreshGetpoint = false
        allianceWarVoApi:setIsEnd(true)
        G_updateEmailList(1, nil, false)
        allianceWarRecordVoApi:setDFlag(-1)
        allianceWarVoApi:setCityInfoExpire(nil)
        
        local function getbattlelogCallback(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                if sData.data and sData.data.alog then
                    allianceWarRecordVoApi:formatResultData(sData.data.alog)
                    base.pauseSync = false
                    G_SyncData()
                    if (G_AllianceWarDialogTb["allianceWarDialog"] or G_AllianceWarDialogTb["allianceWarOverviewDialog"]) and battleScene.isBattleing == false then
                        local isVictory = allianceWarRecordVoApi:isVictory()
                        local params = {}
                        local function callback(tag, object)
                        end
                        allianceSmallDialog:showWarResultDialog("PanelHeaderPopup.png", CCSizeMake(600, 600), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), isVictory, callback, true, 7, params)
                    end
                    allianceWarVoApi:setPoint(allianceWarRecordVoApi.redPoint, allianceWarRecordVoApi.bluePoint)
                end
            end
            
        end
        local type = 2
        local selfAlliance = allianceVoApi:getSelfAlliance()
        local aid = selfAlliance.aid
        local uid = playerVoApi:getUid()
        local warid = allianceWarVoApi.warid
        -- print("aid",aid)
        -- print("uid",uid)
        -- print("warid",warid)
        if warid and warid > 0 then
            socketHelper:allianceGetbattlelog(warid, type, aid, uid, nil, nil, getbattlelogCallback)
        end
        base.allianceTime = nil
        G_getAlliance()
    elseif retTb.cmd == "alliancewarnew.over.push" then --新军团战结束
        G_isRefreshGetpoint = false
        allianceWar2VoApi:setIsEnd(true)
        G_updateEmailList(1, nil, false)
        allianceWar2RecordVoApi:setDFlag(-1)
        allianceWar2VoApi:setCityInfoExpire(nil)
        
        local function getbattlelogCallback(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                if sData.data and sData.data.alog then
                    allianceWar2RecordVoApi:formatResultData(sData.data.alog)
                    base.pauseSync = false
                    G_SyncData()
                    if (G_AllianceWarDialogTb["allianceWar2Dialog"] or G_AllianceWarDialogTb["allianceWar2OverviewDialog"]) and battleScene.isBattleing == false then
                        allianceWar2VoApi:showResultDialog()
                    else
                        allianceWar2VoApi:setIsShowResult(true)
                    end
                    allianceWar2VoApi:setPoint(allianceWar2RecordVoApi.redPoint, allianceWar2RecordVoApi.bluePoint)
                end
            end
        end
        local type = 2
        local selfAlliance = allianceVoApi:getSelfAlliance()
        local aid = selfAlliance.aid
        local uid = playerVoApi:getUid()
        local warid = allianceWar2VoApi.warid
        -- print("aid",aid)
        -- print("uid",uid)
        -- print("warid",warid)
        if warid and warid > 0 then
            socketHelper:alliancewarnewGetbattlelog(warid, type, aid, uid, nil, nil, getbattlelogCallback)
        end
        base.allianceTime = nil
        G_getAlliance()
    elseif retTb.cmd == "userfc.change.push" then --玩家战斗力发生变化
        if(retTb.data and retTb.data.fc)then
            local oldPower = playerVoApi:getPlayerPower()
            playerVoApi:setPlayerPower(retTb.data.fc)
            eventDispatcher:dispatchEvent("user.power.change", {oldPower, retTb.data.fc})
        end
    elseif retTb.cmd == "pay.addprops.push" then --360币购买成功
        if retTb.ret == 0 then
            local cpid = retTb.data.pid
            
            bagVoApi:addBag(tonumber(RemoveFirstChar(cpid)), 1)
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("buyPropPrompt", {getlocal(propCfg[retTb.data.pid].name)}), nil, 20)
        end
    elseif retTb.cmd == "pay.addnewplatprops.push" then --应用宝领取奖励成功
        if retTb.data and retTb.data.props then
            local reward = retTb.data.props
            local rewardStr = getlocal("daily_lotto_tip_10")
            local i = 1
            for k, v in pairs(reward) do
                --local id = Split(k,"p")[2]
                print(k, v)
                bagVoApi:addBag(tonumber(RemoveFirstChar(k)), tonumber(v))
                local nameStr = getlocal(propCfg[k].name)
                if i == SizeOfTable(reward) then
                    rewardStr = rewardStr .. nameStr .. " x" .. v
                else
                    rewardStr = rewardStr .. nameStr .. " x" .. v .. ","
                end
                i = i + 1
            end
            
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), rewardStr, nil, 20)
            
            -- if rewardStr then
            --     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),rewardStr,28)
            -- end
        end
    elseif retTb.cmd == "hero.feat" then
        if(retTb.data)then
            heroVoApi:dealWithServerPush("feat", retTb.data)
        end
    elseif retTb.cmd == "areawarserver.battle.push" then
        if(localWarFightVoApi and localWarFightVoApi.receiveServerPush)then
            localWarFightVoApi:receiveServerPush(retTb.data.areaWarserver)
        end
    elseif retTb.cmd == "alien.resource.push" then --异星科技资源
        if retTb.data then
            alienTechVoApi:setTechData(retTb.data)
            alienTechVoApi:setResFlag(0)
        end
    elseif retTb.cmd == "alient.givegift.push" then --异星科技收到礼物
        if retTb.data then
            alienTechVoApi:receiveGift(retTb.data)
        end
    elseif retTb.cmd == "areawar.job" then --区域战设置官职推送
        if retTb.data then
            if base.localWarSwitch == 1 and localWarVoApi and localWarVoApi.setSelfOffice then
                localWarVoApi:setSelfOffice(retTb.data)
            end
        end
    elseif retTb.cmd == "player.unLockHead.push" then --头像解锁推送
        if retTb.data and retTb.data.unLockHead then
            playerVoApi:setUnLockHead(retTb.data.unLockHead)
        end
    elseif retTb.cmd == "rewardcenter.upnum.push" then --奖励中心推送奖励数
        if retTb.data and retTb.data.total and rewardCenterVoApi then
            rewardCenterVoApi:setNewNum(tonumber(retTb.data.total))
        end
        if retTb.data and retTb.data.rtime and rewardCenterVoApi then
            print("---------------dmj----------checkcodeNum")
            rewardCenterVoApi:setRtime(retTb.data.rtime)
        end
    elseif retTb.cmd == "weapon.change" then
        if retTb.data and retTb.data.fragment and superWeaponVoApi then
            for k, v in pairs(retTb.data.fragment) do
                superWeaponVoApi:setFragmentNum(k, v)
            end
            superWeaponVoApi:setFragmentFlag(0)
        end
    elseif retTb.cmd == "dailyactive.meiridati" then
        if retTb.data and retTb.data.meiridati and retTb.data.meiridati.hr and dailyAnswerVoApi then
            dailyAnswerVoApi:setIsCanReward(retTb.data.meiridati.hr)
        end
        if retTb.data and retTb.data.meiridati and retTb.data.meiridati.flag and dailyAnswerVoApi then
            dailyAnswerVoApi:setIsReceiveReward(retTb.data.meiridati.flag)
        end
    elseif retTb.cmd == "user.ban.push" then
        local function sureCallBackHandler()
            base.banDialog = false
            base:changeServer()
        end
        base.banDialog = true
        if math.abs(retTb.bannedInfo[2] - retTb.bannedInfo[1]) >= 365 * 24 * 60 * 60 then
            local reasonStr
            if(tonumber(retTb.bannedInfo[3]) == 0)then
                if(retTb.bannedInfo[4])then
                    reasonStr = retTb.bannedInfo[4]
                else
                    reasonStr = getlocal("ban_reason1")
                end
            else
                reasonStr = getlocal("ban_reason" .. (retTb.bannedInfo[3] or 1))
            end
            getlocal("ban_reason" .. (retTb.bannedInfo[3] or 1))
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), reasonStr, nil, 8, nil, sureCallBackHandler)
        else
            banSmallDialog:showBanInfo("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), retTb.bannedInfo, nil, 10, {nil, G_ColorRed, G_ColorRed}, sureCallBackHandler)
        end
    elseif retTb.cmd == "userwar.push" then
        if(dimensionalWarFightVoApi and dimensionalWarFightVoApi.receiveServerPush)then
            dimensionalWarFightVoApi:receiveServerPush(retTb.data)
        end
    elseif retTb.cmd == "worldlvl.change" then --世界等级发生变化，同步
        if base.wl == 1 then
            -- print("世界等级发生变化，同步")
            local params = {}
            if retTb.data.lvl then
                playerVoApi:setWorldLv(retTb.data.lvl)
                params.wl = retTb.data.lvl
            end
            if retTb.data.exp then
                playerVoApi:setCurWorldExp(retTb.data.exp)
                params.exp = retTb.data.exp
            end
            chatVoApi:sendUpdateMessage(38, params)
        end
    elseif retTb.cmd == "map.change" then --地图矿点数据发生变化，同步
        -- print("地图矿点数据发生变化")
        if retTb.data and retTb.data.exp and retTb.data.mid and retTb.data.x and retTb.data.y then
            local mineExp = retTb.data.exp
            local mid = retTb.data.mid
            local mineX = retTb.data.x
            local mineY = retTb.data.y
            worldBaseVoApi:updateMineData(mid, mineX, mineY, mineExp)
            worldBaseVoApi:setRefreshMineFlag(true)
            --地图数据发生变化后通知全服玩家更新自己地图数据
            local params = {mid = mid, mineX = mineX, mineY = mineY, mineExp = mineExp}
            chatVoApi:sendUpdateMessage(36, params)
        end
        --击杀叛军推送
        if retTb.data.rebelId then
            local uid = playerVoApi:getUid()
            local rebelInfo = {id = retTb.data.rebelId, rebelLeftLife = 0}
            local params = {uid = uid, rebelInfo = rebelInfo}
            chatVoApi:sendUpdateMessage(40, params, 1)
        end
        if retTb.data.refreshMine then --进攻世界矿点时推送的该矿点的数据（用于刷新金矿和富矿）
            local mineData = retTb.data.refreshMine
            local mine = {}
            if mineData.mid and mineData.lv then
                mine.mid = tonumber(mineData.mid)
                mine.level = mineData.lv
                if mineData.gm then
                    mine.mid = tonumber(mineData.gm[1])
                    mine.disappearTime = mineData.gm[2]
                    mine.goldMineLv = mineData.gm[3]
                end
                if mineData.rm then
                    mine.x = mineData.rm[1]
                    mine.y = mineData.rm[2]
                    mine.richLv = mineData.rm[3]
                end
                worldBaseVoApi:resetWorldMine(mine)
            end
        end
    elseif retTb.cmd == "push.cron.attack" then --攻击叛军推送
        print("push.cron.attack->")
        local uid = playerVoApi:getUid()
        local rebelData = retTb.data.rebelInfo
        if rebelData then
            local reflectId = rebelData.id
            local rebelLeftLife = rebelData.rebelLeftLife
            local place = rebelData.place
            local rebelID = rebelData.rebelID
            local level = rebelData.level
            local rebelInfo = {id = reflectId, rebelLeftLife = rebelLeftLife}
            local params = {uid = uid, rebelInfo = rebelInfo}
            chatVoApi:sendUpdateMessage(40, params, 1)
        end
    elseif retTb.cmd == "msg.sequip" then -- 推送超级装备出征状态
        if retTb.data and retTb.data.sequip then
            if emblemVoApi and emblemVoApi.initData then
                emblemVoApi:initData(retTb.data.sequip)
            end
        end
    elseif retTb.cmd == "msg.plane" then -- 推送飞机出征状态
        if retTb.data and retTb.data.plane then
            if planeVoApi and planeVoApi.initData then
                planeVoApi:initData(retTb.data)
                eventDispatcher:dispatchEvent("plane.expedition.refresh")
            end
        end
    elseif retTb.cmd == "clanwar.invite" then -- 领土争夺战邀请和被邀请
        if retTb.data then
            if ltzdzVoApi then
                ltzdzVoApi:updateInviteOrBeinvite(retTb.data, 100 + retTb.data.action)
            end
        end
    elseif retTb.cmd == "alliancecity.back" then --军团城市驻防返回推送
        if retTb.data then
            if retTb.data.troops ~= nil and retTb.data.troops.attack ~= nil then
                attackTankSoltVoApi:updateAttackSlots(retTb.data)
            end
            allianceCityVoApi:updateData(retTb.data)
        end
    elseif retTb.cmd == "avt.change" then --成就系统有成就完成的推送
        if retTb.data.achievement and achievementVoApi and achievementVoApi:isOpen() == 1 then --成就数据
            achievementVoApi:onAvtFinished(retTb.data)
        end
    elseif retTb.cmd == "msg.aitroops" then --AI部队出征状态同步
        if retTb.data and retTb.data.aitroops and retTb.data.aitroops.stats then
            AITroopsFleetVoApi:syncStats(retTb.data.aitroops.stats)
        end
    elseif retTb.cmd == "monthgive.military.push" then --军令完成任务推送
        if retTb.data and militaryOrdersVoApi then
            militaryOrdersVoApi:initData(retTb.data)
        end
    elseif retTb.cmd == "active.znkh2019.receive" then --周年狂欢赠送数字卡片推送
    elseif retTb.cmd == "msg.airship" then --推送飞艇出征状态
        if retTb.data and retTb.data.airship and retTb.data.airship.stats then
            airShipVoApi:syncStatus(retTb.data.airship.stats)
        end
    end
end

function pushMsgFromServer2(data)
    print("后台socket2推来消息", data)
    local retTb = G_Json.decode(tostring(data))
    if retTb.cmd == "acrossserver.battle.push" then --军团跨服战推送
        if(retTb.data and retTb.data.acrossserver)then
            serverWarTeamFightVoApi:receiveServerPush(retTb.data.acrossserver)
        end
    elseif retTb.cmd == "areateamwarserver.battle.push"then
        if(serverWarLocalFightVoApi and serverWarLocalFightVoApi.receiveServerPush)then
            serverWarLocalFightVoApi:receiveServerPush(retTb.data.areaWarserver)
        end
    elseif retTb.cmd == "clanwar.tqueue.update" or retTb.cmd == "clanwarserver.invite" or retTb.cmd == "clanwar.result" or retTb.cmd == "clanwar.enterbattle" or retTb.cmd == "clanwar.map.update" then -- 领土争夺战
        if ltzdzFightApi and retTb.data then
            -- print("retTb.cmd---->>>>>",retTb.cmd)
            ltzdzFightApi:updateFromeServer2(retTb.data, retTb.cmd)
        end
    elseif retTb.cmd == "clanwar.update" then -- 后台推送让拉数据
        if ltzdzFightApi then
            ltzdzFightApi:EnterForeground()
        end
    elseif retTb.cmd == "clanwar.chat" then -- 领土争夺战 聊天
        if ltzdzChatVoApi and retTb.data and retTb.data.chat then
            ltzdzChatVoApi:updateChat(retTb.data.chat)
        end
    end
    
end

function buyFromStoreSuccess(str)
    
    if G_getPayment() == "" and G_getPaymentUid() == "" then
        G_setPayment(str)
        G_setPaymentUid(playerVoApi:getUid())
    end
    
    local function callback(fn, data)
        local success = base:checkServerData(data)
        if success == true then
        end
    end
    local key = G_savePayment(str)
    socketHelper:userPayment(str, 1, callback, key)
end

--专门为阿拉伯谷歌登陆用
function G_getIsLoginGoole(str)
    print("str===", str)
    local reTb = G_Json.decode(str)
    
    local isGoogleConnected = reTb.isGoogleConnected
    
    if isGoogleConnected == "0" then
        G_isLoginGoole = false
        
    elseif isGoogleConnected == "1" then
        G_isLoginGoole = true
    end
    if G_isNeedLoginGooleF5 then
        G_isNeedLoginGooleF5:refresh()
    end
end

function G_setIsLoginGoole()
    local tmpTb = {}
    tmpTb["action"] = "customAction"
    tmpTb["parms"] = {}
    tmpTb["parms"]["value"] = "checkGoogleLogin"
    local cjson = G_Json.encode(tmpTb)
    G_accessCPlusFunction(cjson)
end

function G_authclanplay()
    local tmpTb = {}
    tmpTb["action"] = "customAction"
    tmpTb["parms"] = {}
    tmpTb["parms"]["value"] = "authclanplay"
    local cjson = G_Json.encode(tmpTb)
    G_accessCPlusFunction(cjson)
end

--appstore补单 存储
function G_savePayment(str)
    local zoneId = tostring(base.curZoneID)
    local gameUid = tostring(playerVoApi:getUid())
    local time = tostring(base.serverTime)
    local key = tostring(gameUid.."_"..zoneId.."_"..time) --生成一个订单号key
    local returnKey = tostring(gameUid.."_"..zoneId.."_"..time)
    CCUserDefault:sharedUserDefault():setStringForKey(key, str)
    CCUserDefault:sharedUserDefault():flush()
    
    local oriderKey = CCUserDefault:sharedUserDefault():getStringForKey("orderkey");
    if oriderKey ~= "" then
        key = oriderKey.."rayjoy"..key
    end
    
    CCUserDefault:sharedUserDefault():setStringForKey("orderkey", key)
    
    local strkey = CCUserDefault:sharedUserDefault():getStringForKey("orderkey");
    print("strkey=", strkey)
    
    return returnKey
    
end

--appstore补单 发送
function G_sendPayment()
    if base.lastSendPayTime == 0 then
        base.lastSendPayTime = base.serverTime
    end
    --CCUserDefault:sharedUserDefault():setStringForKey("orderkey","");
    local keys = CCUserDefault:sharedUserDefault():getStringForKey("orderkey");
    --print("keys=",keys)
    if keys ~= "" and keys ~= "rayjoy" then
        local keysTb = Split(keys, "rayjoy")
        --print("keysTb",keysTb,"SizeOfTable",SizeOfTable(keysTb))
        if keysTb == nil or SizeOfTable(keysTb) == 0 then
            do
                return
            end
        end
        for k, v in pairs(keysTb) do
            local uid = Split(v, "_")[1]
            local zoneid = Split(v, "_")[2]
            if tostring(playerVoApi:getUid()) == uid and zoneid == tostring(base.curZoneID) then
                local orderId = CCUserDefault:sharedUserDefault():getStringForKey(v);
                --发送 orderId
                if base.serverTime - base.lastSendPayTime >= 25 and base.sendPayTimes > 0 then
                    
                    base.lastSendPayTime = base.serverTime;
                    base.sendPayTimes = base.sendPayTimes - 1;
                    local function callback(fn, data)
                        local success = base:checkServerData(data)
                        if success == true then
                        end
                    end
                    
                    socketHelper:userPayment(orderId, 1, callback, v)
                    
                end
                
            end
        end
    end
    
end
function G_removePayment(key)
    CCUserDefault:sharedUserDefault():setStringForKey(key, "")
    CCUserDefault:sharedUserDefault():flush()
    local keys = CCUserDefault:sharedUserDefault():getStringForKey("orderkey");
    local keysTb = Split(keys, "rayjoy")
    for k, v in pairs(keysTb) do
        if key == v then
            table.remove(keysTb, k)
        end
    end
    for k, v in pairs(keysTb) do
        print("y移除掉之后---keysTb", k, v)
    end
    local keysStr = ""
    for k, v in pairs(keysTb) do
        if v ~= nil and v ~= "" then
            keysStr = keysStr.."rayjoy"..v
        end
    end
    CCUserDefault:sharedUserDefault():setStringForKey("orderkey", keysStr)
    CCUserDefault:sharedUserDefault():flush()
    local uuu = CCUserDefault:sharedUserDefault():getStringForKey("orderkey");
    print("总订单------uuukeys=", uuu)
    
end

function SetServerTime(addTime)
    if CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_musicSetting") == 1 then
        SimpleAudioEngine:sharedEngine():stopBackgroundMusic(true)
    end
    --[[
    if base~=nil and base.serverTime~=nil then
        --base.serverTime=base.serverTime+addTime
        base.lastEnterBackGroundTimeSpan=addTime
    end
    if loginScene~=nil and loginScene.loginSuccess==true then
 
        if socketHelper~=nil then
            global.tickIndex=0
            global.needSync=true
        end
    end
    ]]
end
--深度克隆
function G_clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end
function RemoveFirstChar(str)
    return string.sub(str, 2)
end

function PlayEffect(src)
    --[[
    if src==audioCfg.mouseClick then --点击需要防止连续响
         if global.lastPlayMouseClickEffectTime==0 then
                global.lastPlayMouseClickEffectTime=
         end
    end
    ]]
    local effectSetting = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_effectSetting")
    if effectSetting == 2 then
        if(src == nil or type(src) ~= "string")then
            do return end
        end
        --print("src=",src)
        local effectPath = CCFileUtils:sharedFileUtils():fullPathForFilename(src)
        --print("effectPath=",effectPath)
        SimpleAudioEngine:sharedEngine():playEffect(effectPath)
    end
end
function PlayBackGroundEffect(src)
    local effectPath = CCFileUtils:sharedFileUtils():fullPathForFilename(src)
    SimpleAudioEngine:sharedEngine():playBackgroundMusic(effectPath, true)
end

function GetTankOrderByTankId(tid)
    tid = G_pickedList(tid)
    local tankIdTb = {[10006] = 10006, [10016] = 10016, [10026] = 10026, [10036] = 10036, [10093] = 10093, [10044] = 10044, [10045] = 10045, [10103] = 10103, [10104] = 10104, [10054] = 10054, [10113] = 10113, [10123] = 10123, [10064] = 10064, [10074] = 10074, [10075] = 10075, [10007] = 10007, [10017] = 10017, [10027] = 10027, [10037] = 10037, [10008] = 10008, [10018] = 10018, [10028] = 10028, [10038] = 10038, [99999] = 99999, [10083] = 10083, [10084] = 10084, [10094] = 10094, [10095] = 10095, [10163] = 10163, [10164] = 10164, [10165] = 10165, [10114] = 10114, [20114] = 20114, [20115] = 20115, [10124] = 10124, [10133] = 10133, [10134] = 10134, [10135] = 10135, [20044] = 10044, [20054] = 20054, [20064] = 10064, [20065] = 20065, [20074] = 10074, [20083] = 10083, [20084] = 10084, [20094] = 10094, [20095] = 10095, [20124] = 10124, [10144] = 10144, [10145] = 10145, [10143] = 10143, [20153] = 20153, [20154] = 20154, [20155] = 20155, [20125] = 20125, [20163] = 10163, [20164] = 10164, [20165] = 10165, [20055] = 20055, [99998] = 99998, }
    
    if tankIdTb[tid] ~= nil then
        do
            return tankIdTb[tid]
        end
    end
    if tid >= 10001 and tid <= 10005 then
        do
            return tid - 10000
        end
    elseif tid >= 10011 and tid <= 10015 then
        do
            return 5 + tid - 10010
        end
    elseif tid >= 10021 and tid <= 10025 then
        do
            return 10 + tid - 10020
        end
    elseif tid >= 10031 and tid <= 10035 then
        do
            return 15 + tid - 10030
        end
    elseif tid == 10043 then --黑鹰-歼击车
        do
            return 23
        end
    elseif tid == 10053 then --T90-自行火炮
        do
            return 28
        end
    elseif tid == 10063 then --鼠式-坦克
        do
            return 33
        end
    elseif tid == 10073 then --突击虎-自行火炮
        do
            return 38
        end
    elseif tid == 10082 then --火箭车
        do
            return 42
        end
    end
    return - 1
end
function GetTidByTankOrder(type)
    
    local tankIdTb = {[10006] = 10006, [10016] = 10016, [10026] = 10026, [10036] = 10036, [10093] = 10093, [10044] = 10044, [10045] = 10045, [10103] = 10103, [10104] = 10104, [10054] = 10054, [10113] = 10113, [10123] = 10123, [10064] = 10064, [10074] = 10074, [10075] = 10075, [10007] = 10007, [10017] = 10017, [10027] = 10027, [10037] = 10037, [10008] = 10008, [10018] = 10018, [10028] = 10028, [10038] = 10038, [99999] = 99999, [10083] = 10083, [10084] = 10084, [10094] = 10094, [10095] = 10095, [10114] = 10114, [10163] = 10163, [10164] = 10164, [10165] = 10165, [20115] = 20115, [20114] = 20114, [10124] = 10124, [10133] = 10133, [10134] = 10134, [10135] = 10135, [20044] = 10044, [20054] = 20054, [20064] = 10064, [20065] = 20065, [20074] = 10074, [20083] = 10083, [20084] = 10084, [20094] = 10094, [20095] = 10095, [20124] = 10124, [10144] = 10144, [10145] = 10145, [10143] = 10143, [20153] = 20153, [20154] = 20154, [20155] = 20155, [20125] = 20125, [20163] = 10163, [20164] = 10164, [20165] = 10165, [20055] = 20055, [99998] = 99998, }
    if tankIdTb[type] ~= nil then
        do
            return tankIdTb[type]
        end
    end
    if type >= 1 and type <= 5 then
        do
            return type + 10000
        end
    elseif type >= 6 and type <= 10 then
        do
            return type + 10000 + 5
        end
    elseif type >= 11 and type <= 15 then
        do
            return type + 10000 + 10
        end
    elseif type >= 16 and type <= 20 then
        do
            return type + 10000 + 15
        end
    elseif type >= 16 and type <= 20 then
        do
            return type + 10000 + 15
        end
    elseif type == 23 then
        do
            return 10043
        end
    elseif type == 28 then
        do
            return 10053
        end
    elseif type == 33 then
        do
            return 10063
        end
    elseif type == 38 then
        do
            return 10073
        end
    elseif type == 42 then
        do
            return 10082
        end
    end
    
    return - 1
end

--根据坦克id取坦克带炮管的图片   dirFlag：传的话就说明取的是反向显示的图片; isDefault : 默认皮肤
function G_getTankPic(tid, callback, tag, dirFlag, skinId, isDefault)
    -- print("tid------------?",tid)
    -- 需要加上 sId !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if tid and tonumber(tid) then
        tid = tonumber(tid)
        local orderId = GetTankOrderByTankId(tid)
        local sId = ""
        if (isDefault == true or isDefault == nil) and skinId == nil then
            sId = tankSkinVoApi:getEquipSkinByTankId(orderId) --取自己的涂装数据
        else
            sId = skinId
        end
        sId = (sId == nil or sId == "") and "" or sId.."_"
        if sId ~= "" and tonumber(orderId) then
            local path = sId.."t"..orderId.."newTank."
            local str = "ship/newTank/"..path.."plist"
            local str2 = "ship/newTank/"..path.."png"
            spriteController:addPlist(str)
            spriteController:addTexture(str2)
        end
        local strtank = sId.."t"..orderId.."_1.png"
        if dirFlag then
            strtank = sId.."t"..orderId.."_2.png"
        end
        -- print("strtank-------->",strtank)
        local function clickHandler(object, name, tag)
            if callback then
                callback(tag)
            end
        end
        local tankSp = LuaCCSprite:createWithSpriteFrameName(strtank, clickHandler)
        if tag then
            tankSp:setTag(tag)
        end
        if tankCfg[tid].type ~= "8" and tid ~= 10063 then --突击虎比较特殊
            local skinPrefix = skinId and skinId.."_" or ""
            
            local strtank1 = skinPrefix.."t"..orderId.."_1_1.png"
            if dirFlag then
                strtank1 = skinPrefix.."t"..orderId.."_2_1.png"
            end
            -- print("strtank1-------->",strtank1)
            local tankSp1 = CCSprite:createWithSpriteFrameName(strtank1)
            if tankSp1 ~= nil then
                tankSp1:setPosition(getCenterPoint(tankSp))
                tankSp:addChild(tankSp1)
            end
        end
        return tankSp
    end
    return nil
end

--计算航行时间
function MarchTimeConsume(selfCoord, targetCoord, isHelp, isLandTab)
    local x = math.pow(targetCoord[1] - selfCoord[1], 2)
    local y = math.pow(targetCoord[2] - selfCoord[2], 2)
    local baseSec = 120 -- 基础时间
    local baseCellSec = 20 --单元格基础时间
    local techRate = 0.05
    local techLevel = technologyVoApi:getTechVoByTId(22).level
    local marchSpeed = playerCfg.marchSpeed[playerVoApi:getVipLevel() + 1]
    local helpSpeed = 0
    if isHelp and allianceSkillVoApi:getSkillLevel(15) > 0 then
        helpSpeed = (allianceSkillCfg[15].batterValue[allianceSkillVoApi:getSkillLevel(15)] / 100)
    end
    
    --区域战buff
    local buffValue = 0
    if localWarVoApi then
        local buffType = 3
        local buffTab = localWarVoApi:getSelfOffice()
        if G_getHasValue(buffTab, buffType) == true then
            buffValue = G_getLocalWarBuffValue(buffType)
        end
    end
    --三周年七重福利所加buff
    local threeYearAdd = 0
    if acThreeYearVoApi then
        threeYearAdd = acThreeYearVoApi:getBuffAdded(5)
    end
    local btzxAdd = 0
    if acBtzxVoApi and acBtzxVoApi:isActiveTime("btzx") then
        btzxAdd = acBtzxVoApi:matchAdd("btzx")
    end
    
    local territoryBuff = 0 --军团城市领地加成
    if base.allianceCitySwitch == 1 and allianceCityVoApi:hasCity() == true then --如果有军团城市的话，领地会加成行军速度
        local selfAlliance = allianceVoApi:getSelfAlliance()
        if isLandTab and selfAlliance and ((isLandTab.type == 8 and isLandTab.oid == selfAlliance.aid) or (isLandTab.aid == selfAlliance.aid)) then --如果目标地点是军团城市或者我方领地，则加成行军速度
            local buffCfg = allianceCityVoApi:getTerritoryBuff()
            territoryBuff = buffCfg[1] or 0
        end
    end
    local warStatueBuff = 0 --战争塑像的加成
    local battleBuff, skillBuff = warStatueVoApi:getTotalWarStatueAddedBuff("moveSpeed")
    warStatueBuff = skillBuff.moveSpeed or 0
    
    -- 主基地皮肤增加的行军速度
    local skinAddSpeed = 0
    if buildDecorateVoApi and buildDecorateVoApi.addTroopSpeed and base.isSkin == 1 then
        skinAddSpeed = buildDecorateVoApi:addTroopSpeed()
    end
    
    local sec = (math.sqrt(x + y) * baseCellSec + baseSec) / (1 + techLevel * techRate + marchSpeed + helpSpeed + buffValue + threeYearAdd + btzxAdd + territoryBuff + warStatueBuff + skinAddSpeed)
    if useItemSlotVoApi:getSlotById(13) ~= nil then
        sec = sec / 2
    end
    if useItemSlotVoApi:getSlotById(423) ~= nil then
        sec = sec * 0.4
    end
    
    return math.floor(sec)
end

-- 判断文字的字符数
function G_utfstrlen(str, isAddNum)
    local len = #str;
    local left = len;
    local cnt = 0;
    local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc};
    while left ~= 0 do
        local tmp = string.byte(str, -left);
        local i = #arr;
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i;
                break;
            end
            i = i - 1;
        end
        if isAddNum then
            if tmp >= 192 and G_curPlatName() ~= "21" and G_curPlatName() ~= "androidarab" then
                cnt = cnt + 2;
            else
                cnt = cnt + 1;
            end
        else
            cnt = cnt + 1;
        end
    end
    return cnt;
end

--格式化奖励
function FormatItem(data, includeZore, sortByIndex)
    if includeZore == nil then
        includeZore = true
    end
    local formatData = {}
    local num = 0
    local name = ""
    local pic = ""
    local iconImage --没有背景框的图标(默认为nil)
    local desc = ""
    local id = 0
    local index = 0
    local eType = ""
    local noUseIdx = 0 --无用的index 只是占位
    local bgname = ""
    local equipId
    if data then
        for k, v in pairs(data) do
            if v then
                for m, n in pairs(v) do
                    if m ~= nil and n ~= nil then
                        local key, type1, num = m, k, n
                        local extend
                        if type(n) == "table" then
                            for i, j in pairs(n) do
                                if i == "index" then
                                    index = j
                                elseif i == "extend" then --用于需求扩展使用的字段
                                    extend = j
                                else
                                    key = i
                                    num = j
                                end
                            end
                        end
                        if sortByIndex then
                            name, pic, desc, id, noUseIdx, eType, equipId, bgname, iconImage = getItem(key, type1, num)
                        else
                            name, pic, desc, id, index, eType, equipId, bgname, iconImage = getItem(key, type1, num)
                        end
                        if name and name ~= "" then
                            if includeZore == false then
                                if num > 0 then
                                    --index=index+1
                                    table.insert(formatData, {name = name, num = num, pic = pic, iconImage = iconImage, desc = desc, id = id, type = k, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname, extend = extend})
                                end
                            else
                                --index=index+1
                                table.insert(formatData, {name = name, num = num, pic = pic, iconImage = iconImage, desc = desc, id = id, type = k, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname, extend = extend})
                            end
                        end
                    end
                end
            end
        end
    end
    if formatData and SizeOfTable(formatData) > 0 then
        local function sortAsc(a, b)
            if sortByIndex then
                if a.index and b.index and tonumber(a.index) and tonumber(b.index) then
                    return a.index < b.index
                end
            else
                if a.type == b.type then
                    if a.index and b.index and tonumber(a.index) and tonumber(b.index) then
                        return a.index < b.index
                    end
                    --else
                    --return a.type<b.type
                end
            end
        end
        table.sort(formatData, sortAsc)
    end
    return formatData
end
function getItem(key, type, num)
    local name = ""
    local pic = ""
    local iconImage --没有背景框的图标(默认为nil)
    local desc = ""
    local id = 0
    local index = 0
    local eType = ""
    local equipId
    local bgname = ""--icon背景图名称
    if type == "u" then --资源,人物属性
        --[[
        award_1="铁矿",
        award_2="石油",
        award_3="硅矿",
        award_4="铀矿",
        award_5="金币",
        award_6="经验",
        award_7="宝石",
        award_10="声望",
        ]]
        if key == "r1" then
            name = getlocal("award_1")
            pic = "resourse_normal_metal.png"
            desc = "resourse_r1_desc"
            index = 1
        elseif key == "r2" then
            name = getlocal("award_2")
            pic = "resourse_normal_oil.png"
            desc = "resourse_r2_desc"
            index = 2
        elseif key == "r3" then
            name = getlocal("award_3")
            pic = "resourse_normal_silicon.png"
            desc = "resourse_r3_desc"
            index = 3
        elseif key == "r4" then
            name = getlocal("award_4")
            pic = "resourse_normal_uranium.png"
            desc = "resourse_r4_desc"
            index = 4
        elseif key == "gold" then
            name = getlocal("award_5")
            pic = "resourse_normal_gold.png"
            desc = "resourse_gold_desc"
            index = 5
        elseif key == "gem" or key == "gems" then
            name = getlocal("award_7")
            pic = "resourse_normal_gem.png"
            iconImage = "GoldImage.png"
            index = 6
            desc = "gems_desc"
        elseif key == "exp" then
            name = getlocal("award_6")
            pic = "player_exp.png"
            index = 7
            desc = "exp_desc"
        elseif key == "honors" then
            name = getlocal("award_10")
            pic = "Icon_prestige.png"
            index = 8
            desc = "honors_desc"
        elseif key == "energy" then
            name = getlocal("energy")
            pic = "energyIcon.png"
            index = 9
            desc = "energy_desc"
        end
    elseif type == "p" then --物品
        id = tonumber(key) or tonumber(RemoveFirstChar(key))
        if id then
            local pid = "p"..id
            local prop = propCfg[pid]
            if prop then
                name = getlocal(prop.name)
                pic = prop.icon
                iconImage = prop.iconImage
                desc = prop.description
                if prop.iconbg then
                    bgname = prop.iconbg
                end
                if prop.Mid then --装甲矩阵道具
                    local cfg = armorMatrixVoApi:getCfgByMid(prop.Mid)
                    pic = "armorMatrix_"..cfg.part..".png"
                elseif prop.useGetHead then --头像道具
                    local hCfg = headCfg.list[tostring(prop.useGetHead[1])]
                    if hCfg then
                        if hCfg.pic then
                            pic = hCfg.pic
                        end
                        if hCfg.name then
                            name = getlocal(hCfg.name)
                        end
                    end
                elseif prop.useGetHeadFrame then --头像框道具
                    local hfCfg = headFrameCfg.list["h"..prop.useGetHeadFrame[1]]
                    if hfCfg then
                        if hfCfg.pic then
                            pic = hfCfg.pic
                        end
                        if hfCfg.name then
                            name = getlocal(hfCfg.name)
                        end
                    end
                elseif prop.Aid then
                    equipId = prop.Aid
                    eType = string.sub(equipId, 1, 1)
                    if eType == "a" then
                        pic, bgname = accessoryVoApi:getAccessoryIconImage(equipId)
                    elseif eType == "f" then
                        pic, bgname = accessoryVoApi:getFragmentIconImage(equipId)
                    elseif eType == "p" then
                        pic = accessoryCfg.propCfg[equipId].icon
                    end
                end
            end
        end
    elseif type == "o" or type == "troops" then --坦克
        id = tonumber(key) or tonumber(RemoveFirstChar(key))
        if id then
            local tank = tankCfg[id]
            if tank then
                name = getlocal(tank.name)
                pic = tank.icon
                desc = tank.description
            end
        end
    elseif type == "a" then --公会
        if key == "aexp" then
            name = getlocal("alliance_scene_exp")
            -- pic="item_xunzhang_02.png"
            desc = "alliance_scene_expDesc"
            pic = "alliance_icon.png"
            index = 10
        elseif key == "point" then
            name = getlocal("alliance_funds")
            pic = "icon_alliance_gem.png"
            index = 11
        end
    elseif type == "e" then --配件和配件碎片
        eType = string.sub(key, 1, 1)
        local item
        if eType == "a" then
            item = accessoryCfg.aCfg[key]
        elseif eType == "f" then
            item = accessoryCfg.fragmentCfg[key]
        elseif eType == "p" then
            item = accessoryCfg.propCfg[key]
            pic = item.icon
        end
        id = key
        name = getlocal(item.name)
        desc = item.desc
    elseif type == "as" then --飞艇零件
        eType = string.sub(key, 1, 1)
        local item
        if eType == "z" then
            item = airShipVoApi:getAirShipCfg().Prop[key]
        end
        id = key
        name, desc, pic, bgname = airShipVoApi:getAirShipPropShowInfo(key)
    elseif type == "c" then --关卡科技
        id = tonumber(key) or tonumber(RemoveFirstChar(key))
        local item
        if challengeTechCfg then
            item = challengeTechCfg[key]
        end
        if item then
            pic = item.icon
            name = item.name
            desc = item.description
        end
    elseif type == "h" then --英雄和英雄碎片
        id = tonumber(key) or tonumber(RemoveFirstChar(key))
        eType = string.sub(key, 1, 1)
        local item
        if eType == "h" then
            item = heroListCfg[key]
            name = getlocal(item.heroName)
        elseif eType == "s" then
            item = heroListCfg["h"..id]
            name = getlocal("heroSoul", {getlocal(item.heroName)})
        elseif eType == "j" then --将领副官
            name = getlocal(heroAdjutantVoApi:getAdjutantName(key))
        end
        if item then
            pic = item.heroIcon
            desc = item.heroDes
        end
    elseif type == "r" then --异星科技资源
        if alienTechCfg then
            local item = alienTechCfg.resource[key]
            pic = item.icon
            name = getlocal(item.name)
            desc = item.desc
        end
    elseif type == "t" then
        --糖果
        for i = 1, 4 do
            if key == "t"..i then
                name = getlocal("activity_sweettrouble_seed_"..i)
                pic = "sweet_"..i..".png"
                desc = "activity_sweettrouble_seed_desc_"..i
                id = i
                equipId = key
                if key == "t1" then
                    bgname = "equipBg_green.png"
                elseif key == "t2" then
                    bgname = "equipBg_blue.png"
                elseif key == "t3" then
                    bgname = "equipBg_purple.png"
                elseif key == "t4" then
                    bgname = "equipBg_orange.png"
                end
            end
        end
        
    elseif type == "w" then --超级武器
        if superWeaponCfg then
            eType = string.sub(key, 1, 1)
            local item
            if eType == "w" then
                item = superWeaponCfg.weaponCfg[key]
                name = getlocal(item.name)
                desc = item.desc
            elseif eType == "f" then
                item = superWeaponCfg.fragmentCfg[key]
                name, desc = superWeaponVoApi:getFragmentNameAndDesc(key)
            elseif eType == "p" then
                item = superWeaponCfg.propCfg[key]
                name = getlocal(item.name)
                desc = item.desc
            elseif eType == "c" then--能量结晶
                if key == "c200" then
                    item = superWeaponCfg.addcrystalRate[key]
                    name = getlocal(item.name)
                    local rate = tostring(superWeaponCfg.addcrystalRate.c200.att * 100) .. "%%"
                    desc = getlocal(item.desc, {rate})
                elseif key == "c201" then
                    item = superWeaponCfg.stillLevel[key]
                    name = getlocal(item.name)
                    desc = getlocal(item.desc)
                else
                    item = superWeaponCfg.crystalCfg[key]
                    name = getlocal(item.name)..getlocal("fightLevel", {item.lvl})
                    if item.type == 1 then
                        bgname = "crystalIconRedBg.png"
                    elseif item.type == 2 then
                        bgname = "crystalIconYellowBg.png"
                    else
                        bgname = "crystalIconBlueBg.png"
                    end
                    local att = item.att
                    local i = 1
                    local msg = ""
                    for k, v in pairs(att) do
                        msg = getlocal(buffEffectCfg[k].name)
                        if tonumber(k) > 200 then
                            msg = msg..":+"..v
                        else
                            msg = msg..":+" .. (tonumber(v) * 100) .. "%"
                        end
                        msg = msg.."\n"
                        i = i + 1
                    end
                    desc = msg
                end
            end
            id = tonumber(key) or tonumber(RemoveFirstChar(key))
            pic = item.icon
        end
    elseif type == "f" then --装备升级需要的经验
        
        if key == "e1" or key == "e2" or key == "e3" then
            pic = "icon_exp_"..key..".png"
            name = getlocal("sample_prop_name_"..key)
            desc = "sample_prop_des_"..key
        end
    elseif type == "m" then -- 军事演习  竞技勋章
        name = getlocal("shamBattle_medal")
        pic = "icon_medal_sports.png"
        if G_isMemoryServer() == true then
            desc = "shamBattle_medal_msdes"
        else
            desc = "shamBattle_medal_des"
        end
        bgname = "equipBg_blue.png"
    elseif type == "n" then -- 远征 远征积分
        name = getlocal("expedition_medal")
        pic = "expeditionPoint.png"
        desc = "expeditionShopInfo"
        bgname = "equipBg_blue.png"
    elseif type == "gq" then -- 国庆狂欢活动特殊需要（点券）
        name = getlocal("activity_gqkh_couponsName")
        pic = "acGqkh_ vouchers.png"
        desc = "activity_gqkh_couponsDes"
        bgname = "equipBg_blue.png"
    elseif type == "se" then
        -- pic="superEquip_icon_"..key..".png"
        pic = "emblemUnknown.png"
        name = getlocal("emblem_name_"..key)
        desc = "emblem_des_"..key
    elseif type == "am" then -- 装甲
        if key == "exp" then
            name = getlocal("armorMatrix_name_exp")
            pic = "armorMatrixExp.png"
            desc = "armorMatrix_desc_exp"
            bgname = "equipBg_blue.png"
            if num then
                if num < 1000 then
                    bgname = "equipBg_green.png"
                elseif num <= 2000 then
                    bgname = "equipBg_blue.png"
                elseif num <= 5000 then
                    bgname = "equipBg_purple.png"
                else
                    bgname = "equipBg_orange.png"
                end
            end
        else
            eType = string.sub(key, 1, 1)
            local cfg = armorMatrixVoApi:getCfgByMid(key)
            pic = "armorMatrix_"..cfg.part..".png"
            name = getlocal(cfg.name)
            desc = armorMatrixVoApi:getDescByMid(key)
        end
    elseif type == "pl" then --空中打击系统
        local eType = string.sub(key, 1, 1)
        if eType == "s" then
            name, desc = planeVoApi:getSkillInfoById(key)
        end
    elseif type == "acity" then --军团城市相关资源
        if key == "R" then --城市稀土
            name = getlocal("allianceCr")
            pic = allianceCityVoApi:getCrPic()
            desc = "alliancecity_cr_desc"
            bgname = "Icon_BG.png"
            -- index=1
        elseif key == "H" then --个人荣耀
            name = getlocal("gloryres")
            pic = "honor.png"
            desc = "alliancecity_glory_desc"
            bgname = "Icon_BG.png"
            -- index=2
        end
    elseif type == "l" then --头像、头像框、聊天框
        eType = string.sub(key, 1, 1)
        local eValue = string.sub(key, 2)
        local item
        if eType == "a" then
            item = headCfg.list[tostring(eValue)]
            pic = item.pic
            bgname = "equipBg_purple.png"
        elseif eType == "h" then
            item = headFrameCfg.list[key]
            pic = item.pic
        elseif eType == "c" then
            item = chatFrameCfg.list[key]
            pic = item.pic[1]
            -- bgname="fi_bubble_bg.png"
        end
        id = key
        name = getlocal(item.name or "")
        desc = item.desc or ""
    elseif type == "ac" then --情人节活动礼盒
        if key ~= "m4" and key ~= "m5" then
            name, pic, desc, id, index, eType, equipId, bgname = G_acGetItem(key)
        end
    elseif type == "reportAcReward" then --战报里面的活动所得到的道具(战报特殊处理)
        if string.sub(key, 1, 1) == "s" and key ~= "stormFortressMissile" then --秘宝探寻活动战报奖励处理
            -- local pCfg=acMiBaoVoApi:getPieceCfgForShowBySid(k1)
            local pCfg
            for k, v in pairs(activityCfg.miBao) do
                if k == key then
                    pCfg = v
                    do break end
                end
            end
            if pCfg then
                name, pic, desc = getlocal(pCfg.name), pCfg.icon, pCfg.des
            end
        elseif key == "stormFortressMissile" then --攻陷要塞活动战报奖励处理
            name, pic, desc, bgname = getlocal("millieName"), "dartIcon.png", "millieDesc", "Icon_BG.png"
        elseif key == "jidongbudui_mm_m1" then --机动部队活动战报奖励处理
            name, pic, desc, bgname = getlocal("activity_jidongbudui_turkey"), "Turkey.png", "activity_jidongbudui_turkeyDesc", "Icon_BG.png"
        end
    elseif type == "tAllPoint" then -- type All Point 所有积分缩写（tAllPoint）
        if key == "pww" then -- point world war 世界争霸缩写（pww）
            name = getlocal("world_war_name_point")
        end
    elseif type == "at" then --AI部队相关
        eType = string.sub(key, 1, 1)
        if eType == "a" then --AI部队
            name = AITroopsVoApi:getAITroopsNameStr(key)
        elseif eType == "f" then --AI部队碎片
            local aid = "a"..string.sub(key, 2)
            name = AITroopsVoApi:getAITroopsNameStr(aid)..getlocal("fragment")
        elseif eType == "p" then --AI部队相关道具（目前只有经验道具）
            local aiTroopsCfg = AITroopsVoApi:getModelCfg()
            name, desc = "", ""
            if aiTroopsCfg.propCfg[key] then
                name, desc = getlocal(aiTroopsCfg.propCfg[key].name), aiTroopsCfg.propCfg[key].desc
                pic, bgname = aiTroopsCfg.propCfg[key].icon, aiTroopsCfg.propCfg[key].iconbg
            end
        end
    elseif type == "sk" then --坦克涂装相关
        local eType = string.sub(key, 1, 1)
        if eType == "s" then --涂装
            name = tankSkinVoApi:getSkinNameStrForPropShow(key)
            desc = "tankskin_" .. key .. "_desc"
        end
    elseif type == "aj" then --将领副官相关
        name = heroAdjutantVoApi:getAdjutantName(key)
        eType = string.sub(key, 1, 1)
    elseif type == "al" then --军团旗帜相关
        local eType = string.sub(key, 1, 2)
        if eType == "if" then --军团旗帜底框
            name = getlocal("allianceFlagTitle")
            desc = ""
            pic = allianceVoApi:getFlagShowInfo(2, key)
        elseif eType == "ic" then --军团旗帜颜色
        else
            eType = string.sub(key, 1, 1)
            if eType == "i" then --军团旗帜图标
                name = getlocal("allianceFlag_itemNameText")
                desc = "allianceFlag_itemDescText"
                pic = allianceVoApi:getFlagShowInfo(1, key)
            end
        end
    elseif type == "b" then --基地外观
        local eType = string.sub(key, 1, 1)
        if eType == "b" then
            name = buildDecorateVoApi:getBaseSkinNameStr(key)
            pic = buildDecorateVoApi:getBaseSkinPic(key)
            desc = "decorate_desc_"..key
            bgname = "equipBg_orange.png"
        end
    elseif type == "rg" then --叛军营地(个人叛军)道具
        name, desc, pic = rebelVoApi:pr_getPropInfo(key)
    end
    return name, pic, desc, id, index, eType, equipId, bgname, iconImage
end

-- item 格式整理之后的奖励对象  size 图片的大小，如100  isShowInfo 是否显示详细信息面板（true or false）layerNum 图标要放置的面板的layerNum, callback回调
-- 军徽道具一样展示（有底框）
function G_getItemIcon(item, size, isShowInfo, layerNum, callback, container, addDesc, isHuoxianmingjianggai, hideNum, ChunjiepanshengVersion, isAddEmblemBg, isNewUI)
    if item then
        local iconSize = 100
        if size then
            iconSize = size
        end
        local id
        if item.key then
            id = (tonumber(item.key) or tonumber(RemoveFirstChar(item.key)))
        end
        local function showInfoHandler(hd, fn, idx)
            if container and container:getIsScrolled() == true then
                do return end
            end
            
            if G_checkClickEnable() == false then
                do
                    return
                end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            local isShow = true
            if callback then
                isShow = callback(hd, fn, idx)
                if isShow == nil then
                    isShow = true
                end
            end
            if isShowInfo and layerNum and isShow == true then
                PlayEffect(audioCfg.mouseClick)
                if item.type == "as" then
                    propInfoDialog:create(sceneGame, item, layerNum + 1, nil, nil, addDesc, nil, nil, nil, hideNum)
                elseif item.type == "e" then
                    if item.eType == "a" or item.eType == "f" then
                        local isAccOrFrag = true
                        propInfoDialog:create(sceneGame, item, layerNum + 1, nil, nil, addDesc, nil, nil, isAccOrFrag, hideNum)
                    else
                        propInfoDialog:create(sceneGame, item, layerNum + 1, nil, nil, addDesc, nil, nil, nil, hideNum)
                    end
                elseif item.type and item.type == "se" and isAddEmblemBg then
                    local cfg = emblemVoApi:getEquipCfgById(item.key)
                    local eVo = emblemVo:new(cfg)
                    if(eVo)then
                        eVo:initWithData(item.key, 0, 0)
                        emblemVoApi:showInfoDialog(eVo, layerNum + 1, true)
                    end
                elseif item.type and item.type == "am" then
                    if item.key == "exp" then
                        propInfoDialog:create(sceneGame, item, layerNum + 1, nil, nil, addDesc, nil, nil, nil, hideNum)
                    else
                        armorMatrixVoApi:showInfoSmallDialog(nil, layerNum + 1, false, item.key, 1, isNewUI)
                    end
                elseif item.type == "p" and propCfg[item.key] and propCfg[item.key].useGetArmor and propCfg[item.key].Mid then
                    armorMatrixVoApi:showInfoSmallDialog(nil, layerNum + 1, false, propCfg[item.key].Mid, 1, true)
                elseif item.type == "at" then
                    local eType = string.sub(item.key, 1, 1)
                    if eType == "a" then --AI部队
                        local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(item.key, true)
                        AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, layerNum + 1)
                    else
                        G_showNewPropInfo(layerNum + 1, true, true, nil, item, nil, nil, nil, nil, true)
                    end
                elseif item.type == "h" then
                    if item.eType == "j" then --将领副官
                        heroAdjutantVoApi:showInfoSmallDialog(layerNum + 1, {item.key})
                    end
                elseif item.type == "aj" then --将领副官相关
                    heroAdjutantVoApi:showInfoSmallDialog(layerNum + 1, {item.key})
                elseif item.name then
                    if item.key == "energy" then
                        propInfoDialog:create(sceneGame, item, layerNum + 1, nil, true, nil, addDesc)
                    else
                        if ChunjiepanshengVersion and ChunjiepanshengVersion == 3 then
                            propInfoDialog:create(sceneGame, item, layerNum + 1, nil, nil, addDesc, nil, nil, nil, hideNum, nil, nil, nil, 3)
                        elseif isHuoxianmingjianggai == true then
                            propInfoDialog:create(sceneGame, item, layerNum + 1, nil, nil, addDesc, nil, nil, nil, nil, nil, true)
                        elseif (item.type == "p" and id >= 2001 and id <= 2128) or item.key == "p903" or item.key == "p904" then
                            propInfoDialog:create(sceneGame, item, layerNum + 1, nil, true, addDesc, nil, nil, nil, hideNum)
                        else
                            propInfoDialog:create(sceneGame, item, layerNum + 1, nil, nil, addDesc, nil, nil, nil, hideNum)
                        end
                    end
                elseif item.type == "pl" then
                    local eType = string.sub(item.key, 1, 1)
                    if eType == "s" then
                        planeVoApi:showInfoSmallDialog(item.key, layerNum + 1, false)
                    end
                end
            end
        end
        local icon
        if item.type == "t" then
            local bgname = "equipBg_green.png" --糖果
            for i = 1, 4 do
                if item.key == "t1" then
                    local pic = "sweet_1.png"
                    bgname = "equipBg_green.png"
                elseif item.key == "t2" then
                    local pic = "sweet_2.png"
                    bgname = "equipBg_blue.png"
                elseif item.key == "t3" then
                    local pic = "sweet_3.png"
                    bgname = "equipBg_purple.png"
                elseif item.key == "t4" then
                    local pic = "sweet_4.png"
                    bgname = "equipBg_orange.png"
                end
                icon = GetBgIcon(item.pic, showInfoHandler, bgname)
            end
        elseif item.type == "w" and item.eType and item.eType == "f" then
            icon = superWeaponVoApi:getFragmentIcon(item.key, showInfoHandler)
        elseif item.type == "w" and item.eType and item.eType == "c" then
            icon = superWeaponVoApi:getCrystalIcon(item.key, showInfoHandler)
        elseif item.type == "p" and propCfg[item.key] and propCfg[item.key].useGetHero then
            local heroData = {h = G_clone(propCfg[item.key].useGetHero)}
            local hItmeTb = FormatItem(heroData)
            local hItme = hItmeTb[1]
            if hItme and hItme.type == "h" then
                if hItme.eType == "h" then
                    local productOrder = hItme.num
                    icon = heroVoApi:getHeroIcon(hItme.key, productOrder, true, showInfoHandler, nil, nil, nil, {adjutants = {}})
                else
                    icon = heroVoApi:getHeroIcon(hItme.key, 1, false, showInfoHandler)
                end
            end
        elseif item.type == "p" and propCfg[item.key] and propCfg[item.key].speedType and propCfg[item.key].useTimeDecrease then
            if item.bgname and item.bgname ~= "" then
                icon = GetBgIcon(item.pic, showInfoHandler, item.bgname, nil, iconSize)
                local speedType = propCfg[item.key].speedType
                local useTimeDecrease = propCfg[item.key].useTimeDecrease
                local colorType
                if item.bgname == "equipBg_gray.png" then
                    colorType = 1
                elseif item.bgname == "equipBg_green.png" then
                    colorType = 2
                elseif item.bgname == "equipBg_blue.png" then
                    colorType = 3
                elseif item.bgname == "equipBg_purple.png" then
                    colorType = 4
                end
                local leftTimeStr = GetTimeStr(tonumber(useTimeDecrease), true)
                if icon and colorType then
                    local colorSp = CCSprite:createWithSpriteFrameName("speedUp_color"..colorType..".png")
                    colorSp:setAnchorPoint(ccp(0, 0))
                    colorSp:setPosition(ccp(5, 5))
                    icon:addChild(colorSp)
                    local speedTypeSp = CCSprite:createWithSpriteFrameName("speedUp_type_"..speedType..".png")
                    speedTypeSp:setAnchorPoint(ccp(0, 0))
                    speedTypeSp:setPosition(ccp(3, 3))
                    icon:addChild(speedTypeSp)
                    local addSp = CCSprite:createWithSpriteFrameName("speedUp_add.png")
                    addSp:setAnchorPoint(ccp(1, 1))
                    addSp:setPosition(ccp(icon:getContentSize().width - 10, icon:getContentSize().height - 10))
                    icon:addChild(addSp)
                    local timeLb = GetBMLabel(leftTimeStr, G_TimeFontSrc, 10)
                    timeLb:setAnchorPoint(ccp(0.5, 1))
                    timeLb:setPosition(ccp(icon:getContentSize().width - 25, icon:getContentSize().height - 30))
                    icon:addChild(timeLb)
                    timeLb:setScale(0.4)
                end
            else
                icon = LuaCCSprite:createWithSpriteFrameName(item.pic, showInfoHandler)
            end
        elseif item.type == "h" then
            if item.eType == "h" then
                item.productOrder = item.productOrder or item.num
                icon = heroVoApi:getHeroIcon(item.key, item.productOrder, true, showInfoHandler, nil, nil, nil, {adjutants = {}})
                item.num = 1
            elseif item.eType == "j" then --将领副官
                icon = heroAdjutantVoApi:getAdjutantIcon(item.key, nil, nil, showInfoHandler)
            else
                icon = heroVoApi:getHeroIcon(item.key, 1, false, showInfoHandler)
            end
        elseif (item.type == "p" and id >= 2001 and id <= 2128) or item.key == "p903" or item.key == "p904" or item.key == "p3348" then
            icon = GetBgIcon(item.pic, showInfoHandler, nil, 80, 100)
        elseif item.type and item.type == "e" then
            if item.eType then
                if item.eType == "a" then
                    icon = accessoryVoApi:getAccessoryIcon(item.key, iconSize / 100 * 80, iconSize, showInfoHandler)
                elseif item.eType == "f" then
                    icon = accessoryVoApi:getFragmentIcon(item.key, iconSize / 100 * 80, iconSize, showInfoHandler)
                elseif item.pic and item.pic ~= "" then
                    icon = LuaCCSprite:createWithSpriteFrameName(item.pic, showInfoHandler)
                end
            end
        elseif item.type and item.type == "as" then
            if item.eType then
                if item.eType == "z" then
                    icon = airShipVoApi:getAirShipPropIcon(item.key, iconSize, showInfoHandler)
                end
            else
                print("~~~~~~  e r r o r in G_getItemIcon with airShipAccessory is nil ~~~~~~")
            end
        elseif item.equipId then
            local eType = string.sub(item.equipId, 1, 1)
            if eType == "a" then
                icon = accessoryVoApi:getAccessoryIcon(item.equipId, iconSize / 100 * 80, iconSize, showInfoHandler)
            elseif eType == "f" then
                icon = accessoryVoApi:getFragmentIcon(item.equipId, iconSize / 100 * 80, iconSize, showInfoHandler)
            elseif eType == "p" then
                icon = LuaCCSprite:createWithSpriteFrameName(accessoryCfg.propCfg[award.equipId].icon, showInfoHandler)
            end
        elseif item.type == "p" and propCfg[item.key] and propCfg[item.key].useGetArmor then
            -- local reward=G_rewardFromPropCfg(item.key)
            local reward = G_rewardFromPropCfg(item.key)
            if(reward[1].key == "exp")then
                -- icon=G_getItemIcon(reward[1],size,isShowInfo,layerNum,callback,container,addDesc,isHuoxianmingjianggai,hideNum,ChunjiepanshengVersion,isAddEmblemBg)
                item.bgname = reward[1].bgname
                icon = GetBgIcon(item.pic, showInfoHandler, item.bgname, iconSize / 100 * 90, iconSize)
            else
                icon = armorMatrixVoApi:getArmorMatrixIcon(propCfg[item.key].Mid, 90, 100, showInfoHandler)
            end
        elseif item.type == "p" and propCfg[item.key] and propCfg[item.key].tskinDiscount then --坦克涂装折扣券需要特殊显示
            icon = tankSkinVoApi:getSkinDiscountTicketIconSp(item.key, showInfoHandler)
        elseif item.type and item.type == "p" and item.bgname and item.bgname ~= "" then
            local itemPic
            if ChunjiepanshengVersion and ChunjiepanshengVersion == 3 and item.key == "p973" then
                itemPic = "acChunjiepansheng_tanskPoint3.png"
            else
                itemPic = item.pic
            end
            if propCfg[item.key] and propCfg[item.key].isEmblem then
                local emblemKey = propCfg[item.key].isEmblem
                local subIcon = emblemVoApi:getEquipIconNoBg(emblemKey)
                local bgname = item.bgname
                icon = LuaCCSprite:createWithSpriteFrameName(bgname, showInfoHandler)
                icon:addChild(subIcon)
                subIcon:setPosition(getCenterPoint(icon))
                subIcon:setScale(80 / subIcon:getContentSize().width)
                subIcon:setTag(99)
            else
                icon = GetBgIcon(itemPic, showInfoHandler, item.bgname, iconSize / 100 * 90, iconSize)
            end
            local pid = "p"..item.id
            local prop = propCfg[pid]
            if prop and prop.addNum and prop.addNum > 0 then
                local addNumPic = "addnum_"..prop.addNum..".png"
                local addNumBgPic = ""
                if item.bgname == "equipBg_green.png" then
                    addNumBgPic = "addnum_green.png"
                elseif item.bgname == "equipBg_blue.png" then
                    addNumBgPic = "addnum_blue.png"
                elseif item.bgname == "equipBg_purple.png" then
                    addNumBgPic = "addnum_purple.png"
                elseif item.bgname == "equipBg_orange.png" then
                    addNumBgPic = "addnum_orange.png"
                end
                -- print("----dmj----addNumPic:"..addNumPic.."---addNumBgPic:"..addNumBgPic.."---prop.addNum:"..prop.addNum)
                local addNumBgSp = CCSprite:createWithSpriteFrameName(addNumBgPic)
                addNumBgSp:setPosition(ccp(addNumBgSp:getContentSize().width / 2 + 5, iconSize - addNumBgSp:getContentSize().height / 2 - 8))
                icon:addChild(addNumBgSp)
                local addNumSp = CCSprite:createWithSpriteFrameName(addNumPic)
                addNumSp:setPosition(getCenterPoint(addNumBgSp))
                addNumBgSp:addChild(addNumSp)
            end
        elseif item.type and item.type == "f" then
            if equipCfg and equipCfg.quality then
                local bgname = "equipBg_green.png"
                if equipCfg.quality[1] and item.num and item.num < equipCfg.quality[1] then
                    bgname = "equipBg_green.png"
                elseif equipCfg.quality[2] and item.num and item.num < equipCfg.quality[2] then
                    bgname = "equipBg_blue.png"
                elseif equipCfg.quality[3] and item.num and item.num < equipCfg.quality[3] then
                    bgname = "equipBg_purple.png"
                elseif equipCfg.quality[3] and item.num and item.num >= equipCfg.quality[3] then
                    bgname = "equipBg_orange.png"
                end
                icon = GetBgIcon(item.pic, showInfoHandler, bgname, iconSize / 100 * 90, iconSize)
            else
                icon = LuaCCSprite:createWithSpriteFrameName(item.pic, showInfoHandler)
            end
        elseif item.type and (item.type == "m" or item.type == "n") or item.bgname and item.bgname ~= "" then
            icon = GetBgIcon(item.pic, showInfoHandler, item.bgname, iconSize / 100 * 90, iconSize)
        elseif item.type and item.type == "se" and isAddEmblemBg then
            local subIcon = emblemVoApi:getEquipIconNoBg(item.key)
            
            local equipCfg = emblemVoApi:getEquipCfgById(item.key)
            local bgname = "emblem_iconBg" .. equipCfg.color .. ".png"
            icon = LuaCCSprite:createWithSpriteFrameName(bgname, showInfoHandler)
            icon:addChild(subIcon)
            subIcon:setPosition(getCenterPoint(icon))
            subIcon:setScale(90 / subIcon:getContentSize().width)
            subIcon:setTag(99)
            
        elseif item.type and item.type == "se" then
            icon = emblemVoApi:getEquipIconNoBg(item.key, nil, nil, showInfoHandler)
        elseif item.type and item.type == "am" then
            if item.key == "exp" then
                icon = GetBgIcon(item.pic, showInfoHandler, item.bgname, 90, iconSize)
            else
                icon = armorMatrixVoApi:getArmorMatrixIcon(item.key, 90, 100, showInfoHandler, 1)
            end
        elseif item.type and item.type == "pl" then --空中打击系统相关
            local eType = string.sub(item.key, 1, 1)
            if eType == "s" then --技能
                icon = planeVoApi:getSkillIcon(item.key, iconSize, showInfoHandler, item.num)
            end
        elseif item.type and item.type == "l" then --头像、头像框、聊天框
            local eType = string.sub(item.key, 1, 1)
            if eType == "c" then
                icon = LuaCCScale9Sprite:createWithSpriteFrameName("fi_bubble_bg.png", CCRect(4, 4, 1, 1), showInfoHandler)
                icon:setContentSize(CCSizeMake(128, 128))
                icon:setOpacity(0)
                local rect = CCRect(30, 25, 1, 1)
                if item.pic ~= "chat_bg_left.png" then
                    rect = CCRect(48, 25, 1, 1)
                end
                local bubbleSp = CCSprite:createWithSpriteFrameName(item.pic)
                -- local bubbleSp=LuaCCScale9Sprite:createWithSpriteFrameName(item.pic,rect,function()end)
                -- bubbleSp:setContentSize(CCSizeMake(icon:getContentSize().width,icon:getContentSize().height/2))
                bubbleSp:setPosition(icon:getContentSize().width / 2, icon:getContentSize().height / 2)
                icon:addChild(bubbleSp)
                local msgLb = GetTTFLabelWrap(getlocal("hello"), 20, CCSize(bubbleSp:getContentSize().width - 25, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                msgLb:setAnchorPoint(ccp(0, 0.5))
                msgLb:setPosition(25, bubbleSp:getContentSize().height / 2)
                bubbleSp:addChild(msgLb)
            else
                icon = playerVoApi:getPlayerHeadFrameSp(item.key, showInfoHandler)
                if icon == nil then
                    icon = LuaCCSprite:createWithSpriteFrameName(item.pic, showInfoHandler)
                end
            end
        elseif item.type and item.type == "o" then --坦克处理
            icon = LuaCCSprite:createWithSpriteFrameName(item.pic, showInfoHandler)
            if icon then
                if item.id ~= G_pickedList(item.id) then --精英坦克
                    local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                    pickedIcon:setPosition(icon:getContentSize().width - 30, 30)
                    pickedIcon:setScale(1.5)
                    icon:addChild(pickedIcon)
                end
            end
        elseif item.type and item.type == "ac" then --情人节活动礼盒
            icon = G_acGetItemIcon(item.key, showInfoHandler, item)
        elseif item.type and item.type == "reportAcReward" then --战报里面活动奖励的特殊处理
            if item.bgname and item.bgname ~= "" then
                icon = LuaCCSprite:createWithSpriteFrameName(item.bgname, showInfoHandler)
                local addIconSp = CCSprite:createWithSpriteFrameName(item.pic)
                addIconSp:setPosition(getCenterPoint(icon))
                addIconSp:setScale(icon:getContentSize().width / addIconSp:getContentSize().width)
                icon:addChild(addIconSp)
            else
                icon = LuaCCSprite:createWithSpriteFrameName(item.pic, showInfoHandler)
            end
        elseif item.type == "at" then --AI部队相关
            local eType = string.sub(item.key, 1, 1)
            if eType == "a" then --AI部队
                icon = AITroopsVoApi:getAITroopsSimpleIcon(item.key, 1, nil, false, showInfoHandler)
            elseif eType == "f" then --AI部队碎片
                local aid = "a"..string.sub(item.key, 2)
                icon = AITroopsVoApi:getAITroopsSimpleIcon(aid, nil, nil, true, showInfoHandler)
            elseif eType == "p" then --AI部队相关道具（目前只有经验道具）
                icon = GetBgIcon(item.pic, showInfoHandler, item.bgname)
            end
        elseif item.type == "sk" then --坦克涂装相关
            eType = string.sub(item.key, 1, 1)
            if eType == "s" then --涂装
                icon = tankSkinVoApi:getSkinIconSp(item.key, showInfoHandler)
            end
        elseif item.type == "aj" then --将领副官相关
            icon = heroAdjutantVoApi:getAdjutantIcon(item.key, nil, nil, showInfoHandler)
        elseif item.type == "al" then --军团旗帜相关
            eType = string.sub(item.key, 1, 2)
            if eType == "if" then --军团旗帜
                icon = allianceVoApi:getAllianceFlag(item.key, showInfoHandler)
            elseif eType == "ic" then --旗帜颜色
            else
                eType = string.sub(item.key, 1, 1)
                if eType == "i" then --旗帜图案
                    icon = allianceVoApi:getAllianceFlagPattern(item.key, showInfoHandler)
                end
            end
        elseif item.pic and item.pic ~= "" then
            if item.key == "energy" then
                icon = GetBgIcon(item.pic, showInfoHandler)
            else
                -- print("item.pic===> ",item.pic)
                icon = LuaCCSprite:createWithSpriteFrameName(item.pic, showInfoHandler)
            end
        end
        if icon then
            local scale = iconSize / icon:getContentSize().width
            icon:setScale(scale)
            return icon, scale
        end
        return nil
    end
    return nil
end

--添加奖励 isAddAexp：是否加军团数据，isfragAndProp：是否加配件碎片和改造道具,不包括成品配件 为true时是加配件碎片和配件道具，不包括成品配件，添加配件通过其他路径，因配件需要后台返回的id
--isAddAlienDailyRes 是否添加每日异星资源数量
function G_addPlayerAward(type, key, id, addValue, isAddAexp, isfragAndProp, isAddAlienDailyRes)
    if addValue and tonumber(addValue) then
        if type == "u" then
            if key then
                if key == "gem" or key == "gems" then
                    playerVoApi:setValue("gems", playerVo["gems"] + tonumber(addValue))
                elseif playerVo[key] then
                    playerVoApi:setValue(key, playerVo[key] + tonumber(addValue))
                end
            end
        elseif type == "p" then
            if id and tonumber(id) then
                if propCfg and propCfg["p"..id] and propCfg["p"..id].notAddBag and propCfg["p"..id].notAddBag == 1 then
                else
                    bagVoApi:addBag(tonumber(id), tonumber(addValue))
                end
            end
            -- elseif type=="h" then
            -- -- 加将领魂魄
            -- if key and string.sub(key,1,1) == "s" then
            --     heroVoApi:addSoul(key,tonumber(addValue))
            -- end
        elseif type == "o" then
            if id and tonumber(id) then
                tankVoApi:addTank(tonumber(id), tonumber(addValue), true)
            end
        elseif type == "a" and isAddAexp == true then
            if key == "aexp" then
                local selfAlliance = allianceVoApi:getSelfAlliance()
                if selfAlliance then
                    local allianceLv, curExp, curMaxExp, percent = allianceVoApi:getLvAndExpAndPer()
                    
                    local lvCfg = playerCfg["allianceExp"]
                    if curExp + addValue > curMaxExp then
                        if allianceLv + 1 > allianceVoApi:getMaxLevel() then
                            allianceVoApi:setAllianceLevel(allianceVoApi:getMaxLevel())
                            allianceVoApi:setAllianceExp(tonumber(lvCfg[allianceLv + 1]))
                        else
                            allianceVoApi:setAllianceLevel(allianceLv + 1)
                            allianceVoApi:setAllianceExp(selfAlliance.exp + addValue)
                        end
                    else
                        allianceVoApi:setAllianceExp(selfAlliance.exp + addValue)
                    end
                    
                    local params = {playerVoApi:getUid(), nil, nil, 0, selfAlliance.level, selfAlliance.exp, -1}
                    chatVoApi:sendUpdateMessage(9, params, selfAlliance.aid + 1)
                    
                end
            end
            if key == "point" then
                local selfAlliance = allianceVoApi:getSelfAlliance()
                if selfAlliance then
                    local point = (selfAlliance.point or 0) + tonumber(addValue)
                    local updateData = {point = point}
                    allianceVoApi:formatSelfAllianceData(updateData)
                    
                    local params = {playerVoApi:getUid(), nil, nil, nil, nil, nil, nil, point}
                    chatVoApi:sendUpdateMessage(9, params, selfAlliance.aid + 1)
                end
            end
        elseif type == "e" and isfragAndProp == true then
            local fragment = {}
            local props = {}
            eType = string.sub(key, 1, 1)
            if eType == "f" then
                fragment[id] = tonumber(addValue)
            elseif eType == "p" then
                props[id] = tonumber(addValue)
            end
            local accessory = {fragment = fragment, props = props}
            accessoryVoApi:addNewData(accessory)
        elseif type == "r" and base.alien == 1 then
            local resNum = alienTechVoApi:getAlienResByType(key)
            alienTechVoApi:setAlienResByType(key, resNum + tonumber(addValue))
            
            if isAddAlienDailyRes == nil then
                isAddAlienDailyRes = false
            end
            if isAddAlienDailyRes == true and (key == "r1" or key == "r2" or key == "r3") then
                local resDailyNum = alienTechVoApi:getAlienDailyResByType(key)
                if resDailyNum then
                    alienTechVoApi:setAlienDailyResByType(key, resDailyNum + tonumber(addValue))
                end
            end
        elseif type == "f" then
            if heroEquipVoApi and (key == "e1" or key == "e2" or key == "e3") then
                heroEquipVoApi:addEquipXp(key, addValue)
            end
        elseif type == "m" then -- 军事演习 竞技勋章（type m, key p）
            if arenaVoApi then
                arenaVoApi:addPoint(addValue)
            end
        elseif type == "n" then -- 远征 远征积分（type n, key p）
            if expeditionVoApi then
                expeditionVoApi:addPoint(addValue)
            end
        elseif type == "se" then -- 军徽
            if emblemVoApi then
                emblemVoApi:addNumByKey(key, addValue)
            end
        elseif type == "am" then -- 装甲矩阵
            if key == "exp" then -- 装甲 经验前台自己添加
                if armorMatrixVoApi and armorMatrixVoApi.addArmorExp then
                    armorMatrixVoApi:addArmorExp(addValue)
                end
                
            end
            -- 占位（k=="m1" "m2" ...）  没有唯一id 无法添加，有唯一id 调用armorMatrixVoApi:addArmorInfoById(id,value) value 默认是1
        elseif type == "pl" then --空中打击系统
            local eType = string.sub(key, 1, 1)
            if eType == "s" then
                if planeVoApi and planeVoApi.addSkill then
                    planeVoApi:addSkill(key, addValue)
                end
            end
        elseif type == "l" then --头像、头像框、聊天框
            local eType = string.sub(key, 1, 1)
            local eValue = string.sub(key, 2)
            local item, _index, _id
            if eType == "a" then
                item = headCfg.list[tostring(eValue)]
                _index = 1
                _id = eValue
            elseif eType == "h" then
                item = headFrameCfg.list[key]
                _index = 2
                _id = key
            elseif eType == "c" then
                item = chatFrameCfg.list[key]
                _index = 3
                _id = key
            end
            if item then
                local timer = 0
                if item.time then
                    timer = base.serverTime + item.time
                end
                playerVoApi:setUnLockData(_index, {_id, timer})
            end
        elseif type == "ac" then --情人节活动礼盒
            --活动道具不进背包
        elseif type == "at" then --AI部队相关
            --目前只需处理AI部队即可。碎片和道具都只在AI部队功能中使用，每次进入AI部队功能时都会请求数据的
            local eType = string.sub(key, 1, 1)
            if eType == "a" then --AI部队
                AITroopsVoApi:addAITroopById(key)
            elseif eType == "f" then --AI部队碎片
                -- local aid = "a"..string.sub(key,2)
            elseif eType == "p" then --AI部队相关道具（目前只有经验道具）
            end
        end
    end
end

function G_showRewardTip(award, isShow, onlyReward, isNewType, callback)
    if isShow == nil then
        isShow = true
    end
    if isNewType == nil then
        isNewType = true
    end
    local str = ""
    if award and SizeOfTable(award) > 0 then
        if onlyReward == true then
        else
            str = getlocal("daily_lotto_tip_10")
        end
        for k, v in pairs(award) do
            local nameStr = v.name
            if v.type == "c" then
                nameStr = getlocal(v.name, {v.num})
            end
            if k == SizeOfTable(award) then
                if (v.type == "e" and v.eType == "a") or (v.type == "h" and v.eType == "h") or v.num == 0 then
                    str = str .. nameStr
                else
                    str = str .. nameStr .. " x" .. v.num
                end
            else
                if (v.type == "e" and v.eType == "a") or (v.type == "h" and v.eType == "h") or v.num == 0 then
                    str = str .. nameStr .. ","
                else
                    str = str .. nameStr .. " x" .. v.num .. ","
                end
            end
        end
    end
    if isShow and str and str ~= "" then
        if isNewType == false then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), str, 28, nil, nil)
        elseif award and SizeOfTable(award) > 5 then
            local showAward = {}
            local awardNum = SizeOfTable(award)
            local num = math.ceil(awardNum / 5)
            local acArr = CCArray:create()
            for i = 1, awardNum do
                local index = math.ceil(i / 5)
                if showAward[index] == nil then
                    showAward[index] = {}
                end
                table.insert(showAward[index], award[i])
            end
            for k, v in pairs(showAward) do
                local award1 = v
                local function showTip()
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), str, 28, nil, nil, award1)
                end
                local callFunc = CCCallFunc:create(showTip)
                acArr:addObject(callFunc)
                if k < num then
                    local delay = CCDelayTime:create(1.5)
                    acArr:addObject(delay)
                end
            end
            -- print("dafadddddddddddd")
            -- local function endActionCallBack()
            -- print("--------->endActionCallBack")
            --     if callback then
            --         print("=======?endActionCallBack")
            --         callback()
            --     end
            -- end
            -- local callFunc=CCCallFunc:create(endActionCallBack)
            -- acArr:addObject(callFunc)
            local seq = CCSequence:create(acArr)
            sceneGame:runAction(seq)
        else
            -- local num=SizeOfTable(award)
            -- local acArr=CCArray:create()
            -- local delaytime=2+num*0.2
            -- local delay=CCDelayTime:create(delaytime)
            -- acArr:addObject(delay)
            -- local function endActionCallBack()
            --     print("--------->endActionCallBack")
            --     if callback then
            --         print("=======?endActionCallBack")
            --         callback()
            --     end
            -- end
            -- local callFunc=CCCallFunc:create(endActionCallBack)
            -- acArr:addObject(callFunc)
            -- local seq=CCSequence:create(acArr)
            -- sceneGame:runAction(seq)
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), str, 28, nil, nil, award)
        end
    end
    return str
end
function G_showRewardStr(award)
    local str = ""
    if award and SizeOfTable(award) > 0 then
        str = getlocal("daily_lotto_tip_10")
        for k, v in pairs(award) do
            local nameStr = v.name
            if v.type == "c" then
                nameStr = getlocal(v.name, {v.num})
            end
            if k == SizeOfTable(award) then
                str = nameStr .. " x" .. v.num
            else
                str = nameStr .. " x" .. v.num .. ","
            end
            
        end
    end
    return str
end

function DailyUpdateTime()
    local today = os.date("*t")
    local dailyTs = os.time({year = today.year, month = today.month, day = today.day, hour = 0, min = 0, sec = 0})
    return dailyTs
end

--邮件拉数据
function G_updateEmailList(type, callbackHandler, ifShowLoading)
    if type ~= nil then
        local function emailListCallback(fn, data)
            local success, retTb = base:checkServerData(data)
            if success == true then
                if callbackHandler ~= nil then
                    callbackHandler(retTb)
                end
            end
        end
        local flag = emailVoApi:getFlag(type)
        if flag == nil or flag == -1 then
            socketHelper:emailList(type, 0, 0, emailListCallback, 1)
        else
            local mineid, maxeid = emailVoApi:getMinAndMaxEid(type)
            socketHelper:emailList(type, mineid, maxeid, emailListCallback, nil, ifShowLoading)
        end
    end
end

--icon加背景
function GetBgIcon(icon, callback, iconBackSp, iconSize, bgSize)
    local iconSp = CCSprite:createWithSpriteFrameName(icon)
    if iconSize then
        iconSp:setScale(iconSize / iconSp:getContentSize().width)
    end
    iconSp:setTag(99)
    if iconBackSp ~= nil then
        local iconBg
        if callback ~= nil then
            iconBg = LuaCCSprite:createWithSpriteFrameName(iconBackSp, callback)
        else
            iconBg = CCSprite:createWithSpriteFrameName(iconBackSp)
        end
        iconSp:setPosition(getCenterPoint(iconBg))
        iconBg:addChild(iconSp)
        if bgSize then
            iconBg:setScale(bgSize / iconBg:getContentSize().width)
        else
            iconBg:setScale(1)
        end
        return iconBg
    else
        local iconBg
        if callback ~= nil then
            iconBg = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png", callback)
        else
            iconBg = CCSprite:createWithSpriteFrameName("Icon_BG.png")
        end
        iconSp:setPosition(getCenterPoint(iconBg))
        iconBg:addChild(iconSp)
        if bgSize then
            iconBg:setScale(bgSize / iconBg:getContentSize().width)
        else
            iconBg:setScale(1)
        end
        return iconBg
    end
end

--根据岛屿类型取岛屿名字
function G_getIslandName(islandType, name, rebelLv, rebelID, addLv, rpic)
    local islandName = ""
    if islandType >= 0 and islandType < 6 then
        islandName = getlocal("world_island_"..tostring(islandType))
    elseif islandType == 6 and name ~= nil then
        islandName = name
    elseif islandType == 7 and rebelLv and rebelID then
        if addLv == nil then
            addLv = true
        end
        islandName = rebelVoApi:getRebelName(rebelLv, rebelID, addLv, rpic)
    elseif islandType == 8 then --军团城市，此处rebelLv传的是军团城市等级
        islandName = allianceCityVoApi:getAllianceCityName(name, rebelLv)
    elseif islandType == 9 then --欧米伽小队
        islandName = getlocal("airShip_worldTroops")
    end
    return islandName
end
--根据异星资源类型取资源名字
function G_getAlienIslandName(resType)
    local nameStr = getlocal("alienMines_island_name_"..resType)
    return nameStr
end

function G_isIphone5()
    --[[
    if deviceHelper:getDeviceSystemName()=="iPhone OS" and  G_VisibleSize.height==1136 and G_VisibleSize.width==640 then
        return true
    end
    ]]
    if((G_VisibleSize.height / G_VisibleSize.width) >= 1136 / 640)then
        return true
    end
    return false
end

function G_SyncData(callbackHandler)
    local function userSyncCallBack(fn, data)
        local success, retTb = base:checkServerData(data)
        if success == true then
            if callbackHandler ~= nil then
                callbackHandler(retTb)
            end
        end
    end
    base.lastSyncTime = base.serverTime
    socketHelper:userSync(userSyncCallBack)
end

function G_checkClickEnable()
    if math.abs(G_getCurDeviceMillTime() - base.setWaitTime) <= 600 then
        return false
    else
        return true
    end
end

function G_pushMessage(msg, fireDate, key, tag)
    if(pushController:checkPushServiceVersion() ~= 1)then
        do return end
    end
    local energyNoticeFlag = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_energyFull")
    local produceNoticeFlag = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_jobDown")
    local wholeNoticeFlag = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_pushWhole")
    local needNotice = false
    if energyNoticeFlag == 0 or energyNoticeFlag == 2 then
        if tag == G_EnergyFullTag then
            needNotice = true
        end
    end
    local table = {1, 2, 3, 4, 5}
    
    if produceNoticeFlag == 0 or produceNoticeFlag == 2 then
        for k, v in pairs(table) do
            if tag == v then
                needNotice = true
                
            end
        end
    end
    if wholeNoticeFlag == 0 or wholeNoticeFlag == 2 then
        if tag == G_timeTag or tag == G_timeTag2 then
            needNotice = true
        end
    end
    if needNotice == true then
        deviceHelper:pushMessage(msg, fireDate, key, tag)
    end
end

function G_cancelPush(key, tag)
    deviceHelper:cancelPushByKey(key, tag)
end

--获取系统默认设置语言
function G_getOSCurrentLanguage()
    local tmpTb = {}
    tmpTb["action"] = "getDeviceLanguage"
    local cjson = G_Json.encode(tmpTb)
    return G_accessCPlusFunction(cjson)
end

--点击游客登录
function G_setGuestLogin()
    if G_loginType == 2 then
        --[[
                  local uNames=deviceHelper:getUserName()
                  local nameTb=Split(uNames,",")
                  if nameTb[1]~=nil and nameTb[1]~="" then
                      G_setLocalTankUserName(Split(uNames,",")[1])
                      G_setLocalTankPwd("123456")
                  else
                      G_setLocalTankUserName(G_getGuid())
                      G_setLocalTankPwd("123456")
                  end
                  ]]
        --local uNameGuid=CCUserDefault:sharedUserDefault():getStringForKey(G_local_username)
        local uNameGuid = CCUserDefault:sharedUserDefault():getStringForKey(G_local_guestAccount)
        if uNameGuid == "" then
            uNameGuid = G_getGuid()
        end
        CCUserDefault:sharedUserDefault():setStringForKey(G_local_username, uNameGuid)
        CCUserDefault:sharedUserDefault():setStringForKey(G_local_guestAccount, uNameGuid)
        G_setLocalTankPwd("123456")
        CCUserDefault:sharedUserDefault():flush()
        --end
        
    elseif G_loginType == 1 then
        local uNameGuid = CCUserDefault:sharedUserDefault():getStringForKey(G_local_username)
        if uNameGuid == "" then
            uNameGuid = G_getGuid()
            CCUserDefault:sharedUserDefault():setStringForKey(G_local_username, uNameGuid)
            CCUserDefault:sharedUserDefault():flush()
        end
        G_setLocalTankUserName(uNameGuid)
        G_setLocalTankPwd("123456")
    end
end

function G_getTankUserName()
    
    if PlatformManage ~= nil then--判断不同的平台 加载不同的loginScene-----"0":appstore "1":快用 "2":yeahmobi "qihoo":360平台
        
        if platCfg.platCfgUsePlatUid[G_curPlatName()] ~= nil then
            do
                return base.platformUserId
            end
        end
    end
    
    local tankUserName
    tankUserName = CCUserDefault:sharedUserDefault():getStringForKey(G_local_username)
    if tankUserName == "" then
        tankUserName = G_getGuid()
        CCUserDefault:sharedUserDefault():setStringForKey(G_local_username, tankUserName)
        CCUserDefault:sharedUserDefault():setStringForKey(G_local_guestAccount, tankUserName)
        CCUserDefault:sharedUserDefault():flush()
    end
    return tankUserName
    
    --[[
     local tankUserName=CCUserDefault:sharedUserDefault():getStringForKey(tostring(G_local_username)) --优先取临时记录的用户
     if tankUserName=="" then
            local deviceName=deviceHelper:getUserName()
            local allDeviceNames=Split(deviceName,",")
            if allDeviceNames[1]~=nil and allDeviceNames[1]~="" then
                tankUserName=allDeviceNames[1]
            else
                tankUserName=deviceHelper:guid()
                deviceHelper:setUserName(tankUserName..",") --存入机器
            end
            CCUserDefault:sharedUserDefault():setStringForKey(G_local_username,tankUserName)
            CCUserDefault:sharedUserDefault():flush()
     end
     return tankUserName
     ]]
end

--[[
        function G_setTankUserName(username)
                    if username~=nil and username~="" then
                        CCUserDefault:sharedUserDefault():setStringForKey(G_local_username,username)
                        CCUserDefault:sharedUserDefault():flush()
                        username=deviceHelper:getUserName()..username..","
                        deviceHelper:setUserName(username)
                    end
        end
 ]]

function G_setLocalTankUserName(username)
    CCUserDefault:sharedUserDefault():setStringForKey(G_local_username, username)
    CCUserDefault:sharedUserDefault():flush()
end

function G_setLocalTankPwd(password)
    if password ~= nil and password ~= "" then
        CCUserDefault:sharedUserDefault():setStringForKey(G_local_userpassword, password)
        CCUserDefault:sharedUserDefault():flush()
    end
end

function G_getTankUserPassWord()
    local tankUserPassword = CCUserDefault:sharedUserDefault():getStringForKey(tostring(G_local_userpassword)) --优先取临时记录的用户
    
    if tankUserPassword == "" then
        tankUserPassword = "123456"
        CCUserDefault:sharedUserDefault():setStringForKey(G_local_userpassword, tankUserPassword)
        CCUserDefault:sharedUserDefault():flush()
    end
    return tankUserPassword
end

--[[
        function G_setTankUserPassWord(password)
            if password~=nil and password~="" then
                CCUserDefault:sharedUserDefault():setStringForKey(G_local_userpassword,password)
                CCUserDefault:sharedUserDefault():flush()
            end
        end
]]

function G_changeTankUserPassWord(password)
    G_setLocalTankPwd(password)
end
function G_setTankIsguest(isguest)
    
    if isguest ~= nil then
        CCUserDefault:sharedUserDefault():setStringForKey(G_local_isguest, isguest)
        CCUserDefault:sharedUserDefault():flush()
    end
    
end

function G_checkBind()
    local deviceName = deviceHelper:getUserName()
    local allDeviceNames = Split(deviceName, ",")
    if #allDeviceNames >= 5 then
        return false, allDeviceNames[2] .. ","..allDeviceNames[3] .. ","..allDeviceNames[4]
    else
        return true
    end
end

function G_getTankIsguest()
    if G_curPlatName() == "51" then --飞流正版巨兽崛起已暂时去掉游客登录，故先去掉绑定弹板
        do return "0" end
    end
    local isguest
    
    if platCfg.platCfgPlatNoticeIsBind[G_curPlatName()] ~= nil then --快用平台会回传给游戏是否绑定过  不需要自己判断
        isguest = (global.accountIsBind and "0" or "1")
        if G_curPlatName() == "android360ausgoogle" then
            isguest = playerVoApi:isGuest()
        end
    else
        
        if platCfg.platCfgPlatAccountMustBind[G_curPlatName()] ~= nil then
            do
                return "0"
            end
        end
        
        if platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 8 or platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 9 or platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 10 then --rayjoy 账号系统
            if base.loginAccountType == 0 or base.loginAccountType == 1 then
                do
                    return "0"
                end
            else
                do
                    return "1"
                end
            end
        end
        
        local userName = G_getTankUserName()
        if string.len(userName) >= 35 then
            isguest = "1"
        else
            
            isguest = "0"
        end
    end
    return isguest
end

function G_setIsBind(isbind)
    global.accountIsBind = isbind
    G_bindUserACCount(nil)
end

function G_getIsBind(uname)
    local isbind = 0
    
    if platCfg.platCfgPlatNoticeIsBind[G_curPlatName()] ~= nil then --快用平台会回传给游戏是否绑定过  不需要自己判断
        isbind = (global.accountIsBind and 1 or 0)
    else --其它平台需要自己判断
        if platCfg.platCfgPlatAccountMustBind[G_curPlatName()] ~= nil then --这些平台只能使用绑定的账号
            do
                return 1
            end
        end
        
        if platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 8 or platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 9 or platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 10 then --rayjoy 账号系统
            if base.loginAccountType == 0 or base.loginAccountType == 1 then
                do
                    return 1
                end
            else
                do
                    return 0
                end
            end
        end
        
        local userName = uname
        if string.len(userName) >= 35 then
            isbind = 0
        else
            isbind = 1
        end
    end
    print("是否绑定过", isbind)
    return isbind
end

function G_setPayment(payment)
    if payment ~= nil then
        CCUserDefault:sharedUserDefault():setStringForKey(G_local_payment, payment)
        CCUserDefault:sharedUserDefault():flush()
    end
end
function G_getPayment()
    
    local payment = CCUserDefault:sharedUserDefault():getStringForKey(tostring(G_local_payment))
    return payment
    
end
function G_setPaymentUid(uid)
    if uid ~= nil then
        CCUserDefault:sharedUserDefault():setStringForKey(G_local_paymentUid, uid)
        CCUserDefault:sharedUserDefault():flush()
    end
end
function G_getPaymentUid()
    
    local uid = CCUserDefault:sharedUserDefault():getStringForKey(tostring(G_local_paymentUid))
    return uid
    
end

function G_isToday(time)
    return (base.serverTime - (G_getWeeTs(time) + 24 * 60 * 60)) < 0
    --return (base.serverTime-(time+24*60*60))<0
end

function G_buyEnergy(layerNum, isLackEnergy, buyHandler)
    if G_isToday(base.daily_buy_energy.ts) == false then
        base.daily_buy_energy.num = 0
    end
    local function showMessage()
        local textStr = nil;
        local maxVipLevel = 9
        if base.he == 1 then
            maxVipLevel = tonumber(playerVoApi:getMaxLvByKey("maxVip"))
        end
        if playerVoApi:getVipLevel() == maxVipLevel then
            textStr = getlocal("energytodaytimeslimite2")
        else
            textStr = getlocal("energytodaytimeslimite")
        end
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), textStr, nil, layerNum + 1)
    end
    local function addEnergySrue()
        
        local function buyEnergyHandler(fn, data)
            --local retTb=OBJDEF:decode(data)
            if base:checkServerData(data) == true then
                if buyHandler ~= nil then
                    buyHandler()
                end
                local buyEnergyNum = playerCfg.buyAddEnergyNum_normal
                if base.he == 1 then
                    buyEnergyNum = playerCfg.buyAddEnergyNum_equip
                end
                
                local name, pic, desc, id, index, eType, equipId, bgname = getItem("energy", "u")
                local num = buyEnergyNum
                local award = {type = "u", key = "energy", pic = pic, name = name, num = num, desc = desc, id = id, bgname = bgname}
                local reward = {award}
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("promptProduceFinish"), 28, nil, nil, reward)
            end
        end
        if base.daily_buy_energy.num < playerVoApi:getVipLevel() + 1 then
            socketHelper:buyEnergy(buyEnergyHandler)
            
        else
            showMessage()
        end
    end
    if base.daily_buy_energy.num < playerVoApi:getVipLevel() + 1 then
        local needGems = playerCfg.buyEnergyCost_normal * (base.daily_buy_energy.num + 1)
        local buyEnergyNum = playerCfg.buyAddEnergyNum_normal
        if base.he == 1 then
            needGems = playerCfg.buyEnergyCost_equip[(base.daily_buy_energy.num + 1)]
            buyEnergyNum = playerCfg.buyAddEnergyNum_equip
        end
        
        if playerVoApi:getGems() >= needGems then
            if isLackEnergy == nil then
                isLackEnergy = false
            end
            local buyEnergyPrompt = getlocal("buyEnergy", {needGems, buyEnergyNum})
            if isLackEnergy == true then
                buyEnergyPrompt = getlocal("lackEnergyPrompt") .. ", " .. getlocal("buyEnergy", {needGems, buyEnergyNum})
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), addEnergySrue, getlocal("dialog_title_prompt"), buyEnergyPrompt, nil, layerNum + 1)
        else
            local gemsNum = needGems - playerVoApi:getGems()
            GemsNotEnoughDialog(nil, nil, gemsNum, layerNum + 1, needGems)
        end
    else
        showMessage()
    end
    
end

function G_addFlicker(parentBg, scaleX, scaleY, flickerPos)
    if parentBg then
        local pzFrameName = "CircleEffect_1.png"
        local metalSp = CCSprite:createWithSpriteFrameName(pzFrameName)
        local pzArr = CCArray:create()
        for kk = 1, 31 do
            local nameStr = "CircleEffect_"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            pzArr:addObject(frame)
        end
        local animation = CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.03)
        local animate = CCAnimate:create(animation)
        metalSp:setAnchorPoint(ccp(0.5, 0.5))
        if scaleX ~= nil then
            --metalSp:setScaleX(1/scaleX)
            metalSp:setScaleX(scaleX)
        end
        if scaleY ~= nil then
            --metalSp:setScaleY(1/scaleY)
            metalSp:setScaleY(scaleY)
        end
        if flickerPos then
            metalSp:setPosition(flickerPos)
        else
            metalSp:setPosition(getCenterPoint(parentBg))
        end
        metalSp:setTag(10101)
        parentBg:addChild(metalSp, 4)
        local repeatForever = CCRepeatForever:create(animate)
        metalSp:runAction(repeatForever)
        return metalSp
    end
end
function G_addFlickerByTimes(parentBg, scaleX, scaleY, flickerPos, times)
    if parentBg then
        local pzFrameName = "CircleEffect_1.png"
        local metalSp = CCSprite:createWithSpriteFrameName(pzFrameName)
        local pzArr = CCArray:create()
        for kk = 1, 31 do
            local nameStr = "CircleEffect_"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            pzArr:addObject(frame)
        end
        local animation = CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.03)
        local animate = CCAnimate:create(animation)
        metalSp:setAnchorPoint(ccp(0.5, 0.5))
        if scaleX ~= nil then
            --metalSp:setScaleX(1/scaleX)
            metalSp:setScaleX(scaleX)
        end
        if scaleY ~= nil then
            --metalSp:setScaleY(1/scaleY)
            metalSp:setScaleY(scaleY)
        end
        if flickerPos then
            metalSp:setPosition(flickerPos)
        else
            metalSp:setPosition(getCenterPoint(parentBg))
        end
        metalSp:setTag(10101)
        parentBg:addChild(metalSp, 4)
        
        local function realClose()
            metalSp:removeFromParentAndCleanup(true)
        end
        base:removeFromNeedRefresh(self) --停止刷新
        local fc = CCCallFunc:create(realClose)
        local repeatForever = CCRepeat:create(animate, times)
        local acArr = CCArray:create()
        acArr:addObject(repeatForever)
        acArr:addObject(fc)
        local seq = CCSequence:create(acArr)
        metalSp:runAction(seq)
        --return metalSp
    end
end
--图标的领取特效
function G_addNewMainUIRectFlicker(parentBg, scaleX, scaleY, flickerPos)
    if parentBg and parentBg:getChildByTag(10101) == nil then
        local pzFrameName = "newUI_RotatingEffect_0.png"
        local metalSpBg = CCSprite:createWithSpriteFrameName("newUI_RotatingEffect_Bg.png")
        local metalSp = CCSprite:createWithSpriteFrameName(pzFrameName)
        local pzArr = CCArray:create()
        for kk = 0, 14 do
            local nameStr = "newUI_RotatingEffect_"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            pzArr:addObject(frame)
        end
        local blendFunc = ccBlendFunc:new()
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        metalSp:setBlendFunc(blendFunc)
        local animation = CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.08)
        local animate = CCAnimate:create(animation)
        metalSp:setAnchorPoint(ccp(0.5, 0.5))
        if scaleX ~= nil then
            metalSpBg:setScaleX(scaleX)
        end
        if scaleY ~= nil then
            metalSpBg:setScaleY(scaleY)
        end
        if flickerPos then
            metalSpBg:setPosition(flickerPos)
        else
            metalSpBg:setPosition(ccp(parentBg:getContentSize().width / 2 - 2, parentBg:getContentSize().height / 2 + 3))
        end
        metalSp:setPosition(getCenterPoint(metalSpBg))
        metalSp:setTag(10101)
        parentBg:addChild(metalSpBg, 5)
        metalSpBg:addChild(metalSp, 5)
        local repeatForever = CCRepeatForever:create(animate)
        metalSp:runAction(repeatForever)
        return metalSpBg
    end
end

function G_addNewRectFlicker(parentBg)
    if parentBg and parentBg:getChildByTag(10101) == nil then
        local pzFrameName = "yh_RotatingEffect1.png"
        local metalSp = CCSprite:createWithSpriteFrameName(pzFrameName)
        local pzArr = CCArray:create()
        for kk = 1, 15 do
            local nameStr = "yh_RotatingEffect"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            pzArr:addObject(frame)
        end
        local animation = CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.1)
        local animate = CCAnimate:create(animation)
        metalSp:setAnchorPoint(ccp(0.5, 0.5))
        metalSp:setPosition(ccp(parentBg:getContentSize().width / 2 - 2, parentBg:getContentSize().height / 2 + 3))
        metalSp:setTag(10101)
        parentBg:addChild(metalSp, 5)
        local repeatForever = CCRepeatForever:create(animate)
        metalSp:runAction(repeatForever)
        return metalSp
    end
end
--首充奖励的领取特效
function G_addGoldRectFlicker(parentBg, scaleX, scaleY, flickerPos, lnum)
    if parentBg and parentBg:getChildByTag(10101) == nil then
        local m_iconScaleX, m_iconScaleY = scaleX, scaleY
        local pzFrameName = "goldRotatingEffect_0.png"
        local metalSp = CCSprite:createWithSpriteFrameName(pzFrameName)
        local pzArr = CCArray:create()
        for kk = 0, 9 do
            local nameStr = "goldRotatingEffect_"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            pzArr:addObject(frame)
        end
        local blendFunc = ccBlendFunc:new()
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        metalSp:setBlendFunc(blendFunc)
        
        local animation = CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.08)
        local animate = CCAnimate:create(animation)
        metalSp:setAnchorPoint(ccp(0.5, 0.5))
        if m_iconScaleX ~= nil then
            metalSp:setScaleX(m_iconScaleX)
        end
        if m_iconScaleY ~= nil then
            metalSp:setScaleY(m_iconScaleY)
        end
        metalSp:setPosition(ccp(parentBg:getContentSize().width / 2, parentBg:getContentSize().height / 2 - 3))
        metalSp:setTag(10101)
        if lnum == nil then
            lnum = 5
        end
        
        local realLight = CCSprite:createWithSpriteFrameName("goldRotatingEffect_Bg.png")
        realLight:setPosition(ccp(parentBg:getContentSize().width / 2, parentBg:getContentSize().height / 2 - 3))
        realLight:setBlendFunc(blendFunc)
        parentBg:addChild(realLight, lnum)
        
        local fadeTo1 = CCFadeTo:create(0.4, 255)
        local fadeTo2 = CCFadeTo:create(0.6, 0)
        local seq = CCSequence:createWithTwoActions(fadeTo1, fadeTo2)
        
        local finalAc = CCRepeatForever:create(seq)
        realLight:runAction(finalAc)
        
        parentBg:addChild(metalSp, lnum)
        local repeatForever = CCRepeatForever:create(animate)
        metalSp:runAction(repeatForever)
        return metalSp, realLight
        
    end
end

function G_addRectFlicker(parentBg, scaleX, scaleY, flickerPos, lnum)
    if parentBg and parentBg:getChildByTag(10101) == nil then
        local m_iconScaleX, m_iconScaleY = scaleX, scaleY
        local pzFrameName = "RotatingEffect1.png"
        local metalSp = CCSprite:createWithSpriteFrameName(pzFrameName)
        local pzArr = CCArray:create()
        for kk = 1, 20 do
            local nameStr = "RotatingEffect"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            pzArr:addObject(frame)
        end
        local animation = CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.1)
        local animate = CCAnimate:create(animation)
        metalSp:setAnchorPoint(ccp(0.5, 0.5))
        if m_iconScaleX ~= nil then
            metalSp:setScaleX(m_iconScaleX)
        end
        if m_iconScaleY ~= nil then
            metalSp:setScaleY(m_iconScaleY)
        end
        metalSp:setPosition(ccp(parentBg:getContentSize().width / 2, parentBg:getContentSize().height / 2))
        metalSp:setTag(10101)
        if lnum == nil then
            lnum = 5
        end
        parentBg:addChild(metalSp, lnum)
        local repeatForever = CCRepeatForever:create(animate)
        metalSp:runAction(repeatForever)
        return metalSp
        
    end
end

-- function G_addRectFlickerSec(parentBg,rate,lNum,subWidth,subHeight)
--     if parentBg then
--         local curRate = 12
--         if rate then
--             curRate = rate
--         end
--         local acBgNum = 5
--         if lNum then
--             acBgNum = lNum
--         end
--         local curSubWidth = 10
--         local curSubHeight = 10
--         if subWidth then
--             curSubWidth = subWidth
--         end
--         if subHeight then
--             curSubHeight = subHeight
--         end
--         local whiNumA = 1 --控制粒子动画的走向
--         local whiNumB = 1

--         local flyingParticle = "public/flying.plist"
--         local flyingA = CCParticleSystemQuad:create(flyingParticle)
--         flyingA.positionType = kCCPositionTypeFree
--         local flyingB = CCParticleSystemQuad:create(flyingParticle)
--         flyingB.positionType = kCCPositionTypeFree
--         local function noData( )  end
--         local acBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),noData)
--         acBg:setAnchorPoint(ccp(0.5,0.5))
--         acBg:setOpacity(0)
--         acBg:setTag(10101)

--         acBg:setContentSize(CCSizeMake(parentBg:getContentSize().width-curSubWidth,parentBg:getContentSize().height-curSubHeight))
--         acBg:setPosition(getCenterPoint(parentBg))
--         parentBg:addChild(acBg,acBgNum)

--         flyingA:setPosition(ccp(0,acBg:getContentSize().height))
--         flyingB:setPosition(ccp(acBg:getContentSize().width,0))
--         acBg:addChild(flyingA)
--         acBg:addChild(flyingB)

--         local function flyingMoving( )
--             -- print("why????----->whiNumA",whiNumA)
--             if whiNumA ==1 then
--                 if flyingA:getPositionX()+curRate >= acBg:getContentSize().width then
--                     flyingA:setPosition(ccp(acBg:getContentSize().width,acBg:getContentSize().height))
--                     whiNumA = 2
--                 else
--                     flyingA:setPosition(ccp(flyingA:getPositionX()+curRate,acBg:getContentSize().height))
--                 end
--             elseif whiNumA ==2 then
--                 if flyingA:getPositionY()-curRate <= 0 then
--                     flyingA:setPosition(ccp(acBg:getContentSize().width,0))
--                     whiNumA = 3
--                 else
--                     flyingA:setPosition(ccp(acBg:getContentSize().width,flyingA:getPositionY()-curRate))
--                 end
--             elseif whiNumA ==3 then
--                 if flyingA:getPositionX()-curRate <= 0 then
--                     flyingA:setPosition(ccp(0,0))
--                     whiNumA = 4
--                 else
--                     flyingA:setPosition(ccp(flyingA:getPositionX()-curRate,0))
--                 end
--             else
--                 if flyingA:getPositionY()+curRate >= acBg:getContentSize().height then
--                     flyingA:setPosition(ccp(0,acBg:getContentSize().height))
--                     whiNumA = 1
--                 else
--                     flyingA:setPosition(ccp(0,flyingA:getPositionY()+curRate))
--                 end
--             end

--             if whiNumB ==1 then
--                 if flyingB:getPositionX()-curRate <= 0 then
--                     flyingB:setPosition(ccp(0,0))
--                     whiNumB = 2
--                 else
--                     flyingB:setPosition(ccp(flyingB:getPositionX()-curRate,0))
--                 end
--             elseif whiNumB ==2 then
--                 if flyingB:getPositionY()+curRate >= acBg:getContentSize().height then
--                     flyingB:setPosition(ccp(0,acBg:getContentSize().height))
--                     whiNumB = 3
--                 else
--                     flyingB:setPosition(ccp(0,flyingB:getPositionY()+curRate))
--                 end
--             elseif whiNumB ==3 then
--                 if flyingB:getPositionX()+curRate >= acBg:getContentSize().width then
--                     flyingB:setPosition(ccp(acBg:getContentSize().width,acBg:getContentSize().height))
--                     whiNumB = 4
--                 else
--                     flyingB:setPosition(ccp(flyingB:getPositionX()+curRate,acBg:getContentSize().height))
--                 end
--             else
--                 if flyingB:getPositionY()-curRate <= 0 then
--                     flyingB:setPosition(ccp(acBg:getContentSize().width,0))
--                     whiNumB = 1
--                 else
--                     flyingB:setPosition(ccp(acBg:getContentSize().width,flyingB:getPositionY()-curRate))
--                 end
--             end
--         end

--         local delay=CCDelayTime:create(0.05)
--         local callFunc=CCCallFuncN:create(flyingMoving)
--         local acArr=CCArray:create()
--         acArr:addObject(delay)
--         acArr:addObject(callFunc)
--         local seq=CCSequence:create(acArr)
--         local repeatForever=CCRepeatForever:create(seq)
--         acBg:runAction(repeatForever)

--         return acBg
--     end
-- end

function G_removeFlicker(parentBg)
    if parentBg ~= nil then
        local temSp = tolua.cast(parentBg, "CCNode")
        local metalSp = nil;
        if temSp ~= nil then
            metalSp = tolua.cast(temSp:getChildByTag(10101), "CCSprite")
        end
        if metalSp ~= nil then
            metalSp:removeFromParentAndCleanup(true)
            metalSp = nil
        end
    end
end

function G_movePointToScreenCenter(scene, sceneobj, aimpoint, callback)
    
    local aimx = -(aimpoint.x * scene.minScale - G_VisibleSize.width / 2)
    local aimy = -(aimpoint.y * scene.minScale - G_VisibleSize.height / 2)
    
    local ampt = scene:checkBound(CCPointMake(aimx, aimy))
    local function moveCallBack()
        print("callback", callback)
        if callback then
            callback()
        end
    end
    
    local moveTo = CCMoveTo:create(0.3, ampt)
    local callFunc = CCCallFunc:create(moveCallBack)
    local seq = CCSequence:createWithTwoActions(moveTo, callFunc)
    sceneobj:runAction(seq)
    
end

--当天零点的时间戳
function G_getWeeTs(ts)
    local timezone = tonumber(base.curTimeZone)
    ts = tonumber(ts)
    --2018冬令时修正
    if(G_curPlatName() == "androidsevenga" or G_curPlatName() == "11" or G_curPlatName() == "0")then
        --如果要算的时间段处于夏令时阶段而当前是冬令时，那么就要按夏令时的规则来。另外服务器可能会记录一些零点时间戳，要排除当天的零点时间戳
        if(ts >= 1521939600 and ts <= 1540688400 and ts ~= 1540681200 and tonumber(base.curTimeZone) == 1)then
            timezone = tonumber(base.curTimeZone) + 1
            --如果要算的时间段处于冬令时阶段而当前是夏令时，那么就要按冬令时的规则。另外服务器可能会记录一些零点时间戳，要排除当天的零点时间戳
        elseif(ts >= 1509238800 and ts <= 1521939600 and ts ~= 1521928800 and tonumber(base.curTimeZone) == 2)then
            timezone = tonumber(base.curTimeZone) - 1
        end
    elseif(G_curPlatName() == "androidkunlun" or G_curPlatName() == "androidkunlunz" or G_curPlatName() == "14")then
        --如果要算的时间段处于夏令时阶段而当前是冬令时，那么就要按夏令时的规则来。另外服务器可能会记录一些零点时间戳，要排除当天的零点时间戳
        if(ts >= 1520762400 and ts <= 1541322000 and ts ~= 1541318400 and tonumber(base.curTimeZone) == -8)then
            timezone = tonumber(base.curTimeZone) + 1
        end
    end
    local result = ts - ((ts + timezone * 3600) % 86400)
    return result
end

--当天零点的时间戳推送用
function G_getWeeTsPush(ts)
    local ts = ts - (ts % 86400)
    return ts
end

--判断ts1和ts2是否在同一周内：true 是，false 否
function G_getWeekDay(ts1, ts2, isTimeZone)
    local dayTs = G_getWeeTs(ts1)
    local weekTs = ts1 % (7 * 86400)
    local week = math.floor(weekTs / 86400)
    local weekDay = week + 4 --1970年1月1日是星期四
    if weekDay > 7 then
        weekDay = weekDay - 7
    end
    local monday0Ts = dayTs - (weekDay - 1) * 86400
    local nextMonday0Ts = monday0Ts + 7 * 86400
    if isTimeZone then
        if (ts2 + base.curTimeZone * 3600) > monday0Ts and (ts2 + base.curTimeZone * 3600) < nextMonday0Ts then
            return true
        else
            return false
        end
    else
        if ts2 > monday0Ts and ts2 < nextMonday0Ts then
            return true
        else
            return false
        end
    end
end

--根据时间戳获取当前获取当前是星期几
--return 1~7表示星期一到星期日
function G_getFormatWeekDay(ts)
    if(ts == nil)then
        ts = base.serverTime
    end
    ts = ts + 1
    local oneWeek = 7 * 86400
    local weekPassTs = ts % oneWeek + 3 * 86400 + base.curTimeZone * 3600
    if(weekPassTs > oneWeek)then
        weekPassTs = weekPassTs - oneWeek
    end
    local week = math.ceil(weekPassTs / 86400)
    return week
end
--取到通讯录名单
function G_getMailList()
    local friendTb = G_clone(friendMailVoApi:getFriendTb())
    for k, v in pairs(friendTb) do
        if v then
            v.name = v.nickname or ""
        end
    end
    return friendTb
    
    -- local blackTb={}
    -- local key="mail_"..tostring(playerVoApi:getUid())..tostring(playerVoApi:getPlayerName())..tostring(base.curZoneID)
    -- local allValue=CCUserDefault:sharedUserDefault():getStringForKey(key)
    
    -- if allValue~="" then
    --     local valueTb=Split(allValue,"rayjoy")
    --     for k,v in pairs(valueTb) do
    --         if v~="" then
    --             local vTb=Split(v,"=")
    --             local insertTb={}
    --             local nameStr=""
    --             for j=1,SizeOfTable(vTb)-1,1 do
    --                 nameStr=nameStr.."="..vTb[j]
    --             end
    --             nameStr=RemoveFirstChar(nameStr)
    --             insertTb.name=nameStr
    --             insertTb.uid=vTb[SizeOfTable(vTb)]
    --             table.insert(blackTb,insertTb)
    --         end
    --     end
    -- end
    -- local blackTb1={}
    -- for k,v in pairs(blackTb) do
    --     if v~="" then
    --         table.insert(blackTb1,v)
    --     end
    -- end
    -- return blackTb1
end

--聊天通讯录本地存储
function G_saveNameAndUidInMailList(tb)
    
    if SizeOfTable(G_getMailList()) > G_mailListNum then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("blackListMax"), 28)
        
        do
            return false
        end
        
    end
    
    local uName = tb.name
    local uid = tb.uid
    
    local key = "mail_"..tostring(playerVoApi:getUid())..tostring(playerVoApi:getPlayerName())..tostring(base.curZoneID)
    
    local blackValue = uName.."="..uid
    local allValue = CCUserDefault:sharedUserDefault():getStringForKey(key)
    local setValue = ""
    setValue = allValue.."rayjoy"..blackValue
    
    CCUserDefault:sharedUserDefault():setStringForKey(key, setValue);
    CCUserDefault:sharedUserDefault():flush();
    
    return true
    
end

--从通讯录中移除
function G_removeMemberInMailListByUid(uid)
    local key = "mail_"..tostring(playerVoApi:getUid())..tostring(playerVoApi:getPlayerName())..tostring(base.curZoneID)
    local allValue = CCUserDefault:sharedUserDefault():getStringForKey(key)
    
    if allValue ~= "" then
        local valueTb = Split(allValue, "rayjoy")
        for k, v in pairs(valueTb) do
            if v ~= "" then
                local vTb = Split(v, "=")
                if tostring(uid) == vTb[SizeOfTable(vTb)] then
                    table.remove(valueTb, k)
                end
            end
        end
        local valueStr = ""
        for k, v in pairs(valueTb) do
            if v ~= nil and v ~= "" then
                valueStr = valueStr.."rayjoy"..v
            end
        end
        CCUserDefault:sharedUserDefault():setStringForKey(key, valueStr)
        CCUserDefault:sharedUserDefault():flush()
    end
    
end

--初始化黑名单
function G_initBlackList(callback)
    if base.mailBlackList == 1 and G_blackList == nil then
        local function mailBlacklistCallback(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                if sData.data and sData.data then
                    G_blackList = {}
                    if sData.data.updated_at and sData.data.updated_at == 0 then
                        local blackTb = {}
                        local key = "chat_"..tostring(playerVoApi:getUid())..tostring(playerVoApi:getPlayerName())..tostring(base.curZoneID)
                        local allValue = CCUserDefault:sharedUserDefault():getStringForKey(key)
                        if allValue ~= "" then
                            local valueTb = Split(allValue, "rayjoy")
                            for k, v in pairs(valueTb) do
                                if v ~= "" then
                                    local vTb = Split(v, "_")
                                    local insertTb = {}
                                    local nameStr = ""
                                    for j = 1, SizeOfTable(vTb) - 1, 1 do
                                        nameStr = nameStr.."_"..vTb[j]
                                    end
                                    nameStr = RemoveFirstChar(nameStr)
                                    insertTb.name = nameStr
                                    insertTb.uid = vTb[SizeOfTable(vTb)]
                                    table.insert(blackTb, insertTb)
                                end
                            end
                        end
                        local blackTb1 = {}
                        for k, v in pairs(blackTb) do
                            if v and type(v) == "table" then
                                if v.uid and tonumber(v.uid) then
                                    table.insert(blackTb1, {tonumber(v.uid), v.name})
                                end
                            end
                        end
                        while SizeOfTable(blackTb1) > G_blackListNum do
                            table.remove(blackTb1, 1)
                        end
                        local function mailAddblackCallback(fn, data)
                            local ret1, sData1 = base:checkServerData(data)
                            if ret1 == true then
                                G_blackList = blackTb1
                                if callback then
                                    callback()
                                end
                            end
                        end
                        local list = {}
                        for i = G_blackListNum, 1, -1 do
                            if blackTb1 and blackTb1[i] and type(blackTb1[i]) == "table" then
                                local item = blackTb1[i]
                                if item and item[1] and tonumber(item[1]) then
                                    table.insert(list, tonumber(item[1]))
                                end
                            end
                        end
                        if SizeOfTable(list) > 0 then
                            socketHelper:mailAddblack(nil, list, mailAddblackCallback)
                        end
                    elseif sData.data.mailblack then
                        if(friendInfoVoApi == nil or friendInfoVoApi.initBlackListTb == nil)then
                            require "luascript/script/game/gamemodel/friendInfo/friendInfoVo"
                            require "luascript/script/game/gamemodel/friendInfo/friendInfoVoApi"
                        end
                        friendInfoVoApi:initBlackListTb(sData.data.mailblack)
                        if callback then
                            callback()
                        end
                    end
                end
            end
        end
        socketHelper:mailBlacklist(mailBlacklistCallback)
    else
        if callback then
            callback()
        end
    end
end
--取到聊天和邮件黑名单
function G_getBlackList()
    if base.mailBlackList == 1 then
        local blackTb1 = {}
        if G_blackList then
            for k, v in pairs(G_blackList) do
                if v and type(v) == "table" then
                    local uid
                    local name
                    if v.uid then
                        uid = tonumber(v.uid)
                        name = v.name
                    else
                        uid = tonumber(v[1])
                        name = v[2]
                    end
                    if uid and name then
                        table.insert(blackTb1, {uid = uid, name = name})
                    end
                end
            end
        end
        return blackTb1
    else
        local blackTb = {}
        local key = "chat_"..tostring(playerVoApi:getUid())..tostring(playerVoApi:getPlayerName())..tostring(base.curZoneID)
        local allValue = CCUserDefault:sharedUserDefault():getStringForKey(key)
        
        if allValue ~= "" then
            local valueTb = Split(allValue, "rayjoy")
            for k, v in pairs(valueTb) do
                if v ~= "" then
                    local vTb = Split(v, "_")
                    local insertTb = {}
                    local nameStr = ""
                    for j = 1, SizeOfTable(vTb) - 1, 1 do
                        nameStr = nameStr.."_"..vTb[j]
                    end
                    nameStr = RemoveFirstChar(nameStr)
                    insertTb.name = nameStr
                    insertTb.uid = vTb[SizeOfTable(vTb)]
                    table.insert(blackTb, insertTb)
                end
            end
        end
        local blackTb1 = {}
        for k, v in pairs(blackTb) do
            if v ~= "" then
                table.insert(blackTb1, v)
            end
        end
        return blackTb1
    end
end
--聊天黑名单本地存储
function G_saveNameAndUidInBlackList(tb, callback)
    local function initCallback()
        -- local uName=tb.name
        -- local uid=tb.uid
        
        -- local key="chat_"..tostring(playerVoApi:getUid())..tostring(playerVoApi:getPlayerName())..tostring(base.curZoneID)
        -- local setValue="3000001名字_3000001"
        -- for i=2,100 do
        --     local numStr=""
        --     if i<10 then
        --         numStr="00"..i
        --     elseif i<100 then
        --         numStr="0"..i
        --     else
        --         numStr=i
        --     end
        --     local blackValue="3000"..numStr.."名字_".."3000"..numStr
        --     setValue=setValue.."rayjoy"..blackValue
        -- end
        
        -- CCUserDefault:sharedUserDefault():setStringForKey(key,setValue);
        -- CCUserDefault:sharedUserDefault():flush();
        -- if callback then
        --     callback()
        -- end
        -- do return end
        
        if SizeOfTable(G_getBlackList()) >= G_blackListNum then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("blackListMax"), 28)
            do
                return false
            end
        end
        
        if base.mailBlackList == 1 then
            if tb and tb.uid then
                local uid = tonumber(tb.uid)
                local uName = tb.name
                local function mailAddblackCallback(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        if platCfg.platCfgChatBanSpeak[G_curPlatName()] ~= nil then
                            -- if G_isHasAddToTodayBlackList(uid)==false then
                            --     local function callback(fn,data)
                            --         local ret,sData=base:checkServerData(data)
                            --         if ret==true then
                            --             G_addToTodayBlackList(uid)
                            --         end
                            --     end
                            --     socketHelper:userAddblack(uid,callback)
                            -- end
                        end
                        if sData.data.user then
                            friendInfoVoApi:addShieldTb(sData.data.user)
                        end
                        local isHas = false
                        for k, v in pairs(G_blackList) do
                            if v and v[1] and uid and tonumber(v[1]) == tonumber(uid) then
                                isHas = true
                            end
                        end
                        if isHas == false then
                            local tempList = G_clone(G_blackList)
                            G_blackList = {{tonumber(uid), uName}}
                            for k, v in pairs(tempList) do
                                table.insert(G_blackList, v)
                            end
                        end
                        if callback then
                            callback()
                            return true
                        end
                    end
                end
                local tid = tb.uid
                socketHelper:mailAddblack(tid, nil, mailAddblackCallback)
            end
        else
            local uName = tb.name
            local uid = tb.uid
            
            local key = "chat_"..tostring(playerVoApi:getUid())..tostring(playerVoApi:getPlayerName())..tostring(base.curZoneID)
            
            local blackValue = uName.."_"..uid
            local allValue = CCUserDefault:sharedUserDefault():getStringForKey(key)
            local setValue = ""
            setValue = allValue.."rayjoy"..blackValue
            
            CCUserDefault:sharedUserDefault():setStringForKey(key, setValue);
            CCUserDefault:sharedUserDefault():flush();
            
            if platCfg.platCfgChatBanSpeak[G_curPlatName()] ~= nil then
                if G_isHasAddToTodayBlackList(uid) == false then
                    local function callback(fn, data)
                        local ret, sData = base:checkServerData(data)
                        if ret == true then
                            G_addToTodayBlackList(uid)
                        end
                    end
                    socketHelper:userAddblack(uid, callback)
                end
            end
            if callback then
                callback()
            end
            return true
        end
    end
    G_initBlackList(initCallback)
end
--从黑名单中移除
function G_removeMemberInBlackListByUid(uid, callback, isTab)
    local function initCallback()
        -- local key="chat_"..tostring(playerVoApi:getUid())..tostring(playerVoApi:getPlayerName())..tostring(base.curZoneID)
        -- local allValue=""
        
        -- CCUserDefault:sharedUserDefault():setStringForKey(key,allValue)
        -- CCUserDefault:sharedUserDefault():flush()
        -- if callback then
        --     callback()
        -- end
        -- do return end
        
        if base.mailBlackList == 1 then
            local function mailRemoveblackCallback(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true then
                    if isTab then
                        G_blackList = {}
                        friendInfoVo.shieldTb = {}
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("friend_newSys_rejectAll"), 30)
                    else
                        for k, v in pairs(G_blackList) do
                            if uid and v and tonumber(v[1]) == tonumber(uid) then
                                table.remove(G_blackList, k)
                            end
                        end
                        friendInfoVoApi:removeShieldTb(uid)
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("friend_newSys_rejectOne"), 30)
                    end
                    if callback then
                        print("why?")
                        callback()
                    end
                end
            end
            if isTab then
                socketHelper:mailRemoveblack(nil, uid, mailRemoveblackCallback)
            else
                socketHelper:mailRemoveblack(uid, nil, mailRemoveblackCallback)
            end
        else
            local key = "chat_"..tostring(playerVoApi:getUid())..tostring(playerVoApi:getPlayerName())..tostring(base.curZoneID)
            local allValue = CCUserDefault:sharedUserDefault():getStringForKey(key)
            
            if allValue ~= "" then
                local valueTb = Split(allValue, "rayjoy")
                for k, v in pairs(valueTb) do
                    if v ~= "" then
                        local vTb = Split(v, "_")
                        if tostring(uid) == vTb[SizeOfTable(vTb)] then
                            table.remove(valueTb, k)
                        end
                    end
                end
                local valueStr = ""
                for k, v in pairs(valueTb) do
                    if v ~= nil and v ~= "" then
                        valueStr = valueStr.."rayjoy"..v
                    end
                end
                CCUserDefault:sharedUserDefault():setStringForKey(key, valueStr)
                CCUserDefault:sharedUserDefault():flush()
            end
            if callback then
                callback()
            end
        end
    end
    G_initBlackList(initCallback)
end

--当天黑名单列表是否已经添加过该玩家
function G_isHasAddToTodayBlackList(uid)
    if uid then
        local key = "chatTodayBlackList@"..tostring(playerVoApi:getUid()) .. "@"..tostring(playerVoApi:getPlayerName()) .. "@"..tostring(base.curZoneID)
        local allValue = CCUserDefault:sharedUserDefault():getStringForKey(key)
        if allValue and allValue ~= "" then
            local valueTb = Split(allValue, "_")
            local lastTime = valueTb[1]
            local listStr = valueTb[2]
            if G_isToday(lastTime) == true then
                local vTb = Split(listStr, "@")
                for k, v in pairs(vTb) do
                    if v and v ~= "" then
                        if tostring(uid) == tostring(v) then
                            do return true end
                        end
                    end
                end
            end
        end
    end
    return false
end
--添加屏蔽玩家到当天黑名单列表
function G_addToTodayBlackList(uid)
    local key = "chatTodayBlackList@"..tostring(playerVoApi:getUid()) .. "@"..tostring(playerVoApi:getPlayerName()) .. "@"..tostring(base.curZoneID)
    local allValue = CCUserDefault:sharedUserDefault():getStringForKey(key)
    if allValue and allValue ~= "" then
        local valueTb = Split(allValue, "_")
        local lastTime = valueTb[1]
        local listStr = valueTb[2]
        if G_isToday(lastTime) == false then
            CCUserDefault:sharedUserDefault():setStringForKey(key, "")
            local valueStr = tostring(base.serverTime) .. "_"..tostring(uid)
            CCUserDefault:sharedUserDefault():setStringForKey(key, valueStr)
            CCUserDefault:sharedUserDefault():flush()
        else
            if G_isHasAddToTodayBlackList(uid) == true then
                do return false end
            end
            local valueStr = tostring(base.serverTime) .. "_"..listStr.."@"..tostring(uid)
            CCUserDefault:sharedUserDefault():setStringForKey(key, valueStr)
            CCUserDefault:sharedUserDefault():flush()
        end
    else
        local valueStr = tostring(base.serverTime) .. "_"..tostring(uid)
        CCUserDefault:sharedUserDefault():setStringForKey(key, valueStr)
        CCUserDefault:sharedUserDefault():flush()
    end
    return true
end

--聊天显示时间
function G_chatTime(ts, isLocalTime)
    if ts == nil then
        ts = base.serverTime
    end
    local time = ts - G_getWeeTs(ts)
    local chour = math.floor(time / 3600)
    local cm = math.floor((time % 3600) / 60)
    if isLocalTime == true then
        -- local timeTab=os.date("*t",ts)
        local timeTab = G_getDate(ts)
        chour = timeTab.hour
        cm = timeTab.min
    end
    if chour >= 0 and chour < 10 then
        chour = "0"..chour
    end
    if cm >= 0 and cm < 10 then
        cm = "0"..cm
    end
    local tsStr = chour..":"..cm
    return tsStr
end

function G_showLoginLoading(timeOut, showAnim)
    local function tmptick()
        G_cancleLoginLoading()
        --base:netHandler("",2)
    end
    if global.loginTickHandler ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(global.loginTickHandler)
        global.loginTickHandler = nil
    end
    
    local timeLen = 16
    if timeOut ~= nil then
        timeLen = timeOut
    end
    global.loginTickHandler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tmptick, timeLen, false) --15秒超时
    
    socketHelper:cancleAllWaitQueue()
    global:showLoginLoading(showAnim)
end

function G_cancleLoginLoading()
    if global.loginTickHandler ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(global.loginTickHandler)
        global.loginTickHandler = nil
    end
    global:cancleLoginLoading()
end

function G_loginGameFromPlatFormByID(isSuccess, pid, token, pname, isBind, parms)
    if isSuccess == true then
        G_showLoginLoading()
        print("登陆成功了de", pid, token, pname)
        --3k腾讯出包前缀出错了，临时处理
        
        if (G_curPlatName() == "android3ktencent" or G_curPlatName() == "android3ktencent2" or G_curPlatName() == "android3ktencent3" or G_curPlatName() == "android3ktencent4") and G_Version >= 25 then
            
            if G_Version == 25 then
                if string.find(pid, "3KW_") ~= nil then
                    
                    pid = G_stringGsub(pid, "3KW_", "3KWT_")
                    pid = pid.."33"
                end
            end
            
            if G_Version == 26 then
                pid = pid.."33"
            end
            
        end
        
        if G_curPlatName() == "efunandroidhuashuo" then
            pid = G_stringGsub(pid, "EF_", "EFHS_")
        end
        
        --
        
        base.platusername = pname
        if platCfg.platCfgPlatNoticeIsBind[G_curPlatName()] ~= nil then
            global.accountIsBind = isBind
            if G_curPlatName() == "5" or G_curPlatName() == "9" or G_curPlatName() == "45" or G_curPlatName() == "58" then
                if global.accountIsBind == true then
                    CCUserDefault:sharedUserDefault():setStringForKey("isBindFL", "1");
                    CCUserDefault:sharedUserDefault():flush();
                else
                    CCUserDefault:sharedUserDefault():setStringForKey("isBindFL", "2");
                    CCUserDefault:sharedUserDefault():flush();
                end
            end
        end
        
        if G_curPlatName() == "qihoo" then
            
            local tmpTb = {}
            tmpTb["action"] = "recordUserStep"
            tmpTb["parms"] = {}
            tmpTb["parms"]["step"] = "7"
            tmpTb["parms"]["create_time"] = ""
            local cjson = G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
            if HttpRequestHelper ~= nil and HttpRequestHelper.sendTmpStatisticData ~= nil then
                HttpRequestHelper:sendTmpStatisticData("5")
            end
        end
        
        base.platformUserId = pid
        if G_curPlatName() == "androidtencently" then
            base.token = pname
        else
            base.token = token
        end
        mainloading.needRequestCheck = true
        if parms ~= nil then
            
            if platCfg.platCfgLoginWithParms[G_curPlatName()] ~= nil then --efun
                base.efunLoginParms = parms
            end
            base.yingyongbao_mid = G_Json.decode(tostring(parms)).ext1 --应用宝集市用的mid
        end
        --kakao的特殊登录逻辑
        if(G_isKakao())then
            loginScene:removekakaoLoginScene()
            G_cancleLoginLoading()
        else
            loginScene:loginByPlatAccout(pid, 123456)
        end
    else
        print("登陆失败了de", pid, token, pname)
    end
end

function G_exitDialogForAndroid()
    if(base.ifAndroidBackFunctionOpen == 1)then
        if(battleScene and battleScene.isBattleing or BossBattleScene and BossBattleScene.isBattleing or newGuidMgr:isNewGuiding() or otherGuideMgr.isGuiding)then
            do return end
        end
        if(G_SmallDialogDialogTb and #G_SmallDialogDialogTb > 0)then
            local smallDialog = G_SmallDialogDialogTb[#G_SmallDialogDialogTb]
            if(smallDialog and smallDialog.close)then
                smallDialog:close()
                do return end
            end
        elseif(base and base.commonDialogOpened_WeakTb and #base.commonDialogOpened_WeakTb > 0)then
            local commonDialog = base.commonDialogOpened_WeakTb[#base.commonDialogOpened_WeakTb]
            if(commonDialog and commonDialog.close)then
                commonDialog:close()
                do return end
            end
        end
    end
    if G_curPlatName() == "androidnjyidong" or (G_curPlatName() == "androidlewan" and G_Version >= 4) then
        do return end
    end
    
    local function exitSureHandler()
        global.exitForAndroidFlag = 0
        deviceHelper:exitGameForAndroid()
    end
    local function cancleExitHandler()
        global.exitForAndroidFlag = 0
    end
    if base.ifAndroidBackFunctionOpen == 1 or global.exitForAndroidFlag == 0 then
        global.exitForAndroidFlag = 1
        smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), exitSureHandler, getlocal("dialog_title_prompt"), getlocal("exitGameSure"), nil, 80, nil, nil, cancleExitHandler)
    end
end

function G_sendFeed(feedType, sendFeedHandler, contentStr)
    
    local function sendFeedCallback(fn, success)
        
        if sendFeedHandler then
            
            sendFeedHandler()
            if G_curPlatName() == "12" or G_curPlatName() == "androidzhongshouyouru" then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("shareSuccess"), 30)
            end
        end
    end
    local title = platFormCfg.feedTitle
    if type(title) == type(table) then
        title = title[G_getCurChoseLanguage()]
    end
    local content = getlocal("feedDesc" .. (feedType or 1))
    if contentStr and contentStr ~= "" then
        content = contentStr
    end
    local picUrl = serverCfg.feedPicUrl.."feed" .. (feedType or 1) .. ".png?tt="..math.random(1, 10000)
    local gameUrl = ""
    if G_loginType == 1 then
        gameUrl = serverCfg.feedGameUrl.."?deeplink=tankwar"
    end
    
    if platCfg.platCfgShareInfoLinkUrl ~= nil then
        if platCfg.platCfgShareInfoLinkUrl[G_curPlatName()] ~= nil then
            gameUrl = platCfg.platCfgShareInfoLinkUrl[G_curPlatName()]
        end
    end
    
    if G_curPlatName() == "12" or G_curPlatName() == "androidzhongshouyouru" then
        content = content.."["..gameUrl.."]"
    end
    
    if G_isShowShareBtn() then --facebook平台
        
        if FBSdkHelper ~= nil then
            FBSdkHelper:postFeed(title, content, gameUrl, picUrl, sendFeedCallback)
        end
    end
end
--程序进入后台或回来时候调用的方法 参数 1：为进入后台 2：回到游戏
function G_enterBackgroundOrEnterForeground(type)
    if type == 1 then
        --playerVoApi:enterBack()
        print("enterBackground")
        print("进入后台时当前服务器时间：", base.serverTime)
        G_inBackgroundTs = G_getCurDeviceMillTime() / 1000
    elseif type == 2 then
        print("EnterForeground")
        print("回到游戏时当前服务器时间：", base.serverTime)
        
        --玩家切入后台时间超时，则回到登录页面重新登录并拉取最新的服务器列表
        if tonumber(base.curZoneID) == 1000 then --如果是测试1000服将过期时间改为1分钟
            G_backgroundOutTime = 3600
        else
            G_backgroundOutTime = 3600
        end
        local foregroundTs = G_getCurDeviceMillTime() / 1000
        if G_inBackgroundTs and (foregroundTs - G_inBackgroundTs) >= G_backgroundOutTime and loginScene.isShowing == false then
            local function backToLoginScene()
                if global.fastTickID ~= nil then
                    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(global.fastTickID)
                    global.fastTickID = nil
                end
                G_backToLoginScene(true) --返回登录页面
            end
            G_inBackgroundTs = nil
            global.fastTickID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(backToLoginScene, 1, false)
            do return end
        end
        G_inBackgroundTs = nil
        local openTime = meiridatiCfg.openTime[1][1] * 60 * 60 + meiridatiCfg.openTime[1][2] * 60
        if base.dailychoice == 1 and base.datiTime <= G_getWeeTs(base.datiTime) + openTime + 20 * (meiridatiCfg.choiceTime + meiridatiCfg.resultTime) and base.datiTime - (G_getWeeTs(base.datiTime) + openTime - meiridatiCfg.lastTime) >= 0 then
            local function callback(fn, data)
                local ret, sData = base:checkServerData(data)
            end
            socketHelper:dailyAnswerGetNowTime(callback)
        end
        
        if base.amap == 1 or tonumber(base.curZoneID) >= 900 then
            if (alienMinesVoApi:checkIsActive() == true and alienMinesVoApi:checkIsActive2() == true) then
                alienMinesVoApi:setallBaseVoExpireTime()
                alienMinesVoApi:setrefreshFlag(true)
                
            end
        end
        eventDispatcher:dispatchEvent("game.active", {active = true})
        
        -- 势力战（如果是战斗时间，并且调用过get，更新数据）
        if ltzdzFightApi then
            ltzdzFightApi:rSetTid()
            -- ltzdzFightApi:EnterForeground()
        end
        local outTimeUsedInPlaneData = 60--超1分钟刷新飞机数据，用于地图上飞机派出出后数据没有及时刷新使用
        if foregroundTs - outTimeUsedInPlaneData > outTimeUsedInPlaneData and loginScene.isShowing == false then
            if self.plane == 1 and planeVoApi and planeVoApi.planeGet then
                planeVoApi:planeGet()
            end
        end
        
    end
    
end
--同步军团数据
function G_getAlliance(callback, isWaitting)
    if global.hasAllianceFunc == false then
        do
            return
        end
    end
    if(base.isAllianceOpen == false or base.isAllianceOpen == 0)then
        if(callback)then
            callback()
        end
        do return end
    end
    local function acceptCallBack(fn, data)
        local ret, JsData = base:checkServerData(data)
        if ret == true then
            if callback then
                callback(fn, JsData)
            end
            if base.serverWarTeamSwitch == 1 then
                G_getServerCfgFromHttp(true)
                serverWarTeamVoApi:getWarInfo()
            end
            if base.localWarSwitch == 1 then
                if localWarVoApi and localWarVoApi.getApplyData then
                    localWarVoApi:getApplyData(nil, false)
                end
            end
            if(base.platWarSwitch == 1)then
                if(platWarVoApi and platWarVoApi.getWarInfo)then
                    G_getServerCfgFromHttp(true)
                    platWarVoApi:getWarInfo()
                end
            end
            if((G_curPlatName() == "androidarab" or G_curPlatName() == "0") and allianceVoApi:getSelfAlliance())then
                socketHelper:chatClanMsg(1)
            end
            if base.allianceCitySwitch == 1 and allianceVoApi:getSelfAlliance() and allianceCityVoApi:hasCity() == false then --请求军团城市的数据
                local function refreshMap()
                    if allianceCityVoApi:hasCity() == true then
                        allianceCityVoApi:refreshMyCity()
                    end
                end
                allianceCityVoApi:initCity(refreshMap, false)
            end
        end
    end
    local aid = nil;
    if allianceVoApi:getSelfAlliance() then
        aid = allianceVoApi:getSelfAlliance().aid
    end
    socketHelper:allianceGet(aid, base.allianceTime, acceptCallBack, isWaitting)
end
--获取活动配置数据
function G_getActiveList(callback)
    local function getList(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data.activelist ~= nil then
                activityVoApi:formatActivityListData(sData.data.activelist)
                dailyActivityVoApi:formatActivityListData(sData.data.activelist)
            end
            if(callback)then
                callback()
            end
            if base.heroSwitch == 1 then
                --请求英雄数据
                local function heroGetlistHandler(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        if base.he == 1 and sData and sData.data and sData.data.equip and heroEquipVoApi then
                            heroEquipVoApi:formatData(sData.data.equip)
                            heroEquipVoApi.ifNeedSendRequest = true
                        end
                        --请求战争塑像的数据
                        warStatueVoApi:initWarStatue(nil, false)
                    end
                end
                socketHelper:heroGetlist(heroGetlistHandler)
            end
            if acMemoryServerVoApi and activityVoApi:isStart(acMemoryServerVoApi:getAcVo()) and G_isMemoryServer() then
                acMemoryServerVoApi:requestInitData()
            end
        end
    end
    socketHelper:getActivityList(getList)
end
--CPP从lua获取数据
function G_getDataFromLua(jsonParam)
    local param = G_Json.decode(jsonParam);
    local result = "";
    
    deviceHelper:luaPrint(param["action"])
    
    if param["action"] == "getUserInfo" then
        result = G_getUserInfo();
    elseif param["action"] == "getLoginUrl" then
        local loginurl = G_getPlatFormLoginUrl()
        local logUrl = platCfg["platCfgLoginUrl"][G_curPlatName()]
        if logUrl ~= nil then
            loginurl = loginurl..logUrl
        end
        result = loginurl;
    elseif param["action"] == "getServerTime" then
        result = base.serverTime
    elseif param["action"] == "getPayUrl" then
        result = G_getPlatFormPayUrl();
    elseif param["action"] == "getCreatePayOrderUrl" then
        result = G_getCreatePayOrderUrl();
    elseif param["action"] == "changeServer" then
        base:changeServer()
        
    elseif param["action"] == "BDPushBind" then
        print("百度云推送开启成功! 数据: ", jsonParam)
        --[[
        如果action=BDPushBind
            "errorCode":errorCode
            "appid":appid
            "userId":userId
            "channelId":channelId
            其中errorCode为int，其他为string。errorCode为0表示成功。定点推送需要userId和 channelId
        ]]
        pushController:initSuccess(param)
    elseif param["action"] == "BDPushNoti" then
        print("")
        --[[
        如果action=BDPushNoti
            "title":title         ios此项为""
            "description":description
            "customContentString":customContentString
            所有参数为string，customContentString为json型字符串，键值由发送消息时填写的内容决定。
        ]]
        
    elseif param["action"] == "BDPushUnbind" then
        print("")
        --[[
        如果action=BDPushUnbind       IOS没有此action
            "errorCode":errorCode
            其中errorCode为int，其他为string。errorCode为0表示成功。
        ]]
    elseif param["action"] == "musicOn" then
        CCUserDefault:sharedUserDefault():setIntegerForKey("gameSettings_musicSetting", 2)
        CCUserDefault:sharedUserDefault():setIntegerForKey("gameSettings_effectSetting", 2)
        CCUserDefault:sharedUserDefault():flush()
        
    elseif param["action"] == "musicOff" then
        CCUserDefault:sharedUserDefault():setIntegerForKey("gameSettings_musicSetting", 1)
        CCUserDefault:sharedUserDefault():setIntegerForKey("gameSettings_effectSetting", 1)
        CCUserDefault:sharedUserDefault():flush()
    elseif(param["action"] == "traceback")then
        tracebackkkk()
    end
    return result;
end

--获取玩家回头天数
function G_getBackDay()
    local userRegdate = playerVoApi:getRegdate()
    local today0clock = G_getWeeTs(userRegdate)
    local nowDay = math.floor((base.serverTime - today0clock) / (60 * 60 * 24))
    return tonumber(nowDay)
end

function G_getUserInfo()
    local info = {};
    info["platformUserID"] = tostring(base.platformUserId); --用户的平台ID
    info["gameUserID"] = tostring(playerVoApi:getUid()); --用户的游戏内部ID
    info["lv"] = tostring(playerVoApi:getPlayerLevel()); --用户等级
    info["exp"] = tostring(playerVoApi:getPlayerExp()); --用户经验
    info["userName"] = tostring(playerVoApi:getPlayerName()); --用户名字
    info["energy"] = tostring(playerVoApi:getEnergy()); --用户能量
    info["gold"] = tostring(playerVoApi:getGems()); --用户金币数量
    info["honors"] = tostring(playerVoApi:getHonors()); --用户声望
    info["rank"] = tostring(playerVoApi:getRank()); --用户军衔
    info["vipLevel"] = tostring(playerVoApi:getVipLevel()); --用户的VIP等级
    info["power"] = tostring(playerVoApi:getPlayerPower()); --用户战力
    info["zoneID"] = tostring(base.curZoneID); --用户的服务器ID
    --东南亚特殊需求，服务器ID合服之后传原来的
    if(G_curPlatName() == "efunandroiddny" or G_curPlatName() == "efunandroiddnych" or G_curPlatName() == "4" or G_curPlatName() == "47" or G_curPlatName() == "1" or G_curPlatName() == "42")then
        if(base.curOldZoneID and tonumber(base.curOldZoneID) > 0 and base.curOldZoneID ~= base.curZoneID)then
            info["zoneID"] = tostring(base.curOldZoneID);
        end
    end
    info["zoneName"] = tostring(base.curZoneServerName); --用户的服务器名称
    info["inguide"] = tostring(newGuidMgr:isNewGuiding() == true and "1" or "0"); --是否新手引导
    info["backday"] = G_getBackDay() --用户回头
    info["isnew"] = tonumber((base.serverTime - tonumber(playerVoApi:getRegdate())) <= 4 and 1 or 0); --是否是新注册的用户
    info["regdate"] = tostring(playerVoApi:getRegdate())
    local infoJSON = G_Json.encode(info);
    return infoJSON;
end

--Android GooglePlaySuccess
function buyFromAndroidSuccess(data, signature, platform)
    deviceHelper:luaPrint("data:"..data)
    deviceHelper:luaPrint("signature:"..signature)
    
    local function callback(fn, data)
        deviceHelper:luaPrint("支付后台返回"..data)
        local sData = G_Json.decode(tostring(data))
        --    local success,Jdata=base:checkServerData(data)
        --    if success==true then
        --      if sData.error=="0" then
        local purchaseToken = sData.token -- Jdata.data.payment.token
        AppStorePayment:shared():finishPayForAndroid(purchaseToken, "", "", "", "")
        --      end
        --     end
    end
    
    local requestParmTB = {}
    
    requestParmTB["data"] = data
    requestParmTB["signature"] = signature
    
    socketHelper:userPaymentForAndroid(requestParmTB, platform, callback)
    return
end

function G_returnToLoginScene(data)
    base:changeServer()
end

function loginFromAndroid()
    
end

function ShowNOSpeed()
    local tsD = smallDialog:new()
    tsD:initSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("indexisSpeed"), nil, 4)
    
end
function ShowNOCancel()
    local tsD = smallDialog:new()
    tsD:initSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("indexisfinish"), nil, 4)
    
end

function G_getGuid()
    local str = deviceHelper:guid()
    local str1 = tostring(deviceHelper:getRandom())
    local str2 = tostring(deviceHelper:getRandom())
    local str3 = tostring(deviceHelper:getRandom())
    str = str..str1..str2..str3
    --return "QH_142899446"
    --return "62ACAE69-A21B-B6C9-7DF1-59D1B08CBAEF"
    return str
end

-- 供C++获取程序强制更新下载地址
function G_getUpdateUrl()
    return (serverCfg.updateurl == nil and "" or serverCfg.updateurl)
end

--平台登陆地址
function G_getPlatFormLoginUrl()
    if base.loginurl ~= nil then
        if G_curPlatName() == "1" then
            if base.loginurl == "http://tank-ky-cn.raysns.com/gucenter/kylogin.php?tokenKey=" then
                base.loginurl = "http://tank-ky-cn.raysns.com/tank_rayapi/index.php/ioskuaiyonglogin"
            end
        end
        return base.loginurl
    else
        return ""
    end
end

--平台登陆地址
function G_getPlatFormPayUrl()
    if base.payurl ~= nil then
        if G_curPlatName() == "5" then
            if base.payurl ~= "http://tank-fl-app.raysns.com/tank_rayapi/index.php/flappstorepay" then
                base.payurl = "http://tank-fl-app.raysns.com/tank_rayapi/index.php/flappstorepay"
            end
        end
        return base.payurl
    else
        return ""
    end
end
--创建订单地址
function G_getCreatePayOrderUrl()
    if base.orderurl ~= nil then
        return base.orderurl
    else
        return ""
    end
end

-- lua访问C++方法公共接口
function G_accessCPlusFunction(cjson)
    if PlatformManage ~= nil and PlatformManage:shared().AccessCPlusFromLua ~= nil then
        return PlatformManage:shared():AccessCPlusFromLua(cjson)
    end
end
-- C++ 访问lua 方法
function G_cPlusAccessFunction(cjson)
    
    local sData = G_Json.decode(tostring(cjson))
    if sData["action"] == "bindFacebookAccount" then
        local fbid = sData["fbid"]
        if platCfg.platRayJoyAccountPrefix[G_curPlatName()] ~= nil then
            fbid = platCfg.platRayJoyAccountPrefix[G_curPlatName()]["fb"]..fbid
        end
        G_bindUserACCount(fbid)
    elseif sData["action"] == "getPayCallBackUrl" then
        do
            return platCfg.platCfgCallbackurl[G_curPlatName()]
        end
    elseif(sData["action"] == "sendClanDataToGame")then
        local clanUserID = sData["data"]
        if(clanUserID and clanUserID ~= "")then
            base.clanUserID = clanUserID
            if(playerVoApi:getUid() and tonumber(playerVoApi:getUid()) > 0)then
                base:changeServer()
            end
        end
    elseif(sData["action"] == "bindEmail")then
        if(sData["data"] and tonumber(sData["data"]) == 1)then
            deviceHelper:luaPrint("绑定邮箱成功！")
            eventDispatcher:dispatchEvent("movga.bind.success")
        end
    end
end

--获取到平台好友
function G_onGetPlatformFriend(dataJson)
    friendVoApi:onGetFriendFromFB(dataJson)
end

--获取到自己的平台信息
function G_onGetMyPlatformInfo(dataJson)
    local data
    if(dataJson == nil or dataJson == "")then
        data = {}
    else
        data = G_Json.decode(dataJson)
    end
    playerVoApi:onGetPlatformInfo(data)
end
--存储服务器的配置字符串
function G_setServerCfg(str)
    CCUserDefault:sharedUserDefault():setStringForKey(G_local_svrcfg, str)
    CCUserDefault:sharedUserDefault():flush()
end

--获取存储服务器的配置字符串
function G_getServerCfg()
    return CCUserDefault:sharedUserDefault():getStringForKey(G_local_svrcfg)
end

function G_initAllServer()
    local istest = CCUserDefault:sharedUserDefault():getIntegerForKey("test_turntest")
    if platCfg.platCfgGetServerListFromServer[G_curPlatName()] ~= nil or istest == 1 then --需要从服务器获取配置的平台
        if G_getServerCfg() ~= "" then
            serverCfg.allserver = nil
            serverCfg.allserver = {}
            serverCfg.allChatServer = nil
            serverCfg.allChatServer = {}
            local svrCfgData = G_getServerCfg()
            
            local convert1str = {["qnmd001"] = "http:\/\/", ["dyd582"] = "tank", ["fpb$3bn"] = ".com", ["rt39me"] = ".php", ["qn3mlgb"] = "raysns", ["klasdty"] = "1500", ["tyuotu"] = "300"}
            
            for k, v in pairs(convert1str) do
                svrCfgData = string.gsub(svrCfgData, k, v)
            end
            
            svrCfgData = G_Json.decode(svrCfgData)
            local countrySvrTb = svrCfgData[1]
            for k, v in pairs(countrySvrTb) do
                local tmpCountryTb = {}
                serverCfg.allserver[k] = tmpCountryTb
                for kk, vv in pairs(v) do --vv 拼成的字符串
                    local oneSvrTb = {}
                    
                    local parmTb = Split(vv, ",")
                    for pIndex = 1, #parmTb, 1 do
                        if pIndex == 1 then
                            oneSvrTb["name"] = parmTb[pIndex]
                        elseif pIndex == 2 then
                            oneSvrTb["userip"] = parmTb[pIndex]
                        elseif pIndex == 3 then
                            oneSvrTb["ip"] = parmTb[pIndex]
                        elseif pIndex == 4 then
                            oneSvrTb["port"] = parmTb[pIndex]
                        elseif pIndex == 5 then
                            oneSvrTb["zoneid"] = parmTb[pIndex]
                        elseif pIndex == 6 then
                            oneSvrTb["domain"] = parmTb[pIndex]
                        elseif pIndex == 7 then
                            oneSvrTb["loginurl"] = parmTb[pIndex]
                        elseif pIndex == 8 then
                            oneSvrTb["payurl"] = parmTb[pIndex]
                        elseif pIndex == 9 then
                            oneSvrTb["orderurl"] = parmTb[pIndex]
                        elseif pIndex == 10 then
                            oneSvrTb["isnew"] = parmTb[pIndex]
                        elseif pIndex == 11 then
                            oneSvrTb["oldzoneid"] = parmTb[pIndex]
                        elseif pIndex == 12 then --怀旧服入口机域名，即gucenter的访问域名
                            oneSvrTb["msip"] = parmTb[pIndex]
                        elseif pIndex == 13 then --记录怀旧服所在的平台id，所有平台公用怀旧服。但各平台都会配置怀旧服数据
                            oneSvrTb["mspid"] = parmTb[pIndex]
                        elseif pIndex == 14 then --是否是怀旧服
                            oneSvrTb["MS"] = tonumber(parmTb[pIndex]) or 0
                        end
                    end
                    table.insert(tmpCountryTb, oneSvrTb)
                end
            end
            
            local chatSvrTb = svrCfgData[2]
            for k, v in pairs(chatSvrTb) do
                local tmpChatTb = {}
                serverCfg.allChatServer[k] = tmpChatTb
                
                for kk, vv in pairs(v) do --vv 拼成的字符串
                    local oneSvrTb = {}
                    local parmTb = Split(vv, ",")
                    for pIndex = 1, #parmTb, 1 do
                        if pIndex == 1 then
                            oneSvrTb["name"] = parmTb[pIndex]
                        elseif pIndex == 2 then
                            oneSvrTb["ip"] = parmTb[pIndex]
                        elseif pIndex == 3 then
                            oneSvrTb["port"] = parmTb[pIndex]
                        end
                    end
                    table.insert(tmpChatTb, oneSvrTb)
                end
            end
            serverMgr:init() --初始化一下服务器数据
        end
    end
end

function G_getServerCfgFromHttp(getall)
    local istest = CCUserDefault:sharedUserDefault():getIntegerForKey("test_turntest")
    if platCfg.platCfgGetServerListFromServer[G_curPlatName()] ~= nil or istest == 1 then --需要从服务器获取配置的平台
        if getall == false or base.getSvrConfigFromHttpSuccess == false then --本地没有存放数据，需要获取推荐服务器
            
            if CCUserDefault:sharedUserDefault():getIntegerForKey("test_turntest") == 1 then
                if string.find(serverCfg.svrCfgUrl, "getconfig_test") == nil then
                    serverCfg.svrCfgUrl = G_stringGsub(serverCfg.svrCfgUrl, "getconfig", "getconfig_test")
                end
            end
            local svrCfgData = ""
            local tmpTb = {}
            tmpTb["action"] = "getChannel"
            tmpTb["parms"] = {}
            
            local cjson = G_Json.encode(tmpTb)
            
            local tmpChannedId = G_accessCPlusFunction(cjson)
            if getall == false then
                local countryStr
                local platName = G_curPlatName()
                if(platName == "efunandroidtw" or platName == "3" or platName == "androidlongzhong" or platName == "14" or platName == "androidkunlun" or platName == "androidkunlunz" or platName == "0")then
                    countryStr = "global"
                else
                    countryStr = G_country
                end
                svrCfgData = G_sendHttpRequest(serverCfg.svrCfgUrl.."?country="..countryStr.."&plat="..G_curPlatName() .. "&pkg="..G_Version.."&chid="..tmpChannedId, "")
            else
                svrCfgData = G_sendHttpRequest(serverCfg.svrCfgUrl.."?plat="..G_curPlatName() .. "&pkg="..G_Version.."&chid="..tmpChannedId, "")
                if svrCfgData ~= "" then
                    base.getSvrConfigFromHttpSuccess = true
                end
            end
            print("∑∑svrCfgData", svrCfgData)
            if svrCfgData == "" then
                if(G_isIOS())then
                    require "luascript/script/componet/smallDialog2"
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("iosNetTip"), nil, 5)
                end
                do return false end
            end
            serverCfg.allserver = nil
            serverCfg.allserver = {}
            serverCfg.allChatServer = nil
            serverCfg.allChatServer = {}
            G_setServerCfg(svrCfgData)
        end
        if G_getServerCfg() ~= "" then
            serverCfg.allserver = nil
            serverCfg.allserver = {}
            serverCfg.realAllServer = {}
            serverCfg.allChatServer = nil
            serverCfg.allChatServer = {}
            svrCfgData = G_getServerCfg()
            
            local convert1str = {["qnmd001"] = "http:\/\/", ["dyd582"] = "tank", ["fpb$3bn"] = ".com", ["rt39me"] = ".php", ["qn3mlgb"] = "raysns", ["klasdty"] = "1500", ["tyuotu"] = "300"}
            
            for k, v in pairs(convert1str) do
                svrCfgData = string.gsub(svrCfgData, k, v)
            end
            
            svrCfgData = G_Json.decode(svrCfgData)
            local countrySvrTb = svrCfgData[1]
            
            for k, v in pairs(countrySvrTb) do
                local tmpCountryTb = {}
                serverCfg.allserver[k] = tmpCountryTb
                serverCfg.realAllServer[k] = {}
                for kk, vv in pairs(v) do --vv 拼成的字符串
                    local oneSvrTb = {}
                    
                    local parmTb = Split(vv, ",")
                    for pIndex = 1, #parmTb, 1 do
                        if pIndex == 1 then
                            oneSvrTb["name"] = parmTb[pIndex]
                        elseif pIndex == 2 then
                            oneSvrTb["userip"] = parmTb[pIndex]
                        elseif pIndex == 3 then
                            oneSvrTb["ip"] = parmTb[pIndex]
                        elseif pIndex == 4 then
                            oneSvrTb["port"] = parmTb[pIndex]
                        elseif pIndex == 5 then
                            oneSvrTb["zoneid"] = tonumber(parmTb[pIndex])
                        elseif pIndex == 6 then
                            oneSvrTb["domain"] = parmTb[pIndex]
                        elseif pIndex == 7 then
                            oneSvrTb["loginurl"] = parmTb[pIndex]
                        elseif pIndex == 8 then
                            oneSvrTb["payurl"] = parmTb[pIndex]
                        elseif pIndex == 9 then
                            oneSvrTb["orderurl"] = parmTb[pIndex]
                        elseif pIndex == 10 then
                            oneSvrTb["isnew"] = parmTb[pIndex]
                        elseif pIndex == 11 then
                            oneSvrTb["oldzoneid"] = tonumber(parmTb[pIndex])
                        elseif pIndex == 12 then --怀旧服入口机域名，即gucenter的访问域名
                            oneSvrTb["msip"] = parmTb[pIndex]
                        elseif pIndex == 13 then --记录怀旧服所在的平台id，所有平台公用怀旧服。但各平台都会配置怀旧服数据
                            oneSvrTb["mspid"] = parmTb[pIndex]
                        elseif pIndex == 14 then --是否是怀旧服
                            oneSvrTb["MS"] = tonumber(parmTb[pIndex]) or 0
                        end
                    end
                    local isValidServer = true
                    if platCfg.platCfgSetStartServerAsFirst[G_curPlatName()] ~= nil then
                        local oldzoneid = tonumber(oneSvrTb["oldzoneid"])
                        if(oldzoneid and oldzoneid > 0 and oldzoneid ~= tonumber(oneSvrTb["zoneid"]))then
                            if oldzoneid < tonumber(platCfg.platCfgSetStartServerAsFirst[G_curPlatName()]) or (oldzoneid > 500 and oldzoneid < 700)then
                                isValidServer = false
                            end
                        else
                            if tonumber(oneSvrTb["zoneid"]) < tonumber(platCfg.platCfgSetStartServerAsFirst[G_curPlatName()]) or (tonumber(oneSvrTb["zoneid"]) > 500 and tonumber(oneSvrTb["zoneid"]) < 700)then
                                isValidServer = false
                            end
                        end
                    end
                    if isValidServer == true then
                        table.insert(tmpCountryTb, oneSvrTb)
                    end
                    table.insert(serverCfg.realAllServer[k], oneSvrTb)
                end
            end
            
            local chatSvrTb = svrCfgData[2]
            for k, v in pairs(chatSvrTb) do
                local tmpChatTb = {}
                serverCfg.allChatServer[k] = tmpChatTb
                
                for kk, vv in pairs(v) do --vv 拼成的字符串
                    local oneSvrTb = {}
                    local parmTb = Split(vv, ",")
                    for pIndex = 1, #parmTb, 1 do
                        if pIndex == 1 then
                            oneSvrTb["name"] = parmTb[pIndex]
                        elseif pIndex == 2 then
                            oneSvrTb["ip"] = parmTb[pIndex]
                        elseif pIndex == 3 then
                            oneSvrTb["port"] = parmTb[pIndex]
                        end
                    end  
                    table.insert(tmpChatTb, oneSvrTb)
                end
            end
            if svrCfgData[3] ~= nil and svrCfgData[3] ~= "" then
                base.gflogUrl = svrCfgData[3]
                CCUserDefault:sharedUserDefault():setStringForKey("tank_gunfulog", base.gflogUrl)
                CCUserDefault:sharedUserDefault():flush()
                
            end
            if svrCfgData[4] ~= nil and svrCfgData[4] ~= "" then
                base.kfzUrl = svrCfgData[4]
                CCUserDefault:sharedUserDefault():setStringForKey("tank_kfz_url", base.kfzUrl)
                CCUserDefault:sharedUserDefault():flush()
                
            end
            serverMgr:init() --初始化一下服务器数据
        end
    end
    return true
end

function G_getCurChoseLanguage()
    
    if G_language == "" then
        G_language =
        CCUserDefault:sharedUserDefault():getStringForKey(G_local_curLanguage)
    end
    return G_language
end

--全局函数 游戏拿到语言后需要先判定是否为法语，如果是法语，需要修改"LV." 这个变量
function G_LV()
    if G_getCurChoseLanguage() == "fr" then
        return G_FLV
    else
        return getlocal("uper_level") .. "."
    end
end

function G_bindUserACCount(pid)
    if pid == nil then
        pid = base.platformUserId
    end
    if(pid == nil or pid == "")then
        do return end
    end
    ------以下调用http绑定账号
    local ret, retTb
    if pid ~= base.platformUserId then
        local cuname = G_getTankUserName()
        local cuid = playerVoApi:getUid()
        
        local curlStr = serverCfg.baseUrl..serverCfg.serverBindCountUrl.."?uid="..cuid.."&username="..pid.."&password=123456" .. "&oldpassword="..G_getTankUserPassWord() .. "&oldusername="..cuname.."&zoneid="..base.curZoneID
        
        print("请求地址是什么", curlStr)
        local retData = G_sendHttpRequest(curlStr, "")
        if retData == "" then
            do
                return
            end
        end
        ret, retTb = base:checkServerData(retData, false)
    end
    if ret == nil then
        ret = true
        retTb = {["ret"] = 0}
    end
    if ret == true then
        
        print("http绑定请求成功")
        local result = retTb.ret
        if result == 0 then
            G_loginAccountType = 1
            G_setLocalTankUserName(pid)
            G_setLocalTankPwd("123456")
            if G_loginType == 2 then
                base.loginAccountType = 0
            end
            
            CCUserDefault:sharedUserDefault():setStringForKey("rayjoyAccountLastLoginType", 0)--记录最后一次登录的账号类型
            CCUserDefault:sharedUserDefault():flush()
            
            G_setTankIsguest("0")
            playerVoApi:setIsGuest("0")
            local function bindCallBack(fn, sdata)
                base:checkServerData(sdata)
                if G_curPlatName() == "5" or G_curPlatName() == "9" or G_curPlatName() == "45" then
                    CCUserDefault:sharedUserDefault():setStringForKey("isBindFL", "1");
                    CCUserDefault:sharedUserDefault():flush();
                    
                end
                smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("congratulation")..getlocal("bindSuccess", {getlocal("facebook")}), nil, 5)
            end
            socketHelper:bindingAccount(bindCallBack)
            
        end
        
    else --发生错误
        if G_loginType == 1 then --第三方账号
            if G_curPlatName() == "0" or G_curPlatName() == "2" or curPlatName() == "googleplay" then
                FBSdkHelper:exitLogin() --facebook
            end
        end
        do
            return
        end
    end
    ------以上调用http获取uid和token
end

function G_getDataTimeStr(time, withYear, withHour, deTimeFormat)
    do return G_getDateStr(time, withYear, withHour, nil, deTimeFormat) end

    local tab = os.date("*t", time)
    --获得time时间table，有year,month,day,hour,min,sec等元素。
    local function format(num)
        if num < 10 then
            return "0" .. num
        else
            return num
        end
    end
    local date = nil
    if platCfg.platShowtime[G_curPlatName()] ~= nil then
        if withHour == true then
            date = getlocal("scheduleChapter", {format(tab.day), format(tab.month)})
            if withYear == true then
                date = getlocal("year_time", {format(tab.day), format(tab.month), tab.year})
            end
        else
            if withYear == true then
                date = getlocal("note_time", {format(tab.day), format(tab.month), tab.year, format(tab.hour), format(tab.min)})
            else
                date = getlocal("day_time", {format(tab.day), format(tab.month), format(tab.hour), format(tab.min)})
            end
        end
    else
        if withHour == true then
            date = getlocal("scheduleChapter", {format(tab.month), format(tab.day)})
            if withYear == true then
                date = getlocal("year_time", {tab.year, format(tab.month), format(tab.day)})
            end
        else
            if withYear == true then
                date = getlocal("note_time", {tab.year, format(tab.month), format(tab.day), format(tab.hour), format(tab.min)})
            else
                date = getlocal("day_time", {format(tab.month), format(tab.day), format(tab.hour), format(tab.min)})
            end
        end
    end
    return date
end
function G_getRewardTime(time, num)
    local timer = time + num
    local rechageTime = os.date("*t", timer)
    G_dayin(rechageTime)
    local function format(idx)
        if idx < 10 then
            return "0"..idx
        else
            return idx
        end
    end
    local data = nil
    if platCfg.platShowtime[G_curPlatName()] ~= nil then
        data = getlocal("day_time", {format(rechageTime.day), format(rechageTime.month), format(rechageTime.hour), format(rechageTime.min)})
    else
        data = getlocal("day_time", {format(rechageTime.month), format(rechageTime.day), format(rechageTime.hour), format(rechageTime.min)})
    end
    return data
end
function G_getTimeStr(time, type)
    local shi = math.floor(time / 3600)
    local fen = math.floor(time % 3600 / 60)
    if(fen < 10)then
        fen = "0"..tostring(fen)
    end
    local miao = math.floor(time % 60)
    if(miao < 10)then
        miao = "0"..tostring(miao)
    end
    if(shi < 10)then
        shi = "0"..tostring(shi)
    end
    local str = getlocal("timeLabel", {shi, fen, miao})
    if type == 1 then
        str = getlocal("timeLabel2", {fen, miao})
    elseif type == 2 then
        str = getlocal("timeLabel2", {shi, fen})
    end
    return str
end

function G_getCountdownTimeStr(time)
    local day, shi, fen, sec = 0, 0, 0, 0
    local tmpTs = time
    day = math.floor(time / (3600 * 24))
    tmpTs = tmpTs - (day * 3600 * 24)
    shi = math.floor(tmpTs / 3600)
    tmpTs = tmpTs - (shi * 3600)
    fen = math.floor(tmpTs / 60)
    tmpTs = tmpTs - (fen * 60)
    sec = tmpTs
    
    local function formatStr(timeUnit, timeStr, type)
        -- if timeUnit>0 then
        if timeUnit < 10 then
            timeUnit = "0"..tostring(timeUnit)
        end
        local str = ""
        if type == 1 then
            str = getlocal("second_num", {timeUnit})
        elseif type == 2 then
            str = getlocal("minute_num", {timeUnit})
        elseif type == 3 then
            str = getlocal("hour_num", {timeUnit})
        elseif type == 4 then
            str = getlocal("day_num", {timeUnit})
        end
        timeStr = timeStr..str
        -- end
        return timeStr
    end
    
    local timeStr = ""
    if day > 0 then
        timeStr = formatStr(day, timeStr, 4)
        timeStr = formatStr(shi, timeStr, 3)
        timeStr = formatStr(fen, timeStr, 2)
        timeStr = formatStr(sec, timeStr, 1)
    elseif shi > 0 then
        timeStr = formatStr(shi, timeStr, 3)
        timeStr = formatStr(fen, timeStr, 2)
        timeStr = formatStr(sec, timeStr, 1)
    elseif fen > 0 then
        timeStr = formatStr(fen, timeStr, 2)
        timeStr = formatStr(sec, timeStr, 1)
    else
        timeStr = formatStr(sec, timeStr, 1)
    end
    
    return timeStr
end

function G_checkEmjoy(str)
    if platCfg.platCfgCheckEmoji[G_curPlatName()] ~= nil then
        local retstr = G_sendHttpRequest(serverCfg.checkEmojiUrl.."?text="..str, "")
        if tonumber(retstr) == 0 then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("checkEmjoy"), true, 20)
            
            do
                return false
            end
        end
    end
    
    return true
end
function G_onSendAppRequest(jsonParam)
    friendVoApi:onSendAppRequest(jsonParam);
end
function G_getInviteFriendReward(jsonParam)
    friendVoApi:getInviteFriendReward(jsonParam);
end

--保留几位小数
function G_keepNumber(number, digital)
    if number then
        if digital == nil then
            digital = 2
        end
        local intNum, decNum = math.modf(tonumber(number))
        decNum = string.format("%0."..digital.."f", decNum)
        local num = tonumber(intNum) + tonumber(decNum)
        return num
    end
    return number
end

--滚动动画显示文本 --infeedOrVertical 1 横向或是2 竖向滚动，isLoop 是否循环滚动,isBold 是否加粗
function G_LabelRollView(size, content, textSize, kCCTextAlignment, color, setAnchorY, content2, color2, stayTime, rollTime, infeedOrVertical, isLoop, isBold)
    local cellHeight
    local descLb, descLb2, boldStr
    local posUp, posDown
    local change
    if kCCTextAlignment == nil then
        kCCTextAlignment = kCCTextAlignmentCenter
    end
    if isBold then
        boldStr = "Helvetica-bold"
    end
    local function eventHandler(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return 1
        elseif fn == "tableCellSizeForIndex" then
            local tmpSize
            if cellHeight == nil then
                local descLb2 = GetTTFLabelWrap(content, textSize, CCSizeMake(size.width, 0), kCCTextAlignment, kCCVerticalTextAlignmentCenter, boldStr)
                cellHeight = descLb2:getContentSize().height
            end
            tmpSize = CCSizeMake(size.width, cellHeight)
            return tmpSize
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            local showLayer = CCLayer:create()
            showLayer:setPosition(ccp(0, 0))
            showLayer:setContentSize(CCSizeMake(size.width, size.height))
            cell:addChild(showLayer)
            if cellHeight == nil then
                local descLb1 = GetTTFLabelWrap(content, textSize, CCSizeMake(size.width, 0), kCCTextAlignment, kCCVerticalTextAlignmentCenter, boldStr)
                cellHeight = descLb1:getContentSize().height
            end
            
            local posX = size.width / 2
            local posY = size.height / 2
            local anchorX = 0.5
            local anchorY = 0.5
            if setAnchorY then
                anchorY = setAnchorY
            end
            local kCCVerticalTextAlignment = kCCVerticalTextAlignmentCenter
            if cellHeight < size.height then
                cellHeight = size.height
            elseif cellHeight > size.height then
                anchorY = 1
                posY = cellHeight - 5
                kCCVerticalTextAlignment = kCCVerticalTextAlignmentTop
            end
            descLb = GetTTFLabelWrap(content, textSize, CCSizeMake(size.width, 0), kCCTextAlignment, kCCVerticalTextAlignment, boldStr)
            if kCCTextAlignment == kCCTextAlignmentCenter then
                anchorX = 0.5
                posX = size.width / 2
            elseif kCCTextAlignment == kCCTextAlignmentLeft then
                anchorX = 0
                posX = 0
            elseif kCCTextAlignment == kCCTextAlignmentRight then
                anchorX = 1
                posX = size.width
            end
            descLb:setAnchorPoint(ccp(anchorX, anchorY))
            descLb:setPosition(ccp(posX, posY))
            showLayer:addChild(descLb, 2)
            if color then
                descLb:setColor(color)
            end
            
            if content2 then
                descLb2 = GetTTFLabelWrap(content2, textSize, CCSizeMake(size.width, 0), kCCTextAlignment, kCCVerticalTextAlignment, boldStr)
                descLb2:setAnchorPoint(ccp(anchorX, anchorY))
                showLayer:addChild(descLb2, 2)
                if color2 then
                    descLb2:setColor(color2)
                end
            end
            local moveBy, setOrigin
            if infeedOrVertical == 1 then --拿到横竖滚动前后的坐标位置
                posUp = posX - size.width
                posDown = posX + size.width * 0.5
                descLb2:setPosition(ccp(posUp, posY))
                moveBy = CCMoveBy:create(rollTime, ccp(posDown, 0))
                setOrigin = ccp(posUp, size.height)
            elseif infeedOrVertical == 2 then
                posUp = posY - size.height
                posDown = posY + size.height * 0.5
                descLb2:setPosition(ccp(posX, posUp))
                moveBy = CCMoveBy:create(rollTime, ccp(0, posDown))
                setOrigin = ccp(size.width, posUp)
            end
            
            local function callgo(idx)
                
                if infeedOrVertical == 1 then
                    posUp = posUp - size.width * 2
                    setOrigin = ccp(posUp, posY)
                elseif infeedOrVertical == 2 then
                    posUp = posUp - size.height
                    setOrigin = ccp(posX, posUp)
                end
                if idx == 1 then
                    descLb:setPosition(setOrigin)
                elseif idx == 2 then
                    descLb2:setPosition(setOrigin)
                end
            end
            change = 1
            local function callFirst(...)
                
                callgo(change)
                if change == 1 then
                    change = 2
                else
                    change = 1
                end
            end
            local callFunc1 = CCCallFunc:create(callFirst)
            local delayTime = CCDelayTime:create(stayTime)
            local delayTime2 = CCDelayTime:create(stayTime + 1)
            local acArr = CCArray:create()
            acArr:addObject(delayTime)
            acArr:addObject(moveBy)
            local spawn = CCSpawn:create(acArr)
            local acArr2 = CCArray:create()
            acArr2:addObject(delayTime2)
            acArr2:addObject(callFunc1)
            local spawn2 = CCSpawn:create(acArr2)
            local seq = CCSequence:createWithTwoActions(spawn, spawn2)
            showLayer:runAction(CCRepeatForever:create(seq))
            return cell
        elseif fn == "ccTouchBegan" then
            -- self.isMoved=false
            return true
        elseif fn == "ccTouchMoved" then
            -- self.isMoved=true
        elseif fn == "ccTouchEnded" then
            
        end
    end
    
    local function callBack(...)
        return eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    local tv = LuaCCTableView:createWithEventHandler(hd, size, nil)
    return tv, descLb, descLb2
end
--一个文本的tableview
function G_LabelTableView(size, content, textSize, alignment, color)
    local cellHeight
    local descLb
    -- if alignment==nil then
    --     alignment=kCCTextAlignmentCenter
    -- end
    local kCCTextAlignment = kCCTextAlignmentCenter
    if alignment and type(alignment) ~= "table" then
        kCCTextAlignment = alignment
    end
    local function eventHandler(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return 1
        elseif fn == "tableCellSizeForIndex" then
            local tmpSize
            if cellHeight == nil then
                if content and type(content) == "table" then
                    cellHeight = 0
                    for k, v in pairs(content) do
                        local descLb2 = GetTTFLabelWrap(v, textSize, CCSizeMake(size.width, 0), kCCTextAlignment, kCCVerticalTextAlignmentCenter)
                        cellHeight = cellHeight + descLb2:getContentSize().height + 5
                    end
                    cellHeight = cellHeight + 30
                else
                    local descLb2 = GetTTFLabelWrap(content, textSize, CCSizeMake(size.width, 0), kCCTextAlignment, kCCVerticalTextAlignmentCenter)
                    cellHeight = descLb2:getContentSize().height + 30
                end
            end
            tmpSize = CCSizeMake(size.width, cellHeight)
            return tmpSize
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            
            local posYTab = {}
            local heiTab = {}
            if cellHeight == nil then
                if content and type(content) == "table" then
                    cellHeight = 0
                    for k, v in pairs(content) do
                        if alignment and type(alignment) == "table" and alignment[k] then
                            kCCTextAlignment = alignment[k]
                            -- else
                            --     kCCTextAlignment=kCCTextAlignmentCenter
                        end
                        local descLb1 = GetTTFLabelWrap(v, textSize, CCSizeMake(size.width, 0), kCCTextAlignment, kCCVerticalTextAlignmentCenter)
                        cellHeight = cellHeight + descLb1:getContentSize().height + 5
                    end
                    cellHeight = cellHeight + 30
                else
                    local descLb1 = GetTTFLabelWrap(content, textSize, CCSizeMake(size.width, 0), kCCTextAlignment, kCCVerticalTextAlignmentCenter)
                    cellHeight = descLb1:getContentSize().height + 30
                end
            end
            if content and type(content) == "table" then
                for k, v in pairs(content) do
                    if alignment and type(alignment) == "table" and alignment[k] then
                        kCCTextAlignment = alignment[k]
                        -- else
                        --     kCCTextAlignment=kCCTextAlignmentCenter
                    end
                    local tempLb = GetTTFLabelWrap(v, textSize, CCSizeMake(size.width, 0), kCCTextAlignment, kCCVerticalTextAlignmentCenter)
                    table.insert(heiTab, tempLb:getContentSize().height)
                end
            end
            
            local posX = size.width / 2
            local posY = size.height / 2
            local anchorX = 0.5
            local anchorY = 0.5
            local kCCVerticalTextAlignment = kCCVerticalTextAlignmentCenter
            if cellHeight < size.height then
                if heiTab and SizeOfTable(heiTab) > 0 then
                    local py
                    for k, v in pairs(heiTab) do
                        if py == nil then
                            py = size.height / 2 + (cellHeight - 30 - 5) / 2 - v / 2
                        else
                            py = py - v / 2 - 5
                        end
                        table.insert(posYTab, py)
                        py = py - v / 2
                    end
                end
                cellHeight = size.height
            elseif cellHeight > size.height then
                anchorY = 1
                posY = cellHeight - 5
                kCCVerticalTextAlignment = kCCVerticalTextAlignmentTop
                if heiTab and SizeOfTable(heiTab) > 0 then
                    local py
                    for k, v in pairs(heiTab) do
                        if py == nil then
                            py = posY
                        else
                            -- py=py-v-5
                        end
                        table.insert(posYTab, py)
                        py = py - v - 5
                    end
                end
            end
            if kCCTextAlignment == kCCTextAlignmentCenter then
                anchorX = 0.5
                posX = size.width / 2
            elseif kCCTextAlignment == kCCTextAlignmentLeft then
                anchorX = 0
                posX = 0
            elseif kCCTextAlignment == kCCTextAlignmentRight then
                anchorX = 1
                posX = size.width
            end
            if content and type(content) == "table" then
                for k, v in pairs(content) do
                    if alignment and type(alignment) == "table" and alignment[k] then
                        kCCTextAlignment = alignment[k]
                        -- else
                        --     kCCTextAlignment=kCCTextAlignmentCenter
                    end
                    local descLb3 = GetTTFLabelWrap(v, textSize, CCSizeMake(size.width, 0), kCCTextAlignment, kCCVerticalTextAlignment)
                    descLb3:setAnchorPoint(ccp(anchorX, anchorY))
                    if posYTab and posYTab[k] then
                        posY = posYTab[k]
                    end
                    descLb3:setPosition(ccp(posX, posY))
                    cell:addChild(descLb3, 2)
                    if color then
                        if type(color) == "table" and color[k] then
                            descLb3:setColor(color[k])
                        else
                            descLb3:setColor(color)
                        end
                    end
                end
            else
                descLb = GetTTFLabelWrap(content, textSize, CCSizeMake(size.width, 0), kCCTextAlignment, kCCVerticalTextAlignment)
                descLb:setAnchorPoint(ccp(anchorX, anchorY))
                descLb:setPosition(ccp(posX, posY))
                cell:addChild(descLb, 2)
                if color then
                    descLb:setColor(color)
                end
            end
            
            return cell
        elseif fn == "ccTouchBegan" then
            -- self.isMoved=false
            return true
        elseif fn == "ccTouchMoved" then
            -- self.isMoved=true
        elseif fn == "ccTouchEnded" then
            
        end
    end
    
    local function callBack(...)
        return eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    local tv = LuaCCTableView:createWithEventHandler(hd, size, nil)
    return tv, descLb
end

--任务跳转,taskCfg 一条任务的配置
function G_taskJumpTo(taskCfg, taskDialog)
    local taskVo = taskCfg
    if taskVo == nil or SizeOfTable(taskVo) == 0 then
        do return end
    end
    local group = tonumber(taskVo.group)
    local dlayerNum = 3
    
    -- if gloIndex==nil then
    --  gloIndex=0
    -- end
    -- gloIndex=gloIndex+1
    -- group=(gloIndex%21)
    -- if group==0 then
    --  group=21
    -- end
    -- group=6
    -- print("group",group)
    -- group: 1,3:世界地图 2:关卡界面 4,5,30:玩家信息 6:指挥中心 7:水晶工厂 8:铁矿场 9:油井 10:铅矿场 11:钛矿场 12,32:科技中心 13:仓库 14,15,16,17,18:坦克工厂 19,20,21:郊外场景 22,23:配件 24:竞技场 25,26,27:军团 28:充值 29:每日高级抽奖 31:商店 40:将领招募 41:装备探索 42,43:超级武器 44:远征 45:军徽
    local delayTime
    local isShowPoint = true
    if group == 1 or group == 3 then
        --世界地图
        if mainUI:changeToWorld() == true then
            if taskDialog then
                taskDialog:close()
            end
        end
    elseif group == 2 then
        --关卡界面，板子
        storyScene:setShow()
        dlayerNum = dlayerNum + 1
        local sid = checkPointVoApi:getUnlockNum()
        require "luascript/script/game/scene/gamedialog/checkPointDialog"
        local cpd = checkPointDialog:new(sid)
        storyScene.checkPointDialog[1] = cpd
        local cd = cpd:init("panelBg.png", true, CCSizeMake(768, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, getlocal("checkPoint"), true, dlayerNum)
        sceneGame:addChild(cd, dlayerNum)
        if taskDialog then
            taskDialog:close()
        end
    elseif group == 4 or group == 5 or group == 30 then
        --玩家信息
        if taskDialog then
            taskDialog:close()
        end
        -- local td=playerDialog:new(1,dlayerNum)
        -- local tbArr={getlocal("playerInfo"),getlocal("skillTab"),getlocal("buildingTab")}
        -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("playerRole"),true,dlayerNum)
        -- sceneGame:addChild(dialog,dlayerNum)
        local td = playerVoApi:showPlayerDialog(1, dlayerNum, nil, taskVo)
        if group == 30 then
            td:tabClick(2)
        else
            td:tabClick(0)
        end
    elseif group == 6 then
        --"指挥中心"
        if taskDialog then
            taskDialog:close()
        end
        require "luascript/script/game/scene/gamedialog/portbuilding/commanderCenterDialog"
        local bid = 1
        local bType = 7
        local buildVo = buildingVoApi:getBuildiingVoByBId(bid)
        local td = commanderCenterDialog:new(bid, isShowPoint)
        local bName = getlocal(buildingCfg[bType].buildName)
        local tbArr = {getlocal("building"), getlocal("shuoming")}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName.."("..G_LV()..buildVo.level..")", true, dlayerNum)
        sceneGame:addChild(dialog, dlayerNum)
    elseif group == 7 then
        --水晶工厂
        local bid = 2
        local bType = 5
        local buildVo = buildingVoApi:getBuildiingVoByBId(bid)
        if buildVo and buildVo.status >= 0 then
            if taskDialog then
                taskDialog:close()
            end
            local td = homeBuildUpgradeDialog:new(bid, isShowPoint)
            local tbArr = {getlocal("building")}
            local bName = getlocal(buildingCfg[bType].buildName)
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName.."("..G_LV()..buildVo.level..")", true, dlayerNum)
            sceneGame:addChild(dialog, dlayerNum)
        else
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("port_scene_building_tip_"..tostring(bid - 1)), 30)
            do return end
        end
    elseif group == 8 or group == 9 or group == 10 or group == 11 then
        local bType
        if group == 8 then --铁矿场
            bType = 1
        elseif group == 9 then --油井
            bType = 2
        elseif group == 10 then --铅矿场
            bType = 3
        elseif group == 11 then --钛矿场
            bType = 4
        end
        local reqCfg = taskVo.require
        local buildVo = buildingVoApi:getBuildingVoByLevel(bType)
        local bName = getlocal(buildingCfg[bType].buildName)
        if buildVo == nil and buildingVoApi:isHasEmptyPort() == false then
            -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("no_empty_port",{bName}),30)
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("no_empty_port", {bName}), nil, dlayerNum + 1)
            do return end
        end
        if taskDialog then
            taskDialog:close()
        end
        if reqCfg and (reqCfg[2] and reqCfg[2] == 1) then
            mainUI:changeToMainLand()
        elseif buildVo and buildVo.status > 0 then
            PlayEffect(audioCfg["build_audio_"..bType])
            local bid = buildVo.id
            local td = homeBuildUpgradeDialog:new(bid, isShowPoint)
            local tbArr = {getlocal("building")}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName.."("..G_LV()..buildVo.level..")", true)
            sceneGame:addChild(dialog, dlayerNum)
            table.insert(G_CheckMem, td)
        else
            mainUI:changeToMainLand()
        end
    elseif group == 12 or group == 32 then
        --"科技中心"
        local bid = 3
        local bType = 8
        local buildVo = buildingVoApi:getBuildiingVoByBId(bid)
        if buildVo and buildVo.status >= 0 then
            if taskDialog then
                taskDialog:close()
            end
            if group == 32 and buildVo.status > 0 then
                isShowPoint = false
            end
            require "luascript/script/game/scene/gamedialog/portbuilding/techCenterDialog"
            local td = techCenterDialog:new(bid, dlayerNum, nil, isShowPoint)
            local bName = getlocal(buildingCfg[bType].buildName)
            local tbArr = {getlocal("building"), getlocal("startResearch")}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName.."("..G_LV()..buildVo.level..")", true, dlayerNum)
            sceneGame:addChild(dialog, dlayerNum)
            if group == 32 and buildVo.status > 0 then
                td:tabClick(1)
            end
        else
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("port_scene_building_tip_"..tostring(bid - 1)), 30)
            do return end
        end
    elseif group == 13 then
        --仓库
        local bid = 4
        local bType = 10
        local buildVo = buildingVoApi:getBuildingVoByLevel(bType)
        local reqCfg = taskVo.require
        if reqCfg and reqCfg[1] and reqCfg[1] == 1 and reqCfg[2] and reqCfg[2] == 1 then
            bid = 4
        elseif reqCfg and reqCfg[1] and reqCfg[1] == 2 and reqCfg[2] and reqCfg[2] == 1 then
            if bid == 4 then
                bid = 5
            elseif bid == 5 then
                bid = 4
            end
        elseif buildVo then
            bid = buildVo.id
        end
        if buildVo == nil then
            buildVo = buildingVoApi:getBuildiingVoByBId(bid)
        end
        if bid and buildVo and buildVo.status >= 0 then
            if taskDialog then
                taskDialog:close()
            end
            local td = homeBuildUpgradeDialog:new(bid, isShowPoint)
            local tbArr = {getlocal("building")}
            local bName = getlocal(buildingCfg[bType].buildName)
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName.."("..G_LV()..buildVo.level..")", true, dlayerNum)
            sceneGame:addChild(dialog, dlayerNum)
        elseif bid then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("port_scene_building_tip_"..tostring(bid - 1)), 30)
            do return end
        end
    elseif group == 14 or group == 15 or group == 16 or group == 17 or group == 18 then
        --“坦克工厂”
        local bid = 11
        local bType = 6
        local buildVo = buildingVoApi:getBuildingVoByLevel(bType)
        local reqCfg = taskVo.require
        if reqCfg and reqCfg[1] and reqCfg[1] == 1 and reqCfg[2] and reqCfg[2] == 1 then
            bid = 11
        elseif reqCfg and reqCfg[1] and reqCfg[1] == 2 and reqCfg[2] and reqCfg[2] == 1 then
            bid = 12
        elseif buildVo then
            bid = buildVo.id
        end
        if buildVo == nil then
            buildVo = buildingVoApi:getBuildiingVoByBId(bid)
        end
        if bid and buildVo and buildVo.status >= 0 then
            if taskDialog then
                taskDialog:close()
            end
            if group ~= 14 and buildVo.status > 0 then
                isShowPoint = false
            end
            require "luascript/script/game/scene/gamedialog/portbuilding/tankFactoryDialog"
            local td = tankFactoryDialog:new(bid, dlayerNum, nil, isShowPoint, taskVo)
            local bName = getlocal(buildingCfg[bType].buildName)
            local tbArr = {getlocal("buildingTab"), getlocal("startProduce"), getlocal("chuanwu_scene_process")}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName.."("..G_LV()..buildVo.level..")", true, dlayerNum)
            if group == 14 or buildVo.status == 0 then
            else
                td:tabClick(1)
            end
            sceneGame:addChild(dialog, dlayerNum)
        elseif bid then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("port_scene_building_tip_"..tostring(bid - 1)), 30)
            do return end
        end
    elseif group == 19 or group == 20 or group == 21 then
        --郊外场景
        if taskDialog then
            taskDialog:close()
        end
        mainUI:changeToMainLand()
    elseif group == 22 then
        --配件
        if base.ifAccessoryOpen == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage6004"), 30)
            do return end
        end
        if (playerVoApi:getPlayerLevel() < accessoryCfg.accessoryUnlockLv) then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("elite_challenge_unlock_level", {accessoryCfg.accessoryUnlockLv}), 30)
            do return end
        end
        if taskDialog then
            taskDialog:close()
        end
        accessoryVoApi:showAccessoryDialog(sceneGame, dlayerNum)
    elseif group == 23 then
        --配件
        if base.ifAccessoryOpen == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage6004"), 30)
            do return end
        end
        if (playerVoApi:getPlayerLevel() < accessoryCfg.accessoryUnlockLv) then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("elite_challenge_unlock_level", {accessoryCfg.accessoryUnlockLv}), 30)
            do return end
        end
        if taskDialog then
            taskDialog:close()
        end
        accessoryVoApi:showSupplyDialog(dlayerNum)
    elseif group == 24 then
        --竞技场
        G_openArenaDialog(dlayerNum, taskDialog)
    elseif group == 25 or group == 26 or group == 27 then
        --军团
        local bid = 1
        local bType = 7
        local buildVo = buildingVoApi:getBuildiingVoByBId(bid)
        if buildVo and buildVo.level < 5 then --指挥中心5级开放军团
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("port_scene_building_tip_6"), 30)
            do return end
        end
        if base.isAllianceSwitch == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alliance_willOpen"), 30)
            do return end
        end
        if group == 25 then --军团副本
            if base.isAllianceFubenSwitch == 0 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alliance_notOpen"), 30)
                do return end
            end
        elseif group == 26 then --军团科技
            if base.isAllianceSkillSwitch == 0 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alliance_notOpen"), 30)
                do return end
            end
        elseif group == 27 then --军团商店
            if base.ifAllianceShopOpen == 0 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alliance_notOpen"), 30)
                do return end
            end
        end
        if taskDialog then
            taskDialog:close()
        end
        if allianceVoApi:isHasAlliance() == false then
            require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialog"
            local td = allianceDialog:new(1, dlayerNum)
            G_AllianceDialogTb[1] = td
            local tbArr = {getlocal("alliance_list_scene_list"), getlocal("alliance_list_scene_create")}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("alliance_list_scene_name"), true, dlayerNum)
            sceneGame:addChild(dialog, dlayerNum)
        else
            -- allianceEventVoApi:clear()
            -- local td=allianceExistDialog:new(1,dlayerNum)
            -- G_AllianceDialogTb[1]=td
            -- local tbArr={getlocal("alliance_info_title"),getlocal("alliance_function"),getlocal("alliance_list_scene_list")}
            -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,dlayerNum)
            -- sceneGame:addChild(dialog,dlayerNum)
            -- if group==25 then --军团副本
            --     local td=allianceFuDialog:new(dlayerNum)
            --     local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("alliance_duplicate"),true,dlayerNum)
            --     sceneGame:addChild(dialog,dlayerNum)
            -- elseif group==26 then --军团科技
            --     require "luascript/script/game/scene/gamedialog/allianceDialog/allianceSkillDialog"
            --     local td=allianceSkillDialog:new(dlayerNum)
            --     local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("alliance_technology"),true,dlayerNum)
            --     sceneGame:addChild(dialog,dlayerNum)
            -- elseif group==27 then --军团商店
            --     allianceShopVoApi:showShopDialog(dlayerNum)
            -- end
            if group == 25 then
                allianceVoApi:showAllianceDialog(dlayerNum, "alliance_duplicate")
            elseif group == 26 then
                allianceVoApi:showAllianceDialog(dlayerNum, "alliance_technology")
            elseif group == 27 then
                allianceVoApi:showAllianceDialog(dlayerNum, "allianceShop")
            end
        end
    elseif group == 28 then
        --充值
        if taskDialog then
            taskDialog:close()
        end
        vipVoApi:showRechargeDialog(dlayerNum + 1)
    elseif group == 29 then
        --每日高级抽奖
        if(tonumber(base.curZoneID) > 900 and tonumber(base.curZoneID) < 1000)then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alliance_notOpen"), 30)
            do return end
        end
        if taskDialog then
            taskDialog:close()
        end
        if G_getBHVersion() == 1 then
            require "luascript/script/game/scene/gamedialog/dailyDialog"
            local dd = dailyDialog:new()
            local tbArr = {getlocal("lotteryCommon"), getlocal("lotterySenior")}
            local vd = dd:init("panelBg.png", true, CCSizeMake(768, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("daily_scene_title"), true, 3);
            sceneGame:addChild(vd, 3);
            dd:tabClick(1)
        elseif G_getBHVersion() == 2 then
            require "luascript/script/game/scene/gamedialog/dailyTwoDialog"
            local dd = dailyTwoDialog:new()
            local dailyTwo = dd:init("panelBg.png", true, CCSizeMake(768, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("dailyUseIt"), true, 3);
            sceneGame:addChild(dailyTwo, 3);
        end
        -- local dd = dailyDialog:new()
        -- local tbArr={getlocal("lotteryCommon"),getlocal("lotterySenior")}
        -- local vd = dd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("daily_scene_title"),true,dlayerNum);
        -- sceneGame:addChild(vd,dlayerNum)
        --dd:tabClick(1)
    elseif group == 31 then
        --商店
        if taskDialog then
            taskDialog:close()
        end
        -- local td=shopVoApi:showPropDialog(dlayerNum)
        -- td:tabClick(1,false)
        local td = allShopVoApi:showAllPropDialog(3, "gems")
    elseif group == 40 then
        --将领招募
        G_goToDialog("hero", dlayerNum, true, nil, "recruit")
    elseif group == 41 then
        --装备探索
        G_goToDialog("ht", dlayerNum + 1, true, nil, "equipExplore")
        delayTime = 1.2
    elseif group == 42 or group == 43 then
        --超级武器
        local subType
        if group == 42 and tonumber(taskVo.sid) == 1012 then --超级武器掠夺
            subType = "rob"
        elseif group == 43 and tonumber(taskVo.sid) == 1013 then --神秘组织
            subType = "challenge"
        end
        G_goToDialog("wp", dlayerNum, true, nil, subType)
        delayTime = 1.2
    elseif group == 44 then
        --远征
        if tonumber(taskVo.sid) == 1014 then
            G_goToDialog("eb", dlayerNum + 1, true, nil, "expedition")
        else
            G_goToDialog("eb", dlayerNum + 1, true)
        end
        delayTime = 0.6
    elseif group == 45 then
        --军徽
        G_goToDialog("emblem", dlayerNum, true, nil, "get")
    end
    
    local taskDesc = taskVoApi:getTaskInfoById(taskVo.sid, false)--true:name,false:desc
    if taskVo.type == 4 then
        taskDesc = taskVoApi:getTaskInfoById(taskVo.sid, false, true)
    end
    local taskDescLb = GetTTFLabelWrap(taskDesc, 25, CCSizeMake(580, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    local lbHeight = taskDescLb:getContentSize().height
    local tipHeight = 120
    if tipHeight < lbHeight + 60 then
        tipHeight = lbHeight + 60
    end
    local lbHeightPos = tipHeight / 2 + 10
    local stPosY = tipHeight / 2
    -- if base.allShowedCommonDialog==0 then
    --     stPosY=tipHeight/2+192
    --     tipDialog:showTipsBar(sceneGame,ccp(320,stPosY-tipHeight),ccp(320,stPosY),taskDesc,tipHeight,11,nil,2,G_ColorYellow,lbHeightPos)
    -- else
    --     tipDialog:showTipsBar(sceneGame,ccp(320,stPosY-tipHeight),ccp(320,stPosY),taskDesc,tipHeight,11,nil,2,G_ColorYellow,lbHeightPos)
    -- end
    -- 引导性的提示
    if group ~= 2 then --关卡型任务不做引导提示
        local clickRect
        local panelPos
        if group == 6 or group == 14 then --建造和升级指挥中心以及坦克工厂任务
            clickRect = newSkipCfg[group].clickRect
        elseif (group >= 7 and group <= 14) then --建造和升级普通建筑(铁矿场)
            
            local reqCfg = taskVo.require
            if (reqCfg and reqCfg[2] and tonumber(reqCfg[2]) == 1) and (group >= 8 and group <= 11) then
            else
                clickRect = newSkipCfg[group].clickRect
            end
        elseif group == 4 then --提升声望型任务
            
            clickRect = newSkipCfg[group].clickRect
            
        elseif group == 5 then --提升军衔型任务
            if G_isIphone5() == true then
                panelPos = ccp(10, 160)
            else
                panelPos = ccp(10, 40)
            end
        else
            clickRect = taskVo.clickRect
            panelPos = taskVo.panelPos
        end
        guideTipMgr:showGuideTipDialog(taskDesc, G_ColorYellow, 11, panelPos, clickRect, delayTime)
    end
end

function G_updateSelectTankLayer(type, layer, layerNum, isShowTank, tankTb, heroTb, emblemId, planePos, aitroops, airShipId)
    
    if G_editLayer[type] ~= nil then
        G_editLayer[type]:updateSelect(type, layer, layerNum, isShowTank, tankTb, heroTb, emblemId, planePos, aitroops, airShipId)
        do return end
    end
    
    for i = 1, 6, 1 do
        local node = tolua.cast(layer:getChildByTag(i), "CCNode")
        local spA = node:getChildByTag(2)
        if spA ~= nil then
            spA:removeFromParentAndCleanup(true)
        end
        local node = tolua.cast(layer:getChildByTag(i * 10), "CCNode")
        local spB = node:getChildByTag(2)
        if spB ~= nil then
            spB:removeFromParentAndCleanup(true)
        end
        
    end
    local tankTab = tankVoApi:getTanksTbByType(type)
    if tankTb then
        tankTab = tankTb
    end
    for k, v in pairs(tankTab) do
        local heroSp = tolua.cast(layer:getChildByTag(k * 10), "CCNode")
        local tankLb = tolua.cast(heroSp:getChildByTag(100 + k), "CCLabelTTF")
        if tankLb then
            tankLb:setString(getlocal("fight_content_null"))
        end
        
        local sp = layer:getChildByTag(k)
        if v[1] ~= nil and v[2] ~= nil then
            G_addTouchSp(type, sp, v[1], v[2], layerNum, layer, isShowTank)
            
            if tankLb then
                local id = v[1]
                local num = v[2]
                local tId = (tonumber(id) or tonumber(RemoveFirstChar(id)))
                local tankStr = getlocal("item_type_number", {getlocal(tankCfg[tId].name), num})
                tankStr = G_getPointStr(tankStr, heroSp:getContentSize().width * 0.9, 20)
                tankLb:setString(tankStr)
            end
        end
    end
    if type == 7 or type == 8 or type == 9 or type == 13 or type == 14 or type == 15 or type == 17 or type == 18 or type == 21 or type == 22 or type == 23 or (type >= 24 and type <= 29) or (type >= 31 and type <= 32) or type == 34 or heroTb then
        local heroTab
        if heroTb then
            heroTab = heroTb
        elseif type == 7 or type == 8 or type == 9 then
            heroTab = heroVoApi:getServerWarHeroList(type - 6)
        elseif type == 13 or type == 14 or type == 15 then
            heroTab = heroVoApi:getWorldWarHeroList(type - 12)
        elseif type == 17 then
            heroTab = heroVoApi:getLocalWarHeroList()
        elseif type == 18 then
            heroTab = heroVoApi:getLocalWarCurHeroList()
        elseif type == 21 or type == 22 or type == 23 then
            heroTab = heroVoApi:getPlatWarHeroList(type - 20)
        elseif type == 24 or type == 25 or type == 26 then
            heroTab = heroVoApi:getServerWarLocalHeroList(type - 23)
        elseif type == 27 or type == 28 or type == 29 then
            heroTab = heroVoApi:getServerWarLocalCurHeroList(type - 26)
        elseif type == 31 then
            heroTab = heroVoApi:getAllianceWar2CurHeroList()
        elseif type == 32 then
            heroTab = heroVoApi:getAllianceWar2HeroList()
        elseif type == 34 then
            heroTab = heroVoApi:getServerWarTeamCurHeroList()
        end
        heroVoApi:setTroopsByTb(heroTab)
        for k, v in pairs(heroTab) do
            local tankSp = layer:getChildByTag(k)
            local heroLb = tolua.cast(tankSp:getChildByTag(100 + k), "CCLabelTTF")
            if heroLb then
                heroLb:setString(getlocal("fight_content_null"))
            end
            local star = 5
            for i = 1, star do
                local starSize = 15
                local starSpace = starSize
                local starSp = tolua.cast(tankSp:getChildByTag(200 + i), "CCSprite")
                if starSp then
                    starSp:setVisible(false)
                end
            end
            
            local sp = layer:getChildByTag(k * 10)
            local hid = v
            if hid and hid ~= 0 then
                local hero = heroVoApi:getHeroByHid(hid)
                if hero then
                    G_addHeroTouchSp(type, sp, hid, hero.productOrder, layerNum, layer, isShowTank)
                    
                    if heroLb then
                        local heroName = ""
                        if heroListCfg[hero.hid] then
                            heroName = getlocal(heroListCfg[hero.hid].heroName)
                        end
                        local level = hero.level or 1
                        if heroName and heroName ~= "" then
                            local heroStr = getlocal("fightLevel", {level}) .. " "..heroName
                            heroStr = G_getPointStr(heroStr, tankSp:getContentSize().width * 0.9, 20)
                            heroLb:setString(heroStr)
                        end
                    end
                    
                    local productOrder = hero.productOrder or 1
                    local star = productOrder
                    for i = 1, star do
                        local starSize = 15
                        local starSpace = starSize
                        local starSp = tolua.cast(tankSp:getChildByTag(200 + i), "CCSprite")
                        if starSp then
                            local px = tankSp:getContentSize().width / 2 - starSpace / 2 * (star - 1) + starSpace * (i - 1)
                            local py = tankSp:getContentSize().height + 28 + starSize / 2
                            starSp:setPosition(ccp(px, py))
                            starSp:setVisible(true)
                        end
                    end
                end
            end
        end
    end
    
    if isShowTank == 1 then
        
    else
        for k = 1, 6 do
            local sp = layer:getChildByTag(k)
            local star = 5
            for i = 1, star do
                local starSize = 15
                local starSpace = starSize
                local starSp = tolua.cast(sp:getChildByTag(200 + i), "CCSprite")
                if starSp then
                    starSp:setVisible(false)
                end
            end
        end
    end
    
end

--打开竞技场面板
function G_openArenaDialog(layerNum, taskDialog)
    if base.ifMilitaryOpen == 0 then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("arena_noOpen"), 30)
        do
            return
        end
    end
    local limitLv = 10
    if playerVoApi:getPlayerLevel() < limitLv then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("arena_limit", {limitLv}), 30)
        do
            return
        end
    end
    if taskDialog then
        taskDialog:close()
    end
    if base.ma == 1 then
        arenaVoApi:showShamBattleDialog(layerNum + 1)
    else
        local td = arenaDialog:new()
        local tbArr = {getlocal("alliance_challenge_fight"), getlocal("fleetCard"), getlocal("mainRank")}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("arena_title"), true, layerNum)
        sceneGame:addChild(dialog, layerNum)
    end
    
end

--抽将领时展示英雄动画
--type：1.将领，2.魂魄，3.物品 4.装备研究所
--item：type为1和2是将领数据，type为3是物品数据
--heroIsExist：抽出的英雄是否已经存在
--newProductOrder 是否晋升高品阶
-- 装备研究所换底图
function G_recruitShowHero(type, item, layerNum, heroIsExist, addSoulNum, callback, newProductOrder, score, scenePic)
    local layer = CCLayer:create()
    sceneGame:addChild(layer, layerNum)
    local strSize2 = 30
    if G_getCurChoseLanguage() == "ru" then
        strSize2 = 25
    end
    local function callback()
        
    end
    local diPic = "story/CheckpointBg.jpg"
    if scenePic then
        diPic = scenePic
    end
    local sceneSp = LuaCCSprite:createWithFileName(diPic, callback)
    sceneSp:setAnchorPoint(ccp(0, 0))
    sceneSp:setPosition(ccp(0, 0))
    sceneSp:setTouchPriority(-(layerNum) * 20 - 1)
    layer:addChild(sceneSp)
    sceneSp:setColor(ccc3(150, 150, 150))
    
    if G_getIphoneType() == G_iphoneX then
        sceneSp:setScaleY(G_VisibleSizeHeight / sceneSp:getContentSize().height)
    elseif G_isIphone5() == true then
        sceneSp:setScaleY(1.2)
    end
    
    if scenePic then
        sceneSp:setScaleY(G_VisibleSizeHeight / sceneSp:getContentSize().height)
        sceneSp:setScaleX(G_VisibleSizeWidth / sceneSp:getContentSize().width)
    end
    
    local function callback1()
        local particleS = CCParticleSystemQuad:create("public/1.plist")
        particleS:setScale(1)
        particleS.positionType = kCCPositionTypeFree
        particleS:setPosition(ccp(320, G_VisibleSizeHeight / 2 + 100))
        layer:addChild(particleS, 10)
    end
    local function callback2()
        local mIcon
        if item.type == "h" then
            if item.eType == "h" then
                mIcon = heroVoApi:getHeroIcon(item.key, item.num, nil, nil, nil, nil, nil, {adjutants = {}})
            else
                mIcon = heroVoApi:getHeroIcon(item.key, 1, false)
            end
        else
            mIcon = G_getItemIcon(item, 100, false, layerNum)
        end
        if mIcon then
            local function callback3()
                local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
                -- local lightSp = CCSprite:createWithSpriteFrameName("BgSelect.png")
                lightSp:setAnchorPoint(ccp(0.5, 0.5))
                lightSp:setPosition(ccp(320 + 7, G_VisibleSizeHeight / 2 + 100))
                layer:addChild(lightSp, 10)
                lightSp:setScale(2)
                
                local descStr = ""
                local nameStr = item.name or ""
                if item.type == "h" and item.eType == "h" then
                else
                    nameStr = nameStr.."x"..item.num
                end
                if type == 1 then
                    descStr = getlocal("getNewHeroDesc")
                elseif type == 2 then
                    descStr = getlocal("getNewSoulDesc")
                elseif type == 4 then
                    local propKey = heroEquipAwakeShopCfg.buyitem
                    local name, pic, desc = getItem(propKey, "p")
                    descStr = getlocal("equip_getReward", {name .. "*" .. 1})
                else
                    descStr = getlocal("getNewPropDesc")
                end
                local lb = GetTTFLabelWrap(descStr, 24, CCSizeMake(500, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                lb:setPosition(ccp(320, G_VisibleSizeHeight - 150))
                lb:setColor(G_ColorYellowPro)
                layer:addChild(lb, 11)
                
                local nameLb = GetTTFLabel(nameStr, 24)
                nameLb:setPosition(ccp(320, G_VisibleSizeHeight / 2 - 80))
                nameLb:setColor(G_ColorYellowPro)
                layer:addChild(nameLb, 11)
                
                if addSoulNum and addSoulNum > 0 then
                    local hid
                    if item.type == "h" then
                        if item.eType == "h" then
                            hid = item.key
                        elseif item.eType == "s" then
                            hid = heroCfg.soul2hero[item.key]
                        end
                    end
                    local existStr = ""
                    if hid and heroVoApi:getIsHonored(hid) == true and heroVoApi:heroHonorIsOpen() == true then
                        existStr = getlocal("hero_honor_recruit_honored_hero", {addSoulNum})
                    elseif type == 1 and heroIsExist == true then
                        if newProductOrder then
                            existStr = getlocal("hero_breakthrough_desc", {newProductOrder})
                        else
                            existStr = getlocal("alreadyHasDesc", {addSoulNum})
                        end
                    end
                    if existStr and existStr ~= "" then
                        local existLb = GetTTFLabelWrap(existStr, 25, CCSizeMake(500, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                        existLb:setPosition(ccp(320, 300))
                        existLb:setColor(G_ColorYellowPro)
                        layer:addChild(existLb, 11)
                    end
                end
                if score and score ~= "" then
                    local scoreLb = GetTTFLabelWrap(getlocal("serverwar_get_point")..score, 28, CCSizeMake(500, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                    scoreLb:setPosition(ccp(320, 350))
                    scoreLb:setColor(G_ColorYellowPro)
                    layer:addChild(scoreLb, 777)
                end
                local function ok(...)
                    layer:removeFromParentAndCleanup(true)
                    if callback then
                        callback()
                    end
                end
                
                local okItem = GetButtonItem("LoadingSelectServerBtn.png", "LoadingSelectServerBtn_Down.png", "LoadingSelectServerBtn_Down.png", ok, nil, getlocal("confirm"), 24, 101)
                local btnLb = okItem:getChildByTag(101)
                if btnLb then
                    btnLb = tolua.cast(btnLb, "CCLabelTTF")
                    btnLb:setFontName("Helvetica-bold")
                end
                local okBtn = CCMenu:createWithItem(okItem)
                okBtn:setTouchPriority(-(layerNum) * 20 - 2)
                okBtn:setAnchorPoint(ccp(1, 0.5))
                okBtn:setPosition(ccp(320, 150))
                layer:addChild(okBtn, 11)
            end
            mIcon:setScale(0)
            mIcon:setPosition(ccp(320, G_VisibleSizeHeight / 2 + 100))
            layer:addChild(mIcon, 11)
            local ccScaleTo = CCScaleTo:create(0.6, 150 / mIcon:getContentSize().width)
            local ccScaleTo1 = CCScaleTo:create(0.1, (150 + 100) / mIcon:getContentSize().width)
            local ccScaleTo2 = CCScaleTo:create(0.1, 150 / mIcon:getContentSize().width)
            local callFunc3 = CCCallFunc:create(callback3)
            local acArr = CCArray:create()
            acArr:addObject(ccScaleTo)
            acArr:addObject(ccScaleTo1)
            acArr:addObject(ccScaleTo2)
            acArr:addObject(callFunc3)
            local seq = CCSequence:create(acArr)
            mIcon:runAction(seq)
        end
    end
    local callFunc1 = CCCallFunc:create(callback1)
    local callFunc2 = CCCallFunc:create(callback2)
    
    local delay = CCDelayTime:create(0.2)
    local acArr = CCArray:create()
    acArr:addObject(delay)
    acArr:addObject(callFunc1)
    acArr:addObject(callFunc2)
    local seq = CCSequence:create(acArr)
    sceneSp:runAction(seq)
    
end

-- addHeight：新军事演习，部队面板要修改的
-- isLandTab,notTouch,tPosY 新版设置部队需要参数：isLandTab：出征矿点数据，notTouch：不能点击，tPosY：需要自定高度位置
-- cid:领土争夺战需要用 （城市的防守部队）
function G_addSelectTankLayer(type, layer, layerNum, callback, isNotShowBestBtn, addHeight, isLandTab, notTouch, tPosY, cid)
    --print("G_addSelectTankLayer",type)
    --滑动选兵
    require "luascript/script/componet/editTroopsLayer"
    local editLayer = editTroopsLayer:new()
    editLayer:initLayer(type, layer, layerNum, callback, isLandTab, notTouch, tPosY, cid)
    G_editLayer[type] = editLayer
    do return end

    local tHeight = G_VisibleSize.height - 260
    local soldiersLbNum = nil
    if type == 4 then
        tHeight = G_VisibleSize.height - 380
    elseif type == 33 then
        tHeight = G_VisibleSize.height - 160
    end
    
    if type ~= 4 and type ~= 2 and type ~= 16 then
        
        local soldiersLb = GetTTFLabel(getlocal("player_leader_troop_num", {playerVoApi:getTroopsLvNum()}), 26);
        soldiersLb:setAnchorPoint(ccp(0, 0.5));
        soldiersLb:setPosition(ccp(110, tHeight));
        layer:addChild(soldiersLb, 2);
        
        soldiersLbNum = GetTTFLabel("+"..playerVoApi:getExtraTroopsNum(), 26);
        soldiersLbNum:setColor(G_ColorGreen)
        soldiersLbNum:setTag(414)
        soldiersLbNum:setAnchorPoint(ccp(0, 0.5));
        soldiersLbNum:setPosition(ccp(soldiersLb:getPositionX() + soldiersLb:getContentSize().width, tHeight));
        layer:addChild(soldiersLbNum, 2);
        
        if type == 10 then
            tHeight = tHeight + 50
        end
        if addHeight then
            soldiersLb:setPosition(ccp(50, tHeight + addHeight));
            soldiersLbNum:setPosition(ccp(soldiersLb:getPositionX() + soldiersLb:getContentSize().width, tHeight + addHeight));
        end
    end
    
    --最大战力
    local function touchBestFight()
        PlayEffect(audioCfg.mouseClick)
        if soldiersLbNum ~= nil then
            soldiersLbNum:setString("+"..playerVoApi:getExtraTroopsNum())
        end
        local function callback()
            if newGuidMgr:isNewGuiding() == true then
                newGuidMgr:toNextStep()
            end
            local maxTb, heroTb = tankVoApi:getBestTanks(type)
            for i = 1, 6, 1 do
                local spA = layer:getChildByTag(i):getChildByTag(2)
                if spA ~= nil then
                    tankVoApi:deleteTanksTbByType(type, i)
                    spA:removeFromParentAndCleanup(true)
                end
                --将领文字变成无
                heroVoApi:deletTroopsByPos(i, type)
                local tankSp = tolua.cast(layer:getChildByTag(i), "LuaCCSprite")
                local heroLb = tolua.cast(tankSp:getChildByTag(100 + i), "CCLabelTTF")
                if heroLb then
                    heroLb:setString(getlocal("fight_content_null"))
                end
                for i = 1, 5 do
                    if tankSp:getChildByTag(200 + i) then
                        local starSp = tolua.cast(tankSp:getChildByTag(200 + i), "CCSprite")
                        if starSp then
                            starSp:setVisible(false)
                        end
                    end
                end
            end
            for k, v in pairs(maxTb) do
                local sp = layer:getChildByTag(k)
                tankVoApi:setTanksByType(type, k, v[1], v[2])
                G_addTouchSp(type, sp, v[1], v[2], layerNum, layer, 1)
            end
            --将领文字变更
            for k, v in pairs(heroTb) do
                heroVoApi:setTroopsByPos(k, v, type)
                local hVo = heroVoApi:getHeroByHid(v)
                local tankSp = tolua.cast(layer:getChildByTag(k), "LuaCCSprite")
                local heroLb = tolua.cast(tankSp:getChildByTag(100 + k), "CCLabelTTF")
                local scale = 0.9
                if hVo then
                    local heroName = ""
                    if heroListCfg[hVo.hid] then
                        heroName = getlocal(heroListCfg[hVo.hid].heroName)
                    end
                    
                    local level = hVo.level or 1
                    local productOrder = hVo.productOrder or 1
                    if heroName and heroName ~= "" and heroLb then
                        local heroStr = getlocal("fightLevel", {level}) .. " "..heroName
                        heroStr = G_getPointStr(heroStr, tankSp:getContentSize().width * scale, 20)
                        heroLb:setString(heroStr)
                    end
                    
                    local star = productOrder
                    for i = 1, star do
                        local starSize = 15
                        local starSpace = starSize
                        local starSp = tolua.cast(tankSp:getChildByTag(200 + i), "CCSprite")
                        if starSp then
                            local px = tankSp:getContentSize().width / 2 - starSpace / 2 * (star - 1) + starSpace * (i - 1)
                            local py = tankSp:getContentSize().height + 28 + starSize / 2
                            starSp:setPosition(ccp(px, py))
                            starSp:setVisible(true)
                        end
                    end
                end
            end
            if type == 2 then
                local fleetload = FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(2)))
                local temLayer = tolua.cast(layer, "CCLayer")
                local fleetLb = temLayer:getChildByTag(19)
                fleetLb = tolua.cast(fleetLb, "CCLabelTTF")
                fleetLb:setString(getlocal("fleetload", {fleetload}))
            end
            if type == 16 then
                local fleetload = FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(16)))
                local temLayer = tolua.cast(layer, "CCLayer")
                local fleetLb = temLayer:getChildByTag(19)
                fleetLb = tolua.cast(fleetLb, "CCLabelTTF")
                fleetLb:setString(getlocal("fleetload", {fleetload}))
            end
        end
        local function onGetCheckpoint()
            callback()
        end
        local function onGetTech()
            local techFlag = checkPointVoApi:getTechFlag()
            if techFlag == -1 then
                local function challengeRewardlistCallback(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        onGetCheckpoint()
                        checkPointVoApi:setTechFlag(1)
                    end
                end
                socketHelper:challengeRewardlist(challengeRewardlistCallback)
            else
                onGetCheckpoint()
            end
        end
        local function onGetAccessory()
            local alienTechOpenLv = base.alienTechOpenLv or 22
            if base.alien == 1 and base.richMineOpen == 1 and alienTechVoApi and alienTechVoApi.getTechData and playerVoApi:getPlayerLevel() >= alienTechOpenLv then
                alienTechVoApi:getTechData(onGetTech)
            else
                onGetTech()
            end
        end
        if base.ifAccessoryOpen == 1 and accessoryVoApi.dataNeedRefresh == true then
            accessoryVoApi:refreshData(onGetAccessory)
        else
            onGetAccessory()
        end
    end
    --if type~=2 then
    local bestItem = GetButtonItem("BtnOkSmall.png", "BtnOkSmall_Down.png", "BtnCancleSmall.png", touchBestFight, nil, getlocal("autoMaxPower"), 25)
    local bestMenu = CCMenu:createWithItem(bestItem);
    bestMenu:setPosition(ccp(520, 80))
    bestMenu:setTouchPriority((-(layerNum - 1) * 20 - 4));
    layer:addChild(bestMenu)
    if type == 16 then
        bestMenu:setTag(101)
        bestItem:setTag(101)
    end
    if type == 2 or type == 3 or type == 5 or type == 10 or type == 11 or type == 12 or type == 13 or type == 14 or type == 15 or type == 16 or type == 17 or type == 19 or type == 20 or type == 21 or type == 22 or type == 23 or type == 24 or type == 25 or type == 26 or type == 32 then
        bestMenu:setPosition(ccp(320, 80))
    elseif type == 33 then
        bestMenu:setPosition(ccp(180, 75))
    elseif type == 1 or type == 30 then
        bestMenu:setPosition(ccp(160, 80))
    elseif type == 7 or type == 8 or type == 9 then
        bestMenu:setPosition(ccp(320, 70))
    end
    --end
    
    local function bestHero()
        PlayEffect(audioCfg.mouseClick)
        local maxTb = heroVoApi:bestHero(type, tankTb)
        for i = 1, 6, 1 do
            local spA = layer:getChildByTag(i * 10):getChildByTag(2)
            if spA ~= nil then
                heroVoApi:deletTroopsByPos(i, type)
                spA:removeFromParentAndCleanup(true)
            end
            
        end
        for k, v in pairs(maxTb) do
            local sp = layer:getChildByTag(k * 10)
            heroVoApi:setTroopsByPos(k, v, type)
            local hvo = heroVoApi:getHeroByHid(v)
            if hvo then
                G_addHeroTouchSp(type, sp, hvo.hid, hvo.productOrder, layerNum, layer, 2)
            end
        end
        -- body
    end
    local bestHeroItem = GetButtonItem("BtnOkSmall.png", "BtnOkSmall_Down.png", "BtnCancleSmall.png", bestHero, nil, getlocal("bestHero"), 25)
    local bestHeroMenu = CCMenu:createWithItem(bestHeroItem);
    bestHeroMenu:setPosition(ccp(520, 80))
    bestHeroMenu:setTouchPriority((-(layerNum - 1) * 20 - 4));
    layer:addChild(bestHeroMenu)
    if type == 2 or type == 3 or type == 5 or type == 7 or type == 8 or type == 9 or type == 10 or type == 11 or type == 12 or type == 13 or type == 14 or type == 15 or type == 16 or type == 17 or type == 19 or type == 20 or type == 21 or type == 22 or type == 23 or type == 24 or type == 25 or type == 26 or type == 32 then
        bestHeroMenu:setPosition(ccp(320, 80))
    elseif type == 33 then
        bestHeroMenu:setPosition(ccp(180, 75))
    elseif type == 1 or type == 30 then
        bestHeroMenu:setPosition(ccp(160, 80))
    end
    bestHeroMenu:setVisible(false)
    
    local changeMenu = CCMenu:create()
    local switchSp1 = CCSprite:createWithSpriteFrameName("changeRole1.png")
    local switchSp2 = CCSprite:createWithSpriteFrameName("changeRole1.png")
    local menuItemSp1 = CCMenuItemSprite:create(switchSp1, switchSp2)
    local switchSp3 = CCSprite:createWithSpriteFrameName("changeRole2.png")
    local switchSp4 = CCSprite:createWithSpriteFrameName("changeRole2.png")
    local menuItemSp2 = CCMenuItemSprite:create(switchSp3, switchSp4)
    local changeItem = CCMenuItemToggle:create(menuItemSp1)
    changeItem:addSubItem(menuItemSp2)
    changeItem:setAnchorPoint(CCPointMake(0, 0))
    changeItem:setPosition(0, 0)
    local function changeHandler()
        if changeItem:getSelectedIndex() == 0 then
            G_changeHeroOrTank(type, 1, layer, layerNum, nil, addHeight)
            bestHeroMenu:setVisible(false)
            bestMenu:setVisible(true)
        else
            G_changeHeroOrTank(type, 2, layer, layerNum, nil, addHeight)
            bestHeroMenu:setVisible(true)
            bestMenu:setVisible(false)
        end
        if callback then
            callback(changeItem:getSelectedIndex())
        end
    end
    changeItem:registerScriptTapHandler(changeHandler)
    changeMenu:addChild(changeItem)
    changeMenu:setPosition(ccp(layer:getContentSize().width - switchSp1:getContentSize().width - 30, layer:getContentSize().height - 250))
    changeMenu:setTouchPriority(-(layerNum - 1) * 20 - 3)
    layer:addChild(changeMenu, 2)
    changeItem:setSelectedIndex(0)
    
    if addHeight then
        changeMenu:setPosition(ccp(layer:getContentSize().width - switchSp1:getContentSize().width - 30, layer:getContentSize().height - 250 + addHeight / 2))
    end
    if type == 33 then
        changeMenu:setPosition(ccp(layer:getContentSize().width - switchSp1:getContentSize().width - 30, layer:getContentSize().height - 250 + 75))
    elseif type == 7 or type == 8 or type == 9 then
        changeMenu:setPosition(ccp(layer:getContentSize().width - switchSp1:getContentSize().width - 30, layer:getContentSize().height - 250 - 45))
    end
    
    local applyTypeSp = nil
    local function touch1()
        if applyTypeSp:isVisible() then
            applyTypeSp:setVisible(false)
            if type == 2 then
                G_isStoryAutoHero = false
            elseif type == 3 then
                G_isAtkAutoHero = false
            elseif type == 16 then
                G_isStoryAutoHero = false
            end
            
        else
            applyTypeSp:setVisible(true)
            bestHero()
            if type == 2 then
                G_isStoryAutoHero = false
            elseif type == 3 then
                G_isAtkAutoHero = false
            elseif type == 16 then
                G_isStoryAutoHero = false
            end
            
        end
    end
    local typeSp1 = LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png", touch1)
    typeSp1:setAnchorPoint(ccp(1, 0.5))
    typeSp1:setTouchPriority(-(layerNum - 1) * 20 - 3)
    typeSp1:setPosition(90, 155)
    layer:addChild(typeSp1, 2)
    
    applyTypeSp = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
    applyTypeSp:setPosition(getCenterPoint(typeSp1))
    typeSp1:addChild(applyTypeSp)
    
    local heroAutoLb = GetTTFLabel(getlocal("autoHero"), 25)
    heroAutoLb:setAnchorPoint(ccp(0, 0.5))
    heroAutoLb:setPosition(ccp(typeSp1:getContentSize().width + 10, typeSp1:getContentSize().height / 2))
    typeSp1:addChild(heroAutoLb)
    applyTypeSp:setVisible(false)
    
    typeSp1:setVisible(false)
    typeSp1:setPosition(ccp(10000, 0))
    
    local isFirst = true
    G_changeHeroOrTank(type, 1, layer, layerNum, isFirst, addHeight)
    
    if base.heroSwitch == 0 then
        changeItem:setVisible(false)
        changeItem:setPosition(ccp(10000, 0))
        typeSp1:setVisible(false)
        typeSp1:setPosition(ccp(10000, 0))
    end
    
    if type == 11 then
        if SizeOfTable(heroVoApi:getCanSetBestHeroListExpedition()) == 0 then
            changeItem:setVisible(false)
            changeItem:setPosition(ccp(10000, 0))
        end
    end
    
    if heroVoApi:isHaveHero() == false then
        changeItem:setVisible(false)
        changeItem:setPosition(ccp(10000, 0))
        typeSp1:setVisible(false)
        typeSp1:setPosition(ccp(10000, 0))
    else
        if type == 2 or type == 16 then
            typeSp1:setVisible(false)
            typeSp1:setPosition(90, 155)
            if G_isStoryAutoHero == true then
                applyTypeSp:setVisible(true)
                bestHero()
            end
        end
        
        if type == 3 then
            typeSp1:setVisible(false)
            typeSp1:setPosition(90, 155)
            if G_isAtkAutoHero == true then
                applyTypeSp:setVisible(true)
                bestHero()
            end
        end
    end
    
    if type == 4 then
        changeMenu:setPosition(ccp(layer:getContentSize().width - switchSp1:getContentSize().width - 30, layer:getContentSize().height - 350))
    elseif type == 13 or type == 14 or type == 15 then
        changeMenu:setPosition(ccp(layer:getContentSize().width - switchSp1:getContentSize().width - 30, layer:getContentSize().height - 300))
    end
    
    if isNotShowBestBtn == true then
        bestMenu:setVisible(false)
        bestMenu:setPosition(ccp(10000, 0))
        bestHeroMenu:setVisible(false)
        bestHeroMenu:setPosition(ccp(10000, 0))
    end
end

function G_changeHeroOrTank(type, isShowTank, layer, layerNum, isFirst, addHeight)
    
    if G_editLayer[type] ~= nil then
        G_editLayer[type]:changeHeroOrTank(type, isShowTank, layer, layerNum, isFirst)
        do return end
    end
    
    local tHeight = G_VisibleSize.height - 260
    if type == 4 then
        tHeight = G_VisibleSize.height - 380
    end
    if addHeight then
        tHeight = G_VisibleSize.height - 260 + addHeight * 0.8
    end
    
    local tanksTb = tankVoApi:getTanksTbByType(type)
    if type == 4 then
        if allianceWarVoApi:getSelfOid() > 0 then
            tanksTb = tankVoApi:getTanksTbByType(6)
        end
    end
    
    local function touchHero(object, name, tag)
        local tankidx = tag / 10
        if type == 1 then --防守部队时做特殊处理（指定位置没有坦克时，该位置不能部署英雄）
            if tanksTb and tanksTb[tankidx] then
                if SizeOfTable(tanksTb[tankidx]) == 0 then
                    -- print("当前位置没有设置坦克")
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("troops_no_tank"), 30)
                    do return end
                end
            end
        end
        
        if isShowTank == 1 then
            do
                return
            end
        end
        if G_checkClickEnable() == false then
            do
                return
            end
        end
        if type == 18 or (type >= 27 and type <= 29) or type == 31 or type == 34 then
            do return end
        end
        local function callBack(hid, productOrder)
            local sp = layer:getChildByTag(tag)
            heroVoApi:setTroopsByPos(tag / 10, hid, type)
            G_addHeroTouchSp(type, sp, hid, productOrder, layerNum, layer, 2)
        end
        require "luascript/script/game/scene/gamedialog/heroDialog/selectHeroDialog"
        selectHeroDialog:showselectHeroDialog(type, layerNum + 1, callBack)
        PlayEffect(audioCfg.mouseClick)
    end
    
    local function touch(object, name, tag)
        if isShowTank ~= 1 then
            do
                return
            end
        end
        if G_checkClickEnable() == false then
            do
                return
            end
        end
        if type == 18 or (type >= 27 and type <= 29) or type == 31 or type == 34 then
            do return end
        end
        if type == 4 and allianceWarVoApi:getSelfOid() > 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage4008"), 30)
            do
                return
            end
        end
        
        local function callBack(id, num)
            local sp = layer:getChildByTag(tag)
            tankVoApi:setTanksByType(type, tag, id, num)
            G_addTouchSp(type, sp, id, num, layerNum, layer, isShowTank)
        end
        require "luascript/script/game/scene/gamedialog/warDialog/selectTankDialog"
        selectTankDialog:showSelectTankDialog(type, layerNum + 1, callBack)
        PlayEffect(audioCfg.mouseClick)
        
        if type == 2 then
            local fleetload = FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(2)))
            local temLayer = tolua.cast(layer, "CCLayer")
            local fleetLb = temLayer:getChildByTag(19)
            fleetLb = tolua.cast(fleetLb, "CCLabelTTF")
            fleetLb:setString(getlocal("fleetload", {fleetload}))
        end
        
        if type == 16 then
            local fleetload = FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(16)))
            local temLayer = tolua.cast(layer, "CCLayer")
            local fleetLb = temLayer:getChildByTag(19)
            fleetLb = tolua.cast(fleetLb, "CCLabelTTF")
            fleetLb:setString(getlocal("fleetload", {fleetload}))
        end
        
    end
    
    local rect = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(20, 20, 10, 10);
    for i = 0, 1, 1 do
        for j = 0, 2, 1 do
            local tag = ((j + 1) + (i * 3)) * 10
            if layer:getChildByTag(tag) then
                local sp1 = layer:getChildByTag(tag)
                if sp1 then
                    sp1:removeFromParentAndCleanup(true)
                end
            end
            tag = ((j + 1) + (i * 3))
            if layer:getChildByTag(tag) then
                local sp2 = layer:getChildByTag(tag)
                if sp2 then
                    sp2:removeFromParentAndCleanup(true)
                end
            end
            
            local scale = 0.9
            -- local heroSp=LuaCCSprite:createWithSpriteFrameName("emptyHero.png",touchHero)
            -- -- heroSp:setPosition(460-300*i,tHeight-90-140*j);
            -- heroSp:setTag(((j+1)+(i*3))*10)
            -- heroSp:setScale(scale)
            local emptyHeroSp = CCSprite:createWithSpriteFrameName("emptyHero.png")
            local heroSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", CCRect(20, 20, 10, 10), touchHero)
            heroSp:setTag(((j + 1) + (i * 3)) * 10)
            heroSp:setContentSize(CCSizeMake(emptyHeroSp:getContentSize().width, emptyHeroSp:getContentSize().height))
            local selectTankBg3 = CCSprite:createWithSpriteFrameName("selectTankBg3.png")
            selectTankBg3:setPosition(ccp(heroSp:getContentSize().width / 2, heroSp:getContentSize().height / 2 + 5))
            heroSp:addChild(selectTankBg3)
            local selectTankBg21 = CCSprite:createWithSpriteFrameName("selectTankBg2.png")
            selectTankBg21:setAnchorPoint(ccp(0.5, 0))
            selectTankBg21:setPosition(ccp(heroSp:getContentSize().width / 2, 15))
            heroSp:addChild(selectTankBg21)
            
            local tankLb = GetTTFLabel(getlocal("fight_content_null"), 20)
            tankLb:setAnchorPoint(ccp(0.5, 0))
            tankLb:setPosition(ccp(heroSp:getContentSize().width / 2, heroSp:getContentSize().height + 5))
            tankLb:setTag(100 + ((j + 1) + (i * 3)))
            heroSp:addChild(tankLb, 1)
            
            local bgSpHeight = 26
            local bgSp = CCSprite:createWithSpriteFrameName("groupSelf.png")
            bgSp:setAnchorPoint(ccp(0.5, 0))
            bgSp:setPosition(ccp(heroSp:getContentSize().width / 2 + 15, heroSp:getContentSize().height + 3))
            bgSp:setScaleX(heroSp:getContentSize().width / bgSp:getContentSize().width)
            bgSp:setScaleY(bgSpHeight / bgSp:getContentSize().height)
            heroSp:addChild(bgSp)
            
            heroSp:setIsSallow(true)
            -- heroSp:setTouchPriority(-(layerNum-1)*20-2)
            -- layer:addChild(heroSp,1);
            
            -- local touchSp=LuaCCSprite:createWithSpriteFrameName("emptyTank.png",touch)
            -- -- touchSp:setPosition(470-300*i,tHeight-100-140*j);
            -- touchSp:setTag((j+1)+(i*3))
            -- touchSp:setScale(scale)
            -- touchSp:setIsSallow(true)
            local emptyTankSp = CCSprite:createWithSpriteFrameName("emptyTank.png")
            local touchSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", CCRect(20, 20, 10, 10), touch)
            touchSp:setTag((j + 1) + (i * 3))
            touchSp:setIsSallow(true)
            touchSp:setContentSize(CCSizeMake(emptyTankSp:getContentSize().width, emptyTankSp:getContentSize().height))
            local selectTankBg1 = CCSprite:createWithSpriteFrameName("selectTankBg1.png")
            selectTankBg1:setPosition(ccp(touchSp:getContentSize().width / 2, touchSp:getContentSize().height / 2 + 10))
            touchSp:addChild(selectTankBg1)
            local selectTankBg2 = CCSprite:createWithSpriteFrameName("selectTankBg2.png")
            selectTankBg2:setAnchorPoint(ccp(0.5, 0))
            selectTankBg2:setPosition(ccp(touchSp:getContentSize().width / 2, 15))
            touchSp:addChild(selectTankBg2)
            local inedx = ((j + 1) + (i * 3))
            local posSp = CCSprite:createWithSpriteFrameName("tankPos"..inedx..".png")
            posSp:setPosition(ccp(touchSp:getContentSize().width / 2, touchSp:getContentSize().height / 2 - 10))
            touchSp:addChild(posSp)
            
            local heroLb = GetTTFLabel(getlocal("fight_content_null"), 20)
            heroLb:setAnchorPoint(ccp(0.5, 0))
            heroLb:setPosition(ccp(touchSp:getContentSize().width / 2, touchSp:getContentSize().height + 5))
            heroLb:setTag(100 + ((j + 1) + (i * 3)))
            touchSp:addChild(heroLb, 1)
            
            local bgSp1 = CCSprite:createWithSpriteFrameName("groupSelf.png")
            bgSp1:setAnchorPoint(ccp(0.5, 0))
            bgSp1:setPosition(ccp(touchSp:getContentSize().width / 2 + 15, touchSp:getContentSize().height + 3))
            bgSp1:setScaleX(touchSp:getContentSize().width / bgSp1:getContentSize().width)
            bgSp1:setScaleY(bgSpHeight / bgSp1:getContentSize().height)
            touchSp:addChild(bgSp1)
            
            local star = 5
            for i = 1, star do
                local starSize = 15
                local starSpace = starSize
                local starSp = CCSprite:createWithSpriteFrameName("StarIcon.png")
                starSp:setScale(starSize / starSp:getContentSize().width)
                local px = touchSp:getContentSize().width / 2 - starSpace / 2 * (star - 1) + starSpace * (i - 1)
                local py = touchSp:getContentSize().height + 28 + starSize / 2
                starSp:setPosition(ccp(px, py))
                starSp:setTag(200 + i)
                touchSp:addChild(starSp, 1)
                starSp:setVisible(false)
            end
            
            local htb = {0, 0, 0, 0, 0, 0}
            local isSetHeroTroops = false
            if type == 1 then
                htb = heroVoApi:getDefHeroList()
                -- heroVoApi:setTroopsByTb(htb)
                isSetHeroTroops = true
            elseif type == 5 then
                htb = heroVoApi:getArenaHeroList()
                -- heroVoApi:setTroopsByTb(htb)
                isSetHeroTroops = true
            elseif type == 4 then
                htb = heroVoApi:getAllianceHeroList()
                isSetHeroTroops = true
            elseif type == 7 or type == 8 or type == 9 then
                htb = heroVoApi:getServerWarHeroList(type - 6)
                -- heroVoApi:setTroopsByTb(htb)
                isSetHeroTroops = true
            elseif type == 10 then
                htb = heroVoApi:getServerWarTeamHeroList()
                -- heroVoApi:setTroopsByTb(htb)
                isSetHeroTroops = true
            elseif type == 12 then
                htb = heroVoApi:getBossHeroList()
                -- heroVoApi:setTroopsByTb(htb)
                isSetHeroTroops = true
            elseif type == 13 or type == 14 or type == 15 then
                htb = heroVoApi:getWorldWarHeroList(type - 12)
                isSetHeroTroops = true
            elseif type == 17 then
                htb = heroVoApi:getLocalWarHeroList()
                isSetHeroTroops = true
            elseif type == 18 then
                htb = heroVoApi:getLocalWarCurHeroList()
                isSetHeroTroops = true
            elseif type == 19 then
                htb = heroVoApi:getSWAttackHeroList()
                isSetHeroTroops = true
            elseif type == 20 then
                htb = heroVoApi:getSWDefenceHeroList()
                isSetHeroTroops = true
            elseif type == 21 or type == 22 or type == 23 then
                htb = heroVoApi:getPlatWarHeroList(type - 20)
                isSetHeroTroops = true
            elseif type == 24 or type == 25 or type == 26 then
                htb = heroVoApi:getServerWarLocalHeroList(type - 23)
                isSetHeroTroops = true
            elseif type == 27 or type == 28 or type == 29 then
                htb = heroVoApi:getServerWarLocalCurHeroList(type - 26)
                isSetHeroTroops = true
            elseif type == 30 then
                htb = heroVoApi:getNewYearBossHeroList()
                isSetHeroTroops = true
            elseif type == 31 then
                htb = heroVoApi:getAllianceWar2CurHeroList()
                isSetHeroTroops = true
            elseif type == 32 then
                htb = heroVoApi:getAllianceWar2HeroList()
                isSetHeroTroops = true
            elseif type == 33 then
                htb = heroVoApi:getDimensionalWarHeroList()
                isSetHeroTroops = true
            elseif type == 34 then
                htb = heroVoApi:getServerWarTeamCurHeroList()
                isSetHeroTroops = true
            end
            if isSetHeroTroops == true and isFirst and isFirst == true then
                heroVoApi:setTroopsByTb(htb)
            end
            -- local hVo
            local hid, productOrder, level = nil, 1, 1
            if heroVoApi:isHaveTroops() then
                if heroVoApi:getTroopsHeroList()[heroSp:getTag() / 10] ~= nil and heroVoApi:getTroopsHeroList()[heroSp:getTag() / 10] ~= 0 then
                    -- local hid = heroVoApi:getTroopsHeroList()[heroSp:getTag()/10]
                    -- hVo=heroVoApi:getHeroByHid(hid)
                    -- if hVo then
                    --     local productOrder = hVo.productOrder
                    --     G_addHeroTouchSp(type,heroSp,hid,productOrder,layerNum,layer,isShowTank)
                    --     heroVoApi:setTroopsByPos(heroSp:getTag()/10,hid,type)
                    -- end
                    hid = heroVoApi:getTroopsHeroList()[heroSp:getTag() / 10]
                    -- print("hid~~~~~~~~~",hid)
                    if hid and hid ~= 0 then
                        heroVoApi:setTroopsByPos(heroSp:getTag() / 10, hid, type)
                        local hidArr = Split(hid, "-")
                        if hidArr and hidArr[1] and hidArr[2] and hidArr[3] then
                            hid, productOrder, level = hidArr[1], tonumber(hidArr[2]) or 1, tonumber(hidArr[3]) or 1
                        else
                            local hvo = heroVoApi:getHeroByHid(hid)
                            if hvo then
                                productOrder = hvo.productOrder
                                level = hvo.level
                            end
                        end
                        G_addHeroTouchSp(type, heroSp, hid, productOrder, layerNum, layer, isShowTank)
                    end
                end
                -- else
                --     if htb[heroSp:getTag()/10]~=nil and htb[heroSp:getTag()/10]~=0 then
                --         local hid = htb[heroSp:getTag()/10]
                --         if type==1 and SizeOfTable(heroVoApi:defAtkHero())>0 then
                --             for k,v in pairs(heroVoApi:defAtkHero()) do
                --                 if hid==v then
                --                     hVo=heroVoApi:getHeroByHid(hid)
                --                     local productOrder = hVo.productOrder
                --                     G_addHeroTouchSp(type,heroSp,hid,productOrder,layerNum,layer,isShowTank,true)
                --                 end
                --             end
                --         else
                --             hVo=heroVoApi:getHeroByHid(hid)
                --             local productOrder = hVo.productOrder
                --             G_addHeroTouchSp(type,heroSp,hid,productOrder,layerNum,layer,isShowTank)
                --         end
                --     end
            end
            
            -- if hVo then
            if hid and hid ~= 0 then
                local heroName = ""
                -- if heroListCfg[hVo.hid] then
                --     heroName=getlocal(heroListCfg[hVo.hid].heroName)
                -- end
                if heroListCfg[hid] then
                    heroName = getlocal(heroListCfg[hid].heroName)
                end
                
                -- local level=hVo.level or 1
                -- local productOrder=hVo.productOrder or 1
                if heroName and heroName ~= "" then
                    local heroStr = getlocal("fightLevel", {level}) .. " "..heroName
                    heroStr = G_getPointStr(heroStr, touchSp:getContentSize().width * scale, 20)
                    heroLb:setString(heroStr)
                end
                
                local star = productOrder
                for i = 1, star do
                    local starSize = 15
                    local starSpace = starSize
                    local starSp = tolua.cast(touchSp:getChildByTag(200 + i), "CCSprite")
                    if starSp then
                        local px = touchSp:getContentSize().width / 2 - starSpace / 2 * (star - 1) + starSpace * (i - 1)
                        local py = touchSp:getContentSize().height + 28 + starSize / 2
                        starSp:setPosition(ccp(px, py))
                        starSp:setVisible(true)
                    end
                end
            end
            
            if tanksTb ~= nil and SizeOfTable(tanksTb) > 0 then
                if tanksTb[touchSp:getTag()] ~= nil and SizeOfTable(tanksTb[touchSp:getTag()]) > 0 then
                    local id = tanksTb[touchSp:getTag()][1]
                    local num = tanksTb[touchSp:getTag()][2]
                    if id ~= 0 then
                        G_addTouchSp(type, touchSp, id, num, layerNum, layer, isShowTank)
                    end
                    
                    local tId = (tonumber(id) or tonumber(RemoveFirstChar(id)))
                    local tankStr = getlocal("item_type_number", {getlocal(tankCfg[tId].name), num})
                    tankStr = G_getPointStr(tankStr, heroSp:getContentSize().width * scale, 20)
                    tankLb:setString(tankStr)
                end
            end
            
            -- touchSp:setTouchPriority(-(layerNum-1)*20-2)
            -- layer:addChild(touchSp,2);
            
            local tankX = 470
            local tankY = 120
            local heroX = 470
            local heroY = 120
            local hSpace = 0
            if (type == 34 or type == 10) then
                if G_isIphone5() == true then
                    tankY = 150
                    heroY = 150
                    hSpace = 40
                else
                    if type == 10 then
                        tankY = 95
                        heroY = 95
                        hSpace = 12
                    elseif type == 34 then
                        tankY = 135
                        heroY = 135
                        hSpace = 12
                    end
                end
            end
            if isShowTank == 1 then
                layer:addChild(heroSp, 1)
                heroSp:setTouchPriority(-(layerNum - 1) * 20 - 2)
                heroSp:setPosition(heroX - 300 * i, tHeight - heroY - (150 + hSpace) * j)
                tankLb:setVisible(false)
                
                layer:addChild(touchSp, 2)
                touchSp:setTouchPriority(-(layerNum - 1) * 20 - 4)
                touchSp:setPosition(tankX - 300 * i, tHeight - tankY - (150 + hSpace) * j);
                heroLb:setVisible(true)
                
                if type == 33 then
                    heroSp:setPosition(heroX - 300 * i, tHeight - heroY - (150 + hSpace) * j + 100)
                    touchSp:setPosition(tankX - 300 * i, tHeight - tankY - (150 + hSpace) * j + 100);
                end
            else
                layer:addChild(touchSp, 1)
                touchSp:setTouchPriority(-(layerNum - 1) * 20 - 2)
                touchSp:setPosition(heroX - 300 * i, tHeight - heroY - (150 + hSpace) * j);
                tankLb:setVisible(true)
                
                layer:addChild(heroSp, 2)
                heroSp:setTouchPriority(-(layerNum - 1) * 20 - 4)
                heroSp:setPosition(tankX - 300 * i, tHeight - tankY - (150 + hSpace) * j);
                heroLb:setVisible(false)
                
                if type == 33 then
                    touchSp:setPosition(heroX - 300 * i, tHeight - heroY - (150 + hSpace) * j + 100);
                    heroSp:setPosition(tankX - 300 * i, tHeight - tankY - (150 + hSpace) * j + 100);
                end
                
                local star = 5
                for i = 1, star do
                    local starSp = tolua.cast(touchSp:getChildByTag(200 + i), "CCSprite")
                    if starSp then
                        starSp:setVisible(false)
                    end
                end
            end
            
        end
    end
end

function G_addTouchSp(type, parent, id, num, layerNum, layer, isShowTank)
    if G_editLayer[type] ~= nil then
        G_editLayer[type]:addTouchSp(type, parent, id, num, layerNum, layer, isShowTank)
        do return end
    end
    
    local function touchSpAdd()
        if isShowTank ~= 1 then
            do
                return
            end
        end
        PlayEffect(audioCfg.mouseClick)
        if type == 18 or (type >= 27 and type <= 29) or type == 31 or type == 34 then
            do return end
        end
        if type == 4 and allianceWarVoApi:getSelfOid() > 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage4008"), 30)
            
            do
                return
            end
        end
        
        tankVoApi:deleteTanksTbByType(type, parent:getTag())
        local spA = parent:getChildByTag(2)
        if type == 1 then
            local tankidx = parent:getTag()
            heroVoApi:deletTroopsByPos(tankidx, type)
            local tankLb = tolua.cast(parent:getChildByTag(100 + tankidx), "CCLabelTTF")
            if tankLb then
                tankLb:setString(getlocal("fight_content_null"))
            end
            local star = 5
            for i = 1, star do
                local starSize = 15
                local starSpace = starSize
                local starSp = tolua.cast(parent:getChildByTag(200 + i), "CCSprite")
                if starSp then
                    starSp:setVisible(false)
                end
            end
        end
        spA:removeFromParentAndCleanup(true)
        
        if type == 2 then
            local fleetload = FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(2)))
            local temLayer = tolua.cast(layer, "CCLayer")
            local fleetLb = temLayer:getChildByTag(19)
            fleetLb = tolua.cast(fleetLb, "CCLabelTTF")
            fleetLb:setString(getlocal("fleetload", {fleetload}))
        end
        
        if type == 16 then
            local fleetload = FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(16)))
            local temLayer = tolua.cast(layer, "CCLayer")
            local fleetLb = temLayer:getChildByTag(19)
            fleetLb = tolua.cast(fleetLb, "CCLabelTTF")
            fleetLb:setString(getlocal("fleetload", {fleetload}))
        end
        
    end
    local addLayer = CCLayer:create();
    parent:addChild(addLayer)
    addLayer:setTag(2)
    
    local capInSet = CCRect(20, 20, 10, 10);
    local touchSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, touchSpAdd)
    touchSp:setContentSize(CCSizeMake(parent:getContentSize().width, parent:getContentSize().height))
    --local scX=parent:getContentSize().width/touchSp:getContentSize().width
    --local scY=parent:getContentSize().height/touchSp:getContentSize().height
    --touchSp:setScaleX(scX)
    --touchSp:setScaleY(scY)
    touchSp:setPosition(getCenterPoint(parent))
    touchSp:setTouchPriority(-(layerNum - 1) * 20 - 5)
    touchSp:setIsSallow(true)
    --touchSp:setOpacity(0)
    addLayer:addChild(touchSp)
    
    print("aaaaaaaaa=", tankCfg[id].icon)
    local spAdd = LuaCCSprite:createWithSpriteFrameName(tankCfg[id].icon, touchSpAdd);
    spAdd:setScale(0.6)
    spAdd:setAnchorPoint(ccp(0, 0.5));
    spAdd:setIsSallow(true)
    spAdd:setPosition(ccp(5, parent:getContentSize().height / 2))
    spAdd:setTouchPriority(-(layerNum - 1) * 20 - 5)
    addLayer:addChild(spAdd)
    
    if id ~= G_pickedList(id) then
        local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
        spAdd:addChild(pickedIcon)
        pickedIcon:setPosition(spAdd:getContentSize().width - 30, 30)
        pickedIcon:setScale(1.5)
    end
    
    if isShowTank and isShowTank ~= 1 then
        touchSp:setTouchPriority(-(layerNum - 1) * 20 - 3)
        spAdd:setTouchPriority(-(layerNum - 1) * 20 - 3)
    end
    
    local cnOrDeXheightPos = nil
    local cnOrDeTheightPos = nil
    local cnOrDeXWidPos = nil
    local cnOrDeTNumheiPos = nil
    if G_getCurChoseLanguage() == "de" or G_getCurChoseLanguage() == "en" then
        cnOrDeXheightPos = 25
        cnOrDeXWidPos = 25
        cnOrDeTheightPos = 55
        cnOrDeTNumheiPos = 40
    else
        cnOrDeXheightPos = 40
        cnOrDeXWidPos = 40
        cnOrDeTheightPos = 50
        cnOrDeTNumheiPos = 30
    end
    
    if type ~= 18 and type ~= 27 and type ~= 28 and type ~= 29 and type ~= 31 and type ~= 34 then
        local spDelect = LuaCCSprite:createWithSpriteFrameName("IconFault.png", touchSpAdd);
        spDelect:setAnchorPoint(ccp(0.5, 0.5));
        spDelect:setPosition(ccp(parent:getContentSize().width - cnOrDeXWidPos, cnOrDeXheightPos))
        addLayer:addChild(spDelect)
    end
    
    local soldiersLbName = GetTTFLabelWrap(getlocal(tankCfg[id].name), 22, CCSizeMake(170, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop);
    soldiersLbName:setAnchorPoint(ccp(0, 1));
    soldiersLbName:setPosition(ccp(spAdd:getContentSize().width * 0.6 + 5, parent:getContentSize().height / 2 + cnOrDeTheightPos));
    addLayer:addChild(soldiersLbName, 2);
    
    local soldiersLbNum = GetTTFLabel(num, 22);
    soldiersLbNum:setAnchorPoint(ccp(0, 0.5));
    soldiersLbNum:setPosition(ccp(spAdd:getContentSize().width * 0.6 + 10, parent:getContentSize().height / 2 - cnOrDeTNumheiPos));
    addLayer:addChild(soldiersLbNum, 2);
    
    if type == 2 then
        local fleetload = FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(2)))
        local temLayer = tolua.cast(layer, "CCLayer")
        local fleetLb = temLayer:getChildByTag(19)
        fleetLb = tolua.cast(fleetLb, "CCLabelTTF")
        fleetLb:setString(getlocal("fleetload", {fleetload}))
    end
    
    if type == 16 then
        local fleetload = FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(16)))
        local temLayer = tolua.cast(layer, "CCLayer")
        local fleetLb = temLayer:getChildByTag(19)
        fleetLb = tolua.cast(fleetLb, "CCLabelTTF")
        fleetLb:setString(getlocal("fleetload", {fleetload}))
    end
    
end

function G_addHeroTouchSp(type, parent, hid, productOrder, layerNum, layer, isShowTank, isGary)
    
    if G_editLayer[type] ~= nil then
        G_editLayer[type]:addHeroTouchSp(type, parent, hid, productOrder, layerNum, layer, isShowTank, isGary)
        do return end
    end
    
    local function touchSpAdd()
        if isShowTank == 1 then
            do
                return
            end
        end
        PlayEffect(audioCfg.mouseClick)
        print("type=", type)
        if type == 18 or type == 31 or type == 34 then
            do return end
        end
        if type == 4 and allianceWarVoApi:getSelfOid() > 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage4008"), 30)
            
            do
                return
            end
        end
        heroVoApi:deletTroopsByPos(parent:getTag() / 10, type)
        local spA = parent:getChildByTag(2)
        spA:removeFromParentAndCleanup(true)
        
        if type == 2 then
            local fleetload = FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(2)))
            local temLayer = tolua.cast(layer, "CCLayer")
            local fleetLb = temLayer:getChildByTag(19)
            fleetLb = tolua.cast(fleetLb, "CCLabelTTF")
            fleetLb:setString(getlocal("fleetload", {fleetload}))
        end
        
        if type == 16 then
            local fleetload = FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(16)))
            local temLayer = tolua.cast(layer, "CCLayer")
            local fleetLb = temLayer:getChildByTag(19)
            fleetLb = tolua.cast(fleetLb, "CCLabelTTF")
            fleetLb:setString(getlocal("fleetload", {fleetload}))
        end
        
    end
    local addLayer = CCLayer:create();
    parent:addChild(addLayer)
    addLayer:setTag(2)
    
    local capInSet = CCRect(20, 20, 10, 10);
    local touchSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet, touchSpAdd)
    touchSp:setContentSize(CCSizeMake(parent:getContentSize().width, parent:getContentSize().height))
    touchSp:setPosition(getCenterPoint(parent))
    touchSp:setTouchPriority(-(layerNum - 1) * 20 - 5)
    touchSp:setIsSallow(true)
    addLayer:addChild(touchSp)
    
    local spAdd = heroVoApi:getHeroIcon(hid, productOrder, isGary)
    spAdd:setScale(0.45)
    spAdd:setAnchorPoint(ccp(0, 0.5));
    spAdd:setIsSallow(true)
    spAdd:setPosition(ccp(15, parent:getContentSize().height / 2))
    spAdd:setTouchPriority(-(layerNum - 1) * 20 - 5)
    addLayer:addChild(spAdd)
    
    if isShowTank and isShowTank ~= 2 then
        touchSp:setTouchPriority(-(layerNum - 1) * 20 - 3)
        spAdd:setTouchPriority(-(layerNum - 1) * 20 - 3)
    end
    
    if type ~= 18 and type ~= 27 and type ~= 28 and type ~= 29 and type ~= 31 and type ~= 34 then
        local spDelect = LuaCCSprite:createWithSpriteFrameName("IconFault.png", touchSpAdd);
        spDelect:setAnchorPoint(ccp(0.5, 0.5));
        spDelect:setPosition(ccp(parent:getContentSize().width - 40, 40))
        addLayer:addChild(spDelect)
    end
    
    local heroLbName = GetTTFLabelWrap(heroVoApi:getHeroName(hid)..getlocal("uper_level") .. "."..heroVoApi:getHeroByHid(hid).level, 22, CCSizeMake(170, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop);
    heroLbName:setAnchorPoint(ccp(0, 1));
    heroLbName:setPosition(ccp(spAdd:getContentSize().width * 0.6 + 5, parent:getContentSize().height / 2 + 50));
    addLayer:addChild(heroLbName, 2);
    -- if isGary==1 then
    --     spAdd:setVisible(false)
    -- end
    
end

function G_sendGFdata()
    
    if base.gflogUrl ~= nil then
        local platid = (base.platformUserId == nil and G_getTankUserName() or base.platformUserId)
        local url = base.gflogUrl.."/tank-gflog/tank-gflog/gfdata/tankKFLog.php?pid="..platid.."&uid="..playerVoApi:getUid() .. "&zoneid="..base.curZoneID.."&regdate="..playerVoApi:getRegdate() .. "&logindate="..base.serverTime.."&paycost="..playerVoApi:getbuycost() .. "&paynum="..playerVoApi:getbuyn() .. "&firstpaytime="..playerVoApi:getbuyts()
        HttpRequestHelper:sendAsynHttpRequest(url, "")
    end
    
    local tmpTb = {}
    tmpTb["action"] = "recordUserStep"
    tmpTb["parms"] = {}
    tmpTb["parms"]["step"] = "8"
    tmpTb["parms"]["create_time"] = tostring(playerVoApi:getRegdate())
    local cjson = G_Json.encode(tmpTb)
    G_accessCPlusFunction(cjson)
    CCUserDefault:sharedUserDefault():setStringForKey("newuser_recordUserStep", "recorded")
    
end
--聊天
--isShow 是否一定更新显示，初始化用true，
--showType 显示的聊天类型：1.世界，2.私聊，3.军团
--newType 新增聊天标示的类型，军团跨服战是11
--openShowType 打开显示哪个页签，0世界，1军团(默认)，2私聊
--layerNum 加在第几层，默认是11
function G_initChat(parent, layerNum, isShow, showType, newType, posY, bgWidth, openShowType, highZOrder)
    local function chatHandler()
        if G_checkClickEnable() == false then
            do
                return
            end
        end
        if base.shutChatSwitch == 1 then
            G_showTipsDialog(getlocal("chat_sys_notopen"))
            do return end
        end
        if newGuidMgr:isNewGuiding() == true then
            do return end
        end
        local tbArr = {}
        --判断是否有工会
        local isHasAlliance = allianceVoApi:isHasAlliance()
        if isHasAlliance then
            tbArr = {getlocal("chat_world"), getlocal("chat_alliance"), getlocal("chat_private")}
        else
            tbArr = {getlocal("chat_world"), getlocal("chat_private")}
        end
        require "luascript/script/game/scene/gamedialog/chatDialog/chatDialog"
        require "luascript/script/game/scene/gamedialog/chatDialog/chatDialogTab1"
        require "luascript/script/game/scene/gamedialog/chatDialog/chatDialogTab2"
        require "luascript/script/game/scene/gamedialog/chatDialog/chatDialogTab3"
        local td
        if newType == 10000 then
            td = chatDialog:new(10000)
        else
            td = chatDialog:new()
        end
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("chat"), true, layerNum + 1)
        if newType == 10000 then
            sceneGame:addChild(dialog, layerNum + 2)
        else
            sceneGame:addChild(dialog, layerNum + 1)
        end
        if openShowType then
            if openShowType > 0 then
                if isHasAlliance then
                    td:tabClick(openShowType)
                elseif openShowType > 1 then
                    td:tabClick(1)
                end
            end
        else
            if isHasAlliance then
                td:tabClick(1)
            end
        end
    end
    
    local m_chatBtn = GetButtonItem("mainBtnChat.png", "mainBtnChat_Down.png", "mainBtnChat_Down.png", chatHandler, nil, nil, nil)
    -- local m_chatBg=LuaCCScale9Sprite:createWithSpriteFrameName("mainChatBgSmall.png",CCRect(10,10,5,5),chatHandler)
    local m_chatBg = LuaCCScale9Sprite:createWithSpriteFrameName("mainChatBg.png", CCRect(10, 10, 5, 5), chatHandler)
    if posY == nil then
        posY = 0
    end
    local scaleX = 1
    if bgWidth then
        scaleX = bgWidth / (m_chatBtn:getContentSize().width / 2 + m_chatBg:getContentSize().width + 5)
    end
    m_chatBtn:setAnchorPoint(ccp(1, 0))
    local chatSpriteMenu = CCMenu:createWithItem(m_chatBtn)
    chatSpriteMenu:setPosition(ccp(G_VisibleSizeWidth, posY))
    chatSpriteMenu:setTouchPriority(-(layerNum - 1) * 20 - 6)
    if(highZOrder)then
        parent:addChild(chatSpriteMenu, highZOrder)
    else
        parent:addChild(chatSpriteMenu, layerNum)
    end
    m_chatBtn:setScaleX(scaleX)
    
    m_chatBg:setAnchorPoint(ccp(0, 0))
    -- if newType==12 then
    --     m_chatBg:setAnchorPoint(ccp(0,posY))
    -- end
    m_chatBg:setIsSallow(false)
    m_chatBg:setTouchPriority(-(layerNum - 1) * 20 - 6)
    m_chatBg:setPosition(ccp(0, posY + 5))
    if(highZOrder)then
        parent:addChild(m_chatBg, highZOrder)
    else
        parent:addChild(m_chatBg, layerNum)
    end
    m_chatBg:setScaleX(scaleX)
    if bgWidth then
        local wSpace = (G_VisibleSizeWidth - bgWidth) / 2
        chatSpriteMenu:setPosition(ccp(G_VisibleSizeWidth - wSpace, posY))
        m_chatBg:setPosition(ccp(wSpace, posY + 5))
    end
    
    G_setLastChat(m_chatBg, isShow, showType, newType)
    
    return m_chatBg, chatSpriteMenu
end
function G_setLastChat(m_chatBg, isShow, showType, newType)
    -- print("chatVoApi:getHasNewData(newType)",chatVoApi:getHasNewData(newType))
    if isShow == true or chatVoApi:getHasNewData(newType) == true then
        local chatVo = chatVoApi:getLast(showType)
        
        if chatVo and chatVo.subType then
            local isGM = GM_UidCfg[chatVo.sender] and true or false
            local typeStr, color, icon = chatVoApi:getTypeStr(chatVo.subType)
            
            local sizeSp = 36
            if icon and m_chatBg then
                local m_labelLastType = m_chatBg:getChildByTag(11)
                if m_labelLastType then
                    m_labelLastType:removeFromParentAndCleanup(true)
                    m_labelLastType = nil
                end
                m_labelLastType = CCSprite:createWithSpriteFrameName(icon)
                typeScale = sizeSp / m_labelLastType:getContentSize().width
                m_labelLastType:setAnchorPoint(ccp(0.5, 0.5))
                m_labelLastType:setPosition(ccp(5 + sizeSp / 2, m_chatBg:getContentSize().height / 2))
                m_chatBg:addChild(m_labelLastType, 2)
                m_labelLastType:setScale(typeScale)
            end
            local nameStr = chatVoApi:getNameStr(chatVo.type, chatVo.subType, chatVo.senderName, chatVo.reciverName, chatVo.sender)
            --nameStr=nameStr..":"
            local m_labelLastName = m_chatBg:getChildByTag(12)
            if m_labelLastName then
                m_labelLastName = tolua.cast(m_labelLastName, "CCLabelTTF")
            end
            if nameStr ~= nil and nameStr ~= "" and chatVo.type <= 3 and chatVo.contentType ~= 3 then
                nameStr = nameStr..":"
                if m_labelLastName then
                    m_labelLastName:setString(nameStr)
                    if color then
                        m_labelLastName:setColor(color)
                    end
                else
                    m_labelLastName = GetTTFLabel(nameStr, 30)
                    m_labelLastName:setAnchorPoint(ccp(0, 0.5))
                    m_labelLastName:setPosition(ccp(5 + sizeSp, m_chatBg:getContentSize().height / 2))
                    m_chatBg:addChild(m_labelLastName, 2)
                    if color then
                        m_labelLastName:setColor(color)
                    end
                    
                    m_labelLastName:setTag(12)
                end
                if isGM then
                    m_labelLastName:setColor(GM_Color)
                end
            end
            
            local message = chatVo.translateMsg or chatVo.content
            if message == nil then
                message = ""
            end
            local msgFont = nil
            --处理ios表情在安卓不显示问题
            if G_isIOS() == false then
                if platCfg.platCfgSameServerWithIos[G_curPlatName()] then
                    local tmpTb = {}
                    tmpTb["action"] = "EmojiConv"
                    tmpTb["parms"] = {}
                    tmpTb["parms"]["str"] = tostring(message)
                    local cjson = G_Json.encode(tmpTb)
                    message = G_accessCPlusFunction(cjson)
                    msgFont = G_EmojiFontSrc
                end
            end
            
            local xPos = sizeSp + 5
            if m_labelLastName and chatVo.type <= 3 then
                if chatVo.contentType == 3 then
                    --m_labelLastName:setString(nameStr)
                    m_labelLastName:setString("")
                else
                    xPos = xPos + m_labelLastName:getContentSize().width
                end
            end
            --local tmpLb=GetTTFLabel(message,30)
            local m_labelLastMsg = m_chatBg:getChildByTag(13)
            if m_labelLastMsg then
                m_labelLastMsg = tolua.cast(m_labelLastMsg, "CCLabelTTF")
            end
            message = string.gsub(message, "<rayimg>", "")
            if m_labelLastMsg then
                m_labelLastMsg:setString(message)
                if msgFont then
                    m_labelLastMsg:setFontName(msgFont)
                end
            else
                --m_labelLastMsg=GetTTFLabel(message,30)
                m_labelLastMsg = GetTTFLabelWrap(message, 30, CCSizeMake(m_chatBg:getContentSize().width - 100, 35), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, msgFont)
                m_labelLastMsg:setAnchorPoint(ccp(0, 0.5))
                m_labelLastMsg:setPosition(ccp(xPos, m_chatBg:getContentSize().height / 2))
                m_chatBg:addChild(m_labelLastMsg, 2)
                m_labelLastMsg:setTag(13)
            end
            
            m_labelLastMsg:setDimensions(CCSize(m_chatBg:getContentSize().width - xPos - 50, 40))
            if chatVo.contentType and chatVo.contentType == 2 then --战报
                m_labelLastMsg:setColor(G_ColorYellow)
            else
                m_labelLastMsg:setColor(color)
            end
            if isGM then
                m_labelLastMsg:setColor(GM_Color)
            end
            m_labelLastMsg:setPosition(ccp(xPos, m_chatBg:getContentSize().height / 2))
            
        end
        local openChatDialog
        if base.commonDialogOpened_WeakTb and base.commonDialogOpened_WeakTb["chatDialog"] then
            openChatDialog = base.commonDialogOpened_WeakTb["chatDialog"]
        end
        if (openChatDialog and openChatDialog.selectedTabIndex == 0 and newType == 10000) then
        elseif newType == 11 or newType == 12 or newType == 13 or newType == 15 or newType == 10000 then
            chatVoApi:setNoNewData(newType)
        end
    end
end

function G_getPointStr(str, width, size)
    -- str="aa啊啊啊啊啊aaaa啊wwwlll啊啊啊"
    local fmtStr = str
    local strLb = GetTTFLabel(str, size)
    if strLb:getContentSize().width > width then
        local len = #str
        local left = len
        local cnt = 0
        local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
        while left ~= 0 do
            local tmp = string.byte(str, -left)
            local i = #arr;
            while arr[i] do
                if tmp >= arr[i] then
                    left = left - i
                    break
                end
                i = i - 1
            end
            
            local tmpStr = string.sub(str, 1, len - left)
            local tmpLb = GetTTFLabel(tmpStr.."...", size)
            if tmpLb:getContentSize().width > width then
                return fmtStr
            else
                fmtStr = tmpStr.."..."
            end
        end
    end
    return fmtStr
end

--获取第几个阵型的坦克和将领 --isNew:新设置，区分以前
function G_getFormationByIndex(index, type, isNew)
    local tank = {{}, {}, {}, {}, {}, {}}
    local hero = {0, 0, 0, 0, 0, 0}
    local aitroops = {0, 0, 0, 0, 0, 0}
    local emblemId = 0
    local planePos = 0
    local airship  = nil
    local zoneId = base.curZoneID
    local uid = playerVoApi:getUid()
    local isSaved = false
    if index then
        local key = zoneId.."@"..uid.."@"..index
        if isNew then
            local addKeyNum = type == 36 and 35 or type
            key = zoneId.."@"..uid.."@"..addKeyNum.."@"..index
        end
        local valueStr = CCUserDefault:sharedUserDefault():getStringForKey(key)
        -- print("get~~~~valueStr:",valueStr)
        if valueStr and valueStr ~= "" then
            local arr = Split(valueStr, "@")
            local tType
            if arr and arr[3] then
                tType = tonumber(arr[3])
            end
            -- print("tType",tType)
            if arr and arr[4] and base.emblemSwitch == 1 then
                local eId = arr[4]
                if type and (type == 35 or type == 36) then
                    if ltzdzFightApi:canUseEmblemInSetFormation(eId, type) then
                        emblemId = eId
                    end
                elseif eId and tostring(eId) ~= "0" then
                    local canUse = emblemVoApi:checkEquipCanUse(type, eId)
                    -- print("canUse",canUse)
                    if canUse == true then
                        emblemId = eId
                    end
                end
                isSaved = true
            end
            if arr and arr[5] and base.plane == 1 then
                local pId = arr[5]
                if type and (type == 35 or type == 36) then
                    if ltzdzFightApi:canUseInPlaneSetFormation(pId, type) then
                        planePos = tonumber(pId)
                    end
                elseif pId and tonumber(pId) and tonumber(pId) ~= 0 then
                    pId = tonumber(pId)
                    local canUse = planeVoApi:checkEquipCanUse(type, pId)
                    -- print("canUse",canUse)
                    if canUse == true then
                        planePos = pId
                    end
                end
                isSaved = true
            end
            if arr and arr[7] and arr[7] ~= "" and base.airShipSwitch == 1 then
                local asId = arr[7] or nil
                if asId then
                    local canUse = airShipVoApi:checkAirshipCanUse(type, asId)
                    if canUse == 0 or canUse == 2 then
                        airship = asId
                    end
                end
            end
            if arr and arr[1] then
                if G_Json.decode(arr[1]) then
                    tank = G_Json.decode(arr[1])
                    local maxTroopsNum = 0
                    if (type) and (type == 38) then
                        maxTroopsNum = tonumber(playerVoApi:getTotalTroops(type, false))
                    else
                        maxTroopsNum = tonumber(playerVoApi:getTotalTroops(nil, false))
                    end
                    local emblemAddNum = 0
                    if emblemId and tostring(emblemId) ~= "0" then
                        emblemAddNum = emblemVoApi:getTroopsAddById(emblemId)
                    end
                    maxTroopsNum = maxTroopsNum + emblemAddNum
                    -- print("maxTroopsNum",maxTroopsNum)
                    local allTanks = G_clone(tankVoApi:getAllTanks())
                    if type and (type == 35 or type == 36) then--领土争夺战，没用到自身坦克数量，用的是领土的预备役，所以区分出来
                        local reserveNum, fightNum, troops = ltzdzFightApi:UseInGetFormation()
                        local totalNum = fightNum + emblemAddNum
                        for k, v in pairs(tank) do
                            if v and v[1] and v[2] then
                                local tid = v[1]
                                local cantUse = false
                                for k, v in pairs(troops) do
                                    if tid == tonumber(RemoveFirstChar(v)) then
                                        cantUse = true
                                        do break end
                                    end
                                end
                                if cantUse then
                                    local num = tonumber(v[2]) or 0
                                    local canUseNum = reserveNum > totalNum and totalNum or reserveNum
                                    tank[k][2] = num > canUseNum and canUseNum or num
                                    
                                    reserveNum = reserveNum - tank[k][2]
                                    if canUseNum == 0 then
                                        tank[k] = {}
                                    end
                                    
                                else
                                    tank[k] = {}
                                end
                            end
                        end
                        
                    else
                        if tType and tType >= 13 and tType <= 15 and type and type >= 13 and type <= 15 then
                            if worldWarCfg and worldWarCfg.tankeTransRate then
                                local multiple = worldWarCfg.tankeTransRate
                                for k, v in pairs(allTanks) do
                                    if v and v[1] then
                                        local num = tonumber(v[1]) or 0
                                        allTanks[k][1] = num * multiple
                                    end
                                end
                                local worldWarTempTanks = tankVoApi:getWorldWarTempTanks()
                                for k, v in pairs(worldWarTempTanks) do
                                    if v and v[1] and v[2] then
                                        local tid = v[1]
                                        local num = tonumber(v[2])
                                        if allTanks[tid] and allTanks[tid][1] then
                                            allTanks[tid][1] = allTanks[tid][1] + num
                                        else
                                            if allTanks[tid] == nil then
                                                allTanks[tid] = {}
                                            end
                                            allTanks[tid][1] = num
                                        end
                                    end
                                end
                            end
                        elseif tType and tType == 17 and type and type == 17 then
                            if localWarCfg and localWarCfg.tankeTransRate then
                                local multiple = localWarCfg.tankeTransRate
                                for k, v in pairs(allTanks) do
                                    if v and v[1] then
                                        local num = tonumber(v[1]) or 0
                                        allTanks[k][1] = num * multiple
                                    end
                                end
                                -- local worldWarTempTanks=tankVoApi:getWorldWarTempTanks()
                                -- for k,v in pairs(worldWarTempTanks) do
                                --     if v and v[1] and v[2] then
                                --         local tid=v[1]
                                --         local num=tonumber(v[2])
                                --         if allTanks[tid] and allTanks[tid][1] then
                                --             allTanks[tid][1]=allTanks[tid][1]+num
                                --         else
                                --             if allTanks[tid]==nil then
                                --                 allTanks[tid]={}
                                --             end
                                --             allTanks[tid][1]=num
                                --         end
                                --     end
                                -- end
                            end
                        elseif tType and tType >= 21 and tType <= 23 and type and type >= 21 and type <= 23 then
                            if platWarCfg and platWarCfg.tankeTransRate then
                                local multiple = platWarCfg.tankeTransRate
                                for k, v in pairs(allTanks) do
                                    if v and v[1] then
                                        local num = tonumber(v[1]) or 0
                                        allTanks[k][1] = num * multiple
                                    end
                                end
                                local platWarTempTanks = tankVoApi:getPlatWarTempTanks()
                                for k, v in pairs(platWarTempTanks) do
                                    if v and v[1] and v[2] then
                                        local tid = v[1]
                                        local num = tonumber(v[2])
                                        if allTanks[tid] and allTanks[tid][1] then
                                            allTanks[tid][1] = allTanks[tid][1] + num
                                        else
                                            if allTanks[tid] == nil then
                                                allTanks[tid] = {}
                                            end
                                            allTanks[tid][1] = num
                                        end
                                    end
                                end
                            end
                        elseif tType and tType >= 24 and tType <= 27 and type and type >= 24 and type <= 27 then
                            if serverWarLocalCfg and serverWarLocalCfg.tankeTransRate then
                                local multiple = serverWarLocalCfg.tankeTransRate
                                for k, v in pairs(allTanks) do
                                    if v and v[1] then
                                        local num = tonumber(v[1]) or 0
                                        allTanks[k][1] = num * multiple
                                    end
                                end
                                local serverWarLocalTempTanks = tankVoApi:getServerWarLocalTempTanks()
                                for k, v in pairs(serverWarLocalTempTanks) do
                                    if v and v[1] and v[2] then
                                        local tid = v[1]
                                        local num = tonumber(v[2])
                                        if allTanks[tid] and allTanks[tid][1] then
                                            allTanks[tid][1] = allTanks[tid][1] + num
                                        else
                                            if allTanks[tid] == nil then
                                                allTanks[tid] = {}
                                            end
                                            allTanks[tid][1] = num
                                        end
                                    end
                                end
                            end
                        elseif tType and tType == 32 and type and type == 32 then
                            if allianceWar2Cfg and allianceWar2Cfg.tankeTransRate then
                                local multiple = allianceWar2Cfg.tankeTransRate
                                for k, v in pairs(allTanks) do
                                    if v and v[1] then
                                        local num = tonumber(v[1]) or 0
                                        allTanks[k][1] = num * multiple
                                    end
                                end
                            end
                        elseif type and type == 11 then --远征
                            local deadTank = expeditionVoApi:getDeadTank()
                            if deadTank then
                                for k, v in pairs(deadTank) do
                                    if v and v.id and v.num then
                                        local tankId = (tonumber(v.id) or tonumber(RemoveFirstChar(v.id)))
                                        if allTanks and allTanks[tankId] and allTanks[tankId][1] then
                                            allTanks[tankId][1] = allTanks[tankId][1] - v.num
                                            if allTanks[tankId][1] < 0 then
                                                allTanks[tankId][1] = 0
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        for k, v in pairs(tank) do
                            if v and v[1] and v[2] then
                                local tid = v[1]
                                local num = tonumber(v[2]) or 0
                                local canUseNum = 0
                                if allTanks and allTanks[tid] then
                                    canUseNum = allTanks[tid][1] or 0
                                    -- print("canUseNum",canUseNum)
                                    if maxTroopsNum and canUseNum > maxTroopsNum then
                                        canUseNum = maxTroopsNum
                                    end
                                    -- print("canUseNum~~~~~~2",canUseNum)
                                    if num > canUseNum then
                                        tank[k][2] = canUseNum
                                    end
                                    if canUseNum == 0 then
                                        tank[k] = {}
                                    else
                                        allTanks[tid][1] = allTanks[tid][1] - tank[k][2]
                                    end
                                else
                                    tank[k] = {}
                                end
                            end
                        end
                    end
                    isSaved = true
                end
                if G_Json.decode(arr[2]) then
                    hero = G_Json.decode(arr[2])
                    for k, v in pairs(hero) do
                        if v then
                            if tostring(v) == "0" then
                                hero[k] = 0
                            else
                                if type and (type == 35 or type == 36) then
                                    local curCid = ltzdzFightApi:getCurStartCid()
                                    if ltzdzFightApi:heroIsCanUse(v, curCid) == false or SizeOfTable(tank[k]) == 0 then
                                        hero[k] = 0
                                    end
                                else
                                    local atkHero = heroVoApi:allAtkHero()
                                    for _, hid in pairs(atkHero) do
                                        if v == hid then
                                            hero[k] = 0
                                        end
                                    end
                                    --检测世界大战其他部队是否设置该英雄，有则不能再设置
                                    if type and type >= 13 and type <= 15 then
                                        for i = 1, 3 do
                                            local hType = i + 12
                                            if type ~= hType then
                                                local hh = G_clone(heroVoApi:getWorldWarHeroList(i))
                                                if hh and SizeOfTable(hh) > 0 then
                                                    for m, n in pairs(hh) do
                                                        if n and n == v then
                                                            hero[k] = 0
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                        --检测平台战其他部队是否设置该英雄，有则不能再设置
                                    elseif type and type >= 21 and type <= 23 then
                                        for i = 1, 3 do
                                            local hType = i + 20
                                            if type ~= hType then
                                                local hh = G_clone(heroVoApi:getPlatWarHeroList(i))
                                                if hh and SizeOfTable(hh) > 0 then
                                                    for m, n in pairs(hh) do
                                                        if n and n == v then
                                                            hero[k] = 0
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                        --检测群雄争霸其他部队是否设置该英雄，有则不能再设置
                                    elseif type and type >= 24 and type <= 27 then
                                        for i = 1, 3 do
                                            local hType = i + 23
                                            if type ~= hType then
                                                local hh = G_clone(heroVoApi:getServerWarLocalHeroList(i))
                                                if hh and SizeOfTable(hh) > 0 then
                                                    for m, n in pairs(hh) do
                                                        if n and n == v then
                                                            hero[k] = 0
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                        --远征
                                    elseif type and type == 11 then
                                        local deadHero = expeditionVoApi:getDeadHero()
                                        if deadHero and SizeOfTable(deadHero) > 0 then
                                            for k, v in pairs(deadHero) do
                                                for m, n in pairs(hero) do
                                                    if n and v and n == v then
                                                        hero[m] = 0
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    isSaved = true
                end
                --AI部队处理
                if arr[6] then
                    if G_Json.decode(arr[6]) then
                        aitroops = G_Json.decode(arr[6])
                        for k, v in pairs(aitroops) do
                            if v then
                                local tmpId = AITroopsVoApi:getAITroopsId(v)
                                if tostring(tmpId) == "0" or tostring(tmpId) == "" then
                                    aitroops[k] = 0
                                else
                                    if type and (type == 35 or type == 36) then
                                        local curCid = ltzdzFightApi:getCurStartCid()
                                        if ltzdzFightApi:AITroopsIsCanUse(tmpId, curCid) == false or SizeOfTable(tank[k]) == 0 then
                                            aitroops[k] = 0
                                        end
                                    else
                                        local atkAITroops = AITroopsFleetVoApi:allAtkAITroops()
                                        for _, atid in pairs(atkAITroops) do
                                            local id = AITroopsVoApi:getAITroopsId(atid)
                                            if tostring(tmpId) == tostring(id) then
                                                aitroops[k] = 0
                                            end
                                        end
                                        --检测世界大战其他部队是否设置该英雄，有则不能再设置
                                        if type and type >= 13 and type <= 15 then
                                            for i = 1, 3 do
                                                local bType = i + 12
                                                if type ~= bType then
                                                    local tb = G_clone(AITroopsFleetVoApi:getWorldWarAITroopsList(i))
                                                    if tb and SizeOfTable(tb) > 0 then
                                                        for m, n in pairs(tb) do
                                                            local id = AITroopsVoApi:getAITroopsId(n)
                                                            if id == tmpId then
                                                                aitroops[k] = 0
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                            --检测平台战其他部队是否设置该英雄，有则不能再设置
                                        elseif type and type >= 21 and type <= 23 then
                                            for i = 1, 3 do
                                                local bType = i + 20
                                                if type ~= bType then
                                                    local tb = G_clone(AITroopsFleetVoApi:getPlatWarAITroopsList(i))
                                                    if tb and SizeOfTable(tb) > 0 then
                                                        for m, n in pairs(tb) do
                                                            local id = AITroopsVoApi:getAITroopsId(n)
                                                            if id == tmpId then
                                                                aitroops[k] = 0
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                            --检测群雄争霸其他部队是否设置该英雄，有则不能再设置
                                        elseif type and type >= 24 and type <= 27 then
                                            for i = 1, 3 do
                                                local bType = i + 23
                                                if type ~= bType then
                                                    local tb = G_clone(AITroopsFleetVoApi:getServerWarLocalAITroopsList(i))
                                                    if tb and SizeOfTable(tb) > 0 then
                                                        for m, n in pairs(tb) do
                                                            local id = AITroopsVoApi:getAITroopsId(n)
                                                            if id == tmpId then
                                                                aitroops[k] = 0
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                            --远征
                                        elseif type and type == 11 then
                                            local deadAITroops = expeditionVoApi:getDeadAITroops()
                                            if deadAITroops and SizeOfTable(deadAITroops) > 0 then
                                                for k, v in pairs(deadAITroops) do
                                                    local tmpId = AITroopsVoApi:getAITroopsId(v)
                                                    for m, n in pairs(aitroops) do
                                                        local id = AITroopsVoApi:getAITroopsId(n)
                                                        if tmpId == id then
                                                            aitroops[m] = 0
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        isSaved = true
                    end
                end
            end
            -- if arr and arr[4] and base.emblemSwitch==1 then
            --     emblemId = arr[4]
            --     isSaved=true
            -- end
        end
    end
    return isSaved, tank, hero, emblemId, planePos, aitroops, airship
end
--保存第几个阵型的坦克和将领
--param index: 第几个阵型
--param tankTb: 坦克阵型
--param heroTb: 将领阵型
--param emblemId: 军徽ID
--param planePos: 飞机位置
--param airShipId: 飞艇ID
function G_setFormationByIndex(index, tankTb, heroTb, aitroopsTb, type, emblemId, planePos, isNew, airShipId)
    if index then
        local tank = {{}, {}, {}, {}, {}, {}}
        local hero = {0, 0, 0, 0, 0, 0}
        local aitroops = {0, 0, 0, 0, 0, 0}
        local emblem = 0
        local plane = 0
        local airShip = ""
        if tankTb and SizeOfTable(tankTb) > 0 then
            tank = tankTb
        end
        if heroTb and SizeOfTable(heroTb) > 0 then
            hero = heroTb
        end
        if aitroopsTb and SizeOfTable(aitroopsTb) > 0 then
            aitroops = aitroopsTb
        end
        if base.emblemSwitch == 1 and emblemId then
            emblem = emblemId
            if emblem == nil then
                emblem = 0
            end
        end
        if base.plane == 1 and planePos then
            plane = planePos
            if plane == nil then
                plane = 0
            end
        end
        if base.airShipSwitch == 1 and airShipId and airShipId ~= "" then
            airShip = airShipId
        end
        local zoneId = base.curZoneID
        local uid = playerVoApi:getUid()
        local key = zoneId.."@"..uid.."@"..index
        if isNew then
            local addKeyNum = type == 36 and 35 or type
            key = zoneId.."@"..uid.."@"..addKeyNum.."@"..index
        end
        local valueStr = G_Json.encode(tank) .. "@"..G_Json.encode(hero) .. "@"..type.."@"..emblem.."@"..plane.."@"..G_Json.encode(aitroops).."@"..airShip
        -- print("set~~~~valueStr:",valueStr)
        CCUserDefault:sharedUserDefault():setStringForKey(key, valueStr)
        CCUserDefault:sharedUserDefault():flush()
    end
end

function G_getchannelID()
    
    local tmpTb = {}
    tmpTb["action"] = "getChannel"
    tmpTb["parms"] = {}
    
    local cjson = G_Json.encode(tmpTb)
    
    return G_accessCPlusFunction(cjson)
end

function G_getResourceIcon(rkey)
    local picStr
    if rkey == "gem" or rkey == "gems" then
        picStr = "IconGold.png"
    elseif rkey == "r1" then
        picStr = "IconCopper.png"
    elseif rkey == "r2" then
        picStr = "IconOil.png"
    elseif rkey == "r3" then
        picStr = "IconIron.png"
    elseif rkey == "r4" then
        picStr = "IconOre.png"
    elseif rkey == "gold" then
        picStr = "IconCrystal-.png"
    end
    return picStr
end
function G_getResourceIconByIndex(index)
    local picStr
    if index == 1 then
        picStr = "IconCopper.png"
    elseif index == 2 then
        picStr = "IconOil.png"
    elseif index == 3 then
        picStr = "IconIron.png"
    elseif index == 4 then
        picStr = "IconOre.png"
    elseif index == 5 then
        picStr = "IconCrystal-.png"
    end
    return picStr
end

--保存阵型按钮
function G_getFormationBtn(parent, layerNum, isShowTank, tankType, callback, pos, priority, scale)
    local function formationHandler(tag, object)
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local soldiersLbNum = tolua.cast(parent:getChildByTag(414), "CCLabelTTF")
        if soldiersLbNum ~= nil then
            soldiersLbNum:setString("+"..playerVoApi:getExtraTroopsNum())
        end
        local function readCallback()
            if callback then
                callback()
            end
        end
        -- tankType = tankType == 36 and 35 or tankType
        smallDialog:showFormationDialog("PanelHeaderPopup.png", CCSizeMake(550, 700), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), true, layerNum + 1, getlocal("save_formation"), readCallback, tankType, isShowTank, parent)
    end
    local btn1, btn2, btnName = "BtnOkSmall.png", "BtnOkSmall_Down.png", "formation"
    local strSize = 25
    if tankType == 35 then
        btnName = "formation2"
        btn1, btn2 = "newGrayBtn2.png", "newGrayBtn2_Down.png"
        strSize = 22 / scale
    elseif tankType == 36 or tankType == 38 then
        if tankType == 38 then
            btnName = "formation"
        else
            btnName = "formation2"
        end
        btn1, btn2 = "newGreenBtn.png", "newGreenBtn_down.png"
        strSize = 25 / scale
    end
    local formationItem = GetButtonItem(btn1, btn2, btn2, formationHandler, nil, getlocal(btnName), strSize, 101)
    if scale then
        formationItem:setScale(scale)
        -- else
        --     formationItem:setScale(0.8)
    end
    local lb = formationItem:getChildByTag(101)
    if lb then
        lb = tolua.cast(lb, "CCLabelTTF")
        lb:setFontName("Helvetica-bold")
    end
    local formationMenu = CCMenu:createWithItem(formationItem)
    formationMenu:setPosition(ccp(120, 80))
    if pos then
        formationMenu:setPosition(pos)
    end
    formationMenu:setTouchPriority((-(layerNum - 1) * 20 - 6))
    if priority then
        formationMenu:setTouchPriority(priority)
    end
    parent:addChild(formationMenu)
    return formationMenu
end

function G_getPropStr(pidTab, nameTab)
    local index = 0
    if pidTab then
        for _, range in pairs(pidTab) do
            local minPid = range[1]
            local maxPid = range[2]
            if maxPid == nil then
                maxPid = minPid
            end
            for pid = minPid, maxPid do
                index = index + 1
                local propName = 'sample_prop_name_'..pid..'="'..nameTab[index] .. '",'
                
                local propDesc = 'sample_prop_des_'..pid..'="#shiyonghouhuode#'
                local cfg = propCfg["p"..pid]
                if cfg.useGetProp then
                    for _, item in pairs(cfg.useGetProp) do
                        local propId = item[1]
                        local num = item[2]
                        propDesc = propDesc..'#'..propCfg[propId].name..'#*'..num..'，'
                    end
                end
                if cfg.useGetTroops then
                    for tankId, num in pairs(cfg.useGetTroops) do
                        local tid = tonumber(RemoveFirstChar(tankId))
                        propDesc = propDesc..'#'..tankCfg[tid].name..'#*'..num..'，'
                    end
                end
                if cfg.useGetAccessoryProp then
                    for accId, num in pairs(cfg.useGetAccessoryProp) do
                        propDesc = propDesc..'#'..accessoryCfg.propCfg[accId].name..'#*'..num..'，'
                    end
                end
                if cfg.useGetResource then
                    local itemTb = FormatItem({u = cfg.useGetResource})
                    for _, item in pairs(itemTb) do
                        local key = item.key
                        local localKey
                        if key == "r1" then
                            localKey = "metal"
                        elseif key == "r2" then
                            localKey = "oil"
                        elseif key == "r3" then
                            localKey = "silicon"
                        elseif key == "r4" then
                            localKey = "uranium"
                        elseif key == "gold" then
                            localKey = "money"
                        elseif key == "gem" or key == "gems" then
                            localKey = "gem"
                        elseif key == "exp" then
                            localKey = "sample_general_exp"
                        elseif key == "honors" then
                            localKey = "honor"
                        elseif key == "energy" then
                            localKey = "energy"
                        end
                        propDesc = propDesc..'#'..localKey..'#*'..item.num..'，'
                    end
                end
                if cfg.useGetAlienRes then
                    for alienResType, num in pairs(cfg.useGetAlienRes) do
                        local resType = tonumber(RemoveFirstChar(alienResType))
                        local resNameKey = "alien_tech_res_name_"..resType
                        propDesc = propDesc..'#'..resNameKey..'#*'..num..'，'
                    end
                end
                if cfg.useGetHero then
                    for key, num in pairs(cfg.useGetHero) do
                        local item
                        local eType = string.sub(key, 1, 1)
                        local id = string.sub(key, 2)
                        if eType == "h" then
                            item = heroListCfg[key]
                            propDesc = propDesc..'#'..item.heroName..'#*'..num..'，'
                        elseif eType == "s" then
                            item = heroListCfg["h"..id]
                            local name = getlocal("heroSoul", {getlocal(item.heroName)})
                            propDesc = propDesc..name..'*'..num..'，'
                        end
                    end
                end
                if cfg.useGetWeaponRes then
                    require "luascript/script/config/gameconfig/superWeapon/superWeaponCfg"
                    for key, num in pairs(cfg.useGetWeaponRes) do
                        local eType = string.sub(key, 1, 1)
                        local localKey = ""
                        if eType == "f" then
                            local name, desc = superWeaponVoApi:getFragmentNameAndDesc(key)
                            propDesc = propDesc..name..'*'..num..'，'
                        else
                            if eType == "w" then
                                localKey = superWeaponCfg.weaponCfg[key].name
                                propDesc = propDesc..'#'..localKey..'#*'..num..'，'
                            elseif eType == "p" then
                                localKey = superWeaponCfg.propCfg[key].name
                                propDesc = propDesc..'#'..localKey..'#*'..num..'，'
                            elseif eType == "c" then
                                localKey = superWeaponCfg.crystalCfg[key].name
                                propDesc = propDesc..'#'..localKey..'#'..getlocal("fightLevel", {superWeaponCfg.crystalCfg[key].lvl}) .. '*'..num..'，'
                            end
                        end
                    end
                end
                if cfg.useGetEquipRes then
                    for key, num in pairs(cfg.useGetEquipRes) do
                        local localKey = "sample_prop_name_"..key
                        propDesc = propDesc..'#'..localKey..'#*'..num..'，'
                    end
                end
                if cfg.useGetUserarenaRes then
                    local num = 0
                    for k, v in pairs(cfg.useGetUserarenaRes) do
                        num = num + v
                    end
                    local localKey = "shamBattle_medal"
                    propDesc = propDesc..'#'..localKey..'#*'..num..'，'
                end
                if cfg.useGetExpeditionRes then
                    local num = 0
                    for k, v in pairs(cfg.useGetExpeditionRes) do
                        num = num + v
                    end
                    local localKey = "expedition_medal"
                    propDesc = propDesc..'#'..localKey..'#*'..num..'，'
                end
                propDesc = string.sub(propDesc, 1, -4)
                propDesc = propDesc..'",'
                print(propName)
                print(propDesc)
            end
        end
    end
end

function G_isSendAchievementToGoogle()
    if G_curPlatName() == "androidarab" then
        if(G_Version >= 14)then
            return 1
        elseif(G_Version > 2)then
            if base.loginAccountType == 3 then
                return 2
            else
                return 3
            end
        end
    end
    return 0
end

--技能名字
function G_getPropertyStr(attrType)
    if attrType and playerCfg.property and playerCfg.property[attrType] then
        local key = playerCfg.property[attrType]
        return getlocal("property_"..key)
    end
    return ""
end

function G_sendAsynHttpRequestNoResponse(url)
    if G_isTestServer() == true then
        url = G_stringGsub(url, "/tank%-server/", "/tank-server-test/")
    end
    deviceHelper:luaPrint("url~~~~~~~~~~1:"..url)
    -- print("url",url)
    HttpRequestHelper:sendAsynHttpRequest(url, "")
end

function G_sendHttpRequest(url, parms)
    if G_isTestServer() == true then
        url = G_stringGsub(url, "/tank%-server/", "/tank-server-test/")
    end
    deviceHelper:luaPrint("url~~~~~~~~~~2:"..url)
    -- print("url",url)
    local retstr = HttpRequestHelper:sendHttpRequest(string.find(url, "?") == nil and url.."?rayjoy_thief=1" or url.."&rayjoy_thief=1", parms)
    local stidx = string.find(retstr, "rayjoy_thief_start")
    if stidx ~= nil then
        retstr = string.sub(retstr, stidx + 18)
        local edidx = string.find(retstr, "rayjoy_thief_end")
        retstr = string.sub(retstr, 1, edidx - 1)
    end
    return retstr
end

function G_sendHttpRequestPost(url, parms)
    if G_isTestServer() == true then
        url = G_stringGsub(url, "/tank%-server/", "/tank-server-test/")
    end
    deviceHelper:luaPrint("url~~~~~~~~~~3:"..url)
    print("url", url)
    local retstr = HttpRequestHelper:sendHttpRequestPost(url, parms == "" and "rayjoy_thief=1" or parms.."&rayjoy_thief=1")
    local stidx = string.find(retstr, "rayjoy_thief_start")
    if stidx ~= nil then
        retstr = string.sub(retstr, stidx + 18)
        local edidx = string.find(retstr, "rayjoy_thief_end")
        retstr = string.sub(retstr, 1, edidx - 1)
    end
    return retstr
end

G_httpAsynQueue = {} --异步请求排序队列

--http 异步请求
--param url: 请求的url
--param params: 请求参数
--param callback: 回调函数
--param type: 1是get, 2是post, 默认是get
function G_sendHttpAsynRequest(url, params, callback, type)
    if G_isTestServer() == true then
        url = G_stringGsub(url, "/tank%-server/", "/tank-server-test/")
    end
    deviceHelper:luaPrint("url~~~~~~~~~~4:"..url)
    -- print("url",url)
    if(params == nil)then
        params = ""
    end
    if(HttpRequestHelper:shared().sendAsynHttpRequestPost == nil or HttpRequestHelper:shared().sendAsynHttpRequestGet == nil)then
        if(callback)then
            callback("", -1)
        end
        do return end
    end
    if(#G_httpAsynQueue == 0)then
        if(type == 2)then
            HttpRequestHelper:shared():sendAsynHttpRequestPost(url, params)
        else
            HttpRequestHelper:shared():sendAsynHttpRequestGet(url, params)
        end
    end
    local asynData = {time = base.serverTime, url = url, params = params, type = type, callback = callback}
    table.insert(G_httpAsynQueue, asynData)
end

--异步http请求的回调
--result: 0表示成功, 1表示不成功
--data: 返回的数据
--url: 请求的url
--params: 请求的参数
function G_HttpAsynCallBackHandler(result, data, url, params)
    local stidx = string.find(data, "rayjoy_thief_start")
    if stidx ~= nil then
        data = string.sub(data, stidx + 18)
        local edidx = string.find(data, "rayjoy_thief_end")
        data = string.sub(data, 1, edidx - 1)
    end
    --如果排在队列最前面的请求与返回值不一致, 那就当是过期请求, 无视
    if(G_httpAsynQueue[1] == nil)then
        do return end
    end
    local newUrl
    local fistPos, lastPos = string.find(url, "https")
    if fistPos == 1 and lastPos == 5 then
        newUrl = string.gsub(url, "https", "http", 1)
    else
        newUrl = string.gsub(url, "http", "https", 1)
    end
    local callFunc = G_httpAsynQueue[1].callback
    if(callFunc)then
        callFunc(data, result)
    end
    table.remove(G_httpAsynQueue, 1)
    --旧的处理完, 开始处理下一个请求
    local asynData = G_httpAsynQueue[1]
    if(asynData)then
        while(#G_httpAsynQueue > 0 and(asynData == nil or asynData.url == nil or asynData.params == nil))do
            table.remove(G_httpAsynQueue, 1)
            asynData = G_httpAsynQueue[1]
        end
        if(asynData)then
            local urlNew = asynData.url
            local paramNew = asynData.params
            local typeNew = asynData.type
            if(typeNew == 2)then
                HttpRequestHelper:shared():sendAsynHttpRequestPost(urlNew, paramNew == "" and "rayjoy_thief=1" or paramNew.."&rayjoy_thief=1")
            else
                HttpRequestHelper:shared():sendAsynHttpRequestGet(urlNew, paramNew == "" and "rayjoy_thief=1" or paramNew.."&rayjoy_thief=1")
            end
        end
    end
end

--定时检查并清除http异步请求队列中的超时请求
function G_checkAsynHttpTb()
    local flag = false
    local asynData = G_httpAsynQueue[1]
    if(asynData)then
        while(#G_httpAsynQueue > 0 and(asynData == nil or asynData.url == nil or asynData.params == nil or asynData.time < base.serverTime - 30))do
            table.remove(G_httpAsynQueue, 1)
            asynData = G_httpAsynQueue[1]
            flag = true
        end
    end
    if(flag)then
        asynData = G_httpAsynQueue[1]
        if(asynData)then
            local urlNew = asynData.url
            local paramNew = asynData.params
            local typeNew = asynData.type
            if(typeNew == 2)then
                HttpRequestHelper:shared():sendAsynHttpRequestPost(urlNew, paramNew == "" and "rayjoy_thief=1" or paramNew.."&rayjoy_thief=1")
            else
                HttpRequestHelper:shared():sendAsynHttpRequestGet(urlNew, paramNew == "" and "rayjoy_thief=1" or paramNew.."&rayjoy_thief=1")
            end
        end
    end
end

function G_getHasValue(tb, value)
    local hasValue = false
    if tb and SizeOfTable(tb) > 0 and value then
        for k, v in pairs(tb) do
            if v and type(v) == type(value) and v == value then
                hasValue = true
            end
        end
    end
    return hasValue
end
--获取区域战buff的值
function G_getLocalWarBuffValue(buffId)
    if buffId and localWarCfg and localWarCfg.buff and localWarCfg.buff[buffId] then
        local cfg = localWarCfg.buff[buffId]
        return cfg.value
    end
    return 0
end

--发送聊天战报
function G_sendReportChat(layerNum, content, report, battleReportType, landform)
    --检测是否被禁言
    if chatVoApi:canChat(layerNum) == false then
        do return end
    end
    
    local playerLv = playerVoApi:getPlayerLevel()
    local timeInterval = playerCfg.chatLimitCfg[playerLv] or 0
    local diffTime = 0
    if base.lastSendTime then
        diffTime = base.serverTime - base.lastSendTime
    end
    --[[
    if diffTime>0 and diffTime<timeInterval then
        --smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("time_limit_prompt",{timeInterval-diffTime}),30)
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("time_limit_prompt",{timeInterval-diffTime}),true,self.layerNum+1)
        do return end
    end
    ]]
    local canSand
    if diffTime >= timeInterval then
        canSand = true
    end
    if canSand == nil or canSand == false then
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("time_limit_prompt", {timeInterval - diffTime}), true, layerNum + 1)
        do return end
    end
    
    local sender = playerVoApi:getUid()
    local chatContent = content
    if chatContent == nil then
        chatContent = ""
    end
    --如果有联盟，选择联盟还是世界；没有则世界发送到世界 1为世界
    if report then
        local hasAlliance = allianceVoApi:isHasAlliance()
        local reportData = {}
        reportData = report
        -- for k,v in pairs(report) do
        --     if k=="resource" then
        --         local resData={u={}}
        --         if v and SizeOfTable(v)>0 then
        --             for m,n in pairs(v) do
        --                 if resData.u[m]==nil then
        --                     resData.u[m]={}
        --                 end
        --                 resData.u[m][n.key]=n.num
        --             end
        --         end
        --         reportData[k]=resData
        --     elseif k=="award" then
        --         reportData[k]={}
        --         if report.report and report.report.r and type(report.report.r)=="table" then
        --             reportData[k]=report.report.r
        --         end
        --     elseif k=="lostShip" then
        --         local defLost={o={}}
        --         local attLost={o={}}
        --         local attTotal={o={}}
        --         local defTotal={o={}}
        --         if v and v.defenderLost then
        --             for m,n in pairs(v.defenderLost) do
        --                 if defLost.o[m]==nil then
        --                     defLost.o[m]={}
        --                 end
        --                 defLost.o[m][n.key]=n.num
        --             end
        --         end
        --         if v and v.attackerLost then
        --             for m,n in pairs(v.attackerLost) do
        --                 attLost.o[m]={}
        --                 if attLost.o[m]==nil then
        --                     attLost.o[m]={}
        --                 end
        --                 attLost.o[m][n.key]=n.num
        --             end
        --         end
        --         if v and v.attackerTotal then
        --             for m,n in pairs(v.attackerTotal) do
        --                 attTotal.o[m]={}
        --                 if attTotal.o[m]==nil then
        --                     attTotal.o[m]={}
        --                 end
        --                 attTotal.o[m][n.key]=n.num
        --             end
        --         end
        --         if v and v.defenderTotal then
        --             for m,n in pairs(v.defenderTotal) do
        --                 defTotal.o[m]={}
        --                 if defTotal.o[m]==nil then
        --                     defTotal.o[m]={}
        --                 end
        --                 defTotal.o[m][n.key]=n.num
        --             end
        --         end
        --         reportData[k]={}
        --         reportData[k]["defenderLost"]=defLost
        --         reportData[k]["attackerLost"]=attLost
        --         reportData[k]["attackerTotal"]=attTotal
        --         reportData[k]["defenderTotal"]=defTotal
        --     else
        --         reportData[k]=v
        --     end
        -- end
        if hasAlliance == false then
            base.lastSendTime = base.serverTime
            
            local senderName = playerVoApi:getPlayerName()
            local level = playerVoApi:getPlayerLevel()
            local rank = playerVoApi:getRank()
            local language = G_getCurChoseLanguage()
            local params = {subType = 1, contentType = 2, message = chatContent, level = level, rank = rank, power = playerVoApi:getPlayerPower(), uid = playerVoApi:getUid(), name = playerVoApi:getPlayerName(), pic = playerVoApi:getPic(), report = reportData, ts = base.serverTime, vip = playerVoApi:getVipLevel(), language = language, wr = playerVoApi:getServerWarRank(), st = playerVoApi:getServerWarRankStartTime(), landform = landform}
            if battleReportType then
                params.brType = battleReportType
            end
            chatVoApi:sendChatMessage(1, sender, senderName, 0, "", params)
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("read_email_report_share_sucess"), 28)
        else
            local function sendReportHandle(tag, object)
                base.lastSendTime = base.serverTime
                local channelType = tag or 1
                
                local senderName = playerVoApi:getPlayerName()
                local level = playerVoApi:getPlayerLevel()
                local rank = playerVoApi:getRank()
                local allianceName
                local allianceRole
                if allianceVoApi:isHasAlliance() then
                    local allianceVo = allianceVoApi:getSelfAlliance()
                    allianceName = allianceVo.name
                    allianceRole = allianceVo.role
                end
                local language = G_getCurChoseLanguage()
                local params = {subType = channelType, contentType = 2, message = chatContent, level = level, rank = rank, power = playerVoApi:getPlayerPower(), uid = playerVoApi:getUid(), name = playerVoApi:getPlayerName(), pic = playerVoApi:getPic(), report = reportData, ts = base.serverTime, allianceName = allianceName, allianceRole = allianceRole, vip = playerVoApi:getVipLevel(), language = language, wr = playerVoApi:getServerWarRank(), st = playerVoApi:getServerWarRankStartTime(), landform = landform}
                if battleReportType then
                    params.brType = battleReportType
                end
                local aid = playerVoApi:getPlayerAid()
                if channelType == 1 then
                    chatVoApi:sendChatMessage(1, sender, senderName, 0, "", params)
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("read_email_report_share_sucess"), 28)
                elseif aid then
                    chatVoApi:sendChatMessage(aid + 1, sender, senderName, 0, "", params)
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("read_email_report_share_sucess"), 28)
                end
            end
            allianceSmallDialog:selectChannelDialog("PanelHeaderPopup.png", CCSizeMake(450, 350), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), true, layerNum + 1, sendReportHandle)
        end
    end
end

function G_weekDayStr(weekDay)
    return getlocal("week_day_"..weekDay)
end

function G_mappingZoneid()
    if G_curPlatName() == "qihoo" or G_curPlatName() == "androidqihoohjdg" then
        if tonumber(base.curZoneID) == 1000 or tonumber(base.curZoneID) == 997 or tonumber(base.curZoneID) == 998 then
            do return base.curZoneID end
        end
        if tonumber(base.curZoneID) >= 220 and tonumber(base.curZoneID) < 1000 then
            do
                return tostring(tonumber(base.curZoneID) - 94)
            end
        end
    end
    return base.curZoneID
end

global = {
    tickIndex = 999,
    needSync = false,
    lastPlayMouseClickEffectTime = 0,
    waitLayer = nil,
    netWaitLayer = nil,
    waitParent = nil,
    lastWaitTime = 0,
    loginTickHandler,
    exitForAndroidFlag = 0,
    rechargeFailedNoticed = false,
    accountIsBind = false, --账号是否是绑定过的账号，快用等平台会传给游戏
    hasAllianceFunc = true,
}

function global:tick()
    self.tickIndex = self.tickIndex + 1
    if self.needSync == true and self.tickIndex == 3 then
        self.needSync = false
        G_SyncData()
    end
end

function global:showLoginLoading(showAnim)
    if self.waitLayer ~= nil then
        do
            return
        end
    end
    self.waitLayer = CCLayer:create()
    self.waitLayer:setTouchEnabled(true)
    self.waitLayer:setBSwallowsTouches(true)
    self.waitLayer:setTouchPriority(-188)
    self.waitLayer:setContentSize(G_VisibleSize)
    self.waitParent = CCDirector:sharedDirector():getRunningScene()
    CCDirector:sharedDirector():getRunningScene():addChild(self.waitLayer)
    
    if self.netWaitLayer ~= nil then
        do
            return
        end
    end
    local function tmpFunc()
        
    end
    
    self.netWaitLayer = LuaCCSprite:createWithSpriteFrameName("BlackAlphaBg.png", tmpFunc)
    self.netWaitLayer:setOpacity(0)
    self.netWaitLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.netWaitLayer:setPosition(ccp(G_VisibleSize.width / 2, G_VisibleSize.height / 2))
    self.netWaitLayer:setScale(50)
    self.netWaitLayer:setTouchPriority(-128)
    
    local pzFrameName = "loading1.png" --loading动画
    local metalSp = CCSprite:createWithSpriteFrameName(pzFrameName)
    local pzArr = CCArray:create()
    for kk = 1, 10 do
        local nameStr = "loading"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        pzArr:addObject(frame)
    end
    local animation = CCAnimation:createWithSpriteFrames(pzArr)
    animation:setDelayPerUnit(0.1)
    local animate = CCAnimate:create(animation)
    metalSp:setAnchorPoint(ccp(0.5, 0.5))
    metalSp:setScale(1 / 50)
    metalSp:setPosition(ccp(self.netWaitLayer:getContentSize().width / 2, self.netWaitLayer:getContentSize().height / 2))
    self.netWaitLayer:addChild(metalSp)
    local repeatForever = CCRepeatForever:create(animate)
    if showAnim == nil or showAnim == true then
        metalSp:runAction(repeatForever)
    else
        --local waitLb=GetTTFLabel("请稍后...",30)
        local waitLb = GetTTFLabel(getlocal("showLoading"), 30)
        waitLb:setColor(G_ColorYellowPro)
        waitLb:setPosition(ccp(G_VisibleSize.width / 2, G_VisibleSize.height / 2 - 90))
        
        self.waitLayer:addChild(waitLb, 20)
    end
    CCDirector:sharedDirector():getRunningScene():addChild(self.netWaitLayer, 100)
end

--获取用户的平台ID
function G_getUserPlatID()
    return base.platformUserId == nil and G_getTankUserName() or base.platformUserId
end

function global:cancleLoginLoading()
    local curScene = CCDirector:sharedDirector():getRunningScene()
    if(self.waitParent ~= curScene)then
        self.waitLayer = nil
        self.netWaitLayer = nil
        do return end
    end
    if self.waitLayer ~= nil then
        self.waitLayer = tolua.cast(self.waitLayer, "CCNode")
        if(self.waitLayer)then
            self.waitLayer:removeFromParentAndCleanup(true)
        end
        self.waitLayer = nil
    end
    if self.netWaitLayer ~= nil then
        self.netWaitLayer = tolua.cast(self.netWaitLayer, "CCNode")
        if(self.netWaitLayer)then
            self.netWaitLayer:removeFromParentAndCleanup(true)
        end
        self.netWaitLayer = nil
    end
end

function G_isKakao()
    if(G_curPlatName() == "androidkakaonaver" or G_curPlatName() == "androidkakaotstore" or G_curPlatName() == "androidkakaogoogle")then
        return true
    else
        return false
    end
end

function G_isArab()
    if(G_curPlatName() == "21" or G_curPlatName() == "androidarab")then
        return true
    else
        return false
    end
end

G_checkCodeKey = "checkcodeNum"
G_lastCheckCodeKey = "lastCheckcodeNum"
G_lastMapscoutTime = "lastmapscouttime"
G_maxCheckCount = 4999
-- 是否需要显示验证码
function G_isCheckCode()
    -- do return true end
    local checkcodeNum = 0
    local lastCheckcodeNum = 0
    -- print("base.isCheckCode================="..base.isCheckCode)
    if base.isCheckCode == 1 then
        -- 先判断是否跨天
        local lastmapscouttime = CCUserDefault:sharedUserDefault():getIntegerForKey(G_lastMapscoutTime..playerVoApi:getUid())
        -- print("base.serverTime=========="..base.serverTime)
        -- print("lastmapscouttime=========="..lastmapscouttime)
        -- print("G_isToday(lastmapscouttime)===",G_isToday(lastmapscouttime))
        -- print("-----------dmj----------checkcodeNum:"..checkcodeNum.."   base.serverTime:"..base.serverTime.."   lastmapscouttime:"..lastmapscouttime)
        if lastmapscouttime > 0 and G_isToday(lastmapscouttime) == false then
            -- 如果跨天了，计数器重置
            CCUserDefault:sharedUserDefault():setIntegerForKey(G_checkCodeKey..playerVoApi:getUid(), 0)
            CCUserDefault:sharedUserDefault():setIntegerForKey(G_lastCheckCodeKey..playerVoApi:getUid(), 0)
            CCUserDefault:sharedUserDefault():setIntegerForKey(G_lastMapscoutTime..playerVoApi:getUid(), base.serverTime)
            CCUserDefault:sharedUserDefault():flush()
            return false
        end
        lastCheckcodeNum = CCUserDefault:sharedUserDefault():getIntegerForKey(G_lastCheckCodeKey..playerVoApi:getUid())
        checkcodeNum = CCUserDefault:sharedUserDefault():getIntegerForKey(G_checkCodeKey..playerVoApi:getUid())
        -- print("lastCheckcodeNum================"..lastCheckcodeNum)
        -- print("checkcodeNum================"..checkcodeNum)
        -- if (lastCheckcodeNum<20 and checkcodeNum>=20) or (lastCheckcodeNum<30 and checkcodeNum>=30) or (lastCheckcodeNum<40 and checkcodeNum>=40) or (lastCheckcodeNum<50 and checkcodeNum>=50) or (lastCheckcodeNum<G_maxCheckCount and checkcodeNum>=G_maxCheckCount) then
        --     return true
        -- end
        -- if checkcodeNum%2==0 then
        -- if (checkcodeNum+1)==5 or (checkcodeNum+1)==10 or (checkcodeNum+1)==20 or (checkcodeNum+1)==35 or (checkcodeNum+1)==50 then
        
        if (lastCheckcodeNum < 499 and checkcodeNum >= 499) or (lastCheckcodeNum < 999 and checkcodeNum >= 999) or (lastCheckcodeNum < 1999 and checkcodeNum >= 1999) or (lastCheckcodeNum < 3499 and checkcodeNum >= 3499) or (lastCheckcodeNum < G_maxCheckCount and checkcodeNum >= G_maxCheckCount) then
            return true
        end
        --如果大于4999的话，就每隔1000次弹出一次验证码，但是不给奖励
        if checkcodeNum > G_maxCheckCount then
            if checkcodeNum - G_maxCheckCount >= 1000 then
                return true
            end
        end
    end
    --如果没有达到领取验证码次数的话直接更新lastCheckcodeNum,如果达到了则在领取了验证码奖励后更新lastCheckcodeNum
    CCUserDefault:sharedUserDefault():setIntegerForKey(G_lastCheckCodeKey..playerVoApi:getUid(), checkcodeNum)
    CCUserDefault:sharedUserDefault():flush()
    return false
end

-- 是否显示新建筑和新地图，0不显示新的，1显示新UI
function G_isShowNewMapAndBuildings()
    -- if platCfg.platCfgShowNewMapAndBuildings[G_curPlatName()]~=nil and platCfg.platCfgShowNewMapAndBuildings[G_curPlatName()]==1 then
    --     return 1
    -- end
    return 0
end

-- 精英坦克映射列表（精英坦克返回映射的普通坦克id,普通坦克返回自己本身）
g_pickedList = {[50001] = 10001, [50002] = 10002, [50003] = 10003, [50004] = 10004, [50005] = 10005, [50006] = 10006, [50007] = 10007, [50008] = 10008, [50011] = 10011, [50012] = 10012, [50013] = 10013, [50014] = 10014, [50015] = 10015, [50016] = 10016, [50017] = 10017, [50018] = 10018, [50021] = 10021, [50022] = 10022, [50023] = 10023, [50024] = 10024, [50025] = 10025, [50026] = 10026, [50027] = 10027, [50028] = 10028, [50031] = 10031, [50032] = 10032, [50033] = 10033, [50034] = 10034, [50035] = 10035, [50036] = 10036, [50037] = 10037, [50038] = 10038, [50043] = 10043, [50044] = 10044, [50045] = 10045, [50053] = 10053, [50054] = 10054, [50063] = 10063, [60065] = 20065, [50064] = 10064, [50073] = 10073, [50074] = 10074, [50075] = 10075, [50082] = 10082, [50083] = 10083, [50084] = 10084, [50093] = 10093, [50094] = 10094, [50095] = 10095, [50103] = 10103, [50104] = 10104, [50113] = 10113, [50114] = 10114, [50123] = 10123, [50124] = 10124, [50133] = 10133, [50134] = 10134, [50135] = 10135, [50143] = 10143, [50144] = 10144, [50145] = 10145, [50163] = 10163, [50164] = 10164, [50165] = 10165, [60044] = 20044, [60054] = 20054, [60064] = 20064, [60074] = 20074, [60083] = 20083, [60094] = 20094, [60114] = 20114, [60115] = 20115, [60124] = 20124, [60153] = 20153, [60154] = 20154, [60155] = 20155, [60055] = 20055, [60125] = 20125}
function G_pickedList(tid)
    if g_pickedList[tid] then
        return g_pickedList[tid]
    end
    return tid
end
--type 类型：1小图标，2大图标
function G_getETankIcon(type, tid, callback)
    if tid and tankCfg[tid] and tankCfg[tid].icon then
        local function clickHandler(object, name, tag)
            if callback then
                callback(object, name, tag)
            end
        end
        local icon = LuaCCSprite:createWithSpriteFrameName(tankCfg[tid].icon, clickHandler)
        if icon then
            if id ~= G_pickedList(tid) then
                local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                icon:addChild(pickedIcon)
                if type == 1 then
                    pickedIcon:setPosition(icon:getContentSize().width - 30, 30)
                    pickedIcon:setScale(1.5)
                elseif type == 2 then
                    pickedIcon:setPosition(icon:getContentSize().width * 0.7, icon:getContentSize().height * 0.5 - 20)
                end
            end
            return icon
        end
    end
    return nil
end

-- closeFlag 是否关闭现在所有的板子 index 标识打开哪个页签
function G_goToDialog(type, layerNum, closeFlag, index, subType, delayFlag)
    if type == "cn" then -- 关卡
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        
        storyScene:setShow()
        local sid = checkPointVoApi:getUnlockNum()
        require "luascript/script/game/scene/gamedialog/checkPointDialog"
        local cpd = checkPointDialog:new(sid)
        storyScene.checkPointDialog[1] = cpd
        local cd = cpd:init("panelBg.png", true, CCSizeMake(768, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, getlocal("checkPoint"), true, layerNum)
        sceneGame:addChild(cd, layerNum)
    elseif type == "pp" or type == "fa" then -- 世界地图
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        mainUI:changeToWorld()
    elseif type == "pe" then -- 世界地图
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        mainUI:changeToWorld()
    elseif type == "au" or type == "ge" or type == "accessory" then -- 配件
        if base.ifAccessoryOpen == 0 or accessoryVoApi:getTechSkillMaxLv() == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage6004"), 30)
            do return end
        end
        if (playerVoApi:getPlayerLevel() < accessoryCfg.accessoryUnlockLv) then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("elite_challenge_unlock_level", {accessoryCfg.accessoryUnlockLv}), 30)
            do return end
        end
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        accessoryVoApi:showAccessoryDialog(sceneGame, layerNum, index)
    elseif type == "ab" or type == "av" then -- 补给线
        if base.ifAccessoryOpen == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage6004"), 30)
            do return end
        end
        if (playerVoApi:getPlayerLevel() < accessoryCfg.accessoryUnlockLv) then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("elite_challenge_unlock_level", {accessoryCfg.accessoryUnlockLv}), 30)
            do return end
        end
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        accessoryVoApi:showSupplyDialog(layerNum)
    elseif type == "aj" then -- 精炼
        if base.ifAccessoryOpen == 0 or accessoryVoApi:switchIsOpen() == false then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("succinct_false"), 30)
            do return end
        end
        
        if playerVoApi:getPlayerLevel() < 50 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("elite_challenge_unlock_level", {50}), 30)
            do return end
        end
        
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        
        accessoryVoApi:showAccessoryDialog(sceneGame, layerNum)
        
    elseif type == "hy" or type == "ht" then -- 装备研究所
        if base.heroSwitch == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("heroSwitch_false"), 30)
            do return end
        end
        
        if base.he == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("he_false"), 30)
            do return end
        end
        local equipOpenLv = base.heroEquipOpenLv or 30
        if (playerVoApi:getPlayerLevel() < equipOpenLv) then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("elite_challenge_unlock_level", {equipOpenLv}), 30)
            do return end
        end
        
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        if type == "ht" then
            subType = "equipExplore"
        end
        if subType and subType == "equipExplore" then
            heroEquipChallengeVoApi:openExploreDialog(nil, nil, layerNum + 1)
            do return end
        end
        
        if subType and subType == "equipExplore" then
            heroEquipChallengeVoApi:openExploreDialog(nil, nil, layerNum + 1)
            do return end
        end
        
        local function openHeroEquipDialog()
            if heroEquipVoApi and heroEquipVoApi.heroOpenFlag == true then
                do return end
            end
            require "luascript/script/game/scene/gamedialog/heroDialog/heroTotalDialog"
            local td = heroTotalDialog:new()
            local tbArr = {}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("sample_build_name_12"), true, 3)
            sceneGame:addChild(dialog, 3)
            
            if type == "hy" then
                local function openEquipLab(...)
                    heroEquipVoApi:openEquipLabDialog(layerNum)
                end
                
                local function callbackHandler4()
                    openEquipLab()
                end
                if heroEquipVoApi and heroEquipVoApi.ifNeedSendRequest == true then
                    heroEquipVoApi:equipGet(callbackHandler4)
                else
                    openEquipLab()
                end
            else
                heroEquipChallengeVoApi:openExploreDialog(nil, nil, layerNum)
            end
        end
        
        local delay = CCDelayTime:create(0.4)
        local callFunc = CCCallFunc:create(openHeroEquipDialog)
        local acArr = CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(callFunc)
        local seq = CCSequence:create(acArr)
        sceneGame:runAction(seq)
        
    elseif type == "hu" then -- 将领装备
        if base.heroSwitch == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("heroSwitch_false"), 30)
            do return end
        end
        
        if base.he == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("he_false"), 30)
            do return end
        end
        local equipLv = base.heroEquipOpenLv or 30
        if (playerVoApi:getPlayerLevel() < equipLv) then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("elite_challenge_unlock_level", {equipLv}), 30)
            do return end
        end
        
        local function openHeroEquipDialog()
            require "luascript/script/game/scene/gamedialog/heroDialog/heroTotalDialog"
            local td = heroTotalDialog:new()
            local tbArr = {}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("sample_build_name_12"), true, 3)
            sceneGame:addChild(dialog, 3)
            
            require "luascript/script/game/scene/gamedialog/heroDialog/heroManagerDialog"
            local td = heroManagerDialog:new()
            local tbArr = {}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("heroManage"), true, layerNum)
            sceneGame:addChild(dialog, layerNum)
        end
        
        local function openHandler()
            if closeFlag then
                activityAndNoteDialog:closeAllDialog()
                local delay = CCDelayTime:create(0.4)
                local callFunc = CCCallFunc:create(openHeroEquipDialog)
                local acArr = CCArray:create()
                acArr:addObject(delay)
                acArr:addObject(callFunc)
                local seq = CCSequence:create(acArr)
                sceneGame:runAction(seq)
            else
                openHeroEquipDialog()
            end
        end
        
        local heroEquipOpenLv = base.heroEquipOpenLv or 30
        if base.he == 1 and playerVoApi:getPlayerLevel() >= heroEquipOpenLv then
            if heroEquipVoApi and heroEquipVoApi.ifNeedSendRequest == true then
                local function callbackHandler()
                    openHandler()
                end
                heroEquipVoApi:equipGet(callbackHandler)
            else
                openHandler()
            end
        else
            openHandler()
        end
    elseif type == "mb" or type == "mw" or type == "mc" then -- 军事演习
        
        if base.ifMilitaryOpen == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("arena_noOpen"), 30)
            do
                return
            end
        end
        local limitLv = 10
        if playerVoApi:getPlayerLevel() < limitLv then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("arena_limit", {limitLv}), 30)
            do
                return
            end
        end
        
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        
        local function openArenaDialog()
            require "luascript/script/game/scene/gamedialog/arenaDialog/arenaTotalDialog"
            local td = arenaTotalDialog:new()
            local tbArr = {}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("arena_total"), true, 3)
            sceneGame:addChild(dialog, 3)
            
            G_openArenaDialog(layerNum)
        end
        local delay = CCDelayTime:create(0.4)
        local callFunc = CCCallFunc:create(openArenaDialog)
        local acArr = CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(callFunc)
        local seq = CCSequence:create(acArr)
        sceneGame:runAction(seq)
        
    elseif type == "we" or type == "wp" or type == "wh" or type == "weapon" then -- 超级武器
        if base.ifSuperWeaponOpen == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("ifSuperWeaponOpen_false"), 30)
            do
                return
            end
        end
        local openLv = base.superWeaponOpenLv or 25
        if playerVoApi:getPlayerLevel() < openLv then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("port_scene_building_tip_102", {openLv}), 30)
            do
                return
            end
        end
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        
        local function openSWDialog()
            if superWeaponVoApi and superWeaponVoApi.showMainDialog then
                superWeaponVoApi:showMainDialog(3)
            end
            if subType then
                if subType == "rob" then --超级武器掠夺
                    local swChallengeVo = superWeaponVoApi:getSWChallenge()
                    
                    superWeaponVoApi:showRobDialog(layerNum + 1)
                    -- do return end
                elseif subType == "challenge" then --神秘组织
                    superWeaponVoApi:showFinalChallengeDialog(layerNum + 1)
                    -- do return end
                end
            end
        end
        if delayFlag == false then
            openSWDialog()
        else
            local delay = CCDelayTime:create(0.4)
            local callFunc = CCCallFunc:create(openSWDialog)
            local acArr = CCArray:create()
            acArr:addObject(delay)
            acArr:addObject(callFunc)
            local seq = CCSequence:create(acArr)
            sceneGame:runAction(seq)
        end
        
    elseif type == "rg" then -- 在异星科技中赠送X次礼物
        if base.alien == 0 or base.richMineOpen == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage16000"), 30)
            do
                return
            end
        end
        
        local playerLv = playerVoApi:getPlayerLevel()
        if playerLv < alienTechCfg.openlevel then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alien_tech_unlock_player_level", {alienTechCfg.openlevel}), 30)
            do
                return
            end
        end
        
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        
        require "luascript/script/game/scene/gamedialog/alienTechDialog/alienTechDialog"
        local td = alienTechDialog:new(true)
        local tbArr = {getlocal("alien_tech_sub_title1"), getlocal("alien_tech_sub_title2"), getlocal("alien_tech_sub_title3")}
        local vd = td:init("panelBg.png", true, CCSizeMake(768, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("alien_tech_title"), true, 3)
        sceneGame:addChild(vd, 3)
    elseif type == "rb" then -- 攻打X次富矿
        if base.landFormOpen == 0 or base.richMineOpen == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("richMineOpen_false"), 30)
            do
                return
            end
        end
        
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        mainUI:changeToWorld()
        
    elseif type == "rc" then -- 进行X次异星科技开发
        if base.alien == 0 or base.richMineOpen == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage16000"), 30)
            do
                return
            end
        end
        
        local playerLv = playerVoApi:getPlayerLevel()
        if playerLv < alienTechCfg.openlevel then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("alien_tech_unlock_player_level", {alienTechCfg.openlevel}), 30)
            do
                return
            end
        end
        
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        
        require "luascript/script/game/scene/gamedialog/alienTechDialog/alienTechDialog"
        local td = alienTechDialog:new()
        local tbArr = {getlocal("alien_tech_sub_title1"), getlocal("alien_tech_sub_title2"), getlocal("alien_tech_sub_title3")}
        local vd = td:init("panelBg.png", true, CCSizeMake(768, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("alien_tech_title"), true, 3)
        sceneGame:addChild(vd, 3)
    elseif type == "eb" or type == "er" then -- 远征
        if base.heroSwitch == 0 or base.expeditionSwitch == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage13000"), 30)
            do
                return
            end
        end
        
        local expeditionOpenLv = base.expeditionOpenLv or 25
        if playerVoApi:getPlayerLevel() < expeditionOpenLv then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("expeditionNotEnough", {expeditionOpenLv}), 30)
            do return end
        end
        
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        
        if subType and subType == "expedition" then
            expeditionVoApi:showExpeditionDialog(layerNum + 1)
            do return end
        end
        require "luascript/script/game/scene/gamedialog/arenaDialog/arenaTotalDialog"
        local td = arenaTotalDialog:new()
        local tbArr = {}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("arena_total"), true, 3)
        sceneGame:addChild(dialog, 3)
        
        local function callback(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                require "luascript/script/game/scene/gamedialog/expedition/expeditionDialog"
                local vrd = expeditionDialog:new()
                local vd = vrd:init(layerNum)
            end
        end
        socketHelper:expeditionGet(callback)
        
    elseif type == "eu" then -- 远征商店
        if base.heroSwitch == 0 or base.expeditionSwitch == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage13000"), 30)
            do
                return
            end
        end
        
        local expeditionOpenLv = base.expeditionOpenLv or 25
        if playerVoApi:getPlayerLevel() < expeditionOpenLv then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("expeditionNotEnough", {expeditionOpenLv}), 30)
            do return end
        end
        
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        
        require "luascript/script/game/scene/gamedialog/arenaDialog/arenaTotalDialog"
        local td = arenaTotalDialog:new()
        local tbArr = {}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("arena_total"), true, 3)
        sceneGame:addChild(dialog, 3)
        
        local function callback(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                require "luascript/script/game/scene/gamedialog/expedition/expeditionDialog"
                local vrd = expeditionDialog:new()
                local vd = vrd:init(layerNum)
                
                local function reCallback(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        -- require "luascript/script/game/scene/gamedialog/expedition/expeditionShopDialog"
                        -- local dialog=expeditionShopDialog:new()
                        -- local layer=dialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("expeditionShop"),true,layerNum+1)
                        -- sceneGame:addChild(layer,layerNum+1)
                        local td = allShopVoApi:showAllPropDialog(layerNum + 1, "expe")
                    end
                end
                
                socketHelper:expeditionGetshop(reCallback)
            end
        end
        socketHelper:expeditionGet(callback)
    elseif type == "gb" then -- 充值
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        vipVoApi:showRechargeDialog(layerNum)
    elseif type == "hero" then -- 将领,军事学院
        if base.heroSwitch == 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("heroSwitch_false"), 30)
            do return end
        end
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        if subType and subType == "recruit" then
            heroVoApi:showHeroRecruitDialog(layerNum + 1)
            do return end
        end
        local function openHeroTotalDialog(...)
            require "luascript/script/game/scene/gamedialog/heroDialog/heroTotalDialog"
            local td = heroTotalDialog:new()
            local tbArr = {}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("sample_build_name_12"), true, 3)
            sceneGame:addChild(dialog, 3)
        end
        if base.he == 1 then
            local equipLv = base.heroEquipOpenLv or 30
            if playerVoApi:getPlayerLevel() >= equipLv and heroEquipVoApi and heroEquipVoApi.ifNeedSendRequest == true and heroEquipChallengeVoApi then
                local function callbackHandler4()
                    openHeroTotalDialog()
                end
                heroEquipVoApi:equipGet(callbackHandler4)
            else
                openHeroTotalDialog()
            end
        else
            openHeroTotalDialog()
        end
    elseif type == "warehouse" then --仓库储备页面
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        require "luascript/script/game/scene/gamedialog/isLandStateDialog"
        local td = isLandStateDialog:new()
        local tbArr = {getlocal("resource"), getlocal("state")}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("islandState"), true, 3)
        sceneGame:addChild(dialog, 3)
    elseif type == "dtroops" then --防守部队
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        require "luascript/script/game/scene/gamedialog/warDialog/tankDefenseDialog"
        local td = tankDefenseDialog:new(layerNum)
        local tbArr = {getlocal("fleetCard"), getlocal("dispatchCard"), getlocal("repair")}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("defenceSetting"), true, layerNum)
        sceneGame:addChild(dialog, layerNum)
        -- td:tabClick(1)
    elseif type == "build" then --跳转至玩家信息页面建造页面
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        local td = playerVoApi:showPlayerDialog(3, layerNum)
        -- td:tabClick(3)
    elseif type == "study" then --跳转科研中心
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        local bid = 3
        local bType = 8
        local buildVo = buildingVoApi:getBuildiingVoByBId(bid)
        if buildVo and buildVo.status >= 0 then
            require "luascript/script/game/scene/gamedialog/portbuilding/techCenterDialog"
            local td = techCenterDialog:new(bid, layerNum, nil, false)
            local bName = getlocal(buildingCfg[bType].buildName)
            local tbArr = {getlocal("building"), getlocal("startResearch")}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName.."("..G_LV()..buildVo.level..")", true, layerNum)
            sceneGame:addChild(dialog, layerNum)
            if index then
                td:tabClick(index)
            else
                td:tabClick(1)
            end
        else
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("port_scene_building_tip_"..tostring(bid - 1)), 30)
            do return end
        end
    elseif type == "tankfactory" then --“坦克工厂”
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        local bid = 11
        local bType = 6
        local buildVo
        if subType then
            bid = tonumber(subType)
            buildVo = buildingVoApi:getBuildiingVoByBId(bid)
        else
            buildVo = buildingVoApi:getBuildingVoByLevel(bType)
            if buildVo == nil then
                buildVo = buildingVoApi:getBuildiingVoByBId(bid)
            end
        end
        if bid and buildVo and buildVo.status >= 0 then
            require "luascript/script/game/scene/gamedialog/portbuilding/tankFactoryDialog"
            local td = tankFactoryDialog:new(bid, dlayerNum, nil, true)
            local bName = getlocal(buildingCfg[bType].buildName)
            local tbArr = {getlocal("buildingTab"), getlocal("startProduce"), getlocal("chuanwu_scene_process")}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, bName.."("..G_LV()..buildVo.level..")", true, layerNum)
            sceneGame:addChild(dialog, layerNum)
            if index then
                td:tabClick(index)
            else
                td:tabClick(1)
            end
        elseif bid then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("port_scene_building_tip_"..tostring(bid - 1)), 30)
            do return end
        end
    elseif type == "emblem" or type == "sequip" then --“军徽”
        if closeFlag then
            activityAndNoteDialog:closeAllDialog()
        end
        if subType and subType == "get" then
            emblemVoApi:showGetDialog(layerNum + 1)
        else
            emblemVoApi:showMainDialog(layerNum)
        end
    end
end

function G_countDigit(nums)--计算位数
    if nums == 0 then
        return tostring(0)
    end
    local numsStr = ""
    while(nums > 0) do
        if nums < 1000 then
            numsStr = nums..numsStr
            nums = 0
        else
            
            local lastNums = math.mod(nums, 1000)
            if lastNums >= 0 then
                if lastNums < 10 then
                    lastNums = "00"..lastNums
                elseif lastNums < 100 then
                    lastNums = "0"..lastNums
                end
                numsStr = ","..lastNums..numsStr
            end
            nums = math.floor(nums / 1000)
            
        end
    end
    return numsStr
end

-- 是否为压缩资源的包，true是，false否
function G_isCompressResVersion()
    if platCfg.platCfgUseCompressRes and platCfg.platCfgUseCompressRes[G_curPlatName()] then
        local cfg = platCfg.platCfgUseCompressRes[G_curPlatName()]
        local cfgType = type(cfg)
        if(cfgType == "number")then
            if(G_Version >= cfg) then
                return true
            end
        elseif(cfgType == "table")then
            if(G_Version >= cfg[1] and G_Version <= cfg[2])then
                return true
            end
        end
        return true
    end
    return false
end

--是否显示行军路线
function G_isShowLineSprite()
    if LineSprite ~= nil then
        return true
    end
    return false
end

-- 不带背景的资源和异星资源图标
function G_getNoBgResIcon(item)
    local resIcon
    if item and item.key and item.type then
        if item.type == "u" then
            if item.key == "r1" then
                resIcon = CCSprite:createWithSpriteFrameName("IconCopper.png")
            elseif item.key == "r2" then
                resIcon = CCSprite:createWithSpriteFrameName("IconOil.png")
            elseif item.key == "r3" then
                resIcon = CCSprite:createWithSpriteFrameName("IconIron.png")
            elseif item.key == "r4" then
                resIcon = CCSprite:createWithSpriteFrameName("IconOre.png")
            elseif item.key == "gold" then
                resIcon = CCSprite:createWithSpriteFrameName("IconCrystal-.png")
            elseif item.key == "gems" or item.key == "gem" then
                resIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
            end
            resIcon:setScale(1.2)
        elseif item.type == "r" then
            local resId = RemoveFirstChar(item.key)
            local pic = "alien_mines"..resId.."_"..resId..".png"
            resIcon = CCSprite:createWithSpriteFrameName(pic)
            resIcon:setScale(0.5)
        end
    end
    return resIcon
end
-- 解析propCfg
function G_rewardFromPropCfg(key)
    local cfg = propCfg[key]
    local reward = {}
    -- 使用获得道具
    if cfg.useGetProp then
        for k, v in pairs(cfg.useGetProp) do
            local key = v[1]
            local num = v[2]
            local type = "p"
            local name, pic, desc, id, index, eType, equipId, bgname = getItem(key, type)
            table.insert(reward, {name = name, num = num, pic = pic, desc = desc, id = id, type = type, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname})
        end
    end
    -- 使用获得资源
    if cfg.useGetResource then
        for k, v in pairs(cfg.useGetResource) do
            local key = k
            local num = v
            local type = "u"
            local name, pic, desc, id, index, eType, equipId, bgname = getItem(key, type)
            table.insert(reward, {name = name, num = num, pic = pic, desc = desc, id = id, type = type, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname})
        end
    end
    -- 使用获得配件
    if cfg.useGetAccessory then
        for k, v in pairs(cfg.useGetAccessory) do
            local key = k
            local num = v
            local type = "e"
            local name, pic, desc, id, index, eType, equipId, bgname = getItem(key, type)
            table.insert(reward, {name = name, num = num, pic = pic, desc = desc, id = id, type = type, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname})
        end
    end
    --  使用获得配件碎片
    if cfg.useGetFragment then
        for k, v in pairs(cfg.useGetFragment) do
            local key = k
            local num = v
            local type = "e"
            local name, pic, desc, id, index, eType, equipId, bgname = getItem(key, type)
            table.insert(reward, {name = name, num = num, pic = pic, desc = desc, id = id, type = type, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname})
        end
    end
    --  使用获得部队
    if cfg.useGetTroops then
        for k, v in pairs(cfg.useGetTroops) do
            local key = k
            local num = v
            local type = "o"
            local name, pic, desc, id, index, eType, equipId, bgname = getItem(key, type)
            table.insert(reward, {name = name, num = num, pic = pic, desc = desc, id = id, type = type, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname})
        end
    end
    --  使用获得配件道具
    if cfg.useGetAccessoryProp then
        for k, v in pairs(cfg.useGetAccessoryProp) do
            local key = k
            local num = v
            local type = "e"
            local name, pic, desc, id, index, eType, equipId, bgname = getItem(key, type)
            table.insert(reward, {name = name, num = num, pic = pic, desc = desc, id = id, type = type, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname})
        end
    end
    -- useGetHeroPoint 使用获得将领经验点数
    if cfg.useGetHeroPoint then -- 不处理
    end
    -- useGetHero 使用获得将领
    if cfg.useGetHero then
        for k, v in pairs(cfg.useGetHero) do
            local key = k
            local num = v
            local type = "h"
            local name, pic, desc, id, index, eType, equipId, bgname = getItem(key, type)
            table.insert(reward, {name = name, num = num, pic = pic, desc = desc, id = id, type = type, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname})
        end
    end
    -- useGetAlienRes 使用获得异星科技资源
    if cfg.useGetAlienRes then
        for k, v in pairs(cfg.useGetAlienRes) do
            local key = k
            local num = v
            local type = "r"
            local name, pic, desc, id, index, eType, equipId, bgname = getItem(key, type)
            table.insert(reward, {name = name, num = num, pic = pic, desc = desc, id = id, type = type, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname})
        end
    end
    -- useGetTitle 使用获得称号
    if cfg.useGetTitle then -- 不处理
    end
    -- usegetHead 使用获得头像
    if cfg.useGetHead then -- 不处理
    end
    -- useGetWeapon 使用获得超级武器相关
    if cfg.useGetWeapon then -- 不处理
    end
    -- useGetWeaponRes 使用获得超级武器相关
    if cfg.useGetWeaponRes then
        for k, v in pairs(cfg.useGetWeaponRes) do
            local key = k
            local num = v
            local type = "w"
            local name, pic, desc, id, index, eType, equipId, bgname = getItem(key, type)
            table.insert(reward, {name = name, num = num, pic = pic, desc = desc, id = id, type = type, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname})
        end
    end
    -- useGetUserarenaRes
    if cfg.useGetUserarenaRes then
        for k, v in pairs(cfg.useGetUserarenaRes) do
            local key = k
            local num = v
            local type = "m"
            local name, pic, desc, id, index, eType, equipId, bgname = getItem(key, type)
            table.insert(reward, {name = name, num = num, pic = pic, desc = desc, id = id, type = type, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname})
        end
    end
    -- useGetExpeditionRes
    if cfg.useGetExpeditionRes then
        for k, v in pairs(cfg.useGetExpeditionRes) do
            local key = k
            local num = v
            local type = "n"
            local name, pic, desc, id, index, eType, equipId, bgname = getItem(key, type)
            table.insert(reward, {name = name, num = num, pic = pic, desc = desc, id = id, type = type, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname})
        end
    end
    -- useGetEquipRes
    if cfg.useGetEquipRes then
        for k, v in pairs(cfg.useGetEquipRes) do
            local key = k
            local num = v
            local type = "f"
            local name, pic, desc, id, index, eType, equipId, bgname = getItem(key, type)
            table.insert(reward, {name = name, num = num, pic = pic, desc = desc, id = id, type = type, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname})
        end
    end
    
    if cfg.useGetPool then
        for k, v in pairs(cfg.useGetPool[3]) do
            local arr = Split(v[1], "_")
            local key = arr[2]
            local num = v[2]
            local type = G_rewardType(arr[1])
            -- if arr[1]=="props" then
            --     type="p"
            -- elseif arr[1]=="accessory" then
            --     type="e"
            -- elseif arr[1]=="troops" then
            --     type="o"
            -- elseif arr[1]=="userinfo" then
            --     type="u"
            -- elseif arr[1]=="hero" then
            --     type="h"
            -- elseif arr[1]=="alien" then
            --     type="r"
            -- elseif arr[1]=="weapon" then
            --     type="w"
            -- elseif arr[1]=="equip" then
            --     type="f"
            -- elseif arr[1]=="userarena" then
            --     type="m"
            -- elseif arr[1]=="userexpedition" then
            --     type="n"
            -- end
            local name, pic, desc, id, index, eType, equipId, bgname = getItem(key, type)
            table.insert(reward, {name = name, num = num, pic = pic, desc = desc, id = id, type = type, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname})
        end
    end
    if cfg.useGetOne then
        for k, v in pairs(cfg.useGetOne) do
            local arr = Split(v[1], "_")
            local key = arr[2]
            local num = v[2]
            local type = G_rewardType(arr[1])
            local name, pic, desc, id, index, eType, equipId, bgname = getItem(key, type)
            table.insert(reward, {name = name, num = num, pic = pic, desc = desc, id = id, type = type, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname})
        end
    end
    if cfg.useGetArmor then
        for k, v in pairs(cfg.useGetArmor) do
            local key = k
            local num = v
            local type = "am"
            if(k == "exp")then
                local name, pic, desc, id, index, eType, equipId, bgname = getItem(key, type, num)
                table.insert(reward, {name = name, num = num, pic = pic, desc = desc, id = id, type = type, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname})
            else
                local name, pic, desc, id, index, eType, equipId, bgname = getItem(key, type)
                table.insert(reward, {name = name, num = num, pic = pic, desc = desc, id = id, type = type, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname})
            end
        end
    end
    if cfg.useGetPlaneSkill then
        for k, v in pairs(cfg.useGetPlaneSkill) do
            local key = k
            local num = v
            local type = "pl"
            local name, pic, desc, id, index, eType, equipId, bgname = getItem(key, type)
            table.insert(reward, {name = name, num = num, pic = pic, desc = desc, id = id, type = type, index = index, key = key, eType = eType, equipId = equipId, bgname = bgname})
        end
    end
    if cfg.useGetAll then --获取头像、头像框、聊天气泡
        for k, v in pairs(cfg.useGetAll) do
            local tempV = Split(v[1], "_")
            local vId = tempV[2]
            local itemNum = v[2]
            local itemType = "l"
            local itemKey
            if tempV[1] == "head" then --头像
                itemKey = "a" .. vId
            elseif tempV[1] == "headframe" then --头像框
                itemKey = "h" .. vId
            elseif tempV[1] == "chatframe" then --聊天气泡
                itemKey = "c" .. vId
            end
            if itemKey then
                local name, pic, desc, id, index, eType, equipId, bgname = getItem(itemKey, itemType)
                table.insert(reward, {name = name, num = itemNum, pic = pic, desc = desc, id = id, type = itemType, index = index, key = itemKey, eType = eType, equipId = equipId, bgname = bgname})
            end
        end
    end
    return reward
end

function G_rewardType(markStr)
    local markType
    if markStr == "props" then
        markType = "p"
    elseif markStr == "accessory" then
        markType = "e"
    elseif markStr == "troops" then
        markType = "o"
    elseif markStr == "userinfo" then
        markType = "u"
    elseif markStr == "hero" then
        markType = "h"
    elseif markStr == "alien" then
        markType = "r"
    elseif markStr == "weapon" then
        markType = "w"
    elseif markStr == "equip" then
        markType = "f"
    elseif markStr == "sequip" then
        markType = "se"
    elseif markStr == "userarena" then
        markType = "m"
    elseif markStr == "userexpedition" then
        markType = "n"
    elseif markStr == "armor" then
        markType = "am"
    elseif markStr == "plane" then
        markType = "pl"
    elseif markStr == "aitroops" then
        markType = "at"
    elseif markStr == "airship" then
        markType = "as"
    end
    return markType
end

--根据时间戳获取当前服务器的日期，用的还是os.date，但是根据时区偏差做了修正
function G_getDate(time)
    local serverZeroTime = G_getWeeTs(base.serverTime)
    local deviceHour = tonumber(os.date("%H", serverZeroTime))
    --有的地方是差半个时区，不是整时区，所以还要考虑把分钟的修正值也加上
    local deviceMinute = tonumber(os.date("%M", serverZeroTime))
    --如果服务器的零点也是本机的零点，说明本机和服务器时区一致
    if(deviceHour == 0 and deviceMinute == 0)then
        return os.date("*t", time)
    else
        deviceHour = deviceHour + deviceMinute / 60
        local offsetTime
        --如果服务器时区加上本机和服务器的偏差过了十二区，那么服务器的日期比本机要靠前，所以加上修正值
        if(base.curTimeZone + deviceHour > 12)then
            offsetTime = time + (24 - deviceHour) * 3600
            --否则说明本机的日期比服务器快，要减去偏差
        else
            offsetTime = time - deviceHour * 3600
        end
        return os.date("*t", offsetTime)
    end
end

--G_getDataTimeStr的优化改进版，G_getDataTimeStr方法直接用了os.date，如果G_getDate这个方法没有问题的话以后就把G_getDataTimeStr方法直接改掉，这个删掉就好
--deTimeFormat：德国的时间显示格式
function G_getDateStr(time, withYear, withHour, isLineStyle, deTimeFormat)
    local tab = G_getDate(time)
    --获得time时间table，有year,month,day,hour,min,sec等元素。
    local function format(num)
        if num < 10 then
            return "0" .. num
        else
            return num
        end
    end
    local date = nil
    if platCfg.platShowtime[G_curPlatName()] ~= nil then
        if withHour == true then
            if isLineStyle then
                date = getlocal("local_war_time", {format(tab.day), format(tab.month)})
            else
                date = getlocal("scheduleChapter", {format(tab.day), format(tab.month)})
            end
            if withYear == true then
                date = getlocal("year_time", {format(tab.day), format(tab.month), tab.year})
            end
        else
            if withYear == true then
                date = getlocal("note_time", {format(tab.day), format(tab.month), tab.year, format(tab.hour), format(tab.min)})
            else
                date = getlocal("day_time", {format(tab.day), format(tab.month), format(tab.hour), format(tab.min)})
            end
        end
    else
        if withHour == true then
            if isLineStyle then
                date = getlocal("local_war_time", {format(tab.month), format(tab.day)})
            else
                date = getlocal("scheduleChapter", {format(tab.month), format(tab.day)})
            end
            if withYear == true then
                date = getlocal("year_time", {tab.year, format(tab.month), format(tab.day)})
            end
        else
            if deTimeFormat == true then
                if withYear == true then
                    date = getlocal("de_note_time", {format(tab.hour), format(tab.min), format(tab.day), format(tab.month), tab.year})
                else
                    date = getlocal("de_day_time", {format(tab.hour), format(tab.min), format(tab.day), format(tab.month)})
                end
            else
                if withYear == true then
                    date = getlocal("note_time", {tab.year, format(tab.month), format(tab.day), format(tab.hour), format(tab.min)})
                else
                    date = getlocal("day_time", {format(tab.month), format(tab.day), format(tab.hour), format(tab.min)})
                end
            end
        end
    end
    return date
end

function G_formatRichMsg(msgStr, colorTb)
    local msgarr = CCArray:create()
    local colorarr = CCArray:create()
    if msgStr and msgStr ~= "" then
        local arrTb = Split(msgStr, "<rayimg>")
        if arrTb and SizeOfTable(arrTb) > 0 then
            for k, v in pairs(arrTb) do
                if v then
                    if string.find(v, ".png") ~= nil then
                        v = "<rayimg>"..v
                    end
                    msgarr:addObject(CCString:create(v))
                    local color = colorTb[k]
                    if color == nil then
                        color = G_ColorWhite
                    end
                    local luaobj = LuaObject:create()
                    luaobj:setColor(color)
                    colorarr:addObject(luaobj)
                end
            end
        else
            msgarr:addObject(CCString:create(msgStr))
            local color = colorTb[1]
            if color == nil then
                color = G_ColorWhite
            end
            local luaobj = LuaObject:create()
            luaobj:setColor(color)
            colorarr:addObject(luaobj)
        end
    end
    return msgarr, colorarr
end

function G_isShowRichLabel()
    if G_getCurChoseLanguage() == "ar" then
        return false
    end
    --德国因单词截断问题去掉富文本
    if G_getServerPlatId() == "androidsevenga" then
        return false
    end
    if LuaRichText ~= nil then
        return true
    end
    return false
end

-- hSpace：richLabel的行间距
function G_getRichTextLabel(str, colorTab, fontSize, fontWidth, kAlignment, vAlignment, hSpace, isUseRich)
    local label
    local lbHeight = 0
    if isUseRich == nil then
        isUseRich = true
    end
    if G_isShowRichLabel() == true and isUseRich == true then
        label = LuaRichText:create()
        if hSpace then
            label:setVerticalSpace(hSpace)
        end
        -- label:setTextWidth(fontWidth)
        local msgarr, colorarr = G_formatRichMsg(str, colorTab)
        if kAlignment == nil then
            kAlignment = kCCTextAlignmentLeft
        end
        if G_getCurChoseLanguage() == "ar" and kAlignment ~= kCCTextAlignmentCenter then
            kAlignment = kCCTextAlignmentRight
        end
        -- label:setSize(CCSizeMake(fontWidth, 100))
        label:setString(msgarr, colorarr, fontSize, kAlignment)
        label:setSize(CCSizeMake(fontWidth, 0))
        lbHeight = label:getRichTextHeight()
    else
        if kAlignment == nil then
            kAlignment = kCCTextAlignmentLeft
        end
        if vAlignment == nil then
            vAlignment = kCCVerticalTextAlignmentCenter
        end
        str = string.gsub(str, "<rayimg>", "")
        label = GetTTFLabelWrap(str, fontSize, CCSizeMake(fontWidth, 0), kAlignment, vAlignment)
        lbHeight = label:getContentSize().height
        if hSpace then
            lbHeight = lbHeight + hSpace
        end
    end
    return label, lbHeight
end

function G_RunActionCombo(actionTb)
    --每个KEY 内容{ 1：使用动画效果（多效果 放在table里） 2：动画效果的对象 3：父类 4：动画前坐标 5：动画后坐标 6：延时时间 7：动画时间 8：效果显示形式（顺序显示 或同时显示）9:回调 10：缩放比例，11：特殊标识 }
    --actionTb[""] ={1,2,3,4,5,6,7,8,9,10,11 }
    for k, v in pairs(actionTb) do
        if v[11] == nil then
            local ac_1 = nil
            local acNow = nil
            
            local simpleAction, specialAction, delayAc, callFunc = nil
            
            if type(v[1]) == "table" then
                ac_1 = v[1][1]
                acNow = v[1][2]
            elseif v[1] then
                ac_1 = v[1]
            end
            
            if ac_1 then
                if ac_1 == 1 then--moveTo
                    simpleAction = CCMoveTo:create(v[7], v[5])
                elseif ac_1 == 3 then
                    simpleAction = CCScaleTo:create(v[7], v[10])
                elseif ac_1 == 5 then
                    simpleAction = CCFadeIn:create(v[7])
                elseif ac_1 == 7 then
                    simpleAction = CCFadeOut:create(v[7])
                end
            end
            
            if acNow then
                if acNow == 101 then-- CCEaseBounceOut  作用：让目标动作赋予反弹力，且以目标动作结束位子开始反弹
                    specialAction = CCEaseBounceOut:create(simpleAction)
                elseif acNow == 103 then -- CCEaseExponentialOut 让目标动作缓慢中止
                    specialAction = CCEaseExponentialOut:create(simpleAction)
                elseif acNow == 105 then -- CCEaseBackOut 作用：让目标动作赋予回力 ， 且以目标动作终点位置作为回力点
                    specialAction = CCEaseBackOut:create(simpleAction)
                end
            end
            
            if v[6] then
                delayAc = CCDelayTime:create(v[6])
            end
            if v[9] then
                callFunc = CCCallFunc:create(v[9])
            end
            
            if delayAc then
                local acArr = CCArray:create()
                acArr:addObject(delayAc)
                if acNow then
                    acArr:addObject(specialAction)
                elseif ac_1 then
                    acArr:addObject(simpleAction)
                end
                
                if callFunc then
                    acArr:addObject(callFunc)
                end
                local seq = CCSequence:create(acArr)
                v[2]:runAction(seq)
            elseif acNow then
                v[2]:runAction(specialAction)
            elseif ac_1 then
                v[2]:runAction(simpleAction)
            end
        else
            if v[11] == 1689 then
                local BgAction = v[1]
                local PicBgAction = v[2]
                local ScaleAction0 = CCScaleTo:create(0.1, 0.7)
                local ScaleAction1 = CCScaleTo:create(0.1, 1.5)
                
                local ScaleAction2 = CCScaleTo:create(0.1, 1)
                local callFunc = CCCallFunc:create(v[3])
                local acArr = CCArray:create()
                -- acArr:addObject(ScaleAction0)
                acArr:addObject(ScaleAction1)
                acArr:addObject(ScaleAction2)
                acArr:addObject(callFunc)
                local seq = CCSequence:create(acArr)
                v[1]:runAction(seq)
                local ScaleAction3 = CCScaleTo:create(0.1, 0.6)
                local ScaleAction4 = CCScaleTo:create(0.1, 1.5)
                local ScaleAction6 = CCScaleTo:create(0.1, 1)
                local acArr2 = CCArray:create()
                -- acArr2:addObject(ScaleAction3)
                acArr2:addObject(ScaleAction4)
                acArr2:addObject(ScaleAction6)
                local seq2 = CCSequence:create(acArr2)
                v[2]:runAction(seq2)
            elseif v[11] == 1697 then --actionTb["warm_1697"] ={warmBg,nil,nil,nil,nil,nil,nil,nil,warmCallBack,nil,1697 }
                local acSprite = v[1]
                local fadeIn = CCFadeIn:create(0.75)
                local fadeOut = fadeIn:reverse()
                local acArr = CCArray:create()
                local function callback_1697()
                    acSprite:setVisible(false)
                    acSprite:removeFromParentAndCleanup(true)
                end
                local callFunc = CCCallFunc:create(callback_1697)
                local seq = CCSequence:createWithTwoActions(fadeIn, fadeOut)
                local repeatTime = CCRepeat:create(seq, 2)
                acArr:addObject(repeatTime)
                acArr:addObject(callFunc)
                local seq2 = CCSequence:create(acArr)
                acSprite:runAction(seq2)
            elseif v[11] == 1698 then
                local varTime = 0.375
                local midBg = v[1]
                local upAc = v[2]
                local downAc = v[3]
                local midStr = v[4]
                local delayTime = 0.3
                local function callback_midBg()
                    midBg:setVisible(false)
                end
                local function callback_midBg2()
                    if v[9] then
                        v[9]()
                    end
                end
                local midDelayTime = CCDelayTime:create(delayTime)
                local midScaleTo = CCScaleTo:create(varTime, 1)
                local midDelay = CCDelayTime:create(2.25)
                local midScaleReTo = CCScaleTo:create(varTime, 1, v[7])
                local midCallFunc = CCCallFunc:create(callback_midBg)
                local midDelay2 = CCDelayTime:create(1)
                local midCallFunc2 = CCCallFunc:create(callback_midBg2)
                local midArr = CCArray:create()
                midArr:addObject(midDelayTime)
                midArr:addObject(midScaleTo)
                midArr:addObject(midDelay)
                midArr:addObject(midScaleReTo)
                midArr:addObject(midCallFunc)
                midArr:addObject(midDelay2)
                midArr:addObject(midCallFunc2)
                local midSeq = CCSequence:create(midArr)
                midBg:runAction(midSeq)
                
                local function callback_upBg()
                    upAc:setVisible(false)
                    upAc:removeFromParentAndCleanup(true)
                end
                local upDelayTime = CCDelayTime:create(delayTime + 0.3)
                local updelay = CCFadeIn:create(varTime)
                local upMovto = CCMoveTo:create(2 - delayTime, v[5])
                local upCallFunc = CCCallFunc:create(callback_upBg)
                local upArr = CCArray:create()
                upArr:addObject(upDelayTime)
                upArr:addObject(updelay)
                upArr:addObject(upMovto)
                upArr:addObject(upCallFunc)
                local upSeq = CCSequence:create(upArr)
                upAc:runAction(upSeq)
                
                local function callback_downBg()
                    downAc:setVisible(false)
                    downAc:removeFromParentAndCleanup(true)
                end
                local downDelayTime = CCDelayTime:create(delayTime + 0.3)
                local downdelay = CCFadeIn:create(varTime)
                local downMovto = CCMoveTo:create(2 - delayTime, v[6])
                local downCallFunc = CCCallFunc:create(callback_downBg)
                local downAr = CCArray:create()
                downAr:addObject(downDelayTime)
                downAr:addObject(downdelay)
                downAr:addObject(downMovto)
                downAr:addObject(downCallFunc)
                local downSeq = CCSequence:create(downAr)
                downAc:runAction(downSeq)
                
                local midStrfadeIn = CCFadeIn:create(0.42)
                local midStrfadeOut = midStrfadeIn:reverse()
                local midStracArr = CCArray:create()
                local function callback_midStr()
                    midStr:setVisible(false)
                    midStr:removeFromParentAndCleanup(true)
                end
                local midStrCallFunc = CCCallFunc:create(callback_midStr)
                local midStrSeq = CCSequence:createWithTwoActions(midStrfadeIn, midStrfadeOut)
                local midStrRepeatTime = CCRepeat:create(midStrSeq, 3)
                local midStrScaleReTo = CCScaleTo:create(varTime, 1, v[7])
                local midStrDelayTime = CCDelayTime:create(delayTime + 0.3)
                midStracArr:addObject(midStrDelayTime)
                midStracArr:addObject(midStrRepeatTime)
                midStracArr:addObject(midStrScaleReTo)
                midStracArr:addObject(midStrCallFunc)
                local seq2 = CCSequence:create(midStracArr)
                midStr:runAction(seq2)
            end
        end
    end
end

--一开始进入游戏需要请求后台数据接口的序列
function G_addRequestQueue()
    --getData()
    local cmd
    local params
    local callback
    --配件信息 每日任务需求
    if playerVoApi:getPlayerLevel() >= playerVoApi:getMaxLvByKey("roleMaxLevel") then
        local function accessoryListCallback(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                accessoryVoApi:updateAccData(sData)
            end
        end
        cmd = "accessory.list"
        params = {}
        callback = accessoryListCallback
    end
    if cmd and params then
        protocolController:addRequest(cmd, params, callback)
    end
end

--重新返回登录页面
--pullServerCfgFlag：重新登录是否需要重新拉取最新服务器列表
--tip：该方法与设置页面切换账号不同，此方法只是简单的回到登录页面，不做具体平台切换账号处理
function G_backToLoginScene(pullServerCfgFlag)
    if G_curPlatName() == "8" then
        PlatformManage:shared():loginOut()
    end
    if pullServerCfgFlag == true then
        G_getServerCfgFromHttp(true) --拉取最新服务器列表
    end
    base:changeServer()
end
