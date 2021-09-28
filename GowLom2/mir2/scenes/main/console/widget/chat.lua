local common = import("...common.common")
local itemInfo = import("...common.itemInfo")
local chatPos = import("...common.chatPos")
local chatItem = import("...common.chatItem")
local keyboardEx = import("...common.keyboardEx")
local frameSize = 2
local widthMax = display.width
local widthMin = 100
local heightMax = 300
local heightMin = 50
local fontSizeMax = 24
local fontSizeMin = 10
local chat = class("panelMainChat", function ()
	return display.newNode()
end)

table.merge(slot12, {
	config,
	data,
	frame,
	input,
	scroll,
	newMark,
	sayerNode,
	buf,
	default = {
		fontSize = 18,
		chatByteLimit = 75,
		h = 120,
		enableTouch = 1,
		w = 300,
		showFrame = 1,
		enableInput = 1
	}
})

chat.ctor = function (self, config, data)
	data.w = data.w or self.default.w
	data.h = data.h or self.default.h
	data.fontSize = data.fontSize or self.default.fontSize
	data.enableTouch = data.enableTouch or self.default.enableTouch
	data.enableInput = data.enableInput or self.default.enableInput
	data.showFrame = data.showFrame or self.default.showFrame
	self.data = data

	self.size(self, data.w, data.h):anchor(0.5, 0.5):pos(data.x, data.y)

	self.default.chatByteLimit = chatByteLimit

	self.loadFrame(self)
	self.loadScroll(self)
	self.loadInput(self)

	return 
end
chat.getEditNode = function (self)
	local node = display.newNode():size(500, 170)
	local cnt = 0
	local space = 150
	local begin = 20

	local function addToggle(key, name, func)
		local pos = cc.p(cnt*space + 30, node:geth() - 20)
		local btn = an.newBtn(res.getuitex(2, 228), function ()
			self.data[key] = (self.data[key] == 0 and 1) or 0

			func(self.data[key] == 1)

			return 
		end, {
			support = "easy",
			scale = 2,
			select = {
				res.getuitex(2, 229),
				manual = externHandle
			}
		}).anchor(slot4, 0, 0.5):pos(pos.x, pos.y):add2(node)

		if self.data[key] == 1 then
			btn.select(btn)
		end

		an.newLabel(name, 20, 1, {
			color = cc.c3b(0, 255, 255)
		}):add2(node):pos(pos.x + 40, pos.y):anchor(0, 0.5)

		cnt = cnt + 1

		return 
	end

	fontSizeMin("enableTouch", "可触摸", function (b)
		self:loadScroll()

		return 
	end)
	fontSizeMin("enableInput", "可输入", function (b)
		self:loadScroll()
		self:loadInput()

		return 
	end)
	fontSizeMin("showFrame", "显示外框", function (b)
		self:loadFrame()

		return 
	end)

	local cnt = 0
	local space = 45
	local begin = 60

	local function addSlider(key, name, valueMax, valueMin)
		local num = an.newLabel("", 16, 1, {
			color = cc.c3b(0, 255, 255)
		}):add2(node):anchor(0, 0.5):pos(420, node:geth() - begin - cnt*space)

		local function upt(uptUI, from)
			num:setString(name .. "(" .. self.data[key] .. ")")

			if uptUI then
				if key == "w" or key == "h" then
					self:size(self.data.w, self.data.h)
					self:_sizeChanged()

					if self.frame then
						self.frame:size(self:getContentSize()):pos(self:centerPos())
					end
				end

				if from == "end" then
					self:loadScroll()
					self:loadInput()
				end
			end

			return 
		end

		slot5()

		local slider = an.newSlider(res.gettex2("pic/common/sliderBg.png"), res.gettex2("pic/common/sliderBar.png"), res.gettex2("pic/common/sliderBlock.png"), {
			value = (self.data[key] - valueMin)/(valueMax - valueMin),
			valueChange = function (value)
				local num = (valueMax - valueMin)*value + valueMin
				self.data[key] = math.modf(num)

				upt(true, "change")

				return 
			end,
			valueChangeEnd = function (value)
				local num = (valueMax - valueMin)*value + valueMin
				self.data[key] = math.modf(num)

				upt(true, "end")

				return 
			end
		}).add2(slot6, node):anchor(0, 0.5):pos(20, node:geth() - begin - cnt*space)
		cnt = cnt + 1

		return 
	end

	slot9("w", "宽", widthMax, widthMin)
	addSlider("h", "高", heightMax, heightMin)
	addSlider("fontSize", "字号", fontSizeMax, fontSizeMin)

	return node
end
chat.loadFrame = function (self)
	if self.frame then
		self.frame:removeSelf()

		self.frame = nil
	end

	if self.data.showFrame == 1 then
		self.frame = display.newScale9Sprite(res.getframe2("pic/console/chat.png")):size(self.getContentSize(self)):pos(self.centerPos(self)):add2(self, 2)
	end

	return 
end
chat.loadScroll = function (self)
	if self.scroll then
		self.scroll:removeSelf()

		self.scroll = nil
	end

	local beginy = (self.data.enableInput == 1 and 18) or 0
	local maxLine = 20
	self.scroll = an.newScroll(frameSize, frameSize + beginy, self.getw(self) - frameSize*2, self.geth(self) - beginy - frameSize, {
		labelM = {
			self.data.fontSize,
			1,
			params = {
				bufferChannel = 11,
				maxLine = maxLine,
				doubleClickLine_call = self.data.enableTouch == 1 and function (msg)
					if not msg or msg.user == "" then
						return 
					end

					if g_data.chat.style.channel == "私聊" and g_data.chat.style.target == msg.user then
						return 
					end

					common.changeChatStyle({
						{
							"channel",
							"私聊"
						},
						{
							"target",
							msg.user
						}
					})

					return 
				end
			}
		}
	}).addTo(slot3, self, 1)

	self.scroll:enableTouch(self.data.enableTouch == 1)
	self.scroll:setListenner(function (event)
		if event.name == "moved" then
			local x, y = self.scroll:getScrollOffset()

			if self.scroll:getScrollSize().height - self.scroll:geth() < y + self.scroll.labelM.wordSize.height then
				self:hideNewMark()
			end
		end

		return 
	end)

	self.buf = newList()
	local msgs = g_data.chat.getMsgs(slot3, common.getAllOpenChatChannel(), maxLine)

	for i, v in ipairs(msgs) do
		self.addMsg(self, v)
	end

	return 
end
chat.loadInput = function (self)
	local oldstr = ""

	if self.input and self.input.keyboard then
		oldstr = self.input.keyboard:getText()

		if common.hasRich(oldstr) then
			oldstr = ""
		end
	end

	if self.input then
		self.input:removeSelf()

		self.input = nil
	end

	if self.data.enableInput == 0 then
		return 
	end

	self.input = display.newColorLayer(cc.c4b(0, 0, 0, 128)):pos(frameSize, frameSize):size(self.getw(self) - frameSize*2, 18):add2(self)

	self.input:scalex((self.getw(self) - frameSize*2)/self.input:getw())

	local channel = g_data.chat.style.channel
	local filenames = {
		行会 = "guild",
		喊话 = "loudly",
		私聊 = "single",
		战队 = "clan",
		千里传音 = "far",
		组队 = "group",
		附近 = "near"
	}
	local filename = "pic/console/" .. (filenames[channel] or "far") .. ".png"
	local channelBtn = res.get2(filename):anchor(0, 0):pos(0, -3):add2(self.input)

	channelBtn.scale(channelBtn, (self.input:geth() + 6)/channelBtn.geth(channelBtn)):enableClick(function ()
		local p = channelBtn:convertToWorldSpace(cc.p(channelBtn:getw()/2, channelBtn:geth()))

		common.chatChannelChoose(true):anchor(0.5, 0):pos(p.x, p.y):add2(main_scene.ui, main_scene.ui.z.chatChannel)

		return 
	end, {
		size = cc.size(channelBtn.getw(slot5), 17),
		anchor = cc.p(0, 1),
		pos = cc.p(0, 0)
	})

	local labelw = channelBtn.getw(channelBtn)*channelBtn.getScale(channelBtn)

	if channel == "私聊" then
		local text = nil

		if not g_data.chat.style.target or g_data.chat.style.target == "" then
			text = "(点击设置)"
		else
			text = "" .. g_data.chat.style.target
		end

		local label = an.newLabel(text, 16, 1, {
			color = cc.c3b(255, 255, 0)
		}):pos(labelw, -1):add2(self.input)

		label.enableClick(label, function ()
			g_data.mark:addNear(main_scene.ground.map:getHeroNameList())

			local msgbox = nil
			msgbox = an.newMsgbox("\n请输入对方名字.\n", function ()
				common.changeChatStyle({
					{
						"target",
						msgbox.input:getString()
					}
				})

				return 
			end, {
				disableScroll = true,
				input = 20,
				inputList = {
					"<猜你要选>",
					g_data.mark.getNames(slot6)
				}
			})

			msgbox.input:setString(g_data.chat.style.target or "")

			return 
		end, {
			size = cc.size(label.getw(slot8), 17),
			anchor = cc.p(0, 1),
			pos = cc.p(0, 0)
		})

		labelw = labelw + label.getw(label)
	end

	if g_data.chat.style.input == "keyboard" then
		local mac_use_source_keyboard = true

		if (device.platform == "mac" or device.platform == "windows") and mac_use_source_keyboard then
			self.input.keyboard = cc.ui.UIInput.new({
				image = "res/public/empty.png",
				UIInputType = 1,
				size = cc.size(self.input:getw() - labelw, 25),
				listener = function (type)
					if type == "changed" then
						local text = self.input.keyboard:getText()

						if string.byte(string.reverse(text)) == string.byte("\\") then
							self.input.keyboard:setText(string.sub(text, 1, #text - 1))
							self:say(self.input.keyboard:getText())
						end
					elseif type == "return" then
						self:say(self.input.keyboard:getText())
					end

					return 
				end
			}).anchor(slot9, 0, 0):pos(labelw, -6):add2(self.input)

			self.input.keyboard:setText(oldstr)
			self.setKeypadEnabled(self, true)
			self.addNodeEventListener(self, cc.KEYPAD_EVENT, function (event)
				if event.key == 32 then
					self:say(self.input.keyboard:getText())
				end

				return 
			end)
		else
			self.input.keyboard = an.newInput(slot6, -6, self.input:getw() - labelw - 2, 25, self.default.chatByteLimit, {
				label = {
					oldstr,
					16,
					1
				},
				return_call = function ()
					self:say()

					return 
				end,
				show_call = function (dur, y, worldY)
					main_scene:stopAllActions()
					main_scene:moveTo(dur, 0, y/2)
					main_scene.ui:stopAllActions()
					main_scene.ui:moveTo(dur, 0, y/2)
					keyboardEx.create(self.input.keyboard):pos(0, y/2 + worldY)

					return 
				end,
				hide_call = function (dur)
					main_scene:stopAllActions()
					main_scene:moveTo(dur, 0, 0)
					main_scene.ui:stopAllActions()
					main_scene.ui:moveTo(dur, 0, 0)

					return 
				end,
				getWorldY_call = function ()
					return self:getPositionY() - self:geth()*self:getAnchorPoint().y
				end,
				keyboardEx = {
					get = function ()
						return keyboardEx.create(self.input.keyboard)
					end,
					remove = function ()
						return keyboardEx.destory()
					end
				}
			}).anchor(slot9, 0, 0):addto(self.input)
		end
	end

	return 
end
chat.hideSayer = function (self)
	if self.sayerNode then
		self.sayerNode:removeSelf()

		self.sayerNode = nil
	end

	return 
end
chat.showSayer = function (self, msg)
	self.hideSayer(self)

	local size = cc.size(self.getw(self), self.data.fontSize + 2)
	self.sayerNode = display.newClippingRegionNode(cc.rect(0, 0, size.width, size.height)):pos(0, self.geth(self) - frameSize - size.height + 1):add2(self, 1)
	local c1, c2 = self.getColor(self, msg)

	display.newColorLayer(cc.c4b(0, 255, 255, 188)):size(size):add2(self.sayerNode)

	local user = an.newLabel(msg.user .. ":", self.data.fontSize, 1, {
		color = c1,
		sc = c2
	}):anchor(0, 0.5):pos(5, size.height/2):add2(self.sayerNode)

	for i, v in ipairs(msg.data) do
		if v.type == "voice" then
			local bgkey = (msg.channel == "私聊" and ((msg.fromClient and "私聊self") or "私聊")) or msg.channel

			an.newVoiceBubble(size.height, bgkey, v.dur, v.msgID, v.state, true):anchor(0, 0.5):pos(user.getPositionX(user) + user.getw(user) + 3, size.height/2):add2(self.sayerNode)

			break
		end
	end

	return 
end
chat.getColor = function (self, msg)
	local color = msg.color
	local bgColor = msg.bgColor

	if msg.channel == "附近" then
		bgColor = color
		color = bgColor
	elseif color == 219 and (bgColor == 255 or bgColor == 256) then
		bgColor = 0
		color = 250
	end

	local c1, c2 = nil

	if type(color) == "number" then
		c1 = def.colors.get(color)
	else
		c1 = color
	end

	if type(bgColor) == "number" then
		c2 = def.colors.get(bgColor)
	else
		c2 = bgColor
	end

	return c1, c2
end
chat.addMsg = function (self, msg)
	self.buf.pushBack(msg)

	return 
end
chat.updateAddMsg = function (self, msg)
	if not common.getChatChannelIsOpen(msg.channel) then
		return 
	end

	local c1, c2 = self.getColor(self, msg)
	local bgColor = nil
	local chatBgAlpha = 180

	if msg.channel == "千里传音" or (msg.channel == "系统" and c2.r ~= 0 and c2.g == 0 and c2.b == 0 and c1.r == 255 and c1.g == 255 and c1.b == 255) then
		bgColor = cc.c4b(c2.r, c2.g, c2.b, chatBgAlpha)
		c2 = cc.c4b(c2.r, c2.g, c2.b, chatBgAlpha)
	end

	local x, y = self.scroll:getScrollOffset()
	local isInEnd = self.scroll:getScrollSize().height < y + self.scroll:geth() + self.scroll.labelM.wordSize.height

	self.scroll.labelM:nextLine(msg)

	local chatItemScale = 2
	local lines = chatItemScale + 1

	if msg.fromClient == true and msg.user == common.getPlayerName() then
		if type(msg.data[1]) == "string" then
			if string.find(msg.data[1], "/" .. msg.target .. " ") ~= 1 then
				msg.data[1] = "/" .. msg.target .. " " .. msg.data[1]
			end
		else
			table.insert(msg.data, 1, "/" .. msg.target .. " ")
		end
	end

	for i, v in ipairs(msg.data) do
		if v.type == "emoji" then
			self.scroll.labelM:addEmoji(res.gettex2("pic/emoji/" .. v.emoji .. ".png"), common.isBigEmoji(v.emoji))
		elseif v.type == "emojiConvert" then
			self.scroll.labelM:addEmojiForConvert(v.emoji)
		elseif (v.type ~= "voice" or false) and (v.type ~= "pic" or false) then
			if v.type == "pos" then
				self.scroll.labelM:addNode(chatPos.new(chatItemScale, self.scroll.labelM, v, msg.user, self.data.enableTouch == 0), lines)
			elseif v.type == "item" then
				self.scroll.labelM:addNode(chatItem.new(chatItemScale, self.scroll.labelM, v, self.data.enableTouch == 0), lines)
			elseif v.type == "group" then
				local str = v.content

				self.scroll.labelM:addLabel(str, c1, nil, c2, function ()
					local rsb = DefaultClientMessage(CM_JoinGroup)
					rsb.FName = v.name

					MirTcpClient:getInstance():postRsb(rsb)

					return 
				end)
			else
				self.scroll.labelM.addLabel(slot16, v, c1, bgColor, c2)
			end
		end
	end

	if isInEnd then
		self.scroll:setScrollOffset(0, self.scroll:getScrollSize().height - self.scroll:geth())
	else
		self.showNewMark(self)
	end

	return 
end
chat.showNewMark = function (self)
	if not self.newMark then
		self.newMark = res.get2("pic/common/msgNew.png"):add2(self, 1):run(cc.RepeatForever:create(transition.sequence({
			cc.ScaleTo:create(0.5, 0.7),
			cc.ScaleTo:create(0.5, 1)
		}))):enableClick(function ()
			self.newMark:hide()
			self.scroll:setScrollOffset(0, self.scroll:getScrollSize().height - self.scroll:geth())

			return 
		end)
	end

	self.newMark.show(slot1):pos(self.getw(self) - frameSize - 20, ((self.input and self.input:geth()) or 0) + 24 + frameSize)

	return 
end
chat.hideNewMark = function (self)
	if self.newMark then
		self.newMark:hide()
	end

	return 
end
chat.say = function (self, text)
	if not self.input then
		return 
	end

	if common.say(text or self.input.keyboard:getRichText()) then
		self.input.keyboard:setText("")
	end

	return 
end
chat.update = function (self, dt)
	while self.scroll.labelM.maxLine < self.buf.size() do
		self.buf.popFront()
	end

	if not self.buf.isEmpty() then
		self.updateAddMsg(self, self.buf.popFront())
	end

	return 
end

return chat
