GoldTextView = GoldTextView or BaseClass(BaseRender)

function GoldTextView:__init()
	self.item_list = {}
	for i = 1, 8 do
		local item_cell = GoldItem.New(self:FindObj("Item" .. i))
		item_cell:SetHandle(self)
		item_cell:SetIndex(i - 1)
		item_cell:SetData(nil)
		table.insert(self.item_list, item_cell)
	end

	self.item_cell = {}
	for i = 1, 2 do
		self.item_cell[i] = {}
		self.item_cell[i].obj = self:FindObj("ItemCell" .. i)
		self.item_cell[i].cell = ItemCell.New()
		self.item_cell[i].cell:SetInstanceParent(self.item_cell[i].obj)
	end

	self:ListenEvent("ClickAttr",BindTool.Bind(self.ClickAttr, self))
	self:ListenEvent("ClickBtn",BindTool.Bind(self.ClickBtn, self))
	self:ListenEvent("ClickHelp",BindTool.Bind(self.OnClickHelp, self))

	self.capability = self:FindVariable("Capability")
	self.gray = self:FindVariable("Gray")
	self.level = self:FindVariable("Level")
	self.item_number1 = self:FindVariable("ItemNum1")
	self.item_number2 = self:FindVariable("ItemNum2")
	self.is_max_level = self:FindVariable("IsMaxLevel")
	self.button_name = self:FindVariable("ButtonName")

	self.cur_tuhaojin_color = 0
	self.max_tuhaojin_color = 0
	self.total_attr = CommonStruct.Attribute()
end

function GoldTextView:__delete()
	for _, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	for k,v in pairs(self.item_cell) do
		if v.cell then
			v.cell:DeleteMe()
			v.cell = nil
		end
	end
end

function GoldTextView:ClickAttr()
	TipsCtrl.Instance:ShowAttrView(self.total_attr)
end

function GoldTextView:ClickBtn()
	CoolChatCtrl.Instance:SendTuhaojinUpLevelReq()
end

function GoldTextView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(7)
end

function GoldTextView:FlushGoldTextView()
	local tuhaojin_level = CoolChatData.Instance:GetTuHaoJinLevel() or 0
	local max_level = CoolChatData.Instance:GetTuHaoJinMaxLevel() or 0
	if max_level <= tuhaojin_level then
		self.is_max_level:SetValue(true)
		self.button_name:SetValue(Language.Common.YiManJi)
	else
		self.is_max_level:SetValue(false)
		self.button_name:SetValue(Language.Common.UpGrade)
	end
	self.cur_tuhaojin_color = CoolChatData.Instance:GetTuHaoJinCurColor() or 0
	self.max_tuhaojin_color = CoolChatData.Instance:GetTuHaoJinMaxColor() or 0
	self.level:SetValue(tuhaojin_level)
	self.total_attr = CoolChatData.Instance:GetJingHuaAllAttr()
	local capability = CommonDataManager.GetCapability(self.total_attr) or 0
	self.capability:SetValue(capability)
	local list = CoolChatData.Instance:GetAllJingHuaItemCfg()
	local flag = false
	if list then
		for k, v in ipairs(list) do
			if self.item_list[k] then
				self.item_list[k]:SetData(v)
			end
		end
	end

	local tuhaojin_cfg = CoolChatData.Instance:GetGoldTextConfig()
	if tuhaojin_cfg then
		local level_cfg = tuhaojin_cfg.level_cfg
		if level_cfg then
			local cfg = level_cfg[tuhaojin_level + 1]
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
	end
end


GoldItem = GoldItem or BaseClass(BaseCell)

function GoldItem:__init()
	self.icon = self:FindVariable("Icon")
	self.gray = self:FindVariable("Gray")
	self.num_visible = self:FindVariable("NumIsVisible")
	self.lev = self:FindVariable("Num")
	self.show_high_light = self:FindVariable("ShowHighLight")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.limit_level = self:FindVariable("LimitLevel")
	self.show_level = self:FindVariable("ShowLevel")

	self.is_active = false

	self.show_red_point:SetValue(false)
	self.num_visible:SetValue(false)
	self:ListenEvent("Click",BindTool.Bind(self.Click, self))
end

function GoldItem:__delete()

end

function GoldItem:Click()
	if not self.is_active then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.GoldTextNotActive)
		return
	end
	CoolChatCtrl.Instance:SendUseTuHaoJinReq(self.index)
end

function GoldItem:OnFlush()
	if not self.data or not next(self.data) then return end
	-- local level = self.data.level
	-- local num = ItemData.Instance:GetItemNumInBagById(self.data.item_id) or 0
	-- if level < 50 and num > 0 then
	-- 	self.show_red_point:SetValue(true)
	-- else
	-- 	self.show_red_point:SetValue(false)
	-- end
	-- if level > 0 then
	-- 	self.gray:SetValue(false)
	-- 	self.num_visible:SetValue(true)
	-- 	self.lev:SetValue(level)
	-- else
	-- 	self.gray:SetValue(true)
	-- 	self.num_visible:SetValue(false)
	-- end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if not item_cfg then return end
	local bubble, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	self.icon:SetAsset(bubble, asset)
	self.limit_level:SetValue(string.format(Language.Chat.KaiFang, self.data.limit_level))
	self.show_level:SetValue(true)
	if self.handele then
		if self.handele.cur_tuhaojin_color == self.index then
			self.show_high_light:SetValue(true)
			self.limit_level:SetValue(ToColorStr(Language.Common.HasUsed, TEXT_COLOR.GREEN))
		else
			self.show_high_light:SetValue(false)
		end
		if self.handele.max_tuhaojin_color < self.index then
			self.gray:SetValue(true)
			self.is_active = false
		else
			self.gray:SetValue(false)
			self.is_active = true
			if self.handele.cur_tuhaojin_color ~= self.index then
				self.show_level:SetValue(false)
			end
		end
	end
end

function GoldItem:SetHandle(handele)
	self.handele = handele
end

function GoldItem:SetIndex(index)
	self.index = index
end