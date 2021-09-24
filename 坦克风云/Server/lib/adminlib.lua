local Adminlib = {}

-- 系统调用的
local cronApi = {
    ["admin.autobuilding"]=true,
    ["admin.getluastatus"]=true,
    ["admin.setusermap"] = true,
    ["admin.accountsbattle"] = true,
    ["admin.getgameconfig"] = true,
}

-- 管理工具用的
local toolApi = {
    ["admin.setbuilding"]=true,
    ["admin.settech"]=true,
    ["admin.addtroop"]=true,
    ["admin.setskill"]=true,
    ["admin.setuser"]=true,
    ["admin.pay"]=true,
    -- ["admin.mail"]=true,
    ["admin.addaccessory"]=true,
    ["admin.addheros"]=true,
    ["admin.setalien"]=true,
    ["admin.setgag"]=true,
    ["admin.sendgems"]=true,
    ["admin.mailsend"]=true,
    ["admin.worldlevel"]=true,
    ["admin.modifyacrosspoint"]=true,
    ["admin.setgameconfig"]=true,
    ["admin.rebellist"]=true,
    ["admin.rename"]=true,
    ["admin.goldmineadmin"] = true,
    ["admin.allmail"] = true,
    ["admin.notice"] = true,
    ["admin.openbarrier"] = true,
    ["admin.sendtorewardcenter"] = true,
    ["admin.setalliance"] = true,
    ["admin.setallmail"] = true,
    ["admin.setboom"] = true,
    ["admin.setequip"] = true,
    ["admin.setnotice"] = true,
    ["admin.setpoint"] = true,
    -- ["admin.setusermap"] = true,
    ["admin.setweapon"] = true,
    ["admin.user"] = true,
    ["admin.userDevices"] = true,
    ["admin.setarmor"] = true,
    -- 平台方也在用
    ["admin.addgem"]=true,
    ["admin.addprop"]=true,
    ["admin.addrewardbag"]=true,
    ["admin.killrace.new"]=true,
    ["admin.killrace.update"]=true,
    ["admin.killrace.get"]=true,
    ["admin.killrace.setuser"]=true,
}

-- 平台方用的
local platformApi = {
    ["admin.getuser"] = true,
    ["admin.getuserinfo"] = true,
    ["admin.sendgiftbag.send"] = true,
}

local sort = function(tb)
    local str = ""
    local p = {}
    for k,v in pairs(tb) do
        table.insert(p,k)
    end

    table.sort(p)
    for k,v in pairs(p) do
        if type(tb[v]) == "string" or type(tb[v]) == "number" then
            str = str .. tostring(tb[v])
        else
            str = str .. v .. tostring(k)
        end
    end

    p = nil

    return str
end

local function getAdminRequestToken(request)
    do return request.admin_token end

    local adminAccount = request.adminname
    local ts = request.ts

    local paramsString = adminAccount .. ts

    paramsString = paramsString .. sort(request) .. sort(request.params)
    local secret = getConfig("base.ADMINSECRETKEY")
    paramsString = paramsString .. secret

    local sha1 = require "lib.sha1"
    local base64 = require "lib.base64"

    local token = sha1(paramsString)
    token = base64.Encrypt(token)

    return token
end

Adminlib.check = function(request)
    return true
    --local token = getAdminRequestToken(request)
    --local http = require("socket.http")
    --http.TIMEOUT= 5

    --local logUrl,actionLogUrl
    --local adminToolCfg = getConfig('config.adminTool')
    --local url = adminToolCfg.url
    --local ip = adminToolCfg.ip

    --if ip ~= getClientIP() then
       -- return false
    --end

    --local postData = http_build_query({token=token,ts=os.time(),adminAccount=request.adminAccount})
    --local sendret = http.request(url .. postData)

    --sendret = sendret and json.decode(sendret)

    --if type(sendret) == "table" and sendret.ret == 0 and sendret.msg == "Success" then
        --return true
    --end
end

Adminlib.getAdminApi = function()
    return toolApi,platformApi,cronApi
end

return Adminlib