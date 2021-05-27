--------------------------------------------------------
-- 秘宝奖池  配置 
--------------------------------------------------------

TreasureJackpotView = TreasureJackpotView or BaseClass(XuiBaseView)

function TreasureJackpotView:__init()
	self.texture_path_list[1] = 'res/xui/dragon_treasure.png'
	-- self:SetModal(false)
	self:SetIsAnyClickClose(true)
	self.config_tab = {
		{"dragon_treasure_ui_cfg", 2, {0}},
	}

	self.index = nil
	self.left_open_times = nil
end

function TreasureJackpotView:__delete()
end

--释放回调
function TreasureJackpotView:ReleaseCallBack()
	if nil ~= self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if nil ~= self.log_view then
		self.log_view:DeleteMe()
		self.log_view = nil
	end

	self.left_open_times = nil
	self.log_list = nil
end

--加载回调
function TreasureJackpotView:LoadCallBack(index, loaded_times)
	self:CreateCell()
	self:CreateLogView()
	self:CreateTextBtn()
	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_open"].node, BindTool.Bind(self.OnOpen, self, 2))
end

function TreasureJackpotView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function TreasureJackpotView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function TreasureJackpotView:ShowIndexCallBack(index)
	self.index = DragonTreasureData.Instance:GetTreasureIndex(self.index) or 1
	self.node_t_list["img_box_open"].node:setVisible(false)
	self.node_t_list["img_box_close"].node:setVisible(true)
	self.item_cell:GetView():setVisible(false)

	self.node_t_list["img_tab"].node:loadTexture(ResPath.GetDragonTreasure("treasure_tab_" .. self.index))

	self:Flush()

	ActivityBrilliantData.Instance:GetDragonTreasureAllLog()
end

function TreasureJackpotView:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "all" then
			self:SetOpenBtnEnabled()
			self:FlushLeftOpenTimes()	
			self:FlushLogView()
		elseif k == "cell_run_action" then
			-- 判断宝箱是否对应,是才执行开启动作
			if v.index == self.index then
				self:InitCellRunAction()
			end
		elseif k == "flush_left_times" then
			self:FlushLeftOpenTimes()
		end
	end

end

----------视图函数----------

-- 创建"公告"视图
function TreasureJackpotView:CreateLogView()
	local ph_item = self.ph_list["ph_log_item"]
	local ph = self.ph_list["ph_log"]
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.h + 1, self.LogItem, ScrollDir.Vertical, false, ph_item)
	-- grid_scroll:GetView():setAnchorPoint(0, 0)
	self.node_t_list["layout_treasure"].node:addChild(grid_scroll:GetView(), 20)
	self.log_view = grid_scroll
end

-- 刷新全服记录
function TreasureJackpotView:FlushLogView()
	local log_list = ActivityBrilliantData.Instance:GetDragonTreasureAllLog()
	if self.log_list ~= log_list then
		self.log_view:SetDataList(log_list)
	end
	self.log_list = log_list
end

-- 刷新剩余开启次数
function TreasureJackpotView:FlushLeftOpenTimes()
	local node = self.left_open_times or self.node_t_list["rich_left_open_times"].node

	local data = ActivityBrilliantData.Instance:GetDragonTreasureData()
	local left_times = data[self.index] or 0
	local left_times_str = left_times < 1 and "{color;ff2828;20;" .. left_times .. "}" or "{color;1eff00;20;" .. left_times .. "}" --当剩余开启次数小于1时，改变成红色
	local text = string.format(Language.DragonTreasure.LeftOpenTimes, left_times_str)
	node = RichTextUtil.ParseRichText(node, text, 20, COLOR3B.GOLD)
	XUI.RichTextSetCenter(node)
	self.left_open_times = node
end

-- 设置"开启按钮"触摸功能
function TreasureJackpotView:SetOpenBtnEnabled()
	local data = ActivityBrilliantData.Instance:GetDragonTreasureData()
	local left_times = data[self.index] or 0
	if left_times > 0 then
		self:BoxAction()
	end
	self.node_t_list["btn_open"].node:setEnabled(left_times > 0)
end

function TreasureJackpotView:CreateCell()
	if nil == self.item_cell then
		local ph = self.ph_list["ph_cell"]
		local item_cell = BaseCell.New()
		item_cell:GetView():setAnchorPoint(1, 0)
		item_cell:GetView():setPosition(ph.x, ph.y)
		item_cell:GetView():setVisible(false)
		self.node_t_list["layout_treasure"].node:addChild(item_cell:GetView(), 10)
		self.item_cell = item_cell
	end
end

-- 宝箱晃动动作
function TreasureJackpotView:BoxAction()
	local node = self.node_t_list["img_box_close"].node
	node:stopAllActions()
	node:setRotation(0)

	local act_info = {{0.1, 0.015}, {0.2, -0.03}, {0.2, 0.03}, {0.1, -0.015}}
	local act_t = {}
	for i, v in pairs(act_info) do
		act_t[i] = cc.RotateBy:create(v[1], v[2] * 360)
	end
	local seq_act = cc.Sequence:create(unpack(act_t))
	local seq_act = cc.Sequence:create(seq_act, cc.DelayTime:create(1))
	local seq_act = cc.Repeat:create(seq_act, 9999999)
	node:runAction(seq_act)
end

function TreasureJackpotView:InitCellRunAction()
	local results = ActivityBrilliantData.Instance:GetDragonTreasureResults()
	if type(results) ~= "table" and results.type ~= 3 then
		Log("非法调用物品跳出动作")
		return
	end
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.LZMB)
	local item = cfg.config.things[results.box_index][results.item_index]
	item = ItemData.InitItemDataByCfg(item)
	self.item_cell:SetData(item)

	self.node_t_list["img_box_open"].node:setVisible(true)
	self.node_t_list["img_box_close"].node:setVisible(false)
	self.node_t_list["img_box_close"].node:stopAllActions()

	self.item_cell:GetView():setScale(0)
	self.item_cell:GetView():setVisible(true)
	self:CellRunAction()
end

-- 物品跳出动作
function TreasureJackpotView:CellRunAction()
	local node = self.item_cell:GetView()
	local ph = self.ph_list.ph_cell
	local act_jump_1 = cc.JumpTo:create(0.5, cc.p(ph.x,ph.y),50, 1)
	local func = cc.CallFunc:create(BindTool.Bind(function() 
		ItemData.Instance:SetDaley(false)
		if (not self:IsOpen()) then return print("跳出") end
		self.node_t_list["btn_open"].node:setEnabled(true)
		self:FlushLogView()
		end))
	local seq_act = cc.Spawn:create(act_jump_1, cc.ScaleTo:create(0.5, 1))
	local seq_act = cc.Sequence:create(seq_act, func)
	node:stopAllActions()
	node:setPosition(ph.x, ph.y)
	node:runAction(seq_act)
end

-- 创建"奖励预览"按钮
function TreasureJackpotView:CreateTextBtn()
	local ph = self.ph_list["ph_text_btn"]
	local text = RichTextUtil.CreateLinkText(Language.DragonTreasure.AwardPreview, 21, COLOR3B.GREEN, nil, true)
	text:setPosition(ph.x, ph.y)
	self.node_t_list["layout_treasure"].node:addChild(text, 20)
	XUI.AddClickEventListener(text, BindTool.Bind(self.OnTextBtn, self), true)
end

----------end----------

function TreasureJackpotView:OnOpen()
	self.node_t_list["btn_open"].node:setEnabled(false)
	ItemData.Instance:SetDaley(true)
	ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.LZMB, 3, self.index)
end

function TreasureJackpotView:OnTextBtn()
	ViewManager.Instance:Open(ViewName.TreasureAwardPreview)
end

--------------------

----------------------------------------
-- 公告Item
----------------------------------------
TreasureJackpotView.LogItem = BaseClass(BaseRender)
local LogItem = TreasureJackpotView.LogItem
function LogItem:__init()
	self.rich_log = nil
end

function LogItem:__delete()
	self.rich_log = nil
end

function LogItem:CreateChild()
	BaseRender.CreateChild(self)
end

function LogItem:OnFlush()
	if nil == self.data then return end
	local index = tonumber(self.data.index) -- 宝箱索引
	local item_index = tonumber(self.data.item_index)
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.LZMB).config 	 -- 活动配置
	if not(type(cfg) == "table" and cfg.things and cfg.things[index] and cfg.things[index][item_index]) then return end
	local item_id = cfg.things[index][item_index].id 				 -- 物品ID
	local item_cfg = ItemData.Instance:GetItemConfig(item_id) 							 -- 物品配置
	if nil == item_cfg then return end
	local item_name = string.format("{color;%06x;17;%s}", item_cfg.color, item_cfg.name) -- 物品名字
	local role_name = string.format("{color;1eff00;17;%s}", self.data.name) 			 -- 人物名字
	local text =  role_name.. Language.DragonTreasure.TreasureName[index] .. item_name 	 -- 连接字符串
	
	local node = self.rich_log or self.node_tree["rich_log"].node 						 -- 文本节点
	node = RichTextUtil.ParseRichText(node, text, 17, COLOR3B.GOLD)
	XUI.RichTextSetCenter(node)
	self.rich_log = node
end

function LogItem:CreateSelectEffect()
	return
end

function LogItem:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end
