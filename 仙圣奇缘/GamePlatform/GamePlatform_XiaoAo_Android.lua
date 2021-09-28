-- 文件名:	GamePlatform_XiaoAo_Android.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	张齐
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现
-- 渠  道:  小奥游戏安卓平台   

GamePlatform_XiaoAoAndroid = class("GamePlatform_XiaoAoAndroid", function () return PlatformBase:new() end)
GamePlatform_XiaoAoAndroid.__index = GamePlatform_XiaoAoAndroid

function GamePlatform_XiaoAoAndroid:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_XIAOAO_ANDROID_LOGIN_RESPONSE , handler(self, self.OnRespondLoginSDK))
end

--服务器平台类型
function GamePlatform_XiaoAoAndroid:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_ANDROID_XIAOAO
end

function GamePlatform_XiaoAoAndroid:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_XiaoAoAndroid:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginSDK(Account, password)
end

function GamePlatform_XiaoAoAndroid:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_XiaoAoAndroid:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_XiaoAoAndroid:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_XiaoAoAndroid:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_XiaoAoAndroid:CenterDidShowCallBack()

end

function GamePlatform_XiaoAoAndroid:CenterDidCloseCallBack()

end
	
------------------------------------协议--------------------------------
function GamePlatform_XiaoAoAndroid:RequestLoginSDK(sid, token)
    --37玩token带%，不能开启日志，否则报错
	cclog("--------------GamePlatform_XiaoAoAndroid:MIPlatformLoginRequest---------- "..token)
	local Msg = account_pb.PlatformXiaoaoAndroidLoginReq()
    Msg.sid = sid
    cclog("登陆sid:"..Msg.sid)
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_XIAOAO_ANDROID_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_XiaoAoAndroid:OnRespondLoginSDK(tbMsg)
	cclog("--------------GamePlatform_XiaoAoAndroid:OnRespondLoginSDK()----------------------")
	local msgDetail = account_pb.PlatformXiaoaoAndroidLoginResp()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

    if msgDetail.ret == 1 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_XiaoAoAndroid:OnRespondLoginSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end

function GamePlatform_XiaoAoAndroid:OnPlatformPaySuccess(strPayData)
    self:SendPlatformPaySuccess(strPayData)
end

function GamePlatform_XiaoAoAndroid:SendPlatformPaySuccess(strPayData)
    cclog("--------------GamePlatform_XiaoAoAndroid:SendPlatformPaySuccess()----------------------")
    g_MsgMgr:sendMsg(msgid_pb.MSGID_GET_RECHARGE_DATA_REQUEST, nil)
	g_ShowSysTips({text = "充值成功，元宝到账可能有延迟，请耐心等待！"})
end
