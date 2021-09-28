-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	张齐
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现
-- 渠  道:  榴莲科技

GamePlatform_LiuLian = class("GamePlatform_LiuLian", function () return PlatformBase:new() end)
GamePlatform_LiuLian.__index = GamePlatform_LiuLian

function GamePlatform_LiuLian:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_ANDROID_LIULIAN_LOGIN_RESPONSE , handler(self, self.OnRespondLoginSDK))
end

--服务器平台类型
function GamePlatform_LiuLian:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_LIULIAN
end

function GamePlatform_LiuLian:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_LiuLian:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginSDK(Account, password)
end

function GamePlatform_LiuLian:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_LiuLian:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_LiuLian:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_LiuLian:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_LiuLian:CenterDidShowCallBack()

end

function GamePlatform_LiuLian:CenterDidCloseCallBack()

end
	
------------------------------------协议--------------------------------
function GamePlatform_LiuLian:RequestLoginSDK(sid, token)
	cclog("--------------GamePlatform_LiuLian:MIPlatformLoginRequest---------- "..token  .."+sid:"..sid)
	local Msg = account_pb.LiuLianPlatformLoginRequest()
    Msg.sid = sid
    cclog("登陆sid:"..Msg.sid)
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_ANDROID_LIULIAN_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_LiuLian:OnRespondLoginSDK(tbMsg)
	cclog("--------------GamePlatform_LiuLian:OnRespondLoginSDK()----------------------")
	local msgDetail = account_pb.LiuLianPlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

    if msgDetail.ret == 1 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_LiuLian:OnRespondLoginSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end
