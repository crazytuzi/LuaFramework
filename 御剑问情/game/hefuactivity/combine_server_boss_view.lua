CombineServerBossView = CombineServerBossView or BaseClass(BaseView)

function CombineServerBossView:__init()
	self.ui_config = {"uis/views/hefuactivity_prefab","CombineServerBossListView"}
	self.active_close = false
	self.click_flag = 0
	self.view_layer = UiLayer.MainUIHigh
	self.last_remind_time = 0
end

function CombineServerBossView:ReleaseCallBack()
	if self.boss_panel then
		self.boss_panel:DeleteMe()
		self.boss_panel = nil
	end

	if self.person_info then
		self.person_info:DeleteMe()
		self.person_info = nil
	end

	-- 清理变量和对象
	self.boss_btn = nil
	self.track_info = nil
	self.show_panel = nil
	self.guild_info = nil
	self.show_boss_tab_hl = nil
	self.show_team_person_hl = nil
	self.show_team_guild_hl = nil
	self.person_btn = nil
	self.guild_btn = nil
	self.limit_bos_num = nil
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.show_or_hide_other_button_1 ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button_1)
		self.show_or_hide_other_button_1 = nil
	end

end

function CombineServerBossView:LoadCallBack()
	self.boss_panel = BossListInfo.New(self:FindObj("BossPanel"))
	self.person_info = PersonRankInfo.New(self:FindObj("PersonInfoPanel"))
	self.guild_info = GuildRankInfo.New(self:FindObj("GuildInfoPanel"))
	self.boss_btn = self:FindObj("boss_btn")
	self.person_btn = self:FindObj("person_btn")
	self.guild_btn = self:FindObj("guild_btn")
	self.track_info = self:FindObj("track_info")
	self.show_panel = self:FindVariable("ShowPanel")
	self.show_boss_tab_hl = self:FindVariable("show_boss_tab_hl")
	self.show_team_person_hl = self:FindVariable("show_team_person_hl")
	self.show_team_guild_hl = self:FindVariable("show_team_guild_hl")
	self.limit_bos_num = self:FindVariable("limit_bos_num")

	self:ListenEvent("click_person", BindTool.Bind(self.ClickPerson, self))
	self:ListenEvent("click_boss", BindTool.Bind(self.ClickBoss, self))
	self:ListenEvent("click_guild", BindTool.Bind(self.ClickGuild, self))

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))

	self.show_or_hide_other_button_1 = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.PortraitToggleChange, self))
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)

	self:Flush()
end

function CombineServerBossView:ClickPerson()
	if self.click_flag ~= 2 then
		self.click_flag = 2
		self:Flush("person_type")
		self:FlushTabHl(2)
	end
end

function CombineServerBossView:ClickGuild()
	if self.click_flag ~= 3 then
		self.click_flag = 3
		self:Flush("guild_type")
		self:FlushTabHl(3)
	end
end

function CombineServerBossView:ClickBoss()
	if self.click_flag ~= 1 then
		self.click_flag = 1
		self:Flush("boss_type")
		self:FlushTabHl(1)
	end
end

function CombineServerBossView:ClickIcon()
end

function CombineServerBossView:CloseTips()
end

function CombineServerBossView:FlushTabHl(show_boss)
	self.show_boss_tab_hl:SetValue(show_boss ~= 2 and show_boss ~= 3)
	self.show_team_person_hl:SetValue(show_boss ~= 1 and show_boss ~= 3)
	self.show_team_guild_hl:SetValue(show_boss ~= 1 and show_boss ~= 2)
	self.click_flag = show_boss
end

function CombineServerBossView:OpenCallBack()
	self.boss_panel:Flush()
	self:Flush("open_flush")
	self:Flush("team_type")

end

function CombineServerBossView:CloseCallBack()

	if self.root_node.gameObject.activeSelf and self.track_info.gameObject.activeSelf then
		self.boss_btn.toggle.isOn = true
		self:FlushTabHl(true)
	end
	self.click_flag = 0

end

function CombineServerBossView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush()
	end
end

function CombineServerBossView:PortraitToggleChange(state)
	if state then
		if self.click_flag > 0 then
			if self.click_flag == 1 then
				self:Flush("boss_type")
			elseif self.click_flag == 2 then
				self:Flush("person_type")
			elseif self.click_flag == 3 then
				self:Flush("guild_type")
			end
			self:FlushTabHl(self.click_flag)
		else
			self:Flush("boss_type")
			self:FlushTabHl(1)
		end
	end
end

function CombineServerBossView:OnFlush(param_t)
	if self.click_flag == 1 then
		self.boss_panel:Flush()
	elseif self.click_flag == 2 then
		self.person_info:Flush()
	elseif self.click_flag == 3 then
		self.guild_info:Flush()
	end
	self.boss_panel:SetCurIndex(0)
	for k, _ in pairs(param_t) do
		if k == "boss_type" then
			self.boss_panel:Flush()
		elseif k == "person_type" then
			self.person_info:Flush()
		elseif k == "guild_type" then
			self.guild_info:Flush()
		elseif k == "open_flush" then
			self.boss_btn.toggle.isOn = true
			self:FlushTabHl(1)
		else
			self.boss_panel:Flush()
		end
	end

	self.limit_bos_num:SetValue(HefuActivityData.Instance:GetAcquisitionsNum())
end

function CombineServerBossView:SwitchButtonState(enable)
	if self.show_panel then
		self.show_panel:SetValue(enable)
	end
	if self.shrink_button_toggle and self:IsOpen() then
		self.shrink_button_toggle.isOn = not enable
	end
end


------------------ BossListInfo -------------
BossListInfo = BossListInfo or BaseClass(BaseRender)
function BossListInfo:__init()
	-- 获取控件
	self.data_list = HefuActivityData.Instance:GetAllCombineBossList()
	self.list_view = self:FindObj("TaskList")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.item_t= {}
	self.cur_index = 0
	self.list_view.scroller:ReloadData(0)
end

function BossListInfo:__delete()
	for _, v in pairs(self.item_t) do
		v:DeleteMe()
	end

	self.item_t= {}
end

function BossListInfo:BagGetNumberOfCells()
	-- local data_list = self:GetDataList() or {}
	return #self.data_list
end

function BossListInfo:BagRefreshCell(cell, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = HeFuBossItem.New(cell.gameObject, self)
		self.item_t[cell] = item
	end

	-- local data_list = self:GetDataList() or {}
	if self.data_list[cell_index + 1] then
		item:SetData(self.data_list[cell_index + 1])
	end
	item:SetItemIndex(cell_index + 1)
	item:FlushHl()
end

function BossListInfo:GetDataList()
	return HefuActivityData.Instance:GetAllCombineBossList()
end

function BossListInfo:SetCurIndex(index)
	self.cur_index = index
end

function BossListInfo:GetCurIndex()
	return self.cur_index
end

function BossListInfo:OnFlush()
	self.data_list = HefuActivityData.Instance:GetAllCombineBossList()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function BossListInfo:FlushAllHl()
	for _, v in pairs(self.item_t) do
		v:FlushHl()
	end
end
--------------

------------------HeFuBossItem-------------------------------------
------------------------------------------------------------------------
HeFuBossItem = HeFuBossItem or BaseClass(BaseRender)

function HeFuBossItem:__init(instance, parent)
	self.parent = parent
	self.desc = self:FindVariable("Desc")
	self.name = self:FindVariable("Name")
	self.time = self:FindVariable("Time")
	self.show_hl = self:FindVariable("show_hl")
	self.time_color = self:FindVariable("TimeColor")
	self.level_text = self:FindVariable("Level")
	self.index = 0
	self.next_refresh_time = 0
	self:ListenEvent("Click", BindTool.Bind(self.ClickKill, self))
end

function HeFuBossItem:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function HeFuBossItem:ClickKill(is_click)
	if self.data == nil then return end
	if self.data.boss_pos_x < 1 and self.data.boss_pos_y < 1 then return end
	self.parent:SetCurIndex(self.index)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(self.scene_id, self.data.boss_pos_x, self.data.boss_pos_y, 10, 10)
	self.parent:FlushAllHl()
	return
end

function HeFuBossItem:SetData(data)
	self.data = data
	self.scene_id = data.scene_id
	self:Flush()
end

function HeFuBossItem:SetItemIndex(index)
	self.index = index
end

function HeFuBossItem:Flush()
	if nil == self.data then
		self.root_node:SetActive(false)
		return
	else
		self.root_node:SetActive(true)
	end

	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.boss_id]
	if monster_cfg then
		self.name:SetValue(monster_cfg.name)
		self.level_text:SetValue(monster_cfg.level)
	end

	if self.data then
		self.time_color:SetValue(self.data.next_refresh_time == 0 and TEXT_COLOR.GREEN_3 or "#ff0000ff")
		self.next_refresh_time = self.data.next_refresh_time
		if self.data.next_refresh_time == 0 then
			if self.time_coundown then
				GlobalTimerQuest:CancelQuest(self.time_coundown)
				self.time_coundown = nil
				self.time:SetValue(Language.Dungeon.CanKill)
			end
			self.time:SetValue(Language.Dungeon.CanKill)
		elseif self.data.next_refresh_time == 1 then
			self.time:SetValue(Language.Boss.DaiShuaXin)
		else
			if self.time_coundown == nil then
				self.time_coundown = GlobalTimerQuest:AddTimesTimer(
					BindTool.Bind(self.OnBossUpdate, self), 1, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
			end
			self:OnBossUpdate()
		end
	else
		self.time_color:SetValue(TEXT_COLOR.GREEN_3)
		if self.time_coundown then
			GlobalTimerQuest:CancelQuest(self.time_coundown)
			self.time_coundown = nil
		end
		self.time:SetValue(Language.Dungeon.CanKill)
	end
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(self.scene_id)
	if scene_cfg then
		if self.data.boss_pos_x > 0 and self.data.boss_pos_y > 0 then
			self.desc:SetValue(scene_cfg.name .. "(" .. self.data.boss_pos_x .. "," .. self.data.boss_pos_y .. ")")
		else
			self.desc:SetValue(scene_cfg.name .. "<color='#fb1212ff'> 待刷新</color>")
		end
	end

	self:FlushHl()
end

function HeFuBossItem:FlushHl()
	if self.show_hl then
		self.show_hl:SetValue(self.parent:GetCurIndex() == self.index)
	end
end

function HeFuBossItem:OnBossUpdate()
	local time = math.max(0, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.time:SetValue(ToColorStr(Language.Dungeon.CanKill, TEXT_COLOR.GREEN))
	else
		self.time:SetValue(ToColorStr(TimeUtil.FormatSecond(time), TEXT_COLOR.RED))
	end
end

---------------------
PersonRankInfo = PersonRankInfo or BaseClass(BaseRender)

function PersonRankInfo:__init()
	self.item_cell_list = {}
	self.cell_list = {}
	for i = 1, 3 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self:FindObj("ItemCell"..i))
	end

	self.list_view_person = self:FindObj("list_view")
	local list_delegate = self.list_view_person.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfPersonCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshPersonCell, self)
	self.list_view_person.scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)
	self.person_rank_list = HefuActivityData.Instance:GetCombineServerBossPersonRank()

	self.rank_img_person = self:FindVariable("rank_img_person")
	self.kill_num_person = self:FindVariable("kill_num_person")
	self.rank_text_person = self:FindVariable("rank_text_person")
	self.name_text_person = self:FindVariable("name_text_person")
	self.show_img_person_1 = self:FindVariable("show_img_person_1")
	self.show_img_person_2 = self:FindVariable("show_img_person_2")
end

function PersonRankInfo:__delete()
	for i = 1, 3 do
		if self.item_cell_list[i] then
			self.item_cell_list[i]:DeleteMe()
		end
	end
	self.item_cell_list = nil
	self.list_view_person = nil
	self.rank_img_person = nil
	self.kill_num_person = nil
	self.rank_text_person = nil
	self.name_text_person = nil
	self.show_img_person_1 = nil
	self.show_img_person_2 = nil
end

function PersonRankInfo:GetNumberOfPersonCells()
	local num = HefuActivityData.Instance:GetCombineServerBossRankNum(self.person_rank_list)
	return num
end

function PersonRankInfo:RefreshPersonCell(cell, cell_index)
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = CombineServerBossRankItem.New(cell.gameObject,self)
		the_cell:SetToggleGroup(self.list_view_person.toggle_group)
		self.cell_list[cell] = the_cell
	end
	cell_index = cell_index + 1
	the_cell:SetIndex(cell_index, "person")
	the_cell:SetData(self.person_rank_list[cell_index])
	-- the_cell:SetHighLigh(cell_index == self.index and self.str == "person")
	the_cell:Flush()
	self.is_cell_active = true
end

function PersonRankInfo:ScrollerScrolledDelegate(go, param1, param2, param3)
	if self.is_cell_active and self.jump_flag == true then
		self:CheckToJump()
	end
end

function PersonRankInfo:OnFlush(param_t)
	self.person_rank_list = HefuActivityData.Instance:GetCombineServerBossPersonRank()
	if self.list_view_person then
		self.list_view_person.scroller:ReloadData(0)
	end
	local item_list = HefuActivityData.Instance:GetCombineServerPersonItemList()
	for i = 1, 3 do
		self.item_cell_list[i]:SetData(item_list[i])
	end
	-- self:FlushSelfRank()
end

function PersonRankInfo:FlushSelfRank()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
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
		self.show_img_person_2:SetValue(true)
		self.rank_text_person:SetValue(Language.Common.NumToChs[1])
	end
end

function PersonRankInfo:SetCurIndex(index, str)
	self.index = index
	self.str = str
end

function PersonRankInfo:SetHighLighFalse()
	for k,v in pairs(self.cell_list) do
		v:SetHighLigh(false)
	end
end

-----------------
---------------------
GuildRankInfo = GuildRankInfo or BaseClass(BaseRender)

function GuildRankInfo:__init()
	self.item_cell_list = {}
	self.cell_list = {}
	for i = 1, 2 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self:FindObj("ItemCell"..i))
	end

	self.list_view_guild = self:FindObj("list_view")
	local list_delegate = self.list_view_guild.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfGuildCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshGuildCell, self)
	self.list_view_guild.scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)

	self.guild_rank_list = HefuActivityData.Instance:GetCombineServerBossGuildRank()

	self.name_text_guild = self:FindVariable("name_text_guild")
	self.kill_num_guild = self:FindVariable("kill_num_guild")
	self.show_img_guild_1 = self:FindVariable("show_img_guild_1")
	self.show_img_guild_2 = self:FindVariable("show_img_guild_2")
	self.rank_text_guild = self:FindVariable("rank_text_guild")
	self.rank_img_guild = self:FindVariable("rank_img_guild")
end

function GuildRankInfo:__delete()
	for i = 1, 2 do
		if self.item_cell_list[i] then
			self.item_cell_list[i]:DeleteMe()
		end
	end
	self.item_cell_list = nil
	self.name_text_guild = nil
	self.kill_num_guild = nil
	self.show_img_guild_1 = nil
	self.show_img_guild_2 = nil
	self.rank_text_guild = nil
	self.rank_img_guild = nil
end

function GuildRankInfo:GetNumberOfGuildCells()
	local num = HefuActivityData.Instance:GetCombineServerBossRankNum(self.guild_rank_list)
	return num
end

function GuildRankInfo:RefreshGuildCell(cell, cell_index)
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = CombineServerBossRankItem.New(cell.gameObject,self)
		the_cell:SetToggleGroup(self.list_view_guild.toggle_group)
		self.cell_list[cell] = the_cell
	end
	cell_index = cell_index + 1
	the_cell:SetIndex(cell_index, "guild")
	the_cell:SetData(self.guild_rank_list[cell_index])
	-- the_cell:SetHighLigh(cell_index == self.index and self.str == "guild")
	the_cell:Flush()
	self.is_cell_active = true
end

function GuildRankInfo:ScrollerScrolledDelegate(go, param1, param2, param3)
	if self.is_cell_active and self.jump_flag == true then
		self:CheckToJump()
	end
end

function GuildRankInfo:OnFlush(param_t)
	self.guild_rank_list = HefuActivityData.Instance:GetCombineServerBossGuildRank()
	local item_list = HefuActivityData.Instance:GetCombineServerGuildItemList()
	if self.list_view_guild then
		self.list_view_guild.scroller:ReloadData(0)
	end

	for i = 1, 2 do
		self.item_cell_list[i]:SetData(item_list[i])
	end

	-- self:FlushSelfRank()
end

function GuildRankInfo:FlushSelfRank()
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
			self.rank_img_guild:SetAsset(ResPath.GetRankIcon(rank))
		elseif 0 <= rank then
			self.rank_text_guild:SetValue(Language.Common.NumToChs[1])
		else
			self.rank_text_guild:SetValue(rank)
		end
		self.show_img_guild_1:SetValue(0 < rank and rank <= 3)
		self.show_img_guild_2:SetValue(not(0 < rank and rank <= 3))
	else
		self.show_img_guild_1:SetValue(false)
		self.show_img_guild_2:SetValue(true)
		self.rank_text_guild:SetValue(Language.Common.NumToChs[1])
	end
end

function GuildRankInfo:SetCurIndex(index, str)
	self.index = index
	self.str = str
end

function GuildRankInfo:SetHighLighFalse()
	for k,v in pairs(self.cell_list) do
		v:SetHighLigh(false)
	end
end

------
CombineServerBossRankItem = CombineServerBossRankItem  or BaseClass(BaseCell)

function CombineServerBossRankItem:__init(instance, parent)
	self.parent = parent
	self.rank = -1
	self.str = ""
	-- self:ListenEvent("Click",BindTool.Bind(self.OnItemClick, self))
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

function CombineServerBossRankItem:__delete()
	self.parent = nil
	self.show_img_list = nil
	self.rank_img = nil
	self.rank_text = nil
	self.rank = -1
	self.name_text = nil
	self.kill_num = nil
end

function CombineServerBossRankItem:OnFlush()
	self:FlushName()
end

function CombineServerBossRankItem:SetHighLigh(show_hl)
	self.show_hl:SetValue(show_hl)
end

function CombineServerBossRankItem:SetIndex(cell_index, str)
	self.rank = cell_index
	self.str = str
end

function CombineServerBossRankItem:SetData(data)
	self.data = data
end

function CombineServerBossRankItem:FlushName()
	if self.index == -1 or not self.data or self.data.name == "" then return end
	self.rank_text:SetValue(self.rank)
	self.name_text:SetValue(self.data.name)
	self.kill_num:SetValue(self.data.rank_value)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if self.str == "person" then
		self.show_hl:SetValue(main_role_vo.role_id == self.data.id)
	elseif self.str == "guild" then
		self.show_hl:SetValue(main_role_vo.guild_id == self.data.id)
	end
end

function CombineServerBossRankItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function CombineServerBossRankItem:OnItemClick(is_click)
	if is_click then
		self.parent:SetHighLighFalse()
		self.show_hl:SetValue(true)
		self.parent:SetCurIndex(self.rank, self.str)
	end
end