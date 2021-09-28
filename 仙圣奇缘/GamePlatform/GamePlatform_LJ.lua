-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_LJ = class("GamePlatform_LJ", function () return PlatformBase:new() end)

GamePlatform_LJ.__index = GamePlatform_LJ

function GamePlatform_LJ:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_LINGJING_LOGIN_RESPONSE , handler(self, self.OnRespondLoginLJSDK))
end

--服务器平台类型
function GamePlatform_LJ:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_LINGJING
end

function GamePlatform_LJ:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_LJ:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginLJSDK(Account, password)
end

function GamePlatform_LJ:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_LJ:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_LJ:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_LJ:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_LJ:CenterDidShowCallBack()

end

function GamePlatform_LJ:CenterDidCloseCallBack()

end
	
------------------------------------协议--------------------------------
function GamePlatform_LJ:RequestLoginLJSDK(token, password)
	cclog("--------------GamePlatform_LJ:LJPlatformLoginRequest---------- "..token)
	local Msg = account_pb.PLLingJingLoginRequest()

	local endIndex = string.find(token, ",")
	Msg.token = string.sub(token, 1, endIndex - 1)
	Msg.channel = string.sub(token, endIndex + 1)

	local endIndex = string.find(password, ",")
	Msg.user_id = string.sub(password, 1, endIndex - 1)
	Msg.channelLabel = string.sub(password, endIndex + 1)

	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_LINGJING_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_LJ:OnRespondLoginLJSDK(tbMsg)
	cclog("--------------GamePlatform_LJ:OnRespondLoginLJSDK()----------------------")
	local msgDetail = account_pb.PLLingJingLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.is_success == true then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_LJ:OnRespondLoginLJSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end
