local ItemList = class("ItemList", function ()
	return display.newNode()
end)
function ItemList:ctor(param)
	self.height = param.height
	self.width = param.width
	self.itemDataArr = param.itemDataArr
	local function createFunc(index)
		local item = require("game.nbactivity.MonthCard.MonthCardRewardItem").new()
		return item:create({
		id = index,
		viewSize = CCSizeMake(self.width, self.height),
		itemData = self.itemDataArr[index + 1]
		})
	end
	local function refreshFunc(cell, index)
		cell:refresh({
		index = index,
		itemData = self.itemDataArr[index + 1]
		})
	end
	local cellContentSize = require("game.nbactivity.MonthCard.MonthCardRewardItem").new():getContentSize()
	self._curInfoIndex = -1
	self.ListTable = require("utility.TableViewExt").new({
	size = CCSizeMake(self.width, self.height),
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = #self.itemDataArr,
	cellSize = cellContentSize,
	touchFunc = function (cell)
		if self._curInfoIndex ~= -1 then
			return
		end
		local idx = cell:getIdx() + 1
		self._curInfoIndex = idx
		local itemData = self.itemDataArr[idx]
		local itemInfo = require("game.Huodong.ItemInformation").new({
		id = itemData.id,
		type = itemData.type,
		name = itemData.name,
		describe = itemData.describe,
		endFunc = function ()
			self._curInfoIndex = -1
		end
		})
		game.runningScene:addChild(itemInfo, 100)
	end
	})
	self.ListTable:setPosition(0, 0)
	self:addChild(self.ListTable)
end

return ItemList