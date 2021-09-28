LucklyTurntable = LucklyTurntable or BaseClass(BaseRender)
function LucklyTurntable:__init()
	self.info_list = HefuActivityData.Instance:GetLucklyTurnTableInfo()
	self.rest_time = self:FindVariable("rest_time")
	self.check_toggle = self:FindObj("check")
	self.needle = self:FindObj("Neddle")
	self.reward_cell_list = {}
	self.reward_list = self:FindObj("RewardList")
	self.hight_light_list = {}
	self.hight_light_list_obj = self:FindObj("HightLightList")
	self.money = self:FindVariable("money")
	for i = 0, 7 do
		local rewardCell = self.reward_list.transform:GetChild(i).gameObject
		rewardCell = LucklyTurntableRewardCell.New(rewardCell)
		rewardCell:SetIndex(i+1)
		rewardCell:SetData(self.info_list[i].reward_item)
		table.insert(self.reward_cell_list, rewardCell)
		local hight_light = self.hight_light_list_obj.transform:GetChild(i).gameObject
		hight_light:SetActive(false)
		table.insert(self.hight_light_list, hight_light)
	end

	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))
	self:ListenEvent("ClickAddMoney", BindTool.Bind(self.ClickAddMoney, self))
	self.chongzhi_count = self:FindVariable("chongzhi_count")
	self.left_times = self:FindVariable("left_times")

	self.needle_is_role = false
	self.has_click = false
end

function LucklyTurntable:__delete()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end

    if self.tween then
		self.tween:Kill()
		self.tween = nil
	end

	for k,v in pairs(self.reward_cell_list) do
		v:DeleteMe()
	end
	self.reward_cell_list = {}
end

function LucklyTurntable:OpenCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_ROLL)
	local set_rest_time = self:SetTime(rest_time)
	self.rest_time:SetValue(set_rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
            self:SetTime(rest_time)
        end)
	for k,v in pairs(self.reward_cell_list) do
		v:SetIndex(k)
		v:SetData(self.info_list[k - 1].reward_item)
	end

	for k,v in pairs(self.hight_light_list) do
		v:SetActive(false)
	end

	self.needle_is_role = false

	local chongzhi_count, total_chongzhi_count = HefuActivityData.Instance:GetRollChongZhiCount()
	self.chongzhi_count:SetValue(total_chongzhi_count)
	local left_times = math.floor(chongzhi_count / HefuActivityData.Instance:GetRollCost())
	self.left_times:SetValue(left_times)
	self.has_click = false

	local cost = HefuActivityData.Instance:GetCurrentCombineActivityConfig().other
	if cost then
		self.money:SetValue(cost[1].roll_cost)
	end
	self:SetTime(rest_time)
end

function LucklyTurntable:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end

    if self.tween then
		self.tween:Kill()
		self.tween = nil
	end
end

function LucklyTurntable:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local temp = {}
	for k,v in pairs(time_tab) do
		if k ~= "day" then
			if v < 10 then
				v = tostring('0'..v)
			end
		end
		temp[k] = v
	end
	local str = string.format(Language.HefuActivity.RestTime, temp.day, temp.hour, temp.min)
	self.rest_time:SetValue(str)
end

function LucklyTurntable:ShowAnimation(index, time)
	if self.check_toggle.toggle.isOn then
		-- 如果屏蔽了动画
		self.needle.transform.localRotation = Quaternion.Euler(0, 0, -(index-1) * 45 - 48.5)
		self:OnComplete(index)
		self.hight_light_list[index + 1]:SetActive(true)
		return
	end

	if self.needle_is_role == true then
		return
	end
	self.needle_is_role = true
	if self.tween then
		self.tween:Kill()
		self.tween = nil
	end
	if nil == time then
		time = 4
	end

	local angle = (index-1) * 45 + 48.5
	self.tween = self.needle.transform:DORotate(
		Vector3(0, 0, -360 * time - angle),
		time,
		DG.Tweening.RotateMode.FastBeyond360)
	self.tween:SetEase(DG.Tweening.Ease.OutQuart)
	self.tween:OnComplete(function ()
		TipsFloatingManager.Instance:StartFloating()
		self.needle_is_role = false
		self.hight_light_list[index + 1]:SetActive(true)
		self:OnComplete(index)
	end)
end

function LucklyTurntable:OnComplete(reward_index)
	local item_data = self.info_list[reward_index]
	local item_cfg = ItemData.Instance:GetItemConfig(item_data.reward_item.item_id)
	local str = string.format(Language.HefuActivity.AddItem, SPRITE_SKILL_LEVEL_COLOR[item_cfg.color], item_cfg.name, item_data.reward_item.num)
	TipsCtrl.Instance:ShowFloatingLabel(str)

	if item_data.is_broadcast == 1 then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.LUCKLY_TURNTABLE_GET_REWARD)
		HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_ROLL, CSA_ROLL_OPERA.CSA_ROLL_OPERA_BROADCAST, item_data.reward_item.item_id)
	end
end

function LucklyTurntable:ClickReChange()
	if self.needle_is_role == true then
		return
	end
	if self.has_click == true then
		return
	end
	local chongzhi_count = HefuActivityData.Instance:GetRollChongZhiCount()
	if chongzhi_count >= HefuActivityData.Instance:GetRollCost() then
		self.has_click = true
	else
		self.has_click = false
	end
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_ROLL, CSA_ROLL_OPERA.CSA_ROLL_OPERA_ROLL)
end

function LucklyTurntable:ClickAddMoney()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function LucklyTurntable:OnFlush(parm_t)
	for k,v in pairs(parm_t) do
		if k == "luckly" then
			self:FlushNeedle()
		end
	end
	local chongzhi_count, total_chongzhi_count = HefuActivityData.Instance:GetRollChongZhiCount()
	self.chongzhi_count:SetValue(total_chongzhi_count)
	local left_times = math.floor(chongzhi_count / HefuActivityData.Instance:GetRollCost())
	self.left_times:SetValue(left_times)
end

function LucklyTurntable:FlushNeedle()
	self.has_click = false
	for k,v in pairs(self.hight_light_list) do
		v:SetActive(false)
	end

	self:ShowAnimation(HefuActivityData.Instance:GetTurntableIndex())
end

----------------------------------------LucklyTurntableRewardCell---------------------------------------------------
LucklyTurntableRewardCell = LucklyTurntableRewardCell or BaseClass(BaseCell)

function LucklyTurntableRewardCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.root_node)

end

function LucklyTurntableRewardCell:__delete()
	self.item_cell:DeleteMe()
end

function LucklyTurntableRewardCell:OnFlush()
	self.data = self:GetData()
	if next(self.data) then
		self.item_cell:SetData({item_id = self.data.item_id})
		self.item_cell:SetDefualtBgState(false)
		self.item_cell:ShowQuality(false)
	end
end