BubbleView = BubbleView or BaseClass(BaseRender)

function BubbleView:__init()
	self.hp = self:FindVariable("Hp")
	self.gongji = self:FindVariable("Gongji")
	self.fangyu = self:FindVariable("Fangyu")
	self.rise_hp = self:FindVariable("RiseHp")
	self.rise_gongji = self:FindVariable("RiseGongji")
	self.rise_fangyu = self:FindVariable("RiseFangyu")
	self.capability = self:FindVariable("Capability")

	self.bubble_data = {}
	self.cell_list = {}
	self.select_index = 1

	--获取变量
	self.bubble_name = self:FindVariable("BubbleName")
	self.touch_enable = self:FindVariable("TouchEnable")
	self.is_activate = self:FindVariable("IsActivate")
	self.item_number1 = self:FindVariable("ItemNum1")
	self.item_number2 = self:FindVariable("ItemNum2")
	self.button_text = self:FindVariable("ButtonName")

	self.btn_choose_name = self:FindVariable("BtnChooseName")
	self.btn_choose_enable = self:FindVariable("BtnChooseEnable")
	self:ListenEvent("OnClickChoose", BindTool.Bind(self.OnClickChoose, self))

	self.item_cell = {}
	for i = 1, 2 do
		self.item_cell[i] = {}
		self.item_cell[i].obj = self:FindObj("ItemCell" .. i)
		self.item_cell[i].cell = ItemCell.New()
		self.item_cell[i].cell:SetInstanceParent(self.item_cell[i].obj)
	end

	--获取UI
	self.bubble_list = self:FindObj("BubbleList")
	self.ani_obj = self:FindObj("AniObj")

	local scroller_delegate = self.bubble_list.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMaxCellNum, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellList, self)

	--监听事件
	self:ListenEvent("OnClickAtrr",BindTool.Bind(self.OnClickAtrr, self))
	self:ListenEvent("ClickHelp",BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickButton",BindTool.Bind(self.OnClickButton, self))
end

function BubbleView:__delete()
	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	
	for k,v in pairs(self.item_cell) do
		if v.cell then
			v.cell:DeleteMe()
			v.cell = nil
		end
	end

	self.hp = nil
	self.gongji = nil
	self.fangyu = nil
	self.rise_hp = nil
	self.rise_gongji = nil
	self.rise_fangyu = nil
	self.capability = nil
	self.bubble_name = nil
	self.touch_enable = nil
	self.is_activate = nil
	self.item_number1 = nil
	self.item_number2 = nil
	self.button_text = nil
	self.bubble_list = nil
	self.ani_obj = nil
	self.btn_choose_name = nil
	self.btn_choose_enable = nil
end

function BubbleView:OnClickChoose()
	if self.select_index <= 0 then return end
	local select_data = CoolChatData.Instance:GetBubbleDataByIndex(self.select_index)
	local seq = CoolChatData.Instance:GetSeqByIndex(self.select_index)
	local select_seq = CoolChatData.Instance:GetSelectSeq()
	if seq - 1 == select_seq then
		CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_BUBBLE_USE, -1, 0, 0)
	elseif select_data.is_activate then
		CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_BUBBLE_USE, self.select_index - 1, 0, 0)
	end
end

function BubbleView:GetMaxCellNum()
	return #self.bubble_data or 0
end

function BubbleView:RefreshCellList(cell, data_index)
	data_index = data_index + 1

	local bubble_cell = self.cell_list[cell]
	if bubble_cell == nil then
		bubble_cell = BubbleCell.New(cell.gameObject)
		bubble_cell.root_node.toggle.group = self.bubble_list.toggle_group
		bubble_cell.bubble_view = self
		self.cell_list[cell] = bubble_cell
	end

	bubble_cell:SetIndex(data_index)
	bubble_cell:SetData(self.bubble_data[data_index])
end

-- 气泡框总属性
function BubbleView:OnClickAtrr()
	local attr_data = CoolChatData.Instance:GetBubbleAttribute()
	TipsCtrl.Instance:ShowAttrView(attr_data)
end

function BubbleView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(8)
end

function BubbleView:OnClickButton()
	if self.select_index <= 0 then return end
	-- local select_data = CoolChatData.Instance:GetBubbleDataByIndex(self.select_index)
	-- local seq = CoolChatData.Instance:GetSeqByIndex(self.select_index)
	-- local select_seq = CoolChatData.Instance:GetSelectSeq()
	-- if seq - 1 == select_seq then
	-- 	CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_BUBBLE_USE, -1, 0, 0)
	-- elseif select_data.is_activate then
	-- 	CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_BUBBLE_USE, self.select_index - 1, 0, 0)
	-- else
	-- 	CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_BUBBLE_UP_LEVEL, self.select_index - 1, 0, 0)
	-- end
	CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_BUBBLE_UP_LEVEL, self.select_index - 1, 0, 0)
end

function BubbleView:SetBubbleName()
	local select_data = CoolChatData.Instance:GetBubbleDataByIndex(self.select_index)
	local name = select_data.name
	local bubble_level = self.bubble_data[self.select_index].level or 0
	name = "LV:" .. bubble_level .. name
	self.bubble_name:SetValue(name)
end

function BubbleView:ChangeAni()
	local index = self.select_index
	local PrefabName = "BubbleChat" .. index
	PrefabPool.Instance:Load(AssetID("uis/chatres/bubbleres/" .. "bubble" .. index .. "_prefab", PrefabName), function(prefab)
		if prefab and self.ani_obj and self.ani_obj.transform then
			local obj = GameObject.Instantiate(prefab)
			local transform = obj.transform
			for i = 0, self.ani_obj.transform.childCount - 1 do
				local child = self.ani_obj.transform:GetChild(i)
				if child then
					GameObject.Destroy(child.gameObject)
				end
			end
			transform:SetParent(self.ani_obj.transform, false)

			PrefabPool.Instance:Free(prefab)
		end
	end)
end

function BubbleView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function BubbleView:GetSelectIndex()
	return self.select_index
end

function BubbleView:ChangeNeedItemText()
	local select_data = CoolChatData.Instance:GetBubbleDataByIndex(self.select_index)
	local item_data = select_data.item1
end

function BubbleView:ChangeButtonName()
	if self.select_index <= 0 then return end
	local select_data = CoolChatData.Instance:GetBubbleDataByIndex(self.select_index)
	local seq = CoolChatData.Instance:GetSeqByIndex(self.select_index)
	local select_seq = CoolChatData.Instance:GetSelectSeq()
	-- if seq - 1 == select_seq then
	-- 	self.button_text:SetValue(Language.ChatWin.BubbleCancelSelect)
	-- elseif select_data.is_activate then
	-- 	self.button_text:SetValue(Language.ChatWin.BubbleSelect)
	-- else
	-- 	self.button_text:SetValue(Language.ChatWin.BubbleActive)
	-- end

	if self.btn_choose_name ~= nil then
		if self.btn_choose_enable ~= nil then
			self.btn_choose_enable:SetValue(select_data.is_activate)
		end

		if seq - 1 == select_seq then
			self.btn_choose_name:SetValue(Language.ChatWin.BubbleCancelSelect)
		elseif select_data.is_activate then
			self.btn_choose_name:SetValue(Language.ChatWin.BubbleSelect)
		else
			self.btn_choose_name:SetValue(Language.ChatWin.BubbleNoActive)
		end
	end

	local max_level = CoolChatData.Instance:GetBubbleMaxLevel(seq) or 0

	if self.button_text ~= nil then
		local str = Language.ChatWin.BubbleActive
		if select_data.level >= max_level then
			str = Language.ChatWin.BubbleMaxLevel
		end
		self.button_text:SetValue(str)
	end

	if self.touch_enable ~= nil then
		self.touch_enable:SetValue(not (select_data.level >= max_level))
	end

	if self.is_activate ~= nil then
		self.is_activate:SetValue(select_data.level >= max_level)
	end
end

function BubbleView:FlushBubbleView(param)
	if param then
		self:SetSelectIndex(param.index)
	end
	self.bubble_data = CoolChatData.Instance:GetBubbleInfo()
	if self.bubble_list.scroller.isActiveAndEnabled then
		self.bubble_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:ChangeAni()
	self:SetBubbleName()
	self:ChangeButtonName()
	self:FlushItem()
	self:FlushBubbleAttr()
end

function BubbleView:FlushBubbleAttr()
	local cur_attr, total_attr = CoolChatData.Instance:GetBubbleAllAttr(self.select_index)
	self.hp:SetValue(cur_attr.maxhp)
	self.gongji:SetValue(cur_attr.gongji)
	self.fangyu:SetValue(cur_attr.fangyu)
	self.rise_hp:SetValue(total_attr.maxhp)
	self.rise_gongji:SetValue(total_attr.gongji)
	self.rise_fangyu:SetValue(total_attr.fangyu)
	local capability = CommonDataManager.GetCapabilityCalculation(cur_attr) or 0
	self.capability:SetValue(capability)
end

function BubbleView:FlushItem()
	local bubble_level = self.bubble_data[self.select_index].level or 0
	local cfg = CoolChatData.Instance:GetBubbleCfgByLevel(self.select_index, bubble_level)
	if cfg then
		local item = TableCopy(cfg.common_item)
		if item.item_id > 0 then
			self.item_cell[1].obj:SetActive(true)
			item.num = 1
			self.item_cell[1].cell:SetData(item)
			local need_num = cfg.common_item.num or 0
			local has_num = ItemData.Instance:GetItemNumInBagById(cfg.common_item.item_id) or 0
			if has_num < need_num then
				self.item_number1:SetValue(ToColorStr(has_num, TEXT_COLOR.RED) .. "/" .. need_num)
			else
				self.item_number1:SetValue(has_num .. "/" .. need_num)
			end
		else
			self.item_cell[1].obj:SetActive(false)
		end
		local prof = Scene.Instance:GetMainRole().vo.prof
		local prof_item = TableCopy(cfg.prof_one_item)
		if prof == 2 then
			prof_item = TableCopy(cfg.prof_two_item)
		elseif prof == 3 then
			prof_item = TableCopy(cfg.prof_three_item)
		elseif prof == 4 then
			prof_item = TableCopy(cfg.prof_four_item)
		end
		need_num = prof_item.num or 0
		has_num = ItemData.Instance:GetItemNumInBagById(prof_item.item_id) or 0
		if has_num < need_num then
			self.item_number2:SetValue(ToColorStr(has_num, TEXT_COLOR.RED) .. "/" .. need_num)
		else
			self.item_number2:SetValue(has_num .. "/" .. need_num)
		end
		prof_item.num = 1
		self.item_cell[2].cell:SetData(prof_item)
		if cfg.is_need_prof_item == 0 then
			self.item_cell[2].obj:SetActive(false)
		else
			self.item_cell[2].obj:SetActive(true)
		end
	end
end

-----------------------------BubbleCell---------------------------------------------
BubbleCell = BubbleCell or BaseClass(BaseCell)
function BubbleCell:__init()
	--获取变量
	self.item_name = self:FindVariable("ItemName")
	self.icon_image = self:FindVariable("IconImage")
	self.is_select = self:FindVariable("IsSelect")
	self.is_activate = self:FindVariable("IsActivate")
	self.can_activate = self:FindVariable("CanActivate")
	self.limit_level = self:FindVariable("LimitLevel")

	--获取UI
	self.icon = self:FindObj("Icon")

	--监听事件
	self:ListenEvent("ClickItem",BindTool.Bind(self.ClickItem, self))
end

function BubbleCell:__delete()
	self.item_name = nil
	self.icon_image = nil
	self.is_select = nil
	self.is_activate = nil
	self.can_activate = nil
	self.limit_level = nil
	self.icon = nil
end

function BubbleCell:OnFlush()
	if not next(self.data) then return end

	self.item_name:SetValue(self.data.name)

	local bubble, asset = ResPath.GetRightBubbleIcon(self.data.seq)
	self.icon_image:SetAsset(bubble, asset)

	self.is_select:SetValue((self.data.select_seq + 1) == self.data.seq)
	self.is_activate:SetValue(self.data.is_activate)
	self.limit_level:SetValue(string.format(Language.Chat.JiHuo, self.data.limit_level))

	self.can_activate:SetValue(false)
	if self.data.level < CoolChatData.Instance:GetBubbleMaxLevel(self.data.seq) then
		local cfg = CoolChatData.Instance:GetBubbleCfgByLevel(self.data.seq, self.data.level)
		if cfg then
			local need_num1 = cfg.common_item.num or 0
			local has_num1 = ItemData.Instance:GetItemNumInBagById(cfg.common_item.item_id) or 0
			local prof = Scene.Instance:GetMainRole().vo.prof
			local prof_item = cfg.prof_one_item
			if prof == 2 then
				prof_item = cfg.prof_two_item
			elseif prof == 3 then
				prof_item = cfg.prof_three_item
			end
			local need_num2 = prof_item.num or 0
			local has_num2 = ItemData.Instance:GetItemNumInBagById(prof_item.item_id) or 0
			if has_num1 >= need_num1 or has_num2 >= need_num2 then
				self.can_activate:SetValue(true)
			end
		end
	end

	-- 刷新选中特效
	local select_index = self.bubble_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end
end

function BubbleCell:ClickItem()
	self.root_node.toggle.isOn = true
	local select_index = self.bubble_view:GetSelectIndex()
	if select_index == self.index then
		return
	end
	self.bubble_view:SetSelectIndex(self.index)
	self.bubble_view:ChangeAni()
	self.bubble_view:SetBubbleName()
	self.bubble_view:ChangeButtonName()
	self.bubble_view:FlushItem()
	self.bubble_view:FlushBubbleAttr()
end