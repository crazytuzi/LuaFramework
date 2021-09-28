-- 文件名:	GamePlatform_TlanCi.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_TlanCi = class("GamePlatform_TlanCi", function () return PlatformBase:new() end)
GamePlatform_TlanCi.__index = GamePlatform_TlanCi

function GamePlatform_TlanCi:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_ANDROID_TIANCI_LOGIN_RESPONSE , handler(self, self.OnRespondTianCiPlatformLoginResponseSDK))
end

--服务器平台类型 LOGIN_PLATFORM_TIANCI
function GamePlatform_TlanCi:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_TIANCI
end

function GamePlatform_TlanCi:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_TlanCi:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestTianCiPlatformLoginRequestSDK(Account)
end

function GamePlatform_TlanCi:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_TlanCi:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_TlanCi:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_TlanCi:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_TlanCi:CenterDidShowCallBack()

end

function GamePlatform_TlanCi:CenterDidCloseCallBack()

end

function GamePlatform_TlanCi:submitExtendData(roleId, roleName, roleLevel, zoneName, zoneId)
	CGamePlatform:SharedInstance():submitExtendData(roleId, roleName, roleLevel, zoneName, zoneId)
end


------------------------------------协议--------------------------------
function GamePlatform_TlanCi:RequestTianCiPlatformLoginRequestSDK(token)
	-- cclog("--------------RequestTianCiPlatformLoginRequestSDK---------- "..token.." uid="..uid)
	local msg = account_pb.TianCiPlatformLoginRequest()
	msg.tcsso = token
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_ANDROID_TIANCI_LOGIN_REQUEST, msg)
	g_MsgNetWorkWarning:showWarningText()
end

-- 天赐登录响应

function GamePlatform_TlanCi:OnRespondTianCiPlatformLoginResponseSDK(tbMsg)
	cclog("-------------OnRespondTianCiPlatformLoginResponseSDK----------------------")
	local msgDetail = account_pb.TianCiPlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	
	if msgDetail.ret == 1  then 
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		
		g_ServerList:RequestServerListInfo()
	end
	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()
end