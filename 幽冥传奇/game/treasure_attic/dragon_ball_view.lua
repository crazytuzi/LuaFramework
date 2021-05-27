------------------------------------------------------------
-- 龙珠视图 配置 DragonBallConfig
------------------------------------------------------------

local DragonBallView = BaseClass(SubView)

function DragonBallView:__init()
	self.texture_path_list[1] = 'res/xui/dragon_ball.png'
	self.config_tab = {
		{"dragon_ball_ui_cfg", 1, {0}},
	}

	self.type = 1
end

function DragonBallView:__delete()
end

function DragonBallView:ReleaseCallBack()

	if self.grid_scroll then
		self.grid_scroll:DeleteMe()
		self.grid_scroll = nil
	end

	if self.power_view then
		self.power_view:DeleteMe()
		self.power_view = nil
	end

	self.ball_small = nil
	self.type = 1
end

function DragonBallView:LoadCallBack(index, loaded_times)
	self.data = TreasureAtticData.Instance:GetDragonBallData()
	self.ball_cfg = TreasureAtticData.Instance:GetBallCfg()
	self.cfg = DragonBallConfig
	self:CreateTextBtn()
	self:CreatePhaseView()
	self:CreateDragonBall()

	self.node_t_list["btn_absorb"].remind_eff = RenderUnit.CreateEffect(23, self.node_t_list["btn_absorb"].node, 1)
	self.node_t_list["btn_refining"].remind_eff = RenderUnit.CreateEffect(23, self.node_t_list["btn_refining"].node, 1)

	-- 生成战力视图
	local ph = self.ph_list["ph_power_value"]
	self.power_view = FightPowerView.New(ph.x, ph.y,self.node_t_list["layout_dragon_ball"].node, 20, true)
	self.power_view:SetScale(1)
	self.power_view:LoadTexturePower(ResPath.GetCommon("part_101_2"))

	local ph = self.ph_list["ph_phase_num"]
	self.phase_num = NumberBar.New()
	self.phase_num:Create(ph.x, ph.y, 0, 0, ResPath.GetCommon("num_160_"))
    self.phase_num:SetGravity(NumberBarGravity.Left)
	self.node_t_list["layout_dragon_ball"].node:addChild(self.phase_num:GetView(), 101)

	--按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_absorb"].node, BindTool.Bind(self.OnAbsorb, self), true)
	XUI.AddClickEventListener(self.node_t_list["btn_refining"].node, BindTool.Bind(self.OnRefining, self), true)
	XUI.AddClickEventListener(self.node_t_list["btn_suit_attr"].node, BindTool.Bind(self.OnSuitAttr, self), true)

	-- 数据监听
	EventProxy.New(TreasureAtticData.Instance, self):AddEventListener(TreasureAtticData.DRAGON_BALL_DATA_CHANGE, BindTool.Bind(self.OnDragonBallDataChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_COLOR_STONE, BindTool.Bind(self.OnRoleAttrChange, self))
end

--显示索引回调
function DragonBallView:ShowIndexCallBack(index)
	self:Flush()
end

function DragonBallView:OnFlush()
	self:FlushBtn()
	self:FlushBonusView()
	self:FlushConsumeText()
	self:FlushDrgaonBall()
	self:FlushPowerValue() -- 刷新战力值视图

	self.node_t_list["img_star"].node:loadTexture(ResPath.GetDragonBall("img_star_" .. self.type))
	self.node_t_list["lbl_levels"].node:setString(self.data[self.type].level .. "级")
	self.node_t_list["lbl_levels"].node:setVisible(self.data[self.type].level > 0)

	self.phase_num:SetNumber(self.data[self.type].phase)

	local w = self.phase_num.number_bar:getContentSize().width
	w = w > 18 and 4 or 20
	local x = 547 - w
	self.node_t_list["img_phase"].node:setPositionX(x)
	local x = 563 - w
	self.node_t_list["lbl_levels"].node:setPositionX(x)

	self.grid_scroll.items[self.type]:Flush()
end
----------视图函数----------

-- 创建龙珠
function DragonBallView:CreateDragonBall()
	self.ball_small_layout = {}
	self.ball_small = {}
	self.ball_small_eff = {}
	local level = math.max(self.data[self.type].level, 1)
	local child_level = level % 8
	local index = math.max((level - (level - 1) % 8 - 1) / 8 + 1, 1)
	for i = 1, 8 do
		local ph = self.ph_list["ph_dragon_ball_" .. i]
		self.ball_small_layout[i] = XUI.CreateLayout(ph.x, ph.y, 0, 0)
		self.node_t_list["layout_dragon_ball"].node:addChild(self.ball_small_layout[i], 20)

		local path = ResPath.GetDragonBall("img_ball_small_" .. index)
		self.ball_small[i] = XUI.CreateImageView(x, y, path, true)
		self.ball_small[i]:setPosition(0, 0)
		self.ball_small[i]:setVisible(i > child_level)
		self.ball_small[i]:setScale(0.7)
		self.ball_small_layout[i]:addChild(self.ball_small[i], 20)

		local eff_index = self.ball_cfg[self.type][1].lvcfg[level].eff
		local path, name = ResPath.GetEffectUiAnimPath(eff_index)
		self.ball_small_eff[i] = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		self.ball_small_eff[i]:setPosition(0, 0)
		self.ball_small_eff[i]:setVisible(i <= child_level)
		self.ball_small_eff[i]:setScale(0.7)
		self.ball_small_layout[i]:addChild(self.ball_small_eff[i], 20)
	end

	local phase = math.max(self.data[self.type].phase, 1)
	local eff_index = self.ball_cfg[self.type][1].order[phase].eff
	local ph = self.ph_list["ph_ball_big"]
	local path, name = ResPath.GetEffectUiAnimPath(eff_index)
	self.ball_big = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	self.ball_big:setPosition(ph.x - 11, ph.y - 3)
	self.node_t_list["layout_dragon_ball"].node:addChild(self.ball_big, 20)
end

-- 刷新龙珠显示
function DragonBallView:FlushDrgaonBall()
	local level = self.data[self.type].level
	local child_level = level % (#self.ball_small)
	child_level = (level > 0 and child_level == 0) and #self.ball_small or child_level
	local phase = self.data[self.type].phase
	for i = 1, #self.ball_small do
		local img_index = math.max((level - (level - 1) % 8 - 1) / 8 + 1, 1)
		self.ball_small[i]:loadTexture(ResPath.GetDragonBall("img_ball_small_" .. img_index))
		self.ball_small[i]:setVisible(i > child_level and phase ~= 0)
		
		local eff_index = self.ball_cfg[self.type][1].lvcfg[math.max(level, 1)].eff
		local path, name = ResPath.GetEffectUiAnimPath(eff_index)
		self.ball_small_eff[i]:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, 0.1, false)
		self.ball_small_eff[i]:setVisible(i <= child_level and level > 0)
	end

	local phase = math.max(self.data[self.type].phase, 1)
	local eff_index = self.ball_cfg[self.type][1].order[phase].eff
	local path, name = ResPath.GetEffectUiAnimPath(eff_index)
	self.ball_big:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, 0.1, false)
end

-- 播放龙珠动作
function DragonBallView:PlayDragonBallAction()
	for i = 1, #self.ball_small do
		self:DragonBallAction(i)
	end
end

-- 单个龙珠动作
function DragonBallView:DragonBallAction(index)
	local img_node = self.ball_small[index]
	local eff_node = self.ball_small_eff[index]
	local layout_node = self.ball_small_layout[index]
	local max_level = #self.ball_cfg[self.type][1].lvcfg
	local level = math.min(self.data[self.type].level, max_level)
	local eff_index = self.ball_cfg[self.type][1].lvcfg[level].eff
	
	local tag_pos_1 = cc.p(self.ph_list["ph_ball_big"].x, self.ph_list["ph_ball_big"].y)
	local tag_pos_2 = cc.p(layout_node:getPosition())

	local callfunc = cc.CallFunc:create(function()
		local img_index = math.max((level - (level - 1) % 8 - 1) / 8 + 1, 1)
		img_node:loadTexture(ResPath.GetDragonBall("img_ball_small_" .. img_index))
		local path, name = ResPath.GetEffectUiAnimPath(eff_index)
		eff_node:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, 0.1, false)
		eff_node:setVisible(false)
		img_node:setVisible(true)
	end)

	local callfunc_2 = cc.CallFunc:create(function()
		if index == #self.ball_small then
			self:Flush()
		end
	end)

	local move_1 = cc.EaseExponentialIn:create(cc.MoveTo:create(0.8, tag_pos_1))
	local move_2 = cc.EaseExponentialIn:create(cc.MoveTo:create(0.8, tag_pos_2))
	local seq = cc.Sequence:create(move_1, callfunc, move_2, callfunc_2)

	layout_node:runAction(seq)
end

-- 创建"星珠"视图
function DragonBallView:CreatePhaseView()
	local ph = self.ph_list["ph_phase_scroll"]
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, self.ph_list.ph_phase_item.h + 15, self.StarBallShow, ScrollDir.Vertical, false, self.ph_list.ph_phase_item)
	self.node_t_list["layout_dragon_ball"].node:addChild(grid_scroll:GetView(), 2)
	grid_scroll:SetDataList(self.data)
	grid_scroll:SelectItemByIndex(1)
	grid_scroll:SetSelectCallBack(BindTool.Bind(self.StarBallCallBack, self))
	grid_scroll:JumpToTop()
	self.grid_scroll = grid_scroll
end

-- 星珠点击回调
function DragonBallView:StarBallCallBack(item)
	self.type = item.index
	self:Flush()
end

function DragonBallView:FlushBtn()
	local level = self.data[self.type].level
	local max_level = #self.ball_cfg[self.type][1].lvcfg
	self.node_t_list["btn_absorb"].node:setEnabled(level < max_level)

	local phase = self.data[self.type].phase
	local max_phase = #self.ball_cfg[self.type][1].order
	self.node_t_list["btn_refining"].node:setEnabled(phase < max_phase)

	if phase == 0 then
		self.node_t_list["layout_refining"].node:setPositionX(492)
		self.node_t_list["layout_absorb"].node:setVisible(false)
	else
		self.node_t_list["layout_refining"].node:setPositionX(646)
		self.node_t_list["layout_absorb"].node:setVisible(true)
	end
end

-- 刷新战力值视图
function DragonBallView:FlushPowerValue()
	local attr
	local power_value = 0
	
	local prof = math.max(RoleData.Instance:GetRoleBaseProf(), 1) --获取角色基础职业,默认是战士
	for i=1, #self.data do
		local cfg = TreasureAtticData.Instance:GetAbsorbAttr(i)
		attr = {}
		for k, v in ipairs(cfg) do
			attr[#attr + 1] = v
		end
		power_value = power_value + CommonDataManager.GetAttrSetScore(attr)
		attr = {}
		local cfg = TreasureAtticData.Instance:GetRefiningAttr(i)
		for k, v in ipairs(cfg) do
			attr[#attr + 1] = v
		end 
		power_value = power_value + CommonDataManager.GetAttrSetScore(attr)
	end

	self.power_view:SetNumber(power_value)
end

-- 刷新消耗文本
function DragonBallView:FlushConsumeText()
	local level = self.data[self.type].level
	local phase = self.data[self.type].phase

	local item_num_str = nil --物品数量
	local content = nil 	--文本内容
	local color = nil

	local item_1 = self.ball_cfg[self.type][1].order[phase + 1]
	if item_1 then
		local item_num_1 = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COLOR_STONE)	-- 获取七彩石数量
		local item_id_1 =  item_1.consume[1].type > 0 and ItemData.GetVirtualItemId(item_1.consume[1].type) or item_1.consume[1].id
		local item_cfg_1 = ItemData.Instance:GetItemConfig(item_id_1)
		local cfg_count_1 = item_1.consume[1].count -- 龙魂消耗配置数量
		local bool = item_num_1 < cfg_count_1

		color = bool and COLORSTR.RED or COLORSTR.GREEN
		item_num_str =  "{color;" .. color .. ";" .. item_num_1 .. "}" or item_num_1
		content = string.format(Language.DragonBall.Consume, item_cfg_1.name, item_num_str, cfg_count_1)
		RichTextUtil.ParseRichText(self.node_t_list["rich_consume_1"].node, content, 20, COLOR3B.OLIVE)
		XUI.RichTextSetCenter(self.node_t_list["rich_consume_1"].node)
		self.node_t_list["rich_consume_1"].node:setVisible(true)

		self.node_t_list["btn_refining"].remind_eff:setVisible(not bool)
	else
		self.node_t_list["rich_consume_1"].node:setVisible(false)
		self.node_t_list["btn_refining"].remind_eff:setVisible(false)
	end

	local item_2 = self.ball_cfg[self.type][1].lvcfg[level + 1]
	if item_2 then 
		local item_num_2 = BagData.Instance:GetItemNumInBagById(item_2.consume[1].id, nil)
		local item_cfg_2 = ItemData.Instance:GetItemConfig(item_2.consume[1].id)
		local cfg_count_2 = item_2.consume[1].count
		local bool = item_num_2 < cfg_count_2

		color = bool and COLORSTR.RED or COLORSTR.GREEN
		item_num_str =  "{color;" .. color .. ";" .. item_num_2 .. "}"
		content = string.format(Language.DragonBall.Consume, item_cfg_2.name, item_num_str, cfg_count_2)
		RichTextUtil.ParseRichText(self.node_t_list["rich_consume_2"].node, content, 20, COLOR3B.OLIVE)
		XUI.RichTextSetCenter(self.node_t_list["rich_consume_2"].node)
		self.node_t_list["rich_consume_2"].node:setVisible(true)

		self.node_t_list["btn_absorb"].remind_eff:setVisible(not bool)
	else
		self.node_t_list["rich_consume_2"].node:setVisible(false)
		self.node_t_list["btn_absorb"].remind_eff:setVisible(false)
	end
end

-- 刷新加成属性视图
function DragonBallView:FlushBonusView()
	local attr
	attr = TreasureAtticData.Instance:GetAbsorbAttr(self.type)
	local text1 = RoleData.Instance.FormatAttrContent(attr)
	attr = TreasureAtticData.Instance:GetRefiningAttr(self.type)
	local text2 = RoleData.Instance.FormatAttrContent(attr)
	RichTextUtil.ParseRichText(self.node_t_list["rich_attr_1"].node, text1, 18, COLOR3B.G_W)
	RichTextUtil.ParseRichText(self.node_t_list["rich_attr_2"].node, text2, 18, COLOR3B.G_W)
	XUI.SetRichTextVerticalSpace(self.node_t_list["rich_attr_1"].node, 5) --设置垂直间隔
	XUI.SetRichTextVerticalSpace(self.node_t_list["rich_attr_2"].node, 5)
end

-- 播放进阶特效
function DragonBallView:PlayUpPhaseEffectView()
	local ph = self.ph_list["ph_ball_big"]
	local path, name = ResPath.GetEffectUiAnimPath(15)
	local up_phase_eff = AnimateSprite:create(path, name, 1, FrameTime.Effect, false)
	up_phase_eff:setPosition(ph.x, ph.y)
	self.node_t_list["layout_dragon_ball"].node:addChild(up_phase_eff, 99)
	up_phase_eff:setVisible(true)
end

-- 创建"获取材料"按钮
function DragonBallView:CreateTextBtn()
	local ph = self.ph_list["ph_text_btn_1"]
	local text = RichTextUtil.CreateLinkText("获取材料", 19, COLOR3B.GREEN, nil, true)
	text:setPosition(ph.x, ph.y)
	self.node_t_list["layout_refining"].node:addChild(text, 90)
	XUI.AddClickEventListener(text, BindTool.Bind(self.OnTextBtn, self, 1), true)

	local ph = self.ph_list["ph_text_btn_2"]
	text = RichTextUtil.CreateLinkText("获取材料", 19, COLOR3B.GREEN, nil, true)
	text:setPosition(ph.x, ph.y)
	self.node_t_list["layout_absorb"].node:addChild(text, 90)
	XUI.AddClickEventListener(text, BindTool.Bind(self.OnTextBtn, self, 2), true)
end

----------end----------

-- "获取材料"按钮点击回调
function DragonBallView:OnTextBtn(index)
	-- 获取配置
	local consume_1 = self.ball_cfg[self.type][1].order[1].consume[1]
	local item_id_1 =  consume_1.type > 0 and ItemData.GetVirtualItemId(consume_1.type) or consume_1.id
	local item_cfg1 = item_id_1
	local item_cfg2 = self.ball_cfg[self.type][1].lvcfg[1].consume[1].id

	local item = index == 1 and item_cfg1 or item_cfg2
	local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item]
	local data = string.format("{reward;0;%d;1}", item) .. (ways and ways or "")
	TipCtrl.Instance:OpenBuyTip(data)
end

-- "吸收"按钮点击回调
function DragonBallView:OnAbsorb()
	TreasureAtticCtrl.Instance.SendDragonBallAbsorbReq(self.type - 1)
	self.node_t_list["btn_absorb"].node:setEnabled(false)
end

-- "提炼"按钮点击回调
function DragonBallView:OnRefining()
	TreasureAtticCtrl.Instance.SendDragonBallRefiningReq(self.type - 1)
end

-- "套装属性"按钮点击回调
function DragonBallView:OnSuitAttr()
	ViewManager.Instance:OpenViewByDef(ViewDef.TreasureAttic.DragonBall.SuitAttr)
end

function DragonBallView:OnBagItemChange()
	self:FlushConsumeText()
	for i = 1, #self.grid_scroll.items do
		self.grid_scroll.items[i]:Flush()
	end
end

-- "龙珠数据"改变回调
function DragonBallView:OnDragonBallDataChange()
	local old_data = TreasureAtticData.Instance:GetDragonOldBallData()
	if old_data.type_chage == self.type then
		local old_phase = old_data[self.type].phase
		if old_phase < self.data[self.type].phase then
			self:PlayUpPhaseEffectView()
		end
		local level = self.data[self.type].level
		if level % (#self.ball_small) == 1 and level > 1 and old_phase == self.data[self.type].phase then
			self:PlayDragonBallAction()
		else
			self:Flush()
		end
	end
	if self.grid_scroll.items[old_data.type_chage] then
		self.grid_scroll.items[old_data.type_chage]:Flush()
	end
end

function DragonBallView:OnRoleAttrChange()
	self:FlushConsumeText()
	for i = 1, #self.grid_scroll.items do
		self.grid_scroll.items[i]:Flush()
	end
end

----------------------------------------
-- 等级阶位
----------------------------------------

DragonBallView.StarBallShow = BaseClass(BaseRender)
local StarBallShow = DragonBallView.StarBallShow
function StarBallShow:__init()
	self.item_cell = nil
end

function StarBallShow:__delete()

end

function StarBallShow:CreateChild()
	BaseRender.CreateChild(self)
	if nil == self.data then return end
	local ph = self.ph_list["ph_ball"]
	self.ball_cfg = TreasureAtticData.Instance:GetBallCfg()
	local phase = math.max(self.data.phase, 1)
	local eff_index = self.ball_cfg[self.index][1].order[phase].eff
	local path, name = ResPath.GetEffectUiAnimPath(eff_index)
	self.ball = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	self.ball:setScale(0.32)
	self.ball:setPosition(ph.x, ph.y)
	self.view:addChild(self.ball, 20)
end

function StarBallShow:OnFlush()
	if nil == self.data then return end
	local phase = self.data.phase
	self.node_tree.img_background.node:setGrey(phase == 0)

	local phase = math.max(self.data.phase, 1)
	local eff_index = self.ball_cfg[self.index][1].order[phase].eff --获取配置的特效ID
	local path, name = ResPath.GetEffectUiAnimPath(eff_index)
	self.ball:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, 0.1, false)

	local index = 0
	local item_1 = TreasureAtticData.Instance.ball_cfg[self.index][1].order[self.data.phase + 1]
	if item_1 then
		local item_num_1 = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COLOR_STONE)	-- 获取七彩石数量
		local item_id_1 =  item_1.consume[1].type > 0 and ItemData.GetVirtualItemId(item_1.consume[1].type) or item_1.consume[1].id
		local item_cfg_1 = ItemData.Instance:GetItemConfig(item_id_1)
		local cfg_count_1 = item_1.consume[1].count -- 龙魂消耗配置数量
		index = item_num_1 < cfg_count_1 and index or 1
	end

	local vis = (TreasureAtticData.Instance.GetStarBallRemindIndex(self.index) + index) > 0
	self:SetRemind(vis)
end

-- 设置提醒
function StarBallShow:SetRemind(vis, path, x, y)
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

-- function StarBallShow:CreateSelectEffect()
-- 	return
-- end

-- function StarBallShow:OnClickBuyBtn()
-- 	if nil ~= self.click_callback then
-- 		self.click_callback(self)
-- 	end
-- end

-- function StarBallShow:OnClick()
-- 	if nil ~= self.click_callback then
-- 		-- self.click_callback(self)
-- 	end
-- end
--------------------

return DragonBallView