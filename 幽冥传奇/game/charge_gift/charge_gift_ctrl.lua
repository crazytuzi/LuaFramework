require("scripts/game/charge_gift/charge_gift_data")
require("scripts/game/charge_gift/charge_gift_view")

--------------------------------------------------------
-- 充值大礼包
--------------------------------------------------------

ChargeGiftCtrl = ChargeGiftCtrl or BaseClass(BaseController)

function ChargeGiftCtrl:__init()
	if	ChargeGiftCtrl.Instance then
		ErrorLog("[ChargeGiftCtrl]:Attempt to create singleton twice!")
	end
	ChargeGiftCtrl.Instance = self

	self.view = ChargeGiftView.New(ViewDef.ChargeGift)
	self.data = ChargeGiftData.New()

	self:RegisterAllProtocols()
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum), RemindName.DailyGiftBag)
	RemindManager.Instance:DoRemindDelayTime(RemindName.DailyGiftBag)
end

function ChargeGiftCtrl:__delete()
	ChargeGiftCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end


end

function ChargeGiftCtrl:GetRemindNum()
	return ChargeGiftData.GetDailyGiftBagRemind()
end

--登记所有协议
function ChargeGiftCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCDailyGiftBagInfoChange, "OnDailyGiftBagInfoChange")
	self:RegisterProtocol(SCDailyGiftBagInfo, "OnDailyGiftBagInfo")
end

-- 绝版限购上线请求
function ChargeGiftCtrl:RecvMainInfoCallBack()
	local cfg = JueBanQiangGouConfig or {}
	local open_days = cfg.opendays or 1
	local open_lv = cfg.openlimitLevel or 50

	local open_server_day = OtherData.Instance:GetOpenServerDays() + 1
	local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)

	if open_server_day >= open_days and role_lv >= open_lv then
		-- ChargeGiftCtrl.SendOutOfPrintReq(1)
	else
		-- 等级未达到时,监听人物等级
		self.lv_event_handle = RoleData.Instance:AddEventListener(OBJ_ATTR.CREATURE_LEVEL, BindTool.Bind(self.OnRoleLeveChange, self))
	end
end

function ChargeGiftCtrl:OnRoleLeveChange(data)
	-- local cfg = JueBanQiangGouConfig or {}
	-- local open_lv = cfg.openlimitLevel or 50
	-- if data.value >= open_lv then
	-- 	ChargeGiftCtrl.SendOutOfPrintReq(1)
	-- 	RoleData.Instance:RemoveEventListener(self.lv_event_handle) -- 取消监听
	-- 	self.lv_event_handle = nil
	-- end
end

----------接收----------

function ChargeGiftCtrl:OnDailyGiftBagInfoChange(protocol)
    self.data:SetDailyGiftBagDataChange(protocol)
end

function ChargeGiftCtrl:OnDailyGiftBagInfo(protocol)
    self.data:SetDailyGiftBagData(protocol)
end

----------发送----------

-- 请求领取每日礼包(26, 88)
function ChargeGiftCtrl.RequestChargeGiftReq(index)
    local protocol = ProtocolPool.Instance:GetProtocol(CSGetDailyGiftDagReq)
    protocol.index = index
    protocol:EncodeAndSend()
end

--------------------
