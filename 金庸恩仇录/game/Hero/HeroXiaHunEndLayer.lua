local HeroXiaHunEndLayer = class("HeroXiaHunEndLayer", function()
	return require("utility.ShadeLayer").new()
end)

function HeroXiaHunEndLayer:ctor(param)
	local nextXiaHun = param.nextXiaHun
	self:setTouchHandler(function(event)
		if "began" == event.name then
			nextXiaHun()
			self:removeSelf()
			return true
		end
	end,
	1)
end

return HeroXiaHunEndLayer