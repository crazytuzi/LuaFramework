-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	张齐
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现
-- 渠  道:  49游

GamePlatform_49You = class("GamePlatform_49You", function () return PlatformBase:new() end)

GamePlatform_49You.__index = GamePlatform_49You

function GamePlatform_49You:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_ANDROID_49YOU_LOGIN_RESPONSE , handler(self, self.OnRespondLoginSDK))
end

--服务器平台类型
function GamePlatform_49You:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_49YOU
end

function GamePlatform_49You:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_49You:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginSDK(Account, password)
end

function GamePlatform_49You:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_49You:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_49You:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_49You:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_49You:CenterDidShowCallBack()

end

function GamePlatform_49You:CenterDidCloseCallBack()

end
	
------------------------------------协议--------------------------------
function GamePlatform_49You:RequestLoginSDK(sid, token)
	cclog("--------------GamePlatform_49You:MIPlatformLoginRequest---------- "..token  .."+sid:"..sid)
    local login_table = string.split(token, "|")
	local Msg = account_pb.Platform49youLoginRequest()
    Msg.sid = sid
	Msg.token = login_table[1]
    Msg.time = login_table[2]
    cclog("登陆token:"..Msg.token.."登陆time:"..Msg.time)
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_ANDROID_49YOU_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_49You:OnRespondLoginSDK(tbMsg)
	cclog("--------------GamePlatform_49You:OnRespondLoginSDK()----------------------")
	local msgDetail = account_pb.Platform49youLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

    if msgDetail.ret == 0 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_49You:OnRespondLoginSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end
