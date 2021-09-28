-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_GP = class("GamePlatform_GP", function () return PlatformBase:new() end)

GamePlatform_GP.__index = GamePlatform_GP

function GamePlatform_GP:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_GUOPAN_LOGIN_RESPONSE , handler(self, self.OnRespondLoginGPSDK))
end

--服务器平台类型
function GamePlatform_GP:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_GUOPAN
end

function GamePlatform_GP:GetPlatformType()
	return CGamePlatform:GetPlatformType_GP()
end
    
function GamePlatform_GP:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginGPSDK(Account,password)
end

function GamePlatform_GP:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_GP:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_GP:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_GP:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_GP:CenterDidShowCallBack()

end

function GamePlatform_GP:CenterDidCloseCallBack()

end


------------------------------------协议--------------------------------
function GamePlatform_GP:RequestLoginGPSDK(token, password)
	cclog("--------------GamePlatform_GP:RequestLoginGPSDK---------- "..token)

	local Msg = account_pb.GuoPanPlatformLoginRequest()
	Msg.game_uin = password
    Msg.token = token
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_GUOPAN_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_GP:OnRespondLoginGPSDK(tbMsg)
	cclog("--------------GamePlatform_GP:OnRespondLoginGPSDK()----------------------")
	local msgDetail = account_pb.GuoPanPlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.ret == 0 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_GP:OnRespondLoginGPSDK()-------------")
	else

	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end