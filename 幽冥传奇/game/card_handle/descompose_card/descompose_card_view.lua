------------------------------------------------------------
-- 回收
------------------------------------------------------------
local DescomposeCardView = BaseClass(SubView)

function DescomposeCardView:__init()
	self:SetIsAnyClickClose(true)
	self.texture_path_list = {
		'res/xui/card_handlebook.png',
		'res/xui/bag.png',
	}
	self.config_tab = {
		{"card_handlebook_ui_cfg", 3, {0}},
	}
end

function DescomposeCardView:__delete()
end

function DescomposeCardView:ReleaseCallBack()
	if nil ~= self.descompose_list then
		self.descompose_list:DeleteMe()
		self.descompose_list = nil
	end

	if self.card_compose then
		self.card_compose:DeleteMe()
		self.card_compose = nil
	end

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function DescomposeCardView:LoadCallBack(index, loaded_times)
	CardHandlebookData.Instance:InitDescomposeCardDataList()
	self:CreateDescomposeList()
	self:CreateCardList()
	self:CreateRewardCells()

	local role_event_proxy = EventProxy.New(RoleData.Instance, self)
	role_event_proxy:AddEventListener(OBJ_ATTR.ACTOR_RIDE_LEVEL, BindTool.Bind(self.OnMainRoleChange, self))

	-- 一键分解按钮回调绑定
	XUI.AddClickEventListener(self.node_t_list.btn_compose.node, BindTool.Bind(self.OnClickOneKeyDescompose), true)

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(CardHandlebookData.Instance, self):AddEventListener(CardHandlebookData.CARD_CHESS_CHANGE, BindTool.Bind(self.OnDescomposeResult, self))
	EventProxy.New(CardHandlebookData.Instance, self):AddEventListener(CardHandlebookData.CARD_DESCOMPOSE_RESULT, BindTool.Bind(self.OnDescomposeResult, self))

end

function DescomposeCardView:OpenCallBack()
end

function DescomposeCardView:OnMainRoleChange()
	self:OnDescomposeResult()
end

function DescomposeCardView:CreateDescomposeList()
	self.descompose_list = BaseGrid.New()
	-- self.descompose_list:SetPageChangeCallBack(BindTool.Bind1(self.OnBagPageChange, self))
	
	local ph_baggrid = self.ph_list.ph_card_list
	local grid_node = self.descompose_list:CreateCells({w=ph_baggrid.w, h=ph_baggrid.h, cell_count = 120, col=6, row=5, itemRender=BagCell, direction = ScrollDir.Vertical})
	grid_node:setAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_card_decompose.node:addChild(grid_node, 100)
	grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
	self.descompose_list:SetSelectCallBack(BindTool.Bind1(self.SelectRecycleCellCallBack, self))
end

function DescomposeCardView:SelectRecycleCellCallBack(cell)
	if nil == cell or nil == cell:GetData() then
		return
	end

	local cell_data = cell:GetData()
end

function DescomposeCardView:CreateCardList()
	local ph = self.ph_list.ph_recycle_list
	self.card_compose = ListView.New()
	self.card_compose:Create(ph.x, ph.y, ph.w, ph.h, nil, CradListRender, nil, nil, self.ph_list.ph_recycle_item)
	self.node_t_list.layout_card_decompose.node:addChild(self.card_compose:GetView(), 100)
	self.card_compose:SetItemsInterval(1)
	self.card_compose:SetMargin(1)
	self.card_compose:SetJumpDirection(ListView.Top)
end

function DescomposeCardView:CreateRewardCells()
	self.cell_list = {}
	for i = 1, 4 do
		local ph = self.ph_list["ph_item_cell_" .. i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_card_decompose.node:addChild(cell:GetView(), 103)
		table.insert(self.cell_list, cell)
	end
end

function DescomposeCardView:ShowIndexCallBack(index)
	self:Flush()
end

function DescomposeCardView:OnFlush(param_t, index)
	self:FlushBagCard()
end

function DescomposeCardView:OnDescomposeResult()
	self:FlushBagCard()
end

local card_rew = {
	[1] = 77,
}

function DescomposeCardView:FlushBagCard()
	-- local card_list = CardHandlebookData.Instance:GetDescomposeCardBagList()
	local card_list = CardHandlebookData.Instance:RevertTypeEquip(CardHandlebookData.Instance:GetRecycleChess())

	self.descompose_list:SetDataList(card_list)

	self.card_compose:SetDataList(Language.CardHandlebook.ComposeType)

	local rew_list = {}
	for k, v in pairs(card_rew) do
		local vo = {
			item_id = ItemData.GetVirtualItemId(v), 
			num = CardHandlebookData.Instance:GetDecomposeListObtain(card_list),
		}
		table.insert(rew_list, vo)
	end

	for k1, v1 in pairs(self.cell_list) do
		if nil ~= rew_list[k1] and rew_list[k1].num > 0 then
			v1:SetData(rew_list[k1])
		else
			v1:SetData(nil)
		end
	end
end

function DescomposeCardView:OnBagItemChange(vo)
	GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.FlushBagCard, self), 0) -- 延迟到下一帧，防止嵌套
end

function DescomposeCardView:OnClickOneKeyDescompose()
	local card_list = CardHandlebookData.Instance:RevertTypeEquip(CardHandlebookData.Instance:GetRecycleChess())
	local equip_list = {}
	local count = 0
	for k, v in pairs(card_list) do
		count = count + 1
		local equip_t = {}
		equip_t.cfg_index = CardHandlebookData.GetCardSeriessAndIndexById(v.item_id)
		equip_t.series = v.series
		table.insert(equip_list, equip_t)
		if math.modf(count / 50) == 0 then
			CardHandlebookCtrl.CardDecomposeReq(equip_list)
			equip_list = {}
		end
	end
	if #equip_list ~= 0 then
		CardHandlebookCtrl.CardDecomposeReq(equip_list)
		equip_list = {}
	end
end

----------------------------------------------------
-- 回收列表itemRender
----------------------------------------------------
CradListRender = CradListRender or BaseClass(BaseRender)

function CradListRender:__init()
end

function CradListRender:__delete()
	
end

function CradListRender:CreateChild()
	BaseRender.CreateChild(self)
	
	XUI.AddClickEventListener(self.node_tree.img_check.node, BindTool.Bind(self.OnClickRegis, self), false)
	self.node_tree.img_set_equ.node:setVisible(CardHandlebookData.Instance:GetRecycleChess()[self.index] == 1)
end

function CradListRender:OnFlush()
	if nil == self.data then return end

	local _, num = CardHandlebookData.Instance:RquipTypeShow(self.index)
	local color_1 = (num == 0) and "a6a6a6" or "1eff00"
	local color_2 = (num == 0) and COLOR3B.GRAY or COLOR3B.G_W2
	RichTextUtil.ParseRichText(self.node_tree.txt_equ_num.node, string.format(self.data, color_1, num), nil, color_2)
end

function CradListRender:OnClickRegis()
	self.node_tree.img_set_equ.node:setVisible(not self.node_tree.img_set_equ.node:isVisible())
	
	CardHandlebookData.Instance:SetCardChessData(self.index, self.node_tree.img_set_equ.node:isVisible())
end

function CradListRender:CreateSelectEffect()
end

return DescomposeCardView