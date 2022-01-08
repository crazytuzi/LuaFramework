--[[
SDK代理类


]]

local TFPluginsBase = {}

-- --(pPlugin: ProtocolUser, 用户系统插件, code: UserActionResultCode ，登陆回调返回值；msg : string，返回登陆信息，可能为空)
TFPluginsBase.initcallback 		= nil
TFPluginsBase.logincallback 	= nil
TFPluginsBase.loginoutcallback 	= nil
TFPluginsBase.leavecallback 	= nil

local token 		= "Let Me In!"
local userid 		= nil
local sdkVerison 	= nil
local sdkName 		= nil

function TFPluginsBase.InitPlugins()

end

function TFPluginsBase.onActionListener(pPlugin, code, msg)


end

function TFPluginsBase.isLogined()

	return false
end


function TFPluginsBase.getUserID()
	return userid
end

function TFPluginsBase.setUserID(uid)
	userid = uid
end


function TFPluginsBase.getChannelId()
	return ""
end

function TFPluginsBase.Login(callBack)

end

function TFPluginsBase.LoginOut(callback)

end


function TFPluginsBase.EnterPlatform()

end

function TFPluginsBase.showToolBar(ToolBarPlace)

end

function TFPluginsBase.hideToolBar()

end

function TFPluginsBase.accountSwitch()


end

function TFPluginsBase.setInitCallBack(callback)

end

function TFPluginsBase.InitCallBack(code, msg)

end

function TFPluginsBase.setLoginCallBack(callback)

end

function TFPluginsBase.LoginCallBack(code, msg)

end

function TFPluginsBase.setLoginOutCallBack(callback)

end

function TFPluginsBase.LoginOutCallBack(code, msg)

end

function TFPluginsBase.setLeaveCallBack(callback)

end

function TFPluginsBase.LeaveCallBack(code, msg)

end

function TFPluginsBase.getSdkVersion()
	return sdkVerison
end	

function TFPluginsBase.setSdkVersion(version)
	sdkVerison = version
end	

function TFPluginsBase.getSdkName()
	return sdkName
end


function TFPluginsBase.setSdkName(name)
	sdkName = name
end 

function TFPluginsBase.getCheckServerToken()
	return token
end

function TFPluginsBase.setToken(checkToken)
	token = checkToken
end

-- 是否为母包，母包没有任何sdk 
function TFPluginsBase.isPluginExist()

	return false
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

end

function TFPluginsBase.setPayCallback(callback)

end

function TFPluginsBase.PayCallback(code, msg, info)
-- 支付成功	kPaySuccess	null或者错误信息的简单描述
-- 支付取消	kPayCancel	null或者错误信息的简单描述
-- 支付失败	kPayFail	null或者错误信息的简单描述
-- 支付网络出现错误	kPayNetworkError	null或者错误信息的简单描述
-- 支付信息提供不完全	kPayProductionInforIncomplete	null或者错误信息的简单描述
end

return TFPluginsBase