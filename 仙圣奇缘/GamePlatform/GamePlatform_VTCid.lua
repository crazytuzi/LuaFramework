-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_VTCid = class("GamePlatform_VTCid", function () return PlatformBase:new() end)

GamePlatform_VTCid.__index = GamePlatform_VTCid

function GamePlatform_VTCid:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_ANDROID_VT_LOGIN_RESPONSE , handler(self, self.VtAndroidPlatformLoginResponse))
end

--服务器平台类型 
function GamePlatform_VTCid:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_VT
end

function GamePlatform_VTCid:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_VTCid:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestVtAndroidPlatformLoginRequest(Account)
end

function GamePlatform_VTCid:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_VTCid:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_VTCid:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_VTCid:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_VTCid:CenterDidShowCallBack()

end

function GamePlatform_VTCid:CenterDidCloseCallBack()

end

function GamePlatform_VTCid:submitExtendData(roleId, roleName, roleLevel, zoneName, zoneId)
	CGamePlatform:SharedInstance():submitExtendData(roleId, roleName, roleLevel, zoneName, zoneId)
end
-- // 越南android 登录请求
-- message VtAndroidPlatformLoginRequest
-- {
	-- optional string sid = 1;				// 越南ios账号的唯一ID
-- }

-- // 越南android 登录返回
-- message VtAndroidPlatformLoginResponse
-- {
	-- optional uint32 ret = 1;				// 1表示成功，其他表示失败
	-- optional uint32 uin = 2;				// 返回我们内部服务器的账号uin
-- }
------------------------------------协议--------------------------------
function GamePlatform_VTCid:RequestVtAndroidPlatformLoginRequest(token)
	-- cclog("--------------RequestHuaweiPlatformLoginSDK---------- "..token.." uid="..uid)
    if token == ""  then return end
	local msg = account_pb.VtAndroidPlatformLoginRequest()
	msg.sid = token
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_ANDROID_VT_LOGIN_REQUEST, msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_VTCid:VtAndroidPlatformLoginResponse(tbMsg)
	cclog("-------------VtAndroidPlatformLoginResponse----------------------")
	local msgDetail = account_pb.VtAndroidPlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	
	if msgDetail.ret == 1  then 
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
	end
	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()
end

function GamePlatform_VTCid:FBInvite()
    CGamePlatform:SharedInstance():Invitefriends("Nhận Thể Lực|Mời bạn để nhận thể lực miễn phí mỗi ngày ")
end

function GamePlatform_VTCid:FBShare()
    CGamePlatform:SharedInstance():ShareGame("")
end
