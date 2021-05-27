TipSubItemOpt = TipSubItemOpt or BaseClass(TipSub)

TipSubItemOpt.SIZE = cc.size(0, 0)

function TipSubItemOpt:__init()
	self.y_order = 0
	self.is_ignore_height = true
	self.label_t = Language.Tip.ButtonLabel
	self.buttons = {}

	self.in_quick_using = false
end

function TipSubItemOpt:__delete()
end

function TipSubItemOpt:AlignSelf()
	self.view:setPosition(BaseTip.WIDTH, 40)
end

function TipSubItemOpt:SetData(data, fromView, param_t)
	self.data = data
	self.fromView = fromView or EquipTip.FROM_NORMAL
	self.handle_param_t = param_t or {}

	self.handle_type = 0
	self.item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.item_color3b = Str2C3b(string.sub(string.format("%06x", self.item_cfg.color), 1, 6))
	self.item_prof_limit = ItemData.Instance:GetItemLimit(self.data.item_id, ItemData.UseCondition.ucJob)
	self.limit_level = ItemData.Instance:GetItemLimit(self.data.item_id, ItemData.UseCondition.ucLevel)
	self.circle_level = ItemData.Instance:GetItemLimit(self.data.item_id, ItemData.UseCondition.ucMinCircle)

	self:Flush()
	self:BindEvents()
end

function TipSubItemOpt:Release()
	self.buttons = {}

	if nil ~= self.pop_num_view then
		self.pop_num_view:DeleteMe()
		self.pop_num_view = nil
	end

	if nil ~= self.use_alert then
		self.use_alert:DeleteMe()
		self.use_alert = nil
	end
end

function TipSubItemOpt:BindEvents()
	if nil == self.item_use_suc_handler then
		self.item_use_suc_handler = GlobalEventSystem:Bind(KnapsackEventType.KNAPSACK_ITEM_USE, BindTool.Bind(self.OnItemUseSuc, self))
		self.item_del_handler = GlobalEventSystem:Bind(KnapsackEventType.KNAPSACK_ITEM_DELETE, BindTool.Bind(self.OnItemDelete, self))
	end
end

function TipSubItemOpt:CloseCallBack()
	if self.item_use_suc_handler then
		GlobalEventSystem:UnBind(self.item_use_suc_handler)
		self.item_use_suc_handler = nil
	end
	if self.item_del_handler then
		GlobalEventSystem:UnBind(self.item_del_handler)
		self.item_use_suc_handler = nil
	end

	GlobalTimerQuest:CancelQuest(self.auto_use_timer)
	self.auto_use_timer = nil

	self.in_quick_using = false
end

function TipSubItemOpt:CreateChild()
	TipSubItemOpt.super.CreateChild(self)

	self.pop_num_view = NumKeypad.New()
	self.pop_num_view:SetOkCallBack(BindTool.Bind(self.OnOKCallBack, self))

	self.buttons = {}
	for i = 1, 5 do
		node = XUI.CreateButton(109 / 2, 55 / 2 + (i - 1) * (55 + 30)-37, 0, 0, false, ResPath.GetCommon("btn_144_select"), "", "", XUI.IS_PLIST)
		node:setTitleFontName(COMMON_CONSTS.FONT)
		node:setTitleFontSize(22)
		node:setTitleColor(COLOR3B.OLIVE)
		XUI.AddClickEventListener(node, BindTool.Bind(self.OperationClickHandler, self, node))
		self.view:addChild(node)
		table.insert(self.buttons, node)
	end
end

function TipSubItemOpt:OnFlush()
	self:ShowOperationState()
end

--根据不同的状态出现不同的按钮
function TipSubItemOpt:ShowOperationState()
	local handle_types = self:GetOperationLabelByType(self.fromView)
	if handle_types then

		for k, v in ipairs(self.buttons) do
			local label = self.label_t[handle_types[k]]	--获得文字内容
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

function TipSubItemOpt:GetOperationLabelByType(fromView)
	local t = {}
	local item_cfg = self.item_cfg
	-- 屏蔽物品提示的操作按钮
	if IS_ON_CROSSSERVER
	and ShopData.Instance.GetCrossServerItemCanUse(item_cfg.id)
	or item_cfg.id == StdActivityCfg[DAILY_ACTIVITY_TYPE.DUO_BAO_QI_BING].propId then
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

		if ItemData.ItHandedDownProp[self.data.item_id] then
			t[#t+1] = EquipTip.HANDLE_DECOMPOSE
		end

		if ItemData.CanUseItemType(item_cfg.type) and not ItemData.IsShowTimeItem[item_cfg.item_id] then
			t[#t+1] = EquipTip.HANDLE_USE
		elseif ItemData.IsShowTimeItem[item_cfg.item_id] and not ItemData.Instance:CheckItemIsOverdue(self.data) then
			t[#t+1] = EquipTip.HANDLE_USE
		elseif item_cfg.openUi and item_cfg.openUi ~= "" then
			t[#t+1] = EquipTip.HANDLE_USE
		end

		if self.data.num > 1 and item_cfg.flags.isCanOnekeyUse then
			t[#t+1] = EquipTip.HANDLE_QUICK_USE
		end

		if self.data.num >= 2 and ItemData.BatchStatus.OpenViewAndBatchUse == item_cfg.batchStatus then
			t[#t+1] = EquipTip.HANDLE_ONEKEY_USE
		end
		
		if ItemData.GetIHandEquip(self.data.item_id) then
			t[#t+1] = EquipTip.HANDLE_EQUIP
		end
		
		if ItemData.GetIsHeroEquip(self.data.item_id) then
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
	elseif fromView == EquipTip.FROM_CS_BAG then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_CS_CONSUM then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_CS_DECOMPOSE_BAG then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_MEIBA_BAG then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_BAG_ON_RECYCLE then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_RECYCLE then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_BAG_ON_CARD_DESCOMPOSE then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_CARD_DESCOMPOSE then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_WING_BAG then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_WING_CL_SHOW then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_HERO_EQUIP then
		t[#t+1] = EquipTip.HANDLE_TAKEOFF	
	elseif fromView == EquipTip.FROM_ZHANGCHONG then
		if OutOfPrintData.Instance:GetIsOpen() then
			t[#t+1] = EquipTip.HANDLE_GET
		end
	end

	return t
end

function TipSubItemOpt:OperationClickHandler(psender)
	if self.data == nil then
		return
	end
	self.handle_type = psender:getTag()
	if self.handle_type == nil then
		return
	elseif self.handle_type == EquipTip.HANDLE_SPLIT then
		self:OnOpenPopNum()
		self:Close()
		return
	elseif self.handle_type == EquipTip.HANDLE_ZHURU and self.fromView == EquipTip.FROM_WING_STONE then
		TipCtrl.Instance:UseItem(self.handle_type, self.data, self.handle_param_t, self.fromView)
		return
	elseif self.handle_type == EquipTip.HANDLE_QUICK_USE then
		BagCtrl.Instance:SendUseItem(self.data.series, 0, 1)
		psender:setTitleText(Language.Tip.ButtonLabel[EquipTip.HANDLE_CANCEL_USE])
		psender:setTag(EquipTip.HANDLE_CANCEL_USE)
		self.in_quick_using = true
		return
	elseif self.handle_type == EquipTip.HANDLE_CANCEL_USE then
		psender:setTitleText(Language.Tip.ButtonLabel[EquipTip.HANDLE_QUICK_USE])
		psender:setTag(EquipTip.HANDLE_QUICK_USE)
		self.in_quick_using = false
		-- self:Close()
		return
	elseif self.handle_type == EquipTip.HANDLE_ONEKEY_USE then
		-- BagCtrl.SentOnekeyUseItemReq(self.data.series)
		BagCtrl.Instance:SendUseItem(self.data.series, 0, self.data.num)
		self:Close()
		return
	end

	TipCtrl.Instance:UseItem(self.handle_type, self.data, self.handle_param_t, self.fromView)
	self:Close()
end

-- 打开数字键盘
function TipSubItemOpt:OnOpenPopNum()
	if self.data == nil then return end

	if nil ~= self.pop_num_view then
		local maxnum = BagData.Instance:GetItemNumInBagBySeries(self.data.series)
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
function TipSubItemOpt:OnOKCallBack(num)
	if self.data == nil then return end
	if 0 == num then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Common.NumCantBeZero)
		return 
	end

	self.item_num = tonumber(num)
	local maxnum = BagData.Instance:GetItemNumInBagBySeries(self.data.series)
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

function TipSubItemOpt:OnItemUseSuc(param)
	if self.in_quick_using and param.item_id == self.data.item_id then
		if param.result == 0 then
			self:Close()
		else
			self.auto_use_timer = GlobalTimerQuest:AddDelayTimer(function()
				BagCtrl.Instance:SendUseItem(self.data.series, 0, 1)
				self.auto_use_timer = nil
			end, 0.12)
		end
	end
end

function TipSubItemOpt:OnItemDelete(series)
	if self.in_quick_using and self.data.series == series then
		self:Close()
	end
end


return TipSubItemOpt
