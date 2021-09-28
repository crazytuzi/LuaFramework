-- 文件名:	GamePlatform_37Wan.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	张齐
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现
-- 渠  道:  37玩   

GamePlatform_37Wan = class("GamePlatform_37Wan", function () return PlatformBase:new() end)
GamePlatform_37Wan.__index = GamePlatform_37Wan

function GamePlatform_37Wan:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_ANDROID_37WAN_LOGIN_RESPONSE , handler(self, self.OnRespondLoginSDK))
end

--服务器平台类型
function GamePlatform_37Wan:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_37WAN
end

function GamePlatform_37Wan:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_37Wan:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginSDK(Account, password)
end

function GamePlatform_37Wan:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_37Wan:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_37Wan:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_37Wan:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_37Wan:CenterDidShowCallBack()

end

function GamePlatform_37Wan:CenterDidCloseCallBack()

end
	
------------------------------------协议--------------------------------
function GamePlatform_37Wan:RequestLoginSDK(sid, token)
    --37玩token带%，不能开启日志，否则报错
	cclog("--------------GamePlatform_37Wan:MIPlatformLoginRequest---------- "..token)
	local Msg = account_pb.Platform37WanLoginRequest()
    Msg.token = token
    cclog("登陆token:"..Msg.token)
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_ANDROID_37WAN_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_37Wan:OnRespondLoginSDK(tbMsg)
	cclog("--------------GamePlatform_37Wan:OnRespondLoginSDK()----------------------")
	local msgDetail = account_pb.Platform37WanLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

    if msgDetail.ret == 1 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_37Wan:OnRespondLoginSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end
