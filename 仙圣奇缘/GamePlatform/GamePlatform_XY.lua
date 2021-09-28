-- 文件名:	GamePlatform_XY.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_XY = class("GamePlatform_XY", function () return PlatformBase:new() end)

GamePlatform_XY.__index = GamePlatform_XY

function GamePlatform_XY:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_XY_LOGIN_RESPONSE , handler(self, self.OnRespondLoginXYSDK))
end

--服务器平台类型
function GamePlatform_XY:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_XY
end

function GamePlatform_XY:GetPlatformType()
	return CGamePlatform:GetPlatformType_XY()
end
    
function GamePlatform_XY:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginXYSDK(Account, password)
end

function GamePlatform_XY:LoginOutCallBack()
    PlatformBase:GameLoginOut()
end
    
function GamePlatform_XY:CenterDidShowCallBack()

end

function GamePlatform_XY:CenterDidCloseCallBack()

end

function GamePlatform_XY:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_XY:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_XY:GameLogin()
	if g_OnExitGame then
        CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
    else
        CGamePlatform:SharedInstance():ShowSDKCenter()
    end
	return true
end


------------------------------------协议--------------------------------
function GamePlatform_XY:RequestLoginXYSDK(token, password)
	cclog("--------------GamePlatform_XY:RequestLoginXYSDK---------- "..token)
	local Msg = account_pb.XYPlatformLoginRequest()
	Msg.token = token
	Msg.uid = password
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_XY_LOGIN_REQUEST, Msg)
end

function GamePlatform_XY:OnRespondLoginXYSDK(tbMsg)
	cclog("--------------GamePlatform_XY:OnRespondLoginXYSDK()----------------------")
	local msgDetail = account_pb.XYPlatformLoginResponse()
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