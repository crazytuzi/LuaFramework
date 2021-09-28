RegistModules("Pay/View/PayPanel")
RegistModules("Pay/View/PayCheckPanel")
RegistModules("Pay/PayConst")
RegistModules("Pay/PayModel")

PayCtrl = BaseClass(LuaController)

function PayCtrl:GetInstance()
	if PayCtrl.inst == nil then
		PayCtrl.inst = PayCtrl.New()
	end
	return PayCtrl.inst
end

function PayCtrl:__init()
	self.model = PayModel:GetInstance()
	self.model:Regist(self)
	self:Config()
	self:RegistProto()
end

function PayCtrl:Config()

end

--注册协议
function PayCtrl:RegistProto()
	self:RegistProtocal("S_GetFristPayIdList") 
	self:RegistProtocal("S_FinishPay") -- 完成发货的商品ID
	self:RegistProtocal("S_Pay")
end	

-----------------------------------------------------------------------------------------------------------------------------
--------------------------------------接收消息-------------------------------------------------------------------------------
function PayCtrl:S_GetFristPayIdList(buffer) -- 获取已首冲过的商品id列表
	local msg = self:ParseMsg(player_pb.S_GetFristPayIdList(), buffer)
	-- self.model.yichong = msg.payItemId
	self.model:SetYCList(msg.payItemId)
end

function PayCtrl:S_FinishPay(buffer) -- 完成发货ID
	local msg = self:ParseMsg(player_pb.S_FinishPay(), buffer)
	-- 将已充值id加入列表
	table.insert(self.model.yichong, tonumber(msg.payItemId))
	-- 更新列表
	GlobalDispatcher:DispatchEvent(EventName.GetFirstPayList)
	UIMgr.Win_FloatTip("充值成功")

	-- if self.model:HasMonthCardPay() then
	-- 	MonthCardController:GetInstance():C_GetMonthCardInfo()
	-- end

	GlobalDispatcher:DispatchEvent(EventName.FinishPay , msg.payItemId)
	FirstRechargeModel:GetInstance():SetFirstPayRewardState( FirstRechargeConst.RewardState.CanGet )
	RechargeController:GetInstance():C_GetPayActData()
end

-- 充值
	-- msg.payItemId -- 商品编号
	-- msg.payType -- 支付方式  1：支付宝 2：微信 3：苹果
	-- msg.payInfo -- 支付信息	
function PayCtrl:S_Pay( buffer )
	local msg = self:ParseMsg(player_pb.S_Pay(), buffer)
	local cfg = GetCfgData("charge")
	local pdId = msg.payItemId or 0
	local chargeVo = cfg[pdId]
	local loginModel = LoginModel:GetInstance()
	local roleVo = SceneModel:GetInstance().mainPlayer or {}
	local svrId = loginModel.loginServerNo or "0"
	local svrName = loginModel.loginServerNo or "0"
	local rId = roleVo.playerId or ""
	local rName = roleVo.name or ""

	local cpOrderId = msg.cpOrderId or ""
	local pdName = chargeVo.name
	local pdDesc = chargeVo.name
	local total = chargeVo.price * (GameConst.IAPPriceUnit or 1)
	local desc = msg.payInfo or ""
	local payType = msg.payType

	local gid = GameConst.GId
	local sid = GameConst.SId
	
	if isSDKPlat then
		local iapId = self:GetExistPlatIap(pdId, gid, sid)
		if iapId == nil then UIMgr.Win_FloatTip(StringFormat("充值失败，没有找到相关充值配置=>{0}_{1}_{2}"), pdId, gid, sid) return end
		sdkToIOS:OpenPay(svrId, rId, rName, cpOrderId, iapId, pdName, pdDesc, total, desc)
	else
		payMgr:Pay(pdId, desc, payType, cpOrderId)
	end
end
local cfgIap = nil
function PayCtrl:GetExistPlatIap( pdId, gid, sid )
	if cfgIap == nil then
		cfgIap = GetCfgData("platIap")
	end
	if not cfgIap then return nil end
	local check = cfgIap[pdId.."_"..gid.."_"..sid]
	if check then return check.pdid end
	return nil
end

-----------------------------------------------------------------------------------------------------------------------------
------------------------------------发送消息---------------------------------------------------------------------------------
function PayCtrl:C_GetFristPayIdList() -- 获取已首冲过的商品id列表
	self:SendEmptyMsg(player_pb, "C_GetFristPayIdList")
end

function PayCtrl:C_Pay(payItemId, payType)
	-- payType: 1.支付宝 2.微信支付 
	local msg = player_pb.C_Pay()
	msg.payItemId = payItemId
	msg.payType = payType
	self:SendMsg("C_Pay", msg)
end

function PayCtrl:__delete( )
	PayCtrl.inst = nil
	if self.model then
		self.model:Destroy()
	end
	self.model = nil
end