local label = import(".label")
local labelM = class("an.labelM", function ()
	return display.newNode()
end)

table.merge(slot1, {
	font,
	fontSize,
	maxWidth,
	stokeSize,
	wordSize,
	subWordNum,
	lines,
	widthCnt,
	scroll,
	manualNextLine,
	centerShow,
	clickLine_call,
	doubleClickLine_call,
	maxLine
})

labelM.ctor = function (self, maxWidth, fontSize, stokesize, params)
	fontSize = fontSize and math.round(fontSize)
	params = params or {}
	self.font = params.font or display.DEFAULT_TTF_FONT
	self.fontSize = fontSize or display.DEFAULT_TTF_FONT_SIZE
	self.scroll = params.scroll
	self.manualNextLine = params.manual
	self.clickLine_call = params.clickLine_call
	self.doubleClickLine_call = params.doubleClickLine_call
	self.centerShow = params.center
	self.maxLine = params.maxLine
	self.sd = params.sd
	self.bufferChannel = params.bufferChannel
	self.maxWidth = maxWidth
	self.stokeSize = stokesize
	self.lines = {}
	self.wordSize = cc.size(label.string2size("Œ“", self.font, self.fontSize, stokesize))
	self.widthCnt = maxWidth + 1
	self.subWordNum = params.subWordNum

	if self.subWordNum and 0 < self.subWordNum then
		self.maxWidth = maxWidth - self.subWordNum*self.wordSize.width
	end

	return 
end
labelM.clear = function (self)
	for i, v in ipairs(self.lines) do
		v.removeSelf(v)
	end

	self.lines = {}
	self.widthCnt = self.maxWidth + 1

	if self.scroll then
		self.scroll:setScrollSize(self.scroll:getw(), self.scroll:geth())
		self.anchor(self, 0, 1):pos(0, self.scroll:getScrollSize().height)
	end

	return self
end
labelM.setFontSize = function (self, fontSize)
	local oldWordSize = self.wordSize
	self.fontSize = math.round(fontSize)
	self.wordSize = cc.size(label.string2size("Œ“", self.font, self.fontSize, self.stokeSize))

	if oldWordSize and self.subWordNum and 0 < self.subWordNum then
		self.maxWidth = self.maxWidth + self.subWordNum*(oldWordSize.width - self.wordSize.width)
	end

	return 
end
labelM.findVoiceBubbleForMsgID = function (self, msgID)
	for i, v in ipairs(self.lines) do
		for i2, v2 in ipairs(v.getChildren(v)) do
			if v2.__cname == "an.voiceBubble" and v2.msgID == msgID then
				return v2
			end
		end
	end

	return 
end
labelM.findNodeForClassNameAndTag = function (self, name, tag)
	for i, v in ipairs(self.lines) do
		for i2, v2 in ipairs(v.getChildren(v)) do
			if v2.__cname == name and v2.tag == tag then
				return v2
			end
		end
	end

	return 
end
labelM.addEmojiForConvert = function (self, emoji)
	if self.maxWidth < self.widthCnt + self.wordSize.width then
		self.nextLine(self)
	end

	self.addSubLabel_(self, emoji, display.COLOR_WHITE, bgColor, nil, nil, 0)

	return 
end
labelM.addEmoji = function (self, tex, isBigEmoji)
	local node = display.newSprite(tex)

	if not isBigEmoji then
		node.scale(node, self.wordSize.height/node.geth(node))
		self.addNode(self, node, 1)
	else
		self.addNode(self, node, math.ceil(node.geth(node)/self.fontSize) - 1)
	end

	return 
end
labelM.addVoice = function (self, bgkey, dur, msgID, state, readed, clickCallback)
	local voiceBubble = an.newVoiceBubble(self.wordSize.height, bgkey, dur, msgID, state, readed)

	if not self.manualNextLine and self.maxWidth < self.widthCnt + voiceBubble.getw(voiceBubble) then
		self.nextLine(self)
	end

	if clickCallback then
		voiceBubble.enableClick(voiceBubble, clickCallback)
	end

	voiceBubble.anchor(voiceBubble, 0, 0.5):pos(self.widthCnt, self.wordSize.height/2):add2(self.lines[#self.lines])

	self.widthCnt = self.widthCnt + voiceBubble.getw(voiceBubble)

	return voiceBubble
end
labelM.insertNodeToFront = function (self, node, line, tag)
	local lineNum = #self.lines

	self.nextLine(self)
	self.addNode(self, node, line, tag)

	local newLines = {}

	for i = lineNum + 1, #self.lines, 1 do
		newLines[#newLines + 1] = self.lines[i]
		self.lines[i] = nil
	end

	for i = #newLines, 1, -1 do
		table.insert(self.lines, 1, newLines[i])
	end

	local y = 0

	for i = #self.lines, 1, -1 do
		local v = self.lines[i]

		v.pos(v, v.getPositionX(v), y)

		y = y + self.wordSize.height
	end

	return 
end
labelM.addNode = function (self, node, line, tag)
	if not self.manualNextLine and self.maxWidth < self.widthCnt + node.getw(node)*node.getScale(node) then
		self.nextLine(self)
	end

	node.tag = tag

	node.anchor(node, 0, 1):pos(self.widthCnt, self.wordSize.height):add2(self.lines[#self.lines])

	self.widthCnt = self.widthCnt + node.getw(node)*node.getScale(node)

	for i = 2, line, 1 do
		self.nextLine(self)
	end

	return 
end
labelM.addLabel = function (self, text, color, bgColor, strokeColor, clickCallback, params)
	local strs = string.split(text, "\n")

	for i, v in ipairs(strs) do
		if v ~= "" then
			if self.manualNextLine then
				self.addSubLabel_(self, v, color, bgColor, strokeColor, clickCallback, params)
			else
				self.addLabel_(self, v, color, bgColor, strokeColor, clickCallback, params)
			end
		end

		if i < #strs then
			self.nextLine(self)
		end
	end

	return self
end
labelM.nextLine = function (self, params)
	for i, v in ipairs(self.lines) do
		v.pos(v, v.getPositionX(v), v.getPositionY(v) + self.wordSize.height)
	end

	local line = display.newNode():size(self.maxWidth, self.wordSize.height):addto(self)

	if self.clickLine_call or self.doubleClickLine_call then
		if self.doubleClickLine_call then
			local y, handler, clicked = nil

			local function click()
				if clicked then
					if self.doubleClickLine_call then
						self.doubleClickLine_call(params)
					end
				elseif self.clickLine_call then
					self.clickLine_call(params)
				end

				clicked = nil
				handler = nil

				return 
			end

			line.setTouchEnabled(slot2, true)
			line.setTouchSwallowEnabled(line, false)
			line.addNodeEventListener(line, cc.NODE_TOUCH_EVENT, function (event)
				local touchInBtn = line:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y))

				if event.name == "began" then
					if handler then
						clicked = true

						return false
					end

					y = event.y

					return true
				elseif event.name == "ended" and math.abs(event.y - y) < line:geth() then
					handler = scheduler.performWithDelayGlobal(click, 0.25)
				end

				return 
			end)
		else
			local y = nil

			line.setTouchEnabled(slot2, true)
			line.setTouchSwallowEnabled(line, false)
			line.addNodeEventListener(line, cc.NODE_TOUCH_EVENT, function (event)
				local touchInBtn = line:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y))

				if event.name == "began" then
					y = event.y

					return true
				elseif event.name == "ended" and math.abs(event.y - y) < line:geth() then
					self.clickLine_call(params)
				end

				return 
			end)
		end
	end

	self.lines[#self.lines + 1] = line

	if self.maxLine and self.maxLine < #self.lines then
		self.lines[1].removeSelf(slot3)
		table.remove(self.lines, 1)
	end

	self.widthCnt = 0
	local h = 0

	for i, v in ipairs(self.lines) do
		h = h + v.geth(v)
	end

	self.size(self, self.maxWidth, h)

	if self.scroll then
		self.scroll:setScrollSize(self.getw(self), self.geth(self))
		self.anchor(self, 0, 1):pos(0, self.scroll:getScrollSize().height)
	end

	return self
end
labelM.setCurLineWidthCnt = function (self, cnt)
	self.widthCnt = cnt

	return 
end
labelM.isNotOutstrip_ = function (self, text, addChar)
	addChar = addChar or 0

	return self.widthCnt + (string.utf8len(text) + addChar)*self.wordSize.width <= self.maxWidth
end
labelM.addLabel_ = function (self, text, color, bgColor, strokeColor, clickCallback, params)
	local words = utf8strs(text)

	if self.widthCnt + #words*self.wordSize.width <= self.maxWidth then
		return self.addSubLabel_(self, text, color, bgColor, strokeColor, clickCallback, params)
	end

	if self.maxWidth < self.widthCnt + label.string2size(words[1], self.font, self.fontSize, self.stokeSize) then
		self.nextLine(self)
	end

	local tmp = {}
	local i = 1

	while i <= #words do
		tmp[#tmp + 1] = words[i]

		if self.widthCnt + (#tmp + 1)*self.wordSize.width >= self.maxWidth or false then
			local tmpStr = table.concat(tmp)
			local tmpCnt = label.string2size(tmpStr, self.font, self.fontSize, self.stokeSize)

			while self.widthCnt + tmpCnt < self.maxWidth do
				i = i + 1

				if #words < i then
					break
				end

				tmp[#tmp + 1] = words[i]
				tmpStr = table.concat(tmp)
				tmpCnt = tmpCnt + label.string2size(words[i], self.font, self.fontSize, self.stokeSize)
			end

			if i <= #words then
				i = i - 1
				tmp[#tmp] = nil
				tmpStr = table.concat(tmp)
			end

			self.addSubLabel_(self, tmpStr, color, bgColor, strokeColor, clickCallback, params)

			if i < #words then
				self.nextLine(self)
			end

			tmp = {}
		end

		i = i + 1
	end

	if 0 < #tmp then
		self.addSubLabel_(self, table.concat(tmp), color, bgColor, strokeColor, clickCallback, params)
	end

	return 
end
labelM.addSubLabel_ = function (self, text, color, bgColor, strokeColor, clickCallback, stokeSize, params)
	local l = label.new(text, self.fontSize, stokeSize or self.stokeSize, {
		color = color,
		sc = strokeColor,
		bufferChannel = self.bufferChannel,
		sd = self.sd
	}):addTo(self.lines[#self.lines])
	self.lines[#self.lines].labelL = self.lines[#self.lines].labelL or {}
	self.lines[#self.lines].labelL[#self.lines[#self.lines].labelL + 1] = l

	if self.centerShow then
		l.pos(l, self.getw(self)/2 + self.widthCnt/2, 0):anchor(0.5, 0)

		for k, v in pairs(self.lines[#self.lines].labelL) do
			if k ~= #self.lines[#self.lines].labelL then
				v.pos(v, v.getPositionX(v) - l.getContentSize(l).width/2, v.getPositionY(v)):anchor(0.5, 0)
			end
		end
	else
		l.pos(l, self.widthCnt, 0)
	end

	if params and params.tag then
		l.setTag(l, params.tag)
	end

	if bgColor then
		local bgSize = l.getContentSize(l)
		bgSize.width = bgSize.width
		bgSize.height = bgSize.height - 4

		if bgColor.a == nil then
			bgColor.a = 255
		end

		local color = display.newColorLayer(bgColor):size(bgSize):addTo(self.lines[#self.lines], -1)

		if self.centerShow then
			color.anchor(color, 0.5, 0):pos(self.getw(self)/2, 0)
		else
			color.pos(color, self.widthCnt, 0)
		end
	end

	if clickCallback then
		local callback, noUnderLine, easyTouch, size, ani = nil

		if type(clickCallback) == "table" then
			callback = clickCallback.callback
			noUnderLine = clickCallback.noUnderLine
			easyTouch = clickCallback.easyTouch
			ani = clickCallback.ani

			if ani then
				l.anchor(l, 0.5, 0.5):pos(self.widthCnt + l.getw(l)/2, self.wordSize.height/2 + 2)
			end

			if clickCallback.addTouchSizeX or clickCallback.addTouchSizeY then
				size = cc.size(l.getw(l) + (clickCallback.addTouchSizeX or 0), l.geth(l) + (clickCallback.addTouchSizeY or 0))
			end
		else
			callback = clickCallback
		end

		l.enableClick(l, callback, {
			support = "easy",
			ani = true,
			size = size
		})

		if not noUnderLine then
			color = color or display.COLOR_WHITE

			l.addUnderline(l, color)
		end
	end

	self.widthCnt = self.widthCnt + l.getContentSize(l).width

	return 
end
labelM.getCurLabel = function (self)
	return self.lines[#self.lines]
end

return labelM
