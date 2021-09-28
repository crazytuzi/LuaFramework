-- 文件名:	GamePlatform_TWGoogle.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	张齐
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现
-- 渠  道:  台湾googleplay sdk 

GamePlatform_TWGoogle = class("GamePlatform_TWGoogle", function () return PlatformBase:new() end)
GamePlatform_TWGoogle.__index = GamePlatform_TWGoogle

function GamePlatform_TWGoogle:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_ANDROID_TAIWAN_LOGIN_RESPONSE , handler(self, self.OnRespondLoginSDK))
end

--服务器平台类型
function GamePlatform_TWGoogle:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_TAIWAN_ANDROID
end

function GamePlatform_TWGoogle:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_TWGoogle:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginSDK(Account, password)
end

function GamePlatform_TWGoogle:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_TWGoogle:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_TWGoogle:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_TWGoogle:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_TWGoogle:CenterDidShowCallBack()

end

function GamePlatform_TWGoogle:CenterDidCloseCallBack()

end
	
------------------------------------协议--------------------------------
function GamePlatform_TWGoogle:RequestLoginSDK(sid, token)
	cclog("--------------GamePlatform_TWGoogle:MIPlatformLoginRequest---------- ")
	local Msg = account_pb.PlatformTaiWanAndroidLoginReq()
    Msg.token = token
    Msg.uin = sid
    cclog("登陆token:"..token.."登陆sid"..sid)
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_ANDROID_TAIWAN_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_TWGoogle:OnRespondLoginSDK(tbMsg)
	cclog("--------------GamePlatform_TWGoogle:OnRespondLoginSDK()----------------------")
	local msgDetail = account_pb.PlatformTaiWanAndroidLoginResp()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

    if msgDetail.ret == 0 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_TWGoogle:OnRespondLoginSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end

function GamePlatform_TWGoogle:OnRespondGameServerRechage(tbMsg)
	cclog("PlatformBase:OnRespondGameServerBill")
	local msgDetail = zone_pb.RechargeBillnoResponse()
	msgDetail:ParseFromString(tbMsg.buffer)

	--发送平台兑换订单号
	local billon = msgDetail.billno
	local recharge = msgDetail.recharge_id
	if billon ~= nil then
		local tbRechage = g_DataMgr:getShopRechargeCsv(recharge)
		if tbRechage ~= nil then
			--强制测试 1元
			-- CGamePlatform:SharedInstance():ExchangeGoos(tbRechage.RMBPrice, tbRechage.Name, billon)

            --有的平台充值需要平台用户ID
            local PlatformUserID = ""
            if self.GetPlatformUserID ~= nil then
                PlatformUserID = self:GetPlatformUserID()
            end
            if g_OnExitGame then
            	CGamePlatform:SharedInstance():ExchangeGoos(tbRechage.RMBPrice, tbRechage.ProductID, billon, PlatformUserID)
            else
            	CGamePlatform:SharedInstance():ExchangeGoos(tbRechage.RMBPrice, tbRechage.ProductID, billon)
            end
		
		end
	end

end
