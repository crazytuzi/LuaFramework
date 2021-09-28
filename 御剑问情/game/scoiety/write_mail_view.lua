local BAG_MAX_GRID_NUM = 144
local BAG_ROW = 4
local BAG_COLUMN = 4
local PAGE_COUNT = 9

WriteMailView = WriteMailView or BaseClass(BaseRender)
function WriteMailView:__init()
	self.send_item_list = {}
	self.set_item_num = 0
	self.select_gray_list = {}
	self.select_index = -1			-- 记录已选择格子位置
	self.current_page = 0
	self.player_name = ""

	self:ListenEvent("ClickSend",BindTool.Bind(self.ClickSend, self))
	self:ListenEvent("ClickReturn",BindTool.Bind(self.ClickReturn, self))
	self:ListenEvent("ClickFriendList",BindTool.Bind(self.ClickFriendList, self))

	-- 获取控件
	self.cell_list = {}
	self.bag_list_view = self:FindObj("ListView")
	self.name_input = self:FindObj("NameInput")
	self.name_text = self:FindVariable("PlayerName")
	self.content = self:FindObj("Content")
	for i = 1, PAGE_COUNT do
		self["Page" .. i] = self:FindObj("PageToggle" .. i)
		self["Page" .. i].toggle:AddValueChangedListener(BindTool.Bind(self.ChangePage, self, i - 1))

		self:ListenEvent("Page" .. i, BindTool.Bind(self.BagJumpPage, self, i))
	end

	local list_delegate = self.bag_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	for i = 1, 3 do
		local send_item = ItemCell.New()
		send_item:SetInstanceParent(self:FindObj("Item" .. i))
		send_item:ListenClick(BindTool.Bind(self.SendItemClick, self, send_item))
		send_item:SetData(nil)
		send_item:ShowHighLight(false)
		table.insert(self.send_item_list, send_item)
	end
	self.name_text:SetValue(Language.Society.SelectName)
end

function WriteMailView:__delete()
	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	for k, v in ipairs(self.send_item_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.send_item_list = {}
end

function WriteMailView:ChangePage(page, isOn)
	if isOn then
		self.current_page = page
	end
end

function WriteMailView:ClearSendItemList()
	if self.send_item_list then
		for k, v in ipairs(self.send_item_list) do
			if v then
				v:SetData(nil)
			end
		end
	end
end

function WriteMailView:CloseWriteMailView()
	ScoietyData.Instance:SetSendName("")
	ScoietyCtrl.Instance:ShowMailView()

	self.set_item_num = 0
	self:ClearSendItemList()

	if self.select_gray_list then
		for _, v in ipairs(self.select_gray_list) do
			if next(v) then
				v.group:SetGrayVisible(v.index, false)
				v.group:SetIconGrayScale(v.index, false)
			end
		end
	end

	self.select_gray_list = {}

	if not IsNil(self.name_input.gameObject) then
		self.name_input.input_field.text = ""
	end

	if not IsNil(self.content.gameObject) then
		self.content.input_field.text = ""
	end
	self.select_index = -1
	self.name_text:SetValue(Language.Society.SelectName)
	self.player_name = ""
end

function WriteMailView:SendItemClick(send_item)
	local data = send_item:GetData()
	if next(data) then
		send_item:SetData(nil)
		for k, v in ipairs(self.select_gray_list) do
			local group = v.group
			local index = v.index
			if data.index == v.data_index then
				if v.page == self.current_page then
					group:SetGrayVisible(index, false)
					group:SetIconGrayScale(index, false)
				end
				table.remove(self.select_gray_list, k)
				break
			end
		end
		self.set_item_num = self.set_item_num - 1
	end
end

function WriteMailView:ClickSend()
	if self.player_name == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NotChooseUser)
		return
	end

	local content = self.content.input_field.text
	if content == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.MailNotEmpty)
		return
	end

	local uid = ScoietyData.Instance:GetFriendIdByName(self.player_name)
	if not uid then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NotFriendDes)
		return
	end

	local my_name = GameVoManager.Instance:GetMainRoleVo().name

	local param_t = {}
	param_t.recver_uid = uid
	param_t.coin = 0
	param_t.item_count = #self.select_gray_list
	param_t.item_knapindex_list = {0, 0, 0}
	param_t.item_comsume_num = {0, 0, 0}
	for k, v in ipairs(self.select_gray_list) do
		param_t.item_knapindex_list[k] = v.data_index
		param_t.item_comsume_num[k] = v.num
	end
	param_t.subject = my_name
	param_t.contenttxt = content
	ScoietyCtrl.Instance:MailSendReq(param_t)
	self:CloseWriteMailView()
	--先排序再刷新
	ScoietyData.Instance:SortMailIndexList()
	ScoietyCtrl.Instance.scoiety_view:FlushMailLeft()
end

function WriteMailView:ClickReturn()
	self:CloseWriteMailView()
	--先排序再刷新
	ScoietyData.Instance:SortMailIndexList()
	ScoietyCtrl.Instance.scoiety_view:FlushMailLeft()
end

function WriteMailView:SetFriendName(param)
	local role_name = Language.Society.SelectName
	if type(param) == "string" and param ~= "" then
		role_name = param
	elseif type(param) == "table" then
		role_name = param.gamename
	end
	self.player_name = role_name
	self.name_text:SetValue(self.player_name)
end

function WriteMailView:ClickFriendList()
	ScoietyCtrl.Instance:ShowFriendListView(BindTool.Bind(self.SetFriendName, self))
end

function WriteMailView:SetActive(value)
	self.root_node:SetActive(value)
	if value then
		self.bag_list_view.scroller:ReloadData(0)
		self.Page1.toggle.isOn = true
	end
end

function WriteMailView:SetSelectData(data, num)
	self.set_item_num = self.set_item_num + 1
	data.num = num
	for k, v in pairs(self.send_item_list) do
		local temp_data = v:GetData()
		if not next(temp_data) then
			v:SetData(data)
			break
		end
	end
end

function WriteMailView:SetSelectGrayItemList(group, index, data_index, page, num)
	local tbl = {["group"] = group, ["index"] = index, ["data_index"] = data_index, ["page"] = page, ["num"] = num}
	table.insert(self.select_gray_list, tbl)
end

-----------------------------------
-- ListView逻辑
-----------------------------------
function WriteMailView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM / BAG_ROW
end

function WriteMailView:BagRefreshCell(cell, data_index, cell_index)
	-- 构造Cell对象
	local group = self.cell_list[cell]
	if group == nil then
		group = MailItemCellGroup.New(cell.gameObject)
		group.mail_view = self
		group:SetToggleGroup(self.bag_list_view.toggle_group)
		self.cell_list[cell] = group
	end

	-- 计算索引
	local page = math.floor(data_index / BAG_COLUMN)
	local column = data_index - page * BAG_COLUMN
	local grid_count = BAG_COLUMN * BAG_ROW
	for i = 1, BAG_ROW do
		local index = (i - 1) * BAG_COLUMN  + column + (page * grid_count)

		-- 获取数据信息
		local data = nil
		data = ItemData.Instance:GetGridData(index)
		group:SetInteractable(i, data ~= nil)
		data = data or {}
		data.locked = index >= ItemData.Instance:GetMaxKnapsackValidNum()
		data.index = index
		group:SetData(i, data)
		if 1 == data.is_bind then
			group:SetGrayVisible(i, true)
			group:SetIconGrayScale(i, true)
			group:ShowQuality(i, false)
		else
			group:SetGrayVisible(i, false)
			group:SetIconGrayScale(i, false)
		end

		for k, v in ipairs(self.select_gray_list) do
			if v.data_index == data.index then
				group:SetGrayVisible(i, true)
				break
			end
		end
		group:ListenClick(i, BindTool.Bind(self.HandleBagOnClick, self, data, group, i, page))
	end
end

--点击格子事件
function WriteMailView:HandleBagOnClick(data, group, group_index, page)
	if self.select_index ~= data.index then
		self.select_index = data.index
	end
	group:ShowHighLight(group_index, false)
	if data.is_bind == 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.LuckItemCanNotTrade)
		return
	end

	if data.locked then
		print("格子已锁")
		return
	end

	if not data.item_id then
		return
	end

	for k, v in ipairs(self.select_gray_list) do
		if v.data_index == data.index then
			return
		end
	end

	if self.set_item_num >= 3 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.MailItemFull)
		return
	end

	group:ShowHighLight(group_index, true)
	group:SetHighLight(group_index, false)
	local function open_func(num)
		group:ShowHighLight(group_index, false)
		num = tonumber(num)
		if num > data.num then
			num = data.num
		end
		if num > 0 then
			group:SetGrayVisible(group_index, true)
			self:SetSelectGrayItemList(group, group_index, data.index, page, num)
			self:SetSelectData(TableCopy(data), num)
		end
	end

	local function canel_func()
		group:ShowHighLight(group_index, false)
	end

	if data.num and data.num >= 1 then
		if data.num == 1 then
			open_func(1)
			return
		end
		TipsCtrl.Instance:OpenCommonInputView("1", open_func, canel_func, data.num)
	end
end

function WriteMailView:BagJumpPage(page)
	local jump_index = (page - 1) * BAG_COLUMN
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.bag_list_view.scroller.snapTweenType
	local scrollerTweenTime = 0.2
	local scroll_complete = function()
		self.current_page = page
	end
	self.bag_list_view.scroller:JumpToDataIndex(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

MailItemCellGroup = MailItemCellGroup or BaseClass(BaseRender)

function MailItemCellGroup:__init()
	self.cells = {}
	for i = 1, BAG_ROW do
		local cell = ItemCell.New(self:FindObj("Item" .. i))
		table.insert(self.cells, cell)
	end
end

function MailItemCellGroup:__delete()
	for k, v in ipairs(self.cells) do
		if v then
			v:DeleteMe()
		end
	end
	self.cells = {}
end

function MailItemCellGroup:SetData(i, data)
	self.cells[i]:SetData(data)

	if self.cells[i].root_node.toggle.isOn and data.index ~= self.mail_view.select_index then
		self.cells[i]:SetHighLight(false)
	elseif not self.cells[i].root_node.toggle.isOn and data.index == self.mail_view.select_index then
		self.cells[i]:SetHighLight(true)
	end

	-- --暂时还有bug(主要是翻页时正确的置灰显示)
	-- for k, v in ipairs(self.mail_view.select_gray_list) do
	-- 	if v.data_index == data.index then
	-- 		self:SetGrayVisible(i, true)
	-- 	end
	-- 	if v.group == self and v.data_index ~= data.index then
	-- 		self:SetGrayVisible(i, false)
	-- 	end
	-- end
end

function MailItemCellGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function MailItemCellGroup:SetToggleGroup(toggle_group)
	for k, v in ipairs(self.cells) do
		v:SetToggleGroup(toggle_group)
	end
end

function MailItemCellGroup:SetGrayVisible(i, value)
	self.cells[i]:SetIconGrayVisible(value)
end

function MailItemCellGroup:SetIconGrayScale(i, value)
	self.cells[i]:SetIconGrayScale(value)
end

function MailItemCellGroup:GetIsGray(i)
	return self.cells[i]:IsGray()
end

function MailItemCellGroup:GetData(i)
	return self.cells[i]:GetData()
end

function MailItemCellGroup:SetHighLight(i, enable)
	self.cells[i]:SetHighLight(enable)
end

function MailItemCellGroup:SetInteractable(i, enable)
	self.cells[i]:SetInteractable(enable)
end

function MailItemCellGroup:ShowHighLight(i, enable)
	self.cells[i]:ShowHighLight(enable)
end

function MailItemCellGroup:ShowQuality(i, enable)
	self.cells[i]:OnlyShowQuality(enable)
end
