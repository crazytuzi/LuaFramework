-- 文件名:	GamePlatform_LeShi.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	张齐
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现
-- 渠  道:  乐视手游,还没有完成   

GamePlatform_LeShi = class("GamePlatform_LeShi", function () return PlatformBase:new() end)
GamePlatform_LeShi.__index = GamePlatform_LeShi

function GamePlatform_LeShi:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_LESHI_LOGIN_RESPONSE , handler(self, self.OnRespondLoginSDK))
end

--服务器平台类型
function GamePlatform_LeShi:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_LESHI
end

function GamePlatform_LeShi:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_LeShi:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginSDK(Account, password)
end

function GamePlatform_LeShi:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_LeShi:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_LeShi:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_LeShi:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_LeShi:CenterDidShowCallBack()

end

function GamePlatform_LeShi:CenterDidCloseCallBack()

end

function GamePlatform_LeShi:OnPlatformPaySuccess(strPayData)
    self:SendPlatformPaySuccess(strPayData)
end

function GamePlatform_LeShi:SendPlatformPaySuccess(strPayData)
    cclog("--------------GamePlatform_LeShi:SendPlatformPaySuccess()----------------------")
    g_MsgMgr:sendMsg(msgid_pb.MSGID_GET_RECHARGE_DATA_REQUEST, nil)
	g_ShowSysTips({text = "充值成功，元宝到账可能有延迟，请耐心等待！"})
end
	
------------------------------------协议--------------------------------
function GamePlatform_LeShi:RequestLoginSDK(sid, token)
	cclog("--------------GamePlatform_LeShi:MIPlatformLoginRequest---------- "..token)
	local Msg = account_pb.PlatformLeshiReq()
    Msg.token = token
    Msg.uin = sid
    cclog("登陆token:"..Msg.token)
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_LESHI_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_LeShi:OnRespondLoginSDK(tbMsg)
	cclog("--------------GamePlatform_LeShi:OnRespondLoginSDK()----------------------")
	local msgDetail = account_pb.PlatformLeshiResp()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

    if msgDetail.ret == 1 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_LeShi:OnRespondLoginSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end
