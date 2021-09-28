-- 文件名:	GamePlatform_TB.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_TB = class("GamePlatform_TB", function () return PlatformBase:new() end)

GamePlatform_TB.__index = GamePlatform_TB

function GamePlatform_TB:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_TONGBU_LOGIN_RESPONSE , handler(self, self.OnRespondLoginTBSDK))
end

--服务器平台类型
function GamePlatform_TB:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_TONGBU
end

function GamePlatform_TB:GetPlatformType()
	return CGamePlatform:GetPlatformType_TB()
end
    
function GamePlatform_TB:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginTBSDK(Account, password)
end

function GamePlatform_TB:LoginOutCallBack()
    PlatformBase:GameLoginOut()
end
    
function GamePlatform_TB:CenterDidShowCallBack()

end

function GamePlatform_TB:CenterDidCloseCallBack()

end

function GamePlatform_TB:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_TB:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_TB:GameLogin()
	 if g_OnExitGame then
        CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
    else
        CGamePlatform:SharedInstance():ShowSDKCenter()
    end
	return true
end


------------------------------------协议--------------------------------
function GamePlatform_TB:RequestLoginTBSDK(token, password)
	-- cclog("--------------GamePlatform_TB:RequestLoginTBSDK---------- "..token)
	local Msg = account_pb.TongbuPlatformLoginRequest()
	Msg.session = token
	-- Msg.uid = password
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_TONGBU_LOGIN_REQUEST, Msg)

	print("RequestLoginTBSDK token="..token)
	print("RequestLoginTBSDK uid="..password)
end

function GamePlatform_TB:OnRespondLoginTBSDK(tbMsg)
	cclog("--------------GamePlatform_TB:OnRespondLoginTBSDK()----------------------")
	local msgDetail = account_pb.TongbuPlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.ret == 0 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
	end

	AccountRegResponse(false)

end