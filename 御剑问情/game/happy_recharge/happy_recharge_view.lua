HappyRechargeView = HappyRechargeView or BaseClass(BaseView)

function HappyRechargeView:__init()
	self.ui_config = {"uis/views/happyrecharge_prefab", "HappyRecharge"}
end

function HappyRechargeView:__delete()
	-- body
end

function HappyRechargeView:LoadCallBack()
	HappyRechargeCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_HAPPY_RECHARGE,
		RA_CHONGZHI_NIU_EGG_OPERA_TYPE.RA_CHONGZHI_NIU_EGG_OPERA_TYPE_QUERY_INFO)
	self.show_info_list = HappyRechargeData.Instance:GetItemListInfo()

	self.left_info_list = {}
	self.right_info_list = {}
	for k,v in pairs(self.show_info_list) do
		if v.cfg_type == 1 then
			table.insert(self.right_info_list, v)
		else
			table.insert(self.left_info_list, v)
		end
	end
	self.reward_cell_list = {}
	self.reward_list_obj = self:FindObj("RewardList")
	for i = 0, 5 do
		local item_cell = self.reward_list_obj.transform:GetChild(i).gameObject
		item_cell = HappyRewardItem.New(item_cell)
		item_cell:SetIndex(i+1)
		item_cell:SetData(self.right_info_list[i + 1])
		table.insert(self.reward_cell_list, item_cell)
	end

	self.item_cell_list = {}
	for i = 1, 7 do
		self.item_cell_list[i] = self:FindObj("Item"..i)
		if nil ~= self.item_cell_list[i] and nil ~= self.left_info_list[i] then
			local item_cell = ItemCell.New()
			item_cell:SetInstanceParent(self.item_cell_list[i])
			item_cell:SetData(self.left_info_list[i].reward_item)
		end
	end

	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("ClickOnce", BindTool.Bind(self.ClickOnce, self))
	self:ListenEvent("ClickTen", BindTool.Bind(self.ClickTen, self))
	self:ListenEvent("ClickRule", BindTool.Bind(self.ClickRule, self))
    self:ListenEvent("OnClickLog", BindTool.Bind(self.OnClickLog, self))
	
	self.rechanrge_count = self:FindVariable("rechanrge_count")
	self.reward_times = self:FindVariable("reward_times")
	self.res_time = self:FindVariable("res_time")
	self.cost = self:FindVariable("cost")
	self.cost_ten = self:FindVariable("cost_ten")
	self.show_red_1 = self:FindVariable("Show_Red_1")
	self.show_red_2 = self:FindVariable("Show_Red_2")
	self.cost:SetValue(HappyRechargeData.Instance:GetCost())
	self.cost_ten:SetValue(HappyRechargeData.Instance:GetCost() * 10)
end



function HappyRechargeView:ReleaseCallBack()
	for k,v in pairs(self.reward_cell_list) do
		v:DeleteMe()
	end
	self.reward_cell_list = {}

	self.reward_list_obj = nil
	self.rechanrge_count = nil
	self.reward_times = nil
	self.res_time = nil
	self.cost = nil
	self.cost_ten = nil
	self.show_red_1 = nil
	self.show_red_2 = nil
end

function HappyRechargeView:OpenCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
    local time = HappyRechargeData.Instance:GetRestTime()
    self:SetTime(time)
    self.least_time_timer = CountDown.Instance:AddCountDown(time, 1, function ()
			time = time - 1
            self:SetTime(time)
        end)
end

function HappyRechargeView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function HappyRechargeView:SetTime(time)
	time_tab = TimeUtil.Format2TableDHMS(time)
	local str = ""
	if time_tab.day > 0 then
		str = string.format(Language.IncreaseCapablity.ResTime, time_tab.day, time_tab.hour, time_tab.min, time_tab.s)
	else
		str = string.format(Language.IncreaseCapablity.ResTime2, time_tab.hour, time_tab.min, time_tab.s)
	end 
	self.res_time:SetValue(str)
end

function HappyRechargeView:OnFlush(param_list)
	local num = HappyRechargeData.Instance:GetChongZhiVlaue()
	if num >= HappyRechargeData.Instance:GetCost() * 10 then
		self.rechanrge_count:SetValue(ToColorStr(num, TEXT_COLOR.BULE_NORMAL))
		self.show_red_2:SetValue(true)
	else
		self.rechanrge_count:SetValue(ToColorStr(num, TEXT_COLOR.RED_1))
		self.show_red_2:SetValue(false)
	end
	self.reward_times:SetValue(HappyRechargeData.Instance:GetTotalTimes())
	self.show_red_1:SetValue(num >= HappyRechargeData.Instance:GetCost())
	for k,v in pairs(self.reward_cell_list) do
		v:Flush()
	end
end

function HappyRechargeView:ClickOnce()
	HappyRechargeCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_HAPPY_RECHARGE,
		RA_CHONGZHI_NIU_EGG_OPERA_TYPE.RA_CHONGZHI_NIU_EGG_OPERA_TYPE_CHOU, 1)
end

function HappyRechargeView:ClickTen()
	-- 活动号 操作类型 次数
	HappyRechargeCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_HAPPY_RECHARGE,
		RA_CHONGZHI_NIU_EGG_OPERA_TYPE.RA_CHONGZHI_NIU_EGG_OPERA_TYPE_CHOU, 10)
end

function HappyRechargeView:ClickRule()
	TipsCtrl.Instance:ShowHelpTipView(228)
end

function HappyRechargeView:CloseView()
	self:Close()
end

function HappyRechargeView:OnClickLog()
    ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_HAPPY_RECHARGE)
end

-------------------------------HappyRewardItem------------------------------------
HappyRewardItem = HappyRewardItem or BaseClass(BaseCell)
function HappyRewardItem:__init()
	self.times = self:FindVariable("times")
	self.vip_level = self:FindVariable("vip_level")
	self.is_get = self:FindVariable("is_get")
	self.cell = self:FindObj("Cell")
	self.is_able_get = self:FindVariable("is_able_get")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.cell)

	self:ListenEvent("ClickGet", BindTool.Bind(self.ClickGet, self))
end

function HappyRewardItem:__delete()
	self.item_cell:DeleteMe()
	self.item_cell = nil

	self.times = nil
	self.vip_level = nil
	self.is_get = nil
	self.cell = self:FindObj("Cell")
	self.is_able_get = nil
end

function HappyRewardItem:OnFlush()
	self.data = self:GetData()
	if next(self.data) then
		self.item_cell:SetData(self.data.reward_item)
		self.times:SetValue(self.data.server_niu_times)
		self.vip_level:SetValue(self.data.vip_limit)
		self.index = self:GetIndex()
		self.buffer = bit:d2b(HappyRechargeData.Instance:GetFetchFlag())
		self.is_get:SetValue(self.buffer[#self.buffer - self.index + 1] == 1)
		local total_times = HappyRechargeData.Instance:GetTotalTimes()
		self.is_able_get:SetValue(self.data.server_niu_times <= total_times)
	end
end

function HappyRewardItem:ClickGet()
	if not self.is_get:GetBoolean() then
		if self.is_able_get:GetBoolean() then
			HappyRechargeCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_HAPPY_RECHARGE,
			RA_CHONGZHI_NIU_EGG_OPERA_TYPE.RA_CHONGZHI_NIU_EGG_OPERA_TYPE_FETCH_REWARD, self.index - 1)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.CantGet)
		end
	end
end


