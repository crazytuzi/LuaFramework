-- 跨服战场 装备
local CrossBattleEquip = BaseClass()

local CrossEquipRender = BaseClass(BaseRender)
local EquipAttrRender = BaseClass(BaseRender)

local VIEW_ENUM = {
	MOHUA = 1,		-- 魔化
	UPGRADE = 2,	-- 升阶
}

function CrossBattleEquip:__init(root_view)
	self.root_view = root_view
	self.node_t_list = {}
	self.ph_list = {}

	self.view_type = nil
	self.select_equip_index = nil
	self.last_attrs = nil
end

function CrossBattleEquip:__delete()
end

function CrossBattleEquip:LoadCallBack()
	self.node_t_list = self.root_view.node_t_list
	self.ph_list = self.root_view.ph_list
	self.view = self.node_t_list.layout_equip.node
	self.layout_equip_mohua = self.node_t_list.layout_equip_mohua.node
	self.layout_equip_upgrade = self.node_t_list.layout_equip_upgrade.node
	self.rich_equip_name = self.node_t_list.rich_equip_name.node
	self.rich_attr_consum1 = self.node_t_list.rich_attr_consum1.node
	self.rich_cond = self.node_t_list.rich_cond.node
	self.img_list_up = self.node_t_list.img_list_up.node
	self.img_list_down = self.node_t_list.img_list_down.node
	self.img_line = self.node_t_list.img_line.node
	self.btn_equip_up = self.node_t_list.btn_equip_up.node
	self.btn_change_equip_view = self.node_t_list.btn_change_equip_view.node
	self.btn_get_stuff = self.node_t_list.btn_get_stuff.node
	self.lbl_attr_not_active = self.node_t_list.lbl_attr_not_active.node

	XUI.RichTextSetCenter(self.rich_equip_name)
	self.btn_get_stuff:setTitleText(Language.Common.GetStuff)
	self.btn_change_equip_view.btn_remind_eff = RenderUnit.CreateEffect(621, self.btn_change_equip_view:getNormalImage(), 1)
	self.btn_change_equip_view.btn_remind_eff:setVisible(false)
	self.btn_change_equip_view.btn_remind_eff:setScale(1.32, 1.0)
	XUI.AddClickEventListener(self.btn_get_stuff, BindTool.Bind(self.ClickGetStuff, self))
	-- XUI.AddClickEventListener(self.btn_change_equip_view, BindTool.Bind(self.ClickChangeEquipView, self))
	self.btn_change_equip_view:setVisible(false)
	XUI.AddClickEventListener(self.btn_equip_up, BindTool.Bind(self.ClickUp, self))
	XUI.AddClickEventListener(self.img_list_up, BindTool.Bind(self.ClickEquipListChangePage, self, -1), true)
	XUI.AddClickEventListener(self.img_list_down, BindTool.Bind(self.ClickEquipListChangePage, self, 1), true)

	local ph_zhandouli = self.ph_list.ph_zhandouli
	self.zhan_dou_li = UiInstanceMgr.Instance:CreateZhanDouLiUi(ph_zhandouli.x, ph_zhandouli.y, ph_zhandouli.w, ph_zhandouli.h, self.view, 10)

	self:CreateEquipList()
	self:CreateCommonAttrView()
	self:CreateUpgradeParts()
	self:CreateMohuaParts()
end

function CrossBattleEquip:ReleaseCallBack()
	self.view_type = nil
	self.zhan_dou_li = nil
	self.last_attrs = nil

	if self.common_attr_view then
		self.common_attr_view:DeleteMe()
		self.common_attr_view = nil
	end

	if self.equip_list then
		self.equip_list:DeleteMe()
		self.equip_list = nil
	end

	self:ClearUpgradeParts()
	self:ClearMohuaParts()

	self.node_t_list = {}
	self.ph_list = {}
end

function CrossBattleEquip:ShowIndexCallBack()
	self.view_type = nil
	self.select_equip_index = nil

	self.equip_list:SelectCellByIndex(0)	-- 选中第一个
	-- self:SetEquipViewType(VIEW_ENUM.MOHUA)	-- 默认显示魔化
end

function CrossBattleEquip:OnFlush(param_t)
	self:SetViewType()
	self:FlushCommonAllAttrs()
	self:FlushUpgradeParts()
	self:FlushMohuaParts()
	self:FlushConsumParts()
	self:FlushEquipList()
	self:FlushBtns()
end

-- 设置显示类型 未激活、当阶满星数时显示升阶
function CrossBattleEquip:SetViewType()
	if not CrossServerData.Instance:IsCrossEqMaxGrade(self.select_equip_index) and
		(not CrossServerData.Instance:IsCrossEquipAct(self.select_equip_index)
		or CrossServerData.Instance:IsCurGradeMaxMohuaStar(self.select_equip_index)) then
		self:SetEquipViewType(VIEW_ENUM.UPGRADE)
	else
		self:SetEquipViewType(VIEW_ENUM.MOHUA)
	end
end

function CrossBattleEquip:ItemDataChangeCallback(change_type, change_item_id, change_item_index, series, reason, old_num, new_num)
	if change_item_id then
		local listen_items = CrossServerData.Instance:GetCrossEquipListenItems()
		if listen_items[change_item_id] then
			self:FlushUpgradeParts()
			self:FlushConsumParts()
			self:FlushEquipList()
			self:FlushBtns()
		end
	end
end

function CrossBattleEquip:ItemConfigCallback(item_config_t)
	local listen_items = CrossServerData.Instance:GetCrossEquipListenItems()
	for k, v in pairs(item_config_t) do
		if listen_items[v.item_id] then
			self:FlushUpgradeParts()
			self:FlushCommonAllAttrs()
			self:FlushConsumParts()
			break
		end
	end
end

function CrossBattleEquip:RoleDataChangeCallback(key)
	if key == OBJ_ATTR.CREATURE_LEVEL
		or key == OBJ_ATTR.ACTOR_CIRCLE then	
		self:FlushConsumParts()
	end
end

function CrossBattleEquip:CreateUpgradeParts()
	local ph_upgrade_equip = self.ph_list.ph_upgrade_equip
	local ph_upgrade_equip1 = self.ph_list.ph_upgrade_equip1
	local ph_upgrade_equip2 = self.ph_list.ph_upgrade_equip2
	local line_x, line_y = self.img_line:getPosition()
	RenderUnit.CreateEffect(1210, self.layout_equip_upgrade, 10, nil, nil, line_x - 4, line_y - 20)
	RenderUnit.CreateEffect(1209, self.layout_equip_upgrade, 22, nil, nil, ph_upgrade_equip.x, ph_upgrade_equip.y)

	self.equip0 = BaseCell.New()
	self.equip0:SetCellBg(ResPath.GetCommon("cell_107"))
	self.equip0:SetPosition(ph_upgrade_equip.x, ph_upgrade_equip.y)
	self.equip0:SetAnchorPoint(0.5, 0.5)
	self.layout_equip_upgrade:addChild(self.equip0:GetView(), 20)

	self.equip1 = BaseCell.New()
	self.equip1:SetPosition(ph_upgrade_equip1.x, ph_upgrade_equip1.y)
	self.equip1:SetAnchorPoint(0.5, 0.5)
	self.layout_equip_upgrade:addChild(self.equip1:GetView(), 20)

	self.equip2 = BaseCell.New()
	self.equip2:SetPosition(ph_upgrade_equip2.x, ph_upgrade_equip2.y)
	self.equip2:SetAnchorPoint(0.5, 0.5)
	self.layout_equip_upgrade:addChild(self.equip2:GetView(), 20)

	local ph_equip_attr1 = self.ph_list.ph_equip_attr1
	local ph_equip_attr2 = self.ph_list.ph_equip_attr2
	self.cur_equip_attr_render = EquipAttrRender.New(ph_equip_attr1, self.layout_equip_upgrade)
	self.next_equip_attr_render = EquipAttrRender.New(ph_equip_attr2, self.layout_equip_upgrade)
end

function CrossBattleEquip:ClearUpgradeParts()
	if self.equip0 then
		self.equip0:DeleteMe()
		self.equip0 = nil
	end
	if self.equip1 then
		self.equip1:DeleteMe()
		self.equip1 = nil
	end
	if self.equip2 then
		self.equip2:DeleteMe()
		self.equip2 = nil
	end
	if self.cur_equip_attr_render then
		self.cur_equip_attr_render:DeleteMe()
		self.cur_equip_attr_render = nil
	end
	if self.next_equip_attr_render then
		self.next_equip_attr_render:DeleteMe()
		self.next_equip_attr_render = nil
	end
end

function CrossBattleEquip:CreateMohuaParts()
	local ph_equip_display = self.ph_list.ph_equip_display
	local ph_mohua_star = self.ph_list.ph_mohua_star

	self.equip_display = ModelAnimate.New(ResPath.GetEffectUiAnimPath, self.layout_equip_mohua, GameMath.DirDown)
	self.equip_display:SetZOrder(99)
	self.equip_display:SetAnimPosition(ph_equip_display.x, ph_equip_display.y)
	CommonAction.ShowJumpAction(self.equip_display:GetAnimNode(), 10)

	self.stars_ui = UiInstanceMgr.Instance:CreateStarsUi({x = ph_mohua_star.x, y = ph_mohua_star.y, interval_x = 3,
		star_num = 10, parent = self.layout_equip_mohua, zorder = 10,})
end

function CrossBattleEquip:ClearMohuaParts()
	if self.equip_display then
		self.equip_display:DeleteMe()
		self.equip_display = nil
	end
	self.stars_ui = nil
end

function CrossBattleEquip:CreateCommonAttrView()
	local ph_attr = self.ph_list.ph_attr
	self.common_attr_view = AttrView.New(ph_attr.w, 24, 20)
	self.common_attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
	self.common_attr_view:SetItemInterval(2)
	self.common_attr_view:GetView():setPosition(ph_attr.x, ph_attr.y)
	self.common_attr_view:SetDefTitleText(Language.Common.NoActivate)
	self.view:addChild(self.common_attr_view:GetView(), 10)
end

function CrossBattleEquip:CreateEquipList()
	if self.equip_list == nil then
		local equip_list = CrossServerData.Instance:GetCrossEquipList()
		local ph = self.ph_list.ph_equip_list
		self.equip_list = BaseGrid.New()
		self.equip_list:CreateCells({w = ph.w, h = ph.h, itemRender = CrossEquipRender,
			direction = ScrollDir.Vertical, ui_config = nil, cell_count = #equip_list, col = 1, row = 3})
		self.equip_list:GetView():setAnchorPoint(0.5, 0.5)
		self.equip_list:GetView():setPosition(ph.x, ph.y)
		self.view:addChild(self.equip_list:GetView(), 108)
		self.equip_list:SetSelectCallBack(BindTool.Bind(self.OnSelectEquipCallback, self))
		equip_list[0] = table.remove(equip_list, 1)
		self.equip_list:SetDataList(equip_list)
	end
end

function CrossBattleEquip:OnSelectEquipCallback(item)
	if nil == item and nil == item:GetData() then
		return
	end
	local equip_index = item:GetData().equip_index
	if equip_index ~= self.select_equip_index then
		self.select_equip_index = equip_index
		self:UpdateEquipViewBySelectEquip()
	end
end

function CrossBattleEquip:UpdateEquipViewBySelectEquip()
	if nil == self.select_equip_index then
		return
	end

	self.last_attrs = nil -- 清空记录的总属性

	self:SetViewType()
	self:FlushCommonAllAttrs()
	self:FlushMohuaParts()
	self:FlushUpgradeParts()
	self:FlushConsumParts()
	self:FlushBtns()
end

function CrossBattleEquip:ClickEquipListChangePage(dir)
	local page_index = self.equip_list:GetCurPageIndex()
	page_index = (page_index + dir) < 0 and 0 or (page_index + dir)
	self.equip_list:ChangeToPage(page_index)
end

-- 显示类型变化时的更新
function CrossBattleEquip:UpdateEquipViewByShowType()
	self:FlushLayoutVis()
	-- self:FlushBtns()
	-- self:FlushConsumParts()
end

function CrossBattleEquip:SetEquipViewType(view_type)
	if self.view_type ~= view_type then
		self.view_type = view_type
		self:UpdateEquipViewByShowType()
	end
end

function CrossBattleEquip:ClickChangeEquipView()
	local view_type = self.view_type
	if self.view_type == VIEW_ENUM.UPGRADE then
		view_type = VIEW_ENUM.MOHUA
	elseif self.view_type == VIEW_ENUM.MOHUA then
		view_type = VIEW_ENUM.UPGRADE
	end
	self:SetEquipViewType(view_type)
end

function CrossBattleEquip:ClickUp()
	if CrossServerCtrl.CrossServerPingbi() then return end

	local opt_type = 2
	local opt_type2 = 1
	if self.view_type == VIEW_ENUM.UPGRADE then
		opt_type2 = 1
		local consume = CrossServerData.Instance:GetCrossEquipUpgradeConsume(self.select_equip_index)
		for k, v in pairs(consume.items) do
			local num = BagData.Instance:GetItemNumInBagById(v.item_id)
			if num < v.num then
				SysMsgCtrl.Instance:FloatingTopRightText(string.format("{wordcolor;ffff00;%s}", Language.Common.StuffNotEnought))
				return
			end
		end
	elseif self.view_type == VIEW_ENUM.MOHUA then
		opt_type2 = 2
	end
	CrossServerCtrl.SentCrossEqInfoReq(opt_type, CrossServerData.ConverToCrossEqCfgIndex(self.select_equip_index or 1), opt_type2)
end

function CrossBattleEquip:ClickGetStuff()
	local title = ""
	if self.view_type == VIEW_ENUM.UPGRADE then
		title = string.format(Language.Common.StuffWaysStr, Language.CrossServer.Upgrade)
	else
		title = string.format(Language.Common.StuffWaysStr, Language.CrossServer.Mohua)
	end
	TipCtrl.Instance:OpenStuffTip(title, {{stuff_way = Language.CrossServer.CrossBattleDropStuff, open_view = ViewName.CrossBattle, index = TabIndex.crossbattle_entrance}})
end

-----------------------------------------------------------------------------------
-- 魔化parts
function CrossBattleEquip:FlushMohuaParts()
	-- self.equip_display:Show(CrossServerData.Instance:GetCrossEquipEffid(self.select_equip_index))
	-- RichTextUtil.ParseRichText(self.rich_equip_name, CrossServerData.Instance:GetCrossEquipName(self.select_equip_index))
	self.stars_ui:SetStarActNum(CrossServerData.Instance:GetCrossEquipMohuaStarNum(self.select_equip_index))
	local equip_data = EquipData.Instance:GetGridData(self.select_equip_index)
	self.stars_ui:GetView():setVisible(nil ~= equip_data)
end

-- 升阶parts
function CrossBattleEquip:FlushUpgradeParts()
	local upgrade_consum, is_max = CrossServerData.Instance:GetCrossEquipUpgradeConsume(self.select_equip_index)	-- 升阶消耗
	local next_upgrade_equip_data = CrossServerData.Instance:GetNextUpgradeEquipData(self.select_equip_index)
	local equip_data = EquipData.Instance:GetGridData(self.select_equip_index)
	self.equip1:SetData(equip_data)
	self.equip1:SetUnopenIconVisible(nil == equip_data)
	self.equip2:SetData(upgrade_consum.items[1])
	self.equip2:SetUnopenIconVisible(nil == upgrade_consum.items[1])
	self.equip0:SetData(is_max and equip_data or next_upgrade_equip_data)

	local cur_attrs = CrossServerData.Instance:GetCurUpgradeEquipAttrs(self.select_equip_index)
	local next_attrs = CrossServerData.Instance:GetNextUpgradeEquipAttrs(self.select_equip_index)
	self.cur_equip_attr_render:SetData(cur_attrs)
	self.next_equip_attr_render:SetData(is_max and cur_attrs or next_attrs)

	self.equip_display:Show(CrossServerData.Instance:GetCrossEquipEffid(self.select_equip_index))
	RichTextUtil.ParseRichText(self.rich_equip_name, CrossServerData.Instance:GetCrossEquipName(self.select_equip_index))
end

-- 消耗parts
function CrossBattleEquip:FlushConsumParts()
	local mohua_consum = CrossServerData.Instance:GetCrossEquipMohuaConsume(self.select_equip_index)				-- 魔化消耗
	local upgrade_consum, is_max = CrossServerData.Instance:GetCrossEquipUpgradeConsume(self.select_equip_index)	-- 升阶消耗

	local consum = {items = {}, fujiao_rich_contents = {}}
	if self.view_type == VIEW_ENUM.MOHUA then
		consum = mohua_consum
	elseif self.view_type == VIEW_ENUM.UPGRADE then
		consum = upgrade_consum
	end

	local rich_attr_consum1_content = ""
	for k, v in pairs(consum.items) do
		if v.item_id ~= 0 then
			local num = BagData.Instance:GetItemNumInBagById(v.item_id)
			local color = num >= v.num and "1eff00" or "ff2828"
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			local item_name = ""
			if item_cfg then
				item_name = item_cfg.name
			end
			rich_attr_consum1_content = rich_attr_consum1_content .. "\n" .. string.format(Language.CrossServer.ConsumeItemContent, color, item_name, v.num, num)
		end
	end
	if #consum.fujiao_rich_contents > 0 then
		rich_attr_consum1_content = rich_attr_consum1_content .. "\n"
	end
	for k, v in pairs(consum.fujiao_rich_contents) do
		rich_attr_consum1_content = rich_attr_consum1_content .. "\n" .. v.content
	end
	rich_attr_consum1_content = string.gsub(rich_attr_consum1_content, "^\n(.-)", "%1")	-- 去掉多余的换行
	RichTextUtil.ParseRichText(self.rich_attr_consum1, rich_attr_consum1_content)
end

-- 魔化\升阶 布局显隐
function CrossBattleEquip:FlushLayoutVis()
	self.layout_equip_upgrade:setVisible(self.view_type == VIEW_ENUM.UPGRADE)
	self.layout_equip_mohua:setVisible(self.view_type == VIEW_ENUM.MOHUA)
end

-- 按钮们
function CrossBattleEquip:FlushBtns()
	local btn_equip_up_str = ""
	local btn_change_equip_view_str = ""
	local btn_remind_eff_vis = CrossServerData.Instance:CrossEqCanUpgrade(self.select_equip_index) and self.view_type ~= VIEW_ENUM.UPGRADE
	local up_btn_enabled = true
	if self.view_type == VIEW_ENUM.MOHUA then
		btn_equip_up_str = Language.CrossServer.Mohua
		btn_change_equip_view_str = Language.CrossServer.Upgrade
		-- up_btn_enabled = CrossServerData.Instance:CrossEqCanMohua(self.select_equip_index)
	elseif self.view_type == VIEW_ENUM.UPGRADE then
		local is_act = CrossServerData.Instance:IsCrossEquipAct(self.select_equip_index)
		btn_equip_up_str = is_act and Language.CrossServer.Upgrade or Language.Common.Activate
		btn_change_equip_view_str = Language.Common.Return
		-- up_btn_enabled = CrossServerData.Instance:CrossEqCanUpgrade(self.select_equip_index)
	end

	self.btn_change_equip_view:setTitleText(btn_change_equip_view_str)
	self.btn_change_equip_view.btn_remind_eff:setVisible(btn_remind_eff_vis)
	self.btn_equip_up:setTitleText(btn_equip_up_str)
	XUI.SetButtonEnabled(self.btn_equip_up, up_btn_enabled)
end

-- 战斗力 总属性
function CrossBattleEquip:FlushCommonAllAttrs()
	local all_attrs = CrossServerData.Instance:GetEquipAllAttrs(self.select_equip_index)
	local all_score = CommonDataManager.GetAttrSetScore(all_attrs)
	self.zhan_dou_li:SetNumber(all_score)
	if nil == next(all_attrs) then
		all_attrs = nil
	end
	local plus_attrs = nil
	if nil ~= all_attrs and nil ~= self.last_attrs then
		plus_attrs = CommonDataManager.LerpAttributeAttr(self.last_attrs, all_attrs)
	end
	local is_act = CrossServerData.Instance:IsCrossEquipAct(self.select_equip_index)
	self.common_attr_view:SetData(all_attrs, plus_attrs)
	self.common_attr_view:GetView():setVisible(is_act)
	self.lbl_attr_not_active:setVisible(not is_act)
	self.last_attrs = all_attrs
end

function CrossBattleEquip:FlushEquipList()
	if self.equip_list then
		for k, v in pairs(self.equip_list:GetAllCell()) do
			v:Flush()
		end
	end
end

-------------------------------------------------------
-- 战装列表格子 begin
-------------------------------------------------------
function CrossEquipRender:__init(index, ui_config, click_callback)
	self.view:setContentWH(100, 100)
	self.cell = nil
	self:AddClickEventListener()
end

function CrossEquipRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end

	self.img_remind = nil
end

function CrossEquipRender:CreateChild()
	CrossEquipRender.super.CreateChild(self)

	local size = self.view:getContentSize()
	self.cell = BaseCell.New()
	self.cell:GetView():setPosition(size.width / 2, size.height / 2)
	self.cell:GetView():setAnchorPoint(cc.p(0.5, 0.5))
	self.cell:SetEventEnabled(false)
	self.cell:SetCellBg(ResPath.GetCommon("bg_164"))
	self.cell:GetView():setScale(1.2)
	self.view:addChild(self.cell:GetView(), 99)

	self.img_remind = XUI.CreateImageView(size.width - 10, size.height - 10, ResPath.GetMainui("remind_flag"), true)
	self.view:addChild(self.img_remind, 999)
end

function CrossEquipRender:OnFlush()
	if nil == self.data then
		return
	end

	local equip_data = EquipData.Instance:GetGridData(self.data.equip_index)
	if equip_data then
		self.cell:SetData(equip_data)
		self.cell:SetBgTaVisible(false)
	else
		self.cell:SetData(nil)
		self.cell:SetBgTa(ResPath.GetEquipBg("cross_equip_ta_" .. (self.data.equip_index - EquipData.EquipIndex.CrossEquipBeginIndex + 1)))
		self.cell:SetBgTaVisible(true)
	end

	self.img_remind:setVisible(CrossServerData.Instance:GetCrossEquipRemindByIndex(self.data.equip_index) > 0)
end

function CrossEquipRender:CreateSelectEffect()
	self.select_effect = RenderUnit.CreateEffect(1208, self.view, 998)
end
-------------------------------------------------------
-- 战装列表格子 end
-------------------------------------------------------

-------------------------------------------------------
-- 战装属性 begin
-------------------------------------------------------
function EquipAttrRender:__init(ui_config, parent, zorder)
	self.ui_config = ui_config
	self.view:setPosition(ui_config.x, ui_config.y)
	if parent then
		parent:addChild(self.view, zorder or 100)
	end

	self.attr_view = nil
	self.number_bar = nil
end

function EquipAttrRender:__delete()
	if self.attr_view then
		self.attr_view:DeleteMe()
		self.attr_view = nil
	end
	if self.number_bar then
		self.number_bar:DeleteMe()
		self.number_bar = nil
	end
end

function EquipAttrRender:CreateChild()
	EquipAttrRender.super.CreateChild(self)

	local size = self.view:getContentSize()

	local ph_attr = self.ph_list.ph_attr
	self.attr_view = AttrView.New(ph_attr.w, 20, 20, ResPath.GetCommon("img9_115"), true)
	self.attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
	self.attr_view:SetItemInterval(2)
	self.attr_view:SetDefTitleText(Language.Common.No)
	self.attr_view:GetView():setPosition(ph_attr.x, ph_attr.y)
	self.view:addChild(self.attr_view:GetView(), 10)

	local x, y = self.node_tree.img_zdl_word.node:getPosition()
	self.number_bar = NumberBar.New()
	self.number_bar:Create(x + 39, y - 12, 1, 25, ResPath.GetMainui("num_"))
	self.number_bar:GetView():setScale(0.7)
	self.number_bar:SetSpace(-2)
	self.view:addChild(self.number_bar:GetView(), 50)
end

function EquipAttrRender:OnFlush()
	if nil == self.data then
		return
	end

	local attrs = self.data
	self.number_bar:SetNumber(CommonDataManager.GetAttrSetScore(attrs))
	if nil == next(attrs) then
		attrs = nil
	end
	self.attr_view:SetData(attrs)
end

function EquipAttrRender:CreateSelectEffect()
end
-------------------------------------------------------
-- 战装属性 end
-------------------------------------------------------

return CrossBattleEquip

