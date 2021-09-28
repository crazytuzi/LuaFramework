local CommonItem = import("..common.item")
local CommonItemInfo = import("..common.itemInfo")
local horseSoulComposition = class("horseSoulComposition", import(".panelBase"))
horseSoulComposition.ctor = function (self, type)
	self.super.ctor(self)
	self.setMoveable(self, true)

	self.max = 3
	self.items = {}
	self.bOpenPut = false
	self.selStoneType = ""
	self.selStoneLevel = 0

	return 
end
horseSoulComposition.onEnter = function (self)
	self.initPanelUI(self, {
		closeOffsetY = -4,
		title = "合成兽魂石",
		bg = "pic/common/tabbg.png",
		titleOffsetY = -4
	})
	self.anchor(self, 1, 1):pos(display.width/2, display.height - 80)

	local texts = {
		{
			"1、消耗金币、任意3颗同等级兽魂石，可100%合成1颗下级兽魂石。\n"
		},
		{
			"2、兽魂等级达到2阶2星/2阶10星/4阶5星/5阶10星/7阶10星/9阶10星才可合成和镶嵌4/5/6/7/8/9级兽魂石。\n"
		},
		{
			"3、设定合成目标兽魂石后，即可查看目标兽魂石属性。\n"
		},
		{
			"4、合成兽魂石时有一定的几率出现极品兽魂石。\n"
		}
	}

	an.newBtn(res.gettex2("pic/common/question.png"), function ()
		sound.playSound("103")
		an.newMsgbox(texts, nil, {
			contentLabelSize = 20,
			title = "提示"
		})

		return 
	end, {
		pressBig = true,
		pressImage = res.gettex2("pic/common/question.png")
	}).pos(slot2, 40, 390):addto(self.bg, 2)
	res.get2("pic/panels/horseSoul/horseSoulBg2.jpg"):anchor(0.5, 0):pos(self.bg:getw()/2, 20):addto(self.bg)
	self.showBag(self)
	self.reload(self, false)

	self.aimSoulBg = an.newBtn(res.gettex2("pic/panels/horseSoul/hole.png"), function ()
		sound.playSound("103")
		main_scene.ui:togglePanel("horseSoulCompSelect", {
			selStoneType = self.selStoneType,
			selStoneLevel = self.selStoneLevel
		})

		return 
	end, {
		pressImage = res.gettex2("pic/panels/horseSoul/hole.png")
	}).anchor(slot2, 0.5, 0.5):pos(self.bg:getw()/2, self.bg:geth()/2 + 17):addTo(self.bg, 2)
	self.aimNode = display.newNode():addTo(self.aimSoulBg):pos(self.aimSoulBg:getw()/2, self.aimSoulBg:geth()/2)

	display.newSprite(res.gettex2("pic/common/plus.png")):anchor(0.5, 0.5):addTo(self.aimNode, 2)
	res.get2("pic/panels/equipforge/chance.png"):anchor(0.5, 0):pos(self.bg:getw()/2 + 7, self.bg:geth()/2 - 150):addto(self.bg)

	self.chanceLabel = an.newLabel("0%", 18, 0, {
		color = cc.c3b(240, 200, 150)
	}):anchor(0, 0):addTo(self.bg):pos(self.bg:getw()/2 + 17, self.bg:geth()/2 - 133)
	self.needJBLabel = an.newLabel("消耗金币：0", 18, 0, {
		color = cc.c3b(240, 200, 150)
	}):anchor(0, 0.5):addTo(self.bg):pos(self.bg:getw()/2 - 73, self.bg:geth()/2 - 150)

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		self:oneKeyPut()

		return 
	end, {
		clickSpace = 1,
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"一键放入",
			18,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).add2(slot2, self.bg):pos(self.bg:getw()/2 - 72, 50)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		self:startComposite()

		return 
	end, {
		clickSpace = 1,
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"合   成",
			18,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).add2(slot2, self.bg):pos(self.bg:getw()/2 + 72, 50)
	self.bindNetEvent(self, SM_MonSoulStoneCompose, self.onSM_MonSoulStoneCompose)
	def.horseSoul.setSelComSoulStone()
	self.bindNotify(self, "HorseSoul_SelStone", self.onHorseSoul_SelStone)

	return 
end
horseSoulComposition.onHorseSoul_SelStone = function (self)
	self.selStoneType, self.selStoneLevel = def.horseSoul.getSelComSoulStone()

	if self.selStoneType == "" or self.selStoneLevel == 0 then
		return 
	end

	self.oneKeyClear(self)

	if self.aimNode then
		self.aimNode:removeAllChildren()
	end

	local stoneName = self.selStoneLevel .. "级" .. self.selStoneType
	local itemIdx = def.items.getItemIdByName(stoneName)
	local selStoneData = def.items.getStdItemById(itemIdx)
	self.sprite = res.get("items", selStoneData.getVar(selStoneData, "looks") or 0):addto(self.aimNode)

	res.get2("pic/panels/horseSoul/change.png"):anchor(0.5, 0.5):pos(20, -20):addto(self.aimNode)
	self.reload(self, true)

	local stone = def.horseSoul.getComSoulStoneByIndex(itemIdx)

	if stone then
		if self.chanceLabel then
			self.chanceLabel:setText(stone.CompSuccChance .. "%")
		end

		if self.needJBLabel then
			self.needJBLabel:setText("消耗金币：" .. math.floor(stone.CompNeedJinBi/10000) .. "万")
		end
	end

	return 
end
horseSoulComposition.onCloseWindow = function (self)
	self.oneKeyClear(self)

	if main_scene.ui.panels.bag then
		main_scene.ui:togglePanel("bag")
	end

	return self.super.onCloseWindow(self)
end
horseSoulComposition.showBag = function (self)
	if main_scene.ui.panels then
		if main_scene.ui.panels.bag then
			local w = self.getw(self)

			main_scene.ui.panels.bag:pos(display.width/2 - 10, display.height - 80):anchor(0, 1)
		else
			main_scene.ui:togglePanel("bag")
			main_scene.ui.panels.bag:pos(display.width/2 - 10, display.height - 80):anchor(0, 1)
		end
	end

	return 
end
horseSoulComposition.reload = function (self, bOpen)
	for k, v in pairs(self.items) do
		v.removeSelf(v)
	end

	self.items = {}

	for i = 1, self.max, 1 do
		local itembg = res.get2("pic/panels/horseSoul/hole.png"):addTo(self.bg):pos(self.idx2pos(self, i))

		if not bOpen then
			res.get2("pic/panels/horseSoul/lock.png"):addTo(itembg):pos(itembg.getw(itembg)/2, itembg.geth(itembg)/2)
		end
	end

	if not bOpen then
		self.aimTiShiLabel = an.newLabel("请设定合成目标", 18, 0, {
			color = cc.c3b(240, 200, 150)
		}):anchor(0.5, 0.5):addTo(self.bg):pos(self.bg:getw()/2, self.bg:geth()/2 + 67)
	elseif self.aimTiShiLabel then
		local stoneName = self.selStoneLevel .. "级" .. self.selStoneType

		self.aimTiShiLabel:setText(stoneName)
	end

	self.bOpenPut = bOpen

	return 
end
horseSoulComposition.idx2pos = function (self, idx)
	if idx == 1 then
		return self.bg:getw()/2, self.bg:geth()/2 + 133
	elseif idx == 2 then
		return self.bg:getw()/2 - 97, self.bg:geth()/2 - 55
	elseif idx == 3 then
		return self.bg:getw()/2 + 97, self.bg:geth()/2 - 55
	end

	return self.bg:getw()/2, self.geth(self)/2
end
horseSoulComposition.oneKeyClear = function (self)
	for k, v in pairs(self.items) do
		self.rebackBag(self, v.data)
	end

	self.items = {}

	return 
end
horseSoulComposition.startComposite = function (self)
	local bPutAll = true

	for k = 1, 3, 1 do
		if not self.items[k] then
			bPutAll = false
		end
	end

	if not bPutAll then
		main_scene.ui:tip("合成材料不足", 6)

		return 
	end

	local bGoodProp = false

	for k = 1, 3, 1 do
		if self.items[k].data:isGoodItem() then
			bGoodProp = true
		end
	end

	if bGoodProp then
		an.newMsgbox("合成材料中有极品属性，继续合成吗？", function (isOk)
			if isOk == 1 then
				self:requestCompose()
			end

			return 
		end, {
			fontSize = 20,
			title = "提示",
			center = false,
			hasCancel = true
		})
	else
		self.requestCompose(slot0)
	end

	return 
end
horseSoulComposition.oneKeyPut = function (self)
	if not self.bOpenPut or self.selStoneType == "" or self.selStoneLevel == 0 then
		return 
	end

	local function getTrueHorseSoulStone()
		local stoneItems = g_data.bag:getItemsWithstdMode({
			37
		})

		for k, v in ipairs(stoneItems) do
			local stone = def.horseSoul.getComSoulStoneByIndex(v.FIndex)

			if stone and stone.StoneLv == self.selStoneLevel - 1 then
				return v
			end
		end

		return 
	end

	local bPutAll = true
	local notPut = true

	for k = 1, 3, 1 do
		if not self.items[k] then
			bPutAll = false
			local stoneData = slot1()

			if stoneData then
				notPut = false

				g_data.bag:delItem(stoneData.FItemIdent)

				if main_scene.ui.panels.bag then
					main_scene.ui.panels.bag:delItem(stoneData.FItemIdent)
				end

				self.addItem(self, k, stoneData)
			end
		end
	end

	if notPut and not bPutAll then
		main_scene.ui:tip("背包中材料不足", 6)
	end

	return 
end
horseSoulComposition.showResult = function (self)
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
horseSoulComposition.rebackBag = function (self, data)
	g_data.bag:addItem(data)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:addItem(data.FItemIdent)
	end

	self.delItem(self, data.FItemIdent)

	return 
end
horseSoulComposition.addItem = function (self, idx, data)
	sound.play("item", data)

	local tmpItem = self.items[idx]

	if tmpItem then
		self.rebackBag(self, tmpItem.data)
	end

	self.items[idx] = CommonItem.new(data, self, {
		idx = idx
	}):addto(self, 3):pos(self.idx2pos(self, idx))
	g_data.bag.horseSoulPanel[idx] = data

	return 
end
horseSoulComposition.putItem = function (self, item, x, y)
	local form = item.formPanel.__cname
	local target = nil

	for i = 1, self.max, 1 do
		local tmpX, tmpY = self.idx2pos(self, i)

		if (tmpX - x)*(tmpX - x) < 729 and (tmpY - y)*(tmpY - y) < 729 then
			target = i
		end
	end

	if not target or not self.bOpenPut then
		return 
	end

	if form == "bag" then
		local data = item.data

		if data.getVar(data, "stdMode") ~= 37 then
			main_scene.ui:tip("放入材料不正确", 6)

			return 
		end

		local stone = def.horseSoul.getComSoulStoneByIndex(data.FIndex)

		if stone and stone.StoneLv ~= self.selStoneLevel - 1 then
			main_scene.ui:tip("放入材料不正确", 6)

			return 
		end

		g_data.bag:delItem(data.FItemIdent)

		if main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:delItem(data.FItemIdent)
		end

		self.addItem(self, target, data)
	end

	return 
end
horseSoulComposition.getBackItem = function (self, item)
	local data = item.data

	if not data then
		return 
	end

	self.rebackBag(self, data)

	return 
end
horseSoulComposition.duraChange = function (self, makeindex)
	local data = g_data.bag:gethorseSoulPanel(makeindex)

	for k, v in pairs(self.items) do
		if makeindex == v.data.FItemIdent then
			v.data = data

			self.rebackBag(self, data)

			return 
		end
	end

	return 
end
horseSoulComposition.uptItem = function (self, makeIndex)
	local item = g_data.bag:gethorseSoulPanel(makeIndex)

	if not item then
		return 
	end

	for i, v in pairs(self.items) do
		if v and v.data.FItemIdent == makeIndex then
			v.data = item

			break
		end
	end

	return 
end
horseSoulComposition.delItem = function (self, itemIndex)
	for i, v in pairs(self.items) do
		if v and v.data.FItemIdent == itemIndex then
			v.removeSelf(v)

			self.items[i] = nil
			g_data.bag.horseSoulPanel[i] = nil

			break
		end
	end

	return 
end
horseSoulComposition.requestCompose = function (self)
	local stoneName = self.selStoneLevel .. "级" .. self.selStoneType
	local itemIdx = def.items.getItemIdByName(stoneName)
	local rsb = DefaultClientMessage(CM_MonSoulStoneCompose)
	rsb.FTargIndex = itemIdx

	for k, v in pairs(self.items) do
		rsb.FMaterialIdentArray[#rsb.FMaterialIdentArray + 1] = v.data.FItemIdent
	end

	MirTcpClient:getInstance():postRsb(rsb)
	main_scene.ui.waiting:show(10, "CM_MonSoulStoneCompose")

	return 
end
horseSoulComposition.onSM_MonSoulStoneCompose = function (self, result)
	main_scene.ui.waiting:close("CM_MonSoulStoneCompose")

	if not result then
		return 
	end

	if result.FBackValue ~= 0 then
		return 
	end

	local monSoulIndex = result.FTargIndex

	self.showResult(self)

	return 
end

return horseSoulComposition
