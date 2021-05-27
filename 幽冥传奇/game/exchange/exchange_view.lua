ExchangeView = ExchangeView or BaseClass(BaseView)

ExchangeView.EditBoxInitNum = 0
function ExchangeView:__init()
	self:SetBackRenderTexture(true)
	
	self.title_img_path = ResPath.GetWord("word_exchange")
	self.texture_path_list[1] = 'res/xui/exchange.png'
	self.texture_path_list[2] = 'res/xui/consign.png'
	self.config_tab = {
		{"common_ui_cfg", 1, {0},},
		{"exchange_ui_cfg", 1, {0},},
		{"common_ui_cfg", 2, {0},},
	}
end

function ExchangeView:__delete()
end

function ExchangeView:ReleaseCallBack()
	if self.my_input_cell_list then
		self.my_input_cell_list:DeleteMe()
		self.my_input_cell_list = nil
	end

	if self.oppo_input_cell_list then
		self.oppo_input_cell_list:DeleteMe()
		self.oppo_input_cell_list = nil
	end

	if self.can_input_grid_bag then
		self.can_input_grid_bag:DeleteMe()
		self.can_input_grid_bag = nil
	end

	if self.cancel_confirm_dlg then
		self.cancel_confirm_dlg:DeleteMe()
		self.cancel_confirm_dlg = nil
	end

	if self.bag_radio then
		self.bag_radio:DeleteMe()
		self.bag_radio = nil
	end
end

function ExchangeView:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		self:CreateOppositeGrid()
		self:CreateMyInputGrid()
		self:CreateCanInputGrid()
		self:CreateIngotEdit()
		self.node_t_list.btn_exchange.node:setEnabled(false)
		-- XUI.AddClickEventListener(self.node_t_list.btn_cancel_exchange.node, BindTool.Bind(self.OnCancelExchangeClicked,self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_lock.node, BindTool.Bind(self.OnLockClicked, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_exchange.node, BindTool.Bind(self.OnExchangeClicked, self), true)

		EventProxy.New(ExchangeData.Instance, self):AddEventListener(ExchangeData.EXCHANGE_BEGIN, BindTool.Bind(self.OnFlushBegin, self))
		EventProxy.New(ExchangeData.Instance, self):AddEventListener(ExchangeData.EXCHANGE_MY_INFO, BindTool.Bind(self.OnFlushMyInfo, self))
		EventProxy.New(ExchangeData.Instance, self):AddEventListener(ExchangeData.EXCHANGE_OPPOSITE_INFO, BindTool.Bind(self.OnFlushOppositeInfo, self))
		EventProxy.New(ExchangeData.Instance, self):AddEventListener(ExchangeData.EXCHANGE_MY_MONEY, BindTool.Bind(self.OnFlushMyMoney, self))
		EventProxy.New(ExchangeData.Instance, self):AddEventListener(ExchangeData.EXCHANGE_OPPO_MONEY, BindTool.Bind(self.OnFlushOppoMoney, self))
		EventProxy.New(ExchangeData.Instance, self):AddEventListener(ExchangeData.EXCHANGE_OWN_LOCKED, BindTool.Bind(self.OnFlushOwnLocked, self))
		EventProxy.New(ExchangeData.Instance, self):AddEventListener(ExchangeData.EXCHANGE_OTHER_LOCKED, BindTool.Bind(self.OnFlushOtherLocked, self))
		EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleDataChange, self)) --监听金钱数据变化
	end
end

function ExchangeView:OpenCallBack()
	RoleData.Instance:NotifyAttrChange(self.moneydata_change_callback)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ExchangeView:ShowIndexCallBack(index)
	self:OnFlushBegin()
	self.node_t_list.btn_exchange.node:setEnabled(true)
	self.node_t_list.btn_lock.node:setEnabled(true)
end

function ExchangeView:CloseCallBack(is_all)
	self.node_t_list.btn_exchange.node:setEnabled(true)
	self.node_t_list.btn_lock.node:setEnabled(true)
	for k, v in pairs(self.my_input_cell_list:GetAllCell()) do
		v:MakeGray(false)
	end
	for k, v in pairs(self.can_input_grid_bag:GetAllCell()) do
		v:MakeGray(false)
	end
	RoleData.Instance:UnNotifyAttrChange(self.moneydata_change_callback)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ExchangeView:OnFlush(param_t, index)

end

function ExchangeView:OnFlushBegin()
	self:FlushCanInputBagData()
	self:FlushMyInputInfoData()
	self:FlushOppoInputInfoData()
	self:FlushMoney()
	local num = ExchangeData.Instance:GetOppositeExchangeMoney()
	self.node_t_list.lbl_other_zuan.node:setString(num)
	local level =RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)	
	local playername = Scene.Instance:GetMainRole():GetName()
	-- self.node_t_list.txt_my_info.node:setString(string.format(Language.Exchange.TitleInfo, playername, level))
	local trader_name = ExchangeData.Instance:GetTraderName()
	local trader_level = ExchangeData.Instance:GetTraderLevel()
	if trader_name == nil or trader_level == nil then
		return
	end
	self.node_t_list.txt_opposide_info.node:setString(string.format(Language.Exchange.TitleInfo, trader_name, trader_level))
end

function ExchangeView:OnFlushMyInfo()
	self:FlushMyInputInfoData()
	self.can_input_grid_bag:GetCurCell():MakeGray(true)
end

function ExchangeView:OnFlushOppositeInfo()
	self:FlushOppoInputInfoData()
end

function ExchangeView:OnFlushMyMoney()
	local num = ExchangeData.Instance:GetMyExchangeMoney()
	self.edit_yuanbao:setText(num)
end

function ExchangeView:OnFlushOppoMoney()
	local num = ExchangeData.Instance:GetOppositeExchangeMoney()
	self.node_t_list.lbl_other_zuan.node:setString(num)
end

function ExchangeView:OnFlushOwnLocked()
	self.node_t_list.btn_exchange.node:setEnabled(true)
	self.node_t_list.btn_lock.node:setEnabled(false)
	for k, v in pairs(self.my_input_cell_list:GetAllCell()) do
		v:MakeGray(true)
	end
end

function ExchangeView:OnFlushOtherLocked()
	for k, v in pairs(self.oppo_input_cell_list:GetAllCell()) do
		v:MakeGray(true)
	end
end


function ExchangeView:OnLockClicked()
	ExchangeCtrl.ExchangeLockReq()
end

function ExchangeView:OnExchangeClicked()
	ExchangeCtrl.ConfirmExchangeReq()
	if ExchangeData.Instance:OppositeLocking() then
		self.node_t_list.btn_exchange.node:setEnabled(false)
	end
end

function ExchangeView:OnCloseHandler()
	if nil == self.cancel_confirm_dlg then
		self.cancel_confirm_dlg = Alert.New()
		self.cancel_confirm_dlg:SetOkFunc(BindTool.Bind(self.CancelExchange, self))
		self.cancel_confirm_dlg:SetLableString(Language.Exchange.ConfirmContent)
	end
	self.cancel_confirm_dlg:Open()
end

function ExchangeView:CancelExchange()
	ExchangeCtrl.CancelExchangReq(0)
end

function ExchangeView:CreateOppositeGrid()
	if self.oppo_input_cell_list == nil then
		self.oppo_input_cell_list = BaseGrid.New()
		local ph = self.ph_list.ph_other_item_list
		local grid_node = self.oppo_input_cell_list:CreateCells({w = ph.w, h = ph.h, cell_count = 20, col = 3, row = 5})
		grid_node:setPosition(ph.x, ph.y)
		grid_node:setAnchorPoint(0, 0)
		self.node_t_list.layout_exchange_item.node:addChild(grid_node, 999)
	end
end

function ExchangeView:FlushOppoInputInfoData()
	local item_list = ExchangeData.Instance:GetOppoItemsList()
	self.oppo_input_cell_list:SetDataList(item_list)
end

function ExchangeView:CreateMyInputGrid()
	if self.my_input_cell_list == nil then
		self.my_input_cell_list = BaseGrid.New() 
		local ph = self.ph_list.ph_my_item_list
		local grid_node = self.my_input_cell_list:CreateCells({w = ph.w, h = ph.h, cell_count = 20, col = 3, row = 5})
		grid_node:setPosition(ph.x, ph.y)
		grid_node:setAnchorPoint(0, 0)
		self.node_t_list.layout_exchange_item.node:addChild(grid_node, 999)
	end
end

function ExchangeView:FlushMyInputInfoData()
	local item_list = ExchangeData.Instance:GetMyInputItemsList()
	self.my_input_cell_list:SetDataList(item_list)
end

function ExchangeView:CreateCanInputGrid()
	if self.can_input_grid_bag == nil then
		self.can_input_grid_bag = BaseGrid.New() 
		local ph_grid = self.ph_list.ph_bg_list
		local grid_node = self.can_input_grid_bag:CreateCells({w = ph_grid.w, h = ph_grid.h, cell_count = 80, col = 4, row = 5})
		grid_node:setPosition(ph_grid.x, ph_grid.y)
		grid_node:setAnchorPoint(0, 0)
		self.node_t_list.layout_exchange_item.node:addChild(grid_node, 999)
		self.bag_index = self.can_input_grid_bag:GetCurPageIndex()
		self.can_input_grid_bag:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
		self.can_input_grid_bag:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))
		--self.bag_radio = RadioButton.New()
		--self.bag_radio:SetRadioButton(self.node_t_list.layout_can_input_bag_radio)
		--self.bag_radio:SetSelectCallback(BindTool.Bind1(self.BagRadioHandler, self))
		--self.can_input_grid_bag:SetRadioBtn(self.bag_radio)
	end
end

function ExchangeView:FlushCanInputBagData()
	local bag_list = ExchangeData.GetCanExchangeItemsData()
	local page_cell_count = self.can_input_grid_bag:GetPageCellCount()
	--local add_num = math.ceil((#bag_list + 1 - 80) / page_cell_count)
	--if add_num > 0 then
	--	self.can_input_grid_bag:ExtendGrid(80 + add_num * page_cell_count)
	--	local radio_num = self.bag_radio:GetCount()
	--	for i = 1, add_num do
	--		local btn = TabbarBtn.New(ResPath.GetCommon("toggle_101_normal"), ResPath.GetCommon("toggle_101_select"))
	--		local last_btn = self.bag_radio:GetToggle(radio_num)
	--		local x, y = last_btn:getPosition()
	--		self.node_t_list.layout_can_input_bag_radio.node:addChild(btn:GetView())
	--		btn:setAnchorPoint(0.5, 0.5)
	--		btn:setPosition(x + 30 * i, y)
	--		self.bag_radio:AddToggle(btn)
	--	end
	--	local x, y = self.node_t_list.layout_can_input_bag_radio.node:getPosition()
	--	local scale = 1
	--	if (add_num + radio_num) > 10 then
	--		scale = 10 / (add_num + radio_num)
	--		self.node_t_list.layout_can_input_bag_radio.node:setScale(scale)
	--	end
	--	self.node_t_list.layout_can_input_bag_radio.node:setPosition(x - 15 * add_num * scale, y)
	--end
	self.can_input_grid_bag:SetDataList(bag_list)
end

function ExchangeView:OnPageChangeCallBack(grid, page_index, prve_page_index)
	
end

function ExchangeView:SelectCellCallBack(cell)
	if nil == cell or nil == cell:GetData() then return end
	TipCtrl.Instance:OpenItem(cell:GetData(), EquipTip.FROM_EXCHANGE_BAG)
end

function ExchangeView:BagRadioHandler(index)
	if nil ~= self.can_input_grid_bag then
		self.can_input_grid_bag:ChangeToPage(index)
	end
end

--输入框
function ExchangeView:CreateIngotEdit()
	--设置交易元宝输入框
	self.edit_yuanbao = self.node_t_list.edit_yuanbao.node
	self.edit_yuanbao:setFontSize(20)
	self.edit_yuanbao:setFontColor(COLOR3B.OLIVE)
	self.edit_yuanbao:setText(Language.Exchange.EdidDesc)
	self.edit_yuanbao:registerScriptEditBoxHandler(BindTool.Bind(self.ExamineEditYuanbaoNum, self, self.edit_yuanbao, 9))
end

function ExchangeView:ExamineEditYuanbaoNum(edit, num, e_type)
	if e_type == "return" then
		local text = edit:getText() 
		text = string.gsub(text, "[^0-9]", "")			-- 非数字
		if tonumber(text) > RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RED_DIAMONDS) then
			text = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RED_DIAMONDS)
		end
		edit:setText((text ~= "" and tonumber(text) and tonumber(text) > 0) and text or Language.Exchange.EdidDesc)
		if text ~= "" then
			ExchangeCtrl.ChangeExchangeMoneyReq(tonumber(text), MoneyType.RedDiamond)
		end
		local text_num = AdapterToLua:utf8FontCount(text)
		if text_num > num then
			text = AdapterToLua:utf8TruncateByFontCount(text, num)
			edit:setText(text)
			-- SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Consign.ContentToLong, num))
		end
		self:OnFlushBegin()
	end
end

----元宝变化
function ExchangeView:OnRoleDataChange(vo)
	if vo.key == OBJ_ATTR.ACTOR_GOLD then
		self:FlushMoney()
	end
end
--
function ExchangeView:FlushMoney()
	local red_zuan = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RED_DIAMONDS)
	self.node_t_list.lbl_my_zuan.node:setString(red_zuan)
end