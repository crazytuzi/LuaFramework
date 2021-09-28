-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_360 = class("GamePlatform_360", function () return PlatformBase:new() end)

GamePlatform_360.__index = GamePlatform_360

function GamePlatform_360:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_360_LOGIN_RESPONSE , handler(self, self.OnRespondLogin360SDK))

    --360平添id，登录游戏服务器成功后，带回来
    self.__360ID = 0
end

--服务器平台类型
function GamePlatform_360:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_360
end

function GamePlatform_360:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_360:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLogin360SDK(Account, password)
end

function GamePlatform_360:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	
	return true
end

function GamePlatform_360:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_360:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_360:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_360:CenterDidShowCallBack()

end

function GamePlatform_360:CenterDidCloseCallBack()

end

------------------------------------协议--------------------------------
function GamePlatform_360:RequestLogin360SDK(token, password)
	cclog("--------------GamePlatform_360:360PlatformLoginRequest---------- "..token)
	local Msg = account_pb.Platform360LoginRequest()
	Msg.token = token
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_360_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_360:OnRespondLogin360SDK(tbMsg)
	cclog("--------------GamePlatform_360:OnRespondLogin360SDK()----------------------")
	local msgDetail = account_pb.Platform360LoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.ret == 0 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
        self.__360ID = msgDetail.sdk_id
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_360:OnRespondLogin360SDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end

function GamePlatform_360:GetPlatformUserID()
    return self.__360ID
end