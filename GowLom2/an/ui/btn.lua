local btn = class("an.btn", function ()
	return display.newNode()
end)

table.merge(slot0, {
	imageTex,
	listener,
	params,
	bg,
	sprite,
	label,
	isSelect,
	beganPos,
	beganTouchPos,
	hasDrag,
	lastClick
})

btn.ctor = function (self, imageTex, listener, params)
	params = params or {}

	if 0 < DEBUG then
		if type(imageTex) ~= "userdata" or (tolua.type(imageTex) ~= "cc.Texture2D" and tolua.type(imageTex) ~= "cc.SpriteFrame") then
			printError("param[%s] must be 'cc.Texture2D' or 'cc.SpriteFrame' Type. ", imageTex)
		end

		if params.select then
			if type(params.select) == "string" then
				printError("param[select] must be 'table' Type.")
			elseif type(params.select[1]) ~= "userdata" or (tolua.type(params.select[1]) ~= "cc.Texture2D" and tolua.type(params.select[1]) ~= "cc.SpriteFrame") then
				printError("param[%s] must be 'cc.Texture2D' or 'cc.SpriteFrame' Type. ", params.select[1])
			end
		end

		if params.pressImage and (type(params.pressImage) ~= "userdata" or (tolua.type(params.pressImage) ~= "cc.Texture2D" and tolua.type(params.pressImage) ~= "cc.SpriteFrame")) then
			printError("param[%s] must be 'cc.Texture2D' or 'cc.SpriteFrame' Type.", params.pressImage)
		end
	end

	self.imageTex = imageTex
	self.listener = listener
	self.params = params
	local class = nil

	if params.filter then
		class = cc.FilteredSpriteWithOne
	elseif params.scale9 then
		class = ccui.Scale9Sprite

		if tolua.type(imageTex) == "cc.Texture2D" then
			local size = imageTex.getContentSize(imageTex)
			imageTex = cc.SpriteFrame:createWithTexture(imageTex, cc.rect(0, 0, size.width, size.height))

			if cc.SpriteFrame.createWithTexture(imageTex, cc.rect(0, 0, size.width, size.height)) then
			end
		end
	else
		class = cc.Sprite
	end

	if tolua.type(imageTex) == "cc.SpriteFrame" then
		if imageTex.isDownloading and imageTex.isDownloading(imageTex) then
			self.bg = ycM2Sprite:create(res.default2(), false, false):add2(self)

			self.bg:setSpriteFrame(imageTex)

			if main_scene then
			end
		else
			self.bg = display.newSprite(imageTex, nil, nil, {
				class = class,
				size = params.scale9
			}):add2(self)
		end
	else
		self.bg = display.newSprite(imageTex, nil, nil, {
			class = class,
			size = params.scale9
		}):add2(self)
	end

	if params.scale then
		self.bg:scale(params.scale)
	end

	if params.anchor then
		self.bg:anchor(params.anchor[1], params.anchor[2])
	end

	if params.pressShow then
		self.bg:setOpacity(0)
	end

	if params.label then
		self.label = an.newLabel(params.label[1], params.label[2], params.label[3], params.label[4]):anchor(0.5, 0.5):addto(self)
	end

	if params.sprite then
		if params.filter then
			self.sprite = display.newSprite(params.sprite, nil, nil, {
				class = cc.FilteredSpriteWithOne
			})
		else
			self.sprite = display.newSprite(params.sprite)
		end

		self.sprite:anchor(0.5, 0.5):add2(self)
	end

	self.size(self, self.bg:getContentSize().width*self.bg:getScale(), self.bg:getContentSize().height*self.bg:getScale())

	if params.size then
		display.newNode():anchor(0.5, 0.5):pos(self.centerPos(self)):size(params.size):add2(self, an.z.max)
	end

	self.anchor(self, 0.5, 0.5)

	if not params.externTouch then
		if params.support == "scroll" then
			self.setTouchSwallowEnabled(self, false)
		end

		self.setTouchEnabled(self, true)
		self.addNodeEventListener(self, cc.NODE_TOUCH_EVENT, handler(self, self.handleTouch))
	end

	imageTex.retain(imageTex)

	if params.select then
		params.select[1]:retain()
	end

	if params.pressImage then
		params.pressImage:retain()
	end

	self.setNodeEventEnabled(self, true)

	self.onCleanup = function ()
		imageTex:release()

		if params.select then
			params.select[1]:release()
		end

		if params.pressImage then
			params.pressImage:release()
		end

		if params.call_remove then
			params.call_remove()
		end

		return 
	end

	if params.filterOpen then
		self.openFilter(slot0)
	end

	if params.longTouchCB then
		self.longTouchCB = params.longTouchCB
		self.deltaT = 0

		scheduler.scheduleUpdateGlobal(handler(self, self.update))
	end

	return 
end
btn.update = function (self, dt)
	if self.isTouchBegan then
		self.deltaT = self.deltaT + dt

		if 0.5 < self.deltaT then
			self.longTouchCB()
		end
	else
		self.deltaT = 0
	end

	return 
end
btn.size = function (self, width, height)
	if type(width) == "table" then
		self.setContentSize(self, width)
	else
		self.setContentSize(self, cc.size(width, height))
	end

	local anchor = self.bg:getAnchorPoint()

	self.bg:pos(anchor.x*self.getw(self), anchor.y*self.geth(self))

	if self.label then
		local anchor = self.label:getAnchorPoint()
		local offset = self.params.labelOffset or {
			x = 0,
			y = 0
		}

		self.label:pos(anchor.x*self.getw(self) + offset.x, anchor.x*self.geth(self) + offset.y)
	end

	if self.sprite then
		local anchor = self.sprite:getAnchorPoint()
		local offset = self.params.spriteOffset or {
			x = 0,
			y = 0
		}

		self.sprite:pos(anchor.x*self.getw(self) + offset.x, anchor.x*self.geth(self) + offset.y)
	end

	return self
end
btn.setTex = function (self, tex)
	if self.params.scale9 then
		if tolua.type(tex) ~= "cc.SpriteFrame" then
			local size = tex.getContentSize(tex)
			local frame = cc.SpriteFrame:createWithTexture(tex, cc.rect(0, 0, size.width, size.height))

			if frame then
				self.bg:setSpriteFrame(frame)
			end
		else
			self.bg:setSpriteFrame(tex)
		end

		self.bg:size(self.params.scale9)
	else
		self.setTexture(self, tex)
	end

	return 
end
btn.setTexture = function (self, tex)
	self.bg:setTex(tex)

	return 
end
btn.touchIn = function (self, isTouchIn)
	if isTouchIn then
		if self.params.pressShow then
			self.bg:setOpacity(255)
		end

		if self.params.pressBig then
			local power = 1.3

			if type(self.params.pressBig) == "number" then
				power = self.params.pressBig
			end

			self.bg:scaleTo(0.1, power*(self.params.scale or 1))

			if self.sprite then
				self.sprite:scaleTo(0.1, power*(self.params.scale or 1))
			end
		end

		if self.params.pressImage then
			self.setTex(self, self.params.pressImage)
		end
	else
		if self.params.pressShow then
			self.bg:setOpacity(0)
		end

		if self.params.pressBig then
			self.bg:scaleTo(0.1, self.params.scale or 1)

			if self.sprite then
				self.sprite:scaleTo(0.1, self.params.scale or 1)
			end
		end

		if self.params.pressImage then
			self.setTex(self, self.imageTex)
		end
	end

	return 
end
btn.select = function (self)
	if self.params.select and not self.isSelect then
		self.isSelect = true

		self.setTex(self, self.params.select[1])
	end

	return 
end
btn.unselect = function (self)
	if self.params.select and self.isSelect then
		self.isSelect = false

		self.setTex(self, self.imageTex)
	end

	return 
end
btn.setIsSelect = function (self, b)
	if b then
		self.select(self)
	else
		self.unselect(self)
	end

	return self
end
btn.openFilter = function (self)
	if self.params.filter then
		self.bg:setFilter(self.params.filter)

		if self.sprite then
			self.sprite:setFilter(self.params.filter)
		end
	end

	return 
end
btn.closeFilter = function (self)
	if self.params.filter then
		self.bg:clearFilter()

		if self.sprite then
			self.sprite:clearFilter()
		end
	end

	return 
end
btn.handleTouch = function (self, event)
	local function click()
		if self.params.clickSpace then
			local curtime = socket.gettime()

			if self.lastClick and curtime - self.lastClick < self.params.clickSpace then
				return 
			end

			self.lastClick = curtime
		end

		if self.params.select and not self.params.select.manual then
			if self.isSelect then
				self:unselect()
			else
				self:select()
			end
		end

		if self.listener then
			self.listener(self)
		end

		return 
	end

	local touchInBtn = true

	if self.params.customTouchCheck then
		slot4 = self.params.customTouchCheck(event.x, event.y)
		touchInBtn = slot4
	end

	if event.name == "began" and touchInBtn then
		self.isTouchBegan = true

		self.touchIn(self, true)

		if self.params.support == "easy" then
			click()
		elseif self.params.support == "drag" or self.params.support == "scroll" then
			self.beganPos = cc.p(self.getPosition(self))
			self.beganTouchPos = cc.p(event.x, event.y)
			self.hasDrag = false
		end

		return true
	end

	if not self.params.customTouchCheck then
		touchInBtn = self.getCascadeBoundingBox(self):containsPoint(cc.p(event.x, event.y))
	end

	if event.name == "moved" then
		if self.params.support == "drag" or self.params.support == "scroll" then
			if 10 < math.abs(self.beganTouchPos.x - event.x) or 10 < math.abs(self.beganTouchPos.y - event.y) then
				self.hasDrag = true
			end

			if self.hasDrag then
				if self.params.support == "drag" then
					self.pos(self, event.x - self.beganTouchPos.x + self.beganPos.x, event.y - self.beganTouchPos.y + self.beganPos.y)

					if self.params.call_drag_moving then
						self.params.call_drag_moving(self, event)
					end
				elseif self.params.support == "scroll" then
					self.touchIn(self, false)
				end
			end
		else
			self.touchIn(self, touchInBtn)
		end
	elseif event.name == "ended" then
		self.isTouchBegan = false

		if self.params.support ~= "easy" or false then
			if self.params.support == "drag" then
				if self.hasDrag then
					if self.params.call_drag_end then
						self.params.call_drag_end(self, event)
					end
				elseif touchInBtn then
					click()
				end
			elseif self.params.support == "scroll" then
				if not self.hasDrag and touchInBtn then
					click()
				end
			elseif touchInBtn then
				click()
			end
		end

		if not tolua.isnull(self) then
			self.touchIn(self, false)
		end
	else
		self.touchIn(self, false)
	end

	return 
end

return btn
