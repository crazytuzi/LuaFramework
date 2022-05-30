local RewardItemGroup = class("RewardItemGroup", function()
	return CCTableViewCell:new()
end)

function RewardItemGroup:ctor(param)
	self.itemGroups = {}
	self:refreshItem(param)
end

function RewardItemGroup:refresh(param)
	self:refreshItem(param)
end

function RewardItemGroup:refreshItem(param)
	for i = 1, 5 do
		if param[i] ~= nil then
			if self.itemGroups[i] ~= nil then
				self.itemGroups[i]:setVisible(true)
				self.itemGroups[i]:refreshItem({
				id = param.index * 5 + i,
				itemData = param[i],
				viewSize = cc.size(param.width, param.height)
				})
			else
				local item = require("game.Huodong.RewardItem").new()
				self.itemGroups[i] = item:create({
				id = param.index * 5 + i,
				itemData = param[i],
				viewSize = cc.size(param.width, param.height)
				})
				self.itemGroups[i]:setPosition(95 * (i - 1), 3)
				self.itemGroups[i]:setScale(0.9)
				self:addChild(item)
			end
		elseif self.itemGroups[i] ~= nil then
			self.itemGroups[i]:setVisible(false)
		end
	end
end

function RewardItemGroup:onExit()
	itemGroups = nil
end

return RewardItemGroup