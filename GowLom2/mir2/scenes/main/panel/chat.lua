local common = import("..common.common")
local itemInfo = import("..common.itemInfo")
local chatPos = import("..common.chatPos")
local chatItem = import("..common.chatItem")
local keyboardEx = import("..common.keyboardEx")
local chat = class("chat", function ()
	return display.newNode()
end)

table.merge(slot5, {
	leftContent,
	content,
	scroll,
	input,
	newMark,
	sayerNode
})

local path = "pic/panels/chat/"
chat.onCleanup = function (self)
	cache.saveSetting(common.getPlayerName(), "chat")

	return 
end
chat.ctor = function (self)
	self._supportMove = true

	self.setNodeEventEnabled(self, true)

	local bg = res.get2("pic/common/black_0.png"):anchor(0, 0):add2(self)

	self.size(self, bg.getw(bg), bg.geth(bg)):anchor(0.5, 0.5):pos(display.cx, display.cy + 67)
	res.get2(path .. "title.png"):add2(bg):pos(bg.getw(bg)/2, bg.geth(bg) - 23)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot2, 1, 1):pos(self.getw(self) - 9, self.geth(self) - 8):addto(self)
	self.loadLeftContent(self)

	return 
end
chat.loadLeftContent = function (self)
	if self.leftContent then
		self.leftContent:removeSelf()
	end

	self.leftContent = an.newScroll(0, 72, 134, 326):add2(self)
	local tabs = {
		"附近",
		"私聊",
		"组队",
		"行会",
		"系统"
	}
	local sprs = {
		"fj",
		"sl",
		"zd",
		"hh",
		"shezhi"
	}

	for i, v in ipairs(tabs) do
		local text = v

		if text == "组队" then
			text = "编组"
		end

		local btn = an.newBtn(res.gettex2("pic/common/btn60.png"), function ()
			common.setChatChannelIsOpen(v, not common.getChatChannelIsOpen(v))

			return 
		end, {
			support = "scroll",
			label = {
				text,
				20,
				0,
				{
					color = def.colors.btn
				}
			},
			pressImage = res.gettex2("pic/common/btn61.png"),
			spriteOffset = cc.p(10, 0)
		}).anchor(slot9, 0, 0.5):add2(self.leftContent):pos(18, self.leftContent:geth() - 23 - (i - 1)*52)

		if i < #tabs then
			res.get2("pic/common/button_click.png"):add2(btn):pos(24, btn.geth(btn)/2)

			if common.getChatChannelIsOpen(v) then
				res.get2("pic/common/button_click02.png"):add2(btn):pos(24, btn.geth(btn)/2)
			end
		end
	end

	self.loadContent(self)

	return 
end
chat.loadContent = function (self)
	local oldstr = ""

	if self.input and self.input.keyboard then
		oldstr = self.input.keyboard:getText()
	end

	if self.content then
		self.content:removeSelf()
	end

	self.scroll = nil
	self.input = nil
	self.sayerNode = nil
	self.content = display.newNode():pos(144, 20):size(480, 380):add2(self)
	local scrollbg = display.newColorLayer(cc.c4b(255, 255, 255, 255)):size(self.content:getw(), self.content:geth() - 50):pos(0, 50):add2(self.content)
	local maxLine = 60
	local frameSize = 2
	self.scroll = an.newScroll(0, 0, scrollbg.getw(scrollbg), scrollbg.geth(scrollbg), {
		labelM = {
			22,
			0,
			params = {
				maxLine = maxLine,
				doubleClickLine_call = function (msg)
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
	}).addTo(slot5, scrollbg)

	self.scroll:setListenner(function (event)
		if event.name == "moved" then
			local x, y = self.scroll:getScrollOffset()

			if self.scroll:getScrollSize().height - self.scroll:geth() < y + self.scroll.labelM.wordSize.height then
				self:hideNewMark()
			end
		end

		return 
	end)

	local msgs = g_data.chat.getMsgs(slot5, common.getAllOpenChatChannel(), maxLine)

	for i, v in ipairs(msgs) do
		self.addMsg(self, v)
	end

	self.loadInput(self, oldstr)

	return 
end
chat.loadInput = function (self, oldstr)
	local xPosOrigin = -85
	oldstr = oldstr or ""

	if self.input and self.input.keyboard then
		oldstr = self.input.keyboard:getText()

		if common.hasRich(oldstr) then
			oldstr = ""
		end
	end

	if self.input then
		self.input:removeSelf()
	end

	self.input = display.newNode():size(self.content:getw() - 30, 50):pos(0, -8):add2(self.content)

	display.newScale9Sprite(res.getframe2("pic/scale/edit.png")):size(350, 40):anchor(0, 0.5):pos(xPosOrigin + 90, self.input:geth()/2):add2(self.input)

	local filenames = {
		行会 = "hanghui",
		喊话 = "hanhua",
		私聊 = "siliao",
		战队 = "zhandui",
		千里传音 = "ql",
		组队 = "bz",
		附近 = "fujin"
	}
	local channelBtn = nil
	channelBtn = an.newBtn(res.gettex2("pic/common/btn70.png"), function ()
		common.chatChannelChoose():anchor(0.5, 0):pos(channelBtn:getPositionX(), channelBtn:geth() + 3):add2(self.input)

		return 
	end, {
		sprite = res.gettex2("pic/panels/chat/" .. (filenames[g_data.chat.style.channel] or "pd") .. ".png"),
		pressImage = res.gettex2("pic/common/btn71.png")
	}).add2(slot5, self.input):pos(xPosOrigin + 40, self.input:geth()/2)
	local labelw = xPosOrigin + 100
	local labelWidth = 320
	local channel = g_data.chat.style.channel

	if channel == "私聊" then
		local text = nil

		if not g_data.chat.style.target or g_data.chat.style.target == "" then
			text = "(点击设置)"
		else
			text = "" .. g_data.chat.style.target
		end

		label = an.newLabel(text, 20, 1, {
			color = cc.c3b(255, 255, 0)
		}):anchor(0, 0.5):pos(labelw, self.input:geth()/2):add2(self.input)

		label:enableClick(function ()
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
			size = cc.size(label.getw(slot14), 12),
			anchor = cc.p(0, 1),
			pos = cc.p(0, 0)
		})

		labelw = labelw + label:getw() + 5
		labelWidth = labelWidth - label:getw() - 5
	end

	self.input.keyboard = an.newInput(labelw, self.input:geth()/2 - 2, labelWidth, 28, chatByteLimit, {
		label = {
			oldstr,
			20,
			1
		},
		return_call = function ()
			self:say()

			return 
		end,
		getWorldY_call = function ()
			return self:getPositionY() - self:geth()*self:getAnchorPoint().y + self.content:getPositionY()
		end,
		keyboardEx = {
			get = function ()
				return keyboardEx.create(self.input.keyboard)
			end,
			remove = function ()
				return keyboardEx.destory()
			end
		}
	}).anchor(slot9, 0, 0.5):addto(self.input, 0)

	local function btnSendCallback()
		if common.say(self.input.keyboard:getRichText()) then
			self.input.keyboard:setText("")
		end

		return 
	end

	local btnSend = an.newBtn(res.gettex2("pic/common/btn70.png"), slot8, {
		label = {
			"发送",
			20,
			0,
			{
				color = def.colors.btn
			}
		},
		pressImage = res.gettex2("pic/common/btn71.png")
	}):add2(self.input)
	local posx = self.input:getw() + btnSend.getw(btnSend)/2 + xPosOrigin

	btnSend.pos(btnSend, posx, self.input:geth()/2)

	local function btnHistoryCallback()
		local msg = g_data.chat:getSendMsgHistory()

		if not self.input or not self.input.keyboard or not msg then
			return 
		end

		self.input.keyboard:setText(msg)

		return 
	end

	local btnHistory = an.newBtn(res.gettex2("pic/common/btn100.png"), slot11, {
		sprite = res.gettex2("pic/common/up.png"),
		pressImage = res.gettex2("pic/common/btn101.png")
	}):add2(self.input)
	posx = self.input:getw() + btnSend.getw(btnSend) + btnHistory.getw(btnHistory)/2 + 10 + xPosOrigin

	btnHistory.pos(btnHistory, posx, self.input:geth()/2)

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
	if not common.getChatChannelIsOpen(msg.channel) then
		return 
	end

	self.hideSayer(self)

	local size = cc.size(self.content:getw(), 24)
	self.sayerNode = display.newClippingRegionNode(cc.rect(0, 0, size.width, size.height)):pos(0, self.content:geth() - size.height + 2):add2(self.content, 1)
	local c1, c2 = self.getColor(self, msg)

	display.newColorLayer(cc.c4b(0, 255, 255, 188)):size(size):add2(self.sayerNode)

	local user = an.newLabel(msg.user .. ":", 22, 1, {
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
	local c1, c2 = nil

	if type(color) == "number" then
		c1 = def.colors.get(color)
	else
		c1 = color
	end

	if type(bgColor) == "number" then
		c2 = def.colors.get(bgColor, true)
	elseif bgColor then
		c2 = cc.c4b(bgColor.r, bgColor.g, bgColor.b, 255)
	end

	return c1, c2
end
chat.addMsg = function (self, msg)
	if not common.getChatChannelIsOpen(msg.channel) then
		return 
	end

	local c1, c2 = self.getColor(self, msg)
	local x, y = self.scroll:getScrollOffset()
	local isInEnd = self.scroll:getScrollSize().height < y + self.scroll:geth() + self.scroll.labelM.wordSize.height

	self.scroll.labelM:nextLine(msg)

	local chatItemScale = 2
	local lines = chatItemScale + 1

	if msg.fromClient == true and msg.user == common.getPlayerName() then
		if type(msg.data[1]) == "string" then
			if string.find(msg.data[1], "/" .. msg.target) ~= 1 then
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
				self.scroll.labelM:addNode(chatPos.new(chatItemScale, self.scroll.labelM, v, msg.user), lines)
			elseif v.type == "item" then
				self.scroll.labelM:addNode(chatItem.new(chatItemScale, self.scroll.labelM, v), lines)
			elseif v.type == "group" then
				local str = v.content

				self.scroll.labelM:addLabel(str, c1, nil, c2, function ()
					local rsb = DefaultClientMessage(CM_JoinGroup)
					rsb.FName = v.name

					MirTcpClient:getInstance():postRsb(rsb)

					return 
				end)
			else
				string.gsub(slot13, "\r", "\n")
				self.scroll.labelM:addLabel(v, c1, c2)
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

	self.newMark.show(slot1):pos(self.getw(self) - 50, self.input:geth() + 60)

	return 
end
chat.hideNewMark = function (self)
	if self.newMark then
		self.newMark:hide()
	end

	return 
end
chat.say = function (self)
	if common.say(self.input.keyboard:getText(), self.input.keyboard.content) then
		self.input.keyboard:setText("")
	end

	return 
end

return chat
