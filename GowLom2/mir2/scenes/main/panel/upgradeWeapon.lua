local item = import("..common.item")
local itemInfo = import("..common.itemInfo")
local upgradeWeapon = class("upgradeWeapon", function ()
	return display.newNode()
end)

table.merge(slot2, {
	max = 36,
	items = {},
	effects = {}
})

local modes = {
	19,
	20,
	21,
	22,
	23,
	24,
	26
}
ccui.TouchEventType = {
	moved = 1,
	began = 0,
	canceled = 3,
	ended = 2
}
upgradeWeapon.ctor = function (self)
	self._scale = self.getScale(self)
	self._supportMove = true
	self.rootPanel = ccs.GUIReader:getInstance():widgetFromBinaryFile("ui/upgradeWeapon/upgradeWeapon.csb")
	local bg = self.rootPanel

	self.size(self, bg.getw(bg), bg.geth(bg)):anchor(0, 1):pos(10, display.height - 80)
	bg.add2(bg, self)
	self.showBag(self)
	self.reload(self)

	local function clickClose(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		self:hidePanel()

		return 
	end

	local btnClose = ccui.Helper.seekWidgetByName(slot3, self.rootPanel, "btn_close")

	btnClose.addTouchEventListener(btnClose, clickClose)

	local colorTable = {
		display.COLOR_RED,
		display.COLOR_WHITE
	}

	local function parseStr(str)
		local contentT = {}
		local lines = string.split(str, "$$")

		for k, v in pairs(lines) do
			local part = string.split(v, "|")
			contentT[k] = {}

			for i, j in pairs(part) do
				contentT[k][i] = string.split(j, "#")
			end
		end

		return contentT
	end

	local function clickHelp(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		if self.msgboxHelp and self.msgboxHelp.isMsgbox then
			self.msgboxHelp:removeSelf()

			self.msgboxHelp = nil
		end

		self.msgboxHelp = an.newMsgbox("", nil, {
			center = true
		})
		self.msgboxHelp.isMsgbox = true
		local label = an.newLabelM(365, 15, 1):add2(self.msgboxHelp.bg):anchor(0.5, 0.5):pos(self.msgboxHelp.bg:getw()*0.5, self.msgboxHelp.bg:geth()/2 + 15)
		local str = "原材料至少包括一个|1#黑铁矿石|和一个饰品：$$黑铁矿石：可从|1#神秘矿洞|活动获取$$饰品：可用类型包括：|1#戒指、项链、手镯、护腕"
		local strTable = parseStr(str)

		label.nextLine(label)

		for i = 1, #strTable, 1 do
			for j = 1, #strTable[i], 1 do
				if strTable[i][j][1] then
					if strTable[i][j][2] then
						label.addLabel(label, strTable[i][j][2], colorTable[tonumber(strTable[i][j][1])])
					else
						label.addLabel(label, strTable[i][j][1], colorTable[2])
					end
				end
			end

			label.nextLine(label)
		end

		return 
	end

	local btnHelp = ccui.Helper.seekWidgetByName(slot7, self.rootPanel, "btn_help")

	btnHelp.addTouchEventListener(btnHelp, clickHelp)

	local function clickPutin(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		self:oneKey()

		return 
	end

	local btnPutin = ccui.Helper.seekWidgetByName(slot9, self.rootPanel, "btn_putin")

	btnPutin.addTouchEventListener(btnPutin, clickPutin)

	local function clickUpgrade(sender, eventType)
		if self.msgboxUpgradeWeapon and self.msgboxUpgradeWeapon.isMsgbox then
			self.msgboxUpgradeWeapon:removeSelf()

			self.msgboxUpgradeWeapon = nil
		end

		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		if not g_data.equip.items[1] then
			main_scene.ui:tip("请穿戴上需要修炼的武器")

			return 
		end

		if g_data.player.gold < 10000 then
			self.msgboxUpgradeWeapon = an.newMsgbox("你的金币不足\n请确认带够金币再修炼", nil, {
				center = true
			})
			self.msgboxUpgradeWeapon.isMsgbox = true

			return 
		end

		local ironOre = 0
		local jewelry = 0

		for itemIdx, itemData in pairs(self.items) do
			if itemData.data:getVar("name") == "黑铁矿石" then
				ironOre = ironOre + 1
			end

			local modes = {
				19,
				20,
				21,
				22,
				23,
				24,
				26
			}

			for k, v in pairs(modes) do
				if itemData.data:getVar("stdMode") == v then
					jewelry = jewelry + 1
				end
			end
		end

		if ironOre < 1 then
			self.msgboxUpgradeWeapon = an.newMsgbox("你的原料不足\n请放入足够的材料再修炼", nil, {
				center = true
			})
			self.msgboxUpgradeWeapon.isMsgbox = true

			return 
		end

		if jewelry < 1 then
			self.msgboxUpgradeWeapon = an.newMsgbox("你的原料不足\n请放入足够的材料再修炼", nil, {
				center = true
			})
			self.msgboxUpgradeWeapon.isMsgbox = true

			return 
		end

		self.msgboxUpgradeWeapon = an.newMsgbox("", function (idx)
			if idx == 1 then
				local rsb = DefaultClientMessage(CM_UP_WEAPON)
				rsb.FItemIdent_List = {}

				for k, v in pairs(self.items) do
					rsb.FItemIdent_List[#rsb.FItemIdent_List + 1] = v.data.FItemIdent
				end

				MirTcpClient:getInstance():postRsb(rsb)
			end

			return 
		end, {
			disableScroll = true
		})
		self.msgboxUpgradeWeapon.isMsgbox = true
		local label = an.newLabelM(365, 20, 0, {
			center = true
		}).add2(slot4, self.msgboxUpgradeWeapon.bg):anchor(0.5, 0.5):pos(self.msgboxUpgradeWeapon.bg:getw()*0.5, self.msgboxUpgradeWeapon.bg:geth()/2)

		label.nextLine(label):addLabel("请确认是否开始修炼武器“", display.COLOR_WHITE)
		label.addLabel(label, g_data.equip.items[1]:getVar("name"), display.COLOR_RED)
		label.addLabel(label, "”", display.COLOR_WHITE)
		label.nextLine(label)
		label.nextLine(label):addLabel("修炼武器可能会导致武器破碎", display.COLOR_RED)
		label.nextLine(label)
		label.nextLine(label):addLabel("修炼所需要时间：1小时", cc.c3b(250, 210, 100))

		local labelInfo = ""

		return 
	end

	local btnUpgrade = ccui.Helper.seekWidgetByName(slot11, self.rootPanel, "btn_upgrade")

	btnUpgrade.addTouchEventListener(btnUpgrade, clickUpgrade)

	local function clickTakeoff(sender, eventType)
		if eventType ~= ccui.TouchEventType.ended then
			return 
		end

		self:itemsBack2bag()

		return 
	end

	local btnTakeoff = ccui.Helper.seekWidgetByName(slot13, self.rootPanel, "btn_takeoff")

	btnTakeoff.addTouchEventListener(btnTakeoff, clickTakeoff)
	self.addNodeEventListener(self, cc.NODE_EVENT, function (event)
		if event.name == "cleanup" then
			self:itemsBack2bag()
		end

		return 
	end)

	return 
end
upgradeWeapon.reload = function (self)
	for k, v in pairs(self.items) do
		v.removeSelf(v)
	end

	self.items = {}

	for i = 1, self.max, 1 do
		res.get2("pic/panels/bag/itembg.png"):addTo(self):pos(self.idx2pos(self, i))
	end

	return 
end
upgradeWeapon.idx2pos = function (self, idx)
	idx = idx - 1
	local h = idx%6
	local v = math.modf(idx/6)

	return self.getw(self)/2 - 162 - 5 + h*56 + 27, (self.geth(self)/2 + 108 + 5) - v*56 + 27
end
upgradeWeapon.pos2idx = function (self, x, y)
	local h = (x - 48)/46.5 + 0.5
	local v = (y - 321)/46.5 + 0.5

	if 0 < h and h < 5 and 0 < v and v < 5 then
		return math.floor(v)*5 + math.floor(h) + 1
	end

	return -1
end
upgradeWeapon.showResult = function (self)
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
upgradeWeapon.showBag = function (self)
	if main_scene.ui.panels then
		if main_scene.ui.panels.bag then
			local w = self.getw(self)

			main_scene.ui.panels.bag:pos(395, display.height - 80):anchor(0, 1)
		else
			main_scene.ui:togglePanel("bag")
			main_scene.ui.panels.bag:pos(self.getw(self) + 10, display.height - 80)
		end
	end

	return 
end
upgradeWeapon.showEffect = function (self, bShow)
	for i = 1, 4, 1 do
		if bShow then
			self.effects[i]:show()
		else
			self.effects[i]:hide()
		end
	end

	return 
end
upgradeWeapon.uptItem = function (self, makeIndex)
	local item = g_data.bag:getItemupgradeWeapon(makeIndex)

	if not item then
		return 
	end

	for i, v in pairs(self.items) do
		if v and v.isItems and v.data.FItemIdent == makeIndex then
			v.data = item

			break
		end
	end

	return 
end
upgradeWeapon.putItem = function (self, item, x, y)
	local form = item.formPanel.__cname
	local target = nil

	for i = 1, self.max, 1 do
		local tmpX, tmpY = self.idx2pos(self, i)

		if (tmpX - x)*(tmpX - x) < 729 and (tmpY - y)*(tmpY - y) < 729 then
			target = i
		end
	end

	if not target then
		return 
	end

	if form == "bag" and g_data.client:checkLastTime("upgradeWeapon", 2) then
		local data = item.data

		self.getItemFromBg(self, data, target)

		slot7, slot8 = self.idx2pos(self, target)
	end

	return 
end
upgradeWeapon.getBackItem = function (self, item)
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
			g_data.bag.upgradeWeapon[i] = nil

			break
		end
	end

	return 
end
upgradeWeapon.getItemFromBg = function (self, data, pos)
	local tmpItem = self.items[pos]

	g_data.bag:delItem(data.FItemIdent)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:delItem(data.FItemIdent)
	end

	g_data.client:setLastTime("upgradeWeapon", true)
	self.addItem(self, pos, data)

	return 
end
upgradeWeapon.delItem = function (self, itemIndex)
	for i, v in pairs(self.items) do
		if v and v.isItems and v.data.FItemIdent == itemIndex then
			v.removeSelf(v)

			self.items[i] = nil
			g_data.bag.upgradeWeapon[i] = nil

			break
		end
	end

	return 
end
upgradeWeapon.duraChange = function (self, makeindex)
	local data = g_data.bag:getItemupgradeWeapon(makeindex)

	for k, v in pairs(self.items) do
		if makeindex == v.data.FItemIdent then
			v.data = data

			if k == 4 then
				self.rebackBag(self, data)

				g_data.bag.upgradeWeapon[k] = nil

				v.removeSelf(v)

				self.items[k] = nil
			end

			return 
		end
	end

	return 
end
upgradeWeapon.rebackBag = function (self, data)
	g_data.bag:addItem(data)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:addItem(data.FItemIdent)
	end

	return 
end
upgradeWeapon.oneKey = function (self)
	if self.max <= #self.items then
		if 1 < #self.items then
			for i = 1, #self.items - 1, 1 do
				if not self.items[i] then
					local name = "黑铁矿石"
					local bagItem = g_data.bag:getItemWithName(name)

					if bagItem then
						self.getItemFromBg(self, bagItem, i)
					else
						local mods = {
							19,
							20,
							21,
							22,
							23,
							24,
							26
						}
						local bagItem = g_data.bag:getItemWithstdMode(mods)

						if bagItem then
							self.getItemFromBg(self, bagItem, i)
						else
							break
						end
					end
				end
			end
		end

		return 
	end

	local panelNum = #self.items
	local count = panelNum

	if 1 < #self.items then
		for i = 1, #self.items - 1, 1 do
			if not self.items[i] then
				local name = "黑铁矿石"
				local bagItem = g_data.bag:getItemWithName(name)

				if bagItem then
					self.getItemFromBg(self, bagItem, i)
				else
					local mods = {
						19,
						20,
						21,
						22,
						23,
						24,
						26
					}
					local bagItem = g_data.bag:getItemWithstdMode(mods)

					if bagItem then
						self.getItemFromBg(self, bagItem, i)
					else
						break
					end
				end
			end
		end
	end

	for i = panelNum + 1, self.max - 1, 1 do
		local name = "黑铁矿石"
		local bagItem = g_data.bag:getItemWithName(name)

		if bagItem then
			count = count + 1

			self.getItemFromBg(self, bagItem, i)
		else
			break
		end
	end

	local mods = {
		19,
		20,
		21,
		22,
		23,
		24,
		26
	}

	for i = count + 1, self.max, 1 do
		local bagItem = g_data.bag:getItemWithstdMode(mods)

		if bagItem then
			self.getItemFromBg(self, bagItem, i)
		else
			break
		end
	end

	return 
end
upgradeWeapon.itemsBack2bag = function (self)
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

	g_data.bag.upgradeWeapon = {}

	return 
end
upgradeWeapon.addItem = function (self, idx, data)
	sound.play("item", data)

	local canAdd = false

	if data.getVar(data, "name") == "黑铁矿石" then
		canAdd = true
	else
		local modes = {
			19,
			20,
			21,
			22,
			23,
			24,
			26
		}

		for k, v in pairs(modes) do
			if data.getVar(data, "stdMode") == v then
				canAdd = true
			end
		end
	end

	if not canAdd then
		main_scene.ui:tip("请放入黑铁矿石或者首饰")
		self.rebackBag(self, data)

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

	self.items[idx] = item.new(data, self, {
		idx = idx
	}):addto(self, 3):pos(self.idx2pos(self, idx))
	self.items[idx].isItems = true
	g_data.bag.upgradeWeapon[idx] = data

	return 
end
upgradeWeapon.enterUpdate = function (self)
	an.newMsgbox("你的武器已开始修炼\n请于1小时后来领取武器", nil, {
		center = true
	})

	return 
end

return upgradeWeapon
