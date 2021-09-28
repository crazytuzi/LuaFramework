-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_91_and = class("GamePlatform_91_and", function () return PlatformBase:new() end)

GamePlatform_91_and.__index = GamePlatform_91_and

function GamePlatform_91_and:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_BAIDU_LOGIN_RESPONSE , handler(self, self.OnRespondLogin91_andSDK))
end

--服务器平台类型
function GamePlatform_91_and:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_BAIDU
end

function GamePlatform_91_and:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_91_and:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLogin91_andSDK(Account, password)
end

function GamePlatform_91_and:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_91_and:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_91_and:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_91_and:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_91_and:CenterDidShowCallBack()

end

function GamePlatform_91_and:CenterDidCloseCallBack()

end

------------------------------------协议--------------------------------
function GamePlatform_91_and:RequestLogin91_andSDK(token, password)
	cclog("--------------GamePlatform_91_and:91_andPlatformLoginRequest---------- "..token)
	local Msg = account_pb.BaiduPlatformLoginRequest()
	Msg.access_token = token
	Msg.baidu_uid = password
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_BAIDU_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_91_and:OnRespondLogin91_andSDK(tbMsg)
	cclog("--------------GamePlatform_91_and:OnRespondLogin91_andSDK()----------------------")
	local msgDetail = account_pb.BaiduPlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.ret == 1 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_91_and:OnRespondLogin91_andSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end
