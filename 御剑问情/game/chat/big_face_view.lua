BigFaceView = BigFaceView or BaseClass(BaseRender)

function BigFaceView:__init()
	self.capability = self:FindVariable("Capability")
	self.scroller = self:FindObj("Scroller")
	self.cell_list = {}
	self:ListenEvent("ClickAtrr",
		BindTool.Bind(self.ClickAtrr, self))
	self:ListenEvent("ClickLevelUp",
		BindTool.Bind(self.ClickLevelUp, self))
	self:ListenEvent("ClickHelp",BindTool.Bind(self.OnClickHelp, self))
	self.item_cell = {}
	self.data_list = {}
	for i = 1, 2 do
		self.item_cell[i] = {}
		self.item_cell[i].obj = self:FindObj("ItemCell" .. i)
		self.item_cell[i].cell = ItemCell.New()
		self.item_cell[i].cell:SetInstanceParent(self.item_cell[i].obj)
	end
	self.level = self:FindVariable("Level")
	self.item_number1 = self:FindVariable("ItemNum1")
	self.item_number2 = self:FindVariable("ItemNum2")
	self.is_max_level = self:FindVariable("IsMaxLevel")
	self.button_name = self:FindVariable("ButtonName")

	self.scroller_is_load = false

	local active_group = CoolChatData.Instance:GetActiveGroupByLevel() or {}
	self.last_has_active_num = #active_group

	self.total_attr = CommonStruct.Attribute()
	self:InitScroller()
	self:FlushBigFaceView()
end

function BigFaceView:__delete()
	for k,v in pairs(self.item_cell) do
		if v.cell then
			v.cell:DeleteMe()
			v.cell = nil
		end
	end

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self:RemoveDelayTime()
end

function BigFaceView:OpenCallBack()
	self:JumpTo()
end

function BigFaceView:InitScroller()
	local scroller_delegate = self.scroller.page_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMaxCellNum, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellList, self)

	self.scroller.list_view:Reload()
end

function BigFaceView:GetMaxCellNum()
	local big_face_cfg = CoolChatData.Instance:GetBigFaceConfig()
	if big_face_cfg then
		local group_cfg = big_face_cfg.group
		return #group_cfg or 0
	end
	return 0
end

function BigFaceView:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function BigFaceView:RefreshCellList(index, cellObj)
	self.scroller_is_load = true
	if self.load_call_back then
		self:RemoveDelayTime()
		self.delay_time = GlobalTimerQuest:AddDelayTimer(self.load_call_back, 0.01)
		self.load_call_back = nil
	end
	local big_face_cell = self.cell_list[cellObj]
	if big_face_cell == nil then
		big_face_cell = BigFaceCellView.New(cellObj)
		self.cell_list[cellObj] = big_face_cell
	end
	local temp = self.data_list[index + 1]
	local data = {}
	if temp then
		for k,v in pairs(temp) do
			if k ~= "limit_level" then
				table.insert(data, k)
			end
		end
	end
	big_face_cell:SetLevel(temp.limit_level)
	big_face_cell:SetData(data)
end

function BigFaceView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(6)
end

function BigFaceView:FlushBigFaceView()
	local big_face_level = CoolChatData.Instance:GetBigFaceLevel() or 0
	local max_level = CoolChatData.Instance:GetBigFaceMaxLevel() or 0
	if max_level <= big_face_level then
		self.is_max_level:SetValue(true)
		self.button_name:SetValue(Language.Common.YiManJi)
	else
		self.is_max_level:SetValue(false)
		self.button_name:SetValue(Language.Common.UpGrade)
	end
	self.level:SetValue(big_face_level)
	self.total_attr = CoolChatData.Instance:GetBigFaceTotalAttr()
	local capability = CommonDataManager.GetCapability(self.total_attr) or 0
	self.capability:SetValue(capability)
	local big_face_cfg = CoolChatData.Instance:GetBigFaceConfig()
	if big_face_cfg then
		local level_cfg = big_face_cfg.level_cfg
		if level_cfg then
			local cfg = level_cfg[big_face_level + 1]
			if cfg then
				local item = TableCopy(cfg.common_item)
				if item.item_id > 0 then
					self.item_cell[1].obj:SetActive(true)
					item.num = 1
					self.item_cell[1].cell:SetData(item)
					local need_num = cfg.common_item.num or 0
					local has_num = ItemData.Instance:GetItemNumInBagById(cfg.common_item.item_id) or 0
					if has_num < need_num then
						self.item_number1:SetValue(ToColorStr(has_num, TEXT_COLOR.RED) .. " / " .. need_num)
					else
						self.item_number1:SetValue(ToColorStr(has_num, TEXT_COLOR.BLUE1) .. " / " .. need_num)
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
				end
				need_num = prof_item.num or 0
				has_num = ItemData.Instance:GetItemNumInBagById(prof_item.item_id) or 0
				if has_num < need_num then
					self.item_number2:SetValue(ToColorStr(has_num, TEXT_COLOR.RED) .. " / " .. need_num)
				else
					self.item_number2:SetValue(ToColorStr(has_num, TEXT_COLOR.BLUE1) .. " / " .. need_num)
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
		local group_cfg = big_face_cfg.group or {}
		local total_index = #group_cfg or 0
		self.data_list = {}
		local active_group = CoolChatData.Instance:GetActiveGroupByLevel() or {}
		local has_active_num = #active_group
		if has_active_num > self.last_has_active_num then
			self.last_has_active_num = has_active_num
			self:JumpTo()
		end
		for i = 1, total_index do
			self.data_list[i] = CoolChatData.Instance:GetBigFaceByGroupId(i)
			self.data_list[i].limit_level = CoolChatData.Instance:GetBigFaceActiveLevel(i) or 0
		end
	end
	for k,v in pairs(self.cell_list) do
		v:FlushActive()
	end
end

function BigFaceView:ClickAtrr()
	TipsCtrl.Instance:ShowAttrView(self.total_attr)
end

function BigFaceView:ClickLevelUp()
	CoolChatCtrl.Instance:SendBigChatFaceUpLevelReq()
end

function BigFaceView:JumpTo()
	local big_face_cfg = CoolChatData.Instance:GetBigFaceConfig()
	local big_face_level = CoolChatData.Instance:GetBigFaceLevel() or 0
	if big_face_cfg then
		local group_cfg = big_face_cfg.group or {}
		local total_index = #group_cfg or 0
		local cur_index = 0
		for i = 1, total_index do
			local limit_level = CoolChatData.Instance:GetBigFaceActiveLevel(i) or 0
			if limit_level > big_face_level then
				break
			end
			cur_index = i
		end
		if cur_index > 0 and total_index ~= 0 and cur_index ~= total_index then
			cur_index = cur_index - 1
			if cur_index > total_index - 3 then
				cur_index = total_index - 3
			end
			self:JumpToIndex(cur_index)
		else
			self:JumpToIndex(0)
		end
	end
end

function BigFaceView:JumpToIndex(index)
	self.scroller.list_view:JumpToIndex(index)
end

--------------------------------------------------------------BigFaceCellView-------------------------------------------------------------
BigFaceCellView = BigFaceCellView or BaseClass(BaseCell)

function BigFaceCellView:__init()
	self.icon_cell = {}
	self.level = 0
	self.level_text = self:FindVariable("Level")
	self.cur_level = self:FindVariable("CurLevel")
	self.is_active = self:FindVariable("IsActive")
	for i = 1, 5 do
		self.icon_cell[i] = {}
		self.icon_cell[i].obj = self:FindObj("Icon" .. i)
		self.icon_cell[i].cell = BigFaceIconCell.New(self.icon_cell[i].obj)
	end
end

function BigFaceCellView:__delete()
	for i = 1, 5 do
		if self.icon_cell[i].cell then
			self.icon_cell[i].cell:DeleteMe()
			self.icon_cell[i].cell = nil
		end
	end
end

function BigFaceCellView:OnFlush()
	for i = 1, 5 do
		local data = self.data[i]
		if data then
			self.icon_cell[i].obj:SetActive(true)
			-- self.icon_cell[i].cell:SetGray(not CoolChatData.Instance:GetActiveStatusByIndex(data))
			self.icon_cell[i].cell:SetData(data)
		else
			self.icon_cell[i].obj:SetActive(false)
		end
	end
	self.level_text:SetValue(self.level)
	self:FlushActive()
end

function BigFaceCellView:FlushActive()
	local level = CoolChatData.Instance:GetBigFaceLevel() or 0
	if level >= self.level then
		self.is_active:SetValue(true)
	else
		self.is_active:SetValue(false)
	end
	local big_face_level = CoolChatData.Instance:GetBigFaceLevel() or 0
	big_face_level = big_face_level > self.level and self.level or big_face_level
	self.cur_level:SetValue(ToColorStr(big_face_level, big_face_level >= self.level and TEXT_COLOR.BLACK_1 or TEXT_COLOR.RED))
end

function BigFaceCellView:SetLevel(level)
	self.level = level
end