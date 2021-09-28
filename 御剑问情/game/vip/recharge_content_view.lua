RechargeContentView = RechargeContentView or BaseClass(BaseRender)
local DoubleRechargeOpenDay = 7

function RechargeContentView:__init(instance)
	RechargeContentView.Instance = self
	self.contain_cell_list = {}
	self:InitListView()
end

function RechargeContentView:__delete()
	for k,v in pairs(self.contain_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.contain_cell_list = {}
	self.is_double_recharge = nil
	self.double_recharge_time = nil
	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end
end

function RechargeContentView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.is_double_recharge = self:FindVariable("IsDoubleRecharge")
	self.double_recharge_time = self:FindVariable("DoubleRechargeTime")
	self.cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	self:IsDoubleRecharge()
end

function RechargeContentView:GetNumberOfCells()
	local recharge_id_list = RechargeData.Instance:GetRechargeIdList()
	if #recharge_id_list %3 ~= 0 then
		return math.floor(#recharge_id_list/3) + 1
	else
		return #recharge_id_list/3
	end
end

function RechargeContentView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = RechargeContain.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	local id_list = RechargeData.Instance:GetRechargeListByIndex(cell_index)
	contain_cell:SetItemId(id_list)
end

function RechargeContentView:OnFlush()
	self:IsDoubleRecharge()

	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end

	local rest_double_act_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI)

	if self.next_timer == nil and (self.cur_day <= DoubleRechargeOpenDay or rest_double_act_open) then
		self.next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushTime, self), 1)
	end
end

function RechargeContentView:SetRechargeActive(is_active)
	self.root_node:SetActive(is_active)
end

function RechargeContentView:FlushTime()
	local rest_double_act_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI)
	local now_time = TimeCtrl.Instance:GetServerTime()

	local left_time = TimeUtil.NowDayTimeEnd(now_time) - now_time
	local left_day = DoubleRechargeOpenDay - self.cur_day

	local time = math.max(left_day * 86400 + left_time, 0)

	if rest_double_act_open then
		time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI)
	end

	if time > 86400 then
		self.double_recharge_time:SetValue(TimeUtil.FormatSecond(time, 7))
	elseif time > 0 then
		self.double_recharge_time:SetValue(TimeUtil.FormatSecond(time, 1))
	else
		if math.max(left_day * 86400 + left_time, 0) <= 0 then
			GlobalTimerQuest:CancelQuest(self.next_timer)
			self.is_double_recharge:SetValue(false)
			self.double_recharge_time:SetValue("")
		end
	end
end

function RechargeContentView:IsDoubleRecharge()
	local seven_day_is_all = DailyChargeData.Instance:AllOptionRecharge()
	local rest_is_all = ResetDoubleChongzhiData.Instance:IsAllRecharge()
	local open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI)
	self.is_double_recharge:SetValue((self.cur_day <= 7 and not seven_day_is_all) or (open and not rest_is_all))
end
---------------------------------------------------------------
RechargeContain = RechargeContain  or BaseClass(BaseCell)

function RechargeContain:__init()
	self.recharge_contain_list = {}
	for i = 1, 3 do
		self.recharge_contain_list[i] = {}
		self.recharge_contain_list[i].recharge_item = RechargeItem.New(self:FindObj("item_" .. i))
	end
end

function RechargeContain:__delete()
	for i=1,3 do
		self.recharge_contain_list[i].recharge_item:DeleteMe()
		self.recharge_contain_list[i].recharge_item = nil
	end
end

function RechargeContain:SetItemId(item_id_list)
	for i=1,3 do
		self.recharge_contain_list[i].recharge_item:SetItemId(item_id_list[i])
	end
end

function RechargeContain:OnFlushAllCell()
	for i=1,3 do
		self.recharge_contain_list[i].shop_item:OnFlush()
	end
end

----------------------------------------------------------------------------
RechargeItem = RechargeItem or BaseClass(BaseCell)

function RechargeItem:__init()
	self.money_text = self:FindVariable("money")
	self.money_icon = self:FindVariable("money_icon")
	self.gold_text = self:FindVariable("gold_text")
	self.extra_gold = self:FindVariable("extra_gold")
	self.gold_icon = self:FindVariable("gold_icon")
	self.show_return = self:FindVariable("show_return")
	self.is_spec = self:FindVariable("is_spec")
	self.is_server_open_7_day = self:FindVariable("is_server_open_7_day")
	self.spec_txt = self:FindVariable("SpecTxt")
	self.show_red = self:FindVariable("ShowRed")
	self.spec_txt2 = self:FindVariable("SpecTxt2")
	self.has_spec_recharge = self:FindVariable("HasSpecRecharge")

	self:ListenEvent("rechange_click", BindTool.Bind(self.OnRechargeClick, self))
	self.item_id = 0
end

function RechargeItem:__delete()
end

function RechargeItem:SetItemId(item_id)
	self.item_id = item_id
	if self.item_id == RechargeData.SPEC_ID and not IS_AUDIT_VERSION then
		self.has_get_award = self:FindVariable("has_get_award")
		self:ListenEvent("special_rechange_click", BindTool.Bind(self.OnClickRecharge, self))
	end
	self:OnFlush()
end

function RechargeItem:OnFlush()
	self.root_node:SetActive(true)
	if self.item_id == RechargeData.InVaildId then
		self.root_node:SetActive(false)
		return
	end

	local rest_double_act_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI)
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	self.is_server_open_7_day:SetValue(cur_day <= 7 or rest_double_act_open)

	local recharge_cfg = RechargeData.Instance:GetRechargeInfo(self.item_id)
	local reward_cfg = RechargeData.Instance:GetChongzhiRewardCfgById(recharge_cfg.id)
	local other_cfg = ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").other[1]
	local bundle, gold_asset = ResPath.GetDiamonIcon(2)
	local bundle1, bind_gold_asset = ResPath.GetDiamonIcon(3)

	local is_first_chongzhi = DailyChargeData.Instance:CheckIsFirstRechargeById(recharge_cfg.id)
	local is_rest_first_chongzhi = ResetDoubleChongzhiData.Instance:CheckIsFirstRechargeById(recharge_cfg.id)

	if IS_AUDIT_VERSION then
		self.show_return:SetValue(false)
	else
		self.show_return:SetValue(( not rest_double_act_open and is_first_chongzhi) or (rest_double_act_open and not is_rest_first_chongzhi))
	end

	self:SetIcon(recharge_cfg)
	self.money_text:SetValue(recharge_cfg.money)
	self.gold_text:SetValue(recharge_cfg.gold)
	self.is_spec:SetValue((recharge_cfg.id == RechargeData.SPEC_ID) and not IS_AUDIT_VERSION)
	self.show_red:SetValue(false)
	self.has_spec_recharge:SetValue(false)

	if recharge_cfg.id == RechargeData.SPEC_ID and not IS_AUDIT_VERSION then
		local is_special_member = RechargeData.Instance:HasBuy7DayChongZhi()
		local is_fetch = RechargeData.Instance:GetChongZhi7DayRewardIsFetch()	-- 0未领取  1已领取
		self.has_spec_recharge:SetValue(is_special_member)
		self.show_red:SetValue(is_special_member and is_fetch == 0)
		self.has_get_award:SetValue(is_special_member and is_fetch == 1)
	end

	local extra_gold_value = 0
	if reward_cfg and reward_cfg.reward_type == 1 then
		extra_gold_value = reward_cfg.openserver_extra_gold or 0
	else
		extra_gold_value = other_cfg.chongzhi_seven_day_reward_bind_gold or 0
	end

	if not is_rest_first_chongzhi and rest_double_act_open and is_first_chongzhi and cur_day <= 7 then
		extra_gold_value = tonumber(extra_gold_value) * 2
	end

	self.extra_gold:SetValue(extra_gold_value)

	self.gold_icon:SetAsset(bundle1, bind_gold_asset)
end

function RechargeItem:SetIcon(cfg)
	local res = ""
	res = cfg.gold_icon
	if IS_AUDIT_VERSION and res == "Diamond0" then
		res = "Diamond3"
	end
	local bundle, asset = ResPath.GetVipIcon(res)
	local bundle0, asset0 = ResPath.GetVipIcon("Diamond0")
	local recharge_cfg = RechargeData.Instance:GetRechargeInfo(self.item_id)
	if recharge_cfg.id == RechargeData.SPEC_ID and not IS_AUDIT_VERSION then
		self.money_icon:SetAsset(bundle0, asset0)
	else
		self.money_icon:SetAsset(bundle, asset)
	end
end

function RechargeItem:OnRechargeClick()
	local recharge_cfg = RechargeData.Instance:GetRechargeInfo(self.item_id)
	local reward_cfg = RechargeData.Instance:GetChongzhiRewardCfgById(recharge_cfg.id)
	local vip_chongzhi_num = DailyChargeData.Instance:CheckIsFirstRechargeById(self.item_id)
	local reward_18yuan_cfg = RechargeData.Instance:GetChongzhi18YuanRewardCfg()
	if (nil == reward_cfg and recharge_cfg.id ~= RechargeData.SPEC_ID) or not recharge_cfg then return end
	local discretion = ""
	if recharge_cfg.id == RechargeData.SPEC_ID and not IS_AUDIT_VERSION then
		discretion = string.format(Language.Recharge.RechargeDes, reward_18yuan_cfg.chongzhi_seven_day_reward_bind_gold)
		str_recharge = string.format(Language.Recharge.FirstBing, 98)
	else
		discretion = reward_cfg.discretion
		str_recharge = string.format(Language.Recharge.FirstGold, recharge_cfg.money, recharge_cfg.gold)
	end
	-- local str_recharge = string.format(Language.Recharge.FirstGold, recharge_cfg.money, recharge_cfg.gold)
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if vip_chongzhi_num == true and cur_day <= 7 then
		chongzhi_show_str = str_recharge .. "\n" .. string.format(discretion) .. "\n" .. Language.Recharge.WarmPrompt
	else
		chongzhi_show_str = str_recharge .. "\n" .. Language.Recharge.WarmPrompt
	end
	local function ok_func()
		self:SendRecharge(recharge_cfg)
	end
	-- TipsCtrl.Instance:ShowCommonAutoView("", chongzhi_show_str, ok_func)
	ok_func()
end


function RechargeItem:SendRecharge(recharge_cfg)
	RechargeCtrl.Instance:Recharge(recharge_cfg.money)
end

--领取至尊会员奖励
function RechargeItem:OnClickRecharge()
	RechargeCtrl.Instance:SendChongZhi7DayFetchReward()
end
