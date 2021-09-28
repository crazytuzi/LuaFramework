MolongMibaoChapterView = MolongMibaoChapterView or BaseClass(BaseRender)
local CUR_ITEM_ID = 0
function MolongMibaoChapterView:__init()
	self.chapter_id = 0
	self.reward_rate = self:FindVariable("RewardRate")
	self.reward_rate2 = self:FindVariable("RewardRate2")
	self.is_finish = self:FindVariable("IsFinish")
	self.cap = self:FindVariable("Cap")
	self.cap2 = self:FindVariable("Cap2")
	self.procaess = self:FindVariable("Procaess")
	self.procaess2 = self:FindVariable("Procaess2")
	self.show_reward_btn = self:FindVariable("ShowRewardBtn")
	self.show_reward_btn2 = self:FindVariable("ShowRewardBtn2")
	self.condition_txt = self:FindVariable("ConditionTxt")

	self.lable_left_active = self:FindVariable("lable_left")
	self.lable_right_active = self:FindVariable("lable_right")
	self.is_get = self:FindVariable("IsGet")
	self.is_get2 = self:FindVariable("IsGet2")
	self.reward_btn_txt = self:FindVariable("RewardBtnTxt")
	self.is_open = self:FindVariable("IsOpen")

	self.show_progress_1 = self:FindVariable("show_progress_1")
	self.show_progress_2 = self:FindVariable("show_progress_2")
	self.reward_btn_img = self:FindVariable("RewardBtnImg")
	self.chapter_name = self:FindVariable("ChapterName")
	self.finish_need = self:FindVariable("FinishNeed")
	self.finish_need:SetValue(MolongMibaoData.CanRewardCount)
	self.display = self:FindObj("Display")
	self.reward_items = {}
	for i = 1, 4 do
		local reward_item = ItemCell.New()
		reward_item:SetInstanceParent(self:FindObj("Rewards"))
		reward_item:IsDestoryActivityEffect(false)
		reward_item:SetActivityEffect()
		self.reward_items[i] = reward_item
	end

	self.model = RoleModel.New("molong_mibao_panel1")
	self.model:SetDisplay(self.display.ui3d_display)
	self.tab_list = {}
	self:InitScrollerTab()
	self.cell_list = {}
	self:InitScroller()
	self:ListenEvent("Reward",
		BindTool.Bind(self.OnClickRewardButton, self, 0))
end

function MolongMibaoChapterView:__delete()
	if self.reward_items then
		for k,v in pairs(self.reward_items) do
			v:DeleteMe()
		end
		self.reward_items = {}
	end
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
	if self.tab_list then
		for k,v in pairs(self.tab_list) do
			v:DeleteMe()
		end
		self.tab_list = {}
	end
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.reward_rate = nil
	self.reward_rate2 = nil
	self.is_finish = nil
	self.cap = nil
	self.cap2 = nil
	self.procaess = nil
	self.procaess2 = nil
	self.show_reward_btn = nil
	self.reward_btn_img = nil
	self.display = nil
	self.show_progress_1 = nil
	self.show_progress_2 = nil
	self.lable_left_active = nil
	self.lable_right_active = nil
	self.is_get = nil
	CUR_ITEM_ID = 0
end

function MolongMibaoChapterView:InitScrollerTab()
	self.scroller_tab = self:FindObj("TabView")
	local delegate = self.scroller_tab.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return MolongMibaoData.Chapter
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.tab_list[cell]

		if nil == target_cell then
			self.tab_list[cell] =  MolongMibaoTabCell.New(cell.gameObject)
			target_cell = self.tab_list[cell]
			target_cell:SetToggleGroup(self.scroller_tab.toggle_group)
			target_cell.mother_view = self
		end
		target_cell:SetData(data_index)
	end
end

function MolongMibaoChapterView:InitScroller()
	self.data = MolongMibaoData.Instance:GetMibaoChapterDataList(self.chapter_id) or {}
	self.scroller = self:FindObj("ListView")
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  MolongMibaoChapterCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
			target_cell.mother_view = self
		end
		local cell_data = self.data[data_index]
		-- cell_data.data_index = data_index
		target_cell:SetData(cell_data)
	end
end

function MolongMibaoChapterView:OnClickRewardButton()
	MolongMibaoCtrl.SendMagicalPreciousChapterRewardReq(self.chapter_id)
end

local transform =  {"molong_mibao_panel1", "molong_mibao_panel2", "molong_mibao_panel3" ,
"molong_mibao_panel4", "molong_mibao_panel5", "molong_mibao_panel6", "molong_mibao_panel7"}

local asset_cfg = {
	"9001005","9101005","9201005_1"
}
function MolongMibaoChapterView:OpenCallBack()
	local cur_chapter = MolongMibaoData.Instance:GetCurChapter()
	for i=MolongMibaoData.Chapter, 1, -1 do
		if i <= cur_chapter + 1 and not MolongMibaoData.Instance:GetMibaoBigChapterHasReward(i - 1) then
			self:ChapterChange(i)
			return
		end
	end
	self:ChapterChange(1)
end

function MolongMibaoChapterView:ChapterChange(index)
	self.chapter_id = index - 1
	local cur_chapter = MolongMibaoData.Instance:GetCurChapter()
	self.is_open:SetValue(cur_chapter >= self.chapter_id)
	local finish_reward = MolongMibaoData.Instance:GetMibaoFinishChapterReward(self.chapter_id) or {}
	if CUR_ITEM_ID == finish_reward[0].item_id then
		return
	end
	self.chapter_name:SetValue(MolongMibaoData.Instance:GetMibaoChapterName(self.chapter_id))
	CUR_ITEM_ID = finish_reward[0].item_id
	for k,v in pairs(self.reward_items) do
		if finish_reward[k -1] then
			v:SetData(finish_reward[k -1])
		end
		v.root_node:SetActive(finish_reward[k -1] ~= nil)
	end
	self.model:SetPanelName(transform[self.chapter_id + 1] or transform[1])
	ItemData.ChangeModel(self.model, CUR_ITEM_ID)
	self.cap:SetValue(ItemData.GetFightPower(CUR_ITEM_ID))
	self:Flush()
end

function MolongMibaoChapterView:OnFlush()
	self.data = MolongMibaoData.Instance:GetMibaoChapterDataList(self.chapter_id) or {}
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
	if self.scroller_tab.scroller.isActiveAndEnabled then
		self.scroller_tab.scroller:RefreshActiveCellViews()
	end
	local reward_count = 0
	local cur_chapter = MolongMibaoData.Instance:GetCurChapter()
	if cur_chapter >= self.chapter_id then
		for k,v in pairs(self.data) do
			local cur_value, max_value = MolongMibaoData.Instance:GetMibaoChapterValue(v)
			if cur_value >= max_value then
				reward_count = reward_count + 1
			end
		end
	end
	self.condition_txt:SetValue(string.format("<color=#%s>%s</color><color=#fff334>/%s</color>", reward_count < MolongMibaoData.CanRewardCount and "ff0000" or "fff334", reward_count, MolongMibaoData.CanRewardCount))
	local has_reward = MolongMibaoData.Instance:GetMibaoBigChapterHasReward(self.chapter_id)
	self.show_reward_btn:SetValue(reward_count >= MolongMibaoData.CanRewardCount)
	self.is_get:SetValue(reward_count < MolongMibaoData.CanRewardCount)
	self.is_get2:SetValue(has_reward)
	self.reward_btn_txt:SetValue(has_reward and Language.Common.YiLingQu or Language.Common.LingQuJiangLi)
end


---------------------------------------------------------------
--滚动条格子

MolongMibaoTabCell = MolongMibaoTabCell or BaseClass(BaseCell)

function MolongMibaoTabCell:__init()
	self.is_lock = self:FindVariable("IsLock")
	self.tab_name = self:FindVariable("TabName")
	self.remind = self:FindVariable("Remind")
	self.is_get = self:FindVariable("IsGet")
	self:ListenEvent("OnClick",
		BindTool.Bind(self.OnClick, self))
end

function MolongMibaoTabCell:__delete()
	self.mother_view = nil
end

function MolongMibaoTabCell:OnFlush()
	self.root_node.toggle.isOn = self.data == self.mother_view.chapter_id + 1
	local cur_chapter = MolongMibaoData.Instance:GetCurChapter()
	self.is_lock:SetValue(self.data > cur_chapter + 1)
	self.remind:SetValue(MolongMibaoData.Instance:GetMibaoChapterRemind(self.data - 1) > 0)
	self.is_get:SetValue(MolongMibaoData.Instance:GetMibaoBigChapterHasReward(self.data - 1))
	self.tab_name:SetValue(string.format(Language.MoLongMiBao.TabName, CommonDataManager.GetDaXie(self.data)))
end

function MolongMibaoTabCell:OnClick()
	self.mother_view:ChapterChange(self.data or 1)
end

function MolongMibaoTabCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

---------------------------------------------------------------
--滚动条格子

MolongMibaoChapterCell = MolongMibaoChapterCell or BaseClass(BaseCell)

function MolongMibaoChapterCell:__init()
	self.task_dec = self:FindVariable("Dec")
	self.reward_btn_enble = self:FindVariable("BtnEnble")
	self.reward_btn_txt = self:FindVariable("RewardBtnTxt")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.btn_img = self:FindVariable("BtnImage")
	self.process = self:FindVariable("Process")
	self.can_reward = self:FindVariable("CanReward")
	self.rate = self:FindVariable("Rate")
	self.goto_text = self:FindVariable("GotoText")
	self.name = self:FindVariable("Name")
	self.show_finish = self:FindVariable("ShowFinish")
	self.reward_list = {}
	for i = 1, 1 do
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
		self.reward_list[i]:IgnoreArrow(true)
	end
	self:ListenEvent("Reward",
		BindTool.Bind(self.ClickReward, self))
end

function MolongMibaoChapterCell:__delete()
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
	self.mother_view = nil
end

function MolongMibaoChapterCell:ClickReward()
	if self.data == nil then return end
	local cur_value, max_value = MolongMibaoData.Instance:GetMibaoChapterValue(self.data)
	if cur_value < max_value then
		self:ClickGoto()
	else
		MolongMibaoCtrl.SendMagicalPreciousRewardReq(self.data.reward_index, self.data.chapter_id)
	end
end

function MolongMibaoChapterCell:ClickGoto()
	if self.data == nil then return end
	if self.data.open_panel == "jingyantask" then
		local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.RI)
		if task_id == nil or task_id == 0 then
			TipsCtrl.Instance:ShowSystemMsg(Language.MoLongMiBao.NotDailyTask)
			return
		end
		TaskCtrl.Instance:DoTask(task_id)

	elseif self.data.open_panel == "guildtask" then
		local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.GUILD)
		if task_id == nil or task_id == 0 then
			if PlayerData.Instance.role_vo.guild_id > 0 then
				TipsCtrl.Instance:ShowSystemMsg(Language.MoLongMiBao.NotGuildTask)
			else
				ViewManager.Instance:Open(ViewName.Guild)
			end
			return
		end
		TaskCtrl.Instance:DoTask(task_id)
	end
	ViewManager.Instance:OpenByCfg(self.data.open_panel)
	ViewManager.Instance:Close(ViewName.MolongMibaoView)
end

function MolongMibaoChapterCell:OnFlush()
	self:OnFlushView()
	local reward_item = self:RewardItem()
	self.show_finish:SetValue(#reward_item <= 0)
	for k,v in pairs(self.reward_list) do
		v:SetData(reward_item[k])
		v.root_node:SetActive(reward_item[k] ~= nil)
	end
end

function MolongMibaoChapterCell:RewardItem()
	local reward_item = {}
	for k,v in pairs(self.data.client_reward) do
		local cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if cfg and (cfg.limit_prof == 5 or cfg.limit_prof == PlayerData.Instance.role_vo.prof) then
			table.insert(reward_item, v)
		end
	end
	return reward_item
end

function MolongMibaoChapterCell:OnFlushView()
	local has_reward = MolongMibaoData.Instance:GetMibaoChapterHasReward(self.data.chapter_id, self.data.reward_index)
	local cur_value, max_value = MolongMibaoData.Instance:GetMibaoChapterValue(self.data)
	local reward = 0
	if self.data.mojing_reward > 0 then
		reward = self.data.mojing_reward
	else
		reward = self.data.bind_gold_reward
	end

	self.task_dec:SetValue(self.data.desc)
	local rate = string.format("%s/%s", cur_value, max_value)
	self.rate:SetValue(rate)
	self.process:SetValue(cur_value / max_value)
	self.reward_btn_enble:SetValue(not has_reward)
	if not has_reward and cur_value < max_value then
		self.reward_btn_txt:SetValue(Language.Common.QianWang)
		self.btn_img:SetAsset("uis/images_atlas", "btn_04")
		self.can_reward:SetValue(false)
	else
		self.reward_btn_txt:SetValue(has_reward and Language.Common.YiLingQu or Language.Common.LingQu)

		self.btn_img:SetAsset("uis/images_atlas", "btn_04_HL")
		self.can_reward:SetValue(true)
	end
	self.show_red_point:SetValue(not has_reward and cur_value >= max_value)
	local client_cfg = MolongMibaoData.Instance:GetMibaoChapterClientCfg(self.data.chapter_id)
	if client_cfg then
		self.goto_text:SetValue(client_cfg.button_name)
	end
	self.name:SetValue(self.data.target_name)
end