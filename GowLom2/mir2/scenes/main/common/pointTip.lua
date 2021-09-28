local common = import(".common")
local pointTip = class("pointTip", function ()
	return display.newNode()
end)
pointTip.attach = function (node, params)
	return pointTip.new(node, params)
end
pointTip.ctor = function (self, node, params)
	local pic = "pic/panels/mail/newMailTip.png"

	if params and params.ui == "small" then
		pic = "pic/common/button_click02.png"
	end

	self.sprite = display.newSprite(res.gettex2(pic)):anchor(0, 0):add2(self)
	local dir = params.dir or "right"

	if not params.custom then
		local w = params.w or node.getw(node)
		local h = params.h or node.geth(node)

		if params.type and params.type == 0 then
			local r = params.r or w/2
			local rad = math.rad(45)
			local y = math.sin(rad)*r
			local x = y

			self.pos(self, (dir == "left" and r - x) or r + x, r + y)
		else
			self.pos(self, (dir ~= "left" or 0) and w, h)
		end
	else
		self.pos(self, params.pos.x, params.pos.y)
	end

	self.size(self, self.sprite:getw(), self.sprite:geth()):anchor(0.5, 0.5)
	self.visible(self, params.visible or true)
	node.addChild(node, self)

	return 
end
pointTip.visible = function (self, b)
	if b then
		self.show(self)
	else
		self.hide(self)
	end

	return 
end
pointTip.show = function (self)
	self.sprite:setVisible(true)

	return 
end
pointTip.hide = function (self)
	self.sprite:setVisible(false)

	return 
end

return pointTip
