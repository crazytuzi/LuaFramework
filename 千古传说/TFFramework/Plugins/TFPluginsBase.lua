--[[
SDK代理类


]]

local TFPluginsBase = {}

-- --(pPlugin: ProtocolUser, 用户系统插件, code: UserActionResultCode ，登陆回调返回值；msg : string，返回登陆信息，可能为空)
TFPluginsBase.initcallback 		= nil
TFPluginsBase.logincallback 	= nil
TFPluginsBase.loginoutcallback 	= nil
TFPluginsBase.leavecallback 	= nil
TFPluginsBase.paycallback 		= nil

-- 母包的channelid = 999999

function TFPluginsBase.InitPlugins()
	--获取AgentManger
	local agent = AgentManager:getInstance()

	local ChannelId = agent:getChannelId()

	print("InitPlugins ChannelId = ", ChannelId)
	-- ChannelId =    000255 uc

	--初始化并load plugins(注意：初始化和load最好只进行一次，建议agent设置为全局的)
	--init
	local appKey 		= "FF62375B-9E80-213E-A4C4-181142784BE3";
	local appSecret 	= "80e11239f705c827c5b95ab3460250e9";
	local privateKey 	= "FBB186039402BED23337FF3F39CB9EF1";
	local oauthLoginServer = "http://oauth.anysdk.com/api/OauthLoginDemo/Login.php";
	agent:init(appKey,appSecret,privateKey,oauthLoginServer)
	--load
	agent:loadALLPlugin()


	TFPluginsBase.Agent = agent

	--get user
	local user_plugin = agent:getUserPlugin()

	user_plugin:setActionListener(TFPluginsBase.onActionListener)
end

function TFPluginsBase.onActionListener(pPlugin, code, msg)
	-- print("TFPluginsBase.onActionListener")
 --    print("pPlugin  = ", pPlugin)
    print("code 	= ", code)
    print("msg  	= ", msg)

    if code == UserActionResultCode.kInitSuccess then  --初始化SDK成功回调
        --sdk初始化成功，游戏相关处理
        TFPluginsBase.InitCallBack(code, msg)
    end

    if code == UserActionResultCode.kInitFail  then   --初始化SDK失败回调
        --sdk初始化失败，游戏相关处理
        TFPluginsBase.InitCallBack(code, msg)
    end

	    --处理回调函数	
	if code == UserActionResultCode.kLoginSuccess  then   --登陆成功回调
	    --登陆成功后，游戏相关处理
        TFPluginsBase.token = msg
	    TFPluginsBase.LoginCallBack(code, msg)
	end
	if code == UserActionResultCode.kLoginTimeOut  then   --登陆失败回调
	    --登陆失败后，游戏相关处理
	    TFPluginsBase.LoginCallBack(code, msg)
	end
	if code == UserActionResultCode.kLoginCancel  then   --登陆取消回调
	    --登陆失败后，游戏相关处理
	    TFPluginsBase.LoginCallBack(code, msg)
	end
	if code == UserActionResultCode.kLoginFail  then   --登陆失败回调
	    --登陆失败后，游戏相关处理
	    TFPluginsBase.LoginCallBack(code, msg)
	end

	--处理回调函数	
	if code == UserActionResultCode.kLogoutSuccess then  --用户登出成功回调
	    --登出成功，游戏相关操作
	    TFPluginsBase.LoginOutCallBack(code, msg)
	end
	
	if code == UserActionResultCode.kLogoutFail then  --平台中心退出回调
	    --登出失败，游戏相关操作
	    TFPluginsBase.LoginOutCallBack(code, msg)
	end

	--处理回调函数	
	if code == UserActionResultCode.kPlatformEnter then  --平台中心进入回调
	    --do something
	    TFPluginsBase.LeaveCallBack(code, msg)
	end
	if code == UserActionResultCode.kPlatformBack then  --平台中心退出回调
	    --do something
	    TFPluginsBase.LeaveCallBack(code, msg)
	end

	--处理回调函数	
	if code == UserActionResultCode.kAccountSwitchSuccess  then   --切换账号成功回调
	    --切换账号成功，游戏相关操作
	end
	if code == UserActionResultCode.kAccountSwitchFail  then   --切换账号失败回调
	    --切换账号失败，游戏相关操作
	end

end

function TFPluginsBase.isLogined()

	local agent = TFPluginsBase.Agent
	local user_plugin = agent:getUserPlugin();
	if nil ~= user_plugin then
	    return user_plugin:isLogined()
	end

	return false
end


function TFPluginsBase.getUserID()

	local agent = TFPluginsBase.Agent
	local user_plugin = agent:getUserPlugin();
	if nil ~= user_plugin then
	    return user_plugin:getUserID()
	end
end

function TFPluginsBase.setUserID(uid)

end

function TFPluginsBase.getChannelId()

	local agent = TFPluginsBase.Agent
	
	if nil ~= agent then
	    return agent:getChannelId()
	end

	return ""
end


function TFPluginsBase.Login(callBack)
	TFPluginsBase.setLoginCallBack(callBack)

		--调用用户系统登陆功能
	local agent = TFPluginsBase.Agent
	local user_plugin = agent:getUserPlugin();
	if nil ~= user_plugin then
	    user_plugin:login()
	end
end

function TFPluginsBase.LoginOut(callback)
	-- TFPluginsBase.setLoginOutCallBack(callback)

		--调用
	local agent = TFPluginsBase.Agent
	local user_plugin = agent:getUserPlugin();
	if nil ~= user_plugin and user_plugin:isFunctionSupported("logout") then
	    user_plugin:callFuncWithParam("logout")
	end
end


function TFPluginsBase.EnterPlatform()
	local agent = TFPluginsBase.Agent
	--调用用户系统进入平台中心功能
	local user_plugin = agent:getUserPlugin();
	if nil ~= user_plugin and user_plugin:isFunctionSupported("enterPlatform")  then
	    user_plugin:callFuncWithParam("enterPlatform");
	end
end

function TFPluginsBase.showToolBar(ToolBarPlace)
	local agent = TFPluginsBase.Agent
	local user_plugin = agent:getUserPlugin();
	if nil ~= user_plugin and user_plugin:isFunctionSupported("showToolBar")  then
	    local param1 = PluginParam:create(ToolBarPlace)
	    user_plugin:callFuncWithParam("showToolBar", param1);
	end
end

function TFPluginsBase.hideToolBar()
	local agent = TFPluginsBase.Agent
	--在暂停时隐藏悬浮按钮
	local user_plugin = agent:getUserPlugin();
	if nil ~= user_plugin and user_plugin:isFunctionSupported("hideToolBar")  then
	    user_plugin:callFuncWithParam("hideToolBar")
	end
end

function TFPluginsBase.accountSwitch()
	local agent = TFPluginsBase.Agent
	--用户系统调用切换账号功能
	local user_plugin = agent:getUserPlugin();
	if nil ~= user_plugin and user_plugin:isFunctionSupported("accountSwitch") then
	    user_plugin:callFuncWithParam("accountSwitch")
	    print("TFPluginsBase.accountSwitch111")
	else
		print("TFPluginsBase.accountSwitch222")
		toastMessage("渠道暂时不支持切换账号，请在用户中心切换账户")
	end
end

function TFPluginsBase.setInitCallBack(callback)
	if callback then 
        if type(callback) == 'function' then
            TFPluginsBase.initcallback 	= callback
        else
            print("=====init===setInitCallBack=error",callback)
            return
        end
    end
	
end

function TFPluginsBase.InitCallBack(code, msg)
	if TFPluginsBase.initcallback then
		TFPluginsBase.initcallback(code, msg)
	end
end

function TFPluginsBase.setLoginCallBack(callback)
	TFPluginsBase.logincallback = nil
	if callback then 
        if type(callback) == 'function' then
            TFPluginsBase.logincallback 	= callback
        else
            print("=====init===logincallback=error",callback)
            return
        end
    end
end

function TFPluginsBase.LoginCallBack(code, msg)
	if TFPluginsBase.logincallback then
		TFPluginsBase.logincallback(code, msg)
	end
end

function TFPluginsBase.setLoginOutCallBack(callback)
	if callback then 
        if type(callback) == 'function' then
            TFPluginsBase.loginoutcallback 	= callback
        else
            print("=====init===loginoutcallback=error",callback)
            return
        end
    end
end

function TFPluginsBase.LoginOutCallBack(code, msg)
	if TFPluginsBase.loginoutcallback then
		TFPluginsBase.loginoutcallback(code, msg)
	end
end

function TFPluginsBase.setLeaveCallBack(callback)
	if callback then 
        if type(callback) == 'function' then
            TFPluginsBase.leavecallback 	= callback
        else
            print("=====init===leavecallback=error")
            return
        end
    end
end

function TFPluginsBase.LeaveCallBack(code, msg)
	if TFPluginsBase.leavecallback then
		TFPluginsBase.leavecallback(code, msg)
	end
end

function TFPluginsBase.getSdkVersion()
	--调用
	local agent = TFPluginsBase.Agent
	local user_plugin = agent:getUserPlugin();
	if nil ~= user_plugin then
	    return user_plugin:getSDKVersion()
	end
end	

function TFPluginsBase.setSdkVersion(version)
	sdkVerison = version
end	


function TFPluginsBase.getSdkName()
	local agent = TFPluginsBase.Agent

	local user_plugin = agent:getUserPlugin();
	if nil ~= user_plugin then
	    return user_plugin:getPluginName()
	end
end 

function TFPluginsBase.setSdkName(name)
	sdkName = name
end 


function TFPluginsBase.getCheckServerToken()
	return TFPluginsBase.token
end

function TFPluginsBase.setToken(checkToken)
	TFPluginsBase.token = checkToken
end

-- 是否为母包，母包没有任何sdk 
function TFPluginsBase.isPluginExist()
	if AgentManager == nil then
		return false
	end

	--获取AgentManger
	local agent = AgentManager:getInstance()

	local ChannelId = agent:getChannelId()
	print("ChannelId = ", ChannelId)
	if ChannelId == "999999" then
		return false
	end

	return true
end

 -- local info = {
 --       Product_Price="1", 
 --       Product_Id="monthly",  
 --       Product_Name="gold",  
 --       Server_Id="13",  
 --       Product_Count="1",  
 --       Role_Id="1001",  
 --       Role_Name="zhangsan",
 --       Role_Grade="50",
 --       Role_Balance="1"
 --   }
function TFPluginsBase.pay(itemInfo)
	--key就是plugin_id
	local agent 		      = AgentManager:getInstance()
	local iap_plugin_maps 	  = agent:getIAPPlugin()
	local PLUGIN_TONGBUTUI_ID = agent:getChannelId()

	for key, value in pairs(iap_plugin_maps) do
		print("pay ChannelId = ", key)
	    -- if  key == PLUGIN_TONGBUTUI_ID  then
	    	print("TFPluginsBase.pay")
	        value:payForProduct(itemInfo)
	        return
	    -- end
	end

	print("TFPluginsBase.pay can not be find")
end


function TFPluginsBase.setPayCallback(callback)
	if callback then 
        if type(callback) == 'function' then
            TFPluginsBase.paycallback 	= callback
        else
            print("=====init===setPayCallback=error")
            return
        end
    end

    local agent 		      = AgentManager:getInstance()
	local iap_plugin_maps 	  = agent:getIAPPlugin()
	local PLUGIN_TONGBUTUI_ID = agent:getChannelId()

	for key, value in pairs(iap_plugin_maps) do
		value:setResultListener(TFPluginsBase.PayCallback)
	end
end

function TFPluginsBase.PayCallback(code, msg, info)
-- 支付成功	kPaySuccess	null或者错误信息的简单描述
-- 支付取消	kPayCancel	null或者错误信息的简单描述
-- 支付失败	kPayFail	null或者错误信息的简单描述
-- 支付网络出现错误	kPayNetworkError	null或者错误信息的简单描述
-- 支付信息提供不完全	kPayProductionInforIncomplete	null或者错误信息的简单描述
	print("TFPluginsBase.PayCallback")
	print("code = ", code)
	print("msg  = ", msg)
	print("info = ", info)
	if TFPluginsBase.paycallback then
		TFPluginsBase.paycallback(code, msg, info)
	end
end


return TFPluginsBase