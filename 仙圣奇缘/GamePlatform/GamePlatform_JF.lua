-- 文件名:	GamePlatform_JF.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_JF = class("GamePlatform_JF", function () return PlatformBase:new() end)

GamePlatform_JF.__index = GamePlatform_JF

function GamePlatform_JF:PlatformInit()
	 g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_HURRICANE_LOGIN_RESPONSE , handler(self, self.OnRespondLoginJFSDK))
end

--服务器平台类型
function GamePlatform_JF:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_HURRICANE
end

function GamePlatform_JF:GetPlatformType()
	return CGamePlatform:GetPlatformType_JF()
end
    
function GamePlatform_JF:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginJFSDK(Account, password)
end

function GamePlatform_JF:LoginOutCallBack()
    PlatformBase:GameLoginOut()
end
    
function GamePlatform_JF:CenterDidShowCallBack()

end

function GamePlatform_JF:CenterDidCloseCallBack()

end

function GamePlatform_JF:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_JF:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_JF:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end


------------------------------------协议--------------------------------
function GamePlatform_JF:RequestLoginJFSDK(token, password)
	cclog("--------------GamePlatform_JF:RequestLoginJFSDK---------- "..token)
	local Msg = account_pb.HurricanePlatformLoginRequest()
	Msg.session = token
	Msg.user_id = password
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_HURRICANE_LOGIN_REQUEST, Msg)
end

function GamePlatform_JF:OnRespondLoginJFSDK(tbMsg)
	cclog("--------------GamePlatform_JF:OnRespondLoginJFSDK()----------------------")
	local msgDetail = account_pb.HurricanePlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	--xy文档
	if msgDetail.ret == 0 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
	end

	AccountRegResponse(false)

end