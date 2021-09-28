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

GamePlatform_XIAOAO = class("GamePlatform_XIAOAO", function () return PlatformBase:new() end)

GamePlatform_XIAOAO.__index = GamePlatform_XIAOAO

function GamePlatform_XIAOAO:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_XIAOAO_LOGIN_RESPONSE , handler(self, self.OnRespondLoginXIAOAOSDK))
end

--服务器平台类型
function GamePlatform_XIAOAO:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_XIAOAO
end

function GamePlatform_XIAOAO:GetPlatformType()
	return CGamePlatform:GetPlatformType_XIAOAO()
end
    
function GamePlatform_XIAOAO:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginXIAOAOSDK(Account, password)
end

function GamePlatform_XIAOAO:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_XIAOAO:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_XIAOAO:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_XIAOAO:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_XIAOAO:CenterDidShowCallBack()

end

function GamePlatform_XIAOAO:CenterDidCloseCallBack()

end
function GamePlatform_XIAOAO:PlatformPayByClient(recharge_id)
    cclog("GamePlatform_XIAOAO:PlatformPayByClient")



		local tbRechage = g_DataMgr:getShopRechargeCsv(recharge_id)
		if tbRechage ~= nil then
            g_MsgNetWorkWarning:showWarningText()
            CGamePlatform:SharedInstance():ExchangeGoos(tbRechage.RMBPrice, tbRechage.ProductID, "", g_ServerList:GetLocalServerID())
		end

end

function GamePlatform_XIAOAO:OnRespondGameServerRechage(tbMsg)
	cclog("GamePlatform_XIAOAO:OnRespondGameServerBill")
	local msgDetail = zone_pb.RechargeBillnoResponse()
	msgDetail:ParseFromString(tbMsg.buffer)

	--发送平台兑换订单号
	local billon = msgDetail.billno
	local recharge = msgDetail.recharge_id
	if billon ~= nil then
		local tbRechage = g_DataMgr:getShopRechargeCsv(recharge)
		if tbRechage ~= nil then
            g_MsgNetWorkWarning:showWarningText()
            CGamePlatform:SharedInstance():ExchangeGoos(tbRechage.RMBPrice, tbRechage.ProductID, billon, g_ServerList:GetLocalServerID())
		end

		--CGameDataAppsFlyer广告统计
		--if CGameDataAppsFlyer and CGameDataAppsFlyer.onPay then
		--	CGameDataAppsFlyer:onPay(msgDetail.order_id, tbRechage.TalkingDataID, tbRechage.ID, tbRechage.Name, tbRechage.RMBPrice*100)
		--	cclog("CGameDataAppsFlyer:onPay:")
		--end
    end
end

------------------------------------协议--------------------------------
function GamePlatform_XIAOAO:RequestLoginXIAOAOSDK(token, password)
	cclog("--------------GamePlatform_XIAOAO:RequestLoginXIAOAOSDK---------- "..token)
    local Msg = account_pb.PlatformXiaoaoLoginReq()
	Msg.sid = password
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_XIAOAO_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_XIAOAO:OnRespondLoginXIAOAOSDK(tbMsg)
	cclog("--------------GamePlatform_XIAOAO:OnRespondLoginXIAOAOSDK()----------------------")
    local msgDetail = account_pb.PlatformXiaoaoLoginResp()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.ret == 1 then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_XIAOAO:OnRespondLoginXIAOAOSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()
end

function GamePlatform_XIAOAO:FBInvite()
    CGamePlatform:SharedInstance():Invitefriends("")
end

function GamePlatform_XIAOAO:FBShare()
    CGamePlatform:SharedInstance():ShareGame("")
end