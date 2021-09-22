GameAccountCenter={}

function GameAccountCenter.init()
	
end

-------------------------------call-----------------------------

function GameAccountCenter.onLoginZk(paramsTab)
    local params = nil;
    local loginUrl = nil;
    if paramsTab[2] then params=paramsTab[2] end
    if paramsTab[3] then loginUrl=paramsTab[3] end

    local http=cc.XMLHttpRequest:new()
    
    local function http_callback()
        --print("http_callback ",http.status)
        local state=http.status
        if state>=200 and state<=300 then
            local response=http.response
            --local json=string.gsub(GameUtilBase.unicode_to_utf8(response),"\\","")  --这一串貌似没什么必要,还大大降低效率
			local json=response
			--print("http_callback 2")
			--print(json)
            json=GameUtilBase.decode(json)
			--print("http_callback 3")
            if type(json)=="table" and GameCCBridge then
                local data = json["data"];
                local code = tonumber(json["code"]);
                if code == 0 then
                    GameCCBridge.hideWaiting();

                    local fileUtils = cc.FileUtils:getInstance()

                    local anncInfo = data["anncInfo"];
                    if anncInfo then
                        local annc = anncInfo["annc"]
                        local path=fileUtils:getWritablePath().."annc.json";
                        local b = fileUtils:writeStringToFile(annc, path);
                        if b then
                            print("------>写入annc信息成功")
                        end
                    end

                    local serverInfo = data["serverInfo"]
                    if serverInfo then
                        local servers = serverInfo["servers"];
                        servers = GameUtilBase.encode(servers)
                        local path=fileUtils:getWritablePath().."serverList.json";
                        local b = fileUtils:writeStringToFile(servers, path);
                        if b then
                            print("------>写入servers信息成功")
                        end
                    end

                    local player = data["player"];
                    if player then
                        local loginKey = player["loginKey"];
                        local accountId = player["accountId"];
                        GameBaseLogic.accountId = accountId;
                        print("===============>loginKey = "..loginKey)
                        print("===============>accountId = "..accountId)
                        local arg = "onLogin|"..loginKey;
                        GameCCBridge.callListener(arg)
						GameCCBridge.doSdkLoginSuccess()
                    end
                elseif code == 101 then --帐号密码不正确
                    GameCCBridge.hideWaiting();
                    GameCCBridge.showMsg(json.message);
				else
                    GameCCBridge.hideWaiting();
                    GameCCBridge.showMsg(json.message);
                end
            end
        else
			GameCCBridge.hideWaiting();
			GameCCBridge.showMsg("网络异常，登录校验失败")
            print("请求失败")
        end
    end
	
    http.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    http:setRequestHeader("Content-Type", "application/json")
    http:registerScriptHandler(http_callback)
    http:open("POST", loginUrl)

    GameCCBridge.showWaiting({msg="正在登录..."})
	
    http:send(params)
    
end

function GameAccountCenter.logout()
	
end

function GameAccountCenter.showCenter()
	
end

function GameAccountCenter.switchToolBar()
	
end

function GameAccountCenter.appScore()
	
end

function GameAccountCenter.pay(order,number,listener)

end

function GameAccountCenter.showExit()
	
end

-------------------------------listener-----------------------------

function GameAccountCenter.onLogin(param)
	
end

function GameAccountCenter.onLogout()
	
end

function GameAccountCenter.onPayed(params)

	

end

-------------------------------tools-----------------------------

function GameAccountCenter.checkShowCenter()
	
end

function GameAccountCenter.checkPayList()
	
end

return GameAccountCenter