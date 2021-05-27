--------------------------------------------------------
-- 龙族秘宝  配置 
--------------------------------------------------------

DragonTreasureView = DragonTreasureView or BaseClass(ActBaseView)

function DragonTreasureView:__init(view, parent, act_id)

----------重写LoadView----------
	local ui_config = ConfigManager.Instance:GetUiConfig("dragon_treasure_ui_cfg")
	for k, v in pairs(ui_config) do
		if v.n == OPER_ACT_CLIENT_CFG[self.act_id].ui_layout_name then
			self.ui_cfg = v
			break
		end
	end

	if nil == self.ui_cfg then
		ErrorLog(string.format("ActBaseView no ui_cfg !, act_id : %d", self.act_id))
	else
		self.ui_cfg.x = 0
		self.ui_cfg.y = 0
		self.tree = XUI.GeneratorUI(self.ui_cfg, nil, nil, self.node_t_list, nil, self.ph_list)
		parent:addChild(self.tree.node, 999, 999)
		self:InitView()
		self:AddActCommonClickEventListener()
	end
--------------------
	self.rich_consume = nil
	self.rich_times = nil
end

function DragonTreasureView:__delete()
	if nil ~= self.times_award_view then
		self.times_award_view:DeleteMe()
		self.times_award_view = nil
	end
	if nil ~= self.play_view then
		self.play_view:DeleteMe()
		self.play_view = nil
	end
	if nil ~= self.treasure_view then
		self.treasure_view:DeleteMe()
		self.treasure_view = nil
	end
	if nil ~= self.update_spare_timer then
		GlobalTimerQuest:CancelQuest(self.update_spare_timer)
	end

	self.rich_consume = nil
	self.rich_times = nil

end

--加载回调
function DragonTreasureView:InitView(index, loaded_times)
	self:CreateTimesAwardView()
	self:CreatePlayView()
	self:CreateTreasureView()

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["layout_play_1"].node, BindTool.Bind(self.OnPlay, self, 1), true)
	XUI.AddClickEventListener(self.node_t_list["layout_play_2"].node, BindTool.Bind(self.OnPlay, self, 2), true)
	XUI.AddClickEventListener(self.node_t_list["layout_skip"].node, BindTool.Bind(self.OnSkipAction, self))
	XUI.AddClickEventListener(self.node_t_list["btn_tips"].node, BindTool.Bind(self.OnClickTips, self))


	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.LZMB)
	local beg_time = os.date("*t", cfg.beg_time)
	local end_time = os.date("*t", cfg.end_time)
	local str_time = string.format(Language.ActivityBrilliant.AboutTime, beg_time.month, beg_time.day, beg_time.hour, beg_time.min)
	local str_time_2 = string.format(Language.ActivityBrilliant.AboutTime, end_time.month, end_time.day, end_time.hour, end_time.min)
	self.node_t_list.lbl_activity_time.node:setString(str_time .. "-" .. str_time_2)

	self.times_award_view:SetDataList(cfg.config.timesAward)
	self.treasure_view:SetDataList(cfg.config.things)
	self.play_view:SetDataList(cfg.config.slots)

	self.update_spare_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateSpareTime, self), 1)

	self.node_t_list["img_skip"].node:setVisible(false)

	self.item_config_bind = BindTool.Bind(self.RefreshView, self)
	self.itemdata_change_callback = BindTool.Bind(self.FlushConsumeText, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
	ItemData.Instance:NotifyItemConfigCallBack(self.item_config_bind)
end

-- 选中当前视图回调
function DragonTreasureView:ShowIndexView()
	XUI.SetLayoutImgsGrey(self.node_t_list["layout_play_1"].node, false, true)
	XUI.SetLayoutImgsGrey(self.node_t_list["layout_play_2"].node, false, true)
end

function DragonTreasureView:CloseCallback(is_all)
	if ItemData.Instance then
		ItemData.Instance:UnNotifyItemConfigCallBack(self.item_config_bind)
		ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
	end

	DragonTreasureData.Instance:SetShipForce(true)
	ItemData.Instance:SetDaley(false)
	local results = ActivityBrilliantData.Instance:GetDragonTreasureResults() or {}
	results.type = nil
end

function DragonTreasureView:RefreshView(param_list)
	for k,v in pairs(param_list) do
		if k == "all" then
		elseif k == "flush_view" then
			if v.result == 3 then
				XUI.SetLayoutImgsGrey(self.node_t_list["layout_play_1"].node, false, true)
				XUI.SetLayoutImgsGrey(self.node_t_list["layout_play_2"].node, false, true)
				self:FlushConsumeText()
			else
				self:FlushPlayTimesText()
				self:FlushConsumeText()
				self.times_award_view:RefreshItems()
				self.play_view:RefreshItems()
				self.treasure_view:RefreshItems()
			end
		end
	end
end

----------视图函数----------

function DragonTreasureView:UpdateSpareTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.LZMB)
	if nil == cfg then return end
	
	local now_time = TimeCtrl.Instance:GetServerTime()
	local str = TimeUtil.FormatSecond2Str(cfg.end_time - now_time)
	self.node_t_list.lbl_activity_spare_time.node:setString(str)
end

-- 创建"次数奖励"视图
function DragonTreasureView:CreateTimesAwardView()
	local ph_item = self.ph_list["ph_times_award_item"]
	local ph = self.ph_list["ph_times_award"]
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.h + 5, self.TimesAwardItem, ScrollDir.Vertical, false, ph_item)
	-- grid_scroll:GetView():setAnchorPoint(0.5, 0.5)
	self.node_t_list["layout_dragon_treasure"].node:addChild(grid_scroll:GetView(), 20)
	self.times_award_view = grid_scroll
end

-- 创建"抽奖"视图
function DragonTreasureView:CreatePlayView()
	local ph_item = self.ph_list["ph_play_item"]
	local ph = self.ph_list["ph_play"]
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 3, self.PlayItem, ScrollDir.Horizontal, false, ph_item)
	-- grid_scroll:GetView():setAnchorPoint(0, 0)
	self.node_t_list["layout_dragon_treasure"].node:addChild(grid_scroll:GetView(), 20)
	self.play_view = grid_scroll
end

-- 创建"秘宝"视图
function DragonTreasureView:CreateTreasureView()
	local ph_item = self.ph_list["ph_treasure_item"]
	local ph = self.ph_list["ph_treasure"]
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 12, self.TreasureItem, ScrollDir.Horizontal, false, ph_item)
	-- grid_scroll:GetView():setAnchorPoint(0, 0)
	self.node_t_list["layout_dragon_treasure"].node:addChild(grid_scroll:GetView(), 20)
	self.treasure_view = grid_scroll
end

-- 刷新消耗文本
function DragonTreasureView:FlushConsumeText()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.LZMB)
	local yb = cfg.config.grade[1].firstConsume.yb
	local consume = cfg.config.grade[1].firstConsume.count

	local node = self.rich_consume or self.node_t_list["rich_consume"].node
	local img_1 = "{image;res/xui/common/gold.png;38,24}" 	--插入图片-元宝
	local img_2 = "{image;res/xui/dragon_treasure/dragon_treasure_13.png;40,29}" 	--插入图片-卷轴
	local item_id = cfg.config.grade[1].firstConsume.id
	local item_num = ItemData.Instance:GetItemNumInBagById(item_id)
	local item_num_str = item_num < 1 and "{color;ff2828;" .. item_num .. "}" or "{color;1eff00;" .. item_num .. "}" --当物品数量小于1时，改变成红色

	local text = string.format(Language.DragonTreasure.Consume, img_1, yb, img_2, consume, item_num_str)

	node = RichTextUtil.ParseRichText(node, text, 20, COLOR3B.GOLD)
	XUI.RichTextSetCenter(node)
	self.rich_consume = node
end

-- 刷新抽取次数文本
function DragonTreasureView:FlushPlayTimesText()
	local data = ActivityBrilliantData.Instance:GetDragonTreasureData()
	local times = data.buy_times
	local node = self.rich_times or self.node_t_list["rich_times"].node
	local text = string.format(Language.DragonTreasure.Times, times)

	node = RichTextUtil.ParseRichText(node, text, 20, COLOR3B.GOLD)
	XUI.RichTextSetCenter(node)
	self.rich_times = node
end

function DragonTreasureView:SetPlayResult(data)
	if self:IsOpen() then
		if self.draw_item_list[data.draw_index] then
			self.draw_item_list[data.draw_index]:StartRoll(data.reward_index)
		end
	end
end

----------end----------

function DragonTreasureView:OnClickTips()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.LZMB)
    DescTip.Instance:SetContent(cfg.act_desc, cfg.act_name)
end

-- 抽奖按钮点击回调
function DragonTreasureView:OnPlay(index)
	-- XUI.SetLayoutImgsGrey(self.node_t_list["layout_play_1"].node, index == 1, true)
	-- XUI.SetLayoutImgsGrey(self.node_t_list["layout_play_2"].node, index == 1, true)
	if index == 1 then
		ItemData.Instance:SetDaley(true)
	end
	DragonTreasureData.Instance:SetShipForce(index == 2)
	ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.LZMB, 1, index)
end

-- "跳过动画"点击回调
function DragonTreasureView:OnSkipAction()
	local vis = not(self.node_t_list["img_skip"].node:isVisible())
	DragonTreasureData.Instance:SetShipIsVis(vis)
	self.node_t_list["img_skip"].node:setVisible(vis)
end

--------------------

----------------------------------------
-- 抽取奖励项目 ph_play_item
----------------------------------------
DragonTreasureView.PlayItem = BaseClass(BaseRender)
local PlayItem = DragonTreasureView.PlayItem

function PlayItem:__init()
	self.item_cell = nil
	self.scorll_view = nil
	self.item_list = {}

	self.MIN_ROLL_TIME = 0.1
	self.MAX_ROLL_TIME = 0.13
	self.CHANGE_SPEED_TIMES = 1
	self.SPEED_UP_CHANGE_TIME = - 0.05
	self.SPEED_DOWN_CHANGE_TIME = 0.025
	self.MAX_PASS_TIMES = {1, 2, 3, 4}
end

function PlayItem:__delete()
	self.scorll_view = nil
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self:InitRollVal()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = nil
end

function PlayItem:CreateChild()
	BaseRender.CreateChild(self)

	self:InitRollVal()
	local ph = self.ph_list.ph_cell
	local item_cell = BaseCell.New()
	item_cell:GetView():setAnchorPoint(0.5, 0.5)
	item_cell:GetView():setPosition(ph.x, ph.y)
	self.view:addChild(item_cell:GetView(), 10)
	self.item_cell = item_cell
	self.item_cell_index = nil

	self.scorll_view = XUI.CreateLayout(ph.x, ph.y, ph.w, ph.h - 6)
	self.scorll_view:setClippingEnabled(true)
	self.view:addChild(self.scorll_view, 11)
end

function PlayItem:OnFlush()
	if nil == self.data then return end
	local results = ActivityBrilliantData.Instance:GetDragonTreasureResults()
	local index = 1
	if results.type == 1 then
		local index = results.index_list[self.index]
		self:StartRoll(index)
		if self.index == (#results.index_list) then
			results.type = 0
		end
		return
	elseif results.type == 0 then
		return
	end
	self:SetRewardItem(index)
end

function PlayItem:InitRollVal()
	self.change_item = nil
	self.is_rolling = false
	self.cur_index = 1
	self.pass_times = 0
	self.roll_cost_t = 0.4
	self.add_cost_t = self.SPEED_UP_CHANGE_TIME
end

function PlayItem:SetRewardItem(index)
	if self.is_rolling == true then return end

	if self.item_cell_index and self.item_cell_index == index and nil == self.item_cell then
		return
	end
	local item_cfg = self.data.pood
	local item = item_cfg and item_cfg[index]
	if item then
		local item_cfg = ItemData.InitItemDataByCfg(item)
		self.item_cell:SetData(item_cfg)
		local item_config = ItemData.Instance:GetItemConfig(item.id)
		if item_config then
			self.item_cell_index = index
			self.data.try_change = false
		end
		if item_cfg.effectId ~= nil and item_cfg.effectId > 0 then
			if nil == self.item_cell.cell_effect then
				local ph = self.ph_list.ph_cell
				local cell_effect = AnimateSprite:create()
				local path, name = ResPath.GetEffectUiAnimPath(item_cfg.effectId)
				cell_effect:setPosition(ph.x, ph.y)
				cell_effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, 0.12, false)
				self.view:addChild(cell_effect, 300)
				cell_effect:setVisible(true)
				self.item_cell.cell_effect = cell_effect
			else
				self.item_cell.cell_effect:setVisible(true)
			end
		else
			if nil ~= self.item_cell.cell_effect then
				self.item_cell.cell_effect:setVisible(false)
			end
		end
	else
		if nil ~= self.item_cell.cell_effect then
			self.item_cell.cell_effect:setVisible(false)
		end
		self.item_cell:SetData()
		self.item_cell_index = nil
	end
	self.scorll_view:setVisible(false)
end

function PlayItem:StartRoll(index)
	if self.is_rolling == true then return end

	self:SetRewardItem(0)
	self.roll_to_index = index
	self.is_rolling = true

	local x = self.scorll_view:getContentSize().width / 2
	local h = self.scorll_view:getContentSize().height

	self.scorll_view:setVisible(true)
	local item_cfg = self.data.pood
	for i, v in ipairs(item_cfg) do
		if nil == self.item_list[i] then
			local cell = BaseCell.New()
			local item_cfg = ItemData.InitItemDataByCfg(v)
			cell:GetCell():setAnchorPoint(cc.p(0.5, 0.5))
			cell:SetData(item_cfg)
			cell.bg_img:setVisible(false)
			cell:GetView():setTouchEnabled(false)
			self.item_list[i] = cell
			self.scorll_view:addChild(self.item_list[i]:GetView(), 99, 99)
		end
		self.item_list[i]:GetView():stopAllActions()
		y = h * 2
		self.item_list[i]:SetPosition(x, y)
	end

	self.change_item = self.item_list[self.cur_index]
	self:RunRollAction(self.change_item)
end

function PlayItem:RunRollAction(change_item)
	if DragonTreasureData.Instance:GetShipIsVis() then
		self:InitRollVal()
		self:SetRewardItem(self.roll_to_index)
		self.roll_to_index = -1
		if self.index == 4 then
			ItemData.Instance:SetDaley(false)
			ActivityBrilliantCtrl.Instance:SetDragonTreasurePlayBtnEnabled()
		end
		return
	end
	local item_cfg = self.data.pood
	local h = BaseCell.SIZE
	change_item:GetView():setPositionY(h * 1.5)

	local next_roll_cost = self.roll_cost_t + self.add_cost_t
	if next_roll_cost > self.MAX_ROLL_TIME then
		self.roll_cost_t = self.MAX_ROLL_TIME
	elseif self.roll_cost_t < self.MIN_ROLL_TIME then
		self.roll_cost_t = self.MIN_ROLL_TIME
	else
		self.roll_cost_t = next_roll_cost
	end

	local move_by1 = cc.MoveBy:create(self.roll_cost_t, cc.p(0, - h - 20))
	local move_by2 = cc.MoveBy:create(self.roll_cost_t, cc.p(0, - h - 20))
	local func = function()
		if self.cur_index == self.roll_to_index then
			self.pass_times = self.pass_times + 1
			if self.pass_times == self.CHANGE_SPEED_TIMES then
				self.add_cost_t = self.SPEED_DOWN_CHANGE_TIME
			end

			if self.pass_times > self.MAX_PASS_TIMES[self.index] then
				self.change_item:GetView():stopAllActions()
				self:InitRollVal()
				self:SetRewardItem(self.roll_to_index)
				self.roll_to_index = -1
				if self.index == 4 then
					ItemData.Instance:SetDaley(false)
					ActivityBrilliantCtrl.Instance:SetDragonTreasurePlayBtnEnabled()
				end
				return
			end
		end
		self.cur_index = (self.cur_index + 1) > #item_cfg and 1 or (self.cur_index + 1)
		self.change_item = self.item_list[self.cur_index]

		self:RunRollAction(self.change_item)
	end
	local call_back = cc.CallFunc:create(func)
	local sequence = cc.Sequence:create(move_by1, call_back, move_by2)

	change_item:GetView():stopAllActions()
	change_item:GetView():runAction(sequence)
end

function PlayItem:CreateSelectEffect()
	return
end

function PlayItem:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end

----------------------------------------
-- 次数奖品项目 ph_times_award_item
----------------------------------------
DragonTreasureView.TimesAwardItem = BaseClass(BaseRender)
local TimesAwardItem = DragonTreasureView.TimesAwardItem
function TimesAwardItem:__init()
end

function TimesAwardItem:__delete()

end

function TimesAwardItem:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree["img_box"].node, BindTool.Bind(self.OnBox, self), true)
end

function TimesAwardItem:OnFlush()
	if nil == self.data then return end
	local need_times = self.data.times
	local tab_list = ActivityBrilliantData.Instance:GetDragonTreasureTimesAward()
	local boor = (tab_list[33 - self.index] == 1)
	self.node_tree["img_box"].node:loadTexture(ResPath.GetDragonTreasure("box_" .. self.index))
	self.node_tree["img_box"].node:setTouchEnabled(not boor)
	-- self.node_tree["img_box"].node:setGrey(not boor)
	self.node_tree["img_received"].node:setVisible(boor)

	self.node_tree["lbl_need_times"].node:setString(string.format(Language.DragonTreasure.NeedTimes, need_times))

	local buy_times = ActivityBrilliantData.Instance:GetDragonTreasureData().buy_times
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.LZMB).config.timesAward[self.index]
	self:SetRemind((not boor) and buy_times >= cfg.times)
end

function TimesAwardItem:SetRemind(vis, path, x, y)
	path = path or ResPath.GetMainui("remind_flag")
	local size = self.view:getContentSize()
	x = x or size.width - 15
	y = y or size.height - 17
	if vis and nil == self.remind_bg_sprite then		
		self.remind_bg_sprite = XUI.CreateImageView(x, y, path, true)
		self.view:addChild(self.remind_bg_sprite, 1, 1)
	elseif self.remind_bg_sprite then
		self.remind_bg_sprite:setVisible(vis)
	end
end

-- "宝箱"点击回调
function TimesAwardItem:OnBox()
	DragonTreasureData.Instance:SetShipForce(true)
	DragonTreasureData.Instance:SetTimesTreasureIndex(self.index)
	ViewManager.Instance:Open(ViewName.TimesTreasure)
end

function TimesAwardItem:CreateSelectEffect()
	return
end

function TimesAwardItem:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end

----------------------------------------
-- 秘宝项目 ph_treasure_item
----------------------------------------
DragonTreasureView.TreasureItem = BaseClass(BaseRender)
local TreasureItem = DragonTreasureView.TreasureItem
function TreasureItem:__init()
	self.rich_count = nil
end

function TreasureItem:__delete()
	self.rich_count = nil
end

function TreasureItem:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree["img_treasure"].node, BindTool.Bind(self.OnTreasure, self), true)
end

function TreasureItem:OnFlush()
	if nil == self.data then return end
	local img = ResPath.GetDragonTreasure("dragon_treasure_" .. self.index)
	local data = ActivityBrilliantData.Instance:GetDragonTreasureData()

	local times = data[self.index]
	local node = self.rich_count or self.node_tree["rich_count"].node
	local times_text = times > 0 and "{color;1eff00;20;" .. times .. "}" or "{color;ff2828;20;" .. times .."}"
	local text = string.format(Language.DragonTreasure.TreasureTimes, times_text)

	self.node_tree["img_treasure"].node:loadTexture(img)
	RichTextUtil.ParseRichText(node, text, 17, COLOR3B.GOLD)
	XUI.RichTextSetCenter(node)
	self.rich_count = node

	self:SetRemind(times > 0)
end

function TreasureItem:SetRemind(vis, path, x, y)
	path = path or ResPath.GetMainui("remind_flag")
	local size = self.view:getContentSize()
	x = x or size.width - 15
	y = y or size.height - 17
	if vis and nil == self.remind_bg_sprite then		
		self.remind_bg_sprite = XUI.CreateImageView(x, y, path, true)
		self.view:addChild(self.remind_bg_sprite, 1, 1)
	elseif self.remind_bg_sprite then
		self.remind_bg_sprite:setVisible(vis)
	end
end

-- "秘宝"点击回调
function TreasureItem:OnTreasure()
	DragonTreasureData.Instance:SetShipForce(true)
	DragonTreasureData.Instance:SetTreasureIndex(self.index)
	ViewManager.Instance:Open(ViewName.TreasureJackpot)
end

function TreasureItem:CreateSelectEffect()
	return
end

function TreasureItem:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end
