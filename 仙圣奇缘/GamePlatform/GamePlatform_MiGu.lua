-- 文件名:	GamePlatform_MiGu.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	张齐
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现
-- 渠  道:  咪咕  

GamePlatform_MiGu = class("GamePlatform_MiGu", function () return PlatformBase:new() end)
GamePlatform_MiGu.__index = GamePlatform_MiGu

function GamePlatform_MiGu:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_XIAOAO_ANDROID_MIGU_LOGIN_RESPONSE , handler(self, self.OnRespondLoginSDK))
end

--服务器平台类型
function GamePlatform_MiGu:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_MIGU_XIAOAO
end

function GamePlatform_MiGu:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_MiGu:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginSDK(Account, password)
end

function GamePlatform_MiGu:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_MiGu:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_MiGu:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_MiGu:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_MiGu:CenterDidShowCallBack()

end

function GamePlatform_MiGu:CenterDidCloseCallBack()

end
	
------------------------------------协议--------------------------------
function GamePlatform_MiGu:RequestLoginSDK(sid, token)
    --37玩token带%，不能开启日志，否则报错
	cclog("--------------GamePlatform_MiGu:MIPlatformLoginRequest---------- "..token)
	local Msg = account_pb.PlatformXiaoaoMiguReq()
    Msg.sid = sid
    cclog("登陆sid:"..Msg.sid)
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_XIAOAO_ANDROID_MIGU_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_MiGu:OnRespondLoginSDK(tbMsg)
	cclog("--------------GamePlatform_MiGu:OnRespondLoginSDK()----------------------")
	local msgDetail = account_pb.PlatformXiaoaoMiguResp()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

    if msgDetail.ret == 1 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_MiGu:OnRespondLoginSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end
