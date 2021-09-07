SpiritImageView = SpiritImageView or BaseClass(BaseView)

function SpiritImageView:__init()
	self.ui_config = {"uis/views/spiritview", "SpiritImageView"}
end

function SpiritImageView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickUseIma", BindTool.Bind(self.OnClickUseIma, self))

	self.spirit_name = self:FindVariable("ZuoQiName")
	self.show_use_iamge_button = self:FindVariable("IsShowUseImaButton")
	self.show_use_image_sprite = self:FindVariable("IsShowUseImage")

	self.display = self:FindObj("Display")
	self.list_view = self:FindObj("ListView")
	self.use_image_button = self:FindObj("UseImageButton")

	self.image_cfg = nil
	self.info = {}
	self.cur_select_index = 1
	self.list_lenght = 0
	self.cell_list = {}
	self:Flush()
end

function SpiritImageView:ReleaseCallBack()
	if self.cell_list ~= nil then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = nil

	if self.item ~= nil then
		self.item:DeleteMe()
	end

	self.list_delegate = nil
	self.image_cfg = nil
	self.list_lenght = nil
	self.cur_select_index = nil
	self.info = {}
end

function SpiritImageView:CloseCallBack()
	self.from_view = nil
end

function SpiritImageView:SetFromView(from_view)
	self.from_view = from_view
end

function SpiritImageView:SetCallBack(callback)
	self.callback = callback
end

function SpiritImageView:OpenCallBack()
	if nil == self.from_view then return end
	if self.from_view == TabIndex.spirit_fazhen then
		self.image_cfg = SpiritData.Instance:GetSpiritFazhenImageCfg()
		self.info = SpiritData.Instance:GetSpiritFazhenInfo()
		self.cur_select_index = self.info.used_imageid
		self.list_lenght = SpiritData.Instance:GetMaxSpiritFazhenGrade()
	elseif self.from_view == TabIndex.spirit_halo then
		self.image_cfg = SpiritData.Instance:GetSpiritHaloImageCfg()
		self.info = SpiritData.Instance:GetSpiritHaloInfo()
		self.cur_select_index = self.info.used_imageid
		self.list_lenght = SpiritData.Instance:GetMaxSpiritHaloGrade()
	end
	if not self.list_delegate then
		self.list_delegate = self.list_view.list_simple_delegate
		self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_delegate.CellRefreshDel = BindTool.Bind(self.ImageRefreshCell, self)
	end
	self:Flush()
end

function SpiritImageView:OnClickUseIma()
	if not self.cur_select_index or self.cur_select_index <= 0 then
		return
	end
	if self.cur_select_index > self.info.grade then
		return
	end
	if self.from_view == TabIndex.spirit_halo then
		SpiritCtrl.Instance:SendSpiritHaloUseImage(self.cur_select_index)
	elseif self.from_view == TabIndex.spirit_fazhen then
		SpiritCtrl.Instance:SendSpiritFazhenUseImage(self.cur_select_index)
	end
	if self.callback then
		self.callback(self.cur_select_index)
	end
end

function SpiritImageView:GetNumberOfCells()
	return self.list_lenght
end

function SpiritImageView:ImageRefreshCell(cell, data_index)
	local image_cell = self.cell_list[cell]
	if image_cell == nil then
		image_cell = SpiritImageList.New(cell.gameObject)
		image_cell:SetToggleGroup(self.list_view.toggle_group)
		self.cell_list[cell] = image_cell
	end
	image_cell:SetData(self.image_cfg and self.image_cfg[data_index + 1] or {})
	image_cell:ListenClick(BindTool.Bind(self.OnClickItemCell, self, data_index + 1, self.image_cfg and self.image_cfg[data_index + 1] or {}, image_cell))
	image_cell:SetHighLight(self.cur_select_index == data_index + 1)
end

function SpiritImageView:OnClickItemCell(index, image_cfg, image_cell)
	self.cur_select_index = index
	image_cell:SetHighLight(self.cur_select_index == index)
	self:SetButtonState(image_cfg)
end

function SpiritImageView:SetButtonState(image_cfg)
	if not image_cfg then return end

	self.show_use_iamge_button:SetValue((self.info.used_imageid ~= self.cur_select_index) and (self.info.grade >= self.cur_select_index))
	self.show_use_image_sprite:SetValue(self.info.used_imageid == self.cur_select_index)
	self.spirit_name:SetValue(image_cfg.image_name)
end

function SpiritImageView:OnClickClose()
	self:Close()
end

function SpiritImageView:OnFlush(param_t)
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
		self:SetButtonState(self.image_cfg[self.cur_select_index])
	end
end



-- 精灵幻化形象列表
SpiritImageList = SpiritImageList or BaseClass(BaseRender)

function SpiritImageList:__init(instance)
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.show_fight_icon = self:FindVariable("ShowFight")
	self.show_help_icon = self:FindVariable("ShowHelp")
	self.show_red_point = self:FindVariable("ShowRedPoint")
end

function SpiritImageList:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end

function SpiritImageList:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function SpiritImageList:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function SpiritImageList:SetData(data)
	self.name:SetValue(data.image_name)
end