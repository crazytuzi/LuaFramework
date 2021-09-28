-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_MI = class("GamePlatform_MI", function () return PlatformBase:new() end)

GamePlatform_MI.__index = GamePlatform_MI

function GamePlatform_MI:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_XIAOMI_LOGIN_RESPONSE , handler(self, self.OnRespondLoginMISDK))
end

--服务器平台类型
function GamePlatform_MI:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_XIAOMI
end

function GamePlatform_MI:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_MI:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginMISDK(Account, password)
end

function GamePlatform_MI:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_MI:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_MI:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_MI:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_MI:CenterDidShowCallBack()

end

function GamePlatform_MI:CenterDidCloseCallBack()

end
	
------------------------------------协议--------------------------------
function GamePlatform_MI:RequestLoginMISDK(token, password)
	cclog("--------------GamePlatform_MI:MIPlatformLoginRequest---------- "..token)
	local Msg = account_pb.PLXiaoMiLoginRequest()
	Msg.session = token
	Msg.uin = password
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_XIAOMI_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_MI:OnRespondLoginMISDK(tbMsg)
	cclog("--------------GamePlatform_MI:OnRespondLoginMISDK()----------------------")
	local msgDetail = account_pb.PLXiaoMiLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.is_success == true then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_MI:OnRespondLoginMISDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end
