SpiritGetWayView = SpiritGetWayView or BaseClass(BaseView)

function SpiritGetWayView:__init()
	self.ui_config = {"uis/views/spiritview_prefab", "SpiritGetWayTip"}
	self.view_layer = UiLayer.Pop
	self.get_way_list = {}
	self.play_audio = true
end

function SpiritGetWayView:ReleaseCallBack()
	self.get_way_list = {}
	if self.item_cell ~= nil then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	-- 清理变量和对象
	self.item_name = nil
	self.item_icon = nil
	self.color = nil
	self.show_ways = nil
	self.show_icons = nil
end

function SpiritGetWayView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))

	self.item_name = self:FindVariable("ItemName")
	self.item_icon = self:FindVariable("ItemIcon")
	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))

	self.color = self:FindVariable("Color")
end

function SpiritGetWayView:SetData(item_id, close_call_back)
	if close_call_back ~= nil then
		self.close_call_back = close_call_back
	end
	self.item_id = item_id
end

function SpiritGetWayView:OpenCallBack()
	local cfg = ItemData.Instance:GetItemConfig(self.item_id)
	if cfg then
		self.item_name:SetValue(cfg.name)
		self.color:SetValue(Language.Common.QualityRGBColor[cfg.color])

		local data = {}
		data.item_id = self.item_id
		local func = function() if ViewManager.Instance:IsOpen(ViewName.Shop) then self:Close() end end
		data.close_call_back = func
		self.item_cell:SetData(data)
	end
end

function SpiritGetWayView:CloseView()
	self:Close()
end

function SpiritGetWayView:CloseCallBack()
	if self.close_call_back ~= nil then
		self.close_call_back()
		self.close_call_back = nil
	end
	self.get_way_list = {}
	self.item_id = 0
end
