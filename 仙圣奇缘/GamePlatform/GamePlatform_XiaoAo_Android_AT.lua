-- 文件名:	GamePlatform_XiaoAo_Android_AT.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	张齐
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现
-- 渠  道:  小奥游戏安卓推广平台   

GamePlatform_XiaoAo_Android_AT = class("GamePlatform_XiaoAo_Android_AT", function () return PlatformBase:new() end)
GamePlatform_XiaoAo_Android_AT.__index = GamePlatform_XiaoAo_Android_AT

function GamePlatform_XiaoAo_Android_AT:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_XIAOAO_PROMOTION_LOGIN_RESPONSE , handler(self, self.OnRespondLoginSDK))
end

--服务器平台类型
function GamePlatform_XiaoAo_Android_AT:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_XIAOAO_PROMOTION
end

function GamePlatform_XiaoAo_Android_AT:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_XiaoAo_Android_AT:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginSDK(Account, password)
end

function GamePlatform_XiaoAo_Android_AT:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_XiaoAo_Android_AT:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_XiaoAo_Android_AT:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_XiaoAo_Android_AT:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_XiaoAo_Android_AT:CenterDidShowCallBack()

end

function GamePlatform_XiaoAo_Android_AT:CenterDidCloseCallBack()

end
	
------------------------------------协议--------------------------------
function GamePlatform_XiaoAo_Android_AT:RequestLoginSDK(sid, token)
	cclog("--------------GamePlatform_XiaoAo_Android_AT:MIPlatformLoginRequest---------- "..token)
	local Msg = account_pb.PlatformXiaoaoProReq()
    Msg.token = ""
    Msg.uin = sid
    cclog("登陆sid:"..Msg.uin)
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_XIAOAO_PROMOTION_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_XiaoAo_Android_AT:OnRespondLoginSDK(tbMsg)
	cclog("--------------GamePlatform_XiaoAo_Android_AT:OnRespondLoginSDK()----------------------")
	local msgDetail = account_pb.PlatformXiaoaoProResp()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

    if msgDetail.ret == 1 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_XiaoAo_Android_AT:OnRespondLoginSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end

function GamePlatform_XiaoAo_Android_AT:OnPlatformPaySuccess(strPayData)
    self:SendPlatformPaySuccess(strPayData)
end

function GamePlatform_XiaoAo_Android_AT:SendPlatformPaySuccess(strPayData)
    cclog("--------------GamePlatform_XiaoAo_Android_AT:SendPlatformPaySuccess()----------------------")
    g_MsgMgr:sendMsg(msgid_pb.MSGID_GET_RECHARGE_DATA_REQUEST, nil)
	g_ShowSysTips({text = "充值成功，元宝到账可能有延迟，请耐心等待！"})
end
