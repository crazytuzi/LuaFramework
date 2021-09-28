-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_Lenovo = class("GamePlatform_Lenovo", function () return PlatformBase:new() end)

GamePlatform_Lenovo.__index = GamePlatform_Lenovo

function GamePlatform_Lenovo:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_LENOVO_LOGIN_RESPONSE , handler(self, self.OnRespondLoginSDK))
end

--服务器平台类型
function GamePlatform_Lenovo:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_LENOVO
end

function GamePlatform_Lenovo:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_Lenovo:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginSDK(Account, password)
end

function GamePlatform_Lenovo:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_Lenovo:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_Lenovo:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_Lenovo:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_Lenovo:CenterDidShowCallBack()

end

function GamePlatform_Lenovo:CenterDidCloseCallBack()

end

function GamePlatform_Lenovo:OnPlatformPaySuccess(strPayData)
    self:SendPlatformPaySuccess(strPayData)
end

function GamePlatform_Lenovo:SendPlatformPaySuccess(strPayData)
    cclog("--------------GamePlatform_Lenovo:SendPlatformPaySuccess()----------------------")
    g_MsgMgr:sendMsg(msgid_pb.MSGID_GET_RECHARGE_DATA_REQUEST, nil)
	g_ShowSysTips({text = "充值成功，元宝到账可能有延迟，请耐心等待！"})
end
	
------------------------------------协议--------------------------------
function GamePlatform_Lenovo:RequestLoginSDK(token, password)
	cclog("--------------GamePlatform_Lenovo:LenovoPlatformLoginRequest---------- "..token)
	local Msg = account_pb.LenovoPlatformLoginRequest()

	Msg.token = token
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_LENOVO_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_Lenovo:OnRespondLoginSDK(tbMsg)
	cclog("--------------GamePlatform_Lenovo:OnRespondLoginLenovoSDK()----------------------")
	local msgDetail = account_pb.LenovoPlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.is_success == true then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_Lenovo:OnRespondLoginLenovoSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end
