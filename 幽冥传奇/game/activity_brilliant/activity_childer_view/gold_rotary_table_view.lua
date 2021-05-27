--------------------------------------------------------
-- 运营活动33 元宝大转盘
--------------------------------------------------------
GoldRotaryTableView = GoldRotaryTableView or BaseClass(ActBaseView)

function GoldRotaryTableView:__init(view, parent, act_id)
	self:LoadView(parent)

	self.need_play_actions = true
	self.play_type = 1
end

function GoldRotaryTableView:__delete()
	if self.feedback_list then
		self.feedback_list:DeleteMe()
		self.feedback_list = nil
	end

	if self.record_list then
		self.record_list:DeleteMe()
		self.record_list = nil
	end

	if self.jackpot_num then
		self.jackpot_num:DeleteMe()
		self.jackpot_num = nil
	end

	if self.add_num then
		self.add_num:DeleteMe()
		self.add_num = nil
	end

	if self.buy_cell then
		self.buy_cell:DeleteMe()
		self.buy_cell = nil
	end

	if self.buy_list then
		self.buy_list:DeleteMe()
		self.buy_list = nil
	end

	if self.cell_list then
		for i,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.buy_list = nil
	end

	if self.num_list then
		for i,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.buy_list = nil
	end

	if self.tip_cell_list then
		self.tip_cell_list:DeleteMe()
		self.tip_cell_list = nil
	end
end

function GoldRotaryTableView:InitView()
	self:InitNode()
	self:CreateNumber()
	self:CreateFeedbackList()
	self:CreateRecordList()
	self:CreateCellListAndNumList()

	XUI.AddClickEventListener(self.node_t_list["layout_skip"].node, BindTool.Bind(self.OnSkip, self))
	XUI.AddClickEventListener(self.node_t_list["btn_play"].node, BindTool.Bind(self.OnPlay, self))
	XUI.AddClickEventListener(self.node_t_list["layout_item_tip"].node, BindTool.Bind(self.CloseTip, self))
	XUI.AddClickEventListener(self.node_t_list["layout_buy_tip"].node, BindTool.Bind(self.CloseBuyTip, self))
	XUI.AddClickEventListener(self.node_t_list["btn_close_buy_tip"].node, BindTool.Bind(self.CloseBuyTip, self))
	XUI.AddClickEventListener(self.node_t_list["layout_10_play"].node, BindTool.Bind(self.SetPlayType, self, 2))
	XUI.AddClickEventListener(self.node_t_list["layout_50_play"].node, BindTool.Bind(self.SetPlayType, self, 3))
	XUI.AddClickEventListener(self.node_t_list["btn_tip"].node, BindTool.Bind(self.OnClickActTipHandler, self))

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function GoldRotaryTableView:ShowIndexView()
	self.need_play_actions = true
	self.node_t_list["img_tick"].node:setVisible(false)
	self.node_t_list["btn_play"].node:setEnabled(true)

	local item_name_list = ActivityBrilliantData.Instance:GetTurntableList()
	self.record_list:SetDataList(item_name_list)

	self:CloseTip()
	self:CloseBuyTip()
	self:SetPlayType(1)
	self:FlushConsumeCount()
end

function GoldRotaryTableView:CloseCallback()
	self:CloseTip()
	BagData.Instance:SetDaley(false)
end

function GoldRotaryTableView:RefreshView(param_list)
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.GOLDZP) or {}
	self.jackpot_num:SetNumber(ActivityBrilliantData.Instance:GetJackpotNum())
	self.add_num:SetNumber(cfg.config.addYb or 0)
	local reward_list = ActivityBrilliantData.Instance:GetTurntableRewardList() or {}
	self.feedback_list:SetDataList(reward_list)
	self.feedback_list:JumpToTop()

	for k,v in pairs(param_list) do
		-- 单次抽奖才播放转盘动作
		if k == "flush_view" then 
			if v.result == 1 then
				if self.need_play_actions and v.award_list and v.award_list[1] then
					self.award_index = v.award_list[1].grid_index
					self:FlushAction()
				else
					self:OnTableActionChange()
				end
			elseif v.result == 2 and v.result == 3 then
				local item_name_list = ActivityBrilliantData.Instance:GetTurntableList()
				self.record_list:SetDataList(item_name_list)
			end
		end
	end
end

----------视图函数----------

function GoldRotaryTableView:InitNode()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.GOLDZP) or {}
	local consumes = cfg.config.draw_consume and cfg.config.draw_consume.consumes or {}
	self.consume_id = consumes[1] and consumes[1].id or 0
	local item_cfg = ItemData.Instance:GetItemConfig(self.consume_id)
	self.node_t_list["img_consume_icon"].node:loadTexture(ResPath.GetItem(item_cfg.icon))
	self.node_t_list["img_consume_icon"].node:setScale(0.5)

	self.node_t_list["img_pointer"].node:setAnchorPoint(0.5, 0.37)
	self.node_t_list["img_tick"].node:setVisible(false)
	self.node_t_list["img_tick_10"].node:setVisible(false)
	self.node_t_list["img_tick_50"].node:setVisible(false)

	XUI.EnableOutline(self.node_t_list["lbl_consume_count"].node)

	self.node_t_list["layout_item_tip"].node:setLocalZOrder(999)
	self.node_t_list["layout_item_tip"].node:setBackGroundColor(COLOR3B.BLACK)
	self.node_t_list["layout_item_tip"].node:setBackGroundColorOpacity(180)

	self.node_t_list["layout_buy_tip"].node:setLocalZOrder(1000)
	self.node_t_list["layout_buy_tip"].node:setBackGroundColor(COLOR3B.BLACK)
	self.node_t_list["layout_buy_tip"].node:setBackGroundColorOpacity(180)
end

function GoldRotaryTableView:CreateFeedbackList()
	local ph = self.ph_list["ph_feedback_list"]
	self.feedback_list = ListView.New()
	self.feedback_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, self.FeedbackItem, nil, nil, self.ph_list["ph_feedback_item"])
	self.feedback_list:SetItemsInterval(10)
	self.feedback_list:SetJumpDirection(ListView.Top) -- 刷新后自动跳转
	self.node_t_list["layout_gold_rotary_table"].node:addChild(self.feedback_list:GetView(), 10)
end


function GoldRotaryTableView:CreateRecordList()
	local ph = self.ph_list["ph_record_list"]
	self.record_list = ListView.New()
	self.record_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, self.RecordItem, nil, nil, self.ph_list["ph_record_item"])
	self.record_list:SetItemsInterval(5)
	self.node_t_list["layout_gold_rotary_table"].node:addChild(self.record_list:GetView(), 10)
end

function GoldRotaryTableView:CreateNumber()
	local ph = self.ph_list["ph_num_5"]
	local path = ResPath.GetCommon("num_9_")
	local parent = self.node_t_list["layout_gold_rotary_table"].node
	local number_bar = NumberBar.New()
	number_bar:Create(ph.x, ph.y, ph.w, ph.h, path)
	number_bar:SetSpace(-5)
	number_bar:SetGravity(NumberBarGravity.Center)
	parent:addChild(number_bar:GetView(), 99)
	self.jackpot_num = number_bar

	local ph = self.ph_list["ph_num_6"]
	local path = ResPath.GetCommon("num_8_")
	local parent = self.node_t_list["layout_gold_rotary_table"].node
	local number_bar = NumberBar.New()
	number_bar:Create(ph.x, ph.y, ph.w, ph.h, path)
	number_bar:SetSpace(-5)
	number_bar:SetGravity(NumberBarGravity.Center)
	parent:addChild(number_bar:GetView(), 99)
	self.add_num = number_bar
end

function GoldRotaryTableView:CreateCellListAndNumList()
	self.cell_list = {}
	self.num_list = {}
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.GOLDZP) or {}
	local center_x, center_y = self.node_t_list["img_pointer"].node:getPosition() -- 以img_pointer的坐标为中心点
	local r = 135 -- 半径
	local max_count = #(cfg.config.award_pool or {})
	for i,v in ipairs(cfg.config.award_pool or {}) do

		if i % 3 ~= 1 then
			local angle = (i - 1) * 360 / max_count
			local x = center_x + r * math.sin(math.rad(angle))
			local y = center_y + r * math.cos(math.rad(angle))
			local cell = ActBaseCell.New()
			cell:GetView():setPosition(x, y)
			cell:GetView():setScale(0.6)
			cell:GetView():setAnchorPoint(0.5, 0.5)
			cell:SetIsShowTips(false)
			cell:SetClickCallBack(BindTool.Bind(self.OpenTip, self, v))
			local item_cfg = ItemData.Instance:GetItemConfig(v.show_id or 0)
			cell:SetData(item_cfg)
			self.node_t_list["layout_gold_rotary_table"].node:addChild(cell:GetView(), 1)
			self.cell_list[i] = cell
		else
			local ph = self.ph_list["ph_num_" .. i] or {x = 0, y = 0, w = 10, h = 10}
			local number_bar, number_bar_parent = self:CreateNumBar()
			number_bar_parent:setPosition(ph.x, ph.y)
			self.num_list[i] = number_bar
					
			local award = v.awards and v.awards[1] or {} 
			local percent = award and award.percent and award.percent * 100 or 0
			number_bar:SetNumber(percent)

			local y_x = 9 -- 每个数字一半间距
			if percent >= 1000 then
				y_x = y_x * 4
			elseif percent >= 100 then
				y_x = y_x * 3
			elseif percent >= 10 then
				y_x = y_x * 2
			end

			local img_percent = XUI.CreateImageView(y_x, 14.5, ResPath.GetActivityBrilliant("act_33_9"), true)
			self.tree.node:addChild(number_bar_parent, 300, 300)
			number_bar_parent:addChild(img_percent, 300, 300)
		end
	end
end

function GoldRotaryTableView:CreateNumBar()
	local layout = XUI.CreateLayout(0, 0, 0, 0)
	local number_bar = NumberBar.New()
	number_bar:SetRootPath(ResPath.GetCommon("num_14_"))
	number_bar:SetGravity(NumberBarGravity.Center)
	number_bar:SetSpace(-5)
	number_bar:SetPosition(-14.5, 0) -- x轴效准"money_type_1"宽度的一半,以达到居中的效果
	layout:addChild(number_bar:GetView(), 1)
	return number_bar, layout
end

function GoldRotaryTableView:FlushConsumeCount()
	local count = BagData.Instance:GetItemNumInBagById(self.consume_id or 0)
	self.can_play = count >= self.need_consume_count
	local color = self.can_play and COLOR3B.GREEN or COLOR3B.RED
	self.node_t_list["lbl_consume_count"].node:setString(count)
	self.node_t_list["lbl_consume_count"].node:setColor(color)
end

function GoldRotaryTableView:FlushAction()
	if self.award_index == 0 then return end
	local item_index = self.award_index
	self.node_t_list['img_pointer'].node:stopAllActions()

	local act_info = {{0.5, 0.5}, {0.3, 0.5}, {0.2, 0.5}, {1.5, 5}} -- 启动动作
	local act_info_item ={{0.18, 0.6}, {0.16, 0.4}, {0.2, 0.4}, {0.25, 0.4}, {0.15, 0.2}, {0.25, 0.25}, {0.4, 0.2}, {0.15, 0.05}} -- 停止前的缓冲动作

	local current_angle = self.node_t_list['img_pointer'].node:getRotation()
	local item_Angle = ((item_index - 1) * 360 / 12 - current_angle%360)%360
	local ratio = (item_Angle  + 900) / 900 -- 900 是缓冲动作的旋转角度
	for k,v in pairs(act_info_item) do
		table.insert(act_info, {(v[1] * ratio), (v[2] * ratio)})
	end

	local act_t = {}
	for i, v in pairs(act_info) do
		act_t[i] = cc.RotateBy:create(v[1], v[2] * 360)
	end

	local seq_act = cc.Sequence:create(unpack(act_t))
	local seq_act = cc.Sequence:create(seq_act, cc.CallFunc:create(BindTool.Bind(self.OnTableActionChange, self)))
	self.node_t_list['img_pointer'].node:runAction(seq_act)
end

--------------------

function GoldRotaryTableView:UpdateSpareTime(end_time)
	local now_time = TimeCtrl.Instance:GetServerTime()
	local str = TimeUtil.FormatSecond2Str(end_time - now_time)
	self.node_t_list["lbl_time"].node:setString(str)
end

function GoldRotaryTableView:OnTableActionChange()
	BagData.Instance:SetDaley(false)
	
	if self.node_t_list['btn_play'] then
		self.node_t_list['btn_play'].node:setEnabled(true)
	end

	if self.record_list then
		local item_name_list = ActivityBrilliantData.Instance:GetTurntableList()
		self.record_list:SetDataList(item_name_list)
	end
end

function GoldRotaryTableView:OnSkip()
	local vis = self.node_t_list["img_tick"].node:isVisible()
	self.node_t_list["img_tick"].node:setVisible(not vis)
	self.need_play_actions = vis and self.play_type == 1
end

-- 设置抽奖类型 1-抽1次 2-抽10次 3-抽50次
function GoldRotaryTableView:SetPlayType(_type)
	if self.play_type ~= _type then
		self.play_type = _type
	else
		self.play_type = 1
	end

	self.node_t_list["img_tick_10"].node:setVisible(self.play_type == 2)
	self.node_t_list["img_tick_50"].node:setVisible(self.play_type == 3)

	local vis = self.node_t_list["img_tick"].node:isVisible()
	self.need_play_actions = not vis and self.play_type == 1

	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.GOLDZP) or {}
	local counts_list = cfg.config.draw_consume and cfg.config.draw_consume.counts or {}
	self.need_consume_count = counts_list[self.play_type] or 1

	self:FlushConsumeCount()
end

-- '抽奖按钮'点击回调
function GoldRotaryTableView:OnPlay()
	if self.can_play then
		if self.play_type == 1 and self.need_play_actions then
			BagData.Instance:SetDaley(true)
		end
		self.node_t_list['btn_play'].node:setEnabled(false)
		local act_id = ACT_ID.GOLDZP
		ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, 1, self.play_type)
	else
		self:OpenBuyTip()
	end
end

function GoldRotaryTableView:OpenBuyTip()
	self.node_t_list["layout_buy_tip"].node:setVisible(true)

	if nil == self.buy_cell then
		local item_cfg = ItemData.Instance:GetItemConfig(self.consume_id)
		local ph = self.ph_list["ph_buy_cell"]
		local cell = ActBaseCell.New()
		cell:GetView():setAnchorPoint(0.5, 0.5)
		cell:GetView():setPosition(ph.x, ph.y)
		cell:SetData(item_cfg)
		self.buy_cell = cell
		self.node_t_list["layout_buy_tip"].node:addChild(cell:GetView(), 20)

		local color = Str2C3b(string.format("%06x", item_cfg.color))
		self.node_t_list["lbl_buy_name"].node:setString(item_cfg.name)
		self.node_t_list["lbl_buy_name"].node:setColor(color)
	end

	if nil == self.buy_list then
		local ph = self.ph_list["ph_buy_list"]
		self.buy_list = ListView.New()
		self.buy_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, self.BuyItem, nil, nil, self.ph_list["ph_buy_item"])
		self.buy_list:SetItemsInterval(5)
		self.buy_list:SetJumpDirection(ListView.Top)
		self.node_t_list["layout_buy_tip"].node:addChild(self.buy_list:GetView(), 20)

		local cfg = ActivityBrilliantData.Instance:GetOperActCfg(self.act_id)
		local buy_key = cfg.config.buy_key or {}
		self.buy_list:SetDataList(buy_key)
	end
end

function GoldRotaryTableView:OpenTip(cfg)
	-- local rich = self.node_t_list["rich_item_list"].node
	-- local text = ""
	-- for i, v in ipairs(cfg.awards or {}) do
	-- 	local item_cfg = ItemData.Instance:GetItemConfig(v.id)
	-- 	local count = v.count
	-- 	local color = string.format("%06x", item_cfg.color)
	-- 	text = text .. string.format("{eq;%s;%s;%s}{color;%s;X%s}\n", color, item_cfg.name , item_cfg.item_id, color, count)
	-- end

	-- rich = RichTextUtil.ParseRichText(rich, text, 18)
	-- rich:refreshView()

	-- self.node_t_list["layout_item_tip"].node:setVisible(true)

	-- awards = 
	-- {
	-- 	{type = 0,id = 522,count = 2,bind = 1, rate=500, istip = 1,},--200绑元券  X 1
	-- 	{type = 0,id = 844,count = 1,percent = 0.30, rate = 0, istip = 0,},--	30%奖金池
	-- 	{type = 0,id = 513,count = 2,bind = 1, rate=3500, istip = 1,},--经验丹(大)  X 1
	-- 	{type = 0,id = 678,count = 2,bind = 1, rate=5000, istip = 1,},--副本传送卷 X 1
	-- 	{type = 0,id = 844,count = 1,percent = 0.50, rate = 0, istip = 0,},--	50%奖金池
	-- 	{type = 0,id = 522,count = 2,bind = 1, rate=5500, istip = 1,},--200绑元券  X 1
	-- 	{type = 0,id = 513,count = 2,bind = 1, rate=7500, istip = 1,},--经验丹(大)  X 1
	-- 	{type = 0,id = 844,count = 1,percent = 0.10, rate = 0, istip = 0,},--	10%奖金池
	-- 	{type = 0,id = 678,count = 2,bind = 1, rate=10000, istip = 1,},--副本传送卷 X 1
	-- 	{type = 0,id = 844,count = 1,percent = 1.00, rate = 0, istip = 0,},--	100%奖金池
	-- },

	if nil == self.tip_cell_list then
		local ph = self.ph_list["ph_item_list"] or {x = 0, y = 0, w = 10, h = 10}
		local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
		local parent = self.node_t_list["layout_item_tip"].node
		local render = ActBaseCell

		self.tip_cell_list = GridScroll.New()
		self.tip_cell_list:Create(ph.x, ph.y, ph.w, ph.h, 4, ph_item.h + 20, render, ScrollDir.Vertical, false, ph_item)
		parent:addChild(self.tip_cell_list:GetView(), 20)
	end

	local awards = {}
	for i, v in ipairs(cfg.awards or {}) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.id)
		awards[i] = ItemData.InitItemDataByCfg(v)
	end
	self.tip_cell_list:SetDataList(awards)
	self.tip_cell_list:JumpToTop()

	self.node_t_list["layout_item_tip"].node:setVisible(true)
end

function GoldRotaryTableView:CloseTip()
	if self.node_t_list["layout_item_tip"] then
		self.node_t_list["layout_item_tip"].node:setVisible(false)
	end
end

function GoldRotaryTableView:CloseBuyTip()
	if self.node_t_list["layout_buy_tip"] then
		self.node_t_list["layout_buy_tip"].node:setVisible(false)
	end
end

function GoldRotaryTableView:OnBagItemChange(event)
	event.CheckAllItemDataByFunc(function (vo)
		local item_id = vo.data.item_id
		if vo.change_type == ITEM_CHANGE_TYPE.LIST then
		elseif item_id == self.consume_id then
			self:FlushConsumeCount()
		end
	end)
end

function GoldRotaryTableView:OnClickActTipHandler()
	local cfg = ActivityBrilliantData.Instance:GetOperActCfg(self.act_id)
	local act_desc = Split(cfg.act_desc, "#") --#号之后为btn_act_tips文本
	DescTip.Instance:SetContent(act_desc[2] or act_desc[1], Language.ActivityBrilliant.ActTip)
end

----------------------------------------
-- 抽奖回馈Item
----------------------------------------
GoldRotaryTableView.FeedbackItem = BaseClass(BaseRender)
local FeedbackItem = GoldRotaryTableView.FeedbackItem
function FeedbackItem:__init()

end

function FeedbackItem:__delete()
	if self.award_list then
		self.award_list:DeleteMe()
		self.award_list = nil
	end
end

function FeedbackItem:CreateChild()
	BaseRender.CreateChild(self)

	local ph = self.ph_list["ph_awrad_list"]
	self.award_list = ListView.New()
	self.award_list:Create(ph.x, ph.y, ph.w, ph.h * 2, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	self.award_list:SetItemsInterval(10)
	self.view:addChild(self.award_list:GetView(), 10)
	self.award_list:GetView():setScale(0.75)

	XUI.AddClickEventListener(self.node_tree["btn_get"].node, BindTool.Bind(self.OnClickGet, self))
end

function FeedbackItem:OnFlush()
	if nil == self.data then return end
	local rich = self.node_tree["rich_times"].node
	local text = string.format("累计抽奖{color;1eff00;%d}次", self.data.count)
	rich = RichTextUtil.ParseRichText(rich, text, 18, Str2C3b("dfd697"))
	rich:refreshView()

	local award_data = {}
	for i,v in ipairs(self.data.awards) do
		award_data[i] = ItemData.InitItemDataByCfg(v)
	end
	self.award_list:SetDataList(award_data)
	self.award_list:JumpToTop()

	local can_get = self.data.draw_num >= self.data.count
	local draw_num = can_get and self.data.count or self.data.draw_num
	local color = can_get and COLOR3B.GREEN or COLOR3B.RED
	self.node_tree["lbl_times"].node:setString(string.format("(%d/%d)", draw_num, self.data.count))
	self.node_tree["lbl_times"].node:setColor(color)
	
	self.node_tree["btn_get"].node:setEnabled(can_get)
	self.node_tree["btn_get"].node:setVisible(self.data.sign ~= 1)
	self.node_tree["lbl_times"].node:setVisible(self.data.sign ~= 1)
	self.node_tree["img_stamp"].node:setVisible(self.data.sign ~= 0)
end

function FeedbackItem:OnClickGet()
	if type(self.data) == "table" then
		local act_id = ACT_ID.GOLDZP
		ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, 3, self.data.index)
	end
end

function FeedbackItem:CreateSelectEffect()
	return
end

function FeedbackItem:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end

----------------------------------------
-- 全服公告Item
----------------------------------------
GoldRotaryTableView.RecordItem = BaseClass(BaseRender)
local RecordItem = GoldRotaryTableView.RecordItem
function RecordItem:__init(width, height, list_view)
	self.list_view =  list_view
end

function RecordItem:__delete()

end

function RecordItem:CreateChild()
	BaseRender.CreateChild(self)
end

function RecordItem:OnFlush()
	if nil == self.data then return end
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(33)
	if nil == cfg then return end
	local award_pool = cfg.config.award_pool or {}
	local grid_index = tonumber(self.data.grid_index or 0)
	local award_index = tonumber(self.data.award_index or 0)
	local awards = award_pool[grid_index] and award_pool[grid_index].awards or {}
	local award = awards[award_index] or {}
	
	local item_data = ItemData.InitItemDataByCfg(award)
	local item_cfg = ItemData.Instance:GetItemConfig(item_data.item_id)
	local item_color = string.format("%06x", item_cfg.color)
	local playername = Scene.Instance:GetMainRole():GetName()
	local text = {}
	local rolename_color = ""
	if playername == self.data.name then
		rolename_color = "CCCCCC"
	else
		rolename_color = "FFFF00"
	end
	local item_name = ItemData.Instance:GetItemName(item_cfg.item_id)

	local rich = self.node_tree["rich_record"].node
	if award.type ~= tagAwardType.qatEquipment then
		-- 字体颜色强制用红色
		count = self.data.num or 0
		percent = (award.percent or 0) * 100
		rolename_color = COLORSTR.RED
		item_color = COLORSTR.RED
		-- ［玩家名字抽到5%钻石奖池，获得300钻石
		local text = string.format(Language.ActivityBrilliant.Text37,
		 rolename_color, rolename_color, self.data.name, rolename_color, item_color,  percent, item_cfg.name, item_color, count, item_cfg.name)
		rich = RichTextUtil.ParseRichText(rich, text, 18, COLOR3B.RED)
	else
		count = item_data.num or 0
		-- ［玩家名字］获得【物品名称】x数量
		local text = string.format(Language.ActivityBrilliant.Txt, rolename_color, rolename_color, self.data.name, rolename_color, Language.XunBao.Prefix, item_color, item_cfg.name, item_cfg.item_id, item_color,count)
		rich = RichTextUtil.ParseRichText(rich, text, 18, Str2C3b("dcd7c4"))
	end


	rich:refreshView()
	self:UpdataLayout()
end

-- 更新布局
function RecordItem:UpdataLayout()
	-- 计算大小
	local final_h = 0
	local content_render_size = self.node_tree["rich_record"].node:getInnerContainerSize()
	final_h = final_h + content_render_size.height
	if final_h < 20 then final_h = 20 end
	local view_size = self.view:getContentSize()
	if view_size.height ~= final_h then
		self.view:setContentWH(view_size.width, final_h) -- 调整item的布局大小
		self.list_view:requestRefreshView()				 -- 刷新list_view
	end

	self.node_tree["rich_record"].node:setPosition(10, final_h)
end

function RecordItem:CreateSelectEffect()
	return
end

function RecordItem:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end

----------------------------------------
-- 项目渲染命名
----------------------------------------
GoldRotaryTableView.BuyItem = BaseClass(BaseRender)
local BuyItem = GoldRotaryTableView.BuyItem
function BuyItem:__init()
	self.item_cell = nil
end

function BuyItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil
	end
end

function BuyItem:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list["ph_cell"]
	local cell = ActBaseCell.New()
	cell:GetView():setPosition(ph.x, ph.y)
	cell:GetView():setAnchorPoint(0.5, 0.5)
	cell:SetIsShowTips(false)
	self.view:addChild(cell:GetView(), 20)
	self.item_cell = cell

	XUI.AddClickEventListener(self.node_tree["btn_buy"].node, BindTool.Bind(self.OnBuy, self))
end

function BuyItem:OnFlush()
	if nil == self.data then return end
	local award = self.data.awards and self.data.awards[1] or {}
	local item_cfg = ItemData.Instance:GetItemConfig(award.id)
	self.item_cell:SetData(item_cfg)

	local color = Str2C3b(string.format("%06x", item_cfg.color))
	self.node_tree["lbl_item_name"].node:setString(item_cfg.name)
	self.node_tree["lbl_item_name"].node:setColor(color)

	local consume = self.data.awards and self.data.consumes[1] or {}
	self.node_tree["lbl_money_count"].node:setString(consume.count or 0)

	self.consume_count = consume.count
end

function BuyItem:OnBuy()
	-- if self.alert then
	-- 	self.alert:Open()
	-- else
	-- 	local text = string.format("是否花费{color;ff2828;%d钻石}购买", self.consume_count)
	-- 	self.alert:SetLableString(text)
	-- 	self.alert:SetOkFunc(function ()
		local act_id = ACT_ID.GOLDZP
		ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, 2, self.index)
	-- 	end)
	-- end
end

function BuyItem:CreateSelectEffect()
	return
end

function BuyItem:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end