-- 经验玉tips
ExpItemTipView = ExpItemTipView or BaseClass(XuiBaseView)

function ExpItemTipView:__init()
	--self.texture_path_list[1] = 'res/xui/guide.png'
	self.config_tab = {
		{"itemtip_ui_cfg", 16, {0}}
	}
	self.series = nil
	self.alert_view = Alert.New() 
	self.alert_view:SetShowCheckBox(true)
	self.alert_not_view = Alert.New()
	self.alert_not_view:SetShowCheckBox(true)
	self.is_any_click_close = true
end

function ExpItemTipView:__delete()
	if self.alert_view ~= nil then
		self.alert_view:DeleteMe()
		self.alert_view = nil 
	end
	if self.alert_not_view ~= nil then
		self.alert_not_view:DeleteMe()
		self.alert_not_view = nil 
	end
end

function ExpItemTipView:ReleaseCallBack()
	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end

end

function ExpItemTipView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.cell = BaseCell.New()
		self.node_t_list.layout_exp_bottle.node:addChild(self.cell:GetCell(), 200)
		local ph_itemcell = self.ph_list.ph_itemcell --占位符
		self.cell:GetCell():setPosition(ph_itemcell.x, ph_itemcell.y)
		self.cell:SetIsShowTips(false)
		XUI.AddClickEventListener(self.node_t_list.btn_rec.node, BindTool.Bind1(self.OnFreeReceive, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_dobule_rec.node, BindTool.Bind1(self.OnDobuleReceive, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_than_rec.node, BindTool.Bind1(self.OnThanReceive, self), true)

		self.buttons = {self.node_t_list.btn_1.node, self.node_t_list.btn_2.node}
		for k, v in pairs(self.buttons) do
			v:addClickEventListener(BindTool.Bind1(self.OperationClickHandler, self))
		end
	end
end

function ExpItemTipView:CloseCallback()
	self.fromView = EquipTip.FROM_NORMAL
end

function ExpItemTipView:SetData(data, fromView, param_t)
	if not data then
		return
	end
	
	self.data = data
	self:Open()
	self.fromView = fromView or EquipTip.FROM_NORMAL
	self:Flush()
end

function ExpItemTipView:OnFlush(param_t, index)
	self.cell:SetData(self.data)
	self:PropUseLimit()
	local cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	RichTextUtil.ParseRichText(self.node_t_list.rich_item_dec.node, cfg.desc)
	self.node_t_list.itemname_txt.node:setString(cfg.name)
	local durability = self.data.durability or 0
	local durability_max = (self.data.durability_max and self.data.durability_max > 0) and self.data.durability_max or cfg.dura
	self.node_t_list.progress_bar.node:setPercent(durability / durability_max * 100)
	self.node_t_list.progress_text.node:setString(durability .. "/" .. durability_max)



	local vip_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)		-- 人物vip等级
	local exp_cfg = ItemData.Instance:GetExpConfig(self.data.item_id)
	local txt_1 = string.format(Language.Common.ExpItemText, exp_cfg[2].consume.count, ShopData.GetMoneyTypeName(MoneyAwarTypeToMoneyType[exp_cfg[2].consume.type]))
	self.node_t_list.txt_dobule_rec.node:setString(txt_1)
	txt_1 = string.format(Language.Common.ExpItemText, exp_cfg[3].consume.count, ShopData.GetMoneyTypeName(MoneyAwarTypeToMoneyType[exp_cfg[2].consume.type]))
	self.node_t_list.txt_than_rec.node:setString(txt_1)
	for k, v in pairs(exp_cfg[3].vip) do
		if vip_level >= v.cond[1] and vip_level <= v.cond[2] then
			txt_1 = string.format(Language.Common.TimesReceive, v.rate)
			break
		end
	end
	self.node_t_list.txt_time_rec.node:setString(txt_1)

	self.node_t_list.btn_rec.node:setEnabled(self.fromView ~= EquipTip.FROM_MAIL and IS_ON_CROSSSERVER ~= true and self.fromView ~= EquipTip.FROM_STORAGE_ON_BAG_STORAGE and self.fromView ~= EquipTip.FROM_BAG_ON_BUY)
	self.node_t_list.btn_dobule_rec.node:setEnabled(self.fromView ~= EquipTip.FROM_MAIL and IS_ON_CROSSSERVER ~= true and self.fromView ~= EquipTip.FROM_STORAGE_ON_BAG_STORAGE and self.fromView ~= EquipTip.FROM_BAG_ON_BUY)
	self.node_t_list.txt_time_rec.node:setEnabled(self.fromView ~= EquipTip.FROM_MAIL and IS_ON_CROSSSERVER ~= true and self.fromView ~= EquipTip.FROM_STORAGE_ON_BAG_STORAGE and self.fromView ~= EquipTip.FROM_BAG_ON_BUY)
	self.node_t_list.btn_than_rec.node:setEnabled(self.fromView ~= EquipTip.FROM_MAIL and IS_ON_CROSSSERVER ~= true and self.fromView ~= EquipTip.FROM_STORAGE_ON_BAG_STORAGE and self.fromView ~= EquipTip.FROM_BAG_ON_BUY)
	self.node_t_list.txt_dobule_rec.node:setEnabled(self.fromView ~= EquipTip.FROM_MAIL and IS_ON_CROSSSERVER ~= true and self.fromView ~= EquipTip.FROM_STORAGE_ON_BAG_STORAGE and self.fromView ~= EquipTip.FROM_BAG_ON_BUY)
	self.node_t_list.txt_than_rec.node:setEnabled(self.fromView ~= EquipTip.FROM_MAIL and IS_ON_CROSSSERVER ~= true and self.fromView ~= EquipTip.FROM_STORAGE_ON_BAG_STORAGE and self.fromView ~= EquipTip.FROM_BAG_ON_BUY)

	self.node_t_list.txt_time_rec.node:setVisible(vip_level > 0)
	self.node_t_list.btn_than_rec.node:setVisible(vip_level > 0)
	self.node_t_list.txt_than_rec.node:setVisible(vip_level > 0)

	self:ShowOperationState()
end

--根据不同的状态出现不同的按钮
function ExpItemTipView:ShowOperationState()
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

			if handle_types[k] == EquipTip.HANDLE_USE then
				ClientCommonButtonDic[CommonButtonType.ITEM_TIP_USE_BTN] = v
			end	
		end
	end
end

function ExpItemTipView:GetOperationLabelByType(fromView)
	local t = {}
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	if fromView == EquipTip.FROM_BAG then							--在背包界面中
		if not item_cfg.flags.denyDestroy then
			if self.data.is_bind == 0 then
				t[#t+1] = EquipTip.HANDLE_DISCARD
			else
				t[#t+1] = EquipTip.HANDLE_DESTROY
			end
		end
	elseif fromView == EquipTip.FROM_BAG_ON_BAG_STORAGE then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_STORAGE_ON_BAG_STORAGE then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	end
	return t
end

function ExpItemTipView:OperationClickHandler(psender)
	if self.data == nil then
		return
	end
	self.handle_type = psender:getTag()
	if self.handle_type == nil then
		return
	end
	TipsCtrl.Instance:UseItem(self.handle_type, self.data, self.handle_param_t, self.fromView)

	self:Close()
end

--限制道具使用次数
function ExpItemTipView:PropUseLimit()
	local info = ItemData.Instance:GetLimintUseCountCfg(self.data.item_id)

	if info.dailyUseLimit ~= nil then
		local remian_time, total_time = ItemData.Instance:GetLimitItemTick(self.data.item_id)
		if remian_time ~= nil and total_time ~= nil then
			local result = string.format(Language.Bag.PropUseLimit, remian_time, total_time)
			self.node_t_list.txt_limit.node:setString(result)
		end
	else
		self.node_t_list.txt_limit.node:setString("")
	end
end

function ExpItemTipView:OnFreeReceive()
	self:GetTips(1)
end

function ExpItemTipView:OnDobuleReceive()
	self:GetTips(2)
end

function ExpItemTipView:OnThanReceive()
	self:GetTips(3)
end

function ExpItemTipView:GetTips(exp_num)
	if exp_num == 1 then
		if self.data.durability ~= self.data.durability_max then
			self:NotRefreshTips(exp_num)
		else
			BagCtrl.Instance:SendUseItem(self.data.series, 0, 1, exp_num, "")
		end
	else
		if  self.data.durability ~= self.data.durability_max then
			self:NotRefreshTips(exp_num)
		else
			self:RefreshTips(exp_num)
		end
	end
end

function ExpItemTipView:RefreshTips(num)
	-- if self.alert_view == nil then
	-- 	self.alert_view = Alert.New()
	-- end
	local exp_cfg = ItemData.Instance:GetExpConfig(self.data.item_id)
	local txt_type = ShopData.GetMoneyTypeName(MoneyAwarTypeToMoneyType[exp_cfg[num].consume.type])
	local txt = string.format(Language.Common.Refresh_Tips, exp_cfg[num].consume.count, txt_type)
	self.alert_view:SetLableString(txt)
	self.alert_view:SetOkFunc(function ()
		BagCtrl.Instance:SendUseItem(self.data.series, 0, 1, num, "")
  	end)
  	self.alert_view:Open()
end

function ExpItemTipView:NotRefreshTips(num)
	local exp_cfg = ItemData.Instance:GetExpConfig(self.data.item_id)
	-- self.alert_view:SetShowCheckBox(true)
	local txt = Language.Common.NotFull
	
	self.alert_not_view:SetLableString(txt)
	self.alert_not_view:SetOkFunc(function ()
		BagCtrl.Instance:SendUseItem(self.data.series, 0, 1, num, "")
  	end)
  	self.alert_not_view:Open()
end

