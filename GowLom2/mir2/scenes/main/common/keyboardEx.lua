local common = import(".common")
local itemInfo = import(".itemInfo")
local rightBtnW = 45
local edge = 15
local minh = 200
local maxChatItemNum = 1
chatItemNum = 0
local keyboardEx = class("keyboardEx", function ()
	return display.newNode()
end)

table.merge(slot6, {
	input,
	bar,
	content
})

keyboardEx.create = function (input)
	if main_scene.keyboardEx then
		return main_scene.keyboardEx
	end

	main_scene.keyboardEx = keyboardEx.new(input):anchor(0, 1):add2(main_scene, an.z.inputtool)

	return main_scene.keyboardEx
end
keyboardEx.destory = function ()
	if main_scene.keyboardEx then
		main_scene.keyboardEx:removeSelf()

		main_scene.keyboardEx = nil
	end

	return 
end
keyboardEx.ctor = function (self, input)
	local bg = res.get2("pic/keyboard/bar.png"):anchor(0, 0):scalex(display.width/960):add2(self):enableClick(function ()
		return 
	end)

	self.size(slot0, display.width, bg.geth(bg))

	self.input = input
	chatItemNum = self.input.chatItemNum

	self.loadMain(self)
	self.setNodeEventEnabled(self, true)

	return 
end
keyboardEx.onExit = function (self)
	itemInfo.close()

	return 
end
keyboardEx.checkChatItemNum = function (self)
	self.input.chatItemNum = chatItemNum

	if maxChatItemNum <= chatItemNum then
		main_scene.ui:tip("最多只能添加一个道具或者坐标到聊天栏")

		return false
	end

	return true
end
keyboardEx.addRightBtns = function (self)
	an.newBtn(res.gettex2("pic/keyboard/btn11.png"), function ()
		chatItemNum = 0

		self:checkChatItemNum()
		self.input:callback({
			text = "\n",
			type = "insertText"
		})

		return 
	end, {
		pressImage = res.gettex2("pic/keyboard/btn22.png"),
		scale9 = cc.size(rightBtnW, self.content.geth(slot7)/2 - edge),
		sprite = res.gettex2("pic/keyboard/send.png")
	}):add2(self.content):anchor(1, 1):pos(self.content:getw() - edge, self.content:geth()/2)
	an.newBtn(res.gettex2("pic/keyboard/btn11.png"), function ()
		chatItemNum = chatItemNum - 1

		if chatItemNum < 0 then
			chatItemNum = 0
		end

		self.input:callback({
			type = "deleteBackward"
		})

		return 
	end, {
		pressImage = res.gettex2("pic/keyboard/btn22.png"),
		scale9 = cc.size(rightBtnW, self.content.geth(slot7)/2 - edge),
		sprite = res.gettex2("pic/keyboard/delete.png")
	}):add2(self.content):anchor(1, 0):pos(self.content:getw() - edge, self.content:geth()/2)

	return 
end
keyboardEx.loadMain = function (self)
	if self.bar then
		self.bar:removeSelf()
	end

	self.bar = display.newNode():size(self.getContentSize(self)):add2(self)
	local btnw = 83
	local configs = {
		{
			"key",
			btnw/2 + btnw*0,
			self.geth(self)/2,
			function ()
				self.input:setKeyboardVisable(true)

				if self.content then
					self.content:removeSelf()

					self.content = nil
				end

				return 
			end
		},
		{
			"face",
			btnw/2 + btnw*1,
			self.geth(common)/2,
			function ()
				self.input:setKeyboardVisable(false)
				self.input:callback({
					duration = 0.3,
					type = "keyboardWillShow",
					eh = self:loadFace()
				})

				return 
			end
		},
		{
			"cmd",
			btnw/2 + btnw*2,
			self.geth(common)/2,
			function ()
				self.input:setKeyboardVisable(false)
				self.input:callback({
					duration = 0.3,
					type = "keyboardWillShow",
					eh = self:loadCMD()
				})

				return 
			end
		},
		{
			"bag",
			btnw/2 + btnw*3,
			self.geth(common)/2,
			function ()
				self.input:setKeyboardVisable(false)
				self.input:callback({
					duration = 0.3,
					type = "keyboardWillShow",
					eh = self:loadBag()
				})

				return 
			end
		},
		{
			"equip",
			btnw/2 + btnw*4,
			self.geth(common)/2,
			function ()
				self.input:setKeyboardVisable(false)
				self.input:callback({
					duration = 0.3,
					type = "keyboardWillShow",
					eh = self:loadEquip()
				})

				return 
			end
		},
		{
			"pos",
			btnw/2 + btnw*5,
			self.geth(common)/2,
			function ()
				if not self:checkChatItemNum() then
					return 
				end

				chatItemNum = chatItemNum + 1
				local text = string.format("[%s:%s,%s]", g_data.map.mapTitle, main_scene.ground.player.x, main_scene.ground.player.y)

				self.input:addLabel(text, cc.c3b(0, 0, 255), display.COLOR_WHITE, common.encodeRich({
					type = "pos",
					mapID = main_scene.ground.map.mapid,
					mapTitle = g_data.map.mapTitle,
					x = main_scene.ground.player.x,
					y = main_scene.ground.player.y
				}))

				return 
			end,
			true
		}
	}
	local btns = {}

	local function setSelected(key)
		for k, v in pairs(btns) do
			v.setIsSelect(v, k == key)
		end

		return 
	end

	for i, v in ipairs(slot2) do
		local key, x, y, func, isOnce = unpack(v)
		slot16 = res.gettex2("pic/keyboard/btn1.png")
		btns[key] = an.newBtn(slot16, function ()
			if not isOnce then
				setSelected(key)
			end

			func()

			return 
		end, {
			pressImage = isOnce and res.gettex2("pic/keyboard/btn2.png"),
			select = not isOnce and {
				res.gettex2("pic/keyboard/btn2.png"),
				manual = true
			},
			sprite = res.gettex2("pic/keyboard/" .. slot10 .. ".png")
		}):pos(x, y):add2(self.bar)
	end

	setSelected("key")

	return 
end
keyboardEx.loadFace = function (self)
	if self.content then
		self.content:removeSelf()
	end

	local emojiCount = 79
	local space = 55
	local lineMax = math.modf((display.width - rightBtnW - edge)/space)
	local lineCnt = math.ceil(emojiCount/lineMax)
	local h = math.max(minh, lineCnt*space + edge*2)
	self.content = display.newNode():size(self.getw(self), h):anchor(0, 1):add2(self):enableClick(function ()
		return 
	end)

	display.newScale9Sprite(res.getframe2("pic/keyboard/bg.png")).anchor(slot6, 0, 0):size(self.content:getContentSize()):add2(self.content)
	self.addRightBtns(self)

	for i = 1, emojiCount, 1 do
		local col = (i - 1)%lineMax
		local line = math.modf((i - 1)/lineMax)
		local tex = res.gettex2("pic/emoji/" .. i .. ".png")
		slot13 = an.newBtn(tex, function ()
			self.input:addEmoji(tex, common.encodeRich({
				type = "emoji",
				id = i
			}))

			return 
		end, {
			pressBig = true,
			size = {
				space,
				space
			}
		}).pos(slot13, edge + col*space + space/2, self.content:geth() - edge - line*space - space/2):add2(self.content)
	end

	return h
end
keyboardEx.loadCMD = function (self)
	if self.content then
		self.content:removeSelf()
	end

	local h = minh
	self.content = display.newNode():size(self.getw(self), h):anchor(0, 1):add2(self):enableClick(function ()
		return 
	end)

	display.newScale9Sprite(res.getframe2("pic/keyboard/bg.png")).anchor(slot2, 0, 0):size(self.content:getContentSize()):add2(self.content)
	self.addRightBtns(self)

	for i, v in ipairs(def.cmds.all) do
		local col = math.modf((i - 1)/2)
		local line = (i - 1)%2
		local addSpace = (display.width - 960)/math.modf(#def.cmds.all/2)
		local pos = cc.p(col*(addSpace + 190) + 35, h - 60 - line*39)
		local color = cc.c3b(255, 255, 0)
		local label = an.newLabel(v[1], 18, 1, {
			color = color
		}):pos(pos.x, pos.y):add2(self.content):addUnderline(color)

		label.enableClick(label, function ()
			local rsb = nil

			if v[2] == "@天地合一" then
				rsb = DefaultClientMessage(CM_TianDiHeYi)
				rsb.Flag = 2
			elseif v[2] == "@允许天地合一" then
				rsb = DefaultClientMessage(CM_TianDiHeYi)

				if g_data.player.TianDiHeYi then
					rsb.Flag = 0
					g_data.player.TianDiHeYi = false
				else
					rsb.Flag = 1
					g_data.player.TianDiHeYi = true
				end
			elseif v[2] == "@加入战队" then
				rsb = DefaultClientMessage(CM_BO_JOIN_CORP)
			elseif v[2] == "@拒绝求婚" then
				rsb = DefaultClientMessage(CM_BoAgree_Marry)
				rsb.BoAgree = false
			elseif v[2] == "@允许求婚" then
				rsb = DefaultClientMessage(CM_BoAgree_Marry)
				rsb.BoAgree = true
			end

			if rsb then
				MirTcpClient:getInstance():postRsb(rsb)

				return 
			end

			self.input:callback({})

			return 
		end, {
			ani = true,
			size = cc.size(label.getw(slot12), 39)
		})
	end

	return h
end
keyboardEx.loadItems = function (self, datas, emptyTip)
	if self.content then
		self.content:removeSelf()
	end

	local itemCount = table.nums(datas)
	local space = 60
	local lineMax = math.modf((display.width - rightBtnW - edge)/space)
	local lineCnt = math.ceil(itemCount/lineMax)
	local h = minh

	if 0 < itemCount then
		h = math.max(h, lineCnt*space + edge*2 + 50)
	end

	local items = {}

	local function click(data, pos)
		for i, v in ipairs(items) do
			if data == v.data then
				v.bg:setTex(res.gettex2("pic/chatEx/item_bg2.png"))
			else
				v.bg:setTex(res.gettex2("pic/chatEx/item_bg.png"))
			end
		end

		if data and pos then
			local p = cc.p(pos.x, pos.y)

			local function callback()
				if not self:checkChatItemNum() then
					return 
				end

				chatItemNum = chatItemNum + 1
				local text = string.format("[%s]", data:getVar("name"))

				self.input:addLabel(text, cc.c3b(0, 0, 255), display.COLOR_WHITE, common.encodeRich({
					type = "item",
					makeIndex = data.FItemIdent,
					name = data:getVar("name"),
					lookID = data:getVar("looks"),
					weight = data:getVar("weight")
				}))

				return 
			end

			itemInfo.close()
			itemInfo.show(items, p, {
				parent = display.getRunningScene(),
				z = an.z.max + 1,
				itemLink = callback
			})
		end

		return 
	end

	self.content = display.newNode().size(slot10, self.getw(self), h):anchor(0, 1):add2(self):enableClick(function ()
		click()

		return 
	end)

	display.newScale9Sprite(res.getframe2("pic/keyboard/bg.png")).anchor(slot10, 0, 0):size(self.content:getContentSize()):add2(self.content)
	self.addRightBtns(self)

	if 0 < itemCount then
		local cnt = 1

		local function add(data)
			local col = (cnt - 1)%lineMax
			local line = math.modf((cnt - 1)/lineMax)
			local pos = cc.p(edge + space/2 + col*space, self.content:geth() - edge - space/2 - line*space)
			local item = {
				data = data,
				bg = res.get2("pic/chatEx/item_bg.png"):pos(pos.x, pos.y):add2(self.content):enableClick(function ()
					local gPos = item.bg:convertToWorldSpace(cc.p(0, 0))
					local gx = gPos.x + 23
					local gy = gPos.y - 46 - h - 200

					click(data, cc.p(gx, gy))

					return 
				end, {
					size = cc.size(space, space)
				})
			}

			res.get("items", data.getVar(cnt, "looks")):pos(pos.x, pos.y):add2(self.content)

			items[#items + 1] = item
			cnt = cnt + 1

			return 
		end

		for k, v in pairs(edge) do
			add(v)
		end

		return h
	end

	an.newLabel(emptyTip, 24, 1, {
		color = def.colors.labelGray
	}):anchor(0.5, 0.5):pos(self.content:centerPos()):add2(self.content)
end
keyboardEx.loadBag = function (self)
	return self.loadItems(self, g_data.bag.items, "当前背包暂无物品可以分享.")
end
keyboardEx.loadEquip = function (self)
	return self.loadItems(self, g_data.equip.items, "当前装备暂无物品可以分享.")
end

return keyboardEx
