-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_ITOOLS = class("GamePlatform_ITOOLS", function () return PlatformBase:new() end)

GamePlatform_ITOOLS.__index = GamePlatform_ITOOLS

function GamePlatform_ITOOLS:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_ITOOLS_GAME_LOGIN_RESPONSE , handler(self, self.OnRespondLoginITOOLSSDK))
end

--服务器平台类型
function GamePlatform_ITOOLS:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_ITOOLS_GAME
end

function GamePlatform_ITOOLS:GetPlatformType()
	return CGamePlatform:GetPlatformType_ITOOLS()
end
    
function GamePlatform_ITOOLS:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginITOOLSSDK(Account, password)
end

function GamePlatform_ITOOLS:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_ITOOLS:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_ITOOLS:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_ITOOLS:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_ITOOLS:CenterDidShowCallBack()

end

function GamePlatform_ITOOLS:CenterDidCloseCallBack()

end

------------------------------------协议--------------------------------
function GamePlatform_ITOOLS:RequestLoginITOOLSSDK(token, password)
	cclog("--------------GamePlatform_ITOOLS:RequestLoginITOOLSSDK---------- "..token)
	local Msg = account_pb.ItoolsGameLoginRequest()
	Msg.session_id = token
	Msg.uid = password
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_ITOOLS_GAME_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_ITOOLS:OnRespondLoginITOOLSSDK(tbMsg)
	cclog("--------------GamePlatform_ITOOLS:OnRespondLoginITOOLSSDK()----------------------")
	local msgDetail = account_pb.ItoolsGameLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.ret == 0 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_ITOOLS:OnRespondLoginITOOLSSDK()-------------")
	else

	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end