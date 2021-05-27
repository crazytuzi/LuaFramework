

ActLegendView = ActLegendView or BaseClass(ActBaseView)
function ActLegendView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function ActLegendView:__delete()
	if nil~=self.contend_list then
		self.contend_list:DeleteMe()
	end
	self.contend_list=nil

end

function ActLegendView:InitView()
	self:CreateContendList()
	
end

function ActLegendView:RefreshView(param_list)
	self.contend_list:SetDataList(ActivityBrilliantData.Instance:GetZhigouData())
end

function ActLegendView:CreateContendList() --右侧排位表

	if nil == self.contend_list then
		local ph = self.ph_list.ph_contend_list
		self.contend_list = ListView.New()
		-- self:AddObj("contend_list")
		self.contend_list:Create(ph.x, ph.y, ph.w, ph.h, nil, LegendItemRender, nil, nil, self.ph_list.ph_contend_item)
		-- self.contend_list:GetView():setAnchorPoint(0, 0)
		self.contend_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_act_legend.node:addChild(self.contend_list:GetView(), 100)
	end	
end

LegendItemRender = LegendItemRender or BaseClass(BaseRender)
function LegendItemRender:__init()
end

function LegendItemRender:__delete()
	 if nil ~= self.cell_contend_list then
	 	self.cell_contend_list:DeleteMe()
	 	self.cell_contend_list = nil
	 end
end

function LegendItemRender:CreateChild()
	BaseRender.CreateChild(self)
	 local ph = self.ph_list.ph_reward_item
	 self.cell_contend_list = ListView.New()
	 self.cell_contend_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	 self.cell_contend_list:GetView():setAnchorPoint(0, 0)
	 self.cell_contend_list:SetItemsInterval(10)
	 self.view:addChild(self.cell_contend_list:GetView(), 10)

	 XUI.AddClickEventListener(self.node_tree.btn_buy.node, BindTool.Bind(self.OnClickGoBuy, self), true)
end

function LegendItemRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.lbl_gift_name.node:setString(self.data.gift_name)
	local language = {"{wordcolor;ffff00;会员经验+%s}", "{wordcolor;ffff00;会员经验+%s}{wordcolor;55ff00;(双倍)}"}
	local text = string.format(language[self.data.is_double], self.data.vip_exp)
	RichTextUtil.ParseRichText(self.node_tree.rich_vip_exp.node, text, 20)
	XUI.RichTextSetRight(self.node_tree.rich_vip_exp.node)
	local data_list = {}
	for k, v in pairs(self.data.awards) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.FormatItemData(v))
		end
	end
	self.cell_contend_list:SetDataList(data_list)
	self.node_tree.is_complete.node:setVisible(self.data.is_falg)
	self.node_tree.lbl_buy_time.node:setString(string.format("可购买：%d/%d", self.data.buy_time, self.data.max_buy_time))
	self.node_tree.btn_buy.node:setTitleText(string.format("%s元购买", self.data.rmb_num))
	self.node_tree.btn_buy.node:setVisible(not self.data.is_falg)
end

function LegendItemRender:OnClickGoBuy()
	local re_type = string.format("%d|%d", self.data.act_id, self.data.cmd_id)
	ChongzhiCtrl.ActivityCharge(self.data.rmb_num, re_type)
end