-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_KY = class("GamePlatform_KY", function () return PlatformBase:new() end)

GamePlatform_KY.__index = GamePlatform_KY

function GamePlatform_KY:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_KUAIYONG_LOGIN_RESPONSE , handler(self, self.OnRespondLoginKYSDK))
end

--服务器平台类型
function GamePlatform_KY:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_KUAIYONG
end

function GamePlatform_KY:GetPlatformType()
	return CGamePlatform:GetPlatformType_KY()
end
    
function GamePlatform_KY:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginKYSDK(Account)
end

function GamePlatform_KY:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_KY:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_KY:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_KY:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_KY:CenterDidShowCallBack()

end

function GamePlatform_KY:CenterDidCloseCallBack()

end


------------------------------------协议--------------------------------
function GamePlatform_KY:RequestLoginKYSDK(token)
	cclog("--------------GamePlatform_KY:RequestLoginKYSDK--------- "..token)
	local msg = account_pb.KuaiyongPlatformLoginRequest()
	msg.token = token
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_KUAIYONG_LOGIN_REQUEST, msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_KY:OnRespondLoginKYSDK(tbMsg)
	cclog("--------------GamePlatform_KY:OnRespondLoginKYSDK---------------------")
	local msgDetail = account_pb.KuaiyongPlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	--pp文档
	if msgDetail.ret == 0 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_KY:OnRespondLoginKYSDK-------------")
	else

	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end