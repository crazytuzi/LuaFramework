local driftMsg = class("driftMsg", function ()
	return display.newNode()
end)

table.merge(slot0, {
	btn,
	btns,
	beganPos,
	beganTouchPos,
	hasMove,
	lock,
	content
})

driftMsg.ctor = function (self)
	self.btn = res.get2("pic/console/iconbg8.png")

	self.btn:pos(self.btn:centerPos()):add2(self, 1):setCascadeOpacityEnabled(true)
	res.get2("pic/debug/icon.png"):pos(self.btn:centerPos()):add2(self.btn)
	self.setCascadeOpacityEnabled(self, true)
	self.size(self, self.btn:getw(), self.btn:geth()):anchor(0.5, 0.5):pos(self.getw(self)/2, display.height - self.geth(self)/2):opacity(0):runs({
		cc.FadeIn:create(1),
		cc.DelayTime:create(3),
		cc.CallFunc:create(function ()
			self:opacity(128)

			return 
		end)
	})
	self.btn.setTouchEnabled(slot1, true)
	self.btn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if self.lock then
			return 
		end

		if event.name == "began" then
			self.beganPos = cc.p(self:getPosition())
			self.beganTouchPos = cc.p(event.x, event.y)
			self.hasMove = false

			self:opacity(255)
			self:scale(1)
			self:stopAllActions()
		elseif event.name == "moved" then
			if self.hasMove or 10 < math.abs(self.beganTouchPos.x - event.x) or 10 < math.abs(self.beganTouchPos.y - event.y) then
				self.hasMove = true
				local x = event.x - self.beganTouchPos.x + self.beganPos.x
				local y = event.y - self.beganTouchPos.y + self.beganPos.y

				if x < 0 then
					x = 0
				end

				if display.width < x then
					x = display.width or x
				end

				if y < 0 then
					y = 0
				end

				if display.height < y then
					y = display.height or y
				end

				self:pos(x, y)
			end
		elseif event.name == "ended" then
			local function newx(x)
				if x < self:getw()/2 then
					x = self:getw()/2 or x
				end

				if display.width - self:getw()/2 < x then
					x = display.width - self:getw()/2 or x
				end

				return x
			end

			local function newy(y)
				if y < self:geth()/2 then
					y = self:geth()/2 or y
				end

				if display.height - self:geth()/2 < y then
					y = display.height - self:geth()/2 or y
				end

				return y
			end

			local function bothXY(x, y)
				if y < self:geth() then
					x = newx(x)
					y = self:geth()/2
				elseif display.height - self:geth() < y then
					x = newx(x)
					y = display.height - self:geth()/2
				elseif display.cx < x then
					x = display.width - self:getw()/2
					y = newy(y)
				else
					x = self:getw()/2
					y = newy(y)
				end

				return x, y
			end

			local function goto(x, y)
				if self.content then
					self:moveTo(0.25, x, y)
				else
					self:runs({
						cc.MoveTo:create(0.25, cc.p(x, y)),
						cc.DelayTime:create(3),
						cc.CallFunc:create(function ()
							self:opacity(128)

							return 
						end)
					})
				end

				return 
			end

			if not self.hasMove then
				self.lock = true

				self.btn.runs(slot5, {
					cc.ScaleTo:create(0.1, 0.01),
					cc.ScaleTo:create(0.1, 1),
					cc.CallFunc:create(function ()
						self.lock = nil

						if self.content then
							self.content:removeSelf()

							self.content = nil

							goto(bothXY(self:getPosition()))
						else
							self:createContentBase()
						end

						return 
					end)
				})
			else
				local x = event.x - self.beganTouchPos.x + self.beganPos.x
				local y = event.y - self.beganTouchPos.y + self.beganPos.y

				if self.content then
					y = newy(y)
					x = slot1(x)
				else
					x, y = bothXY(x, y)
				end

				goto(x, y)
			end
		end

		return true
	end)

	return 
end
driftMsg.createContentBase = function (self, type)
	if self.content then
		self.content:removeSelf()
	end

	self.content = display.newNode():anchor(0, 1):pos(self.btn:getw()/2 + 5, self.btn:geth()/2 - 5):size(240, 140):add2(self)
	self.content.type = type

	display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(self.content:getContentSize()):add2(self.content)
	display.newScale9Sprite(res.getframe2("pic/scale/scale2.png")):anchor(0, 0):size(self.content:getContentSize()):add2(self.content)

	local labelInfo = "精力值: " .. g_data.player.stamina .. "/" .. g_data.player.staminaMax

	an.newLabel(labelInfo, 20, 1, {
		color = def.colors.labelGray
	}):anchor(0, 0.5):addto(self.content):pos(30, 120)

	labelInfo = "活力值: " .. g_data.player.vitality .. "/" .. g_data.player.vitalityMax

	an.newLabel(labelInfo, 20, 1, {
		color = def.colors.labelGray
	}):anchor(0, 0.5):addto(self.content):pos(30, 95)

	labelInfo = "存储经验: " .. g_data.player.expPoolValue

	an.newLabel(labelInfo, 20, 1, {
		color = def.colors.labelGray
	}):anchor(0, 0.5):addto(self.content):pos(30, 70)

	labelInfo = "魔龙之血: " .. g_data.player.vitaliyitemValue

	an.newLabel(labelInfo, 20, 1, {
		color = def.colors.labelGray
	}):anchor(0, 0.5):addto(self.content):pos(30, 45)

	return 
end

return driftMsg
