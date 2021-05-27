
ItemTipsView = ItemTipsView or BaseClass(XuiBaseView)
ItemTipsView.HEIGHT = 270
function ItemTipsView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.def_index = 0

	self.config_tab = {
		{"itemtip_ui_cfg", 2, {0}}
	}

	self.role_data_event = BindTool.Bind1(self.RoleDataChangeCallback, self)
end

function ItemTipsView:__delete()
end

function ItemTipsView:ReleaseCallBack()
	self.buttons = {}
	self.handle_param_t = {}
	self.data = nil

	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end

	if nil ~= self.pop_num_view then
		self.pop_num_view:DeleteMe()
		self.pop_num_view = nil
	end

	if RoleData.Instance then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_event)
	end

	if nil ~= self.use_alert then
		self.use_alert:DeleteMe()
		self.use_alert = nil
	end
end

function ItemTipsView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.lbl_item_name = self.node_t_list.itemname_txt.node
		self.lbl_type = self.node_t_list.top_txt1.node
		self.lbl_level = self.node_t_list.top_txt2.node
		self.itemtips_bg = self.node_t_list.img9_itemtips_bg.node
		self.layout_content_top = self.node_t_list.layout_content_top.node
		self.layout_content_top:setAnchorPoint(0.5, 0)
		self.layout_content_down = self.node_t_list.layout_content_down.node
		self.layout_content_down:setAnchorPoint(0.5, 0)
		self.layout_btns = self.node_t_list.layout_btns.node
		self.layout_btns:setAnchorPoint(0.5, 0)
		self.cell = BaseCell.New()
		self.layout_content_top:addChild(self.cell:GetCell(), 200)
		local ph_itemcell = self.ph_list.ph_itemcell --占位符
		self.cell:GetCell():setPosition(ph_itemcell.x, ph_itemcell.y)
		self.cell:SetIsShowTips(false)

		self.buttons = {self.node_t_list.btn_0.node, self.node_t_list.btn_1.node, 
		self.node_t_list.btn_2.node, self.node_t_list.btn_3.node}
		for k, v in pairs(self.buttons) do
			v:addClickEventListener(BindTool.Bind1(self.OperationClickHandler, self))
		end
		self.node_t_list.btn_close_window.node:setLocalZOrder(999)
		self.pop_num_view = NumKeypad.New()
		self.pop_num_view:SetOkCallBack(BindTool.Bind1(self.OnOKCallBack, self))
		self.node_t_list.rich_item_dec.node:setVerticalSpace(5)

		self.has_center_text = false
		self.center_text = XUI.CreateText(160, 150, 300, 26, cc.TEXT_ALIGNMENT_LEFT, nil, nil, nil, COLOR3B.GREEN, nil)
		self.layout_content_down:addChild(self.center_text)
		self.center_text:setVisible(false)

		self.time_height = 0
		self.node_t_list.layout_time_tip.node:setVisible(false)

		RoleData.Instance:NotifyAttrChange(self.role_data_event)
	end
end

function ItemTipsView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function ItemTipsView:OpenCallBack()
	AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(AudioEffect.OpenTip), AudioInterval.Common)
	self.item_use_suc_handler = GlobalEventSystem:Bind(KnapsackEventType.KNAPSACK_ITEM_USE, BindTool.Bind(self.OnItemUseSuc, self))
	self.item_del_handler = GlobalEventSystem:Bind(KnapsackEventType.KNAPSACK_ITEM_DELETE, BindTool.Bind(self.OnItemDelete, self))
end

function ItemTipsView:CloseCallBack()
	if self.fromView == EquipTip.FROM_WING_STONE then
		ViewManager.Instance:FlushView(ViewName.Wing, 0, "close_item_tip")
	end
	if self.item_use_suc_handler then
		GlobalEventSystem:UnBind(self.item_use_suc_handler)
	end
	if self.item_del_handler then
		GlobalEventSystem:UnBind(self.item_del_handler)
	end
	self.in_quick_using = false
end

function ItemTipsView:SetData(data, fromView, param_t)
	if not data then
		return
	end
	self.data = data
	self:Open()
	self.fromView = fromView or EquipTip.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self:Flush()
end

function ItemTipsView:OnFlush(param_t, index)
	local cell_data = TableCopy(self.data)
	cell_data.num = 0
	self.cell:SetData(cell_data)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg then
		RichTextUtil.ParseRichText(self.node_t_list.rich_item_dec.node, item_cfg.desc)
		self.lbl_item_name:setString(item_cfg.name)
		self.lbl_item_name:setColor(Str2C3b(string.format("%06x", item_cfg.color)))
		self.lbl_level:setColor(COLOR3B.GREEN)
		self.node_t_list.lbl_item_descrp.node:setColor(COLOR3B.R_Y)
		self.limit_level = 0
		local zhuan = 0
		for k,v in pairs(item_cfg.conds) do
			if v.cond == ItemData.UseCondition.ucLevel then
				self.limit_level = v.value
				if not RoleData.Instance:IsEnoughLevelZhuan(v.value) then
					self.lbl_level:setColor(COLOR3B.RED)
				end
			end
			if v.cond == ItemData.UseCondition.ucMinCircle then
				zhuan = v.value
				if v.value > RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) then
					self.lbl_level:setColor(COLOR3B.RED)
				end
			end
		end
		if zhuan > 0 then
			self.lbl_level:setString(string.format(Language.Tip.ZhuanDengJi, zhuan, self.limit_level))
		else
			self.lbl_level:setString(string.format(Language.Tip.DengJi, self.limit_level))
		end
		self.lbl_type:setString(string.format(Language.Tip.ZhuangBeiLeiXing, ItemData.GetItemTypeName(item_cfg.type)))
		self:UpdateCenterText(item_cfg)
	end
	
	self:ShowOperationState()
	self:UpdateTimeTip()
	self:UpdateViewPosition()
end

--根据不同的状态出现不同的按钮
function ItemTipsView:ShowOperationState()
	local handle_types = self:GetOperationLabelByType(self.fromView)
	if handle_types then
		for k, v in ipairs(self.buttons) do
			local label = Language.Tip.ButtonLabel[handle_types[k]]	--获得文字内容
			if label ~= nil then
				v:setVisible(true)
				v:setTag(handle_types[k])
				v:setTitleText(label)
			else
				v:setVisible(false)
			end
		end
	end
end

function ItemTipsView:GetOperationLabelByType(fromView)
	local t = {}
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end

	if IS_ON_CROSSSERVER and not (ItemData.CanUseItemType(item_cfg.type)) then
		return t
	end
	if fromView == EquipTip.FROM_BAG then							--在背包界面中
		if not item_cfg.flags.denyDestroy then
			if self.data.is_bind == 0 then
				t[#t+1] = EquipTip.HANDLE_DISCARD
			else
				t[#t+1] = EquipTip.HANDLE_DESTROY
			end
		end
		
		if self.data.num and self.data.num > 1 then
			t[#t+1] = EquipTip.HANDLE_SPLIT
		end

		if ItemData.CanUseItemType(item_cfg.type) and not ItemData.IsShowTimeItem[item_cfg.item_id] then
			t[#t+1] = EquipTip.HANDLE_USE
		elseif ItemData.IsShowTimeItem[item_cfg.item_id] and not ItemData.Instance:CheckItemIsOverdue(self.data) then
			t[#t+1] = EquipTip.HANDLE_USE
		elseif item_cfg.openUi and item_cfg.openUi >= 1 then
			t[#t+1] = EquipTip.HANDLE_USE
		end

		if self.data.num > 1 and item_cfg.flags.isCanOnekeyUse then
			t[#t+1] = EquipTip.HANDLE_QUICK_USE
		end
		
		if ItemData.GetIsFashion(self.data.item_id) or ItemData.GetIsHuanWu(self.data.item_id) then
			t[#t+1] = EquipTip.HANDLE_EQUIP
		end

	elseif fromView == EquipTip.FROME_BAG_STONE then
		t[#t+1] = EquipTip.HANDLE_INLAY
	elseif fromView == EquipTip.FROME_EQUIP_STONE then
		t[#t+1] = EquipTip.HANDLE_TAKEOFF
	elseif fromView == EquipTip.FROM_BAG_ON_BAG_STORAGE then
		if not item_cfg.flags.denyDestroy then
			t[#t+1] = EquipTip.HANDLE_DISCARD
		end
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_STORAGE_ON_BAG_STORAGE then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_CONSIGN_ON_SELL then
		t[#t+1] = EquipTip.HANDLE_INPUT
		if self.data.num and self.data.num > 1 then
			t[#t+1] = EquipTip.HANDLE_SPLIT
		end
	elseif fromView == EquipTip.FROM_CONSIGN_ON_BUY then
		if not ConsignData.Instance:GetItemSellerIsMe(self.data) then
			t[#t+1] = EquipTip.HANDLE_BUY
		end
	elseif fromView == EquipTip.FROM_XUNBAO_BAG then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_WING_STONE then
		if self.data.num and self.data.num > 0 then
			t[#t+1] = EquipTip.HANDLE_ZHURU	
		end
	elseif fromView == EquipTip.FROM_CHAT_BAG then
		t[#t+1] = EquipTip.HANDLE_SHOW	
	elseif fromView == EquipTip.FROM_EXCHANGE_BAG then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_STRFB then
		if self.data.num and self.data.num > 0 then
			t[#t+1] = EquipTip.HANDLE_USE
		end
	elseif fromView == EquipTip.FROM_BAG_ON_RECYCLE then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_RECYCLE then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_BAG_ON_CARD_DESCOMPOSE then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_CARD_DESCOMPOSE then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	end
	
	return t
end

function ItemTipsView:OperationClickHandler(psender)
	if self.data == nil then
		return
	end
	self.handle_type = psender:getTag()
	if self.handle_type == nil then
		return
	elseif self.handle_type == EquipTip.HANDLE_SPLIT then
		self:OnOpenPopNum()
		return
	elseif self.handle_type == EquipTip.HANDLE_ZHURU and self.fromView == EquipTip.FROM_WING_STONE then
		TipCtrl.Instance:UseItem(self.handle_type, self.data, self.handle_param_t, self.fromView)
		return
	elseif self.handle_type == EquipTip.HANDLE_QUICK_USE then
		BagCtrl.Instance:SendUseItem(self.data.series, 0, self.data.num)
		psender:setTitleText(Language.Tip.ButtonLabel[EquipTip.HANDLE_CANCEL_USE])
		psender:setTag(EquipTip.HANDLE_CANCEL_USE)
		self.in_quick_using = true
		return
	elseif self.handle_type == EquipTip.HANDLE_CANCEL_USE then
		self.in_quick_using = false
		self:Close()
	end
	TipCtrl.Instance:UseItem(self.handle_type, self.data, self.handle_param_t, self.fromView)

	self:Close()
end

function ItemTipsView:OnItemUseSuc(param)
	if self.in_quick_using and param.item_id == self.data.item_id then
		if param.result == 0 then
			self:Close()
		else
			BagCtrl.Instance:SendUseItem(self.data.series, 0, self.data.num)
		end
	end
end

function ItemTipsView:OnItemDelete(series)
	if self.in_quick_using and self.data.series == series then
		self:Close()
	end
end

-- 打开数字键盘
function ItemTipsView:OnOpenPopNum()
	if self.data == nil then return end

	if nil ~= self.pop_num_view then
		local maxnum = ItemData.Instance:GetItemNumInBagBySeries(self.data.series)
		if maxnum == 1 then  --数量为1时不弹
			self:OnOKCallBack(maxnum)
		else
			self.pop_num_view:Open()
			if self.handle_type == EquipTip.HANDLE_SPLIT then
				self.pop_num_view:SetText(1)
			else
				self.pop_num_view:SetText(maxnum)
			end
			self.pop_num_view:SetMaxValue(maxnum)
		end
	end
end

-- 数字键盘确定按钮回调
function ItemTipsView:OnOKCallBack(num)
	if self.data == nil then return end
	if 0 == num then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Common.NumCantBeZero)
		return 
	end

	self.item_num = tonumber(num)
	local maxnum = ItemData.Instance:GetItemNumInBagBySeries(self.data.series)
	if self.item_num > maxnum then
		self.item_num = maxnum
	end
	self.handle_param_t.num = self.item_num

	

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)

	if self.handle_type == EquipTip.HANDLE_USE or self.handle_type == EquipTip.HANDLE_SPLIT then
		TipCtrl.Instance:UseItem(self.handle_type, self.data, self.handle_param_t, self.fromView)
	end
	self:Close()
end

--特殊物品添加时间提示
function ItemTipsView:UpdateTimeTip()
	if nil == self.data or nil == self.data.use_time then return end
	local is_show_time = ItemData.IsShowTimeItem[self.data.item_id] and true or false
	self.node_t_list.layout_time_tip.node:setVisible(is_show_time)

	self.time_height = is_show_time and 70 or 0

	if is_show_time then
		local time = os.date("*t", self.data.use_time)
		local str = string.format(Language.Tip.TimeTip, time.year, time.month, time.day, time.hour, time.min, time.sec)
		if ItemData.Instance:CheckItemIsOverdue(self.data) then
			str = Language.Tip.TimeTip2
		end
		self.node_t_list.lbl_spare_time.node:setString(str)
	end
end

function ItemTipsView:UpdateViewPosition()
	self.node_t_list.rich_item_dec.node:refreshView()
	local down_height = self.node_t_list.rich_item_dec.node:getInnerContainerSize().height + 40
	local item_tips_h = math.max(ItemTipsView.HEIGHT, down_height + self.time_height + 170 + (self.has_center_text and 30 or 0))
	self.itemtips_bg:setContentWH(self.itemtips_bg:getContentSize().width, item_tips_h)
	self.itemtips_bg:setPositionY(item_tips_h / 2)
	self.layout_content_top:setPositionY(item_tips_h - 130)
	self.layout_content_down:setPositionY(item_tips_h - 280 - (self.has_center_text and 30 or 0))
	self.layout_btns:setPositionY(10)
	self.node_t_list.btn_close_window.node:setPositionY(item_tips_h - 25)
	self.root_node:setContentWH(self.root_node:getContentSize().width, item_tips_h)
end

-- 经验珠显示经验存量
function ItemTipsView:UpdateCenterText(item_cfg)
	if item_cfg.type == ItemData.ItemType.itHpPot and self.data.durability ~= nil and item_cfg.dura ~= nil then
		self.has_center_text = true
		self.center_text:setVisible(true)
		self.center_text:setString(string.format(Language.Tip.ExpMemory, self.data.durability, item_cfg.dura))
	else
		self.has_center_text = false
		self.center_text:setVisible(false)
	end
end

function ItemTipsView:RoleDataChangeCallback(key, value, old_value)
	-- if key == OBJ_ATTR.ACTOR_TAKEON_RIDEID or key == OBJ_ATTR.ACTOR_RIDE_EXPIRED_TIME then
		-- self:Flush()
	-- end
end