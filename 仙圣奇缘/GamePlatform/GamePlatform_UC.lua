-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_UC = class("GamePlatform_UC", function () return PlatformBase:new() end)

GamePlatform_UC.__index = GamePlatform_UC

function GamePlatform_UC:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_UC_LOGIN_RESPONSE , handler(self, self.OnRespondLoginUCSDK))
end

--服务器平台类型
function GamePlatform_UC:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_UC
end

function GamePlatform_UC:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_UC:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginUCSDK(Account, password)
end

function GamePlatform_UC:GameLogin()
	if g_OnExitGame then
        CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
    else
        CGamePlatform:SharedInstance():ShowSDKCenter()
    end
	return true
end

function GamePlatform_UC:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_UC:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_UC:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_UC:CenterDidShowCallBack()

end

function GamePlatform_UC:CenterDidCloseCallBack()

end

------------------------------------协议--------------------------------
function GamePlatform_UC:RequestLoginUCSDK(token, password)
	cclog("--------------GamePlatform_UC:UCPlatformLoginRequest---------- "..token)
	local Msg = account_pb.UCPlatformLoginRequest()
	Msg.sid = token
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_UC_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_UC:OnRespondLoginUCSDK(tbMsg)
	cclog("--------------GamePlatform_UC:OnRespondLoginUCSDK()----------------------")
	local msgDetail = account_pb.UCPlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.ret == 1 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_UC:OnRespondLoginUCSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end

function GamePlatform_UC:submitExtendData(roleId, roleName, roleLevel, zoneName, zoneId)
	CGamePlatform:SharedInstance():submitExtendData(roleId, roleName, roleLevel, zoneName, zoneId)
end