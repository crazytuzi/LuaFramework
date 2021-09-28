--
-- Author: Daneil
-- Date: 2015-01-29 16:42:44
--

local ImageButton = {}
ImageButton.__index = ImageButton

function ImageButton:addTouchListener(node,callBack)
	local scalePre
	local scaleAft 
	local clickEable = true
	node:setTouchEnabled(true)
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		local scale = node:getScale()
		node:setScale(1)
		local boundBox = node:boundingBox()
		node:setScale(scale)
	    local box = CCRectMake(0, 0, boundBox.size.width, boundBox.size.height )
		if event.name == "began" then
			scalePre = node:getScale()
			callBack(node,EventType.began)
			scaleAft = node:getScale()
			if clickEable then
				clickEable = false
				return true
			else
				return false
			end
	    elseif event.name == "ended" then
	    	if box:containsPoint(node:convertToNodeSpace(CCPointMake(event.x, event.y))) then
	    		callBack(node , EventType.ended)
	    	else
	    		callBack(node , EventType.cancel)
	    	end
	    	node:performWithDelay(function ()
	    		clickEable = true
	    		node:setScale(scalePre)
	    	end,0.5)
	    elseif event.name == "moved" then
	    	if not box:containsPoint(node:convertToNodeSpace(CCPointMake(event.x, event.y))) then
	    		node:setScale(scalePre)
	    	else
	    		node:setScale(scaleAft)
	    	end
	    end
		return true
	end)
end


function ImageButton:new(o)
	o = o or {}
	setmetatable(o, self)
	return o
end


return ImageButton
