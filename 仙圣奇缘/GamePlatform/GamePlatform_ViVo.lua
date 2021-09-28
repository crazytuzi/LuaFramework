-- 文件名:	GamePlatform_ViVo.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_ViVo = class("GamePlatform_ViVo", function () return PlatformBase:new() end)
GamePlatform_ViVo.__index = GamePlatform_ViVo

function GamePlatform_ViVo:ctor()
	self.billon = 0
	self.recharge = 0
end

function GamePlatform_ViVo:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_VIVO_LOGIN_RESPONSE , handler(self, self.OnRespondVivoPlatformLogin))
	--vivo 
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_VIVO_ORDER_RESPONSE , handler(self, self.VivoSdkOrderRspRechage))

    --平台id，登录游戏服务器成功后，带回来
    -- self.__ViVoID = 0
end

--服务器平台类型
function GamePlatform_ViVo:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_VIVO
end

function GamePlatform_ViVo:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_ViVo:LoginPlatformSuccessCallBack(Account,  uid)
	self:RequestLoginViVoSDK(Account, uid)
end

function GamePlatform_ViVo:GameLogin()
	if g_OnExitGame then
        CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
    else
        CGamePlatform:SharedInstance():ShowSDKCenter()
    end
	return true
end

function GamePlatform_ViVo:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_ViVo:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_ViVo:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_ViVo:CenterDidShowCallBack()

end

function GamePlatform_ViVo:CenterDidCloseCallBack()

end

function GamePlatform_ViVo:submitExtendData(roleId, roleName, roleLevel, zoneName, zoneId)
	CGamePlatform:SharedInstance():submitExtendData(roleId, roleName, roleLevel, zoneName, zoneId)
end

function GamePlatform_ViVo:setRecharge(irecharge)
	self.recharge = irecharge
end

------------------------------------协议--------------------------------
function GamePlatform_ViVo:RequestLoginViVoSDK(token, uid)
	-- cclog("--------------GamePlatform_ViVo:VivoPlatformLoginRequest---------- "..token)
	local Msg = account_pb.VivoPlatformLoginRequest()
	Msg.token = token
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_VIVO_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()
	--print("GamePlatform_ViVo:RequestLoginViVoSDK sendMsg token="..token.." uid="..uid)
end

function GamePlatform_ViVo:OnRespondVivoPlatformLogin(tbMsg)
	cclog("--------------GamePlatform_ViVo:VivoPlatformLoginResponse()----------------------")
	local msgDetail = account_pb.VivoPlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.is_success  then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
        -- self.__360ID = msgDetail.sdk_id
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_ViVo:VivoPlatformLoginResponse()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end

function GamePlatform_ViVo:OnRespondGameServerRechage(tbMsg)
	cclog("GamePlatform_ViVo:OnRespondGameServerRechage")
	--发送平台兑换订单号
	local msgDetail = zone_pb.RechargeBillnoResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	
	self.billon = msgDetail.billno
	self.recharge = msgDetail.recharge_id
	-- local tbRechage = g_DataMgr:getShopRechargeCsv(self.recharge)
	-- if tbRechage ~= nil then
	-- 	cclog("VIVO发送了==================")
	-- 	self:RequestVivoSdkOrderReq(self.billon,tbRechage.RMBPrice)
	-- end
end


function GamePlatform_ViVo:RequestVivoSdkOrderReq(billNo,money)
	local vivoReq = zone_pb.VivoSdkOrderReq()
	vivoReq.bill_no  = billNo 	--美天的订单号
	vivoReq.money = money*100	--人民币金额，单位分

	cclog("--GamePlatform_ViVo:RequestVivoSdkOrderReq--"..vivoReq.bill_no .." "..vivoReq.money )
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_VIVO_ORDER_REQUEST, vivoReq)
	
end

function GamePlatform_ViVo:VivoSdkOrderRspRechage(tbMsg)
	g_MsgNetWorkWarning:closeNetWorkWarning()
	local msgDetail = zone_pb.VivoSdkOrderRsp()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	local vivoOrder = msgDetail.vivo_order --交易流水号	vivo订单号
	local accessKey = msgDetail.access_key --vivoSDK需要的参数	vivoSDK使用
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
            	CGamePlatform:SharedInstance():ExchangeGoos(tbRechage.RMBPrice, tbRechage.Name, vivoOrder, accessKey)
            else
            	CGamePlatform:SharedInstance():ExchangeGoos(tbRechage.RMBPrice, tbRechage.Name, vivoOrder)
            end
			
		end
	-- end
end


-- function GamePlatform_ViVo:GetPlatformUserID()
    -- return self.__ViVoID
-- end