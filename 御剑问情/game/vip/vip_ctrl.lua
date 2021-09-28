require("game/vip/vip_data")
require("game/vip/vip_power")
require("game/vip/vip_view")
require("game/vip/temp_vip_view")
require("game/exchange/exchange_ctrl")
VipCtrl = VipCtrl or BaseClass(BaseController)

function VipCtrl:__init()
	if VipCtrl.Instance ~= nil then
		print_error("[VipCtrl] Attemp to create a singleton twice !")
	end
	VipCtrl.Instance = self

	self.vip_data = VipData.New()
	self.vip_power = VipPower.New()
	self.vip_view = VipView.New(ViewName.VipView)
	self.temp_vip_view = TempVipView.New()
	self:RegisterAllProtocols()

	self.task_change = GlobalEventSystem:Bind(OtherEventType.TASK_CHANGE, BindTool.Bind(self.OnTaskChange, self))
	self.main_open = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.OnMainOpen, self))
end

function VipCtrl:__delete()
	if self.vip_data then
		self.vip_data:DeleteMe()
		self.vip_data = nil
	end

	if self.vip_power then
		self.vip_power:DeleteMe()
		self.vip_power = nil
	end

	if self.vip_view then
		self.vip_view:DeleteMe()
		self.vip_view = nil
	end

	if self.temp_vip_view then
		self.temp_vip_view:DeleteMe()
		self.temp_vip_view = nil
	end

	if self.task_change then
		GlobalEventSystem:UnBind(self.task_change)
		self.task_change = nil
	end

	if self.main_open then
		GlobalEventSystem:UnBind(self.main_open)
		self.main_open = nil
	end

	VipCtrl.Instance = nil
end

function VipCtrl:OnTaskChange(task_event_type, task_id)
	if task_event_type == "completed_add" and self.vip_data:CanShowTempVipView() then
		local funopen_list = OpenFunData.Instance:OpenFunCfg()
		for k, v in pairs(funopen_list) do
			if v.name == "temp_vip" and v.trigger_param == task_id then
				self:ShowTempVipView(false)
				break
			end
		end
	end
end

function VipCtrl:GetView()
	return self.vip_view
end

function VipCtrl:GetVipData()
	return self.vip_data
end

function VipCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCVipInfo, "OnVipInfo")
	self:RegisterProtocol(SCMonthCardInfo, "OnMonthCardInfo")
	self:RegisterProtocol(CSFetchVipLevelReward)

	self:RegisterProtocol(CSFetchVipWeekReward)
	self:RegisterProtocol(CSFetchTimeLimitVip)
	self:RegisterProtocol(CSMonthCardFetchDayReward)
end

--vip等级信息变化
function VipCtrl:OnVipInfo(protocol)
	--因为兑换时元宝变化没有协议接受，只能在此处刷新兑换界面
	ExchangeCtrl.Instance:FlushExchangeView()
	local scene_obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == scene_obj then
		return
	end
	scene_obj:SetAttr("vip_level", protocol.vip_level)
	if scene_obj ~= nil and scene_obj:IsMainRole() then
		if self.vip_data:GetIsInTempVip() then
			local server_time = TimeCtrl.Instance:GetServerTime()
			if protocol.time_temp_vip_time > 0 and server_time >= protocol.time_temp_vip_time then
				if protocol.vip_level <= 0 then
					self:ShowTempVipView(true)
				end
			end
		end
		self.vip_data:OnVipInfo(protocol)
		MainUICtrl.Instance.view:Flush("temp_vip")
		self:CheckTempVipView()
		if VipContentView.Instance ~= nil and not IsNil(VipContentView.Instance:GetListView().scroller) then
			VipContentView.Instance:FlushRewardState()
		end
		GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, true)
	end
end

--至尊会员
function VipCtrl:OnMonthCardInfo(protocol)
	self.vip_data:SetMonthCardInfo(protocol)
end

--请求领取至尊会员奖励
function VipCtrl:SendMonthCardFetchDayReward()
	local protocol = ProtocolPool.Instance:GetProtocol(CSMonthCardFetchDayReward)
	protocol:EncodeAndSend()
end

--发送领取vip等级奖励申请
function VipCtrl:SendFetchVipLevelRewardReq(seq)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFetchVipLevelReward)
	protocol.seq = seq - 1					--C++从0开始
	protocol:EncodeAndSend()
end

--发送领取vip周奖励申请
function VipCtrl:SendFetchVipWeekRewardReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSFetchVipWeekReward)
	protocol:EncodeAndSend()
end

--请求开启限时VIP
function VipCtrl:SendCSFetchTimeLimitVip()
	local protocol = ProtocolPool.Instance:GetProtocol(CSFetchTimeLimitVip)
	protocol:EncodeAndSend()
end

--展示Vip体验
function VipCtrl:ShowTempVipView(time_is_end)
	if self.temp_vip_view then
		self.temp_vip_view:SetIsTimeEnd(time_is_end)
		self.temp_vip_view:Open()
	end
end

function VipCtrl:OnMainOpen()
	self.main_open_complete = true
	self:CheckTempVipView()
end

function VipCtrl:CheckTempVipView()
	if not self.main_open_complete then
		return
	end
	local can_show_tempvip_view = self.vip_data:CanShowTempVipView()
	if can_show_tempvip_view then
		local funopen_list = OpenFunData.Instance:OpenFunCfg()
		for k, v in pairs(funopen_list) do
			if v.name == "temp_vip" then
				local task_zhu_cfg = TaskData.Instance:GetZhuTaskConfig()
				if task_zhu_cfg and task_zhu_cfg.task_id > v.trigger_param then
					self:ShowTempVipView(false)
				end
				break
			end
		end
	end
end

function VipCtrl:FlushView()
	self.vip_view:Flush()
end
