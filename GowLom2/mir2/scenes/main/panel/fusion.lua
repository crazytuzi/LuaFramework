local common = import("..common.common")
local item = import("..common.item")
local itemInfo = import("..common.itemInfo")
local fusion = class("fusion", function ()
	return display.newNode()
end)

table.merge(slot3, {
	items = {},
	effects = {},
	replaces = {
		"祖玛熔锭",
		"赤月熔锭",
		"雷霆熔锭",
		"强雷熔锭",
		"战神熔锭"
	},
	specil = {
		"祖玛助熔剂",
		"赤月助熔剂",
		"雷霆助熔剂",
		"强雷助熔剂",
		"战神助熔剂"
	},
	dec = {
		"祖玛",
		"赤月",
		"雷霆",
		"强雷",
		"战神"
	}
})

fusion.ctor = function (self)
	self._scale = self.getScale(self)
	self._supportMove = true
	local bg = res.get2("pic/panels/fusion/bg1.png"):anchor(0, 0):addto(self)
	local center = res.get2("pic/panels/fusion/bg.png"):anchor(0.5, 0):pos(bg.getw(bg)/2, 12):addto(bg)

	display.newSprite(res.gettex2("pic/panels/fusion/title.png")):anchor(0.5, 0.5):pos(bg.getw(bg)*0.5, bg.geth(bg) - 20):add2(bg)
	self.size(self, cc.size(bg.getContentSize(bg).width, bg.getContentSize(bg).height)):anchor(0, 1):pos(10, display.height - 80)
	self.setNodeEventEnabled(self, true)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot3, 1, 1):pos(self.getw(self) - 4, self.geth(self) - 4):addto(self)

	local loopEffAni = res.getani2("pic/panels/fusion/effect/1/%d.png", 1, 8, 0.12)

	loopEffAni.retain(loopEffAni)

	local loopEffSpr = res.get2("pic/panels/fusion/effect/1/1.png"):pos(center.getw(center)*0.5, center.geth(center)*0.5):add2(center, 1)

	loopEffSpr.runForever(loopEffSpr, cc.Animate:create(loopEffAni))

	self.boxs = {}
	local files = {
		"equip",
		"equip",
		"equip",
		"equip",
		"equip",
		"equip2",
		"equip"
	}
	local boxPos = {
		{
			x = 104,
			y = 354
		},
		{
			x = 284,
			y = 354
		},
		{
			x = 62,
			y = 208
		},
		{
			x = 128,
			y = 126
		},
		{
			x = 258,
			y = 126
		},
		{
			x = 318,
			y = 208
		},
		{
			x = 190,
			y = 248
		}
	}

	res.get2("pic/panels/fusion/equip3.png"):pos(boxPos[7].x, boxPos[7].y):add2(bg, 2)

	for i = 1, 7, 1 do
		self.boxs[i] = res.get2("pic/panels/fusion/" .. files[i] .. ".png"):pos(boxPos[i].x, boxPos[i].y):add2(bg, 2)

		res.get2("pic/panels/fusion/" .. self.getState(self, i) .. ".png"):pos(self.boxs[i]:getw()*0.5, self.boxs[i]:geth()*0.5):add2(self.boxs[i]):enableClick(function (x, y)
			self:boxClick(i)

			return 
		end)

		if 3 <= i and i <= 5 then
			res.get2("pic/panels/fusion/hint.png").pos(slot11, boxPos[i].x, boxPos[i].y - self.boxs[i]:geth()*0.5):add2(self, 3)
		end
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		local canFusion = true
		local count = 0

		for i = 1, 6, 1 do
			if not self.items[i] then
				main_scene.ui:tip("材料不足")

				return 
			elseif 2 <= i and i <= 5 then
				if self.items[i].isItems then
					if self.items[i].data:getVar("name") ~= self.items[1].data:getVar("name") then
						main_scene.ui:tip("放入的首饰必须相同")

						return 
					end
				else
					count = count + 1
				end
			end
		end

		local msgbox = nil
		slot3 = an.newMsgbox("", function (idx)
			if idx == 1 then
				local data = {}

				for i = 1, 6, 1 do
					if self.items[i].isItems then
						data[#data + 1] = {
							"int",
							self.items[i].data.FItemIdent
						}
					end
				end

				if 0 < #data then
					dump(data)
				end
			end

			return 
		end, {
			disableScroll = true,
			btnTexts = {
				"确定",
				"取消"
			}
		})
		msgbox = slot3
		local labelInfo = ""

		if count == 0 then
			labelInfo = "您确定使用5个" .. self.items[1].data:getVar("name") .. ",加" .. self.specil[self.level]

			an.newLabel(labelInfo, 20, 1, {
				color = def.colors.cellNor
			}):add2(msgbox.bg):anchor(0.5, 0.5):pos(msgbox.bg:getw()*0.5, msgbox.bg:geth()*0.5 + 40)
		else
			labelInfo = "您确定使用" .. count*self.price .. "元宝购买" .. self.replaces[self.level] .. "*" .. count

			an.newLabel(labelInfo, 20, 1, {
				color = def.colors.cellNor
			}):add2(msgbox.bg):anchor(0.5, 0.5):pos(msgbox.bg:getw()*0.5, msgbox.bg:geth()*0.5 + 40)
		end

		if 1 < #self.targetIndex then
			labelInfo = "开始合成 "

			for i, v in ipairs(self.targetIndex) do
				local data = def.items[v] or {}
				labelInfo = labelInfo .. "\"" .. (data.get(data, "name") or "") .. "\","
			end

			labelInfo = labelInfo .. "中的随机一件吗？"
		else
			labelInfo = "开始合成 \"" .. self.target.info:getVar("name") .. "\"吗？"
		end

		local tmpLabel = cc.LabelTTF:create(labelInfo, "", 18, cc.size(320, 0), 1)

		tmpLabel.anchor(tmpLabel, 0.5, 1)
		tmpLabel.setPosition(tmpLabel, msgbox.bg:getw()*0.5, msgbox.bg:geth()*0.5 + 18)
		msgbox.bg:addChild(tmpLabel)
		an.newLabel("合成后所有材料,催化剂和" .. self.replaces[self.level] .. "将自动消耗", 16, 1, {
			color = cc.c3b(162, 78, 54)
		}):add2(msgbox.bg):anchor(0.5, 0.5):pos(msgbox.bg:getw()*0.5, msgbox.bg:geth()*0.5 - 40)

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/fusion/begin.png")
	}).add2(slot7, center, 2):anchor(0.5, 0.5):pos(center.getw(center)*0.5, 36)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		self:oneKey()

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/fusion/allin.png")
	}).add2(slot7, center, 2):anchor(0.5, 0.5):pos(center.getw(center)*0.5 - 114, 36)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		self:itemsBack2bag()

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/panels/fusion/allout.png")
	}).add2(slot7, center, 2):anchor(0.5, 0.5):pos(center.getw(center)*0.5 + 114, 36)

	local frame = 1
	local tmpTex = ""
	self.effects[1] = res.get2("pic/panels/fusion/effect/4/1.png"):add2(self):pos(62, 208):hide()
	self.effects[2] = res.get2("pic/panels/fusion/effect/4/1.png"):add2(self):pos(128, 126):hide()
	self.effects[3] = res.get2("pic/panels/fusion/effect/4/1.png"):add2(self):pos(258, 126):hide()
	self.effects[4] = res.get2("pic/panels/fusion/effect/3/1.png"):add2(self, 4):pos(190, 228):hide()
	local centerAni = res.getani2("pic/panels/fusion/effect/3/%d.png", 1, 16, 0.26)

	centerAni.retain(centerAni)
	self.effects[4]:runForever(cc.Animate:create(centerAni))

	local time = display.newNode():add2(self)

	time.runForever(time, transition.sequence({
		cc.DelayTime:create(0.2),
		cc.CallFunc:create(function ()
			frame = frame + 1
			frame = (10 < frame and 1) or frame
			tmpTex = "pic/panels/fusion/effect/4/" .. frame .. ".png"

			for i = 1, 3, 1 do
				self.effects[i]:setTex(res.gettex2(tmpTex))
			end

			return 
		end)
	}))

	self.items = {}

	self.addNodeEventListener(slot0, cc.NODE_EVENT, function (event)
		if event.name == "cleanup" then
			self:itemsBack2bag()
		end

		return 
	end)

	return 
end
fusion.getState = function (self, pos)
	if pos == 1 then
		return "plus"
	elseif pos == 7 then
		return "quest"
	else
		if pos == 6 and self.items[2] then
			return "plus"
		end

		if pos == 2 and self.items[1] then
			return "plus"
		end

		return "equip1"
	end

	return 
end
fusion.showResult = function (self)
	local loopEffAni = res.getani2("pic/panels/fusion/effect/2/%d.png", 1, 8, 0.16)

	loopEffAni.retain(loopEffAni)

	local loopEffSpr = res.get2("pic/panels/fusion/effect/2/1.png"):pos(self.getw(self)*0.5, self.geth(self)*0.5):add2(self, 9)

	loopEffSpr.runs(loopEffSpr, {
		cc.Animate:create(loopEffAni),
		cc.CallFunc:create(function ()
			loopEffSpr:removeSelf()

			return 
		end)
	})

	return 
end
fusion.showBag = function (self)
	if main_scene.ui.panels then
		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:pos(self.getw(self) + 10, display.height - 80)
		else
			main_scene.ui:togglePanel("bag")
			main_scene.ui.panels.bag:pos(self.getw(self) + 10, display.height - 80)
		end
	end

	return 
end
fusion.showEffect = function (self, bShow)
	for i = 1, 4, 1 do
		if bShow then
			self.effects[i]:show()
		else
			self.effects[i]:hide()
		end
	end

	return 
end
fusion.idx2pos = function (self, idx)
	local boxPos = {
		{
			x = 104,
			y = 354
		},
		{
			x = 284,
			y = 354
		},
		{
			x = 62,
			y = 208
		},
		{
			x = 128,
			y = 126
		},
		{
			x = 258,
			y = 126
		},
		{
			x = 318,
			y = 208
		},
		{
			x = 190,
			y = 248
		}
	}

	return boxPos[idx].x, boxPos[idx].y
end
fusion.addItem = function (self, idx, data)
	sound.play("item", data)

	if idx == 6 and data.getVar(data, "looks") ~= (self.level or 0) + 5579 then
		g_data.bag:addItem(data)

		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:addItem(data.FItemIdent)
		end

		main_scene.ui:tip("放入失败，请放入正确的助熔剂")

		return 
	end

	local tmpItem = self.items[idx]

	if tmpItem then
		if tmpItem.isItems then
			g_data.bag:addItem(tmpItem.data)

			if main_scene.ui.panels.bag then
				main_scene.ui.panels.bag:addItem(tmpItem.data.FItemIdent)
			end
		end

		tmpItem.removeSelf(tmpItem)
	end

	self.boxs[idx]:removeAllChildren()
	self.boxs[idx]:setTex("pic/panels/fusion/equip" .. ((idx == 6 and "2") or "") .. "_0.png")

	self.items[idx] = item.new(data, self, {
		idx = idx
	}):addto(self, 3):pos(self.idx2pos(self, idx))
	self.items[idx].isItems = true
	g_data.bag.fusion[idx] = data

	if (idx ~= 1 or false) and idx == 2 then
		self.autoIn(self)
		self.resetState(self)
	end

	return 
end
fusion.getBackItem = function (self, item)
	local data = item.data

	if not data then
		return 
	end

	g_data.bag:addItem(data)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:addItem(data.FItemIdent)
	end

	local target = nil

	for i, v in pairs(self.items) do
		if v and v.isItems and v.data.FItemIdent == data.FItemIdent then
			target = i

			v.removeSelf(v)

			self.items[i] = nil
			g_data.bag.fusion[i] = nil

			if i == 1 then
				self.itemsBack2bag(self)
			elseif 3 <= i and i <= 5 then
				self.items[i] = res.get("items", self.level + 5589):addto(self, 3):pos(self.idx2pos(self, i)):enableClick(function (x, y)
					self:showReplaceTips(cc.p(x, y))

					return 
				end)
			end

			if i == 6 then
				self.boxs[i].setTex(slot9, "pic/panels/fusion/equip2.png")
			else
				self.boxs[i]:setTex("pic/panels/fusion/equip.png")
			end

			if i == 2 or i == 6 then
				self.boxs[i]:removeAllChildren()
				res.get2("pic/panels/fusion/" .. self.getState(self, i) .. ".png"):pos(self.boxs[i]:getw()*0.5, self.boxs[i]:geth()*0.5):add2(self.boxs[i]):enableClick(function (x, y)
					self:boxClick(i)

					return 
				end)
			end
		end
	end

	if target and target == 2 then
		local makeIndexs = {}

		for i = 3, 6, 1 do
			if self.items[i] then
				if self.items[i].isItems then
					g_data.bag.addItem(slot9, self.items[i].data)

					makeIndexs[#makeIndexs + 1] = self.items[i].data.FItemIdent
					g_data.bag.fusion[i] = nil
				end

				self.items[i]:removeSelf()

				self.items[i] = nil
			end

			self.boxs[i]:removeAllChildren()
			res.get2("pic/panels/fusion/" .. self.getState(self, i) .. ".png"):pos(self.boxs[i]:getw()*0.5, self.boxs[i]:geth()*0.5):add2(self.boxs[i]):enableClick(function (x, y)
				self:boxClick(i)

				return 
			end)
		end

		self.effects[1].hide(slot5)
		self.effects[2]:hide()
		self.effects[3]:hide()

		if main_scene.ui.panels.bag then
			for i, v in ipairs(makeIndexs) do
				main_scene.ui.panels.bag:addItem(v)
			end
		end
	end

	return 
end
fusion.getItemFromBg = function (self, data, pos)
	local tmpItem = self.items[pos]

	if tmpItem and tmpItem.isItems and data.getVar(data, "name") == tmpItem.data:getVar("name") then
		main_scene.ui:tip("放入相同物品")

		return 
	end

	if self.items[1] and 2 <= pos and pos <= 5 and data.getVar(data, "name") ~= self.items[1].data:getVar("name") then
		main_scene.ui:tip("放入的材料不正确")

		return 
	end

	g_data.bag:delItem(data.FItemIdent)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:delItem(data.FItemIdent)
	end

	g_data.client:setLastTime("fusion", true)
	self.addItem(self, pos, data)

	return 
end
fusion.oneKey = function (self)
	if not self.items[1] or not self.items[1].isItems then
		main_scene.ui:tip("一键放入失败")

		return 
	end

	local name = self.items[1].data:getVar("name")

	for i = 2, 5, 1 do
		local bagItem = g_data.bag:getItemWithName(name)

		if not bagItem then
			if i == 2 then
				if not self.items[i] then
					main_scene.ui:tip("一键放入物品不够")
				end
			elseif not self.items[i] then
				self.boxs[i]:removeAllChildren()

				self.items[i] = res.get("items", self.level + 5589):addto(self, 3):pos(self.idx2pos(self, i)):enableClick(function (x, y)
					self:showReplaceTips(cc.p(x, y))

					return 
				end)

				self.effects[i - 2].show(slot7)
			end
		elseif not self.items[i] then
			self.getItemFromBg(self, bagItem, i)
		elseif not self.items[i].isItems then
			self.items[i]:removeSelf()

			self.items[i] = nil

			self.getItemFromBg(self, bagItem, i)
		end
	end

	if not self.items[6] then
		self.boxClick(self, 6)
	end

	return 
end
fusion.autoIn = function (self)
	for i = 3, 5, 1 do
		if not self.items[i] then
			self.boxs[i]:removeAllChildren()

			self.items[i] = res.get("items", self.level + 5589):addto(self, 3):pos(self.idx2pos(self, i)):enableClick(function (x, y)
				self:showReplaceTips(cc.p(x, y))

				return 
			end)

			self.effects[i - 2].show(slot5)
		end
	end

	return 
end
fusion.boxClick = function (self, idx)
	if idx == 1 then
		self.showBag(self)
	elseif idx == 2 then
		if self.items[1] and self.items[1].isItems then
			local name = self.items[1].data:getVar("name")
			local bagItem = g_data.bag:getItemWithName(name)

			if bagItem then
				self.getItemFromBg(self, bagItem, idx)
			end
		end
	elseif idx == 6 then
		if not self.level then
			return 
		end

		local name = self.specil[self.level]
		local bagItem = g_data.bag:getItemWithName(name)

		if bagItem then
			self.getItemFromBg(self, bagItem, idx)
		end
	end

	return 
end
fusion.itemsBack2bag = function (self)
	self.price = nil
	self.level = nil
	local makeIndexs = {}

	for i, v in pairs(self.items) do
		if v.isItems then
			g_data.bag:addItem(v.data)

			makeIndexs[#makeIndexs + 1] = v.data.FItemIdent
		end

		v.removeSelf(v)
	end

	self.items = {}

	if main_scene.ui.panels.bag then
		for i, v in ipairs(makeIndexs) do
			main_scene.ui.panels.bag:addItem(v)
		end
	end

	if self.target then
		self.target:removeSelf()

		self.target = nil
	end

	self.showEffect(self, false)

	for i = 1, 7, 1 do
		self.boxs[i]:removeAllChildren()
		self.boxs[i]:setTex("pic/panels/fusion/equip" .. ((i == 6 and "2") or "") .. ".png")
		res.get2("pic/panels/fusion/" .. self.getState(self, i) .. ".png"):pos(self.boxs[i]:getw()*0.5, self.boxs[i]:geth()*0.5):add2(self.boxs[i]):enableClick(function (x, y)
			self:boxClick(i)

			return 
		end)
	end

	g_data.bag.fusion = {}

	return 
end
fusion.resetState = function (self)
	if self.items[1] then
		if self.items[2] then
			if not self.items[6] then
				self.boxs[6]:removeAllChildren()
				res.get2("pic/panels/fusion/plus.png"):pos(self.boxs[6]:getw()*0.5, self.boxs[6]:geth()*0.5):add2(self.boxs[6]):enableClick(function (x, y)
					self:boxClick(6)

					return 
				end)
			end
		else
			print("==========================")
			self.boxs[2].removeAllChildren(slot1)
			res.get2("pic/panels/fusion/plus.png"):pos(self.boxs[2]:getw()*0.5, self.boxs[2]:geth()*0.5):add2(self.boxs[2]):enableClick(function (x, y)
				self:boxClick(2)

				return 
			end)
		end
	end

	return 
end
fusion.cleanItems = function (self)
	for i, v in pairs(self.items) do
		v.removeSelf(v)
	end

	self.items = {}

	if self.target then
		self.target:removeSelf()

		self.target = nil
	end

	for i = 1, 4, 1 do
		self.effects[i]:hide()
	end

	for i = 1, 7, 1 do
		self.boxs[i]:removeAllChildren()
		self.boxs[i]:setTex("pic/panels/fusion/equip" .. ((i == 6 and "2") or "") .. ".png")
		res.get2("pic/panels/fusion/" .. self.getState(self, i) .. ".png"):pos(self.boxs[i]:getw()*0.5, self.boxs[i]:geth()*0.5):add2(self.boxs[i]):enableClick(function (x, y)
			self:boxClick(i)

			return 
		end)
	end

	return 
end
fusion.putItem = function (self, item, x, y)
	local form = item.formPanel.__cname
	local target = nil

	for i = 1, 6, 1 do
		local tmpX, tmpY = self.idx2pos(self, i)

		if (tmpX - x)*(tmpX - x) < 1600 and (tmpY - y)*(tmpY - y) < 1600 then
			target = i
		end
	end

	if not target then
		return 
	elseif target ~= 1 and not self.items[1] then
		main_scene.ui:tip("首先必须放入装备")

		return 
	elseif target ~= 1 and target ~= 2 and not self.items[2] then
		main_scene.ui:tip("请依次放入装备")

		return 
	end

	if form == "bag" and g_data.client:checkLastTime("fusion", 2) then
		local data = item.data

		self.getItemFromBg(self, data, target)
	end

	return 
end
fusion.addItems = function (self, msg, buf, bufLen)
	if msg.param == 1 then
		self.price = msg.tag
		self.level = msg.recog

		ycByteStream:startRead(buf, bufLen)

		self.targetIndex = {}

		for i = 1, msg.series, 1 do
			self.targetIndex[#self.targetIndex + 1] = ycByteStream:readShort(i*2 - 2)
		end

		local target = self.targetIndex[1]
		local info = def.items[target] or {}

		if self.target then
			self.target:removeSelf()
		end

		self.target = res.get("items", info.looks):addto(self, 3):pos(self.idx2pos(self, 7))
		self.target.info = info

		self.target:enableClick(function (x, y)
			self:showSimpleTips(self.targetIndex, cc.p(x, y))

			return 
		end)

		if 1 < #self.targetIndex then
			local frames = {}

			for i, v in ipairs(self.targetIndex) do
				local data = def.items[v] or {}
				frames[#frames + 1] = res.getframe("items", data.looks or 0)
			end

			local animation = cc.Animation.createWithSpriteFrames(slot7, frames, 1)

			animation.retain(animation)
			self.target:runForever(cc.Animate:create(animation))
		end

		self.boxs[7]:removeAllChildren()
		self.boxs[7]:setTex("pic/panels/fusion/equip_0.png")
		self.effects[4]:show()
		self.resetState(self)
	else
		local errorCode = msg.param
		local errorMsg = {
			[0] = "包裹中没有这件物品",
			[2] = "此物品不可升级",
			[3] = "目前还不能合成这个等级的装备"
		}

		main_scene.ui:tip(errorMsg[errorCode] or "未知错误")
		self.itemsBack2bag(self)
	end

	return 
end
fusion.fusionEquip = function (self, msg, buf, bufLen)
	if msg.param == 1 then
		self.showResult(self)

		g_data.bag.fusion = {}

		self.cleanItems(self)
	else
		local errorCode = msg.param
		local errorMsg = {
			[3] = "参与合成的装备数量不正确",
			[4] = "装备不能合成",
			[5] = "元宝数量不足",
			[6] = "目前不能合成该等级物品",
			[7] = "放入的催化剂不正确",
			[8] = "不可合成绑定装备",
			[9] = "放入装备必须相同",
			[10] = "包裹中没有这个物品",
			[11] = "正在处理元宝交易，请耐心等待"
		}

		main_scene.ui:tip(errorMsg[errorCode] or "未知错误")
	end

	return 
end
fusion.showReplaceTips = function (self, scenePos)
	if not self.items[1] or not self.items[1].isItems then
		return 
	end

	local name = self.items[1].data:getVar("name")
	local layer = display.newNode():size(display.width, display.height):addto(main_scene.ui, main_scene.ui.z.textInfo)

	layer.setTouchEnabled(layer, true)
	layer.setTouchSwallowEnabled(layer, false)
	layer.addNodeEventListener(layer, cc.NODE_TOUCH_CAPTURE_EVENT, function (event)
		if event.name == "ended" then
			layer:runs({
				cc.DelayTime:create(0.01),
				cc.RemoveSelf:create(true)
			})
		end

		return true
	end)

	local labels = {
		an.newLabel(self.replaces[self.level], 20, 1, {
			color = cc.c3b(255, 255, 0)
		}),
		an.newLabel("可替换" .. slot2 .. "进行装备合成。", 20, 1),
		an.newLabel("价格：" .. self.price .. "元宝。", 20, 1),
		an.newLabel("装备拖入可直接替换。", 20, 1)
	}
	local bg = display.newScale9Sprite(res.getframe2("pic/scale/scale4.png")):addto(layer):anchor(0, 1)
	local w = 0
	local h = 7
	local space = -2

	for i = #labels, 1, -1 do
		local v = labels[i]:addto(bg, 99):anchor(0, 0):pos(10, h)
		w = math.max(w, v.getw(v))
		h = h + v.geth(v) + space
	end

	w = w + 20
	h = h + 10
	local rect = cc.rect(0, 0, display.width, display.height)
	local p = scenePos

	if p.x < rect.x then
		p.x = rect.x
	end

	if rect.width < p.x + w then
		p.x = rect.width - w
	end

	if rect.height < p.y then
		p.y = rect.height
	end

	if p.y - h < rect.y then
		p.y = h + rect.y
	end

	bg.size(bg, w, h):pos(p.x, p.y)

	return 
end
fusion.showSimpleTips = function (self, targetList, scenePos)
	local layer = display.newNode():size(display.width, display.height):addto(main_scene.ui, main_scene.ui.z.textInfo)

	layer.setTouchEnabled(layer, true)
	layer.setTouchSwallowEnabled(layer, false)
	layer.addNodeEventListener(layer, cc.NODE_TOUCH_CAPTURE_EVENT, function (event)
		if event.name == "ended" then
			layer:runs({
				cc.DelayTime:create(0.01),
				cc.RemoveSelf:create(true)
			})
		end

		return true
	end)

	local labels = {}

	function add(text, color)
		text = text or ""
		labels[#labels + 1] = an.newLabel(text, 20, 1, {
			color = color
		})

		return 
	end

	function addAttr(data, text, key)
		local front = data[key] or 0
		local after = data["max" .. key] or 0

		if 0 < front or 0 < after then
			add(text .. front .. "-" .. after)
		end

		return 
	end

	function addAttr2(text, value, normalValue, color, attachText)
		attachText = attachText or ""

		add(text .. value .. attachText, color)

		return 
	end

	function needColor(a, b)
		return (b <= a and display.COLOR_GREEN) or display.COLOR_RED
	end

	function addNeed(data)
		local need = data.need
		local needLevel = data.needLevel

		if need == 0 then
			local strlvl = common.getLevelText(needLevel)

			add("需要等级: " .. strlvl .. "级", display.COLOR_RED)
		elseif need == 1 then
			add("需要攻击力: " .. needLevel, display.COLOR_RED)
		elseif need == 2 then
			add("需要魔法力: " .. needLevel, display.COLOR_RED)
		elseif need == 3 then
			add("需要精神力: " .. needLevel, display.COLOR_RED)
		elseif need == 4 then
			add("需要转生等级: " .. needLevel, display.COLOR_GREEN)
		elseif need == 40 then
			add("需要转生&等级: " .. needLevel, display.COLOR_GREEN)
		elseif need == 41 then
			add("需要转生&攻击力: " .. needLevel, display.COLOR_GREEN)
		elseif need == 42 then
			add("需要转生&魔法力: " .. needLevel, display.COLOR_GREEN)
		elseif need == 43 then
			add("需要转生&精神力力: " .. needLevel, display.COLOR_GREEN)
		elseif need == 44 then
			add("需要转生&声望点: " .. needLevel, display.COLOR_GREEN)
		elseif need == 5 then
			add("需要声望点: " .. needLevel, display.COLOR_GREEN)
		elseif need == 6 then
			add("行会成员专用", display.COLOR_GREEN)
		elseif need == 60 then
			add("行会掌门专用", display.COLOR_GREEN)
		elseif need == 7 then
			add("沙城成员专用", display.COLOR_GREEN)
		elseif need == 70 then
			add("沙城掌门专用", display.COLOR_GREEN)
		elseif need == 8 then
			add("会员专用", display.COLOR_GREEN)
		elseif need == 81 then
			add("会员类型 =" .. Loword(needLevel) .. "并等级>=" .. Hiword(needLevel), display.COLOR_GREEN)
		elseif need == 82 then
			add("会员类型 >= " .. Loword(needLevel) .. "并等级>=" .. Hiword(needLevel), display.COLOR_GREEN)
		end

		return 
	end

	local function tmpModf(value)
		local int, f = math.modf(value)

		return (0.5 <= f and int + 1) or int
	end

	if 1 < #targetList then
		labels[#labels + 1] = an.newLabel("可获得以下物品中的随机一件", 20, 1, {
			color = cc.c3b(255, 0, 0)
		})
	end

	for i, v in ipairs(slot1) do
		local data = def.items[v] or {}

		if 1 < #targetList then
			labels[#labels + 1] = an.newLabel("     ", 20, 1, {
				color = cc.c3b(255, 255, 0)
			})
		end

		labels[#labels + 1] = an.newLabel(data.name, 20, 1, {
			color = cc.c3b(255, 255, 0)
		})
		labels[#labels + 1] = an.newLabel("重量: " .. data.weight, 20, 1)

		add("持久: " .. data.duraMax/1000 .. "/" .. data.duraMax/1000)

		local AC = data.getVar(data, "AC")
		local maxAC = data.getVar(data, "maxAC")
		local MAC = data.getVar(data, "MAC")
		local maxMAC = data.getVar(data, "maxMAC")
		local ACN = data.getVar(data, "AC")
		local maxACN = data.getVar(data, "maxAC")
		local MACN = data.getVar(data, "MAC")
		local maxMACN = data.getVar(data, "maxMAC")
		local stdMode = data.getVar(data, "stdMode")

		if stdMode == 19 or stdMode == 53 then
			if 0 < maxAC then
				addAttr2("魔法躲避: +", maxAC, maxACN, display.COLOR_GREEN, "0％")
			end

			if 0 < maxMAC then
				addAttr2("幸运: +", maxMAC, maxMACN, display.COLOR_GREEN)
			end

			if 0 < MAC then
				add("诅咒: +" .. MAC, display.COLOR_RED)
			end
		elseif stdMode == 20 or stdMode == 24 then
			if 0 < AC then
				addAttr2("准确: +", maxAC, maxACN, display.COLOR_GREEN)
			end

			if 0 < MAC then
				addAttr2("敏捷: +", maxMAC, maxMACN, display.COLOR_GREEN)
			end
		elseif stdMode == 21 then
			if 0 < maxAC then
				addAttr2("体力恢复: +", maxAC, maxACN, display.COLOR_GREEN, "0％")
			end

			if 0 < maxMAC then
				addAttr2("魔法恢复: +", maxMAC, maxMACN, display.COLOR_GREEN, "0％")
			end

			if 0 < AC then
				addAttr2("攻击速度: +", AC, ACN, display.COLOR_GREEN)
			end

			if 0 < MAC then
				add("攻击速度: -" .. MAC, display.COLOR_RED)
			end
		elseif stdMode == 23 then
			if 0 < maxAC then
				addAttr2("毒物躲避: +", maxAC, maxACN, display.COLOR_GREEN, "0％")
			end

			if 0 < maxMAC then
				addAttr2("中毒恢复: +", maxMAC, maxMACN, display.COLOR_GREEN, "0％")
			end

			if 0 < AC then
				addAttr2("攻击速度: +", AC, ACN, display.COLOR_GREEN)
			end

			if 0 < MAC then
				add("攻击速度: -" .. MAC, display.COLOR_RED)
			end
		elseif stdMode == 28 or stdMode == 27 then
			addAttr("防御: ", "AC")
			addAttr("魔御: ", "MAC")

			if 0 < getData("aniCount") then
				add("负重: +" .. getData("aniCount"), display.COLOR_GREEN)
			end
		elseif stdMode == 63 then
			if 0 < AC then
				add("HP: +" .. AC, display.COLOR_GREEN)
			end

			if 0 < maxAC then
				add("MP: +" .. maxAC, display.COLOR_GREEN)
			end

			if 0 < maxMAC then
				addAttr2("幸运: +", maxMAC, maxMACN, display.COLOR_GREEN)
			end

			if 0 < MAC then
				add("诅咒: +" .. MAC, display.COLOR_RED)
			end
		else
			addAttr(data, "防御: ", "AC")
			addAttr(data, "魔御: ", "MAC")
		end

		addAttr(data, "攻击: ", "DC")
		addAttr(data, "魔法: ", "MC")
		addAttr(data, "道术: ", "SC")

		if stdMode ~= 52 then
			addNeed(data)
		end
	end

	local bg = display.newScale9Sprite(res.getframe2("pic/scale/scale4.png")):addto(layer):anchor(0, 1)
	local w = 0
	local h = 7
	local space = -2

	for i = #labels, 1, -1 do
		local v = labels[i]:addto(bg, 99):anchor(0, 0):pos(10, h)
		w = math.max(w, v.getw(v))
		h = h + v.geth(v) + space
	end

	w = w + 20
	h = h + 10
	local rect = cc.rect(0, 0, display.width, display.height)
	local p = scenePos

	if p.x < rect.x then
		p.x = rect.x
	end

	if rect.width < p.x + w then
		p.x = rect.width - w
	end

	if rect.height < p.y then
		p.y = rect.height
	end

	if p.y - h < rect.y then
		p.y = h + rect.y
	end

	bg.size(bg, w, h):pos(p.x, p.y)

	return 
end

return fusion
