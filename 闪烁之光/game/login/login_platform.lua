--[[
    登录平台
]]

LoginPlatForm = LoginPlatForm or BaseClass()


function LoginPlatForm:getInstance()
    if LoginPlatForm.instance == nil then 
        LoginPlatForm.instance = LoginPlatForm.New()
    end
    return LoginPlatForm.instance
end

function LoginPlatForm:__init()
    if LoginPlatForm.instance ~= nil then 
        error("[LoginPlatForm] accempt to create a singleton twice!")
        return
    end
    self.info = {}
end

-- 是否登录平台
function LoginPlatForm:isLogin()
    return self.is_logined
end

function LoginPlatForm:getInfo()
    return self.info
end

function LoginPlatForm:getUId()
    if not self.is_logined then return "" end
    ACCOUNT_PRE = ACCOUNT_PRE or ""
    return ACCOUNT_PRE..self.info.openid
end

function LoginPlatForm:getTimestamp()
    if not self.is_logined then return "" .. os.time() end
    return string.format("%s", self.info.timestamp or 0)
end

function LoginPlatForm:getToken()
    return self.info.token or ""
end

function LoginPlatForm:getChannel()
    if FINAL_CHANNEL then return FINAL_CHANNEL end
    CHANNEL_PRE = CHANNEL_PRE or ""
    if self.info.channelId ~= nil and self.info.channelId ~= '' then
        return CHANNEL_PRE..self.info.channelId
    end
    local channel = device.getChannel and device.getChannel() or device.callFunc("channel")
    if channel == "" or channel == nil then
        channel = CHANNEL_NAME
    end
    return CHANNEL_PRE .. (channel or PLATFORM_NAME)
end

function LoginPlatForm:getSign()
    return self.info.sign or ""
end

function LoginPlatForm:loginCallback()
    local usr = string.format("%s", self:getUId())
    local password = "12345678"
    local data = {}
    data.isTourist = false
    data.usrName = usr
    data.password = password
    if data.usrName == LoginController:getInstance():getModel():getLoginData().usrName and data.usrName ~= "" and data.account_name ~= nil and data.account_name ~= ""  then
        print("当前用户ID:"..data.usrName.."已经在线上")
        return
    else
        LoginController:getInstance():getModel():getLoginData().rid = 0
        LoginController:getInstance():getModel():getLoginData().srv_id = ""
    end

    if webFunc_LoginCallback then webFunc_LoginCallback() end -- 网络动态函数调用 
    -- 如果是战盟登录,这个时候直接建立socket连接和登录游戏
    if IS_WIN_PLATFORM == true then
        -- 储存登录信息
        LoginController:getInstance():getModel():setCurSrv(self.info)
        -- 直接请求进入游戏
        LoginController:getInstance():requestLoginGame(self.info.openid, self.info.ip, self.info.port, true, true)
    else
        LoginController:getInstance():loginPlatformRequest(data)
    end
end


function LoginPlatForm:login()
    if self.is_logined then 
        self:loginCallback()
    else
        sdkOnLogin()
    end
end

-- 设置信息
function LoginPlatForm:onLoginInfo(str, isSwitch)
    -- 通知loginwindow 显示版本号
    LoginController:getInstance():showVersionLabel()

    local openid, username, token, channelId, timestamp, rid, srv_id, ip, port, host, srv_name = unpack(Split(str, "#"))
    if isSwitch then
        if openid ~= self.info.openid then
            self:onLogout()
        end
        return
    end
    self.info = {openid = openid, username = username, token = token, channelId = channelId, timestamp = timestamp, rid = rid, srv_id = srv_id, ip = ip, port = port, host = host, srv_name = srv_name}
    self.is_logined = true
    _no_need_restar = nil
    self:loginCallback()
end

-- 设置信息
function LoginPlatForm:onLogout(msg)
    print("logout", msg)
    self.is_logined = false
    self.info = {}
    if RoleController:getInstance():getRoleVo() then
        sdkSubmitUserData(5)
    end
    if restart then restart() end
end

-- 初始化失败
function LoginPlatForm:onSdkInitFail()
    ViewManager:getInstance():getMainScene():stopAllActions()
    ViewManager:getInstance():getMainScene():runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
        self:login()
    end)))
end
