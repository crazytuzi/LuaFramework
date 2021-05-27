ConsignBuyItemPage = ConsignBuyItemPage or BaseClass()

function ConsignBuyItemPage:__init()
	self.view = nil
end

function ConsignBuyItemPage:__delete()
	self:RemoveEvent()
	if self.buy_item_list then
		self.buy_item_list:DeleteMe()
		self.buy_item_list = nil
	end

	if nil ~= self.choice_list then
		self.choice_list:DeleteMe()
		self.choice_list = nil
	end

	if nil ~= self.layout_touch then
		self.layout_touch = nil
	end

	if self.has_consign_buy_item_view_create then
		self.has_consign_buy_item_view_create = nil
	end

	self.view = nil
end

function ConsignBuyItemPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.ph_list = self.view.ph_list
	self.node_t_list = self.view.node_t_list
	self.root_node = self.view.root_node
	self.layout_choice_list = self.node_t_list.layout_choice_list.node
	self.layout_choice_list:setAnchorPoint(0, 0)
	if not self.has_consign_buy_item_view_create then
		ConsignData.Instance:InitChoiceData()
		-- ConsignCtrl.Instance:SendSearchConsignItemsReq()
		self.has_consign_buy_item_view_create = true
	end
	self.node_t_list.btn_species.node:addClickEventListener(BindTool.Bind1(self.OnClickAllTypeHandler, self))
	self.node_t_list.img9_type_bg.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_t_list.img9_type_bg.node, BindTool.Bind(self.OnClickAllTypeHandler, self), false)

	self.node_t_list.btn_level.node:addClickEventListener(BindTool.Bind1(self.OnClickAllLevelHandler, self))
	self.node_t_list.img9_level_bg.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_t_list.img9_level_bg.node, BindTool.Bind(self.OnClickAllLevelHandler, self), false)

	self.node_t_list.btn_profession.node:addClickEventListener(BindTool.Bind1(self.OnClickAllProfessionHandler, self))
	self.node_t_list.img9_profession_bg.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_t_list.img9_profession_bg.node, BindTool.Bind(self.OnClickAllProfessionHandler, self), false)

	self.node_t_list.btn_research.node:addClickEventListener(BindTool.Bind1(self.OnClickResearchHandler, self))
	self:CreateChoiceList()
	self:InitEvent()
end

function ConsignBuyItemPage:InitEvent()
	-- 设置定时刷新
	self.flush_timer_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.OnFlushBuyItem, self),20)
end

function ConsignBuyItemPage:RemoveEvent()
	if nil ~= self.flush_timer_quest then
		GlobalTimerQuest:CancelQuest(self.flush_timer_quest)
		self.flush_timer_quest = nil
	end
end

--更新视图界面
function ConsignBuyItemPage:UpdateData(data)
	ConsignCtrl.Instance:SendSearchConsignItemsReq()
	for k, v in pairs(data) do
		if k == "all" then
			-- self:OnFlushBuyItem()
		end
	end
end

function ConsignBuyItemPage:OnClickAllTypeHandler()
	if nil == self.choice_list then return end
	self:SetChoiceLayoutPos(self.node_t_list.img9_type_bg.node)
	self:OnFlushChoiceList("type")
	self.layout_choice_list:setVisible(true)
end

function ConsignBuyItemPage:OnClickAllLevelHandler()
	if nil == self.choice_list then return end
	self:SetChoiceLayoutPos(self.node_t_list.img9_level_bg.node)
	self:OnFlushChoiceList("level")
	self.layout_choice_list:setVisible(true)
end

function ConsignBuyItemPage:OnClickAllProfessionHandler()
	if nil == self.choice_list then return end
	self:SetChoiceLayoutPos(self.node_t_list.img9_profession_bg.node)
	self:OnFlushChoiceList("profession")
	self.layout_choice_list:setVisible(true)
end


function ConsignBuyItemPage:OnClickResearchHandler()
	if nil == self.buy_item_list then return end
	self:OnFlushBuyItem()
end

function ConsignBuyItemPage:OnFlushBuyItem()
	self:UpdateList()
	self:OnFlushChoice()
end

function ConsignBuyItemPage:UpdateList()
	if self.buy_item_list == nil then
		local ph = self.ph_list.ph_consign_list
		self.buy_item_list = ListView.New()
		self.buy_item_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BuyItemRender, nil, nil, self.ph_list.ph_list_consign_item)
		self.buy_item_list:GetView():setAnchorPoint(0, 0)
		self.buy_item_list:SetItemsInterval(2)
		self.buy_item_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_buy_item.node:addChild(self.buy_item_list:GetView(), 100)
	end	

	local data = ConsignData.Instance:GetSearchChoiceItemDataList()
	if nil == data or nil == data then return end
	self.buy_item_list:SetDataList(data)
end


-------------------------------------
-- 选择列表
function ConsignBuyItemPage:CreateChoiceList()
	if nil == self.choice_list then
		local ph = self.ph_list.ph_choice_list
		self.choice_list = ListView.New()
		self.choice_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ChoiceRender, nil, nil, self.ph_list.ph_choice_cell)
		self.choice_list:GetView():setAnchorPoint(0, 0)
		self.choice_list:SetItemsInterval(3)
		self.choice_list:SetMargin(2)
		self.choice_list:SetJumpDirection(ListView.Top)
		-- self.choice_list:JumpToTop(true)
		self.layout_choice_list:addChild(self.choice_list:GetView(), 100)

		self.choice_list_sav = {}
		local bg = self.node_t_list.layout_choice_list.img9_choice_list_bg.node
		self.choice_list_sav.bg_size = bg:getContentSize()
		self.choice_list_sav.bg_pos = cc.p(bg:getPositionX(), bg:getPositionY())
		self.choice_list_sav.ph_list = ph

		self.choice_list:SetSelectCallBack(BindTool.Bind(self.OnSelectChoiceItemHandler, self))
	end
end

function ConsignBuyItemPage:UpdateLayoutTouch()
	if nil == self.layout_touch then
		local layout_touch = XLayout:create(HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight())
		self.layout_choice_list:addChild(layout_touch)
		XUI.AddClickEventListener(layout_touch, function()
			self.layout_choice_list:setVisible(false)
		end)

		self.layout_touch = layout_touch
	end

	local pos = self.layout_choice_list:convertToNodeSpace(cc.p(0, 0))
	self.layout_touch:setPosition(pos.x, pos.y)
end

function ConsignBuyItemPage:OnSelectChoiceItemHandler(item, index)
	if nil == self.choice_list then return end
	local item_data = item:GetData()

	ConsignData.Instance:SetNowChoiceData(self.choice_list.choice_tag or "type", index)
	-- self:Flush()
	self:OnFlushChoice()

	self.layout_choice_list:setVisible(false)
end

function ConsignBuyItemPage:OnFlushChoiceList(tag)
	if nil == self.choice_list then return end
	local data_list = ConsignData.Instance:GetSearchChoiceData(tag)
	self.choice_list:SetDataList(data_list)
	self.choice_list.choice_tag = tag

	self:SetChoiceListSize(tag)

	GlobalTimerQuest:AddDelayTimer(function()
		self.choice_list:ChangeToIndex(ConsignData.Instance:GetNowChoiceIndex(tag))
	end, 0)

	self:UpdateLayoutTouch()
end

function ConsignBuyItemPage:SetChoiceListSize(tag)
	local bg = self.node_t_list.layout_choice_list.img9_choice_list_bg.node
	if tag == "profession" then
		local height = 230
		local shift = (self.choice_list_sav.bg_size.height - height) / 2
		bg:setContentSize(cc.size(self.choice_list_sav.bg_size.width, height))
		bg:setPositionY(self.choice_list_sav.bg_pos.y - shift)
		self.choice_list:GetView():setContentWH(self.choice_list_sav.ph_list.w, self.choice_list_sav.ph_list.h - shift * 2 + 3)
	else
		bg:setContentSize(cc.size(self.choice_list_sav.bg_size.width, self.choice_list_sav.bg_size.height))
		bg:setPositionY(self.choice_list_sav.bg_pos.y)
		self.choice_list:GetView():setContentWH(self.choice_list_sav.ph_list.w, self.choice_list_sav.ph_list.h)
	end
end

function ConsignBuyItemPage:OnFlushChoice()
	self.node_t_list.txt_type.node:setString(ConsignData.Instance:GetNowChoiceData("type").name)
	self.node_t_list.txt_level.node:setString(ConsignData.Instance:GetNowChoiceData("level").name)
	self.node_t_list.txt_profession.node:setString(ConsignData.Instance:GetNowChoiceData("profession").name)
end

function ConsignBuyItemPage:SetChoiceLayoutPos(bg_node)
	local size = bg_node:getContentSize()
	local x, y = bg_node:getPosition()

	local pos = self.node_t_list.layout_buy_item.node:convertToWorldSpace(cc.p(x - size.width / 2, y + size.height * 2 / 3))
	pos = self.root_node:convertToNodeSpace(pos)
	self.layout_choice_list:setPosition(pos.x, pos.y)
end


-------------------------------------
-- BuyItemRender
-------------------------------------
BuyItemRender = BuyItemRender or BaseClass(BaseRender)
function BuyItemRender:__init()
end

function BuyItemRender:__delete()	
	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end

	if nil ~= self.itemconfig_callback then
		ItemData.Instance:UnNotifyItemConfigCallBack(self.itemconfig_callback)
		self.itemconfig_callback = nil
	end
	if nil ~= self.alert_view then
		self.alert_view:DeleteMe()
		self.alert_view = nil 
	end
end

function BuyItemRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_item_cell
	if nil == self.cell then
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x + ph.w / 2, ph.y + ph.h / 2)
		self.cell:SetIndex(i)
		self.cell:SetAnchorPoint(0.5, 0.5)
		self.view:addChild(self.cell:GetView(), 103)

		--self.cell:SetItemTipFrom(EquipTip.FROM_CONSIGN_ON_BUY)
		self.cell:SetName(GRID_TYPE_BAG)
	end	
	if nil == self.alert_view then
		self.alert_view = Alert.New()
	end
	self.alert_view:SetOkFunc(BindTool.Bind2(self.SendBuyItem, self))
	self.alert_view:SetCancelFunc(BindTool.Bind2(self.CloseWindow, self))
	XUI.AddClickEventListener(self.node_tree.img_consign_bg.node, BindTool.Bind1(self.Opentips, self), true)
end

function BuyItemRender:OnFlush()
	if nil == self.data or nil == self.data.item_data or nil == self.cell then return end
	self.data.item_data.seller_name = self.data.seller_name
	
	self.cell:SetData(self.data.item_data)

	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_data.item_id)
	if nil == item_cfg then
		if nil == self.itemconfig_callback then
			self.itemconfig_callback = BindTool.Bind(self.OnFlush, self)
			ItemData.Instance:NotifyItemConfigCallBack(self.itemconfig_callback)
		end
		return
	end
	if nil ~= self.itemconfig_callback then
		ItemData.Instance:UnNotifyItemConfigCallBack(self.itemconfig_callback)
		self.itemconfig_callback = nil
	end

	local str = EquipTip.GetEquipName(item_cfg, self.data.item_data, EquipTip.FROM_CONSIGN_ON_BUY)
	RichTextUtil.ParseRichText(self.node_tree.rich_txt_item_name.node, str, 20, Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6)))

	local lbl_level = self.node_tree.txt_item_level.node
	local level = 0
	local zhuan = 0
	for k,v in pairs(item_cfg.conds) do
		if v.cond == ItemData.UseCondition.ucLevel then
			level = v.value
			if not RoleData.Instance:IsEnoughLevelZhuan(v.value) then
				lbl_level:setColor(COLOR3B.RED)
			end
		end
		if v.cond == ItemData.UseCondition.ucMinCircle then
			zhuan = v.value
			if v.value > RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) then
				lbl_level:setColor(COLOR3B.RED)
			end
		end
	end
	if zhuan > 0 then
		lbl_level:setString(string.format(Language.Consign.ItemLevelZhuan, zhuan, level))
	else
		lbl_level:setString(level)
	end

	self.node_tree.txt_price.node:setString(self.data.item_price)
	self.node_tree.txt_consignment.node:setString(self.data.seller_name)

	self:SetTimerCountDown()
end

-- 设置倒计时
function BuyItemRender:SetTimerCountDown()
	if nil == self.data then return end
	if self.data.remain_time <= TimeCtrl.Instance:GetServerTime() then
		self.node_tree.txt_remain_time.node:setString(Language.Consign.TimeOut)
		return
	end
	local time_tab = TimeUtil.Format2TableDHM(self.data.remain_time - TimeCtrl.Instance:GetServerTime())
	self.node_tree.txt_remain_time.node:setString(string.format(Language.Consign.TimeTips, time_tab.day, time_tab.hour, time_tab.min))
end

function BuyItemRender:GetCountDownKey()
	if nil == self.data then return end
	local key = "buy_item_render_" .. self.data.item_handle
	return key
end

function BuyItemRender:CreateSelectEffect()
	-- local cell_bg = self.node_tree.img9_buy_render_bg.node
	-- local x, y = cell_bg:getPosition()
	-- local size = cell_bg:getContentSize()
	-- self.select_effect = XUI.CreateImageViewScale9(x, y, size.width, size.height, 
	-- 	ResPath.GetCommon("img9_120"), true)
	-- if nil ~= self.select_effect then
	-- 	self.view:addChild(self.select_effect, 1)
	-- end
end

function BuyItemRender:Opentips()
	self.alert_view:SetShowCheckBox(true)
	self.alert_view:Open()
	local price = self.data.item_price
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_data.item_id)
	if item_cfg == nil then return end
	local name = item_cfg.name
	local color = string.format("%06x", item_cfg.color)
	local txt = string.format(Language.Consign.Desc, price, color, name, self.data.item_data.num)
	self.alert_view:SetLableString(txt)
	-- PrintTable(self.data)
end


function BuyItemRender:SendBuyItem()
	ConsignCtrl.Instance:SendBuyConsignItem(self.data.item_data)
end

function BuyItemRender:CloseWindow()
	self.alert_view:Close()
end

-------------------------------------
-- ChoiceRender
-------------------------------------
ChoiceRender = ChoiceRender or BaseClass(BaseRender)
function ChoiceRender:__init()
end

function ChoiceRender:__delete()
end

function ChoiceRender:CreateChild()
	BaseRender.CreateChild(self)
	self.lbl_choice_name = self.node_tree.lbl_choice_name.node
end

function ChoiceRender:OnFlush()
	if self.data == nil then return end

	self.lbl_choice_name:setString(self.data.name)
end

function ChoiceRender:CreateSelectEffect()
	
end