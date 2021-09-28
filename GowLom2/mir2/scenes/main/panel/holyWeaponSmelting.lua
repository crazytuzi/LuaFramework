local holyWeaponSmelting = class("holyWeaponSmelting", import(".panelBase"))
local item = import("..common.item")
local itemInfo = import("..common.itemInfo")
local tipStr1 = "111111111111"
local kt_weapon = {
	[0] = "开天",
	"镇天",
	"玄天"
}
local holy_weapon = {
	[0] = "王者之刃",
	"王者之杖",
	"王者之剑"
}
local DIAMOND_COUNT = 25888
holyWeaponSmelting.ctor = function (self, params)
	self.super.ctor(self)
	self.setMoveable(self, true)

	self.type = params.type

	return 
end
holyWeaponSmelting.onEnter = function (self)
	self.initPanelUI(self, {
		bg = "pic/panels/fusion/bg1.png",
		size = cc.size(375, 454),
		title = {
			str = "锻造王者武器",
			pos = cc.p(187.5, 436)
		}
	})
	self.pos(self, 10, display.height - 81):anchor(0, 1)
	self.showBag(self)
	self.bindNetEvent(self, SM_ComboKingWeapon, self.onSM_ComboKingWeapon)
	self.setupUI(self)

	return 
end
holyWeaponSmelting.setupUI = function (self)
	local content = self.bg
	local center = display.newSprite(res.gettex2("pic/panels/fusion/bg.png")):add2(content):pos(content.getw(content)/2, 12):anchor(0.5, 0)
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
			x = 94,
			y = 344
		},
		{
			x = 284,
			y = 344
		},
		{
			x = 94,
			y = 146
		},
		{
			x = 284,
			y = 146
		},
		{
			x = 186,
			y = 248
		}
	}
	local floatLabel = {
		"cyss",
		"cyss",
		"cyss",
		"diamond",
		"cloth"
	}

	res.get2("pic/panels/fusion/equip3.png"):pos(boxPos[5].x, boxPos[5].y):add2(content, 2)

	for i = 1, 5, 1 do
		self.boxs[i] = res.get2("pic/panels/fusion/" .. files[i] .. ".png"):pos(boxPos[i].x, boxPos[i].y):add2(content, 2)
	end

	local btnPut = an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		self:onOnekeyClick()

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"一键放入",
			16,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).pos(slot8, 75, 42):addto(content)
	local btnMerge = an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		self:onMergeClick()

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"开始合成",
			16,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).pos(slot9, 195, 42):addto(content)
	local btnOut = an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		self:onBackClick()

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"一键卸下",
			16,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).pos(slot10, 315, 42):addto(content)

	display.newSprite(res.gettex2("pic/panels/fusion/equip3.png")):add2(content):pos(self.bg:getw()/2, 250):anchor(0.5, 0.5)
	display.newSprite(res.gettex2("pic/panels/bag/itembg.png")):add2(content):pos(self.bg:getw()/2, 250):anchor(0.5, 0.5)

	local lblTip = an.newLabelM(320, 18, 1, {
		manual = false,
		center = true
	}):add2(self.bg):anchor(0.5, 0):pos(center.getw(center)*0.5 + 10, 66)

	lblTip.nextLine(lblTip)
	lblTip.addLabel(lblTip, "材料还需：金刚石*25888，将直接从背包中扣除", cc.c3b(220, 210, 190))

	local itemIdx = def.items.getItemIdByName(holy_weapon[self.type])
	local itemData = def.items.getStdItemById(itemIdx)

	item.new(itemData, self, {
		idx = 5,
		donotMove = true
	}):add2(self.bg, 3):pos(self.idx2pos(self, 5))

	self.items = {}

	self.addNodeEventListener(self, cc.NODE_EVENT, function (event)
		if event.name == "cleanup" then
			self:itemsBack2bag()
		end

		return 
	end)

	return 
end
holyWeaponSmelting.onCloseWindow = function (self)
	main_scene.ui:hidePanel("bag")

	return self.super.onCloseWindow(self)
end
holyWeaponSmelting.putItem = function (self, item, x, y)
	local form = item.formPanel.__cname
	local target = nil

	for i = 1, 5, 1 do
		local tmpX, tmpY = self.idx2pos(self, i)

		if (tmpX - x)*(tmpX - x) < 1600 and (tmpY - y)*(tmpY - y) < 1600 then
			target = i
		end
	end

	if not target then
		return 
	end

	if form == "bag" and g_data.client:checkLastTime("strengthen", 2) then
		local data = item.data

		self.getItemFromBg(self, data, target)
	end

	return 
end
holyWeaponSmelting.getItemFromBg = function (self, data, pos)
	local tmpItem = self.items[pos]

	g_data.bag:delItem(data.FItemIdent)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:delItem(data.FItemIdent)
	end

	g_data.client:setLastTime("strengthen", true)
	self.addItem(self, pos, data)

	return 
end
holyWeaponSmelting.addItem = function (self, idx, data)
	sound.play("item", data)

	if 1 <= idx and idx <= 4 and not self.canPutItem(self, idx, data) then
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
	}):addto(self.bg, 3):pos(self.idx2pos(self, idx))
	self.items[idx].isItems = true
	g_data.bag.strengthen[idx] = data

	return 
end
holyWeaponSmelting.getBackItem = function (self, item)
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
			g_data.bag.strengthen[i] = nil

			break
		end
	end

	return 
end
holyWeaponSmelting.idx2pos = function (self, idx)
	local boxPos = {
		{
			x = 94,
			y = 344
		},
		{
			x = 284,
			y = 344
		},
		{
			x = 94,
			y = 146
		},
		{
			x = 284,
			y = 146
		},
		{
			x = 186,
			y = 248
		}
	}

	return boxPos[idx].x, boxPos[idx].y
end
holyWeaponSmelting.canPutItem = function (self, idx, data)
	local dstItem = self.items[idx]

	if self.isTulong(self, data) then
		if dstItem and self.isTulong(self, dstItem.data) then
			return true
		end

		local count = 0

		for i, v in pairs(self.items) do
			if self.isTulong(self, v.data) then
				count = count + 1
			end
		end

		if count == 0 then
			return true
		else
			main_scene.ui:tip("已包含一把屠龙级武器了", 6)

			return false
		end
	end

	if self.isKaitian(self, data) then
		local kt = {}
		local count = 0

		for i, v in pairs(self.items) do
			if self.isKaitian(self, v.data) then
				kt[i] = v.data
				count = count + 1
			end
		end

		if kt[idx] == nil and 2 <= count then
			main_scene.ui:tip("已包含两把开天级武器了", 6)

			return false
		end

		local oldData = kt[idx]
		kt[idx] = data
		local jobNeed = kt_weapon[self.type]
		local ok = 0

		for i, v in pairs(kt) do
			if v.getVar(v, "name") == jobNeed then
				ok = ok + 1
			end
		end

		if 1 <= ok then
			return true
		else
			main_scene.ui:tip("请放入至少一把" .. jobNeed, 6)

			return false
		end
	end

	if data.getVar(data, "name") == "王者精华" then
		if data.FDura < 99 then
			main_scene.ui:tip("王者精华不足", 6)
		else
			if dstItem and dstItem.data:getVar("name") == "王者精华" then
				return true
			end

			local count = 0

			for i, v in pairs(self.items) do
				if v.data:getVar("name") == "王者精华" then
					count = count + 1
				end
			end

			if count == 0 then
				return true
			else
				main_scene.ui:tip("已包含王者精华了", 6)

				return false
			end
		end
	end

	return false
end
holyWeaponSmelting.delItem = function (self, itemIndex)
	for i, v in pairs(self.items) do
		if v and v.isItems and v.data.FItemIdent == itemIndex then
			v.removeSelf(v)

			self.items[i] = nil
			g_data.bag.strengthen[i] = nil

			break
		end
	end

	return 
end
holyWeaponSmelting.duraChange = function (self, makeindex)
	local data = g_data.bag:getItemStrengthen(makeindex)

	for k, v in pairs(self.items) do
		if makeindex == v.data.FItemIdent then
			v.data = data

			self.rebackBag(self, data)

			g_data.bag.strengthen[k] = nil

			v.removeSelf(v)

			self.items[k] = nil

			return 
		end
	end

	return 
end
holyWeaponSmelting.isKaitian = function (self, data)
	local jewelry = {
		"开天",
		"镇天",
		"玄天"
	}

	if table.indexof(jewelry, data.getVar(data, "name")) then
		return true
	end

	return false
end
holyWeaponSmelting.isTulong = function (self, data)
	local jewelry = {
		"屠龙",
		"嗜魂法杖",
		"倚天剑"
	}

	if table.indexof(jewelry, data.getVar(data, "name")) then
		return true
	end

	return false
end
holyWeaponSmelting.rebackBag = function (self, data)
	g_data.bag:addItem(data)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:addItem(data.FItemIdent)
	end

	return 
end
holyWeaponSmelting.itemsBack2bag = function (self)
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

	g_data.bag.strengthen = {}

	return 
end
holyWeaponSmelting.showBag = function (self)
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
holyWeaponSmelting.onOnekeyClick = function (self)
	local itemNum = 0

	for k, v in pairs(self.items) do
		itemNum = itemNum + 1
	end

	if itemNum == 4 then
		main_scene.ui:tip("材料种类已放满", 6)

		return 
	end

	self.itemsBack2bag(self)

	local idx = 1
	local jobNeed = kt_weapon[self.type]
	local target = g_data.bag:getItemWithName(jobNeed)

	if target then
		self.getItemFromBg(self, target, idx)
	else
		main_scene.ui:tip("包裹中没有" .. jobNeed, 6)

		return 
	end

	idx = 2
	local target = g_data.bag:getItemWithShortName({
		"开天",
		"镇天",
		"玄天"
	})

	if target then
		self.getItemFromBg(self, target, idx)
	else
		main_scene.ui:tip("包裹中没有\"开天\",\"镇天\",\"玄天\"中的一把", 6)

		return 
	end

	idx = 3
	local target = g_data.bag:getItemWithShortName({
		"屠龙",
		"嗜魂法杖",
		"倚天剑"
	})

	if target then
		self.getItemFromBg(self, target, idx)
	else
		main_scene.ui:tip("包裹中没有\"屠龙\",\"嗜魂法杖\",\"倚天剑\"中的一把", 6)

		return 
	end

	idx = 4
	local target = g_data.bag:getItemWithNameAndDura("王者精华", 99)

	if target then
		self.getItemFromBg(self, target, idx)
	else
		main_scene.ui:tip("王者精华不足", 6)

		return 
	end

	return 
end
holyWeaponSmelting.onMergeClick = function (self)
	local total = g_data.bag:getItemCount("金刚石")
	local totalBind = g_data.bag:getItemCount("绑定金刚石")
	local itemNum = 0

	for k, v in pairs(self.items) do
		itemNum = itemNum + 1
	end

	if total + totalBind < DIAMOND_COUNT or itemNum < 4 then
		main_scene.ui:tip("材料不足", 6)

		return 
	end

	local function isElitesWeapon(data)
		local attributeRefin = data.getVar(data, "AttributeRefin") and tonumber(data.getVar(data, "AttributeRefin"))
		local cor = cc.c3b(0, 176, 240)

		if attributeRefin and 2 <= attributeRefin then
			return true
		end

		local upType = data.getVar(data, "AttributeUpType") or 0
		local upLevel = data.getVar(data, "UpLevel") or 0
		local itemLevel = data.getVar(data, "itemLevel") or 0

		if 0 < upType and 0 < upLevel then
			return true
		end

		return data.isGoodItem(data)
	end

	local hasElitesWeapon = false

	for i, v in pairs(self.items) do
		if slot4(v.data) then
			hasElitesWeapon = true

			break
		end
	end

	if hasElitesWeapon then
		an.newMsgbox("放入的开天/镇天/玄天已经洗练，精炼，修炼过。\n放入的屠龙/嗜魂法杖/倚天剑已经洗练，精炼，修炼过。\n锻造后，武器的洗练属性，精炼属性，修炼属性将会全部消失，确认要锻造吗？", function (isOk)
			if isOk == 1 then
				an.newMsgbox(string.format("开始锻造%s吗？", holy_weapon[self.type]), function (isOk)
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
			center = true,
			hasCancel = true
		})
	else
		an.newMsgbox(string.format("开始锻造%s吗？", holy_weapon[self.type]), function (isOk)
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
holyWeaponSmelting.onBackClick = function (self)
	self.itemsBack2bag(self)

	return 
end
holyWeaponSmelting.requestMake = function (self)
	local rsb = DefaultClientMessage(CM_ComboKingWeapon)
	local jobNeed = kt_weapon[self.type]

	for i, v in pairs(self.items) do
		if v.data:getVar("name") == jobNeed and rsb.FMainWeaponIdent == 0 then
			rsb.FMainWeaponIdent = v.data.FItemIdent
		elseif self.isKaitian(self, v.data) then
			rsb.FKaitianWeaponIdent = v.data.FItemIdent
		elseif self.isTulong(self, v.data) then
			rsb.FTuLongWeaponIdent = v.data.FItemIdent
		else
			rsb.FKingSoulIdent = v.data.FItemIdent
		end
	end

	print("FMainWeaponIdent", rsb.FMainWeaponIdent)
	print("FKaitianWeaponIdent", rsb.FKaitianWeaponIdent)
	print("FTuLongWeaponIdent", rsb.FTuLongWeaponIdent)
	print("FKingSoulIdent", rsb.FKingSoulIdent)
	MirTcpClient:getInstance():postRsb(rsb)
	main_scene.ui.waiting:show(10, "HOLY_WEAPON")

	return 
end
holyWeaponSmelting.onSM_ComboKingWeapon = function (self, result)
	main_scene.ui.waiting:close("HOLY_WEAPON")

	if not result then
		return 
	end

	local tipTxt = {
		[0] = "合成成功",
		"未知错误",
		"金刚石不足",
		nil,
		"武器状态错误",
		"武器状态错误",
		"王者精华不足"
	}

	main_scene.ui:tip(tipTxt[result.Fretcode] or "系统错误，请稍候再试", 6)

	return 
end

return holyWeaponSmelting
