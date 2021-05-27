local ConsignBuyView = BaseClass(SubView)

function ConsignBuyView:__init()
	self.texture_path_list[1] = 'res/xui/consign.png'
	self.config_tab = {
		{"consign_ui_cfg", 2, {0}},
		{"consign_ui_cfg", 5, {0}, false},
	}
end

function ConsignBuyView:LoadCallBack()
	self.layout_choice_list = self.node_t_list.layout_choice_list.node
	self.layout_choice_list:setAnchorPoint(0, 0)
	
	self.node_t_list.btn_species.node:addClickEventListener(BindTool.Bind(self.OnClickAllTypeHandler, self))
	self.node_t_list.img9_type_bg.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_t_list.img9_type_bg.node, BindTool.Bind(self.OnClickAllTypeHandler, self), false)
	
	self.node_t_list.btn_level.node:addClickEventListener(BindTool.Bind(self.OnClickAllLevelHandler, self))
	-- self.node_t_list.img9_level_bg.node:setTouchEnabled(true)
	-- XUI.AddClickEventListener(self.node_t_list.img9_level_bg.node, BindTool.Bind(self.OnClickAllLevelHandler, self), false)
	self.node_t_list.btn_level.node:setVisible(false)
	-- self.node_t_list.img9_level_bg.node:setVisible(false)
	self.node_t_list.txt_level.node:setVisible(false)
	
	-- self.node_t_list.btn_profession.node:addClickEventListener(BindTool.Bind(self.OnClickAllProfessionHandler, self))
	-- self.node_t_list.img9_profession_bg.node:setTouchEnabled(true)
	-- XUI.AddClickEventListener(self.node_t_list.img9_profession_bg.node, BindTool.Bind(self.OnClickAllProfessionHandler, self), false)
	
	self.node_t_list.btn_research.node:addClickEventListener(BindTool.Bind(self.OnClickResearchHandler, self))
	
	EventProxy.New(ConsignData.Instance, self):AddEventListener(ConsignData.OTHER_CONSIGN_DATA, BindTool.Bind(self.OnMyConsignData, self))--事件监听
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	self:CreateChoiceList()
	-- -- 设置定时刷新
	-- self.flush_timer_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.Flush, self),20)
end

function ConsignBuyView:ReleaseCallBack()
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
	-- if nil ~= self.flush_timer_quest then
	-- 	GlobalTimerQuest:CancelQuest(self.flush_timer_quest)
	-- 	self.flush_timer_quest = nil
	-- end
end

function ConsignBuyView:ShowIndexCallBack()
	ConsignData.Instance:SetNowChoiceData("type", 1)
	ConsignData.Instance:SetNowChoiceData("level", 1)
	self:Flush()
end

function ConsignBuyView:OnClickAllTypeHandler()
	if nil == self.choice_list then return end
	self:SetChoiceLayoutPos(self.node_t_list.img9_type_bg.node)
	self.layout_choice_list:setVisible(true)
	self:OnFlushChoiceList("type")
end

function ConsignBuyView:OnClickAllLevelHandler()
	if nil == self.choice_list then return end
	self:SetChoiceLayoutPos(self.node_t_list.img9_level_bg.node)
	self.layout_choice_list:setVisible(true)
	self:OnFlushChoiceList("level")
end

function ConsignBuyView:OnClickAllProfessionHandler()
	if nil == self.choice_list then return end
	self:SetChoiceLayoutPos(self.node_t_list.img9_profession_bg.node)
	self.layout_choice_list:setVisible(true)
	self:OnFlushChoiceList("profession")
end

function ConsignBuyView:RoleDataChangeCallback(vo)
	local key = vo.key
	if key == OBJ_ATTR.ACTOR_RED_DIAMONDS
	or key == OBJ_ATTR.ACTOR_GOLD then
		self:Flush()
	end
end

function ConsignBuyView:OnClickResearchHandler()
	if nil == self.buy_item_list then return end
	self:Flush()
end

function ConsignBuyView:OnFlush(param_t)
	self:UpdateList()
	self:OnFlushChoice()
	local red_zuan = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RED_DIAMONDS)
	self.node_t_list.lbl_my_zuan.node:setString(red_zuan)
end

function ConsignBuyView:OnMyConsignData()
	self:Flush()
end

function ConsignBuyView:UpdateList()
	if self.buy_item_list == nil then
		local ph = self.ph_list.ph_consign_list
		self.buy_item_list = ListView.New()
		self.buy_item_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BuyItemRender, nil, nil, self.ph_list.ph_list_consign_item)
		self.buy_item_list:GetView():setAnchorPoint(0, 0)
		self.buy_item_list:SetItemsInterval(2)
		self.buy_item_list:SetMargin(2)
		self.buy_item_list:SetJumpDirection(ListView.Top)
		self.buy_item_list:AddListEventListener(BindTool.Bind(self.BuyListEventCallback, self))
		self.node_t_list.layout_buy_item.node:addChild(self.buy_item_list:GetView(), 100)
	end	
	
	local data = ConsignData.Instance:GetSearchChoiceItemDataList(math.max(self.buy_item_list:GetCount(), ConsignData.MinConsignGetNum))
	self.buy_item_list:SetDataList(data)
end

function ConsignBuyView:BuyListEventCallback(sender, event_type, index)
	if XuiListEventType.Began == event_type then
		
	elseif XuiListEventType.Ended == event_type or XuiListEventType.Canceled == event_type then
		local p = self.buy_item_list:GetView():getInnerPosition()
		if p.y == 0 then
			local data = ConsignData.Instance:GetSearchChoiceItemDataList(self.buy_item_list:GetCount() + ConsignData.MinConsignGetNum)
			if #data > self.buy_item_list:GetCount() then
				self.buy_item_list:SetDataList(data)
			end
		end
	elseif XuiListEventType.Refresh == event_type then
		
	end
end


-------------------------------------
-- 选择列表
function ConsignBuyView:CreateChoiceList()
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

function ConsignBuyView:UpdateLayoutTouch()
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

function ConsignBuyView:OnSelectChoiceItemHandler(item, index)
	if nil == self.choice_list then return end
	local item_data = item:GetData()
	
	ConsignData.Instance:SetNowChoiceData(self.choice_list.choice_tag or "type", index)
	-- self:Flush()
	self:OnFlushChoice()
	
	self.layout_choice_list:setVisible(false)
end

function ConsignBuyView:OnFlushChoiceList(tag)
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

function ConsignBuyView:SetChoiceListSize(tag)
	local bg = self.node_t_list.layout_choice_list.img9_choice_list_bg.node
	if tag == "profession" then
		local height = 230
		local shift =(self.choice_list_sav.bg_size.height - height) / 2
		bg:setContentSize(cc.size(self.choice_list_sav.bg_size.width, height))
		bg:setPositionY(self.choice_list_sav.bg_pos.y - shift)
		self.choice_list:GetView():setContentWH(self.choice_list_sav.ph_list.w, self.choice_list_sav.ph_list.h - shift * 2 + 3)
	else
		bg:setContentSize(cc.size(self.choice_list_sav.bg_size.width, self.choice_list_sav.bg_size.height))
		bg:setPositionY(self.choice_list_sav.bg_pos.y)
		self.choice_list:GetView():setContentWH(self.choice_list_sav.ph_list.w, self.choice_list_sav.ph_list.h)
	end
end

function ConsignBuyView:OnFlushChoice()
	self.node_t_list.txt_type.node:setString(ConsignData.Instance:GetNowChoiceData("type").name)
	self.node_t_list.txt_level.node:setString(ConsignData.Instance:GetNowChoiceData("level").name)
	-- self.node_t_list.txt_profession.node:setString(ConsignData.Instance:GetNowChoiceData("profession").name)
end

function ConsignBuyView:SetChoiceLayoutPos(bg_node)
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
	self:AddClickEventListener()
end

function BuyItemRender:__delete()	
	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function BuyItemRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_item_cell
	-- self.node_tree.txt_remain_time.node:setDimensions(cc.size(400, 30.85))
	-- self.node_tree.txt_remain_time.node:setAnchorPoint(cc.p(0.5, 0.5))
	-- self.node_tree.txt_remain_time.node:setPosition(834, 52)
	
	if nil == self.cell then
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x, ph.y)
		self.cell:SetIndex(i)
		self.cell:SetAnchorPoint(0.5, 0.5)
		self.view:addChild(self.cell:GetView(), 103)
		
		self.cell:SetItemTipFrom(EquipTip.FROM_CONSIGN_ON_BUY)
		self.cell:SetName(GRID_TYPE_BAG)
	end	

	XUI.AddClickEventListener(self.node_tree.btn_consign.node, BindTool.Bind(self.OnClickConsign, self), true)
end

function BuyItemRender:OnFlush()
	if nil == self.data or nil == self.data.item_data or nil == self.cell then return end
	self.data.item_data.seller_name = self.data.seller_name
	local role_name = GameVoManager.Instance:GetMainRoleVo().name
	local btn_text = Language.Consign.BtnTextGroup[2]
	if role_name == self.data.item_data.seller_name then 
		btn_text = Language.Consign.BtnTextGroup[1]
	end
	self.node_tree.btn_consign.node:setTitleText(btn_text)
	
	self.cell:SetData(self.data.item_data)
	
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_data.item_id)
	if nil == item_cfg then
		return
	end
	

	self.node_tree.txt_sell_role_name.node:setString(self.data.item_data.seller_name)

	local str = EquipTip.GetEquipName(item_cfg, self.data.item_data, EquipTip.FROM_CONSIGN_ON_BUY)
	RichTextUtil.ParseRichText(self.node_tree.rich_txt_item_name.node, str, 20, Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6)))
	
	-- local lbl_level = self.node_tree.txt_item_level.node
	-- local level = 0
	-- local zhuan = 0
	-- lbl_level:setColor(Str2C3b("9c9181"))
	-- for k, v in pairs(item_cfg.conds) do
	-- 	if v.cond == ItemData.UseCondition.ucLevel then
	-- 		level = v.value
	-- 		if not RoleData.Instance:IsEnoughLevelZhuan(v.value) then
	-- 			lbl_level:setColor(COLOR3B.RED)
	-- 		end
	-- 	end
	-- 	if v.cond == ItemData.UseCondition.ucMinCircle then
	-- 		zhuan = v.value
	-- 		if v.value > RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) then
	-- 			lbl_level:setColor(COLOR3B.RED)
	-- 		end
	-- 	end
	-- end
	-- if zhuan > 0 then
	-- 	lbl_level:setString(string.format(Language.Consign.ItemLevelZhuan, zhuan, level))
	-- else
	-- 	lbl_level:setString(level)
	-- end
	
	self.node_tree.txt_price.node:setString(self.data.item_price)
	-- self.node_tree.txt_consignment.node:setString(self.data.seller_name)
	self:SetTimerCountDown()

	
	-- self.node_tree.img_bg.node:setColor(self:GetIndex() % 2 == 0 and Str2C3b("1D1E1F") or Str2C3b("FFFFFF"))
end

-- 设置倒计时
function BuyItemRender:SetTimerCountDown()
	if nil == self.data then return end
	if self.data.remain_time <= Status.NowTime then
		self.node_tree.txt_remain_time.node:setString(Language.Consign.TimeOut)
		return
	end
	local time_tab = TimeUtil.Format2TableDHM(self.data.remain_time - Status.NowTime)
	self.node_tree.txt_remain_time.node:setString(string.format(Language.Consign.TimeTips, time_tab.day, time_tab.hour, time_tab.min))
end

function BuyItemRender:GetCountDownKey()
	if nil == self.data then return end
	local key = "buy_item_render_" .. self.data.item_handle
	return key
end

function BuyItemRender:CreateSelectEffect()
	if nil == self.node_tree.img9_buy_render_bg then return end
	local cell_bg = self.node_tree.img9_buy_render_bg.node
	local x, y = cell_bg:getPosition()
	local size = cell_bg:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(x, y, size.width, size.height,
	ResPath.GetCommon("img9_120"), true)
	if nil ~= self.select_effect then
		self.view:addChild(self.select_effect, 1)
	end
end

-- 点击回调
function BuyItemRender:OnClick()
	BaseRender.OnClick(self)
	if nil == self.data then return end
	TipCtrl.Instance:OpenItem(self.data.item_data, EquipTip.FROM_CONSIGN_ON_BUY)
end

function BuyItemRender:OnClickConsign()
	local text = self.node_tree.btn_consign.node:getTitleText()
	if text == Language.Consign.BtnTextGroup[1] then 
		if nil == self.data then return end
		local operation = 0
		if self.data.remain_time <= Status.NowTime then operation = 1 end
		ConsignCtrl.Instance:SendCancelConsignItemReq(self.data.item_data.series, self.data.item_handle, operation)
	else
		ConsignCtrl.Instance:SendBuyConsignItem({series = self.data.item_data.series, item_handle = self.data.item_handle})
	end
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

return ConsignBuyView 