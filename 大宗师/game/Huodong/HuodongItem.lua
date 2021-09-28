 --[[
 --
 -- @authors shan 
 -- @date    2014-08-04 15:49:41
 -- @version 
 --
 --]]

local HuodongItem = class("HuodongItem", function ( ... )
    return CCTableViewCell:new()
end)



function HuodongItem:getContentSize()
    if self._sz then

    else
        local proxy = CCBProxy:create()
        local rootnode = {}

        local node = CCBuilderReaderLoad("ccbi/huodong/ccb_huodong_item.ccbi", proxy, rootnode)
        self._sz = rootnode["tag_huodong_item"]:getContentSize()
        self:addChild(node)
        node:removeSelf()
    end

    return self._sz
end



function HuodongItem:create(param)
	local proxy = CCBProxy:create()
    self._rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/huodong/ccb_huodong_item.ccbi", proxy, self._rootnode)
	self:addChild(node)

	
    self:refresh(param)
    return self
end

function HuodongItem:getBtn()
    return self._rootnode["tag_huodong_item"]
end


-- 更新活动item的背景
function HuodongItem:refresh(param)
	if(param.itemData ~= nil ) then
		local spriteName = "ui/ui_huodong/" .. param.itemData.icon .. ".jpg"

		local sprite = display.newSprite(spriteName)
		self._rootnode["tag_huodong_item"]:setDisplayFrame(sprite:getDisplayFrame())

	end
end



return HuodongItem