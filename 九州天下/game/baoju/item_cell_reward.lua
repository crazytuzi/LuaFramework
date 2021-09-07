ItemCellReward = ItemCellReward or BaseClass(ItemCell)

function ItemCellReward:__init()
	self:ShowHighLight(false)
	-- self:ListenClick((function()
	-- 	if self.data ~= nil then
	-- 		TipsCtrl.Instance:OpenItem(self.data)
	-- 	end
	-- end))
	self:SetNotShowRedPoint(true)
end