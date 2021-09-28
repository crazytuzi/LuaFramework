-- 拥有矿物面板
KuaFuMiningGiftPanel = KuaFuMiningGiftPanel or BaseClass(BaseRender)

function KuaFuMiningGiftPanel:__init()
	
	----------------------------------------------------
	-- 列表生成滚动条
	self.mining_creel_cell_list = {}
	self.creel_listview_data = {}
	self.creel_list = self:FindObj("List")
	local creel_list_delegate = self.creel_list.list_simple_delegate
	--生成数量
	creel_list_delegate.NumberOfCellsDel = function()
		return #self.creel_listview_data or 0
	end
	--刷新函数
	creel_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCreelListView, self)

	self:Flush()
end

function KuaFuMiningGiftPanel:__delete()
	if self.mining_creel_cell_list then
		for k,v in pairs(self.mining_creel_cell_list) do
			v:DeleteMe()
		end
	end
	self.mining_creel_cell_list = {}
end

function KuaFuMiningGiftPanel:OnFlush(param_list)
	-- 设置list数据
	local combination_cfg = KuaFuMiningData.Instance:GetMiningExchangeCfg()
	
	self.creel_listview_data = combination_cfg
	if self.creel_list.scroller.isActiveAndEnabled then
		self.creel_list.scroller:ReloadData(0)
	end
end

-- 列表listview
function KuaFuMiningGiftPanel:RefreshCreelListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local creel_cell = self.mining_creel_cell_list[cell]
	if creel_cell == nil then
		creel_cell = MiningExchangePanelItemRender.New(cell.gameObject)
		self.mining_creel_cell_list[cell] = creel_cell
	end
	creel_cell:SetIndex(data_index)
	creel_cell:SetData(self.creel_listview_data[data_index])
end

----------------------------------------------------------------------------
--MiningExchangePanelItemRender	挖矿兑换面板
----------------------------------------------------------------------------
MiningExchangePanelItemRender = MiningExchangePanelItemRender or BaseClass(BaseCell)
function MiningExchangePanelItemRender:__init()
	self.lbl_fish_num = {}
	self.mineral_list = {}
	for i = 1, 5 do
		self.lbl_fish_num[i] = self:FindVariable("FishNum_" .. i)
		self.mineral_list[i] = self:FindVariable("MineralNum_" .. i)
	end
	self.show_red_point = self:FindVariable("ShowRedPoint")


	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self:ListenEvent("OnBtnExchange", BindTool.Bind(self.OnBtnExchangeHandler, self))
end

function MiningExchangePanelItemRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function MiningExchangePanelItemRender:OnFlush()
	local mining_info = KuaFuMiningData.Instance:GetMiningRoleInfo()
	if not self.data or not next(self.data) or not mining_info then return end

	for i = 1, 5 do
		local need_fish_num = self.data["mine_type_" .. (i - 1)]
		local my_fish_num = mining_info.mine_num_list[i]

		if need_fish_num and my_fish_num then
			if self.lbl_fish_num[i] then
				self.lbl_fish_num[i]:SetValue(need_fish_num)
			end
			if self.mineral_list[i] then
				self.mineral_list[i]:SetValue(ToColorStr(my_fish_num, my_fish_num >= need_fish_num and TEXT_COLOR.GREEN1 or TEXT_COLOR.RED))
			end
		end
	end

	if self.item_cell then
		self.item_cell:SetData(self.data.reward_item)
	end
	local is_show = KuaFuMiningData.Instance:GetGiftPanelBtnRedPointBySeq(self.data.seq)
	self.show_red_point:SetValue(is_show)
end

function MiningExchangePanelItemRender:OnBtnExchangeHandler()
	if not self.data or not next(self.data) then return end
	KuaFuMiningCtrl.Instance:SendCSCrossMiningOperaReq(MINING_REQ_TYPE.CROSS_MINING_REQ_TYPE_EXCHANGE, self.data.seq)
	KuaFuMiningCtrl.Instance:SetCloseGiftViewTime()
end

------------------ 挖矿任务面板
KuaFuMiningTaskView = KuaFuMiningTaskView or BaseClass(BaseRender)

function KuaFuMiningTaskView:__init()
	self.cur_combo = self:FindVariable("CurCombo")
	self.next_combo_reward = self:FindVariable("NextComboReward")

	self.item = ItemCell.New(self:FindObj("Item1"))
end

function KuaFuMiningTaskView:__delete()
	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end
end

function KuaFuMiningTaskView:OnFlush(param_list)
	local mining_info = KuaFuMiningData.Instance:GetMiningRoleInfo()
	local combo_reward_cfg = KuaFuMiningData.Instance:GetMiningComboRewardCfg()
	self.cur_combo:SetValue(mining_info.combo_times)

	for k,v in pairs(combo_reward_cfg) do
		if mining_info.max_combo_times < combo_reward_cfg[1].combo_times then
			self.next_combo_reward:SetValue(combo_reward_cfg[1].combo_times)
			self.item:SetData(combo_reward_cfg[1].reward_item)
		elseif mining_info.max_combo_times + 1 <= v.combo_times then
			self.next_combo_reward:SetValue(v.combo_times)
			self.item:SetData(v.reward_item)
			-- if last_combo >= combo_reward_cfg[#combo_reward_cfg].combo_times and max_combo >= combo_reward_cfg[#combo_reward_cfg].combo_times then
			-- 	self.node_t_list.img_yilingwan.node:setZOrder(999)
			-- 	self.node_t_list.img_yilingwan.node:setVisible(true)
			-- end
			return
		end
	end
end


---------------------- 挖矿积分面板
KuaFuMiningScoreView = KuaFuMiningScoreView or BaseClass(BaseRender)

function KuaFuMiningScoreView:__init()
	self.quality_times = {}
	for i = 1, 3 do
		self.quality_times[i] = self:FindVariable("QualityTimes_" .. i) 	--各区域已经挖过的次数
	end
	self.area_score = {}
	for i = 1, 3 do
		self.area_score[i] = self:FindVariable("AreaScore_" .. i) 			--各区域所对应的积分奖励
	end
	self.my_score = self:FindVariable("MyScore")
	self.mining_times = self:FindVariable("MiningTimes")

	self.reward_item_list = {}
	self.reward_item_obj = {}
	for i = 1, 3 do
		local item = ItemCell.New()
		local item_obj = self:FindObj("Item"..i)
		item:SetInstanceParent(item_obj)
		item_obj:SetActive(false)
		table.insert(self.reward_item_obj, item_obj)
		table.insert(self.reward_item_list, item)
	end
end

function KuaFuMiningScoreView:__delete()
	if self.reward_item_list then
		for k,v in pairs(self.reward_item_list) do
			v:DeleteMe()
		end
		self.reward_item_list = nil
	end
end

function KuaFuMiningScoreView:OnFlush(param_list)
	local mining_info = KuaFuMiningData.Instance:GetMiningRoleInfo()
	local mining_other_cfg = KuaFuMiningData.Instance:GetMiningOtherCfg()
	if mining_info and mining_other_cfg then
		local score_reward_cfg = KuaFuMiningData.Instance:GetScoreReward(mining_info.score)
		local score_reward_list = KuaFuMiningData.Instance:GetScoreRewardList(mining_info.score)
		if score_reward_cfg and score_reward_list then
			for i = 1, 3 do
				if self.quality_times[i] then
					self.quality_times[i]:SetValue(mining_info.hit_area_times_list[i])
				end
				local area_score = KuaFuMiningData.Instance:GetAreaScoreByArea(i - 1)
				if self.area_score[i] then
					self.area_score[i]:SetValue(area_score)
				end
			end
			--设置积分奖励itemcell
			for i = 1, 3 do
				self.reward_item_obj[i]:SetActive(false)
				if score_reward_list[i - 1] then
					self.reward_item_list[i]:SetData(score_reward_list[i - 1])
					self.reward_item_obj[i]:SetActive(true)
				end
			end
			local my_score_str = ToColorStr(mining_info.score, mining_info.score >= score_reward_cfg.need_score and TEXT_COLOR.GREEN2 or TEXT_COLOR.RED)
			self.my_score:SetValue(string.format(Language.KuaFuFMining.MiningTimes, my_score_str, score_reward_cfg.need_score))
			self.mining_times:SetValue(string.format(Language.KuaFuFMining.MiningTimes, mining_info.used_mining_times, mining_other_cfg.mining_times + mining_info.add_mining_times))
		end
	end
end

---------------------- 挖矿排行面板
KuaFuMiningRankView = KuaFuMiningRankView or BaseClass(BaseRender)

function KuaFuMiningRankView:__init()
	self.is_norank = true
	self.mining_ranking = self:FindVariable("Ranking")
	self.mining_rank = self:FindVariable("Rank")
	self.mining_name = self:FindVariable("Name")
	self.mining_score = self:FindVariable("Score")
	self.mining_norank = self:FindVariable("NoRank")

	self:ListenEvent("Close", BindTool.Bind(self.CloseView, self))
	self.scroller_data = {}
	self:InitScroller()
end

function KuaFuMiningRankView:__delete()
	if self.cell_list ~= nil then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = {}
end

function KuaFuMiningRankView:LoadCallBack(instance)
end

function KuaFuMiningRankView:CloseView()
	KuaFuMiningCtrl.Instance:SetRankViewVisable(false)
end

function KuaFuMiningRankView:OnFlush(param_list)
	-- 设置list数据
	self.scroller_data = KuaFuMiningData.Instance:GetMiningRankInfo()
	if self.scroller_list.scroller.isActiveAndEnabled then
	end
	self.scroller_list.scroller:ReloadData(0)

	-- 自己的排行信息
	local role_info = KuaFuMiningData.Instance:GetMiningRoleInfo()
	for k,v in pairs(self.scroller_data) do
		if v.plat_id == role_info.plat_id and v.role_id == role_info.role_id then
			self.mining_ranking:SetValue(k)
			self.is_norank = false
			if k <= 3 and k > 0 then
				local bundle, asset = ResPath.GetKFMiningRankIcon(k)
				self.mining_rank:SetAsset(bundle, asset)
			end
		end
	end
	self.mining_norank:SetValue(self.is_norank)
	self.mining_name:SetValue(role_info.name)
	self.mining_score:SetValue(role_info.score)
end
	

function KuaFuMiningRankView:InitScroller()
	self.cell_list = {}
	self.scroller_data = KuaFuMiningData.Instance:GetMiningRankInfo()
	self.scroller_list = self:FindObj("Scroller")
	local delegate = self.scroller_list.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.scroller_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] = MiningRankScrollerCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
			target_cell.mother_view = self
		end
		local cell_data = self.scroller_data[data_index]
		cell_data.data_index = data_index
		target_cell:SetData(cell_data)
	end
end

--滚动条格子
MiningRankScrollerCell = MiningRankScrollerCell or BaseClass(BaseCell)

function MiningRankScrollerCell:__init()
	self.is_top_three = self:FindVariable("IsTopThree")
	self.is_self = self:FindVariable("IsSelf")
	self.rank = self:FindVariable("Rank")
	self.player_name = self:FindVariable("Name")
	self.score = self:FindVariable("Score")
	self.rank_icon = self:FindVariable("RankIcon")
end

function MiningRankScrollerCell:__delete()
end

function MiningRankScrollerCell:OnFlush()
	local rank_is_self = (self.data.user_name == GameVoManager.Instance:GetMainRoleVo().name)
	self.is_self:SetValue(rank_is_self)
	local rank_num = self.data.data_index
	self.is_top_three:SetValue(rank_num < 4)
	if rank_num < 4 then
		self.rank_icon:SetAsset(ResPath.GetKFMiningRankIcon(rank_num))
	else
		self.rank:SetValue(rank_num)
	end
	self.player_name:SetValue(self.data.name)
	self.score:SetValue(self.data.score)
end

---------------提示获得面板
MiningTipsRewardView = MiningTipsRewardView or BaseClass(BaseCell)

function MiningTipsRewardView:__init()
	self.message = self:FindVariable("Message")
	self.show_event = self:FindVariable("ShowEvent") 		--是否显示盗贼时间
	self.bandit_text = self:FindVariable("BanditText")		--盗贼气泡框内容
	self.img_rarity = self:FindVariable("ImgRarity") 		--稀有度
	self.show_rarity = self:FindVariable("ShowRarity") 		--是否显示稀有度
	self.show_bg = self:FindVariable("ShowBG") 				--是否显示稀有度
	self.target_obj = self:FindObj("TargetObj") 			--奖励物品移动目标位置
	self.reward_item = self:FindObj("RewardItem")

	self.show_mine_list = {}
	self.img_name_list = {}

	for i = 1, 2 do
		self.img_name_list[i] = self:FindVariable("ImgName_" .. i)
		self.show_mine_list[i] = self:FindVariable("ShowMine_" .. i)
	end


	self:ListenEvent("OnClickOkBtn", BindTool.Bind(self.CloseView, self))
	self.show_event:SetValue(false)
end

function MiningTipsRewardView:__delete()
	self:ClearGlobalTimer()
end

function MiningTipsRewardView:CloseView()
	KuaFuMiningCtrl.Instance:SetBoxVisable(false)
	self:ClearGlobalTimer()
end

function MiningTipsRewardView:OnFlush()
	--self.show_event:SetValue(false)
	self.show_bg:SetValue(true)
	local other_cfg = KuaFuMiningData.Instance:GetMiningOtherCfg()
	local resule_type = KuaFuMiningData.Instance:GetMiningResuleType()
	-- local item_name = ItemData.Instance:GetItemConfig(item.item_id)

	if resule_type == CROSS_MINING_EVENT_TYPE.CROSS_MINING_EVENT_TYPE_REWARD_MINE then
		self.show_rarity:SetValue(true)
		self:ReFreshObtainBox()
	elseif resule_type == CROSS_MINING_EVENT_TYPE.CROSS_MINING_EVENT_TYPE_ROBBER then
		self.show_rarity:SetValue(false)
		self:ReFreshBeStealeBox()
	end

	--if KuaFuMiningData.Instance:GetMiningIsAuto() then
	self:ClearGlobalTimer()

	if self.delay_time == nil then
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function ()
			self:CloseView()
		end, 1) -- other_cfg.close
	end
	--end
end

function MiningTipsRewardView:ReFreshObtainBox()
	local item = KuaFuMiningData.Instance:GetMiningObtainItem()
	local mine_cfg = KuaFuMiningData.Instance:GetMiningMineCfg()
	if item == nil or mine_cfg[item.item_id] == nil then 
		print_warning("item =", item, "mine_cfg[item.item_id] =", mine_cfg[item.item_id])
		return 
	end

	local bundle, asset = nil, nil
	local text = string.format(Language.KuaFuFMining.MineName, mine_cfg[item.item_id].name)
	self.message:SetValue(text)
	for k,v in pairs(self.show_mine_list) do
		if k == 1 then
			--矿石
			local target_obj = MainUICtrl.Instance.view:GetPackageBtn()
			bundle, asset = ResPath.GetKFMiningRes(mine_cfg[item.item_id].mine_type)
			TipsCtrl.Instance:OpenMoveImageView(bundle, asset, self.reward_item, self.target_obj, 1, true)
			--稀有度图片设置
			self.img_rarity:SetAsset(ResPath.GetKFMiningRarity(item.mining_area))
			--self.img_name_list[k]:SetAsset(bundle, asset)
			v:SetValue(false)
		else
			v:SetValue(false)
		end
	end
end

function MiningTipsRewardView:ReFreshBeStealeBox()
	local item = KuaFuMiningData.Instance:GetMiningObtainItem()
	local mine_cfg = KuaFuMiningData.Instance:GetMiningMineCfg()
	local steal_list = KuaFuMiningData.Instance:GetMiningBeStealedInfo()
	if steal_list and #steal_list == 0 then --没有东西被抢
		self.show_bg:SetValue(false)
		self.message:SetValue("") --Language.KuaFuFMining.NotGet
		for k,v in pairs(self.show_mine_list) do
			v:SetValue(false)
		end
		local other_cfg = KuaFuMiningData.Instance:GetMiningOtherCfg()
		if other_cfg then
			self:ShowBandit(other_cfg.bandit_text_1)
		end
		return
	end
	if item == nil or mine_cfg[item.item_id] == nil or steal_list == nil then 
		print_warning("item =", item, "mine_cfg[item.item_id] =", mine_cfg[item.item_id], "steal_list =", steal_list)
		return 
	end

	local bundle, asset = nil, nil
	-- local text = string.format(Language.KuaFuFMining.MineRobber, mine_cfg[item.item_id].name)
	-- self.message:SetValue(text)

	local name_tb = {}
	for k,v in pairs(steal_list) do
		bundle, asset = ResPath.GetKFMiningRes(mine_cfg[v.mining_type].mine_type)
		self.img_name_list[k]:SetAsset(bundle, asset)
		self.show_mine_list[k]:SetValue(true)
		table.insert(name_tb, mine_cfg[v.mining_type].name)
	end
	
	local text = self:GetMineralNameTextByNameTab(name_tb)
	local bandit_text_1 = string.format(Language.KuaFuFMining.MineRobber, text) 			--奖励面板被抢文本
	self.message:SetValue(bandit_text_1) 

	local bandit_text_2 = string.format(KuaFuMiningData.Instance:GetBanditText(), text) 	--强盗气泡框文本
	self:ShowBandit(bandit_text_2)

	for i = 1, 2 do
		if steal_list[i] == nil then
			self.show_mine_list[i]:SetValue(false)
		end
	end
end

--显示强盗
function MiningTipsRewardView:ShowBandit(bandit_text)
	self.bandit_text:SetValue(bandit_text)
	self.show_event:SetValue(true)
	GlobalTimerQuest:CancelQuest(self.event_timer)
	self.event_timer = GlobalTimerQuest:AddDelayTimer(function()
 		self.show_event:SetValue(false)
 	end, 8)
end

function MiningTipsRewardView:ClearGlobalTimer()
	if nil ~= self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

-- 根据被抢矿石名字列表，去掉重复之后，返回一个字符串
function MiningTipsRewardView:GetMineralNameTextByNameTab(name_tb)
	local neaten_name_tb = {}
	for k,v in pairs(name_tb) do
		local is_repeat = false 					--当前矿石是否是重复的
		for i,v2 in ipairs(neaten_name_tb) do
			if v2.name == v then
				neaten_name_tb[i].num = neaten_name_tb[i].num + 1
				is_repeat = true
			end
		end
		if not is_repeat then 						--如果名字没有重复，则添加到表里
			local info = {name = v, num = 1}
			table.insert(neaten_name_tb, info)
		end
	end
	local result_text = ""
	for i,v in ipairs(neaten_name_tb) do
		if i==1 then
			result_text = v.name
			if v.num > 1 then
				result_text = result_text .. "X" .. v.num
			end
		else
			result_text = result_text .. "、" .. v.name
			if v.num > 1 then
				result_text = result_text .. "X" .. v.num
			end
		end
	end
	return result_text
end