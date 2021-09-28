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

GamePlatform_CHWIOS = class("GamePlatform_CHWIOS", function () return PlatformBase:new() end)

GamePlatform_CHWIOS.__index = GamePlatform_CHWIOS

function GamePlatform_CHWIOS:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_IOS_TAIWAN_LOGIN_RESPONSE , handler(self, self.OnRespondLoginCHWIOSSDK))
end

--服务器平台类型
function GamePlatform_CHWIOS:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_TAIWAN_IOS
end

function GamePlatform_CHWIOS:GetPlatformType()
	return CGamePlatform:GetPlatformType_CHW()
end
    
function GamePlatform_CHWIOS:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginCHWIOSSDK(Account, password)
end

function GamePlatform_CHWIOS:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_CHWIOS:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_CHWIOS:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_CHWIOS:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_CHWIOS:CenterDidShowCallBack()

end

function GamePlatform_CHWIOS:CenterDidCloseCallBack()

end

function GamePlatform_CHWIOS:OnRespondGameServerRechage(tbMsg)
	cclog("GamePlatform_CHWIOS:OnRespondGameServerBill")
	local msgDetail = zone_pb.RechargeBillnoResponse()
	msgDetail:ParseFromString(tbMsg.buffer)

	--发送平台兑换订单号
	local billon = msgDetail.billno
	local recharge = msgDetail.recharge_id
	if billon ~= nil then
		local tbRechage = g_DataMgr:getShopRechargeCsv(recharge)
		if tbRechage ~= nil then
            CGamePlatform:SharedInstance():ExchangeGoos(tbRechage.RMBPrice, tbRechage.ProductID, billon, g_ServerList:GetLocalServerID())
		end
	end

end

------------------------------------协议--------------------------------
function GamePlatform_CHWIOS:RequestLoginCHWIOSSDK(token, password)
	cclog("--------------GamePlatform_CHWIOS:RequestLoginCHWIOSSDK---------- "..token)
    local Msg = account_pb.PlatformTaiWanIOSLoginReq()
	Msg.token = token
	Msg.uin = password
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_IOS_TAIWAN_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_CHWIOS:OnRespondLoginCHWIOSSDK(tbMsg)
	cclog("--------------GamePlatform_CHWIOS:OnRespondLoginCHWIOSSDK()----------------------")
    local msgDetail = account_pb.PlatformTaiWanIOSLoginResp()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.ret == 0 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_CHWIOS:OnRespondLoginCHWIOSSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end

function GamePlatform_CHWIOS:FBInvite()
    CGamePlatform:SharedInstance():Invitefriends("")
end

function GamePlatform_CHWIOS:FBShare()
    CGamePlatform:SharedInstance():ShareGame("")
end