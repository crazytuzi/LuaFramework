KuanHuanDanBiChongZhiItem = KuanHuanDanBiChongZhiItem or BaseClass(BaseCell)

function KuanHuanDanBiChongZhiItem:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
end

function KuanHuanDanBiChongZhiItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function KuanHuanDanBiChongZhiItem:OnFlush()
	if nil == self.data then
		return
	end

	self.item_cell:SetData(self.data)
end