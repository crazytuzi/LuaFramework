local SysInfo = classGc(function(self)
    local app       = gc.App:getInstance()
    local device    = gc.DeviceGc:getInstance()
    local winSize   = cc.Director:getInstance():getWinSize()
    --
    self:resetTextureFormat()

    -- gc.ResHelperGc:getInstance()
    self.m_deviceGc = device
    self.m_app      = app
    self.m_os       = device:getOS()
    self.m_os_ver   = 7.12 --device:getOS()  -- Android 或 iOS版本号 如 iOS:7.12  Android:4.10等等
    self.m_agentCode= app:getAgentCode()
    self.m_gameNameCode=app:getGameNameCode()
    -- 配置信息
    -- gc.ChannelManager:initCID(tostring(self.m_agentCode))
    -- 
    self.m_cid      = gc.ChannelManager:getChannelData(_G.Const.sKeyCID217)
    self.m_lang     = app:getLang()
    self.m_language = "cn" -- 这是用户手机系统语言
    self.m_referrer = ""
    self.m_macId    = device:getMAC()
    self.m_device   = ""
    self.m_sid      = 0
    self.m_uuid     = self:getUuid() or 0
    self.m_account  = ""
    self.m_uid      = 0
    self.m_fcm      = 1
    self.m_fcm_id   = ""
                                                -- 规则 iOS  Version与Build一样: <C++版本号>.<打包版本号>.<资源版本号>
                                                --  Android  VersionCode:      <C++版本号>
                                                --           VersionName:      <C++版本号>.<打包版本号>.<资源版本号>
    self.m_appVersion      = app:getAppVersion()      -- 返回打包时的 版本号          iOS: Version   Android: VersionCode
    self.m_appVersionBuild = app:getAppVersionBuild() -- 返回打包时的 版本号Build     iOS: Build     Android: VersionName
    self.m_source       = app:getFromSource()
    self.m_source_sub   = app:getFromSourceSub()
    self.m_screen       = tostring(winSize.width).."x"..tostring(winSize.height)
    self.m_gcLuaType    = app:getLuaType()
    self.m_gcResType    = app:getResType()

    self.m_versionVer = "1"
    self.m_versionSub = "1"
    self.m_versionRes = "1"

    -- if self:isAndroid() then
    --     local szOSVer=self.m_deviceGc:getOSVersion()
    --     local firstNum=tonumber(string.sub(szOSVer,1,1))
    --     if firstNum>=5 then
    --         cc.SimpleAudioEngine:getInstance():setMusicVolume(0.3)
    --         cc.SimpleAudioEngine:getInstance():setEffectsVolume(1)
    --     end
    -- end

    self.m_networkType=self.m_app:getNetworkType()
    self.m_networkHost=self.m_app:getHost()
    if self:isIpNetwork() then
        _G.CCLOG=_G.GCLOG
        _G.print=_G.gcprint
    else
        LOG_CLOSE()
    end

    self:setGameIntervalLow()
end)

function SysInfo.setGameIntervalLow(self)
    if self.m_isGameIntervalLow==true then
        return
    end
    self.m_isGameIntervalLow=true


    if self:isAndroid() then
        cc.Director:getInstance():setAnimationInterval(1/20)
    else
        cc.Director:getInstance():setAnimationInterval(1/30)
    end
end
function SysInfo.setGameIntervalHigh(self)
    if self.m_isGameIntervalLow==false then
        return
    end
    self.m_isGameIntervalLow=false

    if self:isAndroid() then
        cc.Director:getInstance():setAnimationInterval(1/40)
    else
        cc.Director:getInstance():setAnimationInterval(1/60)
    end
end

function SysInfo.resetTextureFormat(self)
    self:setTextureFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
end
function SysInfo.setTextureFormat(self,_format)
    if self.m_defultTextureFormat==_format then return end
    self.m_defultTextureFormat=_format
    cc.Texture2D:setDefaultAlphaPixelFormat(_format)
end
function SysInfo.getTextureFormat(self)
    return self.m_defultTextureFormat
end

function SysInfo.getGameNameCode(self)
    return self.m_gameNameCode
end

function SysInfo.initXmlVersion(self)
    self.m_versionVer = self.m_app:getVersionVer() or "1" -- XML 里的C++版本号
    self.m_versionSub = self.m_app:getVersionSub() or "1" -- XML 里的打包版本号
    self.m_versionRes = self.m_app:getVersionRes() or "1" -- XML 里的资源版本号

    GCLOG("initXmlVersion==>ver=%s,ver_sub=%s,ver_res=%s",self.m_versionVer,self.m_versionSub,self.m_versionRes)
end

-- 缓存数据
function SysInfo.getSession( self )
    return self.m_app:getSession()
end
-- function SysInfo.setSession( self,session)
--     self.m_app:setSession(session)
-- end
function SysInfo.getUuid( self )
    return self.m_app:getUuid()
end
function SysInfo.setUuid( self, uuid )
    self.m_uuid=uuid
    self.m_app:setUuid(uuid)
end
function SysInfo.getUid( self )
    return self.m_app:getUid()
end
function SysInfo.setUid( self, uid)
    self.m_uid=uid
    self.m_app:setUid(uid)
end
function SysInfo.setSid(self,_sid)
    self.m_sid=_sid
end
function SysInfo.getSid(self)
    return self.m_sid
end
function SysInfo.setSDKUserName(self,_userName)
    self.m_account=_userName
end

function SysInfo.isShowSDKUserBtn(self)
    if self.m_isSupportShowUserBtn~=nil then
        return self.m_isSupportShowUserBtn
    end

    local isSupport=false
    if gc.SDKManager.isSupportShowCenter then
        isSupport=gc.SDKManager:getInstance():isSupportShowCenter()
    elseif not self:isIpNetwork() then
        if self.m_gameNameCode==_G.Const.kAgentGameNameXM_IFEN then
            isSupport=true
        end
    end
    self.m_isSupportShowUserBtn=isSupport
    return isSupport
end

function SysInfo.isYayaImSupport(self)
    -- do return false end
    if self.m_isYayaImSupport~=nil then
        return self.m_isYayaImSupport
    end

    local isSupport=self.m_app:getYayaIMCode()==1
    self.m_isYayaImSupport=isSupport
    return isSupport
end

-- OS
function SysInfo.getOS(self)
    local os = self.m_os
    if os == _G.Const.kPlatformIOS then
        return "iOS"
    elseif os == _G.Const.kPlatformANDROID then
        return "Android"
    else
        return tostring(os)
    end
end
function SysInfo.isIos(self)
    return self.m_os==_G.Const.kPlatformIOS
end
function SysInfo.isAndroid(self)
    return self.m_os==_G.Const.kPlatformANDROID
end

function SysInfo.isAppStoreChannel(self)
    return self.m_agentCode==_G.Const.AGENT_SDK_CODE_APP_IOS_GC
end
function SysInfo.isQQSDKChannel(self)
    return self.m_agentCode==_G.Const.AGENT_SDK_CODE_QQ
end
function SysInfo.isZhuoYiChannel(self)
    return self.m_agentCode==_G.Const.AGENT_SDK_CODE_ZHUOYI
end
function SysInfo.isKuaiFaChannel(self)
    return self.m_agentCode==_G.Const.AGENT_SDK_CODE_KUAIFA
end
function SysInfo.isYiJieChannel(self)
    return self.m_agentCode==_G.Const.AGENT_SDK_CODE_YIJIE
end
function SysInfo.isUCChannel(self)
    return self.m_agentCode==_G.Const.AGENT_SDK_CODE_UC
end
function SysInfo.is19YOUChannel(self)
    return self.m_agentCode==_G.Const.AGENT_SDK_CODE_19YOU
end
function SysInfo.isAnZhiChannel(self)
    local agentCode=self.m_app:getAgentCode()
    if agentCode==_G.Const.AGENT_SDK_CODE_ANYSDK then
        local channelId=gc.SDKManager:getInstance():getSDKChannel()
        return channelId=="000005"
    else
        return false
    end
end

function SysInfo.hasRechargeOrderLocation(self)
    if self:isQQSDKChannel() or self:isAppStoreChannel() then
        if gc.SDKManager.hasOrderLocation~=nil then
            return gc.SDKManager:getInstance():hasOrderLocation()
        end
    end
    return false
end

function SysInfo.setBoardCopyString(self,_content)
    self.m_deviceGc:setBoardCopyString(_content)
end
function SysInfo.getBoardCopyString(self)
    return self.m_deviceGc:getBoardCopyString()
end

-- UI目录(统一用ui)
-- function SysInfo.getDirUi(self)
--     if _G.Const.kLangCodeVN == self.m_lang then
--         return 'ui_vn'
--     -- elseif 86 == self.m_lang then
--     else
--        return 'ui' 
--     end
-- end

-- Config目录(统一用config@cn)
function SysInfo.getDirCnf(self)
    if _G.Const.kLangCodeVN == self.m_lang then
        return 'config@vn'
    -- elseif 86 == self.m_lang then
    else
       return 'config@cn' 
    end
end

-- 配音目录(统一用dub)
-- function SysInfo.getDirDub(self)
--     if _G.Const.kLangCodeVN == self.m_lang then
--         return 'dub@vn'
--     else
--        return 'dub@cn' 
--     end
-- end

function SysInfo.getGcLuaType(self)
    return self.m_gcLuaType
end
function SysInfo.getGcResType(self)
    return self.m_gcResType
end
function SysInfo.isDevelopType(self)
    return self:getGcLuaType()==_G.Const.kResTypeDEV
end

-- 获取 内外网 模式 
function SysInfo.getNetworkType(self)
    return self.m_networkType
end
function SysInfo.isIpNetwork(self)
    return self.m_networkType==_G.Const.kNetworkTypeIP
end
-- PHP Sdk Host
function SysInfo.getHost(self)
    return self.m_networkHost
end
function SysInfo.setHostTest(self,_szHost)
    if self:isIpNetwork() then
        self.m_networkHost=_szHost
    end
end
-- 取出服务器时间(未连接服务器时用)
function SysInfo.getServSeconds(self)
    return self.m_app:getServSeconds()
end
-- 设定服务器时间
function SysInfo.setServSeconds(self,time)
    return self.m_app:setServSeconds(time)
end
-- cid
function SysInfo.getCID(self)
    return self.m_cid
end


function SysInfo.urlServerMaintain(self,_sid)
    local szUrl=string.format("%s/api/PhoneSDK/Repair?cid=%s&sid=%d",self:getHost(),self.m_cid,_sid)
    return szUrl
end

-- SDK - 更新日志
function SysInfo.urlUpdateLogs(self)
    local args  = "cid="..self.m_cid.."&os="..self:getOS().."&source="..self.m_source.."&source_sub="..self.m_source_sub.."&versions="..self.m_appVersion.."_"..self.m_versionRes
    -- return "http://xbsgapi.7pk.cn/api/UpdateLogs?"..args
    return "http://"..self:getHost().."/api/UpdateLogs?"..args
end
function SysInfo.urlBugsReport(self)
    local szName= _G.GPropertyProxy:getMainPlay():getName()
    local args  = "cid="..self.m_cid.."&sid="..tostring(self.m_sid).."&uid="..tostring(self.m_uid)
                  .."&uname="..gc.Md5Crypto:urlEncode(szName).."&os="..self:getOS().."&versions="..self.m_appVersion.."_"..self.m_versionRes

    return "http://"..self:getHost().."/api/Gm?"..args
end
-- API - 版本数据(XML)
function SysInfo.urlUpdateXml(self)
    local time     = self:getServSeconds()
    local os       = self:getOS()
    local device   = gc.Md5Crypto:urlEncode(self.m_device)

    local sign_str = "cid="..tostring(self.m_cid).."&mac="..self.m_macId.."&device="..device.."&uuid="..tostring(self.m_uuid)
                        .."&ver="..self.m_versionVer.."&ver_sub="..self.m_versionSub.."&ver_res="..self.m_versionRes.."&ver_build="..self.m_appVersionBuild
                        .."&os="..self:getOS().."&os_ver="..self.m_os_ver.."&source="..self.m_source.."&source_sub="..self.m_source_sub
                        .."&screen="..self.m_screen.."&language="..self.m_language.."&referrer="..self.m_referrer
                        .."&time="..tostring(time).."&lang="..tostring(self.m_lang)
    local args     = self.m_app:getSignData(sign_str);
    print("url:http://"..self:getHost().."/api/Phone/UpdateXml?"..args)
    return "http://"..self:getHost().."/api/Phone/UpdateXml?"..args
end
-- API - 开服确认
function SysInfo.urlOpenServ(self)

    local args  = "cid="..tostring(self.m_cid).."&ver="..self.m_versionVer.."&ver_sub="..self.m_versionSub.."&ver_res="..self.m_versionRes.."&ver_build="..self.m_appVersionBuild
                        .."&os="..self:getOS().."&os_ver="..self.m_os_ver.."&source="..self.m_source.."&source_sub="..self.m_source_sub
    return "http://"..self:getHost().."/api/Phone/OpenServ?"..args
end
-- API - 登录接口
function SysInfo.urlSDKLogin(self)
    return "http://"..self:getHost().."/api/Phone/Login"
end
function SysInfo.urlSDKLoginSignData(self)
    local session  = self:getSession()
    local account  = gc.Md5Crypto:urlEncode(self.m_account)
    local time     = self:getServSeconds()
    local device   = gc.Md5Crypto:urlEncode(self.m_device)

    local sign_str = "cid="..tostring(self.m_cid).."&account="..account.."&mac="..self.m_macId.."&device="..device
                           .."&ver="..self.m_versionVer.."&ver_sub="..self.m_versionSub.."&ver_res="..self.m_versionRes.."&ver_build="..self.m_appVersionBuild
                           .."&os="..self:getOS().."&os_ver="..self.m_os_ver.."&source="..self.m_source.."&source_sub="..self.m_source_sub
                           .."&time="..tostring(time)
    return self.m_app:getSignData(sign_str)
end
-- API - 登录接口(断线重连)
function SysInfo.urlLoginRelink(self)
    return "http://"..self:getHost().."/api/Phone/LoginRelink"
end
function SysInfo.urlLoginRelinkSignData(self)
    local session  = self:getSession()
    local time     = self:getServSeconds()
    local device   = gc.Md5Crypto:urlEncode(self.m_device)

    local sign_str = "cid="..tostring(self.m_cid).."&sid="..tostring(self.m_sid).."&uuid="..tostring(self.m_uuid).."&uid="..tostring(self.m_uid)
                           .."&mac="..self.m_macId.."&device="..device
                           .."&fcm="..tostring(self.m_fcm).."&fcm_id="..self.m_fcm_id
                           .."&session="..session.."&time="..tostring(time)
    return self.m_app:getSignData(sign_str)
end
-- API - 服务器列表
function SysInfo.urlServList(self)
    local session  = self:getSession()
    local uuid = self:getUuid()
    local time = self:getServSeconds()

    local sign_str = "cid="..tostring(self.m_cid).."&uuid="..tostring(uuid).."&session="..session.."&time="..tostring(time)
    local args     = self.m_app:getSignData(sign_str);
    return "http://"..self:getHost().."/api/Phone/ServList?"..args.."&simple=1&ver_build="..self.m_appVersionBuild
end
-- API - 获取服务器名称
function SysInfo.urlServName(self,_sidArray)
    local szSids=""
    for i=1,#_sidArray do
        if i>1 then
            szSids=szSids.."_".._sidArray[i]
        else
            szSids=szSids.._sidArray[i]
        end
    end
    local args = "cid="..tostring(self.m_cid).."&sids="..szSids
    return "http://"..self:getHost().."/api/Phone/ServName?"..args
end
-- API - 角色列表
function SysInfo.urlRoleList(self,sid)
    local session  = self:getSession()
    local uuid = self:getUuid()
    local time = self:getServSeconds()

    local sign_str = "cid="..tostring(self.m_cid).."&sid="..tostring(sid).."&uuid="..tostring(uuid)
                           .."&fcm="..tostring(self.m_fcm).."&fcm_id="..self.m_fcm_id
                           .."&session="..session.."&time="..tostring(time)
    local args     = self.m_app:getSignData(sign_str);
    return "http://"..self:getHost().."/api/Phone/RoleList?"..args
end
-- API - 创建角色(Uid)
function SysInfo.urlRoleCreate(self,sid)
    local session  = self:getSession()
    local uuid = self:getUuid()
    local time = self:getServSeconds()
    
    local sign_str = "cid="..tostring(self.m_cid).."&sid="..tostring(sid).."&uuid="..tostring(uuid)
                           .."&fcm="..tostring(self.m_fcm).."&fcm_id="..self.m_fcm_id.."&session="..session
                           .."&time="..tostring(time)
    local args     = self.m_app:getSignData(sign_str);
    return "http://"..self:getHost().."/api/Phone/RoleCreate?"..args
end
-- API - 进入游戏
function SysInfo.urlInto(self)
    local session  = self:getSession()
    local device   = gc.Md5Crypto:urlEncode(self.m_device)
    local time     = self:getServSeconds()
    local mac_id   = gc.Md5Crypto:urlEncode(self.m_macId)

    local sign_str = "cid="..tostring(self.m_cid).."&mac="..mac_id.."&device="..device
                           .."&ver="..self.m_versionVer.."&ver_sub="..self.m_versionSub.."&ver_res="..self.m_versionRes.."&ver_build="..self.m_appVersionBuild
                           .."&os="..self:getOS().."&os_ver="..self.m_os_ver.."&source="..self.m_source.."&source_sub="..self.m_source_sub
                           .."&screen="..self.m_screen.."&language="..self.m_language.."&referrer="..self.m_referrer
                           .."&sid="..tostring(self.m_sid).."&uuid="..tostring(self.m_uuid).."&uid="..tostring(self.m_uid)
                           .."&session="..session.."&time="..tostring(time)
    local args     = self.m_app:getSignData(sign_str);
    return "http://"..self:getHost().."/api/Phone/Into?"..args
end
-- API - 微信绑定码
function SysInfo.urlWechatBound(self)
    local time     = self:getServSeconds()

    local sign_str = "cid="..tostring(self.m_cid).."&sid="..tostring(self.m_sid).."&uuid="..tostring(self.m_uuid).."&uid="..tostring(self.m_uid)
                           .."&time="..tostring(time)
    local args     = self.m_app:getSignData(sign_str);
    return "http://"..self:getHost().."/wx/bdapi/?"..args
end
-- API - 提交日志
function SysInfo.urlUpdateErrorLogs(self)
    local device   = gc.Md5Crypto:urlEncode(self.m_device)

    local sign_str = "cid="..tostring(self.m_cid).."&mac="..self.m_macId.."&device="..device
                           .."&ver="..self.m_versionVer.."&ver_sub="..self.m_versionSub.."&ver_res="..self.m_versionRes.."&ver_build="..self.m_appVersionBuild
                           .."&os="..self:getOS().."&os_ver="..self.m_os_ver.."&source="..self.m_source.."&source_sub="..self.m_source_sub
    return "http://"..self:getHost().."/api/Phone/UpdateErrorLogs?"..sign_str
end

-- CR - coolpad登录
function SysInfo.urlCoolpadLogin(self,code)
    local sign_str = "cid="..tostring(self.m_cid).."&code="..code.."&time="..tostring(time)
    local args     = self.m_app:getSignData(sign_str);
    return "http://"..self:getHost().."/api/CReturn/CoolpadLogin?"..args
end

-- CR - i4登录
function SysInfo.urli4Login(self,i4_sid)
    local sign_str = "cid="..tostring(self.m_cid).."&i4_sid="..i4_sid.."&time="..tostring(time)
    local args     = self.m_app:getSignData(sign_str);
    return "http://"..self:getHost().."/api/CReturn/i4Login?"..args
end

-- CR - 快用登录ios
function SysInfo.urlKyLogin(self,ky_sid)
    local sign_str = "cid="..tostring(self.m_cid).."&ky_sid="..ky_sid.."&time="..tostring(time)
    local args     = self.m_app:getSignData(sign_str);
    return "http://"..self:getHost().."/api/CReturn/KyLogin?"..args
end

-- CR - PP登录ios
function SysInfo.urlPpLogin(self,pp_sid)
    local sign_str = "cid="..tostring(self.m_cid).."&pp_sid="..pp_sid.."&time="..tostring(time)
    local args     = self.m_app:getSignData(sign_str);
    return "http://"..self:getHost().."/api/CReturn/PpLogin?"..args
end

-- CR - UC登录
function SysInfo.urlUcLogin(self,uc_sid)
    local sign_str = "cid="..tostring(self.m_cid).."&uc_sid="..uc_sid.."&time="..tostring(time)
    local args     = self.m_app:getSignData(sign_str);
    return "http://"..self:getHost().."/api/CReturn/UcLogin?"..args
end
-- CR - UC登录android
function SysInfo.urlUcAndroidLogin(self,uc_sid)
    local sign_str = "cid="..tostring(self.m_cid).."&uc_sid="..uc_sid.."&time="..tostring(time)
    local args     = self.m_app:getSignData(sign_str);
    return "http://"..self:getHost().."/api/CReturn/UcAndroidLogin?"..args
end
-- CR - 360登录
function SysInfo.urlP360AndroidLogin(self,auth_code,refresh)
    local sign_str = "cid="..tostring(self.m_cid).."&auth_code="..auth_code.."&refresh="..refresh.."&time="..tostring(time)
    local args     = self.m_app:getSignData(sign_str);
    return "http://"..self:getHost().."/api/CReturn/P360AndroidLogin?"..args
end
-- CR - 充值(移动MM)
function SysInfo.urlMmStore(self)
    return "http://"..self:getHost().."/api/CReturn/MmStore"
end
function SysInfo.urlMmStoreSignData(self,receipt,oid,id)
    local account2 = gc.Md5Crypto:urlEncode(self.m_account)
    local sign_str = "cid="..tostring(self.m_cid).."&sid="..tostring(self.m_sid).."&account="..account2
                           .."&uuid="..tostring(self.m_uuid).."&uid="..tostring(uid)
                           .."&receipt="..receipt.."&oid="..oid.."&id="..id.."&time="..tostring(time)
    return self.m_app:getSignData(sign_str)
end
-- CR - ios越狱 充值(越南)
function SysInfo.urlVNiOS_jb(self)
    return "http://"..self:getHost().."/api/CReturn/vn_ios_jb"
end
function SysInfo.urlVNiOS_jbSignData(self,oid)
    local account2 = gc.Md5Crypto:urlEncode(self.m_account)
    local sign_str = "cid="..tostring(self.m_cid).."&sid="..tostring(self.m_sid).."&account="..account2
                           .."&uuid="..tostring(self.m_uuid).."&uid="..tostring(uid)
                           .."&oid="..oid.."&time="..tostring(time)
    return self.m_app:getSignData(sign_str)
end
-- CR - AppStore登录
function SysInfo.urlAppLogin(self)
    return "http://"..self:getHost().."/api/PhoneSDK/AppLogin"
end
function SysInfo.urlAppLoginSignData(self,account,passwd)
    local session  = self:getSession()
    local time     = self:getServSeconds()
    local account2 = gc.Md5Crypto:urlEncode(account)
    local passwd2  = gc.Md5Crypto:md5(passwd,0)

    local sign_str = "cid="..tostring(self.m_cid).."&type=0&account="..account2.."&passwd="..passwd2.."&session="..session
                           .."&ver="..self.m_versionVer.."&ver_sub="..self.m_versionSub.."&ver_res="..self.m_versionRes.."&ver_build="..self.m_appVersionBuild
                           .."&os="..self:getOS().."&os_ver="..self.m_os_ver.."&source="..self.m_source.."&source_sub="..self.m_source_sub
                           .."&time="..tostring(time)
    return self.m_app:getSignData(sign_str)
end
-- CR - AppStore注册
function SysInfo.urlAppRegister(self)
    return "http://"..self:getHost().."/api/PhoneSDK/AppRegister"
end
function SysInfo.urlAppRegisterSignData(self,account,passwd)
    local session  = self:getSession()
    local time     = self:getServSeconds()
    local account2 = gc.Md5Crypto:urlEncode(account)
    local passwd2  = gc.Md5Crypto:md5(passwd,0)
    local device   = gc.Md5Crypto:urlEncode(self.m_device)

    local sign_str = "cid="..tostring(self.m_cid).."&account="..account2.."&passwd="..passwd2
                           .."&mac="..self.m_macId.."&device="..device
                           .."&ver="..self.m_versionVer.."&ver_sub="..self.m_versionSub.."&ver_res="..self.m_versionRes.."&ver_build="..self.m_appVersionBuild
                           .."&os="..self:getOS().."&os_ver="..self.m_os_ver.."&source="..self.m_source.."&source_sub="..self.m_source_sub
                           .."&time="..tostring(time)
    return self.m_app:getSignData(sign_str)
end
-- CR - App忘记/修改密码(新开窗口)
function SysInfo.urlAppPasswd(self)
    local session  = self:getSession()
    local time     = self:getServSeconds()

    local sign_str = "cid="..tostring(self.m_cid).."&uuid="..tostring(self.m_uuid).."&os="..self:getOS()
                           .."&session="..session.."&time="..tostring(time)
    local args     = self.m_app:getSignData(sign_str);
    return "http://"..self:getHost().."/api/PhoneSDK/AppPasswd?"..args
end
-- CR - AppStore充值(Object C里调的 不用在这里弄)
-- function SysInfo.urlAppStore(self)
--     return "http://"..self:getHost().."/api/CReturn/AppStore"
-- end
-- function SysInfo.urlAppStoreSignData(self,sid,uuid,uid,sandbox,account,oid,id,receipt)
--     return self.m_app:getSignDataAppStore(sid,uuid,uid,sandbox,account,oid,id,receipt)
-- end
-- PHP 服务器时间(这里改到 XML里去拿  不用独立去拿了)
-- function SysInfo.urlTimeline(self)
--     return self.m_app:getUrlTimeline()
-- end

return SysInfo

