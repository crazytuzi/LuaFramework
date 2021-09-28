-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_91 = class("GamePlatform_91", function () return PlatformBase:new() end)

GamePlatform_91.__index = GamePlatform_91

function GamePlatform_91:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_91_LOGIN_RESPONSE , handler(self, self.OnRespondLogin91SDK))
end

--服务器平台类型
function GamePlatform_91:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_91
end

function GamePlatform_91:GetPlatformType()
	return CGamePlatform:GetPlatformType_91()
end
    
function GamePlatform_91:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLogin91SDK(Account, password)
end

function GamePlatform_91:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_91:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_91:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_91:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_91:CenterDidShowCallBack()

end

function GamePlatform_91:CenterDidCloseCallBack()

end

------------------------------------协议--------------------------------
function GamePlatform_91:RequestLogin91SDK(token, password)
	cclog("--------------GamePlatform_91:RequestLogin91SDK---------- "..token)
	local Msg = account_pb.PL91LoginRequest()
	Msg.session_id = token
	Msg.uin91 = password
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_91_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_91:OnRespondLogin91SDK(tbMsg)
	cclog("--------------GamePlatform_91:OnRespondLogin91SDK()----------------------")
	local msgDetail = account_pb.PL91LoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.ret == 0 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_91:OnRespondLogin91SDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end