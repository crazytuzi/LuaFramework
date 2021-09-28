GuildStationView = GuildStationView or BaseClass(BaseView)

local RewardCount = 3

function GuildStationView:__init()
	self.ui_config = {"uis/views/guildview_prefab","GuildStationView"}
	self.view_layer = UiLayer.MainUI

	self.last_chat_time = -10
	self.moneytree = false
end

function GuildStationView:__delete()

end

function GuildStationView:ReleaseCallBack()
	for k,v in pairs(self.item_cell) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.item_cell = {}
	if self.show_or_hide_other_button then
        GlobalEventSystem:UnBind(self.show_or_hide_other_button)
        self.show_or_hide_other_button = nil
    end

    self.boss_name = nil
	self.show_reward = nil
	self.notice = nil
	self.hide = nil
	self.no_call = nil
	self.exp = nil
	self.value = nil
	self.precent = nil
	self.showinfo = nil
	self.gathernum = nil
	self.treepercent = nil
	self.list_view = nil
	self.maturity_max = nil
	self.maturity_num = nil
	self.showtijiao = nil
end

function GuildStationView:LoadCallBack()
	self.item_cell = {}
	for i = 1, RewardCount do
		self.item_cell[i] = {}
		self.item_cell[i].obj = self:FindObj("ItemCell" .. i)
		self.item_cell[i].cell = ItemCell.New()
		self.item_cell[i].cell:SetInstanceParent(self.item_cell[i].obj)
		self.item_cell[i].cell:SetInteractable(false)
		if i > 1 then
			self.item_cell[i].obj:SetActive(false)
		end
	end
	self.boss_name = self:FindVariable("BossName")
	self.show_reward = self:FindVariable("ShowReward")
	self.notice = self:FindVariable("Notice")
	self.hide = self:FindVariable("Hide")
	self.no_call = self:FindVariable("NoCall")
	self.exp = self:FindVariable("Exp")
	self.value = self:FindVariable("Value")
	self.precent = self:FindVariable("Percent")
	self.showinfo = self:FindVariable("ShowInfo")
	self.gathernum = self:FindVariable("gathernum")
	self.treepercent = self:FindVariable("TreePercent")
	self.maturity_max = self:FindVariable("maturity_max")
	self.maturity_num = self:FindVariable("maturity_num")
	self.showtijiao = self:FindVariable("showtijiao")
	self.list_view = self:FindObj("ListView")
	self:ListenEvent("OnClickKill",
		BindTool.Bind(self.OnClickKill, self))
	self:ListenEvent("OnClickReminder",
		BindTool.Bind(self.OnClickReminder, self))
	self:ListenEvent("OnClickToTree",
		BindTool.Bind(self.OnClickToTree, self))
	self.precent:SetValue(1)
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
        BindTool.Bind(self.SwitchButtonState, self))

	self.cell_list = {}
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function GuildStationView:OpenCallBack()
	self:Flush()

	if MainUICtrl.Instance.view and MainUICtrl.Instance.view:IsLoaded() then
		local state = MainUICtrl.Instance.view.MenuIconToggle.isOn
		self.hide:SetValue(state or false)
	end

end

function GuildStationView:CloseCallBack()
    self:RemoveCountDown()
    GuildData.Instance:SendMoneyTreeState(false)
    self.moneytree = false
end

function GuildStationView:OnFlush()
	self.moneytree = GuildData.Instance:GetMoneyTreeState()
	self.showinfo:SetValue(false)
	if self.moneytree then
		self:FlushMoneyTree()
	end

	local boss_activity_info = GuildData.Instance:GetBossActivityInfo()
	if boss_activity_info then
		self.exp:SetValue(CommonDataManager.ConverNum(boss_activity_info.totem_exp))
		local boss_info = GuildData.Instance:GetBossInfo()
		if boss_activity_info.boss_id == 0 then
			self.show_reward:SetValue(false)
			local notice = Language.Guild.BossDontCall
			self.no_call:SetValue(false)
			if boss_info then
				if boss_info.boss_normal_call_count > 0 then
					notice = Language.Guild.BossHasKilled
				else
					local post = GuildData.Instance:GetGuildPost()
					if post ~= GuildDataConst.GUILD_POST.TUANGZHANG and post ~= GuildDataConst.GUILD_POST.FU_TUANGZHANG then
						self.no_call:SetValue(true)
					end
				end
			end
			self.notice:SetValue(notice)
			self:RemoveCountDown()
		else
			self.show_reward:SetValue(true)
			self.boss_name:SetValue(boss_activity_info.boss_level)
			local boss_config = GuildData.Instance:GetGuildActiveConfig().boss_cfg
			if boss_config then
				local config = boss_config[boss_activity_info.boss_level]
				if config then
					self.item_cell[1].cell:SetData(config.normal_item_reward)
					self.item_cell[1].cell:SetInteractable(true)
				end
			end
			if not self.count_down then
				self.count_down = CountDown.Instance:AddCountDown(999999, 0.5, BindTool.Bind(self.BossHpUpdate, self))
			end
		end
	end
end

function GuildStationView:FlushMoneyTree()
	local tree_info = GuildData.Instance:GetMoneyTreeInfo()
	local num_now = tree_info.gather_num or 0
	local num_max = tree_info.tianci_tongbi_max_gather_num or 0
	local percent_now = tree_info.tianci_tongbi_tree_maturity_degree or 0
	local percent_max = tree_info.tianci_tongbi_tree_max_maturity_degree or 0
	local tree_percent = 0

	if percent_max > 0 then
		tree_percent = percent_now / percent_max
	end

	if self:IsOpen() and self.showinfo then
		self.showinfo:SetValue(true)
		self.list_view.scroller:ReloadData(0)
		self.gathernum:SetValue(string.format(Language.Guild.MoneyTreeGatherNum, num_now, num_max))
		self.treepercent:SetValue(tree_percent)
		self.maturity_max:SetValue(percent_max)
		self.maturity_num:SetValue(percent_now)
	end
end

function GuildStationView:GetNumberOfCells()
	return GuildData.Instance:GetRankListNum() or 0
end

function GuildStationView:RefreshCell(cell, cell_index)
	local rank_cfg = GuildData.Instance:GetRankInfoList()
	if nil == rank_cfg then
		return
	end

	local item_cell = self.cell_list[cell]
	if nil == item_cell then
		item_cell = TreeRankItem.New(cell.gameObject)
		self.cell_list[cell] = item_cell
	end

	item_cell:SetData(rank_cfg[cell_index + 1])
end

-- Boss血量改变
function GuildStationView:BossHpUpdate()
	local boss_obj_id = -1
	local boss_activity_info = GuildData.Instance:GetBossActivityInfo()
	if boss_activity_info then
		boss_obj_id = boss_activity_info.boss_obj_id
	end
	local boss_obj = Scene.Instance:GetObj(boss_obj_id)
	if not boss_obj then return end

	local value = boss_obj:GetAttr("hp") / boss_obj:GetAttr("max_hp")
	self.precent:SetValue(value)
	value = value * 100
	value = value - value % 0.1
	self.value:SetValue(value .. "%")
end

function GuildStationView:OnClickKill()
	local boss_config = GuildData.Instance:GetGuildActiveConfig().boss_cfg
	if boss_config then
		local boss_activity_info = GuildData.Instance:GetBossActivityInfo()
		if boss_activity_info then
			local config = boss_config[boss_activity_info.boss_level]
			if config then
				MoveCache.end_type = MoveEndType.Auto
				GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), config.pos_x, config.pos_y)
			end
		end
	end
end

function GuildStationView:SwitchButtonState(state)
    if state then
        state = false
    else
        state = true
    end
    self.hide:SetValue(state)
end

function GuildStationView:OnClickReminder()
	if self.last_chat_time + 10 >= Status.NowTime then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.SpeackMax)
	else
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, Language.Guild.BossActivity)
		self.last_chat_time = Status.NowTime
	end
end

function GuildStationView:OnClickToTree()
	GuildCtrl.Instance:GoToMoneyTree()
end

function GuildStationView:MoveToTreeState(state)
	if self.showtijiao then
		self.showtijiao:SetValue(state)
	end
end

function GuildStationView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end




TreeRankItem = TreeRankItem or BaseClass(BaseCell)
function TreeRankItem:__init()
	self.rank = self:FindVariable("rank")
	self.name = self:FindVariable("name")
	self.mojing = self:FindVariable("mojing")
	self.bangyuan = self:FindVariable("bangyuan")
end

function TreeRankItem:__delete()
	self.rank = nil
	self.name = nil
	self.mojing = nil
	self.bangyuan = nil
end

function TreeRankItem:OnFlush()
	self.rank:SetValue(self.data.rank_info)
	self.name:SetValue(self.data.user_name)
	self.mojing:SetValue(self.data.longhun)
	self.bangyuan:SetValue(self.data.coin_bind)
end