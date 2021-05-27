-----------------------------------------------------
-- 奖励列表
----------------------------------------------------
RecordListView = RecordListView or BaseClass()
function RecordListView:__init()
	self.list_view = nil
	self.items = {}
	self.data_list = {}

	self.width = 0
	self.is_pressed = false
	self.is_suoping = false
	self.is_step = true
end

function RecordListView:__delete()
	for i, v in ipairs(self.items) do
		v:DeleteMe()
	end
	self.items = {}
end

function RecordListView:GetView()
	return self.list_view
end

function RecordListView:Create(x, y, w, h)
	if nil ~= self.list_view then
		return
	end

	self.width = w
	self.list_view = XUI.CreateListView(x, y, w, h, ScrollDir.Vertical)
	self.list_view:setGravity(ListViewGravity.CenterHorizontal)
	self.list_view:setBounceEnabled(true)
	self.list_view:setMargin(5)
	self.list_view:setItemsInterval(5)

	self.list_view:addListEventListener(BindTool.Bind1(self.ListEventCallback, self))

	return self.list_view
end

-- 获得数据源
function RecordListView:GetDataList()
	return self.data_list
end

-- 设置数据源
function RecordListView:SetDataList(data_list)
	self.data_list = data_list
	self:RefreshItems()
end

function RecordListView:RefreshItems()
	if self.data_list == nil or self.list_view == nil then
		return
	end

	local item_count = #self.items
	local data_count = #self.data_list

	if item_count > data_count then					-- item太多 删掉
		for i = item_count, data_count + 1, -1 do
			self:RemoveAt(i)
		end
	elseif item_count < data_count then				-- item不足 创建
		local item = nil
		for i = item_count + 1, data_count do
			item = TurnItemRender.New(self, self.width)
			item:SetIsUseStepCalc(self.is_step)
			table.insert(self.items, item)
			self.list_view:pushBackItem(item:GetView())
		end
	end

	for i = data_count, 1, -1 do
		if self.items[i]:GetMsgId() ~= self.data_list[i].msg_id then
			self.items[i]:SetData(self.data_list[i])
		end
	end
	local p = self.list_view:getInnerPosition()

	if not self.is_pressed and not self.is_suoping and p.y >= 0 then
		self.list_view:refreshView()
		self.list_view:jumpToBottom()
		-- local connent = self.list_view:getInnerContainer()
		-- connent:setPositionY(connent:getPositionY() - 80)
	end
end

function RecordListView:SetIsSuoping(flage)
	self.is_step = not flage
	self.is_suoping = flage
end

function RecordListView:RemoveAt(index)
	if index <= 0 then
		return
	end

	local item = self:GetItemAt(index)
	if nil == item then
		return
	end

	self.list_view:removeItemByIndex(index - 1)
	item:DeleteMe()

	table.remove(self.items, index)
end

function RecordListView:GetItemAt(index)
	return self.items[index]
end

function RecordListView:GetAllItems()
	return self.items
end

function RecordListView:RemoveAllItem()
	for k, v in pairs(self.items) do
		v:DeleteMe()
	end
	self.items = {}
	self.list_view:removeAllItems()
end

function RecordListView:GetCount()
	return #self.items
end

-- 移动第一条到最后
function RecordListView:MoveFrontToLast(move_count)
	if move_count <= 0 then
		return
	end

	local item_count = #self.items
	if item_count <= 1 or move_count >= item_count then
		return
	end

	for i = 1, move_count do
		self.list_view:moveFrontToLast()

		local item = table.remove(self.items, 1)
		item:ClearContent()
		table.insert(self.items, item)
	end
end

function RecordListView:ListEventCallback(sender, event_type, index)
	if XuiListEventType.Began == event_type then
		self.is_pressed = true
	elseif XuiListEventType.Ended == event_type or XuiListEventType.Canceled == event_type then
		self.is_pressed = false
	elseif XuiListEventType.Refresh == event_type then

	end
end

function RecordListView:OnItemHeightChange()
	self.list_view:requestRefreshView()
end




TurnItemRender = TurnItemRender or BaseClass(BaseRender)
TurnItemRender.DefH = 20

function TurnItemRender:__init(list_view, w)
	self.list_view = list_view
	self.msg_id = 0
	self.layout_w = w
	self.layout_h = TurnItemRender.DefH
	self.max_text_w = w - 10

	self.text_channel = nil
	self.rich_content = nil
	self.record_item = nil 

	self.view:setContentWH(self.layout_w, TurnItemRender.DefH)
end

function TurnItemRender:__delete()
	if self.record_item then
		self.record_item:DeleteMe()
		self.record_item = nil
	end
end

function TurnItemRender:CreateChild()
	BaseRender.CreateChild(self)
	-- 内容
	self.rich_content = XUI.CreateRichText(20, 15, self.max_text_w, 10, false)
	self.rich_content:setAnchorPoint(0, 1)
	self.view:addChild(self.rich_content)
end

function TurnItemRender:ClearContent()
	if self.rich_content then
		self.rich_content:removeAllElements()
	end
end

function TurnItemRender:GetMsgId()
	return self.msg_id
end

function TurnItemRender:OnFlush()
	if self.msg_id == self.data.msg_id then
		return
	end
	self.msg_id = self.data.msg_id

	self:ParseContent()
	self:UpdataLayout()
end

function TurnItemRender:ParseContent()
	if self.data == nil then return end
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(33)
	if nil == cfg then return end
	local id = cfg.config.award_1[tonumber(self.data.index)].id
	local count = cfg.config.award_1[tonumber(self.data.index)].count

	if  ActivityBrilliantData.Instance == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(id)
	if nil == item_cfg then 
		return 
	end
	local color = string.format("%06x", item_cfg.color)
	local playername = Scene.Instance:GetMainRole():GetName()
	if playername == self.data.name then
		self.rolename_color = "CCCCCC"
	else
		self.rolename_color = "FFFF00"
	end

	local text_1 = ""
	local item_name = ""
	if cfg.config.award_1[tonumber(self.data.index)].percent then 
		item_name = string.format(Language.ActivityBrilliant.Text10, cfg.config.award_1[tonumber(self.data.index)].percent * 100 .. "%")
		count =  self.data.num
		text_1 = string.format(Language.ActivityBrilliant.Txt2, self.rolename_color, self.rolename_color, self.data.name, self.rolename_color, Language.ActivityBrilliant.Text11, color, item_name, id, Language.ActivityBrilliant.Text12, color,count)
	else
		text_1 = string.format(Language.ActivityBrilliant.Txt, self.rolename_color, self.rolename_color, self.data.name, self.rolename_color, Language.XunBao.Prefix, color, item_cfg.name, id, color, count)
	end
	RichTextUtil.ParseRichText(self.rich_content, text_1, 18)
	self.rich_content:refreshView()
end

-- 更新布局
function TurnItemRender:UpdataLayout()
	-- 计算大小
	local final_h = 0

	local content_render_size = self.rich_content:getInnerContainerSize()
	final_h = final_h + content_render_size.height

	if final_h < TurnItemRender.DefH then final_h = TurnItemRender.DefH end

	if self.layout_h ~= final_h then
		self.layout_h = final_h
		self.view:setContentWH(self.layout_w, self.layout_h)
		self.list_view:OnItemHeightChange()
	end

	self.rich_content:setPosition(10, self.layout_h)
end
