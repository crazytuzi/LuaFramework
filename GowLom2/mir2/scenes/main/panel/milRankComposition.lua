local CommonItem = import("..common.item")
local CommonItemInfo = import("..common.itemInfo")
local milRankCompMsg = def.milRankCompMsg
local milRankComposition = class("milRankComposition", import(".panelBase"))
milRankComposition.ctor = function (self, type)
	self.super.ctor(self)
	self.setMoveable(self, true)

	self.params = {
		type = type
	}
	self.max = 36
	self.items = {}
	self.milRankComNeed = {}

	return 
end
milRankComposition.onEnter = function (self)
	self.initPanelUI(self, {
		closeOffsetY = -4,
		title = "军衔装备合成",
		bg = "pic/common/tabbg.png",
		titleOffsetY = -4
	})
	self.anchor(self, 0, 1):pos(100, display.height - 80)
	self.showBag(self)
	self.reload(self)
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
	}).add2(slot1, self.bg):pos(70, 40)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		self:startComposite()

		return 
	end, {
		clickSpace = 1,
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"开始合成",
			18,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).add2(slot1, self.bg):pos(170, 40)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		self:oneKeyClear()

		return 
	end, {
		clickSpace = 1,
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"一键卸下",
			18,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).add2(slot1, self.bg):pos(270, 40)

	local texts = {}

	for k, v in ipairs(milRankCompMsg) do
		if v.milkRankName == self.params.type then
			local qstMsgs = string.split(v.msg, "|")

			for _k, _v in ipairs(qstMsgs) do
				local t = {
					_v,
					(_k%2 == 0 and display.COLOR_RED) or display.COLOR_WHITE
				}
				texts[#texts + 1] = t
			end
		end
	end

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
	}).pos(slot2, 340, 40):addto(self.bg)
	self.bindNetEvent(self, SM_MilEquip_SS_Down, self.onSM_MilEquip_SS_Down)
	self.bindNetEvent(self, SM_MilEquip_SS_Down_Query, self.onSM_MilEquip_SS_Down_Query)

	local itemIdx = def.items.getItemIdByName(self.params.type)
	local rsb = DefaultClientMessage(CM_MilEquip_SS_UP_Query)
	rsb.FItem_ID = itemIdx

	MirTcpClient:getInstance():postRsb(rsb)
	main_scene.ui.waiting:show(10, "QueryMilEquip")

	return 
end
milRankComposition.onCloseWindow = function (self)
	self.oneKeyClear(self)

	if main_scene.ui.panels.bag then
		main_scene.ui:togglePanel("bag")
	end

	return self.super.onCloseWindow(self)
end
milRankComposition.showBag = function (self)
	if main_scene.ui.panels then
		if main_scene.ui.panels.bag then
			local w = self.getw(self)

			main_scene.ui.panels.bag:pos(477, display.height - 80):anchor(0, 1)
		else
			main_scene.ui:togglePanel("bag")
			main_scene.ui.panels.bag:pos(477, display.height - 80)
		end
	end

	return 
end
milRankComposition.reload = function (self)
	for k, v in pairs(self.items) do
		v.removeSelf(v)
	end

	self.items = {}

	for i = 1, self.max, 1 do
		res.get2("pic/panels/bag/itembg.png"):addTo(self.bg):pos(self.idx2pos(self, i))
	end

	return 
end
milRankComposition.idx2pos = function (self, idx)
	idx = idx - 1
	local h = idx%6
	local v = math.modf(idx/6)

	return self.getw(self)/2 - 162 - 5 + h*56 + 27, (self.geth(self)/2 + 108 + 5) - v*56 + 27
end
milRankComposition.oneKeyClear = function (self)
	for k, v in pairs(self.items) do
		self.getBackItem(self, v)
	end

	self.items = {}

	return 
end
milRankComposition.getCurNumByName = function (self, name)
	local curNum = 0

	for k, v in pairs(self.items) do
		if v.data:getVar("name") == name then
			if v.data:isPileUp() then
				curNum = curNum + v.data.FDura
			else
				curNum = curNum + 1
			end
		end
	end

	return curNum
end
milRankComposition.startComposite = function (self)
	local function isElitesMilRank(data)
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

	local function isSureComposite()
		local needItemStr = {}

		for k, v in pairs(self.milRankComNeed) do
			local splitName = string.split(k, "&")
			local nameStr = (#splitName == 2 and splitName[1] .. "/" .. splitName[2]) or splitName[1]
			needItemStr[#needItemStr + 1] = nameStr .. "*" .. v
		end

		local needStr = ""

		for k, v in ipairs(needItemStr) do
			needStr = needStr .. v

			if k < #needItemStr then
				needStr = needStr .. "、"
			end
		end

		an.newMsgbox("确认消耗" .. needStr .. "合成" .. self.params.type .. "吗？\n（优先消耗绑定材料）", function (isOk)
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

		return 
	end

	local hasPutFull = true

	for m, n in pairs(self.milRankComNeed) do
		local splitName = string.split(slot7, "&")
		local curNum = (#splitName == 2 and self.getCurNumByName(self, splitName[1]) + self.getCurNumByName(self, splitName[2])) or self.getCurNumByName(self, m)

		if curNum < n then
			hasPutFull = false
		end
	end

	if not hasPutFull then
		main_scene.ui:tip("所需材料不足", nil, def.colors.Ce66946)

		return 
	end

	local hasElitesMilRank = {}

	for i, v in pairs(self.items) do
		if isElitesMilRank(v.data) then
			hasElitesMilRank[#hasElitesMilRank + 1] = v.data:getVar("name")
		end
	end

	if 0 < #hasElitesMilRank then
		local eqName = ""

		for k, v in ipairs(hasElitesMilRank) do
			eqName = eqName .. v

			if k < #hasElitesMilRank then
				eqName = eqName .. "、"
			end
		end

		an.newMsgbox("放入的" .. eqName .. "已经被洗练、精炼或鉴定过。\n合成后，装备的洗练属性、精炼属性、鉴定属性将会全部消失，确认要合成吗？", function (isOk)
			if isOk == 1 then
				isSureComposite()
			end

			return 
		end, {
			fontSize = 20,
			title = "提示",
			center = false,
			hasCancel = true
		})
	else
		slot2()
	end

	return 
end
milRankComposition.oneKeyPut = function (self)
	self.milRankComNeed = self.milRankComNeed or {}
	local nothingPut = true

	local function findIdxAndPut(name)
		local bagItem = g_data.bag:getItemWithName(name)
		local itemIdx = 0

		for i = 1, self.max, 1 do
			if not self.items[i] then
				itemIdx = i

				break
			end
		end

		if bagItem then
			self:getItemFromBg(bagItem, itemIdx)

			return true
		end

		return false
	end

	for k, v in pairs(self.milRankComNeed) do
		local splitName = string.split(slot6, "&")

		for _k, _v in ipairs(splitName) do
			local curAllNum = (#splitName == 2 and self.getCurNumByName(self, splitName[1]) + self.getCurNumByName(self, splitName[2])) or self.getCurNumByName(self, k)
			local curNum = self.getCurNumByName(self, _v)
			local itemIdx = def.items.getItemIdByName(_v)
			local itemData = nil

			if itemIdx then
				itemData = def.items.getStdItemById(itemIdx)
			end

			if (itemData and curNum == 0 and curAllNum < v) or (curAllNum < v and itemData and not itemData.isPileUp(itemData)) then
				if not itemData.isPileUp(itemData) then
					for i = 1, v - curAllNum, 1 do
						if findIdxAndPut(_v) then
							nothingPut = false
						end
					end
				else
					nothingPut = not findIdxAndPut(_v)
				end
			end
		end
	end

	if nothingPut then
		local hasPut = false

		for _k, _v in pairs(self.items) do
			if _v then
				hasPut = true
			end
		end

		if hasPut then
			local hasPutFull = true

			for m, n in pairs(self.milRankComNeed) do
				local splitName = string.split(k, "&")
				local curNum = (#splitName == 2 and self.getCurNumByName(self, splitName[1]) + self.getCurNumByName(self, splitName[2])) or self.getCurNumByName(self, m)

				if curNum < n then
					hasPutFull = false
				end
			end

			if hasPutFull then
				main_scene.ui:tip("所有材料已放入", nil, def.colors.Ce66946)
			else
				main_scene.ui:tip("所需材料不足", nil, def.colors.Ce66946)
			end
		else
			main_scene.ui:tip("所需材料不足", nil, def.colors.Ce66946)
		end
	end

	return 
end
milRankComposition.getItemFromBg = function (self, data, pos)
	if pos == 0 then
		return 
	end

	local canAdd = false

	for k, v in pairs(self.milRankComNeed) do
		local splitName = string.split(k, "&")

		for _k, _v in ipairs(splitName) do
			if data.getVar(data, "name") == _v then
				canAdd = true
			end
		end
	end

	if not canAdd then
		main_scene.ui:tip("请放入正确的材料", nil, def.colors.Ce66946)

		return 
	end

	local tmpItem = self.items[pos]

	g_data.bag:delItem(data.FItemIdent)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:delItem(data.FItemIdent)
	end

	self.addItem(self, pos, data)

	return 
end
milRankComposition.addItem = function (self, idx, data)
	sound.play("item", data)

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

	self.items[idx] = CommonItem.new(data, self, {
		idx = idx
	}):addto(self, 3):pos(self.idx2pos(self, idx))
	self.items[idx].isItems = true
	g_data.bag.milRankComposition[idx] = data

	return 
end
milRankComposition.rebackBag = function (self, data)
	g_data.bag:addItem(data)

	if main_scene.ui.panels.bag then
		main_scene.ui.panels.bag:addItem(data.FItemIdent)
	end

	return 
end
milRankComposition.uptItem = function (self, makeIndex)
	local item = g_data.bag:getmilRankComposition(makeIndex)

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
milRankComposition.delItem = function (self, itemIndex)
	for i, v in pairs(self.items) do
		if v and v.isItems and v.data.FItemIdent == itemIndex then
			v.removeSelf(v)

			self.items[i] = nil
			g_data.bag.milRankComposition[i] = nil

			break
		end
	end

	return 
end
milRankComposition.getBackItem = function (self, item)
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
			g_data.bag.milRankComposition[i] = nil

			break
		end
	end

	return 
end
milRankComposition.putItem = function (self, item, x, y)
	local form = item.formPanel.__cname

	if form == "bag" then
		local curNum = self.getCurNumByName(self, item.data:getVar("name"))
		local needNum = 0

		for k, v in pairs(self.milRankComNeed) do
			if string.find(k, item.data:getVar("name")) then
				needNum = v
			end
		end

		if (0 < curNum and item.data:isPileUp()) or (needNum <= curNum and curNum ~= 0) then
			main_scene.ui:tip(item.data:getVar("name") .. "不可重复放入", nil, def.colors.Ce66946)

			return 
		end
	end

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

	if form == "bag" then
		local data = item.data

		self.getItemFromBg(self, data, target)

		slot7, slot8 = self.idx2pos(self, target)
	elseif form == "milRankComposition" then
		local data = item.data

		self.changeItemPos(self, data, target)
	end

	return 
end
milRankComposition.changeItemPos = function (self, data, pos)
	self.delItem(self, data.FItemIdent)
	self.addItem(self, pos, data)

	return 
end
milRankComposition.duraChange = function (self, makeindex)
	local data = g_data.bag:getmilRankComposition(makeindex)

	for k, v in pairs(self.items) do
		if makeindex == v.data.FItemIdent then
			v.data = data

			self.rebackBag(self, data)

			g_data.bag.milRankComposition[k] = nil

			v.removeSelf(v)

			self.items[k] = nil

			return 
		end
	end

	return 
end
milRankComposition.showResult = function (self)
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
milRankComposition.requestMake = function (self)
	local itemIdx = def.items.getItemIdByName(self.params.type)
	local rsb = DefaultClientMessage(CM_MilEquip_SS_UP)
	rsb.Fitem_ID = itemIdx
	rsb.FitemListStr = ""

	for k, v in pairs(self.items) do
		if v.data:isPileUp() then
			rsb.FitemListStr = rsb.FitemListStr .. v.data.FItemIdent .. ":" .. v.data.FDura .. "|"
		else
			rsb.FitemListStr = rsb.FitemListStr .. v.data.FItemIdent .. ":1" .. "|"
		end
	end

	MirTcpClient:getInstance():postRsb(rsb)
	main_scene.ui.waiting:show(10, "CompMilEquip")

	return 
end
milRankComposition.onSM_MilEquip_SS_Down = function (self, result, protoId)
	main_scene.ui.waiting:close("CompMilEquip")

	if result and result.FmsItemIdent and 0 < result.FmsItemIdent then
		self.oneKeyClear(self)
		self.showResult(self)

		g_data.bag.milRankComposition = {}
	end

	return 
end
milRankComposition.onSM_MilEquip_SS_Down_Query = function (self, result, protoId)
	if result then
		main_scene.ui.waiting:close("QueryMilEquip")

		if result.FmsRequestStr ~= "-1" then
			self.milRankComNeed = {}
			local needs = string.split(result.FmsRequestStr, "|")

			for k, v in ipairs(needs) do
				local needitem = string.split(v, ":")

				if #needitem == 1 and needitem[1] ~= "" then
					self.milRankComNeed[needitem[1]] = 1
				elseif #needitem == 2 then
					self.milRankComNeed[needitem[1]] = tonumber(needitem[2])
				end
			end
		end
	end

	return 
end

return milRankComposition
