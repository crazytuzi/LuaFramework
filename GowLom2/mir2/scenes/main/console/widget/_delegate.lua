local detail = import("..detail")
local replaceAsk = import("..replaceAsk")
local widgetDelegate = {
	extend = function (target, console)
		local mask, rect, beganPos, beganTouchPos, hasMove, beganTime = nil
		target._startEdit = function (self)
			if mask then
				mask:removeSelf()
			end

			mask = display.newNode():size(self.getContentSize(self)):addto(self, 999999999)

			mask:setTouchEnabled(true)
			mask:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
				if event.name == "began" then
					beganPos = cc.p(self:getPosition())
					beganTouchPos = cc.p(event.x, event.y)
					beganTime = socket.gettime()
					hasMove = false

					self:setLocalZOrder(self:getLocalZOrder() + 1)
					console:showRect(self)
				elseif event.name == "moved" then
					if hasMove or 10 < math.abs(beganTouchPos.x - event.x) or 10 < math.abs(beganTouchPos.y - event.y) or 1 < socket.gettime() - beganTime then
						hasMove = true
						local x = beganPos.x
						local y = beganPos.y

						if not self.config.fixedX then
							x = event.x - beganTouchPos.x + beganPos.x
							x = self:_checkx(x)
							self.data.x = x
						end

						if not self.config.fixedY then
							y = event.y - beganTouchPos.y + beganPos.y
							y = self:_checky(y)
							self.data.y = y
						end

						self:pos(x, y)

						if self.config.class == "btnMove" then
							console:checkBtnAreaShow(cc.p(x, y))
						end
					end
				elseif event.name == "ended" then
					self:setLocalZOrder(self:getLocalZOrder() - 1)

					if hasMove then
						console:checkBtnAreaShow(nil, true)

						if self.config.class == "btnMove" then
							local btnpos = console:pos2btnpos(self:getPosition())

							if btnpos then
								local existBtn = console:findWidgetWithBtnpos(btnpos)

								if existBtn then
									if existBtn == self then
										console:resetBtnAreaBtnPos(self, true)

										return 
									end

									replaceAsk.new(existBtn, function (operator)
										if existBtn.config.banRemove and operator == "replace" then
											operator = "swap"
										end

										if operator == "swap" then
											if not self.data.btnpos and existBtn.data.btnpos then
												existBtn.data.x = beganPos.x
												existBtn.data.y = beganPos.y
											end

											existBtn.data.btnpos = self.data.btnpos
											self.data.btnpos = existBtn.data.btnpos

											console:resetBtnAreaBtnPos(self, true)

											if not existBtn.data.btnpos then
												existBtn:moveTo(0.1, beganPos.x, beganPos.y)
											else
												console:resetBtnAreaBtnPos(existBtn, true)
											end
										elseif operator == "replace" then
											console:removeWidget(existBtn.data.key)

											self.data.btnpos = btnpos

											console:resetBtnAreaBtnPos(self, true)
										elseif operator == "cancel" then
											if not self.data.btnpos then
												self:moveTo(0.1, beganPos.x, beganPos.y)
											else
												console:resetBtnAreaBtnPos(self, true)
											end
										end

										return 
									end, "console")
								else
									self.data.btnpos = btnpos

									console.resetBtnAreaBtnPos(beganTime, self, true)
								end
							else
								self.data.btnpos = nil
							end
						end
					else
						detail.new(self.config, self.data, self:getPositionX(), self:getPositionY(), self:getw(), self:geth(), "console", self)
					end
				end

				return true
			end)

			return 
		end
		target._endEdit = function (self)
			if mask then
				mask:removeSelf()

				mask = nil
			end

			return 
		end
		target._showRect = function (self)
			if not rect then
				rect = display.newRect(cc.rect(0, 0, self.getw(self), self.geth(self)), {
					borderWidth = 1,
					borderColor = cc.c4f(0, 1, 0, 1)
				}):add2(self, 999999999)
			end

			return 
		end
		target._hideRect = function (self)
			if rect then
				rect:removeSelf()

				rect = nil
			end

			return 
		end
		target._checkx = function (self, x)
			if x < self.getw(self)/2 then
				x = self.getw(self)/2 or x
			end

			if display.width - self.getw(self)/2 < x then
				x = display.width - self.getw(self)/2 or x
			end

			return x
		end
		target._checky = function (self, y)
			if y < self.geth(self)/2 then
				y = self.geth(self)/2 or y
			end

			if display.height - self.geth(self)/2 < y then
				y = display.height - self.geth(self)/2 or y
			end

			return y
		end
		target._checkPos = function (self, x, y)
			return self._checkx(self, x), self._checky(self, y)
		end
		target._sizeChanged = function (self)
			if mask then
				mask:size(self.getContentSize(self))
			end

			self._hideRect(self)
			self._showRect(self)
			self.pos(self, self._checkPos(self, self.getPosition(self)))

			return 
		end

		return target
	end
}

return widgetDelegate
