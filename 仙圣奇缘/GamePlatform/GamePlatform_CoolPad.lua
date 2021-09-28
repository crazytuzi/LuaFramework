-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_CoolPad = class("GamePlatform_CoolPad", function () return PlatformBase:new() end)

GamePlatform_CoolPad.__index = GamePlatform_CoolPad

function GamePlatform_CoolPad:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_COOLPAD_LOGIN_RESPONSE , handler(self, self.OnRespondLoginSDK))
end

--服务器平台类型
function GamePlatform_CoolPad:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_COOLPAD
end

function GamePlatform_CoolPad:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_CoolPad:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginSDK(Account, password)
end

function GamePlatform_CoolPad:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_CoolPad:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_CoolPad:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_CoolPad:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_CoolPad:CenterDidShowCallBack()

end

function GamePlatform_CoolPad:CenterDidCloseCallBack()

end
	
------------------------------------协议--------------------------------
function GamePlatform_CoolPad:RequestLoginSDK(token, password)
	cclog("--------------GamePlatform_CoolPad:MIPlatformLoginRequest---------- "..token)
	local Msg = account_pb.CoolPadPlatformLoginRequest()
	Msg.author_code = token
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_COOLPAD_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_CoolPad:OnRespondLoginSDK(tbMsg)
	cclog("--------------GamePlatform_CoolPad:OnRespondLoginMISDK()----------------------")
	local msgDetail = account_pb.CoolPadPlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.is_success == true then

		--额外信息，借用此接口
		CGamePlatform:SharedInstance():submitExtendData(msgDetail.openid, msgDetail.access_token, "", "", 0)

		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_CoolPad:OnRespondLoginMISDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end
