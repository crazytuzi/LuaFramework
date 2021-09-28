SecretTreasureHuntingView = SecretTreasureHuntingView or BaseClass(BaseView)

local ALL_TYPE = 3
local SLIDER_SHOW_REWARD_NUM = 6 			--进度条显示的奖励数量
local COLUMN = 4
local GOLD_TYPE = {
	[1] = "mijingxunbao_once_gold",
	[2] = "mijingxunbao_tentimes_gold",
	[3] = "mijingxunbao3_thirtytimes_gold",
}

local REQUIRE_SEQ = {
	[1] = RA_MIJINGXUNBAO3_CHOU_TYPE.RA_MIJINGXUNBAO3_CHOU_TYPE_1,
	[2] = RA_MIJINGXUNBAO3_CHOU_TYPE.RA_MIJINGXUNBAO3_CHOU_TYPE_10,
	[3] = RA_MIJINGXUNBAO3_CHOU_TYPE.RA_MIJINGXUNBAO3_CHOU_TYPE_30,
}

function SecretTreasureHuntingView:__init()
	self.ui_config = {"uis/views/secrettreasurehunting_prefab", "SecretTreasureHuntingView"}
end

function SecretTreasureHuntingView:__delete()

end

function SecretTreasureHuntingView:LoadCallBack()
	self.data_list = {}
	self.total_list = {}
	self.can_get_list = {}
	self.diamond_num_list = {}
	self.total_reward_list = {}
	self.secret_treasure_hunting_show_list = {}

	self.timer = self:FindVariable("timer")
	self.key_num = self:FindVariable("key_num")
	self.free_time = self:FindVariable("free_timer")
	self.silder_num = self:FindVariable("silder_num")
	self.is_have_key = self:FindVariable("is_have_key")
	self.total_count = self:FindVariable("total_count")
	self.reddot_activate = self:FindVariable("reddot_activate")

	self:ListenEvent("OnCloseClick", BindTool.Bind(self.OnCloseClick, self))
	self:ListenEvent("OnWareHoseClick", BindTool.Bind(self.OnWareHoseClick, self))
	self:ListenEvent("OpenLog", BindTool.Bind(self.OnClickOpenLog, self))

	self.show_list = self:FindObj("ShowListView")
	local list_delegate = self.show_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetLengthsOfCell, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	for i=1, ALL_TYPE do
		self.diamond_num_list[i] = self:FindVariable("diamond_num_".. i)
		self:ListenEvent("OnClick".. i, BindTool.Bind(self.OnClickChouJiang, self, i))
	end

	for i=1, SLIDER_SHOW_REWARD_NUM do
		self.total_list[i] = self:FindVariable("total_" .. i)
		self.can_get_list[i] = self:FindVariable("can_get_" .. i)
		self:ListenEvent("OnClickReward" .. i, BindTool.Bind(self.OnClickReward, self, i))

		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("total_reward_" .. i))
		item:SetData(nil)
		table.insert(self.total_reward_list, item)
	end
end

function SecretTreasureHuntingView:ReleaseCallBack()
	self.data_list = {}
	self.total_list = {}
	self.can_get_list = {}
	self.btn_text_list = {}
	self.diamond_num_list = {}
	self.secret_treasure_hunting_show_list = {}

	self.timer = nil
	self.silder_num = nil
	self.show_list = nil
	self.free_time = nil
	self.total_count = nil
	self.reddot_activate = nil
	self.key_num = nil
	self.is_have_key = nil
end


function SecretTreasureHuntingView:OpenCallBack()
	SecretTreasureHuntingCtrl.Instance:SendGetKaifuActivityInfo(RA_MIJINGXUNBAO3_OPERA_TYPE.RA_MIJINGXUNBAO3_OPERA_TYPE_QUERY_INFO)
	self:GetDataList()
	self.show_list.scroller:ReloadData(0)
end

function SecretTreasureHuntingView:CloseCallBack()
	self:CancelTimeQuest()
	self:CancelCountDown()
end

function SecretTreasureHuntingView:GetDataList()
	self.data_list = SecretTreasureHuntingData.Instance:GetMiJingXunBaoCfgByList()
end

function SecretTreasureHuntingView:GetLengthsOfCell()
	local num = #SecretTreasureHuntingData.Instance:GetMiJingXunBaoCfgByList()
	return math.ceil(num / COLUMN) or 0
end

function SecretTreasureHuntingView:RefreshCell(cell, cell_index)
	local the_cell = self.secret_treasure_hunting_show_list[cell]
	if nil == the_cell then
		the_cell = SecretTreasureHuntingViewShow.New(cell.gameObject)
		self.secret_treasure_hunting_show_list[cell] = the_cell
	end

	the_cell:SetIndex(cell_index)
	the_cell:SetData(self.data_list)
end

function SecretTreasureHuntingView:ShowNeedGoldText()
	local cfg = SecretTreasureHuntingData.Instance:GetOtherCfgByOpenDay()
	local reward_cfg = SecretTreasureHuntingData.Instance:GetMiJingXunBaoRewardConfig()

	if nil == cfg or nil == reward_cfg then return end

	for i=1, ALL_TYPE do
		if self.diamond_num_list[i] then
			local gold_type = GOLD_TYPE[i]
			local value = cfg[gold_type] or 0
			self.diamond_num_list[i]:SetValue(value)
		end
	end

	for i = 1, SLIDER_SHOW_REWARD_NUM do
		if reward_cfg[i] and reward_cfg[i].choujiang_times then
			self.total_list[i]:SetValue(reward_cfg[i].choujiang_times) 
			self.total_reward_list[i]:SetData(reward_cfg[i].reward_item)
		end
	end
end

function SecretTreasureHuntingView:OnFlush()
	self:ShowNeedGoldText()
	self:FlushFreeCountDown()
	self:FlushDataPresentation()
	self:FlushActivityTimeCountDown()
	self:RewardShow()
end

function SecretTreasureHuntingView:FlushDataPresentation()
	local flush_times = SecretTreasureHuntingData.Instance:GetChouTimesByInfo()
	local silder_num = SecretTreasureHuntingData.Instance:GetProValueByTimes(flush_times)
	local key_num, key_color, key_name = SecretTreasureHuntingData.Instance:IsHaveThirtyKey()

	self.total_count:SetValue(flush_times)
	self.silder_num:SetValue(silder_num)
	self.is_have_key:SetValue(key_num > 0)

	local text = key_num > 0 and key_name..Language.Common.X..key_num or ""
	local str = ToColorStr(text, key_color)
	self.key_num:SetValue(str)
end

function SecretTreasureHuntingView:FlushActivityTimeCountDown()
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
end

function SecretTreasureHuntingView:FlushFreeCountDown()
	local next_free_tao_timestamp = SecretTreasureHuntingData.Instance:GetNextFreeTaoTimestampByInfo()
	if next_free_tao_timestamp == 0 then
		self:ShowFreeTimes()
		return
	end

	local server_time = TimeCtrl.Instance:GetServerTime()
	local time_diff = next_free_tao_timestamp - server_time
	self:CancelCountDown()
	if time_diff > 0 then
		self.count_down = CountDown.Instance:AddCountDown(time_diff, 1, BindTool.Bind(self.FlushCountDown, self))
	else
		self:ShowFreeTimes()
	end
end

function SecretTreasureHuntingView:FlushCountDown(elapse_time, total_time)
	if elapse_time >= total_time then
		self:ShowFreeTimes()
	end

	self.reddot_activate:SetValue(false)
	self.free_time:SetValue(TimeUtil.FormatSecond(total_time - elapse_time) .. Language.SecretTreasureHunting.FreeTime)
end

function SecretTreasureHuntingView:ShowFreeTimes()
	local is_free = SecretTreasureHuntingData.Instance:IsFree()
	self:CancelCountDown()
	self.reddot_activate:SetValue(is_free)
	self.free_time:SetValue("")
end

function SecretTreasureHuntingView:RewardShow()
	local total_config = SecretTreasureHuntingData.Instance:GetMiJingXunBaoRewardConfig()

	for i = 1, SLIDER_SHOW_REWARD_NUM do
		if total_config[i] and total_config[i].choujiang_times then
			local info_choujiang_times = SecretTreasureHuntingData.Instance:GetChouTimesByInfo()
			local is_get = SecretTreasureHuntingData.Instance:GetCanFetchFlag(i - 1)
			local is_can_get = info_choujiang_times >= total_config[i].choujiang_times and not is_get

			self.total_reward_list[i]:ShowHaseGet(is_get)
			self.can_get_list[i]:SetValue(is_can_get)
		end
	end
end

function SecretTreasureHuntingView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIJINGXUNBAO3)
	local timer = ""
	if time <= 0 then
		self:CancelTimeQuest()
	end

	if time > 3600 * 24 then
		timer = TimeUtil.FormatSecond(time, 6)
	elseif time > 3600 then
		timer = TimeUtil.FormatSecond(time, 1)
	else
		timer = TimeUtil.FormatSecond(time, 2)
	end
	self.timer:SetValue(timer)
end

function SecretTreasureHuntingView:CancelTimeQuest()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function SecretTreasureHuntingView:CancelCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function SecretTreasureHuntingView:OnCloseClick()
	self:Close()
end

function SecretTreasureHuntingView:OnWareHoseClick()
	ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_warehouse)
end

function SecretTreasureHuntingView:OnClickOpenLog()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIJINGXUNBAO3)
end

function SecretTreasureHuntingView:OnClickReward(index)
	local idx = index
	local cfg = SecretTreasureHuntingData.Instance:GetMiJingXunBaoRewardConfig()
	local param_1 = cfg[idx] and cfg[idx].index or 0
	SecretTreasureHuntingCtrl.Instance:SendGetKaifuActivityInfo(RA_MIJINGXUNBAO3_OPERA_TYPE.RA_MIJINGXUNBAO3_OPERA_TYPE_FETCH_REWARD, param_1)
end

function SecretTreasureHuntingView:OnClickChouJiang(index)
	local opera_type = RA_MIJINGXUNBAO3_OPERA_TYPE.RA_MIJINGXUNBAO3_OPERA_TYPE_TAO
	local param_1 = REQUIRE_SEQ[index]
	SecretTreasureHuntingCtrl.Instance:SendGetKaifuActivityInfo(opera_type, param_1)
	SecretTreasureHuntingData.Instance:SetChestShopMode(index)
end

-------------------------------------------显示奖励物品-------------------------------------------------------
SecretTreasureHuntingViewShow = SecretTreasureHuntingViewShow or BaseClass(BaseCell)
function SecretTreasureHuntingViewShow:__init()
	self.item_cell_list = {}
	for i = 1, COLUMN do		
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("image_0" .. i))
		item:SetData(nil)
		table.insert(self.item_cell_list, item)
	end
end

function SecretTreasureHuntingViewShow:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = nil 
end

function SecretTreasureHuntingViewShow:OnFlush()
	if self.data == nil then return end

	for i = 1, COLUMN do
		index = self.index * COLUMN + i
		if self.data[index] and self.data[index].is_show == 1 then
			self.item_cell_list[i]:SetData(self.data[index].reward_item)
			self.item_cell_list[i]:SetItemActive(true)
		else
			self.item_cell_list[i]:SetItemActive(false)
		end
	end
end