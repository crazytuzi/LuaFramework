JinYinTaView = JinYinTaView or BaseClass(BaseView)

function JinYinTaView:__init()
	self.ui_config = {"uis/views/serveractivity/jinyinta", "JinYinTaView"}
	self.play_audio = true
 	
 	-- 抽奖类型 
 	self.draw_type = CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_1
 	-- 金银塔奖励
	self.jinyinta_reward = {}
	-- 历史抽奖记录
	self.history_reward = {}
	self:SetMaskBg()
end

function JinYinTaView:__delete()

end

function JinYinTaView:ReleaseCallBack()
	-- 清理变量和对象
	for k, v in pairs(self.item_cells) do
		self.show_reward_list[k] = nil
		v:DeleteMe()
		v = nil
	end

	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end

 	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.act_next_timer then
		GlobalTimerQuest:CancelQuest(self.act_next_timer)
		self.act_next_timer = nil
	end

	if self.close_timer then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = nil
	end

	for k, v in pairs(self.jinyinta_reward) do
		v:DeleteMe()
		v = nil 
	end

	for k, v in pairs(self.history_reward) do
		v:DeleteMe()
		v = nil 
	end

	if self.show_reward_panel then
		GlobalTimerQuest:CancelQuest(self.show_reward_panel)
		self.show_reward_panel = nil
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	self.jinyinta_reward = {}
	self.history_reward = {}
	self.mianFeiTime = nil 
	self.imgCurrLevel = nil 
	self.jinYinTaRewardList = nil
	self.ShenYuTime = nil	

	self.history_list_view = nil

	self.OneChouMoney = nil 
	self.OneGoldImage = nil
	self.PointRedCanChou = nil 
	self.TenChouGold = nil
	self.OneChouGold = nil
	self.play_ani_toggle = nil
	self.is_free = nil
end

function JinYinTaView:LoadCallBack()
	self.mianFeiTime      = self:FindVariable("MianFeiTime")
	self.imgCurrLevel     = self:FindVariable("ImgCurrLevel")
	self.ShenYuTime       = self:FindVariable("ShenYuTime")	
	self.TenChouGold      = self:FindVariable("TenChouGold")
	self.OneChouGold      = self:FindVariable("OneChouGold")
	self.is_free		  = self:FindVariable("Is_Free")
	self.OneChouMoney     = self:FindObj("OneChouMoney")
	self.OneGoldImage     = self:FindObj("OneGoldImage")
	self.PointRedCanChou  = self:FindObj("PointRedCanChou")
	self.play_ani_toggle = self:FindObj("PlayAniToggle").toggle
	self.item_cells       = {}
	self.show_reward_list = {}

	for i = 1, 21 do
		self.item_cells[i] = ItemCell.New()
		self.item_cells[i]:SetInstanceParent(self:FindObj("Item"..i))
		self.show_reward_list[i] = self:FindVariable("ShowReward" .. i)
	end

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))

 	-- 金银塔活动奖励
 	local param = JinYinTaData.Instance:GetLevelLotteryItemList()
 	for k, v in pairs(self.item_cells) do
 		self.show_reward_list[k]:SetValue(true)
 		v:SetActive(true)
 		if param[k] ~= nil then
 			v:SetData(param[k].reward_item)
 		end
 		local is_rare = param[k] and param[k].is_rare or 0
 		if is_rare == 1 then
 			v:ShowGetEffect(true)
 		else
 			v:ShowGetEffect(false)
 		end	
	end

	-- 抽一次之前的层级
	self.old_level = 1
	self.is_flush  = true
	-- 一次抽的loop次数
	self.play_num  = 3
 
 	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OneChou", BindTool.Bind(self.OneChou, self))
	self:ListenEvent("TenChou", BindTool.Bind(self.TenChou, self))
	self:ListenEvent("TipsClick", BindTool.Bind(self.TipsClick, self))

	self:InitRewardListView()
	self:FlushActEndTime()
	self:InitHistoryListView()
end

function JinYinTaView:OpenCallBack()
	-- 请求记录信息
 	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_JINYINTA,RA_TOTAL_CHARGE_OPERA_TYPE.RA_LEVEL_LOTTERY_OPERA_TYPE_QUERY_INFO)
 	-- 请求活动信息	
 	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_JINYINTA,RA_TOTAL_CHARGE_OPERA_TYPE.RA_LEVEL_LOTTERY_OPERA_TYPE_ACTIVITY_INFO)
 	JinYinTaData.Instance:SetPlayNotClick(true)
 	JinYinTaData.Instance:SetTenNotClick(true)
end

function JinYinTaView:CloseCallBack()
 	JinYinTaData.Instance:SetShowReasureBool(false)
 	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.close_timer then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = nil
	end
end
 
function JinYinTaView:OnFlush()
	if CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_1 == self.draw_type then
		if self.play_ani_toggle.isOn then
			self:TurnCellOne()
		else
			self:TurnCell(JinYinTaData.Instance:GetOldLevel())
		end
 	else
		TipsCtrl.Instance:ShowTreasureView(self.draw_type)
		self.is_flush = true
		self:FlushCurrLevel()
		if self.show_reward_panel then
			GlobalTimerQuest:CancelQuest(self.show_reward_panel)
			self.show_reward_panel = nil
		end
		self.show_reward_panel = GlobalTimerQuest:AddDelayTimer(function ()
			self:TenTurnCell()
			ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_RA_LEVEL_LOTTERY)
		end,3)
		
 	end
 	JinYinTaData.Instance:SetTenNotClick(true)
end
-- 十次抽的cell的效果
function JinYinTaView:TenTurnCell()
	local reward_info = JinYinTaData.Instance:GetLotteryRewardList()
	if reward_info and reward_info[10] then
		for i = 1, 21 do
			-- 重置itemToggle
			self.item_cells[i]:SetToggle(false)
		end
		if self.item_cells[reward_info[10] + 1] then
			self.item_cells[reward_info[10] + 1]:SetToggle(true)
		end
	end
end
function JinYinTaView:TurnCellOne()
	for i = 1, 21 do
		-- 重置itemToggle
		self.item_cells[i]:SetToggle(false)
	end
	TipsCtrl.Instance:ShowTreasureView(self.draw_type)
	self.is_flush = true
	self:FlushCurrLevel()
	JinYinTaData.Instance:SetPlayNotClick(true)
	local reward_info = JinYinTaData.Instance:GetLotteryRewardList()
	self.item_cells[reward_info[1] + 1]:SetToggle(true)

end
-- 一次抽的cell的效果 
function JinYinTaView:TurnCell(currLevel)
	-- 每层的cell数目
	local cell_count = 6 - currLevel
	-- 某层的最大index
	local max_index = self:AddLastNum(cell_count)
	-- 某层的最小index
	local min_index = self:AddLastNum(cell_count) - cell_count + 1
	local temp = min_index
	local turn_num = 1
	local reward_info = JinYinTaData.Instance:GetLotteryRewardList()
	for i = 1, 21 do
		-- 重置itemToggle
		self.item_cells[i]:SetToggle(false)
	end
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		for i = min_index, max_index do
			if i == temp then
				self.item_cells[i]:SetToggle(true)
				if turn_num == self.play_num then
					if (reward_info[1] == (temp - 1)) then
						if self.time_quest then
							GlobalTimerQuest:CancelQuest(self.time_quest)
							self.time_quest = nil
						end
						TipsCtrl.Instance:ShowTreasureView(self.draw_type)
						self.is_flush = true
						self:FlushCurrLevel()
						if self.show_reward_panel then
							GlobalTimerQuest:CancelQuest(self.show_reward_panel)
							self.show_reward_panel = nil
						end
						self.show_reward_panel = GlobalTimerQuest:AddDelayTimer(function ()
							ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_RA_LEVEL_LOTTERY)
							-- 一次抽奖结束，释放一次抽奖的锁
							JinYinTaData.Instance:SetPlayNotClick(true)
						end,1)
					end
				end
			else
				self.item_cells[i]:SetToggle(false)
			end
		end
		temp = temp + 1
		if temp > max_index then
			turn_num = turn_num + 1
			if turn_num > self.play_num then
				if self.time_quest then
					GlobalTimerQuest:CancelQuest(self.time_quest)
					self.time_quest = nil
				end
				TipsCtrl.Instance:ShowTreasureView(self.draw_type)
			end
			temp = min_index
		end
	end,0.2)
end

-- 计算某层的最大index
function JinYinTaView:AddLastNum(curr_num)
	if curr_num == 6 then
		return 6
	end
	return curr_num + self:AddLastNum(curr_num + 1)
end

-- 刷新当前层级
function JinYinTaView:FlushCurrLevel()
	local currLevel = JinYinTaData.Instance:GetLotteryCurLevel()
	if self.is_flush then
		self.imgCurrLevel:SetValue(currLevel + 1)
		self.is_flush =  false
	end
	-- 刷新抽奖励需要的钻石数
	local need_gold = JinYinTaData.Instance:GetChouNeedGold(currLevel)
	self.OneChouGold:SetValue(need_gold)
	self.TenChouGold:SetValue(need_gold * 10)
end

function JinYinTaView:FlushNextTime()
	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end
	self.OneChouMoney:SetActive(true)
	self.OneGoldImage:SetActive(true)
	self.PointRedCanChou:SetActive(false)
	-- 免费倒计时
	self:FlushCanNextTime()
	self.next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushCanNextTime, self), 1)
    
    -- 刷新累计抽奖次数
	local buy_count = JinYinTaData.Instance:GetLeiJiRewardNum()

 	-- 刷新累计奖励Item
 	if self.jinYinTaRewardList.scroller.isActiveAndEnabled then
		self.jinYinTaRewardList.scroller:RefreshAndReloadActiveCellViews(true)
	end

	if JinYinTaData.Instance:GetShowReasureBool() then
		--TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_RANK_JINYIN_GET_REWARD) 
		 JinYinTaData.Instance:SetShowReasureBool(false)
	end

	-- 刷新全服历史抽奖奖励Item
 	if self.history_list_view.scroller.isActiveAndEnabled then
		self.history_list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function JinYinTaView:FlushCanNextTime()
	local free_config = ServerActivityData.Instance:GetCurrentRandActivityConfig().level_lottery_other
 	local free_time = free_config[1].free_time
 	if free_time == 0 then 
 		self.OneChouMoney:SetActive(true)
		self.OneGoldImage:SetActive(true)
		self.PointRedCanChou:SetActive(false)
		self.is_free:SetValue(false)
		return
 	end
 	
	local time_str = JinYinTaData.Instance:GetLeveLotteryMianFei()
	local value_str = string.format(Language.JinYinTa.MianFeiText,	TimeUtil.FormatSecond(time_str))
 	self.mianFeiTime:SetValue(value_str)
 	if time_str <= 0  then
 		-- 移除计时器
		if self.next_timer then
			GlobalTimerQuest:CancelQuest(self.next_timer)
			self.next_timer = nil
		end
		self.mianFeiTime:SetValue(Language.JinYinTa.KeYiMianFei)
		self.OneChouMoney:SetActive(false)
		self.OneGoldImage:SetActive(false)
		self.PointRedCanChou:SetActive(true)
		self.is_free:SetValue(true)
		JinYinTaData.Instance:FlushHallRedPoindRemind()
 	end
end


function JinYinTaView:FlushActEndTime()
	-- 活动倒计时
	if self.act_next_timer then
		GlobalTimerQuest:CancelQuest(self.act_next_timer)
		self.act_next_timer = nil
	end
	self:FlushUpdataActEndTime()
	self.act_next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushUpdataActEndTime, self), 60)
end

function JinYinTaView:FlushUpdataActEndTime()
	local time_str = JinYinTaData.Instance:GetActEndTime()
 	self.ShenYuTime:SetValue("<color='#00ff00'>" .. TimeUtil.FormatSecond2DHMS(time_str, 1) .. "</color>")

 	if time_str <= 0  then
 		-- 移除计时器
		if self.act_next_timer then
			GlobalTimerQuest:CancelQuest(self.act_next_timer)
			self.act_next_timer = nil
		end
	 	
 	end
end

function JinYinTaView:OnClickClose()
	local is_onwait = JinYinTaData.Instance:GetPlayNotClick()
	local isClick = JinYinTaData.Instance:GetTenyNotClick()
	if is_onwait and isClick then
		self:Close()
	else
		if nil == self.close_timer then
			self.close_timer = GlobalTimerQuest:AddDelayTimer(function ()
				-- 防止没有返回是关闭功能被锁住
				JinYinTaData.Instance:SetPlayNotClick(true)
				JinYinTaData.Instance:SetTenNotClick(true)
			end,5)
		end
	end
	
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_JINYINTA)
	-- 活动未开启
	if not is_open then
		self:Close()
	end
end

-- 抽一次
function JinYinTaView:OneChou()
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	if bags_grid_num > 0 then
		local is_onwait = JinYinTaData.Instance:GetPlayNotClick()
	 	if is_onwait then
	 		local isClick = JinYinTaData.Instance:GetTenyNotClick()
	 		if isClick then
	 			-- 判断是否有免费次数
	 			local time_str = JinYinTaData.Instance:GetLeveLotteryMianFei()
	 			if time_str <= 0  then
	 				-- 免费直接抽
	 				self:OneChouAction()
	 			else
				 	local sure_func = function()
				 		self:OneChouAction()
				 	end
				 	local currLevel = JinYinTaData.Instance:GetLotteryCurLevel()
					-- 刷新抽奖励需要的钻石数
					local need_gold = JinYinTaData.Instance:GetChouNeedGold(currLevel)
					local tips_text = string.format(Language.JinYinTa.OneChouNeedGold,need_gold)
					-- 玩家钻石数量
					local role_gold = GameVoManager.Instance:GetMainRoleVo().gold
					if role_gold >= need_gold then
						TipsCtrl.Instance:ShowCommonAutoView("jinyinta_use_gold_1",tips_text, sure_func, nil, nil, nil, nil, nil, true, true)
					else
						TipsCtrl.Instance:ShowLackDiamondView()
					end
				end
			end
		end
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

function JinYinTaView:OneChouAction()
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
		if bags_grid_num > 0 then
		-- 抽一次之前的层级
	 	self.old_level = JinYinTaData.Instance:GetLotteryCurLevel()
	 	JinYinTaData.Instance:SetOldLevel(self.old_level)
		self.draw_type = CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_1
		JinYinTaData.Instance:SetPlayNotClick(false)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_JINYINTA,RA_TOTAL_CHARGE_OPERA_TYPE.RA_LEVEL_LOTTERY_OPERA_TYPE_DO_LOTTERY,CHARGE_OPERA.CHOU_ONE)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

-- 抽十次
function JinYinTaView:TenChou()
	local is_onwait = JinYinTaData.Instance:GetPlayNotClick()
 	if is_onwait then
		local sure_func = function()
	 		self:TenChouAction()
	 	end
		local currLevel = JinYinTaData.Instance:GetLotteryCurLevel()
		-- 刷新抽奖励需要的钻石数
		local need_gold = JinYinTaData.Instance:GetChouNeedGold(currLevel)
		local ten_gold_str = string.format(Language.JinYinTa.TenChouNeedGold,need_gold * 10)
		local role_gold = GameVoManager.Instance:GetMainRoleVo().gold
		-- 有足够的钻石
		if role_gold >= need_gold then
			TipsCtrl.Instance:ShowCommonAutoView("jinyinta_use_gold_10",ten_gold_str, sure_func, nil, nil, nil, nil, nil, true, true)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
		
	end
end

-- 抽十次
function JinYinTaView:TenChouAction()
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	if bags_grid_num > 0 then
		self.draw_type = CHEST_SHOP_MODE.CHEST_RANK_JINYIN_TA_MODE_10
		JinYinTaData.Instance:SetTenNotClick(false)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_JINYINTA,RA_TOTAL_CHARGE_OPERA_TYPE.RA_LEVEL_LOTTERY_OPERA_TYPE_DO_LOTTERY,CHARGE_OPERA.CHOU_TEN)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

-- 玩法说明
function JinYinTaView:TipsClick()
	local tips_id = 236 -- 金银塔
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

-------------------累计奖励---------------------

function JinYinTaView:InitRewardListView()
	self.jinYinTaRewardList = self:FindObj("LeiJiReward")
	local list_delegate = self.jinYinTaRewardList.list_simple_delegate
	-- 有有多少个cell
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCurrScoreOfCells, self)
	-- 更新cell
	list_delegate.CellRefreshDel = BindTool.Bind(self.ScoreRefreshCell, self)
	self.jinYinTaRewardList.scroll_rect.vertical = true
	self.jinYinTaRewardList.scroll_rect.horizontal = false
end

function JinYinTaView:GetCurrScoreOfCells()
	return #JinYinTaData.Instance:GetLeijiJiangli() or 0
end

function JinYinTaView:ScoreRefreshCell(cell, data_index)
	data_index = data_index + 1
	local score_cell = self.jinyinta_reward[cell]
	if score_cell == nil then
		score_cell = RewardItem.New(cell.gameObject)
		score_cell.root_node.toggle.group = self.jinYinTaRewardList.toggle_group
		self.jinyinta_reward[cell] = score_cell
	end
 	score_cell:SetClickCallBack(BindTool.Bind(self.ScoreCellClick, self))
	local reward_info = JinYinTaData.Instance:GetLeijiJiangli()
	if reward_info then
		local data = reward_info[data_index]
		score_cell:SetIndex(data_index)
		score_cell:SetData(data)
	end

	--设置高亮展示
	if data_index == self.select_score_index then
		score_cell:SetSorceToggleIsOn(true)
	else
		score_cell:SetSorceToggleIsOn(false)
	end
end

function JinYinTaView:ScoreCellClick(cell)
	local index = cell:GetIndex()
	self.select_score_index = index
end
--------------------------------------------------------------------------
-- RewardItem 	奖励item
--------------------------------------------------------------------------
RewardItem = RewardItem or BaseClass(BaseCell)

function RewardItem:__init(instance)

	self:RewardObj()
	self:ListenEvent("ClickItem", BindTool.Bind(self.GetLeijiReward, self))
end

function RewardItem:__delete()
	self.LinQuNum    = nil
	self.ShowImage   = nil
	self.LblVipLevel = nil
	self.ItemImage   = nil
	if self.reward_item_cells then
		self.reward_item_cells:DeleteMe()
		self.reward_item_cells = nil
	end
	self.GrayGg = nil
	self.RedPoint = nil
	self.VipIcon = nil
end

function RewardItem:RewardObj()
	self.LinQuNum    = self:FindVariable("LinQuNum")
	self.ShowImage   = self:FindVariable("ShowImage")
	self.LblVipLevel = self:FindVariable("LblVipLevel")
	self.ItemImage   = self:FindVariable("ItemImage")
	self.ShowEff   = self:FindVariable("ShowEff")
	self.GrayGg =  self:FindVariable("GrayGg")
	self.RedPoint = self:FindVariable("RedPoint")
	self.reward_item_cells = ItemCell.New()
	self.reward_item_cells:SetInstanceParent(self:FindObj("IconItem"))
	self.VipIcon = self:FindObj("VipIcon")
end

function RewardItem:OnFlush()
	if not next(self.data) then return end
	local vip_str = string.format(Language.JinYinTa.VipMiaoshu,self.data.vip_level_limit)
	self.LblVipLevel:SetValue(vip_str)
	self.reward_item_cells:SetActive(true)
	self.reward_item_cells:SetData(self.data.reward[0])
	self.ShowImage:SetValue(true)
	self.ShowEff:SetValue(false)
    -- 是否领取了奖励
	local lottery_bool = JinYinTaData.Instance:IsGetReward(self.data.reward_index)
	if lottery_bool then
		self.LinQuNum:SetValue("")
		self.reward_item_cells:ShowHaseGet(true)
		self.reward_item_cells:ShowGetEffect(false)
		--self.VipIcon:SetActive(false)
		self.GrayGg:SetValue(true)
		self.RedPoint:SetValue(false)
	else
		self.reward_item_cells:ShowGetEffect(false)
		-- 是否满足领取累计奖励
		local can_lin = JinYinTaData.Instance:CanGetRewardByVipAndCount(self.data.vip_level_limit,self.data.total_times)
		if can_lin then
		 	self.RedPoint:SetValue(true)
			self.LinQuNum:SetValue(Language.JinYinTa.KeLingQu)
		--	self.VipIcon:SetActive(false)
		else 
			local buy_count = JinYinTaData.Instance:GetLeiJiRewardNum()
			local lingqu = string.format(Language.JinYinTa.LingQuTiaoJian,buy_count,self.data.total_times)
			self.LinQuNum:SetValue(lingqu)
			self.RedPoint:SetValue(false)
			self.VipIcon:SetActive(true)
		end
		self.GrayGg:SetValue(false)

	end
end

function RewardItem:SetSorceToggleIsOn(ison)
	local now_ison = self.root_node.toggle.isOn
	if ison == now_ison then
		return
	end
	self.root_node.toggle.isOn = ison
end

function RewardItem:GetLeijiReward()
	-- 是否满足领取累计奖励
	local can_lin = JinYinTaData.Instance:CanGetRewardByVipAndCount(self.data.vip_level_limit,self.data.total_times)
	if can_lin then
		JinYinTaData.Instance:SetLenRewardLevel(self.data.total_times)
 		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_JINYINTA,RA_TOTAL_CHARGE_OPERA_TYPE.RA_LEVEL_LOTTERY_OPERA_TYPE_FETCHE_TOTAL_REWARD,self.data.total_times)
	   	JinYinTaData.Instance:SetShowReasureBool(true)
	end
end
function RewardItem:LoadCallBack(uid, raw_img_obj, path)

end

-------------------全服抽奖记录---------------------
function JinYinTaView:InitHistoryListView()
	self.history_list_view = self:FindObj("HistoryListView")
	local list_delegate = self.history_list_view.list_simple_delegate
	-- 有有多少个cell
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetHistoryInfoCount, self)
	-- 更新cell
	list_delegate.CellRefreshDel = BindTool.Bind(self.HistoryRefreshCell, self)
end

function JinYinTaView:GetHistoryInfoCount()
	return #JinYinTaData.Instance:GetHistoryRewardList() or 0
end

function JinYinTaView:HistoryRefreshCell(cell, data_index)
	data_index = data_index + 1
	local history_cell = self.history_reward[cell]
	if history_cell == nil then
		history_cell = HistoryItem.New(cell.gameObject)
		history_cell.root_node.toggle.group = self.history_list_view.toggle_group
		self.history_reward[cell] = history_cell
	end
 	history_cell:SetClickCallBack(BindTool.Bind(self.HistoryCellClick, self))
	local history_reward_info = JinYinTaData.Instance:GetHistoryRewardList()
	if history_reward_info then
		local data = history_reward_info[data_index]
		history_cell:SetIndex(data_index)
		history_cell:SetData(data)
	end

	--设置高亮展示
	if data_index == self.select_history_index then
		history_cell:SetSorceToggleIsOn(true)
	else
		history_cell:SetSorceToggleIsOn(false)
	end
end

function JinYinTaView:HistoryCellClick(cell)
	local index = cell:GetIndex()
	self.select_history_index = index
end
--------------------------------------------------------------------------
-- HistoryItem 	历史抽奖item
--------------------------------------------------------------------------
HistoryItem = HistoryItem or BaseClass(BaseCell)

function HistoryItem:__init(instance)
	self:InitHistoryReward()
end

function HistoryItem:__delete()
	self.RoleName    = nil
	self.RoleActivity   = nil
end

function HistoryItem:InitHistoryReward()
	self.RoleName     = self:FindVariable("RoleName")
	self.RoleActivity = self:FindVariable("RoleActivity")
end

function HistoryItem:OnFlush()
	if not next(self.data) then return end
 	local name_str = string.format(Language.JinYinTa.NameMiaoshu,self.data.user_name)
 	self.RoleName:SetValue(name_str)
 	local item_info = JinYinTaData.Instance:GetHistoryRewardInfo(self.data.reward_index)
 	local name_info = ItemData.Instance:GetItemConfig(item_info.item_id)
 	local item_str = string.format(Language.JinYinTa.ChouJiang,name_info.name,item_info.num)
 	self.RoleActivity:SetValue(item_str)
end

function HistoryItem:SetSorceToggleIsOn(ison)
	local now_ison = self.root_node.toggle.isOn
	if ison == now_ison then
		return
	end
	self.root_node.toggle.isOn = ison
end

function HistoryItem:LoadCallBack(uid, raw_img_obj, path)

end