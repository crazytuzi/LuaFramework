------------------------------------------------------------
-- VipBoss
------------------------------------------------------------

VipBossView = VipBossView or BaseClass(BaseView)

function VipBossView:__init()
	self:SetModal(true)

	self.texture_path_list[1] = "res/xui/vip.png"
	self.config_tab = {
		{"vip_ui_cfg", 2, {0}},
	}

	self.cell_list = {}
end

function VipBossView:__delete()
end

function VipBossView:ReleaseCallBack()
	if self.cell_list then
		self.cell_list:DeleteMe()
		self.cell_list = nil
	end

	self.select_vip_boss_data = nil
end

function VipBossView:LoadCallBack(index, loaded_times)
	self:CreateCellList()
	self:InitTextBtn()

	--按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.OnBtn, self), true)

	-- 数据监听
	-- EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleAttrChange, self))

end

--显示索引回调
function VipBossView:ShowIndexCallBack(index)
	self.select_vip_boss_data = VipData.Instance:GetSelectVipBossData()

	local name = self.select_vip_boss_data.boss_name or ""
	self.node_t_list["lbl_boss_name"].node:setString(name)
	XUI.EnableOutline(self.node_t_list["lbl_boss_name"].node)

	local power = self.select_vip_boss_data.power or 0
	local role_power = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BATTLE_POWER)
	local bool = role_power >= power
	local color = bool and COLOR3B.GREEN or COLOR3B.RED
	self.node_t_list["lbl_power"].node:setColor(color)
	self.node_t_list["lbl_power"].node:setString(Language.Vip.VipBossPower .. power)

	self:FlushCellList()
end

----------视图函数----------

function VipBossView:CreateCellList()
	local ph = self.ph_list["ph_cell_list"]
	local ph_item = self.ph_list["ph_cell_item"]
	local parent = self.node_t_list["layout_vip_boss"].node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 10, self.CellListItem, ScrollDir.Horizontal, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.cell_list = grid_scroll
end

function VipBossView:FlushCellList()
	local show_list = self.select_vip_boss_data.show or {}
	self.cell_list:SetDataList(show_list)

	-- 居中处理
	local view = self.cell_list:GetView()
	local inner = view:getInnerContainer()
	local size = view:getContentSize()
	local interval = 10
	local inner_width = (self.ph_list["ph_cell_item"].w + interval) * (#show_list) - interval
	local view_width = math.min(self.ph_list["ph_cell_list"].w, inner_width + 20)
	view:setContentSize(cc.size(view_width, size.height))
	view:setInnerContainerSize(cc.size(inner_width, size.height))
	view:jumpToTop()
end

function VipBossView:InitTextBtn()
	local ph
	local text_btn
	local parent = self.node_t_list["layout_vip_boss"].node

	ph = self.ph_list["ph_text_btn"]
	text_btn = RichTextUtil.CreateLinkText("获取魂力值", 20, COLOR3B.GREEN)
	text_btn:setPosition(ph.x, ph.y)
	parent:addChild(text_btn, 99)
	XUI.AddClickEventListener(text_btn, BindTool.Bind(self.OnTextBtn, self), true)
end


----------end----------

-- 挑战boss按钮点击回调
function VipBossView:OnBtn()
	if self.select_vip_boss_data.percent < 100 then
		local item_id = VipChapterConfig and VipChapterConfig.show_id or 0
		local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
		local data = string.format("{reward;0;%d;1}", item_id) .. (ways and ways or "")
		TipCtrl.Instance:OpenBuyTip(data)		
	end
	VipCtrl.SentSChallengeVipBoss()
end

function VipBossView:OnTextBtn()
	local item_id = VipChapterConfig and VipChapterConfig.show_id or 0
	local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
	local data = string.format("{reward;0;%d;1}", item_id) .. (ways and ways or "")
	TipCtrl.Instance:OpenBuyTip(data)
end


--------------------

----------------------------------------
-- cell_list 渲染
----------------------------------------
VipBossView.CellListItem = BaseClass(BaseRender)
local CellListItem = VipBossView.CellListItem
function CellListItem:__init()
	--self.item_cell = nil
end

function CellListItem:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function CellListItem:CreateChild()
	BaseRender.CreateChild(self)

	local ph = self.ph_list["ph_cell"]
	local cell = BaseCell.New()
	cell:SetPosition(ph.x, ph.y)
	self.view:addChild(cell:GetView(), 2)
	self.cell = cell
end

function CellListItem:OnFlush()
	if nil == self.data then return end
	local item_name = ItemData.Instance:GetItemName(self.data.item_id or 1)
	self.node_tree["lbl_item_name"].node:setString(item_name)
	self.cell:SetData(self.data)
	self.cell:SetBindIconVisible(false)
end

function CellListItem:CreateSelectEffect()
	return
end

function CellListItem:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end