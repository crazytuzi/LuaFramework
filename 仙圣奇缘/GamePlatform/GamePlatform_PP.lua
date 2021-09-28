-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_PP = class("GamePlatform_PP", function () return PlatformBase:new() end)

GamePlatform_PP.__index = GamePlatform_PP

function GamePlatform_PP:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_PP_LOGIN_RESPONSE , handler(self, self.OnRespondLoginPPSDK))
end

--服务器平台类型
function GamePlatform_PP:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_PP
end

function GamePlatform_PP:GetPlatformType()
	return CGamePlatform:GetPlatformType_PP()
end
    
function GamePlatform_PP:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginPPSDK(Account)
end

function GamePlatform_PP:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_PP:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_PP:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_PP:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_PP:CenterDidShowCallBack()

end

function GamePlatform_PP:CenterDidCloseCallBack()

end


------------------------------------协议--------------------------------
function GamePlatform_PP:RequestLoginPPSDK(token)
	cclog("--------------GamePlatform_PP:RequestLoginPPSDK---------- "..token)
	local Msg = account_pb.PPPlatformLoginRequest()
	Msg.sid = token
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_PP_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_PP:OnRespondLoginPPSDK(tbMsg)
	cclog("--------------GamePlatform_PP:OnRespondLoginPPSDK()----------------------")
	local msgDetail = account_pb.PPPlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	--pp文档
	if msgDetail.errorCode == 1 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_PP:OnRespondLoginPPSDK()-------------")
	else

	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end