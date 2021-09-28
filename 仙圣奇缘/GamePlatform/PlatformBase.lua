-- 文件名:	PlatformBase.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

PlatformBase = class("PlatformBase")

PlatformBase.__index = PlatformBase

function PlatformBase:PlatformInit()
end

function PlatformBase:getUin()
	return ""
end

--服务器平台类型
function PlatformBase:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_NONE
end

function PlatformBase:GetPlatformType()
	return 0
end
    
function PlatformBase:GamePlatformStart()
	g_MsgMgr:connectToDir()
end

function PlatformBase:GameConnectPlatform()

end

function PlatformBase:GameLogin()
cclog("--------------------PlatformBase:GameLogin-------------------")
	return false
end

function PlatformBase:GameLoginOut()
	g_FormMsgSystem:PostFormMsg(FormMsg_ClientNet_LogOut, nil)
end

---------------------------各种回调---------------------------
--登入平台成功
function PlatformBase:LoginPlatformSuccessCallBack(Account,  password)

end

--注销成功回调
function PlatformBase:LoginOutCallBack()

end
    
--界面显示回调
function PlatformBase:CenterDidShowCallBack()

end

--界面关闭回调
function PlatformBase:CenterDidCloseCallBack()

end

function PlatformBase:AccountRegResponse()
	return false
end

function PlatformBase:setRecharge(irecharge)

end


function PlatformBase:OnRespondGameServerRechage(tbMsg)
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
            	CGamePlatform:SharedInstance():ExchangeGoos(tbRechage.RMBPrice, tbRechage.Name, billon, PlatformUserID)
            else
            	CGamePlatform:SharedInstance():ExchangeGoos(tbRechage.RMBPrice, tbRechage.Name, billon)
            end
		end
	end

end
