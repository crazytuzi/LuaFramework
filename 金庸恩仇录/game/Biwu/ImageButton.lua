local ImageButton = {}

ImageButton.__index = ImageButton

function ImageButton:addTouchListener(node, callBack)
	local scalePre, scaleAft
	local x = 0
	local y = 0
	node:setTouchEnabled(true)
	node.clickEable = true
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		local scale = node:getScale()
		node:setScale(1)
		local boundBox = node:boundingBox()
		node:setScale(scale)
		local box = cc.rect(0, 0, boundBox.width, boundBox.height)
		if event.name == "began" then
			--dump("~~~~~~~~~九-零-一-起玩-w-w-w-.9-0-1-7-5-.-com~~~~~~~~~~~~~~~~~~~~~~~addNodeEventListener:")
			--dump(clickEable)
			if node.clickEable then
				scalePre = node:getScale()
				callBack(node, EventType.began)
				scaleAft = node:getScale()
				x = event.x
				y = event.y
				node.clickEable = false
				return true
			else
				return false
			end
		elseif event.name == "ended" then
			node:performWithDelay(function()
				node.clickEable = true
				node:setScale(scalePre)
			end,
			0.1)
			local tmepx = math.abs(event.x - x)
			local tempy = math.abs(event.y - y)
			if tempy < boundBox.height and tmepx < boundBox.width then
				if cc.rectContainsPoint(box, node:convertToNodeSpace(cc.p(event.x, event.y))) then
					callBack(node, EventType.ended)
				else
					callBack(node, EventType.cancel)
				end
			end
		elseif event.name == "moved" then
			if not cc.rectContainsPoint(box, node:convertToNodeSpace(cc.p(event.x, event.y))) then
				node:setScale(scalePre)
			else
				node:setScale(scaleAft)
			end
		end
		return true
	end)
end

function ImageButton:reset()
	self.clickEable = true
end

function ImageButton:new(o)
	o = o or {}
	setmetatable(o, self)
	return o
end

return ImageButton