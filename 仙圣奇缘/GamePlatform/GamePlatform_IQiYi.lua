-- 文件名:	GamePlatform_IQiYi.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	张齐
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现
-- 渠  道:  爱奇艺   

GamePlatform_IQiYi = class("GamePlatform_IQiYi", function () return PlatformBase:new() end)
GamePlatform_IQiYi.__index = GamePlatform_IQiYi

function GamePlatform_IQiYi:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_XIAOAO_ANDROID_AIQIYI_LOGIN_RESPONSE , handler(self, self.OnRespondLoginSDK))
end

--服务器平台类型
function GamePlatform_IQiYi:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_AIQIYI
end

function GamePlatform_IQiYi:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_IQiYi:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginSDK(Account, password)
end

function GamePlatform_IQiYi:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_IQiYi:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_IQiYi:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_IQiYi:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_IQiYi:CenterDidShowCallBack()

end

function GamePlatform_IQiYi:CenterDidCloseCallBack()

end
	
------------------------------------协议--------------------------------
function GamePlatform_IQiYi:RequestLoginSDK(sid, token)
	cclog("--------------GamePlatform_IQiYi:MIPlatformLoginRequest---------- "..token)
	local Msg = account_pb.PlatformXiaoaoAiqiyiReq()
    Msg.token = token
    Msg.uin = sid
    cclog("登陆token:"..Msg.token)
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_XIAOAO_ANDROID_AIQIYI_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_IQiYi:OnRespondLoginSDK(tbMsg)
	cclog("--------------GamePlatform_IQiYi:OnRespondLoginSDK()----------------------")
	local msgDetail = account_pb.PlatformXiaoaoAiqiyiResp()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

    if msgDetail.ret == 1 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_IQiYi:OnRespondLoginSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end
