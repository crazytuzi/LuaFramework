-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_HM = class("GamePlatform_HM", function () return PlatformBase:new() end)

GamePlatform_HM.__index = GamePlatform_HM

function GamePlatform_HM:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_HAIMA_LOGIN_RESPONSE , handler(self, self.OnRespondLoginHMSDK))
end

--服务器平台类型
function GamePlatform_HM:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_HAIMA
end

function GamePlatform_HM:GetPlatformType()
	return CGamePlatform:GetPlatformType_HM()
end
    
function GamePlatform_HM:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginHMSDK(Account, password)
end

function GamePlatform_HM:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_HM:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_HM:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_HM:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_HM:CenterDidShowCallBack()

end

function GamePlatform_HM:CenterDidCloseCallBack()

end


------------------------------------协议--------------------------------
function GamePlatform_HM:RequestLoginHMSDK(token, uid)
	cclog("--------------GamePlatform_HM:RequestLoginHMSDK---------- "..token.." uid="..uid)
	local Msg = account_pb.HaimaPlatformLoginRequest()
	Msg.uid = uid
	Msg.token = token
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_HAIMA_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_HM:OnRespondLoginHMSDK(tbMsg)
	cclog("--------------GamePlatform_PP:OnRespondLoginPPSDK()----------------------")
	local msgDetail = account_pb.HaimaPlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.ret == 0 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_HM:OnRespondLoginHMSDK-------------")
	else

	end
	
	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end