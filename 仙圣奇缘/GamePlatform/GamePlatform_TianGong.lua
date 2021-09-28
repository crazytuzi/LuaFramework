-- 文件名:	GamePlatform_TianGong.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	张齐
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现
-- 渠  道:  东方二次元，sdk天工  

GamePlatform_TianGong = class("GamePlatform_TianGong", function () return PlatformBase:new() end)
GamePlatform_TianGong.__index = GamePlatform_TianGong

function GamePlatform_TianGong:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_ANDROID_TIANGONG_LOGIN_RESPONSE , handler(self, self.OnRespondLoginSDK))
end

--服务器平台类型
function GamePlatform_TianGong:GetServerPlatformType()
    cclog("平台类型:"..macro_pb.LOGIN_PLATFORM_TIANGONG)
	return macro_pb.LOGIN_PLATFORM_TIANGONG
end

function GamePlatform_TianGong:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_TianGong:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginSDK(Account, password)
end

function GamePlatform_TianGong:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_TianGong:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_TianGong:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_TianGong:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_TianGong:CenterDidShowCallBack()

end

function GamePlatform_TianGong:CenterDidCloseCallBack()

end
	
------------------------------------协议--------------------------------
function GamePlatform_TianGong:RequestLoginSDK(sid, token)
	cclog("--------------GamePlatform_TianGong:MIPlatformLoginRequest---------- "..token)
	local Msg = account_pb.PlatformTianGongLoginRequest()
    Msg.sid = sid
    cclog("登陆sid:"..Msg.sid)
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_ANDROID_TIANGONG_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_TianGong:OnRespondLoginSDK(tbMsg)
	cclog("--------------GamePlatform_TianGong:OnRespondLoginSDK()----------------------")
	local msgDetail = account_pb.PlatformTianGongLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

    if msgDetail.ret == 1 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_TianGong:OnRespondLoginSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end
