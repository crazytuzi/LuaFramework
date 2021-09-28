HeFuBossView = HeFuBossView or BaseClass(BaseRender)

local TOGGLE_NUM = 2

function HeFuBossView:__init(instance)
	self.toggle_list = {}
	self.cur_index = 0
	self:ListenEvent("OnClickTips", BindTool.Bind(self.OnClickTips, self))

	self.combine_boss = self:FindObj("BossInfo")
	self.combine_boss_info_view = HeFuBossInfoView.New(self.combine_boss)
	
	self.combine_rank = self:FindObj("RankInfo")
	self.combine_rank_info_view = HeFuBossRankView.New(self.combine_rank)

	self.red_point_list = {}
	for  i = 1, TOGGLE_NUM do
		self:ListenEvent("OnClickToggle"..i, BindTool.Bind(self.OnClickToggle, self, i))
		self.toggle_list[i] = self:FindObj("Toggle"..i).toggle
		self.red_point_list[i] = self:FindVariable("ShowRedPoint"..i)
	end
	self:OnClickToggle(1)
end

function HeFuBossView:__delete()
	self.combine_boss = nil 
	self.combine_boss_info_view = nil
	self.combine_rank = nil
	self.combine_rank_info_view = nil

	self.cur_index = 0
end

function HeFuBossView:OpenCallBack()
	self:OpenSelectView()
end

function HeFuBossView:OnClickToggle(index)
	self.cur_index = index - 1
	self:OpenSelectView()
end
function HeFuBossView:OnClickTips()
	TipsCtrl.Instance:ShowHelpTipView(230)
end

function HeFuBossView:OpenSelectView()
	-- if self.toggle_list then
	-- 	self:ShowOrHideTab()
	-- end
	if self.cur_index == 0 and self.combine_boss_info_view then
		self.combine_boss_info_view:OpenCallBack()
	elseif self.cur_index == 1 and self.combine_rank_info_view then
		self.combine_rank_info_view:OpenCallBack()
	end
	-- GlobalTimerQuest:AddDelayTimer(
	-- 	function ()
	-- 		self.toggle_list[self.cur_index + 1].toggle.isOn = true
	-- 		self:UpdataView()
	-- 	end, 0)
end

function HeFuBossView:UpdataView()
	if self.cur_index == 0 then
		self:FlushBossList()
	elseif self.cur_index == 1 then
		self:FlushBossRank()
	end
end

function HeFuBossView:Flush()
	if self.cur_index == 0 and self.combine_boss_info_view then
		self.combine_boss_info_view:Flush()
	elseif self.cur_index == 1 and self.combine_rank_info_view then
		self.combine_rank_info_view:Flush()
	end
end

----------------------
HeFuBossInfoView = HeFuBossInfoView or BaseClass(BaseRender)

function HeFuBossInfoView:__init(instance)
	self.red_point_list = {}
	self:ListenEvent("OnClickGoToBoss", BindTool.Bind(self.OnClickGoToBoss, self))

	self.reward_item_list = {}

	
	self.boss_item_cell = ConbineServerBossCell.New(self:FindObj("BossItemCell"))

	self.show_get_reward_btn = self:FindVariable("ShowGetBtn")
	self.show_effect = self:FindVariable("ShowEffect")

	self.boss_list = {}
	self.cur_index = 0
	self:InitShow()
end

function HeFuBossInfoView:__delete()

	for k, v in pairs(self.reward_item_list) do
		v:DeleteMe()
	end
	self.reward_item_list = {}

	self.boss_list = {}
	self.cur_index = nil

	if self.boss_item_cell then
		self.boss_item_cell:DeleteMe()
		self.boss_item_cell = nil
	end
end
function HeFuBossInfoView:OpenCallBack()
	self:Flush()
end
local boss_item_num = 5
function HeFuBossInfoView:InitShow()
	self.reward_item_list = {}
	for i = 1, boss_item_num do
		self.reward_item_list[i] = ItemCell.New()
		self.reward_item_list[i]:SetInstanceParent(self:FindObj("ItemCell"..i))
	end

	-- for i = 1, 5 do
	-- 	self.boss_item_cell:ListenClick(i, BindTool.Bind(self.OnClickBossItem, self, i))
	-- end
end

function HeFuBossInfoView:FlushBossList()
	self.boss_list = HefuActivityData.Instance:GetCombineServerBossCfg()
	self.boss_item_cell:SetData(self.boss_list)
	self:SetRewardItemData()
end

function HeFuBossInfoView:OnClickBossItem(index)
	if not index then return end

	for k, v in pairs(self.boss_list) do
		if k == index then
			TipsCtrl.Instance:ShowBossInfoView(v.id)
			return
		end
	end
end

function HeFuBossInfoView:SetRewardItemData()
	local item_list = HefuActivityData.Instance:GetCombineServerBossItemList()
	for i = 1, boss_item_num do
		self.reward_item_list[i]:SetData(item_list[i])
	end
end

function HeFuBossInfoView:OnClickGoToBoss()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_ENTER)
end

function HeFuBossInfoView:OnFlush()
	self:FlushBossList()
end


ConbineServerBossCell = ConbineServerBossCell or BaseClass(BaseRender)

function ConbineServerBossCell:__init(instance)
	self.icon_list = {}
	self.name_list = {}
	self.show_had_kill = {}
	self.time_list = {}
	self.count_down_list = {}
	for i = 1, 5 do
		self.icon_list[i] = self:FindVariable("Icon"..i)
		self.name_list[i] = self:FindVariable("Name"..i)
		self.show_had_kill[i] = self:FindVariable("ShowHadKill"..i)
		self.time_list[i] = self:FindVariable("Time"..i)
	end
end

function ConbineServerBossCell:__delete()
	self.icon_list = nil
	self.name_list = nil
	self.show_had_kill = nil
	self.time_list = nil
	for k,v in pairs(self.count_down_list) do
		if self.count_down_list[k] then
			CountDown.Instance:RemoveCountDown(self.count_down_list[k])
		end
	end
	self.count_down_list = nil
end

function ConbineServerBossCell:SetData(data_list)
	if not data_list then return end
	local refresh_state = HefuActivityData.Instance:GetRefreshState()
	local other_cfg = HefuActivityData.Instance:GetCombineServerBossConfig().other[1] or {}

	for k, v in pairs(data_list) do
		if type(v) == "table" then
			local bundle, asset = ResPath.GetBossIcon(v.headid)
			self.icon_list[k]:SetAsset(bundle, asset)
			self.name_list[k]:SetValue(v.name)
			self.show_had_kill[k]:SetValue(false)
			local str = v.next_refresh_time == 0 and Language.Boss.HasRefresh or TimeUtil.FormatSecond(v.next_refresh_time - TimeCtrl.Instance:GetServerTime())
			if refresh_state == 1 then
				str = string.format(Language.Boss.LimitTimeFlush, TimeUtil.FormatSecond(other_cfg.great_boss_end_time))
			end
			local color = v.next_refresh_time == 0 and "#00EA00FF" or COLOR.RED
			self.time_list[k]:SetValue("<color=" .. color ..">" .. str .. "</color>")

			if self.count_down_list[k] then
				CountDown.Instance:RemoveCountDown(self.count_down_list[k])
				self.count_down_list[k] = nil
			end
			if self.count_down_list[k] == nil and refresh_state == 0 and v.next_refresh_time - TimeCtrl.Instance:GetServerTime() > 0 then
				local total_time = v.next_refresh_time - TimeCtrl.Instance:GetServerTime()
				self.count_down_list[k] = CountDown.Instance:AddCountDown(total_time, 1, BindTool.Bind(self.SetTime, self, k))
			end
		end
	end

end

function ConbineServerBossCell:SetTime(k, elapse_time, total_time)
	if elapse_time >= total_time then
		CountDown.Instance:RemoveCountDown(self.count_down_list[k])
		self.time_list[k]:SetValue("<color=#00EA00FF>" .. Language.Boss.HasRefresh .. "</color>")
		return
	end
	local left_time = math.floor(total_time - elapse_time)
	local time_str = TimeUtil.FormatSecond(left_time)
	self.time_list[k]:SetValue("<color=#fb1212ff>" .. time_str .. "</color>")
end

function ConbineServerBossCell:ListenClick(i, handler)
	self:ClearEvent("Click"..i)
	self:ListenEvent("Click"..i, handler)
end

--------------------------rank------------
HeFuBossRankView = HeFuBossRankView or BaseClass(BaseRender)
local rank_gift_num = 5
function HeFuBossRankView:__init(instance)
	self.cell_list = {}
	self.index = 0
	self.str = ""
	self.list_view_person = self:FindObj("PersonList")
	self.list_view_group = self:FindObj("GroupList")

	local list_delegate = self.list_view_person.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfPersonCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshPersonCell, self)
	self.list_view_person.scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)

	local list_delegate = self.list_view_group.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfPersonCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshGroupCell, self)
	self.list_view_group.scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)

	self.reward_item_list = {}
	for i = 1, rank_gift_num do
		self.reward_item_list[i] = ItemCell.New()
		self.reward_item_list[i]:SetInstanceParent(self:FindObj("ItemCell"..i))
	end

	self.name_text_guild = self:FindVariable("name_text_guild")
	self.kill_num_guild = self:FindVariable("kill_num_guild")
	self.show_img_guild_1 = self:FindVariable("show_img_guild_1")
	self.show_img_guild_2 = self:FindVariable("show_img_guild_2")
	self.show_img_guild_3 = self:FindVariable("show_img_guild_3")
	self.rank_text_guild = self:FindVariable("rank_text_guild")
	self.rank_img_guild = self:FindVariable("rank_img_guild")
	
	self.rank_img_person = self:FindVariable("rank_img_person")
	self.kill_num_person = self:FindVariable("kill_num_person")
	self.rank_text_person = self:FindVariable("rank_text_person")
	self.name_text_person = self:FindVariable("name_text_person")
	self.show_img_person_1 = self:FindVariable("show_img_person_1")
	self.show_img_person_2 = self:FindVariable("show_img_person_2")
	self.show_img_person_3 = self:FindVariable("show_img_person_3")

	self.person_rank_list = HefuActivityData.Instance:GetCombineServerBossPersonRank()
	self.guild_rank = HefuActivityData.Instance:GetCombineServerBossGuildRank()
	
	self:SetRewardItemData()
end

function HeFuBossRankView:__delete()
	self.list_view_person = nil
	self.list_view_group = nil
	self.person_rank_list = nil
	self.guild_rank = nil

	self.name_text_guild = nil
	self.kill_num_guild = nil
	self.show_img_guild_1 = nil
	self.show_img_guild_2 = nil
	self.show_img_guild_3 = nil
	self.rank_text_guild = nil
	self.rank_img_guild = nil
	
	self.rank_img_person = nil
	self.kill_num_person = nil
	self.rank_text_person = nil
	self.name_text_person = nil
	self.show_img_person_1 = nil
	self.show_img_person_2 = nil
	self.show_img_person_3 = nil

	for k,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	for k,v in pairs(self.reward_item_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.reward_item_list = nil
end
function HeFuBossRankView:OpenCallBack()
	self:Flush()
end

local rank_item_num = 10
function HeFuBossRankView:GetNumberOfPersonCells()
	return rank_item_num
end

function HeFuBossRankView:RefreshPersonCell(cell, cell_index)
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = CombineServerRankItem.New(cell.gameObject,self)
		the_cell:SetToggleGroup(self.list_view_person.toggle_group)
		self.cell_list[cell] = the_cell
	end
	cell_index = cell_index + 1
	the_cell:SetIndex(cell_index, "person")
	the_cell:SetData(self.person_rank_list[cell_index])
	the_cell:SetHighLigh(cell_index == self.index and self.str == "person")
	the_cell:Flush()
	self.is_cell_active = true
end

function HeFuBossRankView:ScrollerScrolledDelegate(go, param1, param2, param3)
	if self.is_cell_active and self.jump_flag == true then
		self:CheckToJump()
	end
end

function HeFuBossRankView:FlushSelfRank()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local guild_id = main_role_vo.guild_id

	self.name_text_guild:SetValue(guild_id > 0 and main_role_vo.guild_name or Language.Common.No)
	self.kill_num_guild:SetValue(HefuActivityData.Instance:GetCombineServerBossGuildKill())
	if guild_id > 0 then
		local rank = 0
		for k,v in pairs(self.guild_rank) do
			if v and v.id == main_role_vo.guild_id then
				rank = k
				break
			end
		end
		if 0 < rank and rank <= 3 then
			self.show_img_guild_1:SetValue(true)
			self.show_img_guild_2:SetValue(false)
			self.rank_img_guild:SetAsset(ResPath.GetRankIcon(rank))
		elseif 0 <= rank then
			self.show_img_guild_1:SetValue(false)
			self.show_img_guild_2:SetValue(true)
			self.rank_text_guild:SetValue(Language.Common.NumToChs[1])
		else
			self.show_img_guild_1:SetValue(false)
			self.show_img_guild_2:SetValue(true)
			self.rank_text_guild:SetValue(rank)
		end
	else
		self.show_img_guild_1:SetValue(false)
		self.show_img_guild_2:SetValue(false)
		self.show_img_guild_3:SetValue(true)
		--self.rank_text_guild:SetValue(Language.Common.NumToChs[1])
	end

	self.name_text_person:SetValue(main_role_vo.name)
	self.kill_num_person:SetValue(HefuActivityData.Instance:GetCombineServerBossPersonKill())
	local person_rank = 0
	for k,v in pairs(self.person_rank_list) do
		if v and v.id == main_role_vo.role_id then
			person_rank = k
			break
		end
	end
	if 0 < person_rank and person_rank <= 3 then
		self.show_img_person_1:SetValue(true)
		self.show_img_person_2:SetValue(false)
		self.rank_img_person:SetAsset(ResPath.GetRankIcon(person_rank))
	elseif 3 < person_rank and person_rank <= 10 then
		self.show_img_person_1:SetValue(false)
		self.show_img_person_2:SetValue(true)
		self.rank_text_person:SetValue(person_rank)
	else
		self.show_img_person_1:SetValue(false)
		self.show_img_person_2:SetValue(false)
		self.show_img_person_3:SetValue(true)
		--self.rank_text_person:SetValue(Language.Common.NumToChs[1])
	end
end

function HeFuBossRankView:RefreshGroupCell(cell, cell_index)
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = CombineServerRankItem.New(cell.gameObject,self)
		the_cell:SetToggleGroup(self.list_view_group.toggle_group)
		self.cell_list[cell] = the_cell
	end
	cell_index = cell_index + 1
	the_cell:SetIndex(cell_index, "guild")

	the_cell:SetData(self.guild_rank[cell_index])
	the_cell:Flush()
	the_cell:SetHighLigh(cell_index == self.index and self.str == "guild")
	self.is_cell_active = true
end

function HeFuBossRankView:SetRewardItemData()
	local gift_list = HefuActivityData.Instance:GetCombineServerBossRankGiftList()
	for i = 1, rank_gift_num do
		self.reward_item_list[i]:SetData(gift_list[i])
	end
end

function HeFuBossRankView:OnFlush()
	self.person_rank_list = HefuActivityData.Instance:GetCombineServerBossPersonRank()
	self.guild_rank = HefuActivityData.Instance:GetCombineServerBossGuildRank()
	self:FlushSelfRank()
end

function HeFuBossRankView:SetCurIndex(index, str)
	self.index = index
	self.str = str
end

function HeFuBossRankView:SetHighLighFalse()
	for k,v in pairs(self.cell_list) do
		v:SetHighLigh(false)
	end
end

---------------
CombineServerRankItem = CombineServerRankItem  or BaseClass(BaseCell)

function CombineServerRankItem:__init(instance, parent)
	self.parent = parent
	self.rank = -1
	self.str = ""
	self:ListenEvent("Click",BindTool.Bind(self.OnItemClick, self))
	self.text = self:FindVariable("text")
	self.show_hl = self:FindVariable("show_hl")
	self.show_img_list = {}
	for i = 1, 2 do
		self.show_img_list[i] = self:FindVariable("show_img_"..i)
	end
	self.rank_img = self:FindVariable("rank_img")
	self.rank_text = self:FindVariable("rank_text")
	self.name_text = self:FindVariable("name_text")
	self.kill_num = self:FindVariable("kill_num")
	
end

function CombineServerRankItem:__delete()
	self.parent = nil
	self.show_img_list = nil
	self.rank_img = nil
	self.rank_text = nil
	self.rank = -1
	self.name_text = nil
	self.kill_num = nil
end

function CombineServerRankItem:OnFlush()
	self:FlushName()
end

function CombineServerRankItem:SetHighLigh(show_hl)
	self.show_hl:SetValue(show_hl)
end

function CombineServerRankItem:SetIndex(cell_index, str)
	self.rank = cell_index
	self.str = str
end

function CombineServerRankItem:SetData(data)
	self.data = data
end

function CombineServerRankItem:FlushName()
	if self.index == -1 or not self.data then return end

	if self.rank <= 3 then
		self.show_img_list[1]:SetValue(true)
		self.show_img_list[2]:SetValue(false)
		local bundle, asset = ResPath.GetRankIcon(self.rank)
		self.rank_img:SetAsset(bundle, asset)
	else
		self.rank_text:SetValue(self.rank)
		self.show_img_list[1]:SetValue(false)
		self.show_img_list[2]:SetValue(true)
	end
	self.name_text:SetValue(self.data.name ~= "" and self.data.name or Language.Competition.NoRank)
	self.kill_num:SetValue(self.data.rank_value)
end

function CombineServerRankItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function CombineServerRankItem:OnItemClick(is_click)
	if is_click then
		self.parent:SetHighLighFalse()
		self.show_hl:SetValue(true)
		self.parent:SetCurIndex(self.rank, self.str)
	end
end