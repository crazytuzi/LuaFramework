local OpenSerVeGiftQGView = OpenSerVeGiftQGView or BaseClass(SubView)
local ItemRender = ItemRender or BaseClass(BaseRender)

function OpenSerVeGiftQGView:__init()
	-- self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/open_serve_gift.png'
	self.texture_path_list[2] = "res/xui/vip.png"
	self.config_tab = {
		{"open_serve_gift_ui_cfg", 3, {0}},
	}
end

function OpenSerVeGiftQGView:ReleaseCallBack()
	for i,v in ipairs(self.delete_list) do
		v:DeleteMe()
	end
	self.delete_list = nil


	if nil ~= self.update_spare_timer then
		GlobalTimerQuest:CancelQuest(self.update_spare_timer)
	end
	self.update_spare_timer = nil
end

function OpenSerVeGiftQGView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
	end
	self.delete_list = {}

	self.item_list = self:CreateItemList()
	table.insert(self.delete_list, self.item_list)

	RichTextUtil.ParseRichText(self.node_t_list.rich_act_desc.node, "活动期间, 满足条件即可购买", 19)

	--剩余时间
	local now_time = TimeCtrl.Instance:GetServerTime()
	self.update_spare_timer = GlobalTimerQuest:AddRunQuest(function ()
		-- local end_time = now_time + 5 * 86400
		-- local str = TimeUtil.FormatSecond2Str(end_time - TimeCtrl.Instance:GetServerTime())
		self.node_t_list.lbl_spare_time.node:setString(TimeUtil.FormatSecond2Str(OpenSerVeGiftData.Instance:GetSpareTime()))
	end, 1)

	EventProxy.New(OpenSerVeGiftData.Instance, self):AddEventListener(OpenSerVeGiftData.LimTimeGitfInfoChange, function ()
		self.item_list:SetDataList(OpenSerVeGiftData.Instance:GetLimitGiftList())
		self.item_list:SelectIndex(OpenSerVeGiftData.Instance:GetNextCanBuyIdx())
	end)
end

function OpenSerVeGiftQGView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function OpenSerVeGiftQGView:ShowIndexCallBack(index)
	self:Flush()
end

function OpenSerVeGiftQGView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function OpenSerVeGiftQGView:OnFlush(param_t, index)
	self.item_list:SetDataList(OpenSerVeGiftData.Instance:GetLimitGiftList())
	self.item_list:SelectIndex(OpenSerVeGiftData.Instance:GetNextCanBuyIdx())
end


function OpenSerVeGiftQGView:CreateItemList()
	local ph = self.ph_list.ph_qg_list
	local list = ListView.New()
	list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical , ItemRender, nil, nil, self.ph_list.ph_qg_item)
	list:SetItemsInterval(4)
	list:SetMargin(2)
	list:SetJumpDirection(ListView.Top)
	self.node_t_list.layout_qinggou.node:addChild(list:GetView(), 300)
	return list
end

-----------------------------------
--item render 特惠礼包顶部列表
function ItemRender:CreateChildCallBack()
	XUI.AddClickEventListener(self.node_tree.btn_bag_buy.node, BindTool.Bind(self.OnClickBuy, self))

	local vip_level_num = NumberBar.New()
	vip_level_num:SetGravity(NumberBarGravity.Left)
	vip_level_num:SetRootPath(ResPath.GetVipResPath("vip_tequan_num_"))
	vip_level_num:SetPosition(55, 2)
	vip_level_num:SetSpace(-1)
	self.vip_level_num = vip_level_num
	self.node_tree.layout_vip_can_buy.node:addChild(vip_level_num:GetView(), 100, 100)

	local sale_num_cap = NumberBar.New()
	sale_num_cap:SetGravity(NumberBarGravity.Left)
	sale_num_cap:SetRootPath(ResPath.GetVipResPath("vip_tequan_num_"))
	sale_num_cap:SetPosition(6, 97)
	sale_num_cap:SetSpace(7)
	self.sale_num_cap = sale_num_cap
	self.view:addChild(sale_num_cap:GetView(), 100, 100)

	local ph = self.ph_list.ph_award_list
	local list = ListView.New()
	list:Create(ph.x, ph.y+5, ph.w, ph.h + 20, ScrollDir.Horizontal, NameCell, nil, nil)
	list:SetItemsInterval(4)
	list:SetMargin(2)
	self.view:addChild(list:GetView(), 3)
	self.award_list = list

	self.stamp_img = XUI.CreateImageView(620, 60, ResPath.GetCommon("stamp_5"))
	self.view:addChild(self.stamp_img, 300)
	self.stamp_img:setVisible(false)
end

function ItemRender:OnClickBuy()
	OpenSerVeGiftData.Instance:SendQGBuyReq(self.data.idx)
end

function ItemRender:OnFlush()
	if nil == self.data then return end
	local vip = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)

	local list = {}
	for i,v in ipairs(self.data.award) do
		list[i] = ItemData.FormatItemData(v)
	end
	self.award_list:SetDataList(list)

	self.sale_num_cap:SetNumber(self.data.discount * 100)

	self.vip_level_num:SetNumber(self.data.vipLv)
	self.node_tree.layout_vip_can_buy.node:setVisible(self.data.vipLv > 0)


	local is_can_buy = OpenSerVeGiftData.Instance:GetBuyNumByIdx(self.data.idx) == self.data.buyTms
	self.stamp_img:setVisible(is_can_buy)
	self.node_tree.btn_bag_buy.node:setVisible(not is_can_buy)
	self.node_tree.btn_bag_buy.node:setEnabled(vip >= self.data.vipLv)
	self.node_tree.lbl_can_buy.node:setVisible(not is_can_buy)

	-- self.node_tree.img_line.node:setScale(self.data.currMoney.count > 10000 and 8 or 7)
	self.node_tree.label_sale_item_old_cost.node:setString(self.data.srcMoney.count)
	self.node_tree.label_sale_item_cost.node:setString(self.data.currMoney.count)
	self.node_tree.lbl_can_buy.node:setString("可购买次数: ".. OpenSerVeGiftData.Instance:GetBuyNumByIdx(self.data.idx) .. "/" .. self.data.buyTms)
end

----------------------------------------------------
-- 带名字的cell
----------------------------------------------------
NameCell = NameCell or BaseClass(BaseCell)

function NameCell:__init()
	self.name = GRID_TYPE_BAG
end

function NameCell:__delete()
end

function NameCell:OnFlush(...)
	if BaseCell.OnFlush(self, ...) then
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
		if nil == self.item_name then
			self.item_name = XUI.CreateText(BaseCell.SIZE / 2, - 10, 0, 0, cc.TEXT_ALIGNMENT_CENTER, item_cfg.name, nil, 18)
			self.view:addChild(self.item_name, 300)
		end
		self:GetView():setPositionX(self:GetView():getPositionX() + 10)
		self.item_name:setString(item_cfg.name)
		self.item_name:setColor(Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6)))
	end

end

function NameCell:CreateSelectEffect()
end

return OpenSerVeGiftQGView