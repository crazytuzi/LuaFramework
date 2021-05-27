-- 跨服战场 入口
local CrossBattleEntrance = BaseClass()

local EntranceIconRender = BaseClass(BaseRender)

function CrossBattleEntrance:__init(root_view)
	self.root_view = root_view
	self.node_t_list = {}
	self.ph_list = {}

	self.cur_select_entrance = 1	-- 玩家选中的入口
	self.drop_items = {}			-- 掉落物品格子
	self.entrance_icons = {}		-- 入口图标
end

function CrossBattleEntrance:__delete()
end

function CrossBattleEntrance:LoadCallBack()
	self.node_t_list = self.root_view.node_t_list
	self.ph_list = self.root_view.ph_list
	self.view = self.node_t_list.layout_entrance.node
	self.btn_enter = self.node_t_list.btn_enter.node
	self.btn_buy_tumo = self.node_t_list.btn_buy_tumo.node
	self.rich_rule = self.node_t_list.rich_rule.node
	self.rich_cur_tumo_val = self.node_t_list.rich_cur_tumo_val.node

	self.rich_rule:retain()
	self.rich_rule:removeFromParent(false)
	local x, y = self.rich_rule:getPosition()
	local size = self.rich_rule:getContentSize()
	self.scroll_rich = XUI.CreateScrollView(590, 481, 316, 376.95, ScrollDir.Vertical)
	self.view:addChild(self.scroll_rich, 10)
	self.scroll_rich:setAnchorPoint(0, 1)
	self.scroll_rich:addChild(self.rich_rule)
	RichTextUtil.ParseRichText(self.rich_rule, CrossServerData.Instance:CrossBattleRule())
	self.rich_rule:setVerticalSpace(2)
	self.rich_rule:refreshView()
	local inner_size = self.rich_rule:getInnerContainerSize()
	local inner_heigh = math.max(inner_size.height, size.height)
	inner_size.height = inner_heigh
	self.rich_rule:setPosition(0, inner_heigh)
	self.scroll_rich:setInnerContainerSize(inner_size)
	self.scroll_rich:jumpToTop()

	self.btn_buy_tumo:setTitleText(Language.CrossServer.BuyTulong)
	XUI.RichTextSetCenter(self.rich_cur_tumo_val)
	self:CreateEntranceIcons()

	XUI.AddClickEventListener(self.btn_enter, BindTool.Bind(self.Enter, self))
	XUI.AddClickEventListener(self.btn_buy_tumo, BindTool.Bind(self.BuyTomo, self))
end

function CrossBattleEntrance:ReleaseCallBack()
	self.node_t_list = {}
	self.ph_list = {}

	for k, v in pairs(self.entrance_icons) do
		v:DeleteMe()
	end
	self.entrance_icons = {}

	for k, v in pairs(self.drop_items) do
		v:DeleteMe()
	end
	self.drop_items = {}
end

function CrossBattleEntrance:ShowIndexCallBack()
	local can_enter_index = CrossServerData.Instance:GetCanEnterEntranceIndex()
	self.cur_select_entrance = can_enter_index and can_enter_index or 1
end

function CrossBattleEntrance:OnFlush(param_t)
	local tomo_val = CrossServerData.Instance:TumoVal()
	local color_str = tomo_val > 0 and "1eff00" or "ff2828"
	RichTextUtil.ParseRichText(self.rich_cur_tumo_val, string.format(Language.CrossServer.CurTumoVal, color_str, tomo_val))

	self:FlushBtns()

	self:FlushSelectEntrance()
end

function CrossBattleEntrance:FlushBtns()
	local btn_txt = ""
	local btn_enabled = true
	if not IS_ON_CROSSSERVER then
		btn_txt = Language.CrossServer.EnterBattle
	else
		btn_txt = Language.CrossServer.IsCrossServerStr
		btn_enabled = false
	end
	self.btn_enter:setTitleText(btn_txt)
	XUI.SetButtonEnabled(self.btn_enter, btn_enabled)
end

function CrossBattleEntrance:CreateEntranceIcons()
	local index = 1
	while self.ph_list["ph_battle" .. index] do
		local ph = self.ph_list["ph_battle" .. index]
		local icon = EntranceIconRender.New(index, ph, BindTool.Bind(self.SelectEntranceCallback, self, index))
		self.view:addChild(icon:GetView(), 10)
		self.entrance_icons[index] = icon
		index = index + 1
	end
end

function CrossBattleEntrance:SelectEntranceCallback(index)
	if self.cur_select_entrance ~= index then
		self.cur_select_entrance = index
		self:FlushSelectEntrance()
	end
end

function CrossBattleEntrance:ShowDropItemList()
	local drop_items_cfg = CrossServerData.Instance:GetEntrancesDrops(self.cur_select_entrance)

	-- 格子数量不够时创建
	while #drop_items_cfg > #self.drop_items do
		local cell = BaseCell.New()
		cell:GetView():setAnchorPoint(0.5, 0.5)
		cell:GetView():setScale(0.95)
		self.view:addChild(cell:GetView(), 20)
		table.insert(self.drop_items, cell)
		local index = #self.drop_items
		local ph_drop_start = self.ph_list.ph_ljdl_start
		cell:SetPosition(ph_drop_start.x + (index - 1) * 80, ph_drop_start.y)
	end

	local item_data = nil
	for k, v in pairs(self.drop_items) do
		item_data = drop_items_cfg[k]
		if nil ~= item_data then
			v:SetData(drop_items_cfg[k])
		end
		-- 多出来的隐藏
		v:SetVisible(nil ~= item_data)
	end
end

function CrossBattleEntrance:FlushSelectEntrance()
	for _, v in pairs(self.entrance_icons) do
		v:SetSelect(self.cur_select_entrance == v:GetIndex())
	end
	self:ShowDropItemList()
end

function CrossBattleEntrance:Enter()
	local entrance_index = CrossServerData.Instance:GetCanEnterEntranceIndex()
	if entrance_index then
		if self.cur_select_entrance ~= entrance_index then
			SysMsgCtrl.Instance:FloatingTopRightText(Language.CrossServer.CircleNotRight)
			return
		end

		CrossServerCtrl.SentJoinCrossServerReq(CROSS_SERVER_TYPE.FUBEN, entrance_index)
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.CrossServer.NoConformityEntrance)
	end
end

function CrossBattleEntrance:BuyTomo()
	CrossServerCtrl.Instance:BuyTumo()
end

-------------------------------------------------------
-- 入口图标 begin
-------------------------------------------------------
function EntranceIconRender:__init(index, ui_config, click_callback)
	self.index = index
	self.ignore_data_to_select = true
	self:SetUiConfig(ui_config, false)
	self:SetIsUseStepCalc(true)
	self:SetAnchorPoint(0.5, 0.5)
	self:SetPosition(ui_config.x + ui_config.w / 2, ui_config.y + ui_config.h / 2)
	self:AddClickEventListener(click_callback, true)
	self:Flush()
end

function EntranceIconRender:__delete()
end

function EntranceIconRender:CreateChild()
	EntranceIconRender.super.CreateChild(self)

	XUI.RichTextSetCenter(self.node_tree.rich_battle_name.node)
	XUI.RichTextSetCenter(self.node_tree.rich_battle_need.node)
	self.node_tree.rich_battle_need.node:setVisible(false)

	self.accord_eff = RenderUnit.CreateEffect(1208, self.view, 10, nil, nil, 53, 83)
	self.accord_eff:setScale(0.6)
	self.accord_eff:setVisible(false)
	self.node_tree.img_icon.node:loadTexture(ResPath.GetCrossBattle("cross_battle_icon" .. self.index), true)
end

function EntranceIconRender:OnFlush()
	local entrance_cfg = CrossServerData.Instance:GetEntrancesCfg(self.index)
	if nil == entrance_cfg then
		return
	end

	local role_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local role_battle_power = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BATTLE_POWER)
	local is_circle_accrod = role_circle >= entrance_cfg.needmincircle and role_circle <= entrance_cfg.needmaxcircle
	local is_power_accrod = role_battle_power >= entrance_cfg.openBattle
	local need_circle_str = string.format("%d-%d", entrance_cfg.needmincircle, entrance_cfg.needmaxcircle)
	local name = string.format(Language.CrossServer.EntranceName, is_circle_accrod and COLORSTR.GREEN or COLORSTR.RED,
		entrance_cfg.fubenName, need_circle_str)
	RichTextUtil.ParseRichText(self.node_tree.rich_battle_name.node, name)

	local need_battle_power = string.format(Language.CrossServer.EntranceNeedPower, (is_circle_accrod and is_power_accrod) and COLORSTR.GREEN or COLORSTR.RED,
		math.floor(entrance_cfg.openBattle / 10000) .. Language.Common.Wan)
	RichTextUtil.ParseRichText(self.node_tree.rich_battle_need.node, need_battle_power)
	self.accord_eff:setVisible(is_circle_accrod)
end
-------------------------------------------------------
-- 入口图标 end
-------------------------------------------------------

return CrossBattleEntrance
