mainloading = {
    callBack,
    needRequestCheck,
    tickHandlerIndex = -1,
    curServerName,
    percentage = 0,
    fc_lua = 0, --需要加载的lua文件数量
    fc_texture = 0, --需要加载的纹理文件数量
    rf_count = 0, --文件加载计数
    lua_entryId = -1, --加载lua定时entryid
    tex_entryId = -1, --加载texture定时entryid
}

require "luascript/script/mainloading/resFileMgr"

function mainloading:login(curServerName, callBack, needRequestCheck)
    self.curServerName = curServerName
    self.callBack = callBack
    self.needRequestCheck = needRequestCheck
    self:getAcessToken()
end

function mainloading:getAcessToken()
    ------以下调用http获取uid和token
    local uname, upwd, gaccount
    --是否是自有账号系统中的FB登录，如果是这种情况的话后台不验证密码
    local isSelfFB = false
    if G_loginType == 1 then --第三方平台账号登录的界面
        if G_loginAccountType == 1 then --绑定账号方式
            uname = base.tmpUserName
            upwd = base.tmpUserPassword
        else --游客方式
            uname = G_getTankUserName()
            upwd = G_getTankUserPassWord()
        end
    elseif G_loginType == 2 then --自己的账号登录的界面
        
        if self.needRequestCheck == true and base.loginAccountType == 2 then
            uname = G_getTankUserName()
            upwd = G_getTankUserPassWord()
        else
            uname = base.tmpUserName
            upwd = base.tmpUserPassword
            if base.loginAccountType == 0 then
                isSelfFB = true
                gaccount = CCUserDefault:sharedUserDefault():getStringForKey(G_local_guestAccount)
            end
        end
    end
    
    local urlStr = serverCfg.baseUrl..serverCfg.serverTokenUrl.."?pm="
    
    local accessZoneid = base.curZoneID
    if base.curOldZoneID ~= nil and base.curOldZoneID ~= 0 and base.curOldZoneID ~= "0" and base.curOldZoneID ~= "" then
        accessZoneid = base.curOldZoneID
    end
    
    -- local urlParm="username="..uname.."&zoneid="..accessZoneid.."&newzoneid="..base.curZoneID.."&password="..upwd.."&ts="..os.time()
    local urlParm = "username="..uname.."&zoneid="..accessZoneid.."&newzoneid="..base.curZoneID.."&password="..HttpRequestHelper:URLEncode(upwd) .. "&ts="..os.time()
    
    if base.yingyongbao_mid ~= nil and G_isArab() == false then
        urlParm = urlParm.."&mid="..base.yingyongbao_mid
    end
    
    if base.efunLoginParms ~= nil and G_isArab() == false then
        urlParm = urlParm.."&parm="..base.efunLoginParms
    end
    if(isSelfFB)then
        urlParm = urlParm.."&fb=1"
    end
    
    if CCUserDefault:sharedUserDefault():getIntegerForKey("test_turntest") == 1 then
        urlParm = urlParm.."&local=1"
    end
    
    local platform = G_curPlatName() --平台
    local device = (G_isIOS() and "IOS" or "Android")
    local area = G_getCountry()
    if gaccount ~= nil and gaccount ~= "" and G_isArab() == false then
        urlParm = urlParm.."&gaccount="..gaccount
    end
    urlParm = urlParm.."&platform="..platform.."&device="..device.."&area="..area.."&rayparms=1"
    print("加密前", urlParm)
    urlParm = deviceHelper:base64Encode(urlParm)
    print("截取之前", urlParm)
    print("时间戳", os.time())
    
    local qStr = string.sub(urlParm, 1, 2)
    
    local hStr = string.sub(urlParm, 3)
    
    local timeStr = deviceHelper:base64Encode(os.time())
    
    urlParm = qStr..string.sub(timeStr, 1, 5)..hStr
    
    print("组合之后", urlParm)
    
    if HttpRequestHelper.URLEncode ~= nil then
        urlParm = HttpRequestHelper:URLEncode(urlParm)
    end
    
    --[[
        local urlStr=serverCfg.baseUrl..serverCfg.serverTokenUrl.."?"
        
        local urlParm="username="..uname.."&zoneid="..base.curZoneID.."&password="..upwd.."&ts="..os.time()
        ]]
    
    urlStr = urlStr..urlParm
    
    print("发送了什么数据吗？", self.needRequestCheck, urlStr)
    
    local retData = G_sendHttpRequest(urlStr, "")
    
    if tostring(retData) == "" then
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("timeout"), nil, 200)
        G_cancleLoginLoading()
        do
            return
        end
    end
    local ret, sData = base:checkServerData(retData, false)
    self.cuid = sData.uid
    local isMaintain = false
    if sData.gconfig ~= nil and sData.gconfig.zoneid ~= nil then
        if SizeOfTable(sData.gconfig.zoneid) == 0 then
            isMaintain = true
            
        else
            for k, v in pairs(sData.gconfig.zoneid) do
                if v == base.curZoneID then
                    isMaintain = true
                    break
                end
            end
        end
        if isMaintain and sData.gconfig ~= nil and sData.gconfig.status == -9999 then
            -- sData.gconfig.st=222222222222
            -- sData.gconfig.et=666666666666
            G_cancleLoginLoading()
            if sData.gconfig.content ~= nil and sData.gconfig.content ~= "" then
                if(type(sData.gconfig.content) == "string")then
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), sData.gconfig.content, nil, 200)
                elseif(type(sData.gconfig.content) == "table")then
                    local content = sData.gconfig.content[G_getCurChoseLanguage()]
                    if(content == nil)then
                        for k, v in pairs(sData.gconfig.content) do
                            content = v
                            break
                        end
                    end
                    if(content)then
                        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), content, nil, 200)
                    end
                end
                do return end
            end
            
            if sData.gconfig.st == 0 and sData.gconfig.et == 0 then
                smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("sys_maintain1"), nil, 200)
            else
                local str = activityVoApi:getActivityTimeStr(sData.gconfig.st, sData.gconfig.et)
                smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("sys_maintain2", {str}), nil, 200)
                
            end
            
            do
                return
            end
        end
        if isMaintain and sData.gconfig ~= nil and sData.gconfig.status == -9998 then --重新获取服务器列表
            G_cancleLoginLoading()
            if sData.gconfig.content ~= nil and sData.gconfig.content ~= "" then
                local function reloadserverlist()
                    base.getSvrConfigFromHttpSuccess = false
                    G_getServerCfgFromHttp(true)
                end
                smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), sData.gconfig.content, reloadserverlist, 200)
                do
                    return
                end
            end
            
        end
        
    end
    
    if sData.gconfig ~= nil and sData.gconfig.status == -9999 then
        -- sData.gconfig.st=222222222222
        -- sData.gconfig.et=666666666666
        if sData.gconfig.st == 0 and sData.gconfig.et == 0 then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("sys_maintain1"), nil, 200)
        else
            local str = activityVoApi:getActivityTimeStr(sData.gconfig.st, sData.gconfig.et)
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("sys_maintain2", {str}), nil, 200)
            
        end
        
        do
            return
        end
    end
    
    if ret == true then
        --设置实名相关数据
        require "luascript/script/healthy/verifyApi"
        verifyApi:setToken(sData.logints, sData.access_token, self.cuid, uname)
        verifyApi:setVerifiedInfo(sData.NAME, sData.ID)

        self:gameconnect()
        
    else --发生错误
        
        do
            return
        end
    end
    if sData.client_ip ~= nil then
        base.client_ip = sData.client_ip
    end
    
end

function mainloading:gameconnect()
    
    local function connectHandler(...)
        self:loginSuccess(...)
    end
    local k1, k2 = Split(self.curServerName, ",")[1], Split(self.curServerName, ",")[2]
    local svrTb
    for k, v in pairs(serverCfg.allserver[k1]) do
        if v.name == k2 then
            svrTb = v
        end
    end
    
    local ips = CCArray:create()
    local ipTbs = Split(svrTb.ip, ",")
    for k, v in pairs(ipTbs) do
        ips:addObject(CCString:create(v))
    end
    
    local ports = CCArray:create()
    local portTbs = Split(svrTb.port, ",")
    for k, v in pairs(portTbs) do
        ports:addObject(CCString:create(v))
    end
    
    SocketHandler:shared():rememberServer(ips, ports)
    socketHelper:socketConnect(ipTbs[1], tonumber(portTbs[1]), connectHandler)
    self:chatconnect()
end

function mainloading:chatconnect()
    local chatSvrTb
    if serverCfg.allChatServer[base.curCountry] ~= nil then
        for k, v in pairs(serverCfg.allChatServer[base.curCountry]) do
            if v.name == base.curArea then
                chatSvrTb = v
            end
        end
    end
    if chatSvrTb ~= nil then
        socketHelper:chatSocketConnect(chatSvrTb.ip, chatSvrTb.port) --连接聊天服务器
    end
    
end

function mainloading:loginSuccess(fn, ret)
    if self.callBack ~= nil then
        if self.needRequestCheck == true then
            self.newUser = false
            local function serverCheckHandler(fn, data)
                --local sData=G_Json.decode(data)
                local result, sData = base:checkServerData(data, false)
                if sData ~= nil and sData.ret >= 0 then
                    if tonumber(sData.uid) > 0 then --登陆过，直接登陆
                        self.newUser = false
                    else --没有登陆过,弹出输入角色
                        self.newUser = true
                    end
                    -- self:loadResources()

                    local function loadEnd()
                        self:enterGame()                        
                    end
                    self:loadGame(loadEnd)
                end
            end
            if G_loginType == 1 then --第三方账号登录的界面（台湾）
                local userNm
                if G_loginAccountType == 1 then
                    userNm = base.tmpUserName
                else --游客方式
                    userNm = G_getTankUserName()
                end
                
                socketHelper:userCheck(self.cuid, userNm, serverCheckHandler)
            elseif G_loginType == 2 then --本地账号的登陆
                socketHelper:userCheck(self.cuid, G_getTankUserName(), serverCheckHandler)
            end
        else
            socketHelper:userLogin(self.callBack, self.cuid, base.tmpUserName, base.tmpUserPassword)
        end
    end
end

--初始化加载数据
function mainloading:initLoad()
    self.luas, self.textures = {}, {}
    if self.lua_entryId ~= -1 and self.tex_entryId ~= -1 then --切换账号只需加载部分资源
        self.luas = resFileMgr:getReloadLuaFiles()
        self.textures = resFileMgr:getReloadTextures()
    else
        self.luas = resFileMgr:getLuaFileList()
        self.textures = resFileMgr:getTextureFileList()
    end
    self.lua_entryId, self.tex_entryId = -1, -1
    self.rf_count = 0
    self.fc_lua, self.fc_texture = SizeOfTable(self.luas), SizeOfTable(self.textures)
end

--加载lua文件
function mainloading:loadLuas(luasEnd)
    if self.lua_entryId ~= -1 then
        if luasEnd then luasEnd() end
        do return end
    end
    
    local plua_c = 3 --每帧可加载的lua数量
    local rf_allc = self.fc_lua + self.fc_texture
    local function tickLoad()
        if platCfg.platCfgNewLoadResources[G_curPlatName()] then --有此配置分段加载即可，此加载方式在一帧内加载完成，会卡住ui线程直到加载完成
            if self.rf_count == 0 then
                loginScene:showLoadGameProcess(40)
                self.rf_count = 1
            elseif self.rf_count < self.fc_lua then
                for k, luaPath in pairs(self.luas) do
                    require (luaPath)
                end
                self.rf_count = self.fc_lua
                
                loginScene:showLoadGameProcess(80)
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.lua_entryId)
                
                if luasEnd then luasEnd() end --lua加载完成，运行回调
            end
            do return end
        end
        --以下加载方式把加载压力分摊到各个帧加载
        if self.rf_count < self.fc_lua then --加载lua文件
            local rest_c = self.fc_lua - self.rf_count
            plua_c = (rest_c < plua_c) and rest_c or plua_c
            for k = 1, plua_c do
                local luaPath = self.luas[1]
                if luaPath and type(luaPath) == "string" then
                    require (luaPath)
                    table.remove(self.luas, 1)
                end
            end
            self.rf_count = self.rf_count + plua_c
        else
            if luasEnd then luasEnd() end --lua加载完成，运行回调
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.lua_entryId)
        end
        
        local percent = (self.rf_count / rf_allc) * 100
        loginScene:showLoadGameProcess(percent)
    end
    self.lua_entryId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tickLoad, 0, false)
    loginScene:showLoadGameProcess(0)
    G_cancleLoginLoading()
end

--加载纹理资源文件
function mainloading:loadTextures(texturesEnd)
    if self.tex_entryId ~= -1 then
        if texturesEnd then texturesEnd() end
        do return end
    end
    
    local ptexture_c = 3 --每帧可加载的纹理数量
    local rf_allc = self.fc_lua + self.fc_texture
    local function tickLoad()
        if platCfg.platCfgNewLoadResources[G_curPlatName()] then --有此配置分段加载即可，此加载方式在一帧内加载完成，会卡住ui线程直到加载完成
            if self.rf_count < rf_allc then
                for k, tex in pairs(self.textures) do
                    if tex.w and tex.w == 1 then --kRGBA8888加载方式
                        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
                        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
                        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(tex.path)
                        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
                        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
                    else
                        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(tex.path)
                    end
                end
                self.rf_count = rf_allc
                loginScene:showLoadGameProcess(100)
            else
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.tex_entryId)
                
                if texturesEnd then texturesEnd() end --纹理加载完成，运行回调
            end
            do return end
        end
        if self.rf_count < rf_allc then --加载纹理文件
            local rest_c = rf_allc - self.rf_count
            ptexture_c = (rest_c < ptexture_c) and rest_c or ptexture_c
            for k = 1, ptexture_c do
                local tex = self.textures[1]
                if tex then
                    if tex.w and tex.w == 1 then --kRGBA8888加载方式
                        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
                        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
                        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(tex.path)
                        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
                        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
                    else
                        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(tex.path)
                    end
                    table.remove(self.textures, 1)
                end
            end
            self.rf_count = self.rf_count + ptexture_c
        else
            if texturesEnd then texturesEnd() end --纹理加载完成，运行回调
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.tex_entryId)
        end
        
        local percent = (self.rf_count / rf_allc) * 100
        loginScene:showLoadGameProcess(percent)
    end
    self.tex_entryId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tickLoad, 0, false)
    G_cancleLoginLoading()
end

--加载游戏
function mainloading:loadGame(loadEnd)
    self:initLoad() --初始化资源加载
    
    local function luasEnd()
        self:loadTextures(loadEnd)
    end
    self:loadLuas(luasEnd)
end

function mainloading:enterGame()
    if(self.newUser)then
        G_cancleLoginLoading()
        base:cancleWait()
        base:cancleNetWait()
        loginScene:createNewRole(self.callBack, self.cuid)
    else
        socketHelper:userLogin(self.callBack, self.cuid)
    end
end
