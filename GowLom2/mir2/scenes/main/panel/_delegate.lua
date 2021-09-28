local panelDelegate = {
	extend = function (target, name, parent)
		target.hidePanel = function (self)
			parent:hidePanel(name)

			if name == "equip" or name == "equipOther" then
				parent:hidePanel("rankEquip")
			elseif name == "bag" then
				parent:hidePanel("materialBag")
			end

			return 
		end
		target.setFocus = function (self)
			if parent.lastFocus then
				parent.lastFocus:setLocalZOrder(0)
			end

			parent.lastFocus = self

			self.setLocalZOrder(self, parent.z.focus)

			return 
		end
		target.checkInPanel = function (self, pos)
			local p = self.convertToWorldSpace(self, cc.p(0, 0))

			for k, v in pairs(self._touchFrames) do
				local rect = v.rect

				if cc.rectContainsPoint(cc.rect(p.x + rect.x*self.getScale(self), p.y + rect.y*self.getScale(self), rect.width*self.getScale(self), rect.height*self.getScale(self)), pos) then
					return true
				end
			end

			return 
		end
		target.addTouchFrame = function (self, rect, name, onlyRect)
			self.removeTouchFrame(self, name)

			local frame = {
				rect = rect
			}

			if not onlyRect then
				frame.mask1 = display.newNode():pos(rect.x, rect.y):size(rect.width, rect.height):addto(self, -999999999)

				frame.mask1:setTouchEnabled(true)
				frame.mask1:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
					if not self._supportMove then
						return 
					end

					if event.name == "began" then
						frame.beganPos = cc.p(self:getPosition())
						frame.beganTouchPos = cc.p(event.x, event.y)

						return true
					elseif event.name == "moved" then
						self:pos(event.x - frame.beganTouchPos.x + frame.beganPos.x, event.y - frame.beganTouchPos.y + frame.beganPos.y)
					elseif event.name == "ended" then
						self:pos(event.x - frame.beganTouchPos.x + frame.beganPos.x, event.y - frame.beganTouchPos.y + frame.beganPos.y)

						if target.oX and target.oY then
							target.oX[#target.oX + 1] = event.x - frame.beganTouchPos.x
							target.oY[#target.oY + 1] = event.y - frame.beganTouchPos.y
						end
					end

					return 
				end)

				frame.mask2 = display.newNode().pos(slot5, rect.x, rect.y):size(rect.width, rect.height):addto(self, 999999999)

				frame.mask2:setTouchEnabled(true)
				frame.mask2:setTouchSwallowEnabled(false)
				frame.mask2:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
					if event.name == "began" then
						self:setFocus()

						return true
					end

					return 
				end)
			end

			self._touchFrames[name] = frame

			return 
		end
		target.removeTouchFrame = function (self, name)
			if self._touchFrames[name] then
				if self._touchFrames[name].mask1 then
					self._touchFrames[name].mask1:removeSelf()
				end

				if self._touchFrames[name].mask2 then
					self._touchFrames[name].mask2:removeSelf()
				end

				self._touchFrames[name] = nil
			end

			return 
		end
		target._touchFrames = {}
		local rect = target._mainRect or cc.rect(0, 0, target.getw(slot0), target.geth(target))

		target.addTouchFrame(target, rect, "main")

		return target
	end
}

return panelDelegate
