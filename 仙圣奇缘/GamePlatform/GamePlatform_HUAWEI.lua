-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_HUAWEI = class("GamePlatform_HUAWEI", function () return PlatformBase:new() end)

GamePlatform_HUAWEI.__index = GamePlatform_HUAWEI

function GamePlatform_HUAWEI:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_HUAWEI_LOGIN_RESPONSE , handler(self, self.OnRespondHuaweiPlatformLoginSDK))
end

--服务器平台类型 LOGIN_PLATFORM_HUAWEI
function GamePlatform_HUAWEI:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_HUAWEI
end

function GamePlatform_HUAWEI:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_HUAWEI:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestHuaweiPlatformLoginSDK(Account)
end

function GamePlatform_HUAWEI:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_HUAWEI:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_HUAWEI:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_HUAWEI:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_HUAWEI:CenterDidShowCallBack()

end

function GamePlatform_HUAWEI:CenterDidCloseCallBack()

end

function GamePlatform_HUAWEI:submitExtendData(roleId, roleName, roleLevel, zoneName, zoneId)
	CGamePlatform:SharedInstance():submitExtendData(roleId, roleName, roleLevel, zoneName, zoneId)
end

------------------------------------协议--------------------------------
function GamePlatform_HUAWEI:RequestHuaweiPlatformLoginSDK(token)
	-- cclog("--------------RequestHuaweiPlatformLoginSDK---------- "..token.." uid="..uid)
	local msg = account_pb.HuaweiPlatformLoginRequest()
	msg.token = token
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_HUAWEI_LOGIN_REQUEST, msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_HUAWEI:OnRespondHuaweiPlatformLoginSDK(tbMsg)
	cclog("-------------OnRespondHuaweiPlatformLoginSDK----------------------")
	local msgDetail = account_pb.HuaweiPlatformLoginResponse()
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