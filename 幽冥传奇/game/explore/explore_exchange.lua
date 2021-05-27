-- 积分兑换

local ExploreExchangeView = BaseClass(SubView)

function ExploreExchangeView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)

	self.config_tab = {
		{"explore_ui_cfg", 4, {0}},
	}

	self.exchange_index = 1
end

function ExploreExchangeView:__delete()
end

function ExploreExchangeView:ReleaseCallBack()
	if self.exchange_item_list then
		self.exchange_item_list:DeleteMe()
		self.exchange_item_list = nil
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	self.exchange_index = 1
end

function ExploreExchangeView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateTabbar()
		self:CreateItemList()

		-- XUI.AddClickEventListener(self.node_t_list.btn_black1.node, BindTool.Bind1(self.OnClickBlack, self))
		EventProxy.New(ExploreData.Instance, self):AddEventListener(ExploreData.EXPLORE_SCORE_CHANGE, BindTool.Bind(self.FlushScoreData, self))
		EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.FlushScoreData, self))
	end

end

function ExploreExchangeView:OnClickBlack()
	ViewManager.Instance:OpenViewByDef(ViewDef.Explore.Xunbao)
end

function ExploreExchangeView:ShowIndexCallBack(index)
	self:Flush()
end

function ExploreExchangeView:FlushScoreData()
	self:Flush()
end
	
function ExploreExchangeView:OpenCallBack()
end

function ExploreExchangeView:CloseCallBack()
end

function ExploreExchangeView:CreateTabbar()
	if nil == self.tabbar then
		self.tabbar = ScrollTabbar.New()
		self.tabbar:SetSpaceInterval(6)
		self.tabbar:CreateWithNameList(self.node_t_list.scroll_tabbar.node, 8, -3,
			BindTool.Bind(self.SelectTabCallback, self), Language.JiFenEquipment.TabGroup, 
			true, ResPath.GetCommon("toggle_120"))
		self.tabbar:ChangeToIndex(self:GetShowIndex())
		self.tabbar:SetToggleVisible(3, false)
	end
end

function ExploreExchangeView:SelectTabCallback(index)
	self.exchange_index = index

	self:FlushList()
end

function ExploreExchangeView:FlushList()
	local current_index = self.exchange_index
	local data = ExploreData.Instance:GetExchangeList(current_index)
	self.exchange_item_list:SetDataList(data)

	for i = 1, #TreasureIntegral do
		self.tabbar:SetRemindByIndex(i, ExploreData.Instance:GetTabbarremind(i))
	end

	local data = ExploreData.Instance:GetXunBaoData()
	self.node_t_list.lbl_xb_score.node:setString(string.format(Language.JiFenEquipment.NowScore, data.bz_score))
end

function ExploreExchangeView:CreateItemList()

	if nil == self.exchange_item_list then
		local ph = self.ph_list.ph_exchange_list
		self.exchange_item_list = ListView.New()
		self.exchange_item_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ExchangeRender, nil, nil, self.ph_list.ph_exchange_item)
		-- self.exchange_item_list:GetView():setAnchorPoint(0, 0)
		-- self.exchange_item_list:SetItemsInterval(5)
		self.exchange_item_list:SetMargin(0)
		self.exchange_item_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_exchange.node:addChild(self.exchange_item_list:GetView(), 100)
	end
end

function ExploreExchangeView:OnFlush(param_t, index)
	self:FlushList()
end

-- 列表Item
ExchangeRender = ExchangeRender or BaseClass(BaseRender)
function ExchangeRender:__init()
	self.save_data = {}
end

function ExchangeRender:__delete()
	
end

function ExchangeRender:CreateChild()
	BaseRender.CreateChild(self)
	if nil == self.cell then
		self.cell = BaseCell.New()
		self.cell:SetPosition(self.ph_list.ph_item_cell.x, self.ph_list.ph_item_cell.y)
		self.cell:SetIndex(i)
		self.cell:SetAnchorPoint(0.5, 0.5)
		self.view:addChild(self.cell:GetView(), 103)
	end	

	XUI.AddClickEventListener(self.node_tree.btn_duihuan.node, BindTool.Bind1(self.OnClickExchange, self))
end

function ExchangeRender:OnClickExchange()
	-- if nil == self.data or self.data.find_count == 0 then 
	-- 	return 
	-- end
	ExploreCtrl.Instance:ExchageItemReq(self.data.index, self.data.id)
end

function ExchangeRender:OnFlush()
	if nil == self.data then return end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg  then
		return
	end 
	local tab = ExploreData.Instance:GetXunBaoData()
	local xunbao_jifen = tab.bz_score

	local txt = string.format(Language.JiFenEquipment.NameColor, string.format("%06x", item_cfg.color), item_cfg.name)
	RichTextUtil.ParseRichText(self.node_tree.rich_equip_name.node, txt, 18)
	local data = {item_id = self.data.item_id, num = 1, is_bind = self.data.is_bind}
	self.cell:SetData(data)
	if self.data.index ~= 5 then
		local item_consume_cfg = ItemData.Instance:GetItemConfig(self.data.consume[1].id) 
		if	nil == item_consume_cfg then
			return
		end	
		local n = BagData.Instance:GetItemNumInBagById(self.data.consume[1].id, nil)
		if n >= self.data.consume[1].count and xunbao_jifen >= self.data.score then 
			XUI.SetButtonEnabled(self.node_tree.btn_duihuan.node, true)
		else 
			XUI.SetButtonEnabled(self.node_tree.btn_duihuan.node, false)
		end	
		local cound = self.data.consume[1].count == 1 and "" or " × " .. self.data.consume[1].count
		local txt = "消耗：" .. string.format(Language.JiFenEquipment.NameColor, string.format("%06x", item_consume_cfg.color), item_consume_cfg.name) .. cound .. " + " .. self.data.score..Language.JiFenEquipment.Lang
		RichTextUtil.ParseRichText(self.node_tree.rich_equip_desc.node, txt, 18, COLOR3B.OLIVE)
	else
		local txt = self.data.score..Language.JiFenEquipment.Lang
		RichTextUtil.ParseRichText(self.node_tree.rich_equip_desc.node, txt, 18, COLOR3B.OLIVE)
		if xunbao_jifen >= self.data.score then
			XUI.SetButtonEnabled(self.node_tree.btn_duihuan.node, true)
		else
			XUI.SetButtonEnabled(self.node_tree.btn_duihuan.node, false)
		end 
	end	
end

function ExchangeRender:CreateSelectEffect()
end

return ExploreExchangeView