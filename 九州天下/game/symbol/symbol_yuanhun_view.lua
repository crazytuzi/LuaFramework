-- 灵炼界面
SymbolYuanhunView = SymbolYuanhunView or BaseClass(BaseRender)

function SymbolYuanhunView:__init()
	self.last_send_xi_lian_time = 0
	self.model_res = 0
	self.cur_act = false
	self.stuff_item_id = 0
	self.lock_slot_num = 0
	self.lock_slot_flag = 0
	self.toggle = self:FindObj("toggle")

	self.name = self:FindVariable("name")
	self.attr1 = self:FindVariable("attr1")
	self.attr2 = self:FindVariable("attr2")
	self.limit_icon_1 = self:FindVariable("LimitIcon1")
	self.limit_icon_2 = self:FindVariable("LimitIcon2")
	self.power = self:FindVariable("power")
	self.stuff_num = self:FindVariable("stuff_num")
	self.lock_num = self:FindVariable("lock_num")
	self.show_buy = self:FindVariable("show_buy")
	self.show_cur_attr = self:FindVariable("show_cur_attr")
	self.show_next_attr = self:FindVariable("show_next_attr")
	self.display = self:FindObj("ModelDisplay")

	self.stuff_cell = ItemCell.New()
	self.stuff_cell:SetInstanceParent(self:FindObj("item"))

	self.lock_cell = ItemCell.New()
	self.lock_cell:SetInstanceParent(self:FindObj("lock_item"))
	self.cell_list = {}
	self.left_select = 0
	self:InitLeftScroller()

	self.attr_list = {}
	for i = 1, GameEnum.ELEMENT_HEART_MAX_XILIAN_SLOT do
		local xilian_element_obj =  self:FindObj("Element" .. i)
		local element = yuanhunXiLianElement.New(xilian_element_obj)
		element:SetIndex(i)
		element.parent = self
		table.insert(self.attr_list, element)
	end
	self.select_stuff_cfg = SymbolData.Instance:GetXiLianDefaultInfo()

	self:ListenEvent("OnClickXiLian", BindTool.Bind(self.OnClickXiLian, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
end

function SymbolYuanhunView:__delete()
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	if self.attr_list then
		for k,v in pairs(self.attr_list) do
			v:DeleteMe()
		end
	end
	if self.stuff_cell then
		self.stuff_cell:DeleteMe()
		self.stuff_cell = nil
	end
	if self.lock_cell then
		self.lock_cell:DeleteMe()
		self.lock_cell = nil
	end
	if nil ~= self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function SymbolYuanhunView:InitLeftScroller()
	self.left_scroller = self:FindObj("LeftList")
	local delegate = self.left_scroller.list_simple_delegate
	-- 生成数量
	self.left_data = SymbolData.Instance:GetElementHeartOpencCfg()
	delegate.NumberOfCellsDel = function()
		return #self.left_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  YuanhunLeftCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
			target_cell:SetToggleGroup(self.left_scroller.toggle_group)
		end
		target_cell:SetData(self.left_data[data_index + 1])
		target_cell:SetIndex(data_index)
		local info = SymbolData.Instance:GetElementInfo(data_index)
		target_cell:Lock(info == nil or info.element_level <= 0)
		target_cell:IsOn(data_index == self.left_select)
		target_cell:SetClickCallBack(BindTool.Bind(self.ClickLeftListCell, self, target_cell))
	end
end

function SymbolYuanhunView:FlushModel(info)
	if info and info.element_level > 0 then
		if nil == self.model then
			self.model = RoleModel.New("symbol_panel")
			self.model:SetDisplay(self.display.ui3d_display)
		end
		local model_res = SymbolData.Instance:GetModelResIdByElementId(info.wuxing_type)
		if self.model_res ~= model_res then
			self.model_res = model_res

			local asset, bundle = ResPath.GetWuXinZhiLingModel(model_res)
			self.model:SetMainAsset(asset, bundle)
			self.model:SetModelScale(Vector3(1.5, 1.5, 1.5))
		end
	elseif self.model then
		self.model_res = 0
		self.model:ClearModel()
	end
end

function SymbolYuanhunView:OnClickXiLian()
	if Status.NowTime - self.last_send_xi_lian_time < 0.3 then
		return
	end

	if ItemData.Instance:GetItemNumInBagById(self.stuff_item_id) <= 0 and (not self.toggle.toggle.isOn or self.select_stuff_cfg.comsume_color >= HunQiData.XiLianStuffColor.RED) then
		-- 物品不足，弹出TIP框
		-- local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.stuff_item_id]
		-- if item_cfg then
		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.toggle.toggle.isOn = true
			end
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, self.stuff_item_id, nofunc, 1)
		return
		-- end
	end

	local has_rare, num = SymbolData.Instance:GetXiLianHasRareById(self.left_select)
	local des = string.format(Language.Symbol.XiLianConfireTips, num)
	local function ok_callback()
		-- 请求洗练，param1 魂器类型， param2锁定槽0-7位表示1-8位属性, param3洗练材料类型,param4 是否自动购买,
		local is_auto_buy = self.toggle.toggle.isOn and 1 or 0
		self.last_send_xi_lian_time = Status.NowTime
		SymbolCtrl.Instance:SendXilianElementHeartReq(self.left_select, self.lock_slot_flag, self.xilian_comsume_color, is_auto_buy)
	end
	if has_rare then
		TipsCtrl.Instance:ShowCommonAutoView(nil, des, ok_callback)
	else
		ok_callback()
	end
end

function SymbolYuanhunView:SelectStuffCallBack(data)
	self.select_stuff_cfg = data
	self.toggle.toggle.isOn = false
	self:Flush()
end

function SymbolYuanhunView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(287)
end

function SymbolYuanhunView:ClickLeftListCell(cell)
	if self.left_select ~= cell.index then
		SymbolData.LOCK = {}
		self.lock_slot_flag = 0
		self.lock_slot_num = 0
		self.left_select = cell.index
		self:Flush()
	end
end

function SymbolYuanhunView:OpenCallBack()
	SymbolData.LOCK = {}
	self.lock_slot_flag = 0
	self.lock_slot_num = 0
	self.model_res = 0
	self:Flush()
end

function SymbolYuanhunView:CloseCallBack()
	TipsCtrl.Instance:ChangeAutoViewAuto(false)
	TipsCommonAutoView.AUTO_VIEW_STR_T.Symbol_XiLian = nil
end

function SymbolYuanhunView:UpdateLockPanel()
	local count = 0
	local lock_flag = 0
	for k,v in pairs(SymbolData.LOCK) do
		if v then
			count = count + 1
			lock_flag = lock_flag + math.pow(2 , k)
		end
	end
	self.lock_slot_num = count
	self.lock_slot_flag = lock_flag
	local lock_cfg = SymbolData.Instance:GetElementXiLianLockCfg(count)
	if lock_cfg then
		self.lock_cell:SetData({item_id = lock_cfg.lock_comsume_ID, num = 0})
		local need = lock_cfg.lock_comsume_item.num
		local has = ItemData.Instance:GetItemNumInBagById(lock_cfg.lock_comsume_ID)
		local color = has >= need and COLOR.GREEN or COLOR.RED
		self.lock_num:SetValue(ToColorStr(has,color).. "/" .. need)
	end
end

function SymbolYuanhunView:OnFlush(param_t)
	local data = SymbolData.Instance
	local info = data:GetElementInfo(self.left_select)
	if info == nil then
		return
	end

	self:FlushModel(info)
	self.cur_act = info.element_level > 0
	local stuff_cfg = self.select_stuff_cfg
	self.stuff_cell:SetData({item_id = stuff_cfg.consume_item.item_id})
	self.xilian_comsume_color = stuff_cfg.comsume_color
	self.show_buy:SetValue(self.xilian_comsume_color < SymbolData.XiLianStuffColor.RED)
	self.stuff_item_id = stuff_cfg.consume_item.item_id
	local num = ItemData.Instance:GetItemNumInBagById(stuff_cfg.consume_item.item_id)
	local need_num = stuff_cfg.consume_item.num
	local color = num >= need_num and COLOR.GREEN or COLOR.RED
	self.stuff_num:SetValue(ToColorStr(num,color).. "/" .. need_num)
	self.lock_cell.root_node:SetActive(true)
	local count_t = {}
	local attr_list = CommonStruct.Attribute()
	local yuanhun_info = data:GetElementXiLianSingleInfo(self.left_select)
	if self.cur_act and yuanhun_info then
		local name = Language.Symbol.ElementsName[info.wuxing_type]
		self.name:SetValue("LV." .. info.element_level .. " " .. name)
		for k,v in pairs(self.attr_list) do
			local vo = yuanhun_info.slot_list[k]
			if vo then
				local attr_type = data:GetElementXiLianAttr(self.left_select, k - 1)
				attr_list[attr_type] = attr_list[attr_type] + vo.xilian_val
				v:SetData({element_id = self.left_select, slot = k -1, xilian_val = vo.xilian_val, element_attr_type = vo.element_attr_type, open_slot = vo.open_slot, attr_type = attr_type})
				if vo.open_slot == 1 then
					if count_t[vo.element_attr_type] then
						count_t[vo.element_attr_type] = count_t[vo.element_attr_type] + 1
					else
						count_t[vo.element_attr_type] = 1
					end
				end
			else
				v:SetData({element_id = self.left_select, slot = k -1, open_slot = 0})
			end
		end
		self:UpdateLockPanel()
		local addition_cfg = SymbolData.Instance:GetElementXiLianAttrAddition(info.wuxing_type)
		local index = 1
		for i,v in ipairs(addition_cfg) do
			local has_count = count_t[v.element_shuxing_type] or 0
			local color = has_count < v.need_element_shuxing_count and "#ff0000" or "#00ff00"
			local add_name = Language.Symbol.Elements[v.element_shuxing_type] or ""
			self["attr" .. index]:SetValue(string.format(Language.Symbol.ElementAttrAdd, name, v.add_percent, color, has_count, v.need_element_shuxing_count, add_name))
			self["limit_icon_" .. index]:SetAsset(ResPath.GetSymbolImage("yuanhun_icon_" .. v.element_shuxing_type))
			index = index + 1
		end
	else
		self.name:SetValue("")
		self.lock_num:SetValue("")
		self.power:SetValue(0)
		self.lock_cell.root_node:SetActive(false)
		for k,v in pairs(self.attr_list) do
			v:SetData({element_id = self.left_select, slot = k -1, open_slot = 0})
		end
	end
	self.power:SetValue(CommonDataManager.GetCapability(attr_list))
	if self.left_scroller.scroller.isActiveAndEnabled then
		self.left_scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

-----------------------------------------------------------------
YuanhunLeftCell = YuanhunLeftCell or BaseClass(BaseCell)

function YuanhunLeftCell:__init()
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.remind = self:FindVariable("Remind")
	self.lock = self:FindVariable("Lock")
	self:ListenEvent("OnClick",
		BindTool.Bind(self.OnClick, self))
end

function YuanhunLeftCell:__delete()

end

function YuanhunLeftCell:IsOn(value)
	self.root_node.toggle.isOn = value
end

function YuanhunLeftCell:SetToggleGroup(group)
  	self.root_node.toggle.group = group
end

function YuanhunLeftCell:Lock(value)
	self.lock:SetValue(value)
end

function YuanhunLeftCell:OnFlush()
	if nil == self.data then return end
	local info = SymbolData.Instance:GetElementInfo(self.data.id)
	if info then
		self.icon:SetAsset(ResPath.GetSymbolImage("yuansu_icon_" .. self.data.id))
		if info.element_level > 0 then
			self.name:SetValue("LV." .. info.element_level)
		else
			self.name:SetValue("")
		end
	end

	self.remind:SetValue(false)
end

-----------------------------------------------------------------
yuanhunXiLianElement = yuanhunXiLianElement or BaseClass(BaseCell)

function yuanhunXiLianElement:__init()
	self.attr = self:FindVariable("attr")
	self.icon = self:FindVariable("Icon")
	self.lock = self:FindVariable("Lock")
	self.open = self:FindVariable("Open")
	self.limit = self:FindVariable("Limit")
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end

function yuanhunXiLianElement:__delete()
	self.parent = nil
end

function yuanhunXiLianElement:OnClick()
	if not SymbolData.Instance:GetElementXiLianCanChangeLock(self.data.element_id, self.data.slot) then
		TipsCtrl.Instance:ShowSystemMsg(Language.Symbol.XilianLockLimit)
		return
	end
	SymbolData.LOCK[self.data.slot] = not SymbolData.LOCK[self.data.slot]
	local lock_img = SymbolData.LOCK[self.data.slot] == true and "icon_lock" or "icon_unlock"
	self.lock:SetAsset(ResPath.GetImages(lock_img))
	if self.parent then
		self.parent:UpdateLockPanel()
	end
end

function yuanhunXiLianElement:OnFlush(param_t)
	if not self.data then
		return
	end
	local element_data = SymbolData.Instance
	self.open:SetValue(self.data.open_slot == 1)
	if self.data.open_slot == 0 then
		local open_lv = element_data:GetElementXiLianOpenLevel(self.data.element_id, self.data.slot)
		self.limit:SetValue(string.format(Language.Symbol.SymbolXLOpenLevel, open_lv))
		self.attr:SetValue("")
		return
	end
	self.limit:SetValue("")
	local star = element_data:GetElementXiLianAttrStar(self.data.element_id, self.data.slot, self.data.xilian_val)
	local color = TEXT_COLOR.GREEN_SPECIAL
	if star >= 9 then
		color = TEXT_COLOR.RED
	elseif star >= 7 then
		color = TEXT_COLOR.ORANGE2
	elseif star >= 5 then
		color = TEXT_COLOR.PURPLE2
	end

	self.attr:SetValue(Language.Common.AttrName[self.data.attr_type] .. ":<color='".. color .."'>+" .. self.data.xilian_val .. "(" .. star .."星)</color>")
	self.icon:SetAsset(ResPath.GetSymbolImage("yuanhun_icon_" .. self.data.element_attr_type))
	local lock_img = SymbolData.LOCK[self.data.slot] == true and "icon_lock" or "icon_unlock"
	self.lock:SetAsset(ResPath.GetImages(lock_img))
end
