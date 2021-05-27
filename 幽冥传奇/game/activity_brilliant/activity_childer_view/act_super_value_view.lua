----------------------------------------
-- 运营活动 95 超值礼包
----------------------------------------

SuperValueGiftView = SuperValueGiftView or BaseClass(ActBaseView)

function SuperValueGiftView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function SuperValueGiftView:__delete()
	if nil ~= self.cell_show_list then
		for k,v in pairs(self.cell_show_list) do
			v:DeleteMe()
			v = nil
		end
	end
	self.cell_show_list = {}

	if self.task_list then
		self.task_list:DeleteMe()
		self.task_list = nil
	end
end

function SuperValueGiftView:InitView()
	self:CreateTaskList()

	-- EventProxy.New(ShenDingData.Instance, self):AddEventListener(ShenDingData.TASK_DATA_CHANGE, BindTool.Bind(self.RefreshView, self))
end

function SuperValueGiftView:RefreshView(param_list)
	local task_data_list = ActivityBrilliantData.Instance:GetCZLBData()
	self.task_list:SetDataList(task_data_list)
	self.task_list:JumpToTop()
end

function SuperValueGiftView:CreateTaskList()
	local ph = self.ph_list["ph_list"]
	local ph_item = self.ph_list["ph_item"] or {x = 0, y = 0, w = 10, h = 10}
	local parent = self.tree.node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 3, ph_item.h + 1, self.GiftItemRender, ScrollDir.Vertical, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.task_list = grid_scroll
end

----------------------------------------
-- GiftItemRender
----------------------------------------

SuperValueGiftView.GiftItemRender = BaseClass(BaseRender)
local GiftItemRender = SuperValueGiftView.GiftItemRender
function GiftItemRender:__init()
	
end

function GiftItemRender:__delete()
	
end

function GiftItemRender:CreateChild()
	BaseRender.CreateChild(self)

	XUI.AddClickEventListener(self.node_tree["btn_buy"].node, BindTool.Bind(self.OnLeaveFor, self))

	local parent = self.view
	local ph = self.ph_list["ph_cell"] or {x = 0, y = 0, w = 10, h = 10}
	local cell = BaseCell.New()
	-- cell:SetIsShowTips(false)
	cell:SetPosition(ph.x, ph.y)
	parent:addChild(cell:GetView(), 99)
	self.cell = cell
	self:AddObj("cell")
end

function GiftItemRender:OnFlush()
	if nil == self.data then return end

	local cell_cfg = ItemData.FormatItemData(self.data.award)
	self.cell:SetData(cell_cfg)
	local item_cfg = ItemData.Instance:GetItemConfig(cell_cfg.item_id)
	self.node_tree.lbl_item_name.node:setString(item_cfg.name)
	self.node_tree.lbl_item_name.node:setColor(Str2C3b(string.format("%06x", item_cfg.color)))
	self.node_tree.lbl_src_price.node:setString(self.data.src_price)
	self.node_tree.lbl_curr_price.node:setString(self.data.curr_price)
	self.node_tree.lbl_discount.node:setString(self.data.discount)
	local is_buy = self.data.buy_tms >= self.data.max_buy_tms
	self.node_tree.btn_buy.node:setVisible(not is_buy)
	self.node_tree.img_is_buy.node:setVisible(is_buy)
	XUI.EnableOutline(self.node_tree.lbl_discount.node, nil, 1.2)

	local res_path = RoleData.GetMoneyTypeIconByAwardType(self.data.money_type)
	self.node_tree.img_y_curr.node:loadTexture(res_path)
	self.node_tree.img_x_curr.node:loadTexture(res_path)
end

function GiftItemRender:OnLeaveFor()
	local act_id = ACT_ID.CZLB
	ActivityBrilliantCtrl.ActivityReq(4, act_id, self.data.index)
end

function GiftItemRender:CreateSelectEffect()
	return
end