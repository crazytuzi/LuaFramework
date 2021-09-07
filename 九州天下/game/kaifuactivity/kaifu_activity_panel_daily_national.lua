KaifuActivityPanelDailyNational = KaifuActivityPanelDailyNational or BaseClass(BaseRender)

function KaifuActivityPanelDailyNational:__init(instance)
	self.panel_list = {}
end

function KaifuActivityPanelDailyNational:__delete()
	for k, v in pairs(self.panel_list) do
		v:DeleteMe()
		v = nil
	end
	self.panel_list = {}
end

function KaifuActivityPanelDailyNational:LoadCallBack()
	self.panel_obj_list = {}

	self.activity_title = self:FindVariable("Title")
	self.activity_explain = self:FindVariable("Explain")
	self.time_desc = self:FindVariable("TimeDesc")

	--活动面板
	self.panel_obj_list = {
		[0] = self:FindObj("YuanSuZhanChang"),
		[1] = self:FindObj("QiangGuoWang"),
		[2] = self:FindObj("QiangHuangDi"),
	}
	self.panel_list = {
		[0] = ElementBattleground.New(self.panel_obj_list[0]),
		[1] = GrabKing.New(self.panel_obj_list[1]),
		[2] = GrabEmperor.New(self.panel_obj_list[2]),
	}
end

function KaifuActivityPanelDailyNational:SetCurTyoe(cur_type)
	self.cur_type = cur_type
end

function KaifuActivityPanelDailyNational:OnFlush()
	self:FlushCurNationalInfo()
	self:FlushPanel()

	local info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAILY_NATION_WAR)
	self.time_desc:SetValue(string.format(Language.DailyNational.TimeDesc, os.date('%Y年%m月%d日20时', os.time())))
end

--显示当日国事信息
function KaifuActivityPanelDailyNational:FlushCurNationalInfo()
	if KaifuActivityData.Instance:GetShowCurNationalInfo() then
		self.activity_title:SetValue(KaifuActivityData.Instance:GetShowCurNationalInfo().name)
		self.activity_explain:SetValue(KaifuActivityData.Instance:GetShowCurNationalInfo().explain)
	end
end

--显示当日国事prefab
function KaifuActivityPanelDailyNational:FlushPanel()
	local panel_index = KaifuActivityData.Instance:GetTodayNationalType()
	for k, v in pairs(self.panel_obj_list) do
		v:SetActive(false)
		if panel_index and panel_index == k then
			v:SetActive(true)
		end
	end
	--刷新prefab
	if self.panel_list[panel_index] then
		--self.panel_list[panel_index]:Flush(self.cur_type)
		self.panel_list[panel_index]:Flush()
	end
end

--------------------------------------------------------------------------------------
--元素战场
ElementBattleground = ElementBattleground or BaseClass(BaseRender)

function ElementBattleground:__init(instance)
	--奖励创建
	self.cell_list = {}	
	self.total_reward_list = self:FindObj("TotalRewardItemList")
	self.list_view_delegate = self.total_reward_list.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function ElementBattleground:__delete()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.cell_list = {}
end

function ElementBattleground:OnFlush()
	if self.total_reward_list.scroller.isActiveAndEnabled then
		self.total_reward_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

--单条奖励创建
function ElementBattleground:RefreshView(cell,data_index)
	data_index = data_index + 1

	local element_battle_item_cell = self.cell_list[cell]
	if element_battle_item_cell == nil then
		element_battle_item_cell = NationalAffairsRankRewardCell.New(cell.gameObject,data_index)  
		self.cell_list[cell] = element_battle_item_cell
	end
	element_battle_item_cell:SetIndex(data_index)
	--给item赋值
	if KaifuActivityData.Instance:GetQunXianLunDouReward() then
		local data = KaifuActivityData.Instance:GetQunXianLunDouReward()
		element_battle_item_cell:SetData(data[data_index]) --调用Onflush
	end
end

--BossItem创建的条数
function ElementBattleground:GetNumberOfCells()
	return #KaifuActivityData.Instance:GetQunXianLunDouReward()
end

--------------------------------------------------------------------------------------
--抢国王 grabking
GrabKing = GrabKing or BaseClass(BaseRender)

function GrabKing:__init(instance)
	self.reward_data = {}
	self.cur_index = 1

	--奖励创建
	self.cell_list = {}	
	self.total_reward_list = self:FindObj("TotalRewardItemList")
	self.list_view_delegate = self.total_reward_list.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function GrabKing:__delete()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.cell_list = {}
end

function GrabKing:OnFlush()
	if self.total_reward_list.scroller.isActiveAndEnabled then
		self.total_reward_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

--单条奖励创建
function GrabKing:RefreshView(cell,data_index)
	data_index = data_index + 1

	local grab_king_item_cell = self.cell_list[cell]
	if grab_king_item_cell == nil then
		grab_king_item_cell = NationalAffairsRankRewardCell.New(cell.gameObject,data_index)  
		self.cell_list[cell] = grab_king_item_cell
	end
	grab_king_item_cell:SetIndex(data_index)
	local data = KaifuActivityData.Instance:GetGuildBattleReward()
	grab_king_item_cell:SetData(data[data_index]) --调用Onflush
end

--BossItem创建的条数
function GrabKing:GetNumberOfCells()
	return #KaifuActivityData.Instance:GetGuildBattleReward() or 0
end

--------------------------------------------------------------------------------------
--抢皇帝 GrabEmperor
GrabEmperor = GrabEmperor or BaseClass(BaseRender)

function GrabEmperor:__init(instance)
	self.cur_index = 1
	self.reward_data = {}

	--奖励创建
	self.cell_list = {}
	self.total_reward_list = self:FindObj("TotalRewardItemList")
	self.list_view_delegate = self.total_reward_list.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	for i = 1, 2 do
		self:ListenEvent("OnClick"..i, BindTool.Bind(self.OnClick, self, i))
	end
end

function GrabEmperor:__delete()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.cell_list = {}
end

function GrabEmperor:OnFlush()
	if self.total_reward_list.scroller.isActiveAndEnabled then
		self.total_reward_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function GrabEmperor:OnClick(index)
	self.cur_index = index
	self.total_reward_list.scroller:RefreshAndReloadActiveCellViews(true)
end

--单条奖励创建
function GrabEmperor:RefreshView(cell,data_index)
	data_index = data_index + 1
	local reward_info = {}

	local grab_emperor_item_cell = self.cell_list[cell]
	if grab_emperor_item_cell == nil then
		grab_emperor_item_cell = NationalAffairsRankRewardCell.New(cell.gameObject,data_index)  
		grab_emperor_item_cell.parent_view = self
		self.cell_list[cell] = grab_emperor_item_cell
	end
	grab_emperor_item_cell:SetIndex(data_index)

	local data = KaifuActivityData.Instance:GetGrabEmperorRewardBySide(self.cur_index)
	grab_emperor_item_cell:SetData(data[data_index])
end

--BossItem创建的条数
function GrabEmperor:GetNumberOfCells()
	return #KaifuActivityData.Instance:GetGrabEmperorRewardBySide(self.cur_index)
end

function GrabEmperor:GetCurIndex()
	return self.cur_index
end

---------------------------------------------------------------------------------------
--每日国事奖励cell
NationalAffairsRankRewardCell = NationalAffairsRankRewardCell or BaseClass(BaseCell)
function NationalAffairsRankRewardCell:__init(instance) --根据排名来获取格子里面该显示什么
	self.get_rewar_btn = self:FindObj("GetRewardBtn")
	self.ranking_title = self:FindVariable("RankingTitle")
	self.btn_text = self:FindVariable("BtnText")
	self:ListenEvent("OnClickGetReward", BindTool.Bind(self.OnClickGetReward, self))
end

function NationalAffairsRankRewardCell:__delete()
	self.parent_view = nil
end

function NationalAffairsRankRewardCell:LoadCallBack()
	self.rank_reward_list = {}
	for i = 1, 5 do
		self.rank_reward_list[i] = ItemCell.New()
		self.rank_reward_list[i]:SetInstanceParent(self:FindObj("RewardItemCell" .. i))
		self.rank_reward_list[i]:SetActive(false) 
	end
	self:Flush() 
end

function NationalAffairsRankRewardCell:ReleaseCallBack()
	for _,v in pairs(self.rank_reward_list) do
		v:DeleteMe()
		v = nil
	end
	self.rank_reward_list = {}
 end

function NationalAffairsRankRewardCell:OnFlush()
	if nil == self.data then return end

	local daily_national_info =  KaifuActivityData.Instance:GetDailyNationalInfo()
	local camp_info = PlayerData.Instance.role_vo.camp 
	local cur_national = KaifuActivityData.Instance:GetTodayNationalType()
	local cur_daily_national_info = daily_national_info[cur_national]

	--放入奖励
	if self.data.reward_item and self.data.reward_item.num > 1 then
		gift_reward = self.data.reward_item
		self.rank_reward_list[1]:SetData(gift_reward)
		self.rank_reward_list[1]:SetActive(true)
	else
		local gift_list = ItemData.Instance:GetGiftItemList(self.data.reward_item and self.data.reward_item.item_id or 0)
		for k,v in pairs(gift_list) do
			if v then
				self.rank_reward_list[k]:SetData(v)
				self.rank_reward_list[k]:SetActive(true)
			else
				self.rank_reward_list[k]:SetActive(false) 
			end
		end
	end

	self.get_rewar_btn.button.interactable = false
	self.btn_text:SetValue(Language.Common.LingQu)
	--设置按钮可领取状态
	if self.data.rank_mix and self.data.rank_max  then
		if cur_daily_national_info.param_1 >= self.data.rank_mix and cur_daily_national_info.param_1 <= self.data.rank_max then
			self.get_rewar_btn.button.interactable = true
			if cur_daily_national_info.is_fetch == 1 then
				self.btn_text:SetValue(Language.Common.YiLingQu)
				self.get_rewar_btn.button.interactable = false	
			else
				self.btn_text:SetValue(Language.Common.LingQu)
			end
		else
			self.get_rewar_btn.button.interactable = false	
			self.btn_text:SetValue(Language.Common.LingQu)
		end
	else
		if cur_daily_national_info.param_2 == self.parent_view:GetCurIndex() then
			if cur_daily_national_info.param_1 == self.data.post then
				self.get_rewar_btn.button.interactable = true
				if cur_daily_national_info.is_fetch == 1 then
					self.btn_text:SetValue(Language.Common.YiLingQu)
					self.get_rewar_btn.button.interactable = false	
				else
					self.btn_text:SetValue(Language.Common.LingQu)
				end
			end
		else
			self.get_rewar_btn.button.interactable = false	
			self.btn_text:SetValue(Language.Common.LingQu)
		end
	end
	
	--抢皇帝名次
	if self.data.post then
		self.ranking_title:SetValue(Language.Convene.Post[1][self.index])
		return
	end
	--抢国王、元素战场排名
	if self.data.rank and self.data.rank_mix and self.data.rank_max then
		if self.data.rank_mix == self.data.rank_max then
			self.ranking_title:SetValue(string.format(Language.DailyNational.RankDesc1, self.data.rank_mix))
		else
			self.ranking_title:SetValue(string.format(Language.DailyNational.RankDesc, self.data.rank_mix, self.data.rank_max))
		end
		return
	end
end

--点击领取奖励
function NationalAffairsRankRewardCell:OnClickGetReward()
	local cur_national = KaifuActivityData.Instance:GetTodayNationalType()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAILY_NATION_WAR,RA_DAILY_NATION_WAR_REQ_TYPE.FETCH_REWARD, cur_national)
end