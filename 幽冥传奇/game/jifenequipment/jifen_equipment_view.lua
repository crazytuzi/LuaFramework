JiFenEquipmentView = JiFenEquipmentView or BaseClass(XuiBaseView)

function JiFenEquipmentView:__init()
	self.texture_path_list[1] = 'res/xui/jifenequipment.png'
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"jifen_equipment_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}
	self.def_index = 1
	self.tabbar = nil
	
	self.jifen_data = {}
	self.sign_num = 0
	self.title_img_path = ResPath.GetJiFenEquipment("jifen_titile")
end

function JiFenEquipmentView:__delete()
end

function JiFenEquipmentView:ReleaseCallBack()
	if nil ~= self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	if self.exchange_item_list then
		self.exchange_item_list:DeleteMe()
		self.exchange_item_list = nil
	end
	if self.world_change_list then
		self.world_change_list:DeleteMe()
		self.world_change_list = nil
	end	
	if self.itemconfig_change_callback  then
		ItemData.Instance:UnNotifyItemConfigCallBack(self.itemconfig_change_callback)
		self.itemconfig_change_callback = nil 
	end
	if self.itemdata_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
		self.itemdata_change_callback = nil
	end
	if self.time_event then
		GlobalEventSystem:UnBind(self.time_event)
		self.time_event = nil
	end
	
	ViewManager.Instance:UnRegsiterTabFunUi(ViewName.JiFenEquipment)
end

function JiFenEquipmentView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		JiFenEquipmentCtrl.Instance:SendGetFullScaleAnnouncementInfReq()
		self:InitBar()
		self:UpdateItemList()
		self:UpdateWorldChange()
		ViewManager.Instance:RegsiterTabFunUi(ViewName.JiFenEquipment, self.tabbar)
		self.itemconfig_change_callback = BindTool.Bind1(self.ItemConfigChangeCallback, self)	  --监听Config
		self.itemdata_change_callback = BindTool.Bind1(self.ItemDataChangeCallback, self)           -- 监听物品数据变化、
		ItemData.Instance:NotifyItemConfigCallBack(self.itemconfig_change_callback)
		ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
		self.time_event = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind1(self.FlushDataList, self))
	end
end

function JiFenEquipmentView:FlushDataList()
	self:FlushList()
end

function JiFenEquipmentView:InitBar()
	if nil == self.tabbar then
		self.exchange_layout = self.node_t_list.layout_exchange
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithNameList(self.exchange_layout.node, 15, 568,
			function(index) self:ChangeToIndex(index) end, 
			Language.JiFenEquipment.TabGroup, false, ResPath.GetCommon("toggle_105"),nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
		self.tabbar:ChangeToIndex(self:GetShowIndex())
		self.tabbar:SetSpaceInterval(15)
	end	
	RichTextUtil.ParseRichText(self.node_t_list.rich_txt_explain.node, Language.JiFenEquipment.JiFenExplain, 18, COLOR3B.G_W2)
end

function JiFenEquipmentView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	
end

function JiFenEquipmentView:ShowIndexCallBack(index)
	self:Flush(index)
end

function JiFenEquipmentView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.tabbar:SelectIndex(1)
end
	
function JiFenEquipmentView:ItemDataChangeCallback()
	self:Flush()
end

function JiFenEquipmentView:ItemConfigChangeCallback()
	self:Flush()
end

function JiFenEquipmentView:OnFlush(param_t, index)
	local tab = ExploreData.Instance:GetXunBaoData()
	local xunbao_jifen = tab.current_treasure_jifen
	self.node_t_list.txt_count.node:setString(xunbao_jifen)
	self:FlushList()
end

function JiFenEquipmentView:UpdateItemList()
	if nil == self.exchange_item_list then
		local ph = self.ph_list.ph_item_list
		self.exchange_item_list = ListView.New()
		self.exchange_item_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ExchangeItemRender, nil, nil, self.ph_list.ph_list_item)
		self.exchange_item_list:GetView():setAnchorPoint(0, 0)
		self.exchange_item_list:SetItemsInterval(5)
		self.exchange_item_list:SetMargin(3)
		self.exchange_item_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_exchange.node:addChild(self.exchange_item_list:GetView(), 100)
	end
end

function JiFenEquipmentView:FlushList()
	local current_index = self:GetShowIndex()
	local jifen_data = JiFenEquipmentData.Instance:GetDataJifenData()
	self.exchange_item_list:SetDataList(jifen_data[current_index])
	local change_state = JiFenEquipmentData.Instance:GetInfo()
	self.world_change_list:SetDataList(change_state)
end

function JiFenEquipmentView:UpdateWorldChange()
	if nil == self.world_change_list then
		local ph = self.ph_list.ph_world_change_list
		self.world_change_list = ListView.New()
		self.world_change_list:Create(ph.x, ph.y, ph.w, ph.h, nil, WorldChangeRender, nil, nil, self.ph_list.ph_wordchange_item)
		self.world_change_list:GetView():setAnchorPoint(0, 0)
		self.world_change_list:SetJumpDirection(ListView.Top)
		self.world_change_list:SetItemsInterval(15)
		self.node_t_list.layout_exchange.node:addChild(self.world_change_list:GetView(), 100)
	end		
end

ExchangeItemRender = ExchangeItemRender or BaseClass(BaseRender)
function ExchangeItemRender:__init()
end

function ExchangeItemRender:__delete()	
	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end	
end

function ExchangeItemRender:CreateChild()
	BaseRender.CreateChild(self)
	if nil == self.cell then
		self.cell = BaseCell.New()
		self.cell:SetPosition(56,62)
		self.cell:SetIndex(i)
		self.cell:SetAnchorPoint(0.5, 0.5)
		self.view:addChild(self.cell:GetView(), 103)
	end	
	self.node_tree.btn_item_duihuan.node:addClickEventListener(BindTool.Bind1(self.OnClickExchangeHandler, self))
end

function ExchangeItemRender:OnClickExchangeHandler()
	JiFenEquipmentCtrl.Instance:SendIntegralExchangeBagReq(self.data.index, self.data.id)
end

function ExchangeItemRender:OnFlush()
	if self.data == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg  then
		return
	end 
	local tab = ExploreData.Instance:GetXunBaoData()
	local xunbao_jifen = tab.current_treasure_jifen
	self.node_tree.txt_name.node:setString(item_cfg.name)
	local data = {item_id = self.data.item_id, num = 1, is_bind = self.data.is_bind}
	self.cell:SetData(data)
	if self.data.index <= 5 then
		local item_consume_cfg = ItemData.Instance:GetItemConfig(self.data.consume_id) 
		if	nil == item_consume_cfg then
			return
		end	
		local n = ItemData.Instance:GetItemNumInBagById(self.data.consume_id,nil)
		local bool = JiFenEquipmentData.Instance:GetStrengthLevel(self.data.consume_id)
		if n >= 1 and bool == true and xunbao_jifen >= self.data.score then 
			XUI.SetButtonEnabled(self.node_tree.btn_item_duihuan.node, true)
		else 
			XUI.SetButtonEnabled(self.node_tree.btn_item_duihuan.node, false)
		end	
		self.node_tree.txt_desc.node:setString(item_consume_cfg.name.." ".."+".." "..self.data.score..Language.JiFenEquipment.Lang)
	elseif self.data.index == 6 then
		self.node_tree.txt_desc.node:setString(self.data.score..Language.JiFenEquipment.Lang)
		if xunbao_jifen >= self.data.score then
			XUI.SetButtonEnabled(self.node_tree.btn_item_duihuan.node, true)
		else
			XUI.SetButtonEnabled(self.node_tree.btn_item_duihuan.node, false)
		end 
	end	
end

WorldChangeRender = WorldChangeRender or BaseClass(BaseRender)
function WorldChangeRender:__init()
	
end

function WorldChangeRender:__delete()	
end

function WorldChangeRender:OnFlush()
	RichTextUtil.ParseRichText(self.node_tree.rich_explore_attr.node, self.data, 18)
end

function WorldChangeRender:CreateSelectEffect() 
end

