local common = import("..common.common")
local item = import("..common.item")
local itemInfo = import("..common.itemInfo")
local jewelryComposition = class("jewelryComposition", function ()
	return display.newNode()
end)
local config = {
	法神手镯 = "烈焰护腕",
	三眼手镯 = "天尊手镯",
	法神戒指 = "烈焰魔戒",
	龙之手镯 = "法神手镯",
	灵魂项链 = "天尊项链",
	恶魔铃铛 = "法神项链",
	青铜腰带 = "钢铁腰带",
	圣战头盔 = "雷霆战盔",
	绿色项链 = "圣战项链",
	圣战项链 = "雷霆项链",
	天尊手镯 = "光芒护腕",
	紫绸靴 = "避魂靴",
	天尊头盔 = "光芒道盔",
	圣战手镯 = "雷霆护腕",
	骑士手镯 = "圣战手镯",
	紫碧螺 = "法神戒指",
	圣战戒指 = "雷霆战戒",
	天尊戒指 = "光芒道戒",
	泰坦戒指 = "天尊戒指",
	力量戒指 = "圣战戒指",
	法神头盔 = "烈焰魔盔",
	天尊项链 = "光芒项链",
	法神项链 = "烈焰项链",
	黑铁头盔 = {
		"圣战头盔",
		"法神头盔",
		"天尊头盔"
	},
	钢铁腰带 = {
		"雷霆腰带",
		"烈焰腰带",
		"光芒腰带"
	},
	避魂靴 = {
		"雷霆战靴",
		"烈焰魔靴",
		"光芒道靴"
	}
}
local bestConfig = {
	真魂手镯 = "光芒护腕-战神碎片",
	圣魔头盔 = "烈焰魔盔-战神碎片",
	圣魔靴 = "烈焰魔靴-战神碎片",
	圣魔腰带 = "烈焰腰带-战神碎片",
	星王法靴 = "烈焰魔靴-星王碎片",
	战神手镯 = "雷霆护腕-战神碎片",
	战神项链 = "雷霆项链-战神碎片",
	星王魔戒 = "烈焰魔戒-星王碎片",
	["星王护腕(法)"] = "烈焰护腕-星王碎片",
	["星王护腕(道)"] = "光芒护腕-星王碎片",
	战神腰带 = "雷霆腰带-战神碎片",
	星王道靴 = "光芒道靴-星王碎片",
	圣魔戒指 = "烈焰魔戒-战神碎片",
	真魂项链 = "光芒项链-战神碎片",
	星王战盔 = "雷霆战盔-星王碎片",
	圣魔项链 = "烈焰项链-战神碎片",
	星王法冠 = "烈焰魔盔-星王碎片",
	真魂腰带 = "光芒腰带-战神碎片",
	战神头盔 = "雷霆战盔-战神碎片",
	["星王护腕(战)"] = "雷霆护腕-星王碎片",
	["星王腰带(法)"] = "烈焰腰带-星王碎片",
	圣魔手镯 = "烈焰护腕-战神碎片",
	星王战戒 = "雷霆战戒-星王碎片",
	真魂靴 = "光芒道靴-战神碎片",
	["星王腰带(道)"] = "光芒腰带-星王碎片",
	["星王腰带(战)"] = "雷霆腰带-星王碎片",
	["星王项链(法)"] = "烈焰项链-星王碎片",
	战神戒指 = "雷霆战戒-战神碎片",
	["星王项链(道)"] = "光芒项链-星王碎片",
	星王道戒 = "光芒道戒-星王碎片",
	真魂头盔 = "光芒道盔-战神碎片",
	星王战靴 = "雷霆战靴-星王碎片",
	真魂戒指 = "光芒道戒-战神碎片",
	星王道盔 = "光芒道盔-星王碎片",
	["星王项链(战)"] = "雷霆项链-星王碎片",
	战神靴 = "雷霆战靴-战神碎片"
}
local holy_jewelry = {
	王者法冠 = "烈焰魔盔-王者结晶",
	王者道盔 = "光芒道盔-王者结晶",
	["王者腰带(战)"] = "雷霆腰带-王者结晶",
	["王者腰带(法)"] = "烈焰腰带-王者结晶",
	["王者护腕(法)"] = "烈焰护腕-王者碎片",
	王者道戒 = "光芒道戒-王者碎片",
	王者道靴 = "光芒道靴-王者结晶",
	王者法靴 = "烈焰魔靴-王者结晶",
	王者魔戒 = "烈焰魔戒-王者碎片",
	["王者项链(道)"] = "光芒项链-王者碎片",
	["王者项链(法)"] = "烈焰项链-王者碎片",
	["王者护腕(道)"] = "光芒护腕-王者碎片",
	["王者护腕(战)"] = "雷霆护腕-王者碎片",
	王者战靴 = "雷霆战靴-王者结晶",
	["王者项链(战)"] = "雷霆项链-王者碎片",
	王者战戒 = "雷霆战戒-王者碎片",
	["王者腰带(道)"] = "光芒腰带-王者结晶",
	王者战盔 = "雷霆战盔-王者结晶"
}
local xw_jewelry = {
	"星王战戒",
	"星王魔戒",
	"星王道戒",
	"星王护腕(战)",
	"星王护腕(法)",
	"星王护腕(道)",
	"星王项链(战)",
	"星王项链(法)",
	"星王项链(道)",
	"星王战盔",
	"星王法冠",
	"星王道盔",
	"星王腰带(战)",
	"星王腰带(法)",
	"星王腰带(道)",
	"星王战靴",
	"星王法靴",
	"星王道靴"
}
local qhml_jewelry = {
	强化烈焰魔盔 = "烈焰魔盔-魔龙凭证",
	强化雷霆战靴 = "雷霆战靴-魔龙凭证",
	强化光芒道戒 = "光芒道戒-魔龙凭证",
	强化光芒项链 = "光芒项链-魔龙凭证",
	强化雷霆战戒 = "雷霆战戒-魔龙凭证",
	强化烈焰腰带 = "烈焰腰带-魔龙凭证",
	强化烈焰魔靴 = "烈焰魔靴-魔龙凭证",
	强化雷霆护腕 = "雷霆护腕-魔龙凭证",
	强化光芒护腕 = "光芒护腕-魔龙凭证",
	强化烈焰项链 = "烈焰项链-魔龙凭证",
	强化光芒道盔 = "光芒道盔-魔龙凭证",
	强化雷霆腰带 = "雷霆腰带-魔龙凭证",
	强化烈焰护腕 = "烈焰护腕-魔龙凭证",
	强化雷霆项链 = "雷霆项链-魔龙凭证",
	强化光芒腰带 = "光芒腰带-魔龙凭证",
	强化烈焰魔戒 = "烈焰魔戒-魔龙凭证",
	强化雷霆战盔 = "雷霆战盔-魔龙凭证",
	强化光芒道靴 = "光芒道靴-魔龙凭证"
}

table.merge(slot3, {
	isBest = false,
	isQHML = false,
	items = {},
	targetList = {}
})

jewelryComposition.ctor = function (self, targetName)
	self.targetName = targetName
	self._scale = self.getScale(self)
	self._supportMove = true

	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_SS_DOWN, self, self.onSM_SS_DOWN)
	g_data.eventDispatcher:addListener("NPC_DIALOG_CLOSE", self, self.handleNpcDlgClose)

	local bg = res.get2("pic/panels/fusion/bg1.png"):anchor(0, 0):addto(self)
	local center = res.get2("pic/panels/fusion/bg.png"):anchor(0.5, 0):pos(bg.getw(bg)/2, 12):addto(bg)
	self.center = center

	an.newLabel("首饰合成", 22, 1, {
		color = def.colors.title
	}):addTo(bg):pos(bg.getw(bg)/2, bg.geth(bg) - 3):anchor(0.5, 1)
	self.size(self, cc.size(bg.getContentSize(bg).width, bg.getContentSize(bg).height)):anchor(0, 1):pos(10, display.height - 80)
	self.setNodeEventEnabled(self, true)

	local loopEffAni = res.getani2("pic/panels/fusion/effect/1/%d.png", 1, 8, 0.12)

	loopEffAni.retain(loopEffAni)

	local loopEffSpr = res.get2("pic/panels/fusion/effect/1/1.png"):pos(center.getw(center)*0.5, center.geth(center)*0.5):add2(center, 1)

	loopEffSpr.runForever(loopEffSpr, cc.Animate:create(loopEffAni))

	self.targetBgEffect = res.get2("pic/panels/fusion/effect/3/1.png"):add2(self, 4):pos(190, 228):hide()
	local centerAni = res.getani2("pic/panels/fusion/effect/3/%d.png", 1, 16, 0.26)

	centerAni.retain(centerAni)
	self.targetBgEffect:runForever(cc.Animate:create(centerAni))
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		if main_scene.ui.panels.bag then
			main_scene.ui:hidePanel("bag")
		end

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot7, 1, 1):pos(self.getw(self) - 4, self.geth(self) - 4):addto(self)

	for v, k in pairs(qhml_jewelry) do
		if v == targetName then
			self.isQHML = true

			break
		end
	end

	if self.isQHML then
		self.showQHMLView(self, targetName)

		self.qhmlItem = {}

		return 
	end

	self.boxs = {}
	self.boxPos = {
		{
			x = 104,
			y = 354
		},
		{
			x = 284,
			y = 354
		},
		{
			x = 318,
			y = 208
		},
		{
			x = 258,
			y = 126
		},
		{
			x = 128,
			y = 126
		},
		{
			x = 62,
			y = 208
		},
		{
			x = 190,
			y = 248
		}
	}

	res.get2("pic/panels/fusion/equip3.png"):pos(self.boxPos[7].x, self.boxPos[7].y):add2(bg, 2)

	for i = 1, 7, 1 do
		self.boxs[i] = res.get2("pic/panels/fusion/equip.png"):pos(self.boxPos[i].x, self.boxPos[i].y):add2(bg, 2)

		res.get2("pic/panels/fusion/" .. self.getState(self, i) .. ".png"):pos(self.boxs[i]:getw()*0.5, self.boxs[i]:geth()*0.5):add2(self.boxs[i]):enableClick(function (x, y)
			self:boxClick(i)

			return 
		end)
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		self:beginComposing()

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"开始合成",
			20,
			0,
			{
				color = cc.c3b(240, 200, 150)
			}
		}
	}).add2(slot7, center, 2):anchor(0.5, 0.5):pos(center.getw(center)*0.5, 36)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		self:oneKey()

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"一键放入",
			20,
			0,
			{
				color = cc.c3b(240, 200, 150)
			}
		}
	}).add2(slot7, center, 2):anchor(0.5, 0.5):pos(center.getw(center)*0.5 - 114, 36)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		self:itemsBack2bag()

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"一键卸下",
			20,
			0,
			{
				color = cc.c3b(240, 200, 150)
			}
		}
	}).add2(slot7, center, 2):anchor(0.5, 0.5):pos(center.getw(center)*0.5 + 114, 36)

	self.items = {}

	self.addNodeEventListener(self, cc.NODE_EVENT, function (event)
		if event.name == "cleanup" then
			self:itemsBack2bag()
		end

		return 
	end)
	self.showBag(qhml_jewelry)

	self.material = {}

	local function splitMaterial(material_name)
		local material_list = string.split(material_name, "-")

		for i = 1, #material_list, 1 do
			self.material[i] = {}
			local mat = material_list[i]

			if string.find(material_list[i], "|") then
				local mat_temp = string.split(mat, "|")
				self.material[i].name = mat_temp[1]
				self.material[i].num = tonumber(mat_temp[2])
			else
				self.material[i].name = mat
				self.material[i].num = 1
			end
		end

		return 
	end

	if bestConfig[self.targetName] then
		self.isBest = true
		self.isHoly = false

		self.showPreviewTarget(qhml_jewelry)
		splitMaterial(bestConfig[self.targetName])
	elseif holy_jewelry[self.targetName] then
		self.isBest = false
		self.isHoly = true

		self.showPreviewTarget(self)
		splitMaterial(holy_jewelry[self.targetName])
	else
		self.targetName = ""
		self.isBest = false
		self.isHoly = false
	end

	return 
end
jewelryComposition.handleNpcDlgClose = function (self)
	self.hidePanel(self)

	if main_scene.ui.panels.bag then
		main_scene.ui:hidePanel("bag")
	end

	return 
end
jewelryComposition.getState = function (self, pos)
	if pos == 1 then
		return "plus"
	elseif pos == 7 then
		return "quest"
	else
		if self.items[pos - 1] then
			return "plus"
		end

		return "equip1"
	end

	return 
end
jewelryComposition.showResult = function (self)
	local x = self.getw(self)*0.5

	if self.isQHML then
		x = 290
	end

	local loopEffAni = res.getani2("pic/panels/fusion/effect/2/%d.png", 1, 8, 0.16)

	loopEffAni.retain(loopEffAni)

	local loopEffSpr = res.get2("pic/panels/fusion/effect/2/1.png"):pos(x, self.geth(self)*0.5):add2(self, 9)

	loopEffSpr.runs(loopEffSpr, {
		cc.Animate:create(loopEffAni),
		cc.CallFunc:create(function ()
			loopEffSpr:removeSelf()

			return 
		end)
	})

	return 
end
jewelryComposition.showBag = function (self)
	if main_scene.ui.panels then
		if not main_scene.ui.panels.bag then
			main_scene.ui:togglePanel("bag")
		end

		main_scene.ui.panels.bag:pos(self.getw(self) + 10, display.height - 80)
	end

	return 
end
jewelryComposition.idx2pos = function (self, idx)
	return self.boxPos[idx].x, self.boxPos[idx].y
end
jewelryComposition.getBackItem = function (self, item)
	local data = item.data

	if not data then
		return 
	end

	self.addItemToBag(self, data)

	for i, v in pairs(self.items) do
		local d = v.data

		if v and v.data.FItemIdent == data.FItemIdent then
			v.removeSelf(v)

			self.items[i] = nil
			g_data.bag.jewelryComposition[i] = nil

			if i == 1 then
				self.itemsBack2bag(self)
			else
				self.boxs[i]:setTex("pic/panels/fusion/equip.png")
				res.get2("pic/panels/fusion/" .. self.getState(self, i) .. ".png"):pos(self.boxs[i]:getw()*0.5, self.boxs[i]:geth()*0.5):add2(self.boxs[i]):enableClick(function (x, y)
					self:boxClick(i)

					return 
				end)

				if not self.items[i - 1] then
					self.boxs[i - 1].setTex(slot9, "pic/panels/fusion/equip.png")
					res.get2("pic/panels/fusion/" .. self.getState(self, i - 1) .. ".png"):pos(self.boxs[i - 1]:getw()*0.5, self.boxs[i - 1]:geth()*0.5):add2(self.boxs[i - 1]):enableClick(function (x, y)
						self:boxClick(i - 1)

						return 
					end)
				end

				if not self.items[i + 1] and i ~= 6 then
					self.boxs[i + 1].setTex(slot9, "pic/panels/fusion/equip.png")
					res.get2("pic/panels/fusion/" .. self.getState(self, i + 1) .. ".png"):pos(self.boxs[i + 1]:getw()*0.5, self.boxs[i + 1]:geth()*0.5):add2(self.boxs[i + 1]):enableClick(function (x, y)
						self:boxClick(i + 1)

						return 
					end)
				end
			end

			return 
		end
	end
end
jewelryComposition.isXingWang = function (self, data)
	for k, v in pairs(xw_jewelry) do
		if v == data.getVar(data, "name") then
			return true
		end
	end

	return false
end
jewelryComposition.getItemFromBg = function (self, data, pos)
	local tmpItem = self.items[pos]

	if tmpItem then
		if data.getVar(data, "name") == tmpItem.data:getVar("name") then
			main_scene.ui:tip("放入相同物品")

			return 
		else
			main_scene.ui:tip("请放入正确的材料")

			return 
		end
	elseif pos == 1 then
		if self.isBest then
			if self.material[1].name ~= data.getVar(data, "name") then
				main_scene.ui:tip("请放入" .. self.material[1].name)

				return 
			end
		elseif self.isHoly then
			if self.material[1].name ~= data.getVar(data, "name") then
				main_scene.ui:tip("请放入" .. self.material[1].name)

				return 
			end
		elseif checkExist(data.getVar(data, "name"), "强化魔龙碎片", "战神碎片", "星王碎片") or bestConfig[data.getVar(data, "name")] or not config[data.getVar(data, "name")] then
			main_scene.ui:tip("请放入正确的材料")

			return 
		end
	elseif self.isBest then
		if self.material[2].name ~= data.getVar(data, "name") then
			main_scene.ui:tip("请放入正确的材料")

			return 
		end
	elseif self.isHoly then
		if not self.isXingWang(self, data) and self.material[2].name ~= data.getVar(data, "name") then
			main_scene.ui:tip("请放入正确的材料")

			return 
		else
			local xw_count, cl_count = self.getClNum(self)

			if self.isXingWang(self, data) and 2 <= xw_count then
				main_scene.ui:tip("已包含两件星王级首饰了")

				return 
			elseif self.material[2].name == data.getVar(data, "name") and 3 <= cl_count then
				main_scene.ui:tip("已包含三个" .. data.getVar(data, "name") .. "了")
			end
		end
	elseif data.getVar(data, "name") ~= self.items[1].data:getVar("name") then
		main_scene.ui:tip("放入材料不正确")

		return 
	end

	self.delItemFromBag(self, data)
	g_data.client:setLastTime("fusion", true)
	sound.play("item", data)
	self.boxs[pos]:removeAllChildren()
	self.boxs[pos]:setTex("pic/panels/fusion/equip_0.png")

	self.items[pos] = item.new(data, self, {
		idx = pos
	}):addto(self, 3):pos(self.idx2pos(self, pos))
	g_data.bag.jewelryComposition[pos] = data

	if pos == 1 and self.isBest == false and self.isHoly == false then
		local iname = self.items[1].data:getVar("name")
		self.targetName = config[iname]

		self.showPreviewTarget(self)
	end

	if pos < 6 and not self.items[pos + 1] then
		self.boxs[pos + 1]:removeAllChildren()
		res.get2("pic/panels/fusion/plus.png"):pos(self.boxs[pos + 1]:getw()*0.5, self.boxs[pos + 1]:geth()*0.5):add2(self.boxs[pos + 1]):enableClick(function (x, y)
			self:boxClick(pos + 1)

			return 
		end)
	end

	return 
end
jewelryComposition.addItemToBag = function (self, data)
	g_data.bag:addItem(data)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:addItem(data.FItemIdent)
	end

	return 
end
jewelryComposition.delItemFromBag = function (self, data)
	g_data.bag:delItem(data.FItemIdent)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:delItem(data.FItemIdent)
	end

	return 
end
jewelryComposition.getClNum = function (self)
	local xw_count = 0
	local cl_count = 0

	for i, v in pairs(self.items) do
		if self.isXingWang(self, v.data) then
			xw_count = xw_count + 1
		end

		if v.data:getVar("name") == self.material[2].name then
			cl_count = cl_count + 1
		end
	end

	return xw_count, cl_count
end
jewelryComposition.getNextItemName = function (self)
	local name = ""

	if self.isHoly then
		local xw_count, cl_count = self.getClNum(self)

		if xw_count < 2 then
			local target = g_data.bag:getItemWithTable(xw_jewelry)

			if target then
				name = target.getVar(target, "name")
			end
		end

		if name == "" and cl_count < 3 then
			name = self.material[2].name
		end
	end

	return name
end
jewelryComposition.boxClick = function (self, idx)
	if self.items[1] and self.getState(self, idx) == "plus" then
		local name = ""

		if self.isBest then
			name = self.material[2].name
		elseif self.isHoly then
			name = self.getNextItemName(self)
		else
			name = self.items[1].data:getVar("name")
		end

		local bagItem = g_data.bag:getItemWithName(name)

		if bagItem then
			self.getItemFromBg(self, bagItem, idx)
		else
			main_scene.ui:tip("材料不足")
		end
	end

	return 
end
jewelryComposition.composingHolyJew = function (self)
	local function isElitesJewelry(data)
		local attributeRefin = data.getVar(data, "AttributeRefin") and tonumber(data.getVar(data, "AttributeRefin"))

		if attributeRefin and 2 <= attributeRefin then
			return true
		end

		for k, v in ipairs(data.FItemValueList) do
			if 59 <= v.FValueType and v.FValueType <= 77 and v.FValueType ~= 73 then
				return true
			end
		end

		return data.isGoodItem(data)
	end

	local hasElitesJewelrys = {}

	for i, v in pairs(self.items) do
		if slot1(v.data) then
			hasElitesJewelrys[#hasElitesJewelrys + 1] = v.data:getVar("name")
		end
	end

	if 0 < #hasElitesJewelrys then
		local eqName = ""

		for k, v in ipairs(hasElitesJewelrys) do
			eqName = eqName .. v

			if k < #hasElitesJewelrys then
				eqName = eqName .. "、"
			end
		end

		an.newMsgbox("放入的" .. eqName .. "已经被洗练、精炼或鉴定过。\n合成后，装备的洗练属性、精炼属性、鉴定属性将会全部消失，确认要合成吗？", function (isOk)
			if isOk == 1 then
				an.newMsgbox(string.format("开始合成%s吗？", self.targetName), function (isOk)
					if isOk == 1 then
						self:requestMake()
					end

					return 
				end, {
					fontSize = 20,
					title = "提示",
					center = true,
					hasCancel = true
				})
			end

			return 
		end, {
			fontSize = 20,
			title = "提示",
			center = false,
			hasCancel = true
		})
	else
		an.newMsgbox(string.format("开始合成%s吗？", self.targetName), function (isOk)
			if isOk == 1 then
				self:requestMake()
			end

			return 
		end, {
			fontSize = 20,
			title = "提示",
			center = true,
			hasCancel = true
		})
	end

	return 
end
jewelryComposition.requestMake = function (self)
	local xw_count, cl_count = self.getClNum(self)

	if self.items[1].data:getVar("name") ~= self.material[1].name or xw_count ~= 2 or cl_count ~= 3 then
		main_scene.ui:tip("材料异常", 6)

		return 
	end

	local itemList = {}

	for i = 1, 6, 1 do
		itemList[#itemList + 1] = self.items[i].data.FItemIdent
	end

	itemList[7] = 1
	itemList[8] = 1
	local rsb = DefaultClientMessage(CM_SS_UP)
	rsb.FItem_List = itemList

	MirTcpClient:getInstance():postRsb(rsb)

	return 
end
jewelryComposition.beginComposing = function (self)
	for i = 1, 6, 1 do
		if not self.items[i] then
			main_scene.ui:tip("材料不足")

			return 
		end
	end

	if self.isHoly then
		self.composingHolyJew(self)

		return 
	end

	local msgbox = nil
	slot2 = an.newMsgbox("", function (idx)
		if idx == 1 then
			local itemList = {}

			for i = 1, 6, 1 do
				itemList[#itemList + 1] = self.items[i].data.FItemIdent
			end

			local rsb = DefaultClientMessage(CM_SS_UP)
			rsb.FItem_List = itemList

			if self.isBest then
				itemList[#itemList + 1] = def.items.getItemIdByName(self.targetName)
			end

			MirTcpClient:getInstance():postRsb(rsb)
		end

		return 
	end, {
		disableScroll = true,
		btnTexts = {
			"确定",
			"取消"
		}
	})
	msgbox = slot2
	local labelInfo = ""

	if 1 < #self.targetList then
		labelInfo = "开始合成 "

		for i, v in ipairs(self.targetList) do
			local data = def.items[v] or {}
			labelInfo = labelInfo .. "\"" .. (data.name or "") .. "\","
		end

		labelInfo = labelInfo .. "中的随机一件吗？"
	else
		labelInfo = "开始合成 \"" .. self.target.info:getVar("name") .. "\"吗？"
	end

	local tmpLabel = cc.LabelTTF:create(labelInfo, "", 18, cc.size(320, 0), 1)

	tmpLabel.anchor(tmpLabel, 0.5, 1)
	tmpLabel.setColor(tmpLabel, def.colors.text)
	tmpLabel.setPosition(tmpLabel, msgbox.bg:getw()*0.5, msgbox.bg:geth()*0.5 + 18)
	msgbox.bg:addChild(tmpLabel)

	return 
end
jewelryComposition.oneKey = function (self)
	if not self.items[1] then
		main_scene.ui:tip("一键放入失败")

		return 
	end

	local name = ""

	if self.isBest then
		name = self.material[2].name
	else
		name = self.items[1].data:getVar("name")
	end

	local itemNum = 0

	for k, v in pairs(self.items) do
		itemNum = itemNum + 1
	end

	if itemNum == 6 then
		main_scene.ui:tip("材料已放满")

		return 
	end

	for i = 2, 6, 1 do
		if self.isHoly then
			name = self.getNextItemName(self)

			if name == "" then
				return 
			end
		end

		local bagItem = g_data.bag:getItemWithName(name)

		if bagItem then
			if not self.items[i] then
				self.getItemFromBg(self, bagItem, i)
			end
		else
			main_scene.ui:tip("一键放入材料不足")

			return 
		end
	end

	return 
end
jewelryComposition.itemsBack2bag = function (self)
	for i, v in pairs(self.items) do
		self.addItemToBag(self, v.data)
		v.removeSelf(v)
	end

	self.items = {}

	if self.isBest == false and self.target and self.isHoly == false then
		self.target:removeSelf()

		self.target = nil
		self.target = nil
		self.targetList = {}
	end

	for i = 1, 7, 1 do
		if i == 7 and (self.isBest == true or self.isHoly == true) then
			break
		end

		self.boxs[i]:removeAllChildren()
		self.boxs[i]:setTex("pic/panels/fusion/equip.png")
		res.get2("pic/panels/fusion/" .. self.getState(self, i) .. ".png"):pos(self.boxs[i]:getw()*0.5, self.boxs[i]:geth()*0.5):add2(self.boxs[i]):enableClick(function (x, y)
			self:boxClick(i)

			return 
		end)
	end

	g_data.bag.jewelryComposition = {}

	return 
end
jewelryComposition.cleanItems = function (self)
	for i, v in pairs(self.items) do
		v.removeSelf(v)
	end

	self.items = {}

	if self.isBest == false and self.target and self.isHoly == false then
		self.targetName = nil

		self.target:removeSelf()

		self.target = nil
		self.targetList = {}
	end

	for i = 1, 7, 1 do
		if i == 7 and (self.isBest == true or self.isHoly == true) then
			return 
		end

		self.boxs[i]:removeAllChildren()
		self.boxs[i]:setTex("pic/panels/fusion/equip.png")
		res.get2("pic/panels/fusion/" .. self.getState(self, i) .. ".png"):pos(self.boxs[i]:getw()*0.5, self.boxs[i]:geth()*0.5):add2(self.boxs[i]):enableClick(function (x, y)
			self:boxClick(i)

			return 
		end)
	end
end
jewelryComposition.putItem = function (self, item, x, y)
	local form = item.formPanel.__cname

	if self.isQHML then
		if self.materialname ~= item.data:getVar("name") then
			main_scene.ui:tip("请放入正确的材料")

			return 
		end

		g_data.bag.jewelryComposition = {}

		if form == "bag" then
			local data = item.data

			print("物品放入，当前已有物品数量：", tostring(#self.qhmlItem))

			if 0 < #self.qhmlItem then
				self.addItemToBag(self, self.qhmlItem[1])
			end

			self.qhmlItem[1] = data

			self.delItemFromBag(self, data)

			g_data.bag.jewelryComposition[1] = data
			self.targetListL[1] = def.items.getItemIdByName(self.materialname)
			local info = def.items[self.targetListL[1]]

			if self.targetLeft then
				self.targetLeft:removeSelf()
			end

			self.targetLeft = res.get("items", info.looks):addto(self.leftFrame, 3):pos(self.leftFrame:getw()/2, self.leftFrame:geth()/2)
			self.targetLeft.info = info

			self.targetLeft:enableClick(function (x, y)
				self:showSimpleTips(self.targetListL, cc.p(x, y))

				return 
			end)
		end

		return 
	end

	local target = nil

	for i = 1, 6, 1 do
		local tmpX, tmpY = self.idx2pos(slot0, i)

		if (tmpX - x)*(tmpX - x) < 1600 and (tmpY - y)*(tmpY - y) < 1600 then
			target = i
		end
	end

	if not target then
		return 
	elseif item.data:isBinded() then
		main_scene.ui:tip("绑定装备不可作为材料")

		return 
	elseif target ~= 1 and not self.items[1] then
		main_scene.ui:tip("请将材料放入正确的位置")

		return 
	elseif target ~= 1 and self.getState(self, target) ~= "plus" then
		main_scene.ui:tip("请依次放入材料")

		return 
	end

	if form == "bag" and g_data.client:checkLastTime("jewelryComposition", 2) then
		local data = item.data

		self.getItemFromBg(self, data, target)
	end

	return 
end
jewelryComposition.showPreviewTarget = function (self)
	self.targetList = {}

	if type(self.targetName) == "table" then
		for k, v in pairs(self.targetName) do
			local id = def.items.getItemIdByName(v)
			self.targetList[#self.targetList + 1] = id
		end
	else
		local id = def.items.getItemIdByName(self.targetName)
		self.targetList[#self.targetList + 1] = id
	end

	self.addItems(self)

	return 
end
jewelryComposition.addItems = function (self)
	local target = self.targetList[1]
	local info = def.items[target] or {}

	if self.target then
		self.target:removeSelf()
	end

	self.target = res.get("items", info.looks):addto(self, 3):pos(self.idx2pos(self, 7))
	self.target.info = info

	self.target:enableClick(function (x, y)
		self:showSimpleTips(self.targetList, cc.p(x, y))

		return 
	end)

	if 1 < #self.targetList then
		local frames = {}

		for i, v in ipairs(self.targetList) do
			local data = def.items[v] or {}
			frames[#frames + 1] = res.getframe("items", data.looks or 0)
		end

		local animation = cc.Animation.createWithSpriteFrames(slot4, frames, 1)

		animation.retain(animation)
		self.target:runForever(cc.Animate:create(animation))
	end

	self.boxs[7]:removeAllChildren()
	self.boxs[7]:setTex("pic/panels/fusion/equip_0.png")
	self.targetBgEffect:show()

	return 
end
jewelryComposition.onSM_SS_DOWN = function (self, result, protoId)
	if result then
		if result.FItemId ~= -1 then
			self.showResult(self)

			g_data.bag.jewelryComposition = {}

			if self.isQHML then
				self.targetLeft:removeSelf()

				self.qhmlItem = {}
			else
				self.cleanItems(self)
			end
		else
			local errorMsg = {
				"首饰合成的可用原料数量不足！",
				"首饰合成的目标物品不存在！",
				"不能删除背包的原料!",
				"首饰合成中背包不能增加!"
			}

			main_scene.ui:tip(errorMsg[result.Flag] or "未知错误")
		end
	end

	return 
end
jewelryComposition.showSimpleTips = function (self, targetList, scenePos)
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
				addAttr2("魔法躲避: +", maxAC, maxACN, display.COLOR_GREEN)
			end

			if 0 < maxMAC then
				addAttr2("幸运: +", maxMAC, maxMACN)
			end

			if 0 < MAC then
				add("诅咒: +" .. MAC)
			end
		elseif stdMode == 20 or stdMode == 24 then
			if 0 < AC then
				addAttr2("准确: +", maxAC, maxACN)
			end

			if 0 < MAC then
				addAttr2("敏捷: +", maxMAC, maxMACN)
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
			addAttr(data, "防御: ", "AC")
			addAttr(data, "魔御: ", "MAC")

			if 0 < data.aniCount then
				add("负重: +" .. data.aniCount)
			end
		elseif stdMode == 63 then
			if 0 < AC then
				add("HP: +" .. AC)
			end

			if 0 < maxAC then
				add("MP: +" .. maxAC)
			end

			if 0 < maxMAC then
				addAttr2("幸运: +", maxMAC, maxMACN)
			end

			if 0 < MAC then
				add("诅咒: +" .. MAC)
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
jewelryComposition.showQHMLView = function (self, itemname)
	self.leftFrame = res.get2("pic/panels/drumUpgrade/drumBgLeft.png"):addTo(self):pos(90, 250)
	self.rightFrame = res.get2("pic/panels/drumUpgrade/drumBgRight.png"):addTo(self):pos(290, 250)

	res.get2("pic/panels/drumUpgrade/arrow.png"):addTo(self):pos(185, 250)

	self.targetListR = {}
	self.targetListL = {}
	local strmaterial = qhml_jewelry[itemname]
	local material_list = string.split(strmaterial, "-")
	local materialname = material_list[1]
	self.materialname = materialname
	self.targetListR[1] = def.items.getItemIdByName(itemname)
	local info = def.items[self.targetListR[1]]

	if self.targetRight then
		self.targetRight:removeSelf()
	end

	self.targetRight = res.get("items", info.looks):addto(self.rightFrame, 3):pos(self.rightFrame:getw()/2, self.rightFrame:geth()/2)
	self.targetRight.info = info

	self.targetRight:enableClick(function (x, y)
		self:showSimpleTips(self.targetListR, cc.p(x, y))

		return 
	end)

	local LabelM = an.newLabelM(200, 18, 0, {
		center = true
	}).add2(slot6, self.center, 2):anchor(0.5, 0.5):pos(self.center:getw()/2, 100)

	LabelM.addLabel(LabelM, "所需材料：")
	LabelM.addLabel(LabelM, "魔龙凭证*5\n", cc.c3b(255, 0, 0))
	LabelM.addLabel(LabelM, "将直接从背包中扣除")
	res.get2("pic/panels/drumUpgrade/line.png"):addTo(self):pos(self.center:getw()/2, 80):anchor(0.5, 0.5):scaleX(0.7)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		print("开始合成，当前已有物品数量：", tostring(#self.qhmlItem))

		if #self.qhmlItem <= 0 then
			main_scene.ui:tip("请放入需升级的装备")

			return 
		end

		local texts = {
			{
				"开始合成",
				cc.c3b(255, 255, 255)
			},
			{
				itemname,
				cc.c3b(255, 255, 255)
			},
			{
				"吗?\n注：",
				cc.c3b(255, 255, 255)
			},
			{
				"合成后装备的洗炼、精炼、鉴定属性将全部消失。",
				cc.c3b(255, 0, 0)
			}
		}

		an.newMsgbox(texts, function (isOk)
			if isOk == 1 then
				local rsb = DefaultClientMessage(CM_SS_UP)
				rsb.FItem_List = {
					self.qhmlItem[1].FItemIdent
				}

				MirTcpClient:getInstance():postRsb(rsb)
			end

			return 
		end, {
			fontSize = 20,
			title = "提示",
			center = true,
			hasCancel = true
		})

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"开始合成",
			20,
			0,
			{
				color = cc.c3b(240, 200, 150)
			}
		}
	}).add2(slot7, self.center, 2):anchor(0.5, 0.5):pos(self.center:getw()*0.5, 36)
	self.addNodeEventListener(self, cc.NODE_EVENT, function (event)
		if event.name == "cleanup" then
			if 0 < #self.qhmlItem then
				self:addItemToBag(self.qhmlItem[1])
			end

			g_data.bag.jewelryComposition = {}
		end

		return 
	end)
	self.showBag(qhml_jewelry)

	return 
end

return jewelryComposition
