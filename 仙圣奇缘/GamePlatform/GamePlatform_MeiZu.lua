-- 文件名:	GamePlatform_MeiZu.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	张齐
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现
-- 渠  道:  魅族

GamePlatform_MeiZu = class("GamePlatform_MeiZu", function () return PlatformBase:new() end)
GamePlatform_MeiZu.__index = GamePlatform_MeiZu

function GamePlatform_MeiZu:PlatformInit()
    self.sdkUin = ""
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_MEIZU_LOGIN_RESPONSE , handler(self, self.OnRespondLoginSDK))
end

function GamePlatform_MeiZu:getUin()
	return self.sdkUin
end

--服务器平台类型
function GamePlatform_MeiZu:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_MEIZU
end

function GamePlatform_MeiZu:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_MeiZu:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginSDK(Account, password)
end

function GamePlatform_MeiZu:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_MeiZu:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_MeiZu:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_MeiZu:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_MeiZu:CenterDidShowCallBack()

end

function GamePlatform_MeiZu:CenterDidCloseCallBack()

end
	
------------------------------------协议--------------------------------
function GamePlatform_MeiZu:RequestLoginSDK(sid, token)
	cclog("--------------GamePlatform_MeiZu:MIPlatformLoginRequest---------- "..token)
	local Msg = account_pb.PlatformMeizuReq()
    Msg.token = token
    Msg.uin = sid
    self.sdkUin = sid
    cclog("登陆token:"..Msg.token)
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_MEIZU_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_MeiZu:OnRespondLoginSDK(tbMsg)
	cclog("--------------GamePlatform_MeiZu:OnRespondLoginSDK()----------------------")
	local msgDetail = account_pb.PlatformMeizuResp()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

    if msgDetail.ret == 1 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_MeiZu:OnRespondLoginSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end
