--
-- Author: Daneil
-- Date: 2015-03-06 14:27:27
--

local SuijiRewordItem = class("SuijiRewordItem", function()
	return CCTableViewCell:new()
end)


function SuijiRewordItem:getContentSize()
	return CCSizeMake(105, 120)
end


function SuijiRewordItem:refreshItem(param)

end


function SuijiRewordItem:create(param)
    local _viewSize = param.viewSize
    local _data     = param.itemData
    for k,v in pairs(_data) do
    	local item = require("game.nbactivity.TanBao.SuijiCell").new()
    	local itemCell = item:create({
			id = v.id, 
			itemData = v,
	        viewSize = _viewSize
		})
		itemCell:setPosition(cc.p((k - 1) * 118 + 12,- 12))
		self:addChild(itemCell)
    end
	return self
end

function SuijiRewordItem:refresh(param)
	self:refreshItem(param)
end


return SuijiRewordItem