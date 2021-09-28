DabaoBossView = DabaoBossView or BaseClass(BaseRender)

local PageUp = 1
local PageDown = 2

function DabaoBossView:__init()
	self.select_index = 1
	self.select_monster_res_id = 0
	self.select_scene_id = 9020
	self.select_boss_id = BossData.Instance:GetDaBaoBossList(self.select_scene_id)[1].bossID
	self.boss_data = {}
	self.cell_list = {}
	self.is_first = true
	self.layer = 1
	self.num = 0
	self.rew_list = {}
	self.nowpanelboss_num = self:FindVariable("NowPanelBossNum")

	self.enter_limit = self:FindVariable("EnterLimit")
	self.enter_btn_name = self:FindVariable("EnterBtnName")
	self.enter_btn_gray = self:FindVariable("EnterBtnGray")
	self.show_diamond = self:FindVariable("ShowDiamond")

	self.remain_count_text_list = {}
	for i=1,3 do
		self.remain_count_text_list[i] = self:FindVariable("RemainCountText" .. i)
	end

	self.boss_list = self:FindObj("BossList")
	self.turntable_info = TurntableInfoCell.New(self:FindObj("Turntable"))

	self.list_view_delegate = self.boss_list.list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.reward_list = self:FindObj("RewardList")
	self.reward_view_delegate = self.reward_list.list_simple_delegate
	self.reward_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRewardNumberOfCells, self)
	self.reward_view_delegate.CellRefreshDel = BindTool.Bind(self.ReRewardfreshView, self)

	self.show_hl_list = {}
	self.toggle_list = {}
	for i=1, 6 do
		self:ListenEvent("ClickScene"..i, BindTool.Bind(self.ClickScene, self, i))
		self.show_hl_list[i] = self:FindVariable("show_hl_" .. i)
		self.toggle_list[i] = self:FindObj("toggle_" .. i)
	end
	self:ListenEvent("ToActtack",
		BindTool.Bind(self.ToActtack, self))
	self:ListenEvent("QuestionClick",
		BindTool.Bind(self.QuestionClick, self))
	self:ListenEvent("OpenKillRecord",
		BindTool.Bind(self.OpenKillRecord, self))
	self.model_display = self:FindObj("display")
	self.model_view = RoleModel.New("boss_panel")
	self.model_view:SetDisplay(self.model_display.ui3d_display)
end

function DabaoBossView:__delete()
	if nil ~= self.model_view then
		self.model_view:DeleteMe()
	end

	for _,v in pairs(self.rew_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.rew_list = {}

	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	self.is_first = false
	self.turntable_info:DeleteMe()
	self.turntable_info = nil
	self.nowpanelboss_num = nil
end

function DabaoBossView:ClickScene(layer, is_click)
	self.num = 0
	if is_click then
		for k,v in pairs(BossData.Instance:GetDabaoBossClientCfg()) do
			if layer == k then
				local can_go, min_level = BossData.Instance:GetCanToSceneLevel(v.scene_id)
				if not can_go then
					local level_text = PlayerData.GetLevelString(min_level)
					local text = string.format(Language.Boss.BossLimit, level_text)
					TipsCtrl.Instance:ShowSystemMsg(text)
					return
				end
				self.select_scene_id = v.scene_id
				break
			end
		end
		self.layer = layer
		self:FlushBossView()
		self:FlushToggleHL()
	end
end

function DabaoBossView:FlushToggleHL()
	for k, v in ipairs(self.show_hl_list) do
		v:SetValue(k == self.layer)
	end
end

function DabaoBossView:FlushToggleState()
	for _, v in ipairs(self.toggle_list) do
		v:SetActive(true)
	end
	local index = BossData.Instance:GetCanGoLevel(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO)
	if index  > 3 then
		self.toggle_list[1]:SetActive(false)
	else
		self.toggle_list[6]:SetActive(false)
	end
end


function DabaoBossView:OpenBossView()
	self.select_scene_id = 9020
	self:FlushBossView()
end

-- function DabaoBossView:FlushBossRemainCount()
-- 	for i=1,3 do
-- 		self.remain_count_text_list[i]:SetValue("2")
-- 	end
-- end

function DabaoBossView:CloseBossView()
	self.select_index = 1
	-- self.select_boss_id = 10
end

function DabaoBossView:GetNumberOfCells()
	return #BossData.Instance:GetDaBaoBossList(self.select_scene_id) or 0
end

function DabaoBossView:GetRewardNumberOfCells()
	return 2
end

function DabaoBossView:ReRewardfreshView(cell, data_index)
	data_index = data_index + 1
	local reward_cell = self.rew_list[cell]
	if not reward_cell then
		reward_cell = DaBaoBossRewardCell.New(cell.gameObject)
		self.rew_list[cell] = reward_cell
	end
	reward_cell:SetIndex(data_index)
	reward_cell:SetBossID(self.select_boss_id)
	reward_cell:Flush()
end

function DabaoBossView:RefreshView(cell, data_index)
	data_index = data_index + 1

	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = DabaoBossItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.boss_list.toggle_group
		boss_cell.boss_view = self
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
end

function DabaoBossView:ToActtack()
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	if self.select_scene_id == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
		return
	end
	local enter_count = BossData.Instance:GetDabaoBossCount()
	local max_count = BossData.Instance:GetDabaoFreeTimes()
	if enter_count >= max_count and BossData.Instance:GetDabaoEnterGold(enter_count - max_count) then
		local cost = BossData.Instance:GetDabaoEnterGold(enter_count - max_count)
		local func = function()
			BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
			ViewManager.Instance:CloseAll()
			BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.select_scene_id, 1)
		end
		TipsCtrl.Instance:ShowCommonAutoView(nil, string.format(Language.Boss.BuyEnterDabao, cost), func, nil, true)
		return
	else
		BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
		ViewManager.Instance:CloseAll()
		BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.select_scene_id, 1)
	end
end

function DabaoBossView:QuestionClick()
	local tips_id = 143
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end


function DabaoBossView:FlushModel()
	if self.model_view == nil then
		return
	end
	-- if self.model_display.gameObject.activeInHierarchy then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.select_boss_id]
		if monster_cfg then
			local display_name = BossData.Instance:DisplayName(monster_cfg.resid)
			self.model_view:SetPanelName(display_name)
			self.model_view:SetMainAsset(ResPath.GetMonsterModel(monster_cfg.resid))
			self.model_view:SetTrigger("rest1")
		end
	-- end
end

function DabaoBossView:OpenKillRecord()
	BossCtrl.SendBossKillerInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.select_boss_id, self.select_scene_id)
end

function DabaoBossView:FlushInfoList()
	if self.select_scene_id ~= 0 and self.select_boss_id ~= 0 then
		-- local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.select_boss_id]
		-- if monster_cfg then
		-- 	self.boss_name:SetValue(monster_cfg.name)
		-- end
		local enter_count = BossData.Instance:GetDabaoBossCount()
		local max_count = BossData.Instance:GetDabaoFreeTimes()
		local has_count = math.max(max_count - enter_count, 0)
		if has_count > 0 then
			self.show_diamond:SetValue(false)
			self.enter_limit:SetValue(Language.Boss.ResetEnterTimes .. ToColorStr(tostring(has_count), TEXT_COLOR.GREEN))
		else
			self.show_diamond:SetValue(true)
			local cost = BossData.Instance:GetDabaoEnterGold(enter_count - max_count)
			self.enter_limit:SetValue(Language.Boss.XiaoHao .. ToColorStr(tostring(cost), TEXT_COLOR.YELLOW))
		end
		local str = Language.Boss.EnterBtnName[2]
		if enter_count == 0 then
			str = Language.Boss.EnterBtnName[1]
		end
		self.enter_btn_name:SetValue(str)
		self.enter_btn_gray:SetValue(has_count > 0 or BossData.Instance:GetDabaoEnterGold(enter_count - max_count))
		self:FlushModel()
	end
end

function DabaoBossView:FlushBossList()
	self.num = 0
	if self.is_first == true then
		local index = BossData.Instance:GetCanGoLevel(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO)
		self.toggle_list[index].toggle.isOn = true
		self.is_first = false
	end

	local boss_list = BossData.Instance:GetDaBaoBossList(self.select_scene_id)
	if #boss_list > 0 then
		for i = 1, #boss_list do
			self.boss_data[i] = boss_list[i]
			local reflash_time = BossData.Instance:GetDaBaoStatusByBossId(boss_list[i].bossID, self.select_scene_id)
			if reflash_time <= 0 then
				self.num = self.num + 1
			end
		end
		self.select_boss_id = boss_list[1].bossID
		self.nowpanelboss_num:SetValue(self.num.." / "..#boss_list)
	end
	if self.select_index == 1 then
		self.boss_list.scroller:ReloadData(0)
	else
		self.boss_list.scroller:RefreshAndReloadActiveCellViews(true)
	end

	self.turntable_info:SetShowEffect(WelfareData.Instance:GetTurnTableRewardCount() ~= 0)
	self:FlushToggleState()
end

function DabaoBossView:FlushReward()
	self.reward_list.scroller:ReloadData(0)
end

function DabaoBossView:FlushBossView()
	self.select_index = 1
	self:FlushBossList()
	self:FlushReward()
	self:FlushInfoList()
	self:FlushToggleHL()
	self:FlushModel()
end

function DabaoBossView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function DabaoBossView:GetSelectIndex()
	return self.select_index or 1
end

function DabaoBossView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function DabaoBossView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

----------------------------------------------------------------------
DaBaoBossRewardCell = DaBaoBossRewardCell or BaseClass(BaseCell)

function DaBaoBossRewardCell:__init()
	self.boss_id = 0
	self.rew_cell = {}
	for i=1,4 do
		self.rew_cell[i] = {}
		self.rew_cell[i] = ItemCell.New()
		self.rew_cell[i]:SetInstanceParent(self:FindObj("Item"..i))
	end

end

function DaBaoBossRewardCell:__delete()
	for i,v in pairs(self.rew_cell) do
		v:DeleteMe()
	end
	self.rew_cell = {}
end


function DaBaoBossRewardCell:OnFlush()
	local temp = 0
	if self.index == 2 then
		temp = 4
	end
	local data = BossData.Instance:GetDabaoBossRewards(self.boss_id)
	for i=1,4 do
		local item_id = data[i+temp]
		if item_id then
			local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
			if item_cfg.color == GameEnum.ITEM_COLOR_RED and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then   -- 红色装备写死3星
				self.rew_cell[i]:SetData(BossData.Instance:GetShowEquipItemList(item_id, 0))
			else
				self.rew_cell[i]:SetData({item_id = item_id})
			end
		end
	end
end

function DaBaoBossRewardCell:SetBossID(id)
	self.boss_id = id
end

----------------------------------------------------------------------
DabaoBossItemCell = DabaoBossItemCell or BaseClass(BaseCell)

function DabaoBossItemCell:__init()
	self.boss_name = self:FindVariable("Name")
	self.level = self:FindVariable("Level")
	self.icon = self:FindVariable("Icon")
	self.time = self:FindVariable("Time")
	self.iskill = self:FindVariable("IsKill")
	self.image_gray_scale = self:FindVariable("image_gray_scale")
	self.show_hl = self:FindVariable("show_hl")
	self.show_limit = self:FindVariable("show_limit")
	self.canKill = self:FindVariable("canKill")
	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function DabaoBossItemCell:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function DabaoBossItemCell:ClickItem(is_click)
	if is_click then
		self.root_node.toggle.isOn = true
		local select_index = self.boss_view:GetSelectIndex()
		self.boss_view:SetSelectIndex(self.index)
		self.boss_view:SetSelectBossId(self.data.bossID)
		self.boss_view:FlushAllHL()
		if select_index == self.index then
			return
		end
		self.boss_view:FlushModel()
	end
end

function DabaoBossItemCell:OnFlush()
	if not self.data then return end
	self.root_node.toggle.isOn = false
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.bossID]
	if monster_cfg then
		self.level:SetValue("Lv." .. monster_cfg.level)
		self.boss_name:SetValue(monster_cfg.name)
		self.canKill:SetValue(true)
		local bundle, asset = ResPath.GetBoss("boss_item_" .. monster_cfg.headid)
		self.icon:SetAsset(bundle, asset)
	end
	local reflash_time = BossData.Instance:GetDaBaoStatusByBossId(self.data.bossID, self.data.scene_id)
	if reflash_time > 0 then
		local time_tab = os.date("*t", reflash_time)
		local str = string.format("%02d:%02d%s", time_tab.hour, time_tab.min, Language.Boss.BossFlush)
		self.time:SetValue(str)
		if nil == self.time_coundown then
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
					BindTool.Bind(self.OnBossUpdate, self), 1, reflash_time - TimeCtrl.Instance:GetServerTime()
			)
		end
		self.iskill:SetValue(true)
		self.image_gray_scale:SetValue(false)
	else
		if self.time_coundown then
			GlobalTimerQuest:CancelQuest(self.time_coundown)
			self.time_coundown = nil
		end
		self.iskill:SetValue(false)
		self.image_gray_scale:SetValue(true)
		self.time:SetValue(Language.Boss.HadFlush)
	end
	self:FlushHL()
end

function DabaoBossItemCell:OnBossUpdate()
	local reflash_time = BossData.Instance:GetDaBaoStatusByBossId(self.data.bossID, self.data.scene_id)
	if reflash_time <= TimeCtrl.Instance:GetServerTime() then
		self.iskill:SetValue(false)
		self.image_gray_scale:SetValue(true)
		self.time:SetValue(Language.Boss.HadFlush)
	else
		local time_tab = os.date("*t", reflash_time)
		local str = string.format("%02d:%02d%s", time_tab.hour, time_tab.min, Language.Boss.BossFlush)
		self.time:SetValue(str)
		self.iskill:SetValue(true)
		self.image_gray_scale:SetValue(false)
	end
end

function DabaoBossItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.index)
end