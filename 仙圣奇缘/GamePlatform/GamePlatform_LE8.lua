-- 文件名:	GamePlatform_LE8.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_LE8 = class("GamePlatform_LE8", function () return PlatformBase:new() end)

GamePlatform_LE8.__index = GamePlatform_LE8

function GamePlatform_LE8:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_ANDROID_LE8_LOGIN_RESPONSE , handler(self, self.OnRespondLoginLE8SDK))
end

--服务器平台类型
function GamePlatform_LE8:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_LE8
end

function GamePlatform_LE8:GetPlatformType()
	return CGamePlatform:GetPlatformType_LE8()
end
    
function GamePlatform_LE8:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginLE8SDK(Account, password)
end

function GamePlatform_LE8:LoginOutCallBack()
    PlatformBase:GameLoginOut()
end
    
function GamePlatform_LE8:CenterDidShowCallBack()

end

function GamePlatform_LE8:CenterDidCloseCallBack()

end

function GamePlatform_LE8:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_LE8:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_LE8:GameLogin()
	if g_OnExitGame then
        CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
    else
        CGamePlatform:SharedInstance():ShowSDKCenter()
    end
	return true
end

-------------------------------协议---------------------------------
function GamePlatform_LE8:RequestLoginLE8SDK(token, password)
	cclog("--------------GamePlatform_LE8:RequestLoginLE8SDK---------- "..token)
	local Msg = account_pb.Le8PlatformLoginRequest()
	Msg.token = token
	Msg.sid = password
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_ANDROID_LE8_LOGIN_REQUEST, Msg)
end

function GamePlatform_LE8:OnRespondLoginLE8SDK(tbMsg)
	cclog("--------------GamePlatform_LE8:OnRespondLoginLE8SDK()----------------------")
	local msgDetail = account_pb.Le8PlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))


	if msgDetail.ret == 0 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		---请求服务器列表
		g_ServerList:RequestServerListInfo()
	end

	AccountRegResponse(false)

end