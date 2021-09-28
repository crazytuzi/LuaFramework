-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_JINLI = class("GamePlatform_JINLI", function () return PlatformBase:new() end)

GamePlatform_JINLI.__index = GamePlatform_JINLI

function GamePlatform_JINLI:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_AMIGO_LOGIN_RESPONSE , handler(self, self.OnRespondLoginSDK))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_AMIGO_ORDER_RESPONSE , handler(self, self.sdkOrderRspRechage))
end

function GamePlatform_JINLI:getUin()
	return self.playerID
end

--服务器平台类型
function GamePlatform_JINLI:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_AMIGO
end

function GamePlatform_JINLI:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_JINLI:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginSDK(Account, password)
end

function GamePlatform_JINLI:GameLogin()
	if g_OnExitGame then
		CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
	else
		CGamePlatform:SharedInstance():ShowSDKCenter()
	end
	return true
end

function GamePlatform_JINLI:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_JINLI:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_JINLI:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_JINLI:CenterDidShowCallBack()

end

function GamePlatform_JINLI:CenterDidCloseCallBack()

end
	
------------------------------------协议--------------------------------
function GamePlatform_JINLI:RequestLoginSDK(token, password)
	self.playerID = password

	cclog("--------------GamePlatform_JINLI:MIPlatformLoginRequest---------- "..token)
	local Msg = account_pb.AmigoPlatformLoginRequest()
	Msg.amigo_token = token
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_AMIGO_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
end

function GamePlatform_JINLI:OnRespondLoginSDK(tbMsg)
	cclog("--------------GamePlatform_JINLI:OnRespondLoginMISDK()----------------------")
	local msgDetail = account_pb.AmigoPlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.is_success == true then

		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_JINLI:OnRespondLoginMISDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end

-- function GamePlatform_JINLI:OnRespondGameServerRechage(tbMsg)
-- 	cclog("GamePlatform_ViVo:OnRespondGameServerRechage")
-- 	--发送平台兑换订单号
-- 	local msgDetail = zone_pb.RechargeBillnoResponse()
-- 	msgDetail:ParseFromString(tbMsg.buffer)
	
-- 	self.billon = msgDetail.billno
-- 	self.recharge = msgDetail.recharge_id
-- 	local tbRechage = g_DataMgr:getShopRechargeCsv(self.recharge)
-- 	if tbRechage ~= nil then
-- 		cclog("VIVO发送了==================")
-- 		self:RequestVivoSdkOrderReq(self.billon,tbRechage.RMBPrice)
-- 	end
-- end

-- function GamePlatform_JINLI:RequestVivoSdkOrderReq(billNo,money)
-- 	local msg = zone_pb.AmigoSdkOrderReq()
-- 	msg.bill_no  = billNo 	--美天的订单号
-- 	msg.money = tostring(0.01) --人民币金额，单位元
-- 	msg.player_id = self.playerID

-- 	cclog("--GamePlatform_JINLI:RequestVivoSdkOrderReq--"..msg.bill_no .." "..msg.money )
-- 	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_AMIGO_ORDER_REQUEST, msg)
	
-- end

function GamePlatform_JINLI:sdkOrderRspRechage(tbMsg)
	local msg = zone_pb.AmigoSdkOrderRsp()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))

	-- if self.billon ~= nil then
		local tbRechage = g_DataMgr:getShopRechargeCsv(self.recharge)
		if tbRechage ~= nil then
			--强制测试 1元
			-- CGamePlatform:SharedInstance():ExchangeGoos(tbRechage.RMBPrice, tbRechage.Name, billon)
            --有的平台充值需要平台用户ID
            -- local PlatformUserID = ""
            -- if self.m_PlatformInterface.GetPlatformUserID ~= nil then
                -- PlatformUserID = self.m_PlatformInterface:GetPlatformUserID()
            -- end
            if g_OnExitGame then
            	CGamePlatform:SharedInstance():ExchangeGoos(tbRechage.RMBPrice, tbRechage.Name, msg.out_order_no, msg.submit_time)
            else
            	CGamePlatform:SharedInstance():ExchangeGoos(tbRechage.RMBPrice, tbRechage.Name, msg.out_order_no, msg.submit_time)
            end		
		end
	-- end
end
