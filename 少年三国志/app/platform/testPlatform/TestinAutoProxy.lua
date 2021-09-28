local TestinAutoProxy = class("TestinAutoProxy", require("app.platform.PlatformProxy"))
local storage = require("app.storage.storage")

local TEST_PROXY_FILE = "test_proxy.data"

function TestinAutoProxy:ctor(...)
    self.super.ctor(self, ...)
    self._opId = 1
    self._userName = ""

    local model = UFCCSModelLayer.new()
    local mask = CCLayerColor:create(ccc4(0, 0, 0, 0.1*255), display.width, display.height)
    mask:setTouchEnabled(true)
    model:addChild(mask)
    uf_notifyLayer:getModelNode():addChild(model)

end



--获取推荐的服务器, 用于登陆显示
function TestinAutoProxy:getRecommendServer()
    --获取上次登陆的server id
    
    return  {name="QA外网", id=101, login="http://122.226.211.153//web/hook_login/login.php", gateway="122.226.211.153",port=8118}

end



function TestinAutoProxy:getLoginServer()
    return self:getRecommendServer()
end

function TestinAutoProxy:beforeLogin()
    --自动使用新角色登陆游戏

    local userName = "testin" .. FuncHelperUtil:getCurrentTime() .. '_' .. math.random(10000) .. "_" ..math.random(10000)

    self:_onLoginedPlatform({uid =userName})
end

function TestinAutoProxy:getToken(opId, params, callback)
    self._server = self:getLoginServer()

    local url =  self._server.login--'http://192.168.1.159/web/hook_login/login.php';
    url = url .. "?op_id=" .. opId .. "&params=" .. json.encode(params)
    print(url)


 
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
        local t=json.decode(response)
        if t then
            local ok = (event.name == "completed")
            if ok then
                --获得了token
                print("token=" ..t["accessToken"])

                --if t.userinfo and t.userinfo.uid then
                --    self._platform_uid = t.userinfo.uid
               -- end
                callback(t["accessToken"])

                self:loginGame()

            end
        else
            CCMessageBox("token is wrong","error")
        end

    end)
    request:start()
end


function TestinAutoProxy:_onLoginedPlatform(params)
    self._userName = params.uid
    self:getToken(self._opId, params, handler(self,self._onGetToken))
end

function TestinAutoProxy:_onNeedCreateRole() 
    -- G_HandlersManager.coreHandler:sendCreateRole( "xxxx", 1)
    uf_sceneManager:pushScene(require("app.platform.testPlatform.TestinBattleScene").new({["msg"] = require("app.cfg.guide_battle").info}))

end

return TestinAutoProxy
