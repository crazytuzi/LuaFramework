------------------------------------------------------------
--可选择物品tip
------------------------------------------------------------
SelectItemTip = SelectItemTip or BaseClass(BaseView)

local select_data = nil

function SelectItemTip:__init()
	self.is_async_load = false
	self.zorder = COMMON_CONSTS.SELECT_ITEM_TIPS
	self.is_any_click_close = true
	self.is_modal = true
	self.item_id = 0
	self.config_tab = {{"itemtip_ui_cfg", 14, {0}}}
end

function SelectItemTip:__delete()
	if self.exchange_alert then
		self.exchange_alert:DeleteMe()
  		self.exchange_alert = nil
	end	
	if self.grid_select_scroll_list then
		self.grid_select_scroll_list:DeleteMe()
		self.grid_select_scroll_list = nil
	end
end

function SelectItemTip:ReleaseCallBack()
	-- self.tabbar:DeleteMe()
	-- self.tabbar = nil

	self.grid_select_scroll_list:DeleteMe()
	self.grid_select_scroll_list = nil

end

function SelectItemTip:LoadCallBack()
	-- if nil == self.tabbar then
	-- 	self.tabbar = Tabbar.New()
	-- 	self.tabbar:CreateWithNameList(self.root_node, 50, 320,
	-- 		function(pro) self:ChangeToIndex(pro) end, 
	-- 		Language.Tip.SelectItemGroup, false, ResPath.GetCommon("btn_144"))

	-- 	self.tabbar:SetSpaceInterval(20)
	-- 	self.tabbar:ChangeToIndex(self:GetShowIndex())
	-- end

	local ph = self.ph_list.ph_item_list
	self.grid_select_scroll_list = GridScroll.New()
	self.grid_select_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 3, 140, SelectItemRender, ScrollDir.Vertical, false,self.ph_list.ph_item_render)
	self.node_t_list.layout_select_item_tip.node:addChild(self.grid_select_scroll_list:GetView(), 100)
	-- self.grid_select_scroll_list:SetDataList(self:GetAwardCfg(1))
	self.grid_select_scroll_list:SetSelectCallBack(BindTool.Bind(self.OnClickRenderHandle, self))

	XUI.AddClickEventListener(self.node_t_list.btn_ok.node, function ()
		if nil == select_data then
			SysMsgCtrl.Instance:FloatingTopRightText("请选择物品")
			return
		end
		local have_num = BagData.Instance:GetItemNumInBagById(self.item_id)
		if have_num <= 1 then
			BagCtrl.SendSelectItemReq(select_data.id, select_data.pro, select_data.index, 1)
		else
			TipCtrl.Instance:ShowSelectItemNumip({num = have_num, item_id = self:GetAwardCfg(1)[select_data.index].vid, pro = 1, parent_id = select_data.id, index = select_data.index})
		end
		TipCtrl.Instance:CloseSelectView()
	end, true)
end

function SelectItemTip:OnClickRenderHandle(item)		
	select_data = item:GetData()
	for k,v in pairs(self.grid_select_scroll_list:GetItems()) do
		v:OnSelectOne(item:GetIndex())
	end
end

function SelectItemTip:OnClickOkHandle()
	local have_num = ItemData.Instance:GetItemNumInBagById(self.item_id)

	if have_num <= 1 then
		BagCtrl.SendSelectItemReq(select_data.id, select_data.pro, select_data.index, 1)
	else
		-- self.quick_buy = self.quick_buy or SelectNumWithConfirm.New()
		-- self.quick_buy:SetConfirmCallback(function(item_count)
		-- 	BagCtrl.SendSelectItemReq(select_data.id, select_data.pro, select_data.index,item_count)
		-- 	self.quick_buy:Close()
		-- end)
		-- self.quick_buy:Open()
		-- self.quick_buy:Flush(0, "param", {select_data.vid, 0,select_data.id,select_data.count})
	end
	TipCtrl.Instance:CloseSelectView()
end


function SelectItemTip:ShowIndexCallBack()
	-- self.tabbar:ChangeToIndex(1)
end

function SelectItemTip:CloseCallBack()
	self.item_id = 0
	select_data = nil
	for k,v in pairs(self.grid_select_scroll_list:GetItems()) do
		v:OnSelectOne(-1)
	end
end

function SelectItemTip:GetAwardCfg(pro)
	local item_list = {}

	for k,v in pairs(UseItemChooseItem) do
		if v.item_id == self.item_id then
			for k1,v1 in pairs(v.award) do
				table.insert(item_list, {id = v.item_id, vid = v1[pro].id, name = v1[pro].name, count =v1[pro].count , index = k1, pro = pro})
			end
		end
	end
	return item_list
end

function SelectItemTip:ChangeToIndex(pro)
	self.grid_select_scroll_list:SetDataList(self:GetAwardCfg(pro))
	self.grid_select_scroll_list:JumpToTop()
end

function SelectItemTip:OnTabChangeHandler(index)

end

function SelectItemTip:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			self.item_id = v.item_id
			self:ChangeToIndex(1)
		end
	end
end


SelectItemRender = SelectItemRender or BaseClass(BaseRender)
function SelectItemRender:__init()
	self:AddClickEventListener()
end

function SelectItemRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function SelectItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(self.ph_list.ph_item_cell.x, self.ph_list.ph_item_cell.y)
	self.item_cell:GetView():setAnchorPoint(cc.p(0.5, 0.5))
	self.view:addChild(self.item_cell:GetView(), 7)

	XUI.AddClickEventListener(self.node_tree.layout_check.btn_nohint_checkbox.node, function ()
		select_idx = self:GetIndex()
		self:OnClick()
	end, true)
	self.node_tree.layout_check.img_hook.node:setVisible(false)
end

function SelectItemRender:OnSelectOne(idx)
	self.node_tree.layout_check.img_hook.node:setVisible(idx == self:GetIndex())
end

function SelectItemRender:OnFlush()
	if nil == self.data then return end
	self.item_cell:SetData({item_id = self.data.vid, num = self.data.count , is_bind = 0})
	self.node_tree.lbl_item_name.node:setString(self.data.name)
	self.node_tree.lbl_item_name.node:setColor(COLOR3B.GREEN)
end

-- function SelectItemRender:OnClickBtnHandle()
-- 	 BagCtrl.SendSelectItemReq(self.data.id, self.data.pro, self.data.index)
-- 	 TipsCtrl.Instance:CloseSelectView()
-- end

-- 创建选中特效
function SelectItemRender:CreateSelectEffect()
end

--SelectNumWithConfirm-----购买确认
SelectNumWithConfirm = SelectNumWithConfirm or BaseClass(QuickBuy)
function SelectNumWithConfirm:SetConfirmCallback(callback)
	self.confirm_callback = callback
end

function SelectNumWithConfirm:OnClickBuy()
	if self.confirm_callback then
		self.confirm_callback(self.item_count)
	end
end 

function SelectNumWithConfirm:LoadCallBack()
	self:CreateItemCell()
	self:CreateKeyBoard()

	self.node_t_list.img_cost_type.node:setVisible(false)
	self.node_t_list.label_cost.node:setVisible(false)
	self.node_t_list.btn_OK.node:setTitleText(Language.Common.Confirm)
	XUI.AddClickEventListener(self.node_t_list.img9_buy_num_bg.node, BindTool.Bind1(self.OnOpenPopNum, self), false)
	XUI.AddClickEventListener(self.node_t_list.btn_minus.node, BindTool.Bind2(self.OnClickChangeNum, self, -1))
	XUI.AddClickEventListener(self.node_t_list.btn_plus.node, BindTool.Bind2(self.OnClickChangeNum, self, 1))
	XUI.AddClickEventListener(self.node_t_list.btn_OK.node, BindTool.Bind1(self.OnClickBuy, self))
	XUI.AddClickEventListener(self.node_t_list.btn_cancel.node, BindTool.Bind1(self.OnClickCancel, self))
	XUI.AddClickEventListener(self.node_t_list.btn_max.node, BindTool.Bind(self.OnClickMax, self))
end

--创建物品格子
function SelectNumWithConfirm:CreateItemCell()
	if self.item_cell then return end

	local item_cell = BaseCell.New()
	item_cell:SetPosition(self.ph_list.ph_cell.x + 85, self.ph_list.ph_cell.y)
	item_cell:SetCellBg(ResPath.GetCommon("cell_100"))
	item_cell:GetCell():setAnchorPoint(0.5, 0.5)
	item_cell:SetIsShowTips(true)
	self.node_t_list.layout_quick_buy.node:addChild(item_cell:GetCell(), 200, 200)
	self.item_cell = item_cell
end

function SelectNumWithConfirm:OnFlush(param_t, index)
	if param_t.param then
		self.item_id = tonumber(param_t.param[1])
		self.item_index = tonumber(param_t.param[3])
		self.item_num = tonumber(param_t.param[4])
	end
	
	if nil == self.item_id then
		Log("You need an item_id !!")
		return
	end
	local item_config = ItemData.Instance:GetItemConfig(self.item_id)
	if nil == item_config then
		if self.on_cfg_listen == false then
			ItemData.Instance:NotifyItemConfigCallBack(self.item_config_bind)
			self.on_cfg_listen = true
		end
		return
	end

	self.node_t_list.img_cost_type.node:loadTexture(ShopData.GetMoneyTypeIcon(price_type))

	local item_data = {item_id = self.item_id}
	self.item_cell:SetData(item_data)

	self.node_t_list.lbl_item_name.node:setString(string.format("%s * %d",item_config.name,self.item_num))
	self.node_t_list.lbl_item_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))

	self:RefreshPurchaseView(self.item_count)
end

function SelectNumWithConfirm:GetMaxBuyNum()
	local have_num =  ItemData.Instance:GetItemNumInBagById(self.item_index)
	if have_num > 255 then
		have_num = 255
	end
	return have_num
end

function SelectNumWithConfirm:RefreshPurchaseView(item_count)
	self.node_t_list.lbl_num.node:setString(item_count)
	self.item_count = item_count
	if self.item_id == SettingData.DELIVERY_T[1] or self.item_id == SettingData.DELIVERY_T[2] then
		self.item_cell:SetRightBottomText(item_count * 50)
	end
end