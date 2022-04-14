--
-- @Author: LaoY
-- @Date:   2021-11-15 20:10:45
--

g_NtfMgr = NFTSDKManager.Instance

NFTManager = NFTManager or {}


NFTManager.Events = {
	Update = "NFTManager.Events.Update",
}

local app_id  = 4
local chain_type  = 30
local silent_login = 0

function NFTManager.Init()
	g_NtfMgr:InitMoblieSdk(app_id,chain_type,silent_login)
	NFTManager.SetLuaNotifier()
end

function NFTManager.SetLuaNotifier()
	local function call_back(funcName,code,data)
		logError(string.format("Ntf callback funcName = %s , then code = %s,data = %s",funcName,code or "nil",data or "nil"))
		if funcName == "SignAndLogin" then
			if code == 0 then
				logError("=============登录成功")
				logError("LuaNotifier = ",data)
				-- dump(data)		

				LoginModel:GetInstance():SetNftToken(data)		
			end
		end

		GlobalEvent:Brocast(NFTManager.Events.Update,funcName,code,data)
	end
	g_NtfMgr:SetLuaNotifier(call_back)
end

function NFTManager.Connect()
	g_NtfMgr:Connect()
end


function NFTManager.SignAndLogin()
	g_NtfMgr:SignAndLogin()
end


--- <summary>
--- 购买
--- </summary>
--- <param name="bnbValue">BNB金额 支付币为 BNB 时填写，JOJO 时无需填写</param>
--- <param name="jojoValue">JOJO数量</param>
--- <param name="orderType">下单类型</param>
--- <param name="orderNo">订单号</param>
--- <param name="signature">签名串</param>
--- <param name="timestamp">时间戳</param>
--- <param name="order_title">订单标题</param>
--- <param name="">卖方地址 orderType为1时填写</param>
--- <param name="saleId">销售编号 orderType为1时填写</param>
--- <param name="deadline">订单锁定时间</param>
function NFTManager.Pay(bnbValue,jojoValue,orderType,orderNo,signature,timestamp,order_title,seller,saleId,deadline)
	if orderType == 1 then
		
	else
		seller = ""
		saleId = ""
	end
	g_NtfMgr:Pay(bnbValue,jojoValue,orderType,orderNo,signature,timestamp,order_title,seller,saleId,deadline)
end