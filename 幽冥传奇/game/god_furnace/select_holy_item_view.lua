
-- 圣物选择
SelectHolyItemView = SelectHolyItemView or BaseClass(BaseView)

function SelectHolyItemView:__init()
	self.texture_path_list = {
		'res/xui/godfurnace.png',
	}
	self.config_tab = {
		{"common2_ui_cfg", 1, {0}},
		{"common2_ui_cfg", 2, {0}, nil, 999},
		{"holy_synthesis_ui_cfg", 2, {0}},
	}

	self.mutli_select_tab = {}
end

function SelectHolyItemView:__delete()
end

function SelectHolyItemView:ReleaseCallBack()
	self:InitSelectItem()
	if self.holy_list then
		self.holy_list:DeleteMe()
		self.holy_list = nil
	end
end

function SelectHolyItemView:LoadCallBack(index, loaded_times)
	self:CreateTopTitle(ResPath.GetGodFurnace("word_select_holy"), 275, 695)

	XUI.RichTextSetCenter(self.node_t_list.rich_tip.node)
	local content = "选择三个相同品质的圣物"
	RichTextUtil.ParseRichText(self.node_t_list.rich_tip.node, content, 22, COLOR3B.ORANGE)

	-- 按钮
	self.node_t_list.btn_putin.node:setTitleText("放入")
	self.node_t_list.btn_putin.node:setTitleFontName(COMMON_CONSTS.FONT)
	self.node_t_list.btn_putin.node:setTitleFontSize(22)
	self.node_t_list.btn_putin.node:setTitleColor(COLOR3B.G_W2)
	XUI.AddClickEventListener(self.node_t_list.btn_putin.node, BindTool.Bind(self.OnClickPutIn, self))

	local ph = self.ph_list.ph_item_list
	self.holy_list = GridScroll.New()
	self.holy_list:Create(ph.x, ph.y, ph.w, ph.h, 4, 110, SelectHolyItemView.HolyBagItem, ScrollDir.Vertical, false)
	self.holy_list:SetSelectCallBack(BindTool.Bind(self.SelectItem, self))
	self.node_t_list.layout_select_holy.node:addChild(self.holy_list:GetView(), 100)
	self:InitSelectItem()

	EventProxy.New(GodFurnaceData.Instance, self):AddEventListener(GodFurnaceData.HOLY_BAG_ITEM_CHANGE, BindTool.Bind(self.OnHolyBagItemChange, self))
end

function SelectHolyItemView:OpenCallBack()
end

function SelectHolyItemView:CloseCallBack(is_all)
	self:InitSelectItem()
end

function SelectHolyItemView:ShowIndexCallBack(index)
	self:Flush()
end

function SelectHolyItemView:OnFlush(param_t, index)
	self.holy_list:SetDataList(GodFurnaceData.Instance:GetHolyBagList())
	self:UpdateMutliSelectTable()
end
------------------------------------------------------------------------
function SelectHolyItemView:InitSelectItem()
	for k, v in pairs(self.mutli_select_tab) do
		if not v.is_delete then
			v:SetSelect(false)
		end
	end
	self.mutli_select_tab = {}
end

function SelectHolyItemView:SelectItem(item)
	if nil ~= self.mutli_select_tab[item] then
		self.mutli_select_tab[item] = nil
		item:SetSelect(false)
	else
		self.mutli_select_tab[item] = item
	end

	for k, v in pairs(self.mutli_select_tab) do
		if not v.is_delete then
			v:SetSelect(true)
		else
			self.mutli_select_tab[k] = nil
		end
	end
end

function SelectHolyItemView:OnHolyBagItemChange()
	self:Flush()
end

function SelectHolyItemView:UpdateMutliSelectTable()
	for k, v in pairs(self.mutli_select_tab) do
		if v.is_delete then
			self.mutli_select_tab[k] = nil
		end
	end
end

function SelectHolyItemView:OnClickPutIn()
	self:UpdateMutliSelectTable()
	for k, v in pairs(self.mutli_select_tab) do
		v:SetSelect(false)
		self.mutli_select_tab[k] = nil
		GodFurnaceData.Instance:AddToHolySynthesis(v:GetData())
	end
end
------------------------------------------------------------------------
local HolyBagItem = BaseClass(BaseRender)
SelectHolyItemView.HolyBagItem = HolyBagItem
HolyBagItem.size = cc.size(80, 92)
function HolyBagItem:__init()
	self.view:setContentSize(HolyBagItem.size)

	self.cell = BaseCell.New()
	self.cell:SetPosition(HolyBagItem.size.width / 2, HolyBagItem.size.height - BaseCell.SIZE / 2)
	self.cell:SetAnchorPoint(0.5, 0.5)
	self.cell:SetIsShowTips(false)
	self.view:addChild(self.cell:GetView(), 10)
	self.cell:SetEventEnabled(false)

	self.is_delete = false
end

function HolyBagItem:__delete()
	self.is_delete = true

	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function HolyBagItem:CreateChild()
	HolyBagItem.super.CreateChild(self)

	self.rich_text = XUI.CreateRichText(HolyBagItem.size.width / 2, 0, 100, 16, true)
	self.rich_text:setAnchorPoint(0.5, 0)
	self.view:addChild(self.rich_text, 10)
end

function HolyBagItem:OnFlush()
	self.cell:SetData(self.data)
	if nil ~= self.data then
		RichTextUtil.ParseRichText(self.rich_text, ItemData.Instance:GetItemNameRich(self.data.item_id, 18))
	end
end

return SelectHolyItemView
