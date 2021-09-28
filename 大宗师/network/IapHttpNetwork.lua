--[[
 --
 -- add by vicky
 -- 2014.10.23 
 --
 --]]

 require ("zlib")


 local IapHttpNetwork = class("IapRequest") 

 function IapHttpNetwork:ctor() 
    self._network = require("framework.network") 
    self._json = require("framework.json") 
 end


 function IapHttpNetwork:sendRequest(param)
    self._callback = param.callback  
    self._errorCallback = param.errorCallback 
    self._url = param.url 
    self._timeout = param.timeout or 10 
    self._action = param.action or "POST" 

    -- 1.网络不好
    if(self._network.isInternetConnectionAvailable() == false) and (self._network.isLocalWiFiAvailable() == false) then
        printf("3G和WIFI网络不好")
        device.showAlert("无法连接到网络，请检查您的网络", "",{"确定"}, function ()
            os.exit(0);
        end)
        return
    end 

    dump(self._url)

    self:starRequest() 
 end


 function IapHttpNetwork:starRequest() 
    -- 创建一个请求，并以 POST 方式发送数据到服务端
    local request = self._network.createHTTPRequest(handler(self, IapHttpNetwork.onRequestFinished), self._url, self._action) 
    request:setTimeout(self._timeout)
    -- 开始请求。当请求完成时会调用 callback() 函数
    request:start() 
    -- REQ_NUM = 2 
 end


 function IapHttpNetwork:onRequestFinished(event) 
 	-- dump("====onRequestFinished=====")
 	local ok = (event.name == "completed")
    local request = event.request

    if event.name == "failed" then 
        printf("-----  failed:%s", request:getErrorMessage())
        if self._errorCallback ~= nil then
            self._errorCallback()
        end
    end 
 
    if not ok then
        -- 请求失败，显示错误代码和错误消息
        print(request:getErrorCode(), request:getErrorMessage())
        return
    end
 
    local code = request:getResponseStatusCode()
    if code ~= 200 then
        -- 请求结束，但没有返回 200 响应代码
        device.showAlert("Warning","Network Warning!",{"OK"}, function ()

            require("utility.LoadingLayer").destroy()
            end)
        print(code)
        return
    end
 
    -- 请求成功，显示服务端返回的内容
    local zipRes = request:getResponseData()--request:getResponseDataLua()

    local res,eof,bin,bout
    if(ENABLE_GAME_ZLIB == true) then
        -- uncompress data
        res,eof,bin,bout = zlib.inflate()(zipRes)
    else
        res = zipRes
    end

    local codeJson = self._json.decode(res) 
    dump(codeJson) 
    if self._callback ~= nil then 
        self._callback(codeJson) 
    end 
 end 


 return IapHttpNetwork



