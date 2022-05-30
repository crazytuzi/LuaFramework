local SuijiRewordItem = class("SuijiRewordItem", function()
	return CCTableViewCell:new()
end)

function SuijiRewordItem:getContentSize()
	return cc.size(105, 132)
end

function SuijiRewordItem:refreshItem(param)
end

function SuijiRewordItem:create(param)
	local _viewSize = param.viewSize
	local _data = param.itemData
	for k, v in pairs(_data) do
		local item = require("game.nbactivity.TanBao.SuijiCell").new()
		local itemCell = item:create({
		id = v.id,
		itemData = v,
		viewSize = _viewSize
		})
		itemCell:setPosition(cc.p((k - 1) * 118 + 12, 0))
		self:addChild(itemCell)
	end
	return self
end

function SuijiRewordItem:refresh(param)
	self:refreshItem(param)
end

return SuijiRewordItem