userAccountCenterVoApi = {
    
}

function userAccountCenterVoApi:init()
    self.url, self.platname = G_getPlatGmUrl(), G_getGmPlatName()
end

--获取本机存储的注册账号信息列表
function userAccountCenterVoApi:getRegisterUsers()
    local userListJsonStr = CCUserDefault:sharedUserDefault():getStringForKey("rayRegisterUsers")
    if userListJsonStr and userListJsonStr ~= "" then
        local userList = G_Json.decode(userListJsonStr)
        if type(userList) == "table" then
            return userList
        end
    end
    return {}
end

--获取指定账号信息
function userAccountCenterVoApi:getUserAccountInfo(username)
    local users = self:getRegisterUsers()
    return users[username]
end

--保存账号信息
function userAccountCenterVoApi:saveUserAccountInfo(username, udata)
    if username == nil or username == "" or udata == nil then
        do return end
    end
    local users = self:getRegisterUsers()
    local register = users[username] or {}
    if udata.isBind ~= nil then --邮箱是否已绑定
        register.isBind = udata.isBind
    end
    if udata.bc then --绑定验证码
        register.bc = udata.bc
    end
    if udata.bcet then --获取绑定验证码时间戳
        register.bcet = udata.bcet
    end
    if udata.pwdc then --更新密码验证码
        register.pwdc = udata.pwdc
    end
    if udata.pwdcet then --获取密码验证码时间戳
        register.pwdcet = udata.pwdcet
    end
    if udata.mail then --绑定邮箱地址
        register.mail = udata.mail
    end
    if udata.pwdup_ct then --修改密码的次数
        register.pwdup_ct = udata.pwdup_ct
    end
    if udata.pwdup_at then --最近一次修改密码的时间戳
        register.pwdup_at = udata.pwdup_at
    end
    if udata.resetc then --一天重置密码的次数
        register.resetc = udata.resetc
    end
    if udata.resetc_at then --重置密码的时间戳
        register.resetc_at = udata.resetc_at
    end
    users[username] = register
    CCUserDefault:sharedUserDefault():setStringForKey("rayRegisterUsers", G_Json.encode(users))
    CCUserDefault:sharedUserDefault():flush()
end

function userAccountCenterVoApi:getSecurityCode(args, callback)
    local codeUrl = self.url.."sendmail"
    local parms = "platname="..self.platname.."&username="..args.username.."&bind="..args.bind
    if args.pwd then
        parms = parms.."&pwd="..args.pwd
    end
    if args.mail then
        parms = parms.."&mail="..args.mail
    end
    print("获取验证码链接", codeUrl.."?"..parms)
    local result = G_sendHttpRequestPost(codeUrl, parms)
    print("result====>", result)
    if(result ~= "")then
        local sData = G_Json.decode(result)
        G_dayin(sData)
        if sData == nil then
            do return end
        end
        if sData.result == 1 then --获取验证码成功
            local deviceTime = math.floor(G_getCurDeviceMillTime() / 1000)
            if args.bind == 1 then
                sData.bcet = deviceTime + 15 * 60
                self:saveUserAccountInfo(args.username, {bcet = sData.bcet})
            else
                sData.pwdcet = deviceTime + 15 * 60
                self:saveUserAccountInfo(args.username, {pwdcet = sData.pwdcet})
            end
        end
        callback(sData)
    end
end

function userAccountCenterVoApi:bindMail(args, callback)
    local bindUrl = self.url.."bindmail"
    local parms = "platname="..self.platname.."&username="..args.username.."&pwd="..args.pwd.."&mail="..args.mail.."&code="..args.code
    print("绑定邮箱链接", bindUrl.."?"..parms)
    local result = G_sendHttpRequestPost(bindUrl, parms)
    print("result====>", result)
    if(result ~= "")then
        local sData = G_Json.decode(result)
        G_dayin(sData)
        if sData == nil then
            do return end
        end
        if sData.result == 1 then --绑定邮箱成功
            sData.pwdcet = bcet
            self:saveUserAccountInfo(args.username, {mail = args.mail, isBind = 1, bcet = sData.pwdcet})
        end
        if callback then
            callback(sData)
        end
    end
end

--检测账号是否已绑定
function userAccountCenterVoApi:isUserAccountBind(args)
    local user = self:getUserAccountInfo(args.username)
    if user and user.isBind == 1 then
        do return true end
    end
    local checkUrl = self.url.."getbind"
    local parms = "platname="..self.platname.."&username="..args.username
    print("验证是否绑定的接口", checkUrl.."?"..parms)
    local result = G_sendHttpRequestPost(checkUrl, parms)
    print("result====>", result)
    if(result ~= "")then
        local sData = G_Json.decode(result)
        G_dayin(sData)
        if sData == nil then
            return false
        end
        if tonumber(sData.result) == -111 then
            return false
        elseif tonumber(sData.result) == -105 then
            return true
        end
    end
    return false
end

function userAccountCenterVoApi:resetPwd(args, callback)
    local resetUrl = self.url.."updatepwd"
    local parms = "platname="..self.platname.."&username="..args.username.."&pwd="..args.pwd.."&code="..args.code
    print("修改密码链接", resetUrl.."?"..parms)
    local result = G_sendHttpRequestPost(resetUrl, parms)
    print("result====>", result)
    if(result ~= "")then
        local sData = G_Json.decode(result)
        G_dayin(sData)
        if sData == nil then
            do return end
        end
        if sData.result == 1 then --修改密码成功
            sData.pwdcet = 0
            local deviceTime = math.floor(G_getCurDeviceMillTime() / 1000)
            local resetc = 1
            local user = self:getUserAccountInfo(args.username)
            if user and user.resetc then
                resetc = tonumber(user.resetc) + 1
            end
            self:saveUserAccountInfo(args.username, {pwdcet = sData.pwdcet, resetc = resetc, resetc_at = deviceTime})
        end
        if callback then
            callback(sData)
        end
    end
end

--检查邮箱的合法性
function userAccountCenterVoApi:checkEmail(mail)
    if mail == nil or mail == "" or type(mail) ~= "string" then
        return 1
    end
    
    if self:isMail(mail) == true then
        return 0
    else
        return 2
    end
end

function userAccountCenterVoApi:isMail(str)
    if string.len(str or "") < 6 then return false end
    local b, e = string.find(str or "", '@')
    local bstr = ""
    local estr = ""
    if b then
        bstr = string.sub(str, 1, b - 1)
        estr = string.sub(str, e + 1, -1)
    else
        return false
    end
    -- check the string before '@'
    local p1, p2 = string.find(bstr, "[%w%_%.]+")
    if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end
    -- check the string after '@'
    if string.find(estr, "^[%.]+") then return false end
    if string.find(estr, "%.[%.]+") then return false end
    if string.find(estr, "@") then return false end
    if string.find(estr, "%s") then return false end --空白符
    if string.find(estr, "[%.]+$") then return false end
    
    local ds, count = string.gsub(estr, "%.", "")
    if (count < 1) or (count > 3) then
        return false
    end
    
    return true
end

--检查验证码合法性
function userAccountCenterVoApi:checkSecurityCode(code)
    if code == nil or code == "" then
        return 1
    end
    if string.match(code, "^%d%d%d%d%d%d$") then
        return 0
    end
    return 2
end

--检查账号的合法性
function userAccountCenterVoApi:checkUserAccount(name)
    if string.find(name, ' ') ~= nil or string.find(name, ' ') ~= nil then
        return 1
    elseif name == "" then
        return 2
    end
    return 0
end
--检查密码的合法性
function userAccountCenterVoApi:checkPassward(pwd, username)
    if pwd == nil or pwd == "" then
        return 1
    end
    if username and username ~= "" then --如果传入了用户名，则需要校验密码跟用户名是否匹配
        local accountList = G_getHistoryAccount()
        for k, v in pairs(accountList) do
            if username == v[1] and tostring(pwd) ~= tostring(v[2]) then --不匹配
                return 2
            end
        end
    end
    return 0
end

--是否可以重置密码
function userAccountCenterVoApi:isCanResetPwd(username)
    local user = self:getUserAccountInfo(username)
    if user then
        local resetc = tonumber(user.resetc) or 0
        local resetc_at = tonumber(user.resetc_at) or 0
        if resetc_at > 0 and G_isToday(resetc_at) == false then
            local deviceTime = math.floor(G_getCurDeviceMillTime() / 1000)
            resetc, resetc_at = 0, deviceTime
            self:saveUserAccountInfo({resetc = resetc, resetc_at = resetc_at})
        end
        if resetc >= 3 then
            return false
        end
    end
    return true
end
