require("scripts/game/worship/worship_view")
require("scripts/game/worship/worship_data")
--膜拜城主
WorshipCtrl = WorshipCtrl or BaseClass(BaseController)

function WorshipCtrl:__init()
	if WorshipCtrl.Instance ~= nil then
		ErrorLog("[WorshipCtrl] attempt to create singleton twice!")
		return
	end
	WorshipCtrl.Instance = self
	
	self.view = WorshipView.New(ViewDef.Worship)
	self.data = WorshipData.New()
	self:CreateOneKeyUpdateConfirDlg()
	self:RegisterAllEvents()
end

function WorshipCtrl:__delete()
	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.OneKeyUpConfirDlg then
		self.OneKeyUpConfirDlg:DeleteMe()
		self.OneKeyUpConfirDlg = nil
	end
	WorshipCtrl.Instance = nil
end

function WorshipCtrl:RegisterAllEvents()
	self:RegisterProtocol(SCWorshipOrDespisePost, "OnWorshipOrDespisePost")
	self:RegisterProtocol(SCWorshipRefreAward, "OnWorshipRefreAward")
	self:RegisterProtocol(SCWorshipReceiveAward, "OnWorshipReceiveAward")
end

function WorshipCtrl:CreateOneKeyUpdateConfirDlg()
	if not self.OneKeyUpConfirDlg then
		self.OneKeyUpConfirDlg = Alert.New(Language.Worship.ConfirmOneTimeUp2Ten,
		function() WorshipCtrl.WorshipRefreRateReq(WORSHIP_MONEY_TYPE.INGOT) end,
		cancel_func, close_func, true, is_show_action, is_any_click_close
		)
	end
end
--  鄙视或膜拜(145 13)
function WorshipCtrl:OnWorshipOrDespisePost(protocol)
	ViewManager.Instance:Open(ViewName.Worship)
	self.view:Flush(0, "worship_despise",
	{	
	[WORSHIP_ENUM.DESPISE_PROGRESS] = protocol.despise_per,
	[WORSHIP_ENUM.WORSHIP_PROGRESS] = protocol.worship_per,
	[WORSHIP_ENUM.LEFT_TIMES] = protocol.cur_times,
	-- [WORSHIP_ENUM.THIS_TIME_EXP] = protocol.this_time_exp,
	-- [WORSHIP_ENUM.TOTAL_EXP] = protocol.total_exp,
	[WORSHIP_ENUM.DAY_GLOD_BENEFIT] = protocol.award_count,
	})
end

-- 膜拜刷新奖励(145 28)
function WorshipCtrl:OnWorshipRefreAward(protocol)
	self.view:Flush(0, "refre_award",
	{
		[WORSHIP_ENUM.MULTI_RATE] = protocol.award_index,
	})
end

-- 领取城主累计元宝返回结果(145 31)
function WorshipCtrl:OnWorshipReceiveAward(protocol)
	if not self.view.btn_receive_reward then return end
	if protocol.is_receive == 1 then
		self.view.btn_receive_reward:setEnabled(false)
	else
		self.view.btn_receive_reward:setEnabled(false)
	end
end


--------请求---------
-- 膜拜或者鄙视(返回 145 13)
function WorshipCtrl.WorshipOrDespiseReq(type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSWorshipOrDespiseReq)
	protocol.type = type
	protocol:EncodeAndSend()
end

-- 膜拜刷新倍率(返回 145 28)
function WorshipCtrl.WorshipRefreRateReq(money_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSWorshipRefreshRateReq)
	protocol.money_type = money_type
	protocol:EncodeAndSend()
end

-- 进行膜拜城主泡点活动(在城主雕像所在地图安全区内 返回 145 21)
function WorshipCtrl.WorshipChatelainReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSWorshipChatelainReq)
	protocol:EncodeAndSend()
end

-- 领取城主累计元宝
function WorshipCtrl.WorshipReceiveRewardsReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSWorshipReceiveRewardsReq)
	protocol:EncodeAndSend()
end
