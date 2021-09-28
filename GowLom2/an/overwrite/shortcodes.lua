local c = cc
local Node = c.Node
Node.addto = function (self, target, zorder, tag)
	target.addChild(target, self, zorder or 0, tag or 0)

	return self
end
Node.add2 = function (self, target, zorder, tag)
	target.addChild(target, self, zorder or 0, tag or 0)

	return self
end
Node.anchor = function (self, x, y)
	self.setAnchorPoint(self, cc.p(x, y))

	return self
end
Node.scaleX = function (self, scale)
	self.setScaleX(self, scale)

	return self
end
Node.scalex = function (self, scale)
	self.setScaleX(self, scale)

	return self
end
Node.scaleY = function (self, scale)
	self.setScaleY(self, scale)

	return self
end
Node.scaley = function (self, scale)
	self.setScaleY(self, scale)

	return self
end
Node.fit = function (self)
	self.setScaleX(self, display.width/self.getContentSize(self).width)
	self.setScaleY(self, display.height/self.getContentSize(self).height)

	return self
end
Node.run = function (self, action)
	self.runAction(self, action)

	return self
end
Node.runForever = function (self, action)
	self.runAction(self, cc.RepeatForever:create(action))

	return self
end
Node.runs = function (self, actions)
	local prev = actions[1]

	for i = 2, #actions, 1 do
		prev = cc.Sequence:create(prev, actions[i])
	end

	self.runAction(self, prev)

	return self, prev
end
Node.resetCascadeBoundingBox = function (self)
	print("-------------an.Node:resetCascadeBoundingBox----------------")

	return 
end
Node.runsAtSameTime = function (self, actions)
	local prev = actions[1]

	for i = 2, #actions, 1 do
		prev = cc.Spawn:create(prev, actions[i])
	end

	self.runAction(self, prev)

	return self
end
Node.getw = function (self)
	return self.getContentSize(self).width
end
Node.geth = function (self)
	return self.getContentSize(self).height
end
Node.centerPos = function (self)
	return self.getw(self)/2, self.geth(self)/2
end
Node.posAdd = function (self, x, y)
	return self.pos(self, self.getPositionX(self) + x, self.getPositionY(self) + y)
end
Node.sizeScale = function (self, size, scale)
	return self.size(self, size.width*scale, size.height*scale)
end
Node.enableClick = function (self, func, params)
	params = params or {}

	local function click(x, y)
		if params.ani then
			self:runs({
				cc.ScaleTo:create(0.1, 1.5),
				cc.ScaleTo:create(0.1, 1)
			})
		end

		func(x, y)

		return 
	end

	local beganPos, beganTouchPos, hasDrag = nil

	if params.support == "scroll" then
		self.setTouchSwallowEnabled(slot0, false)
	end

	self.setTouchEnabled(self, true)
	self.addNodeEventListener(self, cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			if params.support == "easy" then
				click(event.x, event.y)
			elseif params.support == "drag" or params.support == "scroll" then
				beganPos = cc.p(self:getPosition())
				beganTouchPos = cc.p(event.x, event.y)
				hasDrag = false
			end

			return true
		elseif event.name == "moved" then
			if params.support == "drag" or params.support == "scroll" then
				if 10 < math.abs(beganTouchPos.x - event.x) or 10 < math.abs(beganTouchPos.y - event.y) then
					hasDrag = true
				end

				if params.support == "drag" and hasDrag then
					self:pos(event.x - beganTouchPos.x + beganPos.x, event.y - beganTouchPos.y + beganPos.y)

					if params.call_drag_moving then
						params.call_drag_moving(event)
					end
				end
			end
		elseif event.name == "ended" then
			local touchIn = self:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y))

			if params.support ~= "easy" or false then
				if params.support == "drag" then
					if hasDrag then
						if params.call_drag_end then
							params.call_drag_end(event)
						end
					elseif touchIn then
						click(event.x, event.y)
					end
				elseif params.support == "scroll" then
					if not hasDrag and touchIn then
						click(event.x, event.y)
					end
				elseif touchIn then
					click(event.x, event.y)
				end
			end
		end

		return 
	end)

	return self
end
Node.debug = function (self)
	self.enableDebugdraw(self)

	return self
end
local Sprite = c.Sprite
Sprite.setTex = function (self, filename)
	local tex = nil

	if type(filename) == "string" then
		tex = cc.Director:getInstance():getTextureCache():addImage(filename)
	elseif tolua.type(filename) == "cc.Texture2D" or tolua.type(filename) == "cc.SpriteFrame" then
		tex = filename
	else
		printError("param[%s] must be 'cc.Texture2D' or 'cc.SpriteFrame' or 'string' Type. ", filename)
	end

	if tex then
		if tolua.type(tex) == "cc.SpriteFrame" then
			self.setSpriteFrame(self, tex)
		else
			local size = tex.getContentSize(tex)

			self.setTexture(self, tex)
			self.setTextureRect(self, cc.rect(0, 0, size.width, size.height))
		end
	end

	return self
end

return 
