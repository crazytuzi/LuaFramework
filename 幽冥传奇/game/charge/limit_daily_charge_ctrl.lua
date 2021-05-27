require("scripts/game/charge/limit_daily_charge_data")
require("scripts/game/charge/limit_daily_charge_view")
-- 开服限时每日充值
LimitDailyChargeCtrl = LimitDailyChargeCtrl or BaseClass(BaseController)

function LimitDailyChargeCtrl:__init()
	if	LimitDailyChargeCtrl.Instance then
		ErrorLog("[LimitDailyChargeCtrl]:Attempt to create singleton twice!")
	end
	LimitDailyChargeCtrl.Instance = self

	self.data = LimitDailyChargeData.New()
    self.view = LimitDailyChargeView.New(ViewName.LimitDailyCharge) 
    self.role_attr_change_callback = BindTool.Bind(self.RoleDataChangeCallback, self)
	RoleData.Instance:NotifyAttrChange(self.role_attr_change_callback)

	self:RegisterAllProtocols()
end

function LimitDailyChargeCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	if RoleData.Instance then
		RoleData.Instance:UnNotifyAttrChange(self.role_attr_change_callback)
	end
	LimitDailyChargeCtrl.Instance = nil
end

function LimitDailyChargeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCOpSerLimitDailyChargeDataIss, "OnOpSerLimitDailyChargeDataIss")
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.SendInfoReq))
	GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.FlushMainUiIconPos, self))
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.ChargeEveryDay)
end

function LimitDailyChargeCtrl:OnOpSerLimitDailyChargeDataIss(protocol)
	self.data:SetChargeEveryDay(protocol)
	-- print("LimitDailyChargeCtrl:OnOpSerLimitDailyChargeDataIss day====", protocol.day)
	if ViewManager.Instance then
		self:FlushMainUiIconPos()
		if  self.data:GetDailyChargeIsAllGet() then
			self.view:Close()
			return
		end
	end
	RemindManager.Instance:DoRemind(RemindName.ChargeEveryDay)
	self.view:Flush()
end

function LimitDailyChargeCtrl:FlushMainUiIconPos()
	if ViewManager.Instance then
		ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
	end
end

--------------------------------------
-- 每日充值请求
--------------------------------------

-- 请求获取领取礼包数据
function LimitDailyChargeCtrl:SendInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpSerLimitDailyChargeDataReq)
	protocol:EncodeAndSend()
end

-- 请求领取每日充值大礼包 
function LimitDailyChargeCtrl:SendGetEveryDayGiftBagReq(cur_level)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpSerLimitDailyChargeFetchAwarReq)
	protocol.cur_level = cur_level
	protocol:EncodeAndSend()
end

function LimitDailyChargeCtrl:RoleDataChangeCallback(key, value, old_value)
	if key == OBJ_ATTR.ACTOR_GOLD then
		 self:SendInfoReq()
	end
end

function LimitDailyChargeCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.ChargeEveryDay then
		return self.data:GetCanLinQu() or 0
	end
end
