local input = class("an.input", function ()
	return display.newNode()
end)
local testh = 280

table.merge(slot0, {
	bg,
	bgIsPressShow,
	label,
	content,
	cursor,
	maxLen,
	mask,
	testKeyboard,
	listener,
	password,
	passwordHandle,
	donotMove,
	donotClip,
	return_call,
	stop_call,
	show_call,
	hide_call,
	getWorldY_call,
	inputting,
	tip,
	chatItemNum = 0
})

input.ctor = function (self, x, y, w, h, max, params)
	self.chatItemNum = 0
	params = params or {}

	if 0 < DEBUG and params.bg and params.bg.tex and (type(params.bg.tex) ~= "userdata" or (tolua.type(params.bg.tex) ~= "cc.Texture2D" and tolua.type(params.bg.tex) ~= "cc.SpriteFrame")) then
		printError("param[%s] must be 'cc.Texture2D' or 'cc.SpriteFrame' Type. ", params.bg.tex)
	end

	local labelParams = params.label or {}
	local text = labelParams[1] or ""
	local fontSize = labelParams[2] or display.DEFAULT_TTF_FONT_SIZE
	local strokeSize = labelParams[3] or 0

	if params.bg then
		if params.bg.tex then
			local frame = nil

			if tolua.type(params.bg.tex) == "cc.Texture2D" then
				local size = params.bg.tex:getContentSize()
				frame = cc.SpriteFrame:createWithTexture(params.bg.tex, cc.rect(0, 0, size.width, size.height))
			end

			offset = params.bg.offset or {
				0,
				0
			}
			slot14 = display.newScale9Sprite(frame)
			self.bg = display.newScale9Sprite(frame).size(slot14, w, params.bg.h or h):anchor(0, 0):pos(offset[1], offset[2]):addto(self)
		else
			bgColor = params.bg.color or cc.c4b(0, 0, 0, 255)
			slot13 = display.newColorLayer(bgColor):size(w, params.bg.h or fontSize + 2)
			self.bg = display.newColorLayer(bgColor).size(w, params.bg.h or fontSize + 2).pos(slot13, 0, params.bg.y or (h - fontSize)/2):addto(self)
			self.bgIsPressShow = params.bg.pressShow

			self.checkBgShow(self, false)
		end
	else
		self.bgIsPressShow = nil
	end

	local clip = nil

	if not params.donotClip then
		clip = display.newClippingRegionNode(cc.rect(0, 0, w, h)):add2(self)
	end

	self.label = an.newLabelM(w, fontSize, strokeSize, {
		manual = true
	}):pos(0, (h - fontSize)/2):add2(clip or self)
	self.cursor = display.newColorLayer(cc.c4b(0, 255, 255, 255)):size(2, fontSize):pos(0, (h - fontSize)/2):addto(self):hide()
	self.listener = ycInputListener:create()

	self.listener:setListener(handler(self, self.callback))
	self.anchor(self, 0.5, 0.5):pos(x, y):size(w, h)
	self.setTouchEnabled(self, true)
	self.addNodeEventListener(self, cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			self:startInput()
		end

		return 
	end)
	self.setNodeEventEnabled(slot0, true)

	self.onCleanup = function ()
		ycInputListener:release(self.listener)

		if self.passwordHandle then
			scheduler.unscheduleGlobal(self.passwordHandle)

			self.passwordHandle = nil
		end

		if self.mask then
			self.mask:removeSelf()

			self.mask = nil
		end

		return 
	end
	self.keyboardHeightMax = 0
	self.maxLen = max
	self.password = params.password
	self.donotMove = params.donotMove
	self.return_call = params.return_call
	self.start_call = params.start_call
	self.stop_call = params.stop_call
	self.show_call = params.show_call
	self.hide_call = params.hide_call
	self.getWorldY_call = params.getWorldY_call
	self.params = params
	self.mask = nil
	self.passwordHandle = nil
	self.inputting = nil

	self.setText(slot0, text)
	self.showTip(self, true)

	return 
end
input.callback = function (self, dic)
	if dic.type == "keyboardWillShow" then
		if self.inputting and not self.donotMove then
			local worldY = nil

			if self.getWorldY_call then
				worldY = self.getWorldY_call()
			else
				local p = self.convertToWorldSpace(self, cc.p(0, 0))
				worldY = p.y
			end

			local y = nil

			if dic.eh then
				y = dic.eh - worldY
			else
				y = display.height - worldY - self.geth(self) - 120
			end

			if 0 < y then
				if self.params.keyboardEx then
					y = y + self.params.keyboardEx.get():geth()
				end

				if self.show_call then
					self.show_call(dic.duration, y, worldY)
				else
					display.getRunningScene():stopAllActions()
					display.getRunningScene():moveTo(dic.duration, 0, y)

					if self.params.keyboardEx then
						self.params.keyboardEx.get():pos(0, worldY)
					end
				end
			end
		end
	elseif dic.type == "keyboardWillHide" then
		if not self.donotMove then
			if self.hide_call then
				self.hide_call(dic.duration)
			else
				display.getRunningScene():stopAllActions()
				display.getRunningScene():moveTo(dic.duration, 0, 0)
			end
		end
	elseif dic.type == "insertText" then
		if dic.text == "\n" or ((device.platform == "mac" or device.platform == "windows") and dic.text == "\\") then
			self.stopInput(self)

			if self.return_call then
				self.return_call()
			end

			return 
		end

		local len = #self.content
		local strs = utf8strs(dic.text)

		for i, v in ipairs(strs) do
			self.content[#self.content + 1] = v
		end

		if self.params.checkCLen then
			local newContent = {}
			local cnt = 0

			for i, v in ipairs(self.content) do
				local wordLen = (type(v) == "string" and ycFunction:getStringLenWithAscii(v)) or 2

				if self.maxLen < cnt + wordLen then
					break
				end

				cnt = cnt + wordLen
				newContent[#newContent + 1] = v
			end

			self.content = newContent
		elseif self.maxLen < #self.content then
			for i = self.maxLen + 1, #self.content, 1 do
				self.content[i] = nil
			end
		end

		if #self.content == len then
			return 
		end

		if self.password then
			local showstr = self.getStarText(self, len) .. dic.text

			self.uptLabelM(self, showstr)

			if self.passwordHandle then
				scheduler.unscheduleGlobal(self.passwordHandle)
			end

			self.passwordHandle = scheduler.performWithDelayGlobal(function ()
				if self.passwordHandle then
					scheduler.unscheduleGlobal(self.passwordHandle)

					self.passwordHandle = nil
				end

				self:uptLabelM()
				self:uptCursor()

				return 
			end, 1)
		else
			self.uptLabelM(slot0)
		end

		self.uptCursor(self)
	elseif dic.type == "deleteBackward" and 0 < #self.content then
		self.content[#self.content] = nil

		self.uptLabelM(self)
		self.uptCursor(self)
	end

	return 
end
input.getStarText = function (self, len)
	if 0 < len then
		local tmp = ""

		for i = 1, len, 1 do
			tmp = tmp .. "*"
		end

		return tmp
	end

	return ""
end
input.uptLabelMPos = function (self)
	self.label:pos((self.getw(self) < self.label.widthCnt and self.getw(self) - self.label.widthCnt) or 0, self.label:getPositionY())

	return 
end
input.uptLabelM = function (self, text)
	self.label:clear():nextLine()

	if text then
		self.label:addLabel(text)
		self.uptLabelMPos(self)

		return 
	end

	local str = ""

	for i, v in ipairs(self.content) do
		if type(v) == "string" then
			str = str .. ((self.password and "*") or v)
		else
			if str ~= "" then
				self.label:addLabel(str)
			end

			str = ""

			if v.type == "emoji" then
				self.label:addEmoji(v.tex)
			elseif v.type == "label" then
				self.label:addLabel(v.text, v.color, nil, v.strokeColor)
			end
		end
	end

	if str ~= "" then
		self.label:addLabel(str)
	end

	self.uptLabelMPos(self)
	self.uptCursor(self)

	return 
end
input.addEmoji = function (self, tex, content)
	if #self.content < self.maxLen then
		self.content[#self.content + 1] = {
			type = "emoji",
			tex = tex,
			content = content
		}

		self.uptLabelM(self)
	end

	return 
end
input.addLabel = function (self, text, color, strokeColor, content)
	if #self.content < self.maxLen then
		self.content[#self.content + 1] = {
			type = "label",
			text = text,
			color = color,
			strokeColor = strokeColor,
			content = content
		}

		self.uptLabelM(self)
	end

	return 
end
input.setText = function (self, text)
	self.content = utf8strs(text)

	self.uptLabelM(self)

	return 
end
input.getText = function (self)
	local str = ""

	for i, v in ipairs(self.content) do
		if type(v) == "string" then
			str = str .. v
		else
			str = str .. (v.content or v.text or "")
		end
	end

	return str
end
input.getRichText = function (self)
	local ret = {}
	local str = ""

	for i, v in ipairs(self.content) do
		if type(v) == "string" then
			str = str .. ((self.password and "*") or v)
		else
			if str ~= "" then
				ret[#ret + 1] = str
			end

			str = ""
			ret[#ret + 1] = {
				v.content or v.text or ""
			}
		end
	end

	if str ~= "" then
		ret[#ret + 1] = str
	end

	return ret
end
input.getTextForListenner = function (self)
	local str = ""

	for i, v in ipairs(self.content) do
		if type(v) == "string" then
			str = str .. v
		else
			str = str .. "ÎÒ"
		end
	end

	return str
end
input.setString = function (self, ...)
	self.setText(self, ...)

	return 
end
input.getString = function (self)
	return self.getText(self)
end
input.clear = function (self)
	self.setText(self, "")

	return 
end
input.isInputting = function (self)
	return self.inputting
end
input.showMask = function (self, b)
	if self.mask then
		self.mask:removeSelf()

		self.mask = nil
	end

	if b then
		self.mask = display.newNode():addto(display.getRunningScene(), an.z.input):anchor(0.5, 0.5):center():size(display.width, display.height)

		self.mask:setTouchEnabled(true)
		self.mask:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				self:stopInput()
			end

			return 
		end)
	end

	return 
end
input.showTestKeyboard = function (self, b)
	if device.platform ~= "windows" and device.platform ~= "mac" then
		return 
	end

	if b == (self.testKeyboard ~= nil) then
		return 
	end

	if b then
		local scene = display.getRunningScene()
		self.testKeyboard = display.newColorLayer(cc.c4b(255, 0, 0, 128)):size(display.width, testh):add2(scene, an.z.input)

		self.testKeyboard:runForever(transition.sequence({
			cc.DelayTime:create(0.1),
			cc.CallFunc:create(function ()
				if self.testKeyboard then
					self.testKeyboard:pos(0, -scene:getPositionY())
				end

				return 
			end)
		}))
		an.newLabel("Èí¼üÅÌ", 30, 2).anchor(slot3, 0.5, 0.5):pos(self.testKeyboard:centerPos()):add2(self.testKeyboard)

		return 
	end

	self.testKeyboard:removeSelf()

	self.testKeyboard = nil
end
input.checkBgShow = function (self, b)
	if not self.bg then
		return 
	end

	if self.bgIsPressShow and not b then
		self.bg:hide()
	else
		self.bg:show()
	end

	return 
end
input.showCursor = function (self, isshow)
	self.cursor:stopAllActions()
	self.cursor:setVisible(isshow)

	if isshow then
		self.cursor:run(cc.RepeatForever:create(transition.sequence({
			cc.Hide:create(),
			cc.DelayTime:create(0.3),
			cc.Show:create(),
			cc.DelayTime:create(0.3)
		})))
	end

	return 
end
input.uptCursor = function (self)
	self.cursor:pos(math.min(self.label.widthCnt, self.getw(self)), self.cursor:getPositionY())

	return 
end
input.showTip = function (self, isshow)
	if not self.params.tip or not unpack(self.params.tip) then
		return 
	end

	if not self.tip then
		self.tip = an.newLabel(unpack(self.params.tip)):anchor(0.5, 0.5):pos(self.centerPos(self)):add2(self)
	end

	self.tip:setVisible(isshow and #self.content == 0)

	return 
end
input.setKeyboardVisable = function (self, b)
	if b then
		self.listener:attachWithIME()
	else
		self.listener:detachWithIME()
	end

	self.showTestKeyboard(self, b)
	self.keyboardVisableCallback(self, b)

	return 
end
input.keyboardVisableCallback = function (self, b)
	if b then
		if device.platform == "android" then
			luaj.callStaticMethod(platformSdk:getPackageName() .. "Mir2", "getKeyboardHeight", {
				function (height)
					if not self.inputting then
						return 
					end

					height = tonumber(height) or 0

					if height ~= 0 or false then
						self:callback({
							duration = 0.3,
							type = "keyboardWillShow",
							eh = height/display.contentScaleFactor
						})
					end

					return 
				end
			})
		elseif device.platform == "windows" or device.platform == "mac" then
			self.callback(testh, {
				duration = 0.3,
				type = "keyboardWillShow",
				eh = testh
			})
		end
	else
		self.callback(self, {
			duration = 0.3,
			type = "keyboardWillHide"
		})

		if device.platform == "android" then
			luaj.callStaticMethod(platformSdk:getPackageName() .. "Mir2", "cancelGetKeyboardHeight")
		end
	end

	return 
end
input.startInput = function (self)
	self.inputting = true

	self.checkBgShow(self, true)
	self.showMask(self, true)
	self.showTestKeyboard(self, true)
	self.showCursor(self, true)
	self.showTip(self, false)
	self.uptCursor(self)
	self.listener:setContentText(self.getTextForListenner(self))
	self.listener:attachWithIME()
	self.keyboardVisableCallback(self, true)

	if self.start_call then
		self.start_call()
	end

	return 
end
input.stopInput = function (self)
	self.inputting = false

	self.checkBgShow(self, false)
	self.showMask(self, false)
	self.showTestKeyboard(self, false)
	self.showCursor(self, false)
	self.showTip(self, true)
	self.listener:setContentText(self.getTextForListenner(self))
	self.listener:detachWithIME()

	if self.params.keyboardEx then
		self.params.keyboardEx:remove()
	end

	self.keyboardVisableCallback(self, false)

	if self.stop_call then
		self.stop_call(self)
	end

	return 
end

return input
