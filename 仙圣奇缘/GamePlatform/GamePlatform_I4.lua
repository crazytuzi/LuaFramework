-- 文件名:	GamePlatform_I4.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_I4 = class("GamePlatform_I4", function () return PlatformBase:new() end)

GamePlatform_I4.__index = GamePlatform_I4

function GamePlatform_I4:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_I4_LOGIN_RESPONSE , handler(self, self.OnRespondLoginI4SDK))
end

--服务器平台类型
function GamePlatform_I4:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_I4
end

function GamePlatform_I4:GetPlatformType()
	return CGamePlatform:GetPlatformType_I4()
end
    
function GamePlatform_I4:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginI4SDK(Account)
end

function GamePlatform_I4:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end

function GamePlatform_I4:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end
    
function GamePlatform_I4:CenterDidShowCallBack()

end

function GamePlatform_I4:CenterDidCloseCallBack()

end

function GamePlatform_I4:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_I4:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end


------------------------------------协议--------------------------------
function GamePlatform_I4:RequestLoginI4SDK(token)
	cclog("--------------GamePlatform_I4:RequestLoginI4SDK---------- "..token)
	local Msg = account_pb.I4PlatformLoginRequest()
	Msg.token = token
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_I4_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_I4:OnRespondLoginI4SDK(tbMsg)
	cclog("--------------GamePlatform_I4:OnRespondLoginI4SDK()----------------------")
	local msgDetail = account_pb.I4PlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	--I4文档
	if msgDetail.errorCode == 0 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_PP:OnRespondLoginPPSDK()-------------")
	else

	end

	AccountRegResponse(true)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end