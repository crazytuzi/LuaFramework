-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_OPPO = class("GamePlatform_OPPO", function () return PlatformBase:new() end)

GamePlatform_OPPO.__index = GamePlatform_OPPO

function GamePlatform_OPPO:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_OPPO_LOGIN_RESPONSE , handler(self, self.OnRespondLoginOPPOSDK))
end

--服务器平台类型
function GamePlatform_OPPO:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_OPPO
end

function GamePlatform_OPPO:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_OPPO:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginOPPOSDK(Account, password)
end

function GamePlatform_OPPO:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_OPPO:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_OPPO:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_OPPO:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_OPPO:CenterDidShowCallBack()

end

function GamePlatform_OPPO:CenterDidCloseCallBack()

end

function GamePlatform_OPPO:submitExtendData(roleId, roleName, roleLevel, zoneName, zoneId)
	CGamePlatform:SharedInstance():submitExtendData(roleId, roleName, roleLevel, zoneName, zoneId)
end


------------------------------------协议--------------------------------
function GamePlatform_OPPO:RequestLoginOPPOSDK(token, uid)
	cclog("--------------GamePlatform_HM:RequestLoginOPPOSDK---------- "..token.." uid="..uid)
	local Msg = account_pb.PLOppoLoginRequest()
	Msg.oauth_tokne_secret = uid
	Msg.oauth_token = token
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_OPPO_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_OPPO:OnRespondLoginOPPOSDK(tbMsg)
	cclog("--------------GamePlatform_PP:OnRespondLoginOPPOSDK()----------------------")
	local msgDetail = account_pb.PLOppoLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.is_success then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_HM:OnRespondLoginOPPOSDK-------------")
	else

	end
	
	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end