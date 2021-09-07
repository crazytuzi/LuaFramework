BeautyAttrTipView = BeautyAttrTipView or BaseClass(BaseView)

function BeautyAttrTipView:__init()
	self.ui_config = {"uis/views/beauty", "BeautyAttrTip"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)
	self.item_t = {}
end

function BeautyAttrTipView:LoadCallBack()
	self.fight_power = self:FindVariable("fight_power")
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))

	self.list_view = self:FindObj("ListView")

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function BeautyAttrTipView:ReleaseCallBack()
	for k,v in pairs(self.item_t) do
		if v ~= nil then
			v:DeleteMe()
		end
	end

	self.item_t = {}

	self.fight_power = nil
	self.list_view = nil
	self.attr_cfg = nil
	self.cap = nil
end

function BeautyAttrTipView:GetNumberOfCells()
	if self.attr_cfg == nil then
		return 0
	end

	return #self.attr_cfg
end

function BeautyAttrTipView:RefreshCell(cell, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = BeautyAttrRender.New(cell.gameObject, self)
		self.item_t[cell] = item
	end

	if self.attr_cfg ~= nil then
		item:SetData(self.attr_cfg[cell_index + 1] or {})
	end	
end

function BeautyAttrTipView:ShowIndexCallBack()
	local cfg, cap = BeautyData.Instance:GetBeautyAllCapAttr()
	self.cap = cap
	self.attr_cfg = CommonDataManager.GetAttrNameAndValueByClass(cfg, false)
	self:Flush()
end

function BeautyAttrTipView:OnFlush()
	if self.fight_power ~= nil then
		self.fight_power:SetValue(self.cap or 0)
	end

	if self.list_view ~= nil then
		self.list_view.scroller:ReloadData(0)
	end
end

function BeautyAttrTipView:OnCloseClick()
	self:Close()
end


----------------------------------------------------
BeautyAttrRender = BeautyAttrRender or BaseClass(BaseRender)
function BeautyAttrRender:__init()
	self.name = self:FindVariable("Name")
	self.value = self:FindVariable("Value")
end

function BeautyAttrRender:__delete()
end

function BeautyAttrRender:SetData(data)
	self.data = data
	self:Flush()
end

function BeautyAttrRender:OnFlush()
	if self.data == nil or next(self.data) == nil then
		return
	end

	if self.name ~= nil then
		self.name:SetValue(self.data.attr_name)
	end
	if self.value ~= nil then
		self.value:SetValue(self.data.value)
	end
end
