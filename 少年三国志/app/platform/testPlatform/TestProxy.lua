local TestProxy = class("TestProxy", require("app.platform.PlatformProxy"))
local storage = require("app.storage.storage")

local TEST_PROXY_FILE = "test_proxy.data"
local ComSdkUtils = require("upgrade.ComSdkUtils")

function TestProxy:ctor(...)
    self.super.ctor(self, ...)

    self._opId = ComSdkUtils:getOpId()
    
    self._userName = ""

end



-- 登陆平台
function TestProxy:loginPlatform()
    self._wantAutoEnterGame = false
    self:_loginPlatform()    
end

function TestProxy:_loginPlatform()
    --一般来说这个时候是要弹出一个登陆框让玩家输入用户名和密码(参考91和PP助手)
    --由于我们这里是测试用的假平台, 再做一个自动登陆好了
    if self._wantAutoEnterGame and self:getLoginUserName() ~= "" then
        local userName = self:getLoginUserName()
        G_MovingTip:showMovingTip("正在以" ..userName .."登陆" )

        self:_onLoginedPlatform({uid =userName})
        return
    end

     
    
    
    local loginLayer = require("app.platform.testPlatform.TestProxyLayer").create()
    loginLayer:setLoginCallback(handler(self, self._onLoginedPlatform))
    uf_notifyLayer:getModelNode():addChild(loginLayer)
    loginLayer:showAtCenter(true)
   
    
end

function TestProxy:getToken(opId, params, callback)
    local server = self:getLoginServer()
    local url =  server.login--'http://192.168.1.159/web/hook_login/login.php';
    url = url .. "?op_id=" .. opId .. "&uid=" .. params.uid


    trace("get token:" .. url)
    callback(params.uid)


    --[[local server = self:getLoginServer()
    local url =  server.login--'http://192.168.1.159/web/hook_login/login.php';
    url = url .. "?op_id=" .. opId .. "&uid=" .. params.uid


 
    local request = uf_netManager:createHTTPRequestGet(url, function(event) 
        local request = event.request
        local errorCode = request:getErrorCode()
        if errorCode ~= 0 then
            MessageBoxEx.showOkMessage(nil, 
                G_lang:get("LANG_ERROR_NETWORK"), false, 
                function ( ... )
                    
                end
            )
            return
        end

        local response = request:getResponseString()
        --print(response)
        local t=json.decode(response)
        if t then
            local ok = (event.name == "completed")
            if ok then
                --获得了token
                if t.status == 1 then
                     print("token=" ..t["osdk_ticket"])

                     --if t.userinfo and t.userinfo.uid then
                     --    self._platform_uid = t.userinfo.uid
                    -- end
                     callback(t["osdk_ticket"])
                 else
                    MessageBoxEx.showOkMessage(nil, 
                       "该账号暂时无法登录", false, 
                        function ( ... )
                            
                        end
                    )
                end
              
            end
        else
            CCMessageBox("token is wrong","error")
        end

    end)
    request:start()]]
end


function TestProxy:_onLoginedPlatform(params)
    --dump(params)
    self._userName = params.uid
    if params.opId ~= nil then
        self._opId = params.opId         
    end

    if params.serverId and params.serverName and params.gateway then
        --set loginserver
        local server = G_ServerList:addTestServer(params.serverId , params.serverName, params.gateway)
        G_PlatformProxy:setLoginServer(server)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_UPDATE_SERVER_LIST, nil, false)
    end

    storage.save(storage.path(TEST_PROXY_FILE), {userName = self._userName})
     --local a = ccc .. ".."
     --开始跟verify接口交互取到token
    self:getToken(self._opId, params, handler(self,self._onGetToken))
    
end

function TestProxy:getDefaultRoleName()
    return self._userName
end

function TestProxy:getLoginUserName()

    --todo
    --这里是个临时fix, 后面要删掉,

    local old = storage.load( CCFileUtils:sharedFileUtils():getWritablePath().. "/" .. TEST_PROXY_FILE)
    if old and old.userName then
        -- print("copy to new place")
        storage.save(storage.path(TEST_PROXY_FILE), {userName = old.userName})
        storage.save(CCFileUtils:sharedFileUtils():getWritablePath() .. "/" .. TEST_PROXY_FILE, {})
    end
    



    local proxyInfo = storage.load(storage.path(TEST_PROXY_FILE))

    

    if proxyInfo then
        return proxyInfo.userName
    end
    return ""
end

return TestProxy
