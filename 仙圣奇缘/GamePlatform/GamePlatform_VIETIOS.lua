--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_VIETIOS = class("GamePlatform_VIETIOS", function () return PlatformBase:new() end)

GamePlatform_VIETIOS.__index = GamePlatform_VIETIOS

function GamePlatform_VIETIOS:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_IOS_VT_LOGIN_RESPONSE , handler(self, self.OnRespondLoginVIETIOSSDK))
end

--服务器平台类型
function GamePlatform_VIETIOS:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_VT
end

function GamePlatform_VIETIOS:GetPlatformType()
	return CGamePlatform:GetPlatformType_VIET()
end
    
function GamePlatform_VIETIOS:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginVIETIOSSDK(Account, password)
end

function GamePlatform_VIETIOS:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_VIETIOS:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_VIETIOS:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_VIETIOS:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_VIETIOS:CenterDidShowCallBack()

end

function GamePlatform_VIETIOS:CenterDidCloseCallBack()

end

------------------------------------协议--------------------------------
function GamePlatform_VIETIOS:RequestLoginVIETIOSSDK(token, password)
	cclog("--------------GamePlatform_VIETIOS:RequestLoginVIETIOSSDK---------- "..token)
    if password == ""  then return end
	local Msg = account_pb.VtIosPlatformLoginRequest()
	Msg.sid = password
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_IOS_VT_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_VIETIOS:OnRespondLoginVIETIOSSDK(tbMsg)
	cclog("--------------GamePlatform_VIETIOS:OnRespondLoginVIETIOSSDK()----------------------")
	local msgDetail = account_pb.VtIosPlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.ret == 1 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_VIETIOS:OnRespondLoginVIETIOSSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end

function GamePlatform_VIETIOS:FBInvite()
    CGamePlatform:SharedInstance():Invitefriends("Nhận Thể Lực|Mời bạn để nhận thể lực miễn phí mỗi ngày ")
end

function GamePlatform_VIETIOS:FBShare()
    CGamePlatform:SharedInstance():ShareGame("")
end