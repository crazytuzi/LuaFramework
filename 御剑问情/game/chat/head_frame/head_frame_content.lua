HeadFrameContent = HeadFrameContent or BaseClass(BaseRender)

function HeadFrameContent:__init()
	self.cell_list = {}
	self.select_index = 0

	self.frame_name = self:FindVariable("frame_name")
	self.cur_num = self:FindVariable("cur_num")
	self.need_num = self:FindVariable("need_num")
	self.raw_image_obj = self:FindObj("raw_image_obj")
	self.avatar = self:FindVariable("avatar")
	self.show_avatar = self:FindVariable("show_avatar")
	self.frame = self:FindVariable("frame")

	self.item_obj = self:FindObj("ItemCell1")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.item_obj)

	self.attr1 = self:FindObj("attr1")
	self.attr2 = self:FindObj("attr2")

	self.cur_attr = HeadFrameAttrGroup.New(self.attr1)
	self.next_attr = HeadFrameAttrGroup.New(self.attr2)
	self.level = self:FindVariable("level")
	self.is_max_level = self:FindVariable("is_max_level")

	--获取UI
	self.list = self:FindObj("list")

	local scroller_delegate = self.list.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMaxCellNum, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellList, self)
	self.list_data = HeadFrameData.Instance:GetListData()
	local use_seq = HeadFrameData.Instance:GetUseFrame()
	for i,v in ipairs(self.list_data) do
		if v.seq == use_seq then
			self.select_index = v.seq
			break
		end
	end
	self.list.scroller:ReloadData((self.select_index) / (HeadFrameData.Instance:GetMaxNum() - 1))
	-- self.list.scroller:ReloadData(1)
	self:ShowHl()

	--监听事件
	self:ListenEvent("OnClickAtrr",BindTool.Bind(self.OnClickAtrr, self))
	self:ListenEvent("ClickHelp",BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickButton",BindTool.Bind(self.OnClickButton, self))
end

function HeadFrameContent:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if self.cur_attr then
		self.cur_attr:DeleteMe()
		self.cur_attr = nil
	end

	if self.next_attr then
		self.next_attr:DeleteMe()
		self.next_attr = nil
	end

end

function HeadFrameContent:GetMaxCellNum()
	return HeadFrameData.Instance:GetMaxNum() or 0
end

function HeadFrameContent:RefreshCellList(cell, data_index)
	data_index = data_index + 1

	local head_frame_cell = self.cell_list[cell]
	if head_frame_cell == nil then
		head_frame_cell = HeadFrameCell.New(cell.gameObject)
		head_frame_cell.root_node.toggle.group = self.list.toggle_group
		head_frame_cell.parent_view = self
		self.cell_list[cell] = head_frame_cell
	end
	local data = HeadFrameData.Instance:GetListData()
	head_frame_cell:SetIndex(data_index)
	head_frame_cell:SetData(data[data_index])
	head_frame_cell:SetClickCallBack(BindTool.Bind(self.ClickCell, self))
	self:ShowHl()
end

function HeadFrameContent:OnClickAtrr()
	local attr_data = HeadFrameData.Instance:GetHeadFrameAttribute()
	TipsCtrl.Instance:ShowAttrView(attr_data)
end

function HeadFrameContent:OnClickHelp()
	-- tag
	TipsCtrl.Instance:ShowHelpTipView(10)
end

function HeadFrameContent:OnClickButton()
	CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_FRAME_UP_LEVEL, self.cur_data.seq)
end

-- tag
function HeadFrameContent:OpenCallBack(param)
	self:Flush()
end

function HeadFrameContent:ShowHl()
	for k,v in pairs(self.cell_list) do
		v:ShowHl(self.select_index)
	end
end

function HeadFrameContent:OnFlush()
	self:ConstructData()
	self:SetFlag()
	self:SetInfo()
end

function HeadFrameContent:ConstructData()
	self.cur_data = HeadFrameData.Instance:GetChooseData(self.select_index)
	local role = GameVoManager.Instance:GetMainRoleVo()
	CommonDataManager.NewSetAvatar(role.role_id, self.show_avatar, self.avatar, self.raw_image_obj, role.sex, role.prof, true)
end

function HeadFrameContent:SetFlag()
	self.is_max_level:SetValue(self.cur_data.level == self.cur_data.max_level)
end

function HeadFrameContent:SetInfo()
	self.item_cell:SetData({item_id = self.cur_data.item1.item_id})
	self.cur_num:SetValue(self.cur_data.cur_num)
	self.need_num:SetValue(self.cur_data.need_num)
	local cur_attr = HeadFrameData.Instance:GetAttrData(self.cur_data.level, self.cur_data.seq)
	self.cur_attr:SetData(cur_attr)
	local next_attr = HeadFrameData.Instance:GetAttrData(self.cur_data.level + 1, self.cur_data.seq)
	self.next_attr:SetData(next_attr)
	self.frame_name:SetValue(self.cur_data.name)
	self.frame:SetAsset(ResPath.GetHeadFrameIcon(self.cur_data.seq))
	self.level:SetValue(self.cur_data.level)

	self.list.scroller:RefreshAndReloadActiveCellViews(false)
end

function HeadFrameContent:ClickCell(data)
	if HeadFrameData.Instance:GetUseFrame() == data.seq and self.select_index == data.seq then
		CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_FRAME_USE, -1)
		self.select_index = data.seq
		self:ShowHl()
		self:Flush()
		return
	end
	
	if data.level > 0 and HeadFrameData.Instance:GetUseFrame() ~= data.seq then
		CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_FRAME_USE, data.seq)
	end
	self.select_index = data.seq
	self:ShowHl()
	self:Flush()
end


-----------------------------HeadFrameCell---------------------------------------------
HeadFrameCell = HeadFrameCell or BaseClass(BaseCell)
function HeadFrameCell:__init()
	self.level = self:FindVariable("level")
	self.name = self:FindVariable("name")
	self.image = self:FindVariable("image")
	self.is_use = self:FindVariable("is_use")
	self.is_select = self:FindVariable("is_select")
	self.is_can_up = self:FindVariable("is_can_up")

	self.toggle = self:FindObj("toggle").toggle

	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClick, self))
end

function HeadFrameCell:__delete()
	if self.parent_view then
		self.parent_view = nil
	end
end

function HeadFrameCell:OnFlush()
	self:SetInfo()
end

function HeadFrameCell:SetInfo()
	self.level:SetValue(self.data.level)
	self.name:SetValue(self.data.name)
	local bundle, asset = ResPath.GetItemIcon(self.data.image)
	self.image:SetAsset(bundle, asset)
	self.is_can_up:SetValue(self.data.is_can_up)
	local is_use = HeadFrameData.Instance:GetUseFrame()
	self.is_use:SetValue(is_use == self.data.seq)
end

function HeadFrameCell:ShowHl(select_index)
	self.toggle.isOn = select_index == self.index - 1
end

function HeadFrameCell:OnClick()
	if self.click_callback then
		self.click_callback(self.data)
	end
end

function HeadFrameCell:SetClickCallBack(func)
	self.click_callback = func
end


HeadFrameAttrGroup = HeadFrameAttrGroup or BaseClass(BaseRender)

function HeadFrameAttrGroup:__init()
	self.power = self:FindVariable("Power")
	self.level = self:FindVariable("Level")

	self.attrs = {}
	for i=1,3 do
		self.attrs[i] = HeadFrameAttr.New(self:FindObj("attr_" .. i))
	end
end

function HeadFrameAttrGroup:__delete()
	
end

function HeadFrameAttrGroup:SetData(data)
	if data == nil then
		return
	end
	self.level:SetValue(data.level)
	self.power:SetValue(data.power)
	for i=1,3 do
		self.attrs[i]:SetData(data.attrs[i])
		self.attrs[i]:SetImage(i)
	end
end

HeadFrameAttr = HeadFrameAttr or BaseClass(BaseRender)

function HeadFrameAttr:__init()
	self.attr_value = self:FindVariable("AttrValue")
	self.att_image = self:FindVariable("att_image")
end

function HeadFrameAttr:__delete()
	
end

function HeadFrameAttr:SetData(value)
	if value == nil then
		return
	end
	self.attr_value:SetValue(value)
end

function HeadFrameAttr:SetImage(i)
	local bundle, asset = ResPath.GetBaseAttrIcon(GameEnum.AttrList[i])
	self.att_image:SetAsset(bundle, asset)
end