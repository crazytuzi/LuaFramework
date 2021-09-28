local item = import("..common.item")
local bag = class("bag", function ()
	return display.newNode()
end)

table.merge(slot1, {})

bag.resetPanelPosition = function (self, type)
	if type == "left" then
		self.anchor(self, 0, 1):pos(0, display.height)
	elseif type == "right" then
		self.anchor(self, 1, 1):pos(display.width - 50, display.height - 50)
	elseif type == "stall" then
		self.anchor(self, 0, 0.5):pos(display.cx - 50, display.cy + 50)
	elseif type == "ybdeal" then
		self.anchor(self, 0, 0.5):pos(display.cx + 65, display.cy)
	elseif type == "storage" then
		self.anchor(self, 0, 1):pos(display.cx + 15, display.height - 50)
	end

	if self.setFocus then
		self.setFocus(self)
	end

	return self
end
bag.ctor = function (self, flag)
	self._supportMove = true

	self.setNodeEventEnabled(self, true)

	local bg = res.get2("pic/panels/bag/newbg.png"):anchor(0, 0):addto(self)
	self.bg = bg

	an.newLabel("背包", 22, 0, {
		color = def.colors.Cd2b19c
	}):anchor(0.5, 0.5):pos(bg.getw(bg)/2, bg.geth(bg) - 28):addto(bg)
	self.size(self, cc.size(bg.getContentSize(bg).width, bg.getContentSize(bg).height)):resetPanelPosition("left")

	if main_scene.ui.panels.heroBag then
		main_scene.ui.panels.heroBag:resetPanelPosition("right")
	end

	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot3, 1, 1):pos(self.getw(self) - 14, self.geth(self) - 14):addto(bg):setName("bag_close")
	res.get2("pic/panels/bag/gold_bg.png"):addTo(bg):pos(26, 40):anchor(0, 0.5):scale(0.8)

	local id = def.items.getItemIdByName("金币1")
	local gold = def.items.getStdItemById(id)

	item.new(gold, self, {
		isGold = true,
		tex = res.gettex2("pic/panels/bag/gold.png")
	}):addto(bg):pos(51, 40)

	self.gold = an.newLabel(change2GoldStyle(g_data.player.gold), 20, 0, {
		color = cc.c3b(250, 178, 100)
	}):pos(78, 28):addto(bg)

	g_data.eventDispatcher:addListener("MONEY_UPDATE", self, self.uptGold)
	display.newNode():size(451, 342):pos(24, 68):add2(bg):enableClick(function ()
		return 
	end)

	for i = 1, g_data.bag.max, 1 do
		res.get2("pic/panels/bag/itembg.png").anchor(slot9, 0.5, 0.5):addTo(bg):pos(self.idx2pos(self, i))
	end

	self.items = {}

	self.reload(self, flag)
	an.newBtn(res.gettex2("pic/common/btn70.png"), function ()
		sound.playSound("103")
		self:closeOperatePanel()
		self:showFunctionPanel(flag)

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn71.png"),
		label = {
			"功能",
			20,
			0,
			{
				color = cc.c3b(240, 200, 150)
			}
		}
	}).pos(slot5, 445, 40):add2(bg)
	an.newBtn(res.gettex2("pic/common/btn70.png"), function ()
		sound.playSound("103")

		if main_scene.ui.panels.materialBag then
			main_scene.ui.panels.materialBag:hidePanel()
		elseif g_data.player.ability.FLevel < 44 then
			main_scene.ui:tip("44级开放材料背包功能")
		else
			local rsb = DefaultClientMessage(CM_ItemListMaterStorage)
			rsb.FNpcId = 0

			MirTcpClient:getInstance():postRsb(rsb)
		end

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn71.png"),
		label = {
			"材料",
			20,
			0,
			{
				color = cc.c3b(240, 200, 150)
			}
		}
	}).pos(slot5, 370, 40):add2(bg)
	g_data.eventDispatcher:addListener("BAG_REFRESH", self, self.reload)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_ItemListMaterStorage, self, self.onSM_ItemListMaterStorage)

	return 
end
bag.onCleanup = function (self)
	if main_scene.ui.panels.heroBag then
		main_scene.ui.panels.heroBag:resetPanelPosition("left")
	end

	return 
end
bag.reload = function (self, flag)
	local it = self.items

	for k, v in pairs(self.items) do
		v.removeSelf(v)
	end

	self.items = {}

	if flag ~= 1 then
		for i = 1, g_data.bag.max, 1 do
			local v = g_data.bag.items[i]

			if v then
				local name = v.getVar(v, "name")
				self.items[i] = item.new(v, self, {
					idx = i
				}):addto(self):pos(self.idx2pos(self, i))

				self.items[i].sprite:setName("bag_" .. name)

				self.items[i].owner = "bag"
			end
		end
	else
		for i = 1, g_data.bag.max, 1 do
			local v = g_data.bag.items[i]

			if v then
				print("#######################", json.encode(v), v._item.stdMode)

				if v._item.stdMode and 10 < v._item.stdMode and v._item.stdMode < 30 then
					local name = v.getVar(v, "name")
					local newindex = #self.items + 1
					self.items[newindex] = item.new(v, self, {
						idx = newindex
					}):addto(self):pos(self.idx2pos(self, newindex))

					self.items[newindex].sprite:setName("bag_" .. name)

					self.items[newindex].owner = "bag"
				end
			end
		end
	end

	return 
end
bag.uptGold = function (self, gold)
	self.gold:setString(change2GoldStyle(g_data.player.gold))

	return 
end
bag.idx2pos = function (self, idx)
	idx = idx - 1
	local h = idx%8
	local v = math.modf(idx/8)

	return h*56 + 53, v*56 - 379
end
bag.pos2idx = function (self, x, y)
	local h = math.floor((x - 53 + 28)/56)
	local v = math.floor((y - 379 + 28)/56)

	if 0 <= v and v < 6 and 0 <= h and h < 8 then
		return v*8 + h + 1
	end

	return -1
end
bag.getItem = function (self, makeIndex)
	for k, v in pairs(self.items) do
		if v.data.FItemIdent == tonumber(makeIndex) then
			return v
		end
	end

	return 
end
bag.addItem = function (self, makeIndex)
	local i, v = g_data.bag:getItem(makeIndex)

	if v then
		if self.items[i] then
			self.items[i]:removeSelf()
		end

		self.items[i] = item.new(v, self, {
			idx = i
		}):addto(self):pos(self.idx2pos(self, i))

		self.items[i].sprite:setName("bag_" .. v.getVar(v, "name"))

		self.items[i].owner = "bag"
	end

	return 
end
bag.delItem = function (self, makeIndex)
	for k, v in pairs(self.items) do
		if v.data.FItemIdent == tonumber(makeIndex) then
			if self.operateItem == v then
				self.closeOperatePanel(self)
			end

			self.items[k]:removeSelf()

			self.items[k] = nil

			break
		end
	end

	return 
end
bag.uptItem = function (self, makeIndex)
	local i, v = g_data.bag:getItem(makeIndex)

	if v and self.items[i] then
		self.items[i].data = v
	end

	return 
end
bag.putItem = function (self, item, x, y)
	local form = item.formPanel.__cname

	if form == "equip" or form == "rankEquip" or (form == "horseUpgrade" and item.data:getVar("stdMode") == 37) then
		item.takeOff(item)
	elseif form == "bag" then
		if self.operatePanel and cc.rectContainsPoint(self.operatePanel:getBoundingBox(), cc.p(x, y)) then
			self.operateItemEnter(self, item)

			return true
		end

		local putIdx = self.pos2idx(self, x, y)

		if putIdx == -1 then
			return 
		end

		local srcIdx = item.params.idx

		if srcIdx ~= putIdx and g_data.bag:isAallCanPileUp(srcIdx, putIdx) then
			local item1 = self.items[putIdx].data
			local makeIndex2 = self.items[srcIdx].data.FItemIdent

			if item1.isNeedResetPos(item1, self.items[srcIdx].data) then
				self.items[putIdx]:pos(self.idx2pos(self, putIdx))
				self.items[srcIdx]:pos(self.idx2pos(self, srcIdx))
			end

			local rsb = DefaultClientMessage(CM_ITEM_PILEUP)
			rsb.FitemIdent1 = item1.FItemIdent
			rsb.FitemIdent2 = makeIndex2

			MirTcpClient:getInstance():postRsb(rsb)
			g_data.player:setIsinPileUping(true)
		else
			if self.operateItem and self.operateItem.params.idx == srcIdx then
				self.operateItem = nil

				if (self.operatePanel.type == "修理" or self.operatePanel.type == "特殊修理") and self.operatePanel.price then
					self.operatePanel.price:removeSelf()

					self.operatePanel.price = nil
				end
			end

			if item.params.idx == putIdx then
				item.pos(item, self.idx2pos(self, putIdx))
			else
				item.params.idx = putIdx

				item.pos(item, self.idx2pos(self, putIdx))

				local target = self.items[putIdx]

				if target then
					target.params.idx = srcIdx

					target.pos(target, self.idx2pos(self, srcIdx))
				end

				self.items[putIdx] = item
				self.items[srcIdx] = target

				g_data.bag:changePos(srcIdx, putIdx)
			end
		end

		return true
	elseif form == "npc" then
		item.formPanel:delSellItem()
	elseif form == "deal" then
		an.newMsgbox("交易的物品不可以取回，要取回物品请取消再重新交易！！！")
	elseif form == "storage" or form == "heroBag" then
		item.formPanel:getBackItem(item)
	elseif form == "materialBag" then
		item.formPanel:getBackItem(item)

		return true
	elseif form == "stall" then
		item.formPanel:getBackItem(item)
	elseif form == "ybdeal" then
		item.formPanel:getBackItem(item)
	elseif form == "fusion" then
		item.formPanel:getBackItem(item)
	elseif form == "strengthen" then
		item.formPanel:getBackItem(item)
	elseif form == "upgradeWeapon" then
		item.formPanel:getBackItem(item)
	elseif form == "milRankComposition" then
		item.formPanel:getBackItem(item)
	elseif form == "horseSoulComposition" then
		item.formPanel:getBackItem(item)
	elseif form == "necklaceIdent" then
		item.formPanel:resetVal()
		item.formPanel:getBackItem(item)
	elseif form == "clothComposition" then
		item.formPanel:getBackItem(item)
	elseif form == "jewelryComposition" then
		item.formPanel:getBackItem(item)
	elseif form == "f2fDeal" then
		item.formPanel:getBackItem(item)
	elseif form == "RecyclingItems" then
		item.formPanel:delItem(item)
	elseif form == "holyWeaponSmelting" then
		item.formPanel:getBackItem(item)
	end

	return 
end
bag.useItem = function (self, makeIndex)
	local i, v = g_data.bag:getItem(makeIndex)

	if v and self.items[i] then
		self.items[i]:use()
	end

	return 
end
bag.useItemByName = function (self, name)
	for k, v in pairs(self.items) do
		if name == v.data._item.name then
			v.use(v)

			break
		end
	end

	return 
end
bag.duraChange = function (self, makeindex)
	for k, v in pairs(self.items) do
		if makeindex == v.data.FItemIdent then
			v.duraChange(v)

			return 
		end
	end

	return 
end
bag.setScaleMul = function (self, num)
	return 
end
bag.showFunctionPanel = function (self, flag)
	if not self.functionPanel then
		self.functionPanel = display.newScale9Sprite(res.getframe2("pic/common/black_3.png"), 240, 70, cc.size(230, 200)):anchor(0, 0):addTo(self, 1000):enableClick(function ()
			return 
		end)
		local btnList = {
			"仓库",
			"信用验证",
			"回收商人",
			"飞鞋"
		}

		for k, v in ipairs(slot2) do
			an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
				sound.playSound("103")
				self.functionPanel:removeSelf()

				self.functionPanel = nil

				self:operateForItem(v)

				return 
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				label = {
					v,
					20,
					0,
					{
						color = cc.c3b(240, 200, 150)
					}
				}
			}).pos(slot8, k%2*108 - 170, math.floor((k - 1)/2)*50 - 165):addTo(self.functionPanel)
		end
	elseif self.functionPanel then
		self.functionPanel:removeSelf()

		self.functionPanel = nil
	end

	return 
end
bag.operateForItem = function (self, type)
	if type == "整理" then
		if g_data.client:checkLastTime("queryBag", 1) then
			g_data.client:setLastTime("queryBag", true)

			local rsb = DefaultClientMessage(CM_QUERYBAGITEMS)

			MirTcpClient:getInstance():postRsb(rsb)
		else
			main_scene.ui:tip("你整理的太快了。")
		end
	elseif type == "飞鞋" then
		main_scene.ui:togglePanel("flyshoe")
	elseif type == "仓库" then
		if not main_scene.ui.panels.storage then
			local rsb = DefaultClientMessage(CM_StroeItemList)
			rsb.FNpcId = 0
			rsb.FiStoreType = 0

			MirTcpClient:getInstance():postRsb(rsb)
		end
	elseif type == "药品仓库" then
		if g_data.player:isAuthen() then
			local rsb = DefaultClientMessage(CM_StroeItemList)
			rsb.FNpcId = 0
			rsb.FiStoreType = 2

			MirTcpClient:getInstance():postRsb(rsb)
		end
	elseif type == "信用验证" then
		local rsb = DefaultClientMessage(CM_BEGIN_CREDITAUTHEN)

		MirTcpClient:getInstance():postRsb(rsb)
	elseif type == "销毁" then
		self.showOperatePanel(self, type, type, "M")
	elseif type == "修理" then
		self.showOperatePanel(self, type, "修理:", "L")
	elseif type == "特殊修理" then
		self.showOperatePanel(self, type, "特修:", "L")
	elseif type == "一键特修" then
		local texts = {
			{
				"确认花费",
				cc.c3b(255, 255, 255)
			},
			{
				"1元宝",
				cc.c3b(255, 0, 0)
			},
			{
				"特殊修理",
				cc.c3b(255, 255, 255)
			},
			{
				"\n身上穿戴的所有装备",
				cc.c3b(255, 255, 255)
			},
			{
				"\n（请确认是否已穿戴需要特殊修理的装备）",
				cc.c3b(255, 0, 0)
			}
		}

		an.newMsgbox(texts, function (isOk)
			if isOk == 1 and g_data.client:checkLastTime("ItemRepair_Bag", 0.8) then
				g_data.client:setLastTime("ItemRepair_Bag", true)

				local rsb = DefaultClientMessage(CM_USERREPAIRITEM)
				rsb.Flag = 0
				rsb.FRepairMode = 7

				MirTcpClient:getInstance():postRsb(rsb)
			end

			return 
		end, {
			fontSize = 20,
			disableScroll = true,
			center = true,
			hasCancel = true
		})
	elseif type == "回收商人" then
		if main_scene.ground.player == nil or main_scene.ground.map == nil then
			return 
		end

		print("main_scene.ground.map.x = ", main_scene.ground.player.x)
		print("main_scene.ground.map.x = ", main_scene.ground.player.y)
		print("main_scene.ground.map.mapid = ", main_scene.ground.map.mapid)

		if g_data.map.isInSafeZone(slot2, main_scene.ground.map.mapid, main_scene.ground.player.x, main_scene.ground.player.y) then
			main_scene.ui:togglePanel("RecyclingItems")
		else
			local tipstr = "在安全区才能使用回收商人功能"

			main_scene.ui:tip(tipstr, 6)
		end
	end

	return 
end
bag.showOperatePanel = function (self, type, title, alignS)
	self.operatePanel = res.get2("pic/panels/npc/sellbg.png"):pos(self.bg:getw() - 10, 0):anchor(0, 0):addTo(self.bg)
	self.operatePanel.type = type

	self.addTouchFrame(self, self.operatePanel:getBoundingBox(), "operatePanel")

	local operateP = self.operatePanel

	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:closeOperatePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot5, 1, 1):pos(operateP.getw(operateP) + 10, operateP.geth(operateP) - 4):addto(operateP):setName("OperateClose")

	if title then
		local pos, align = nil

		if alignS == "L" then
			align = {
				0,
				0.5
			}
			pos = {
				12,
				self.operatePanel:geth() - 18
			}
		else
			align = {
				0.5,
				0.5
			}
			pos = {
				operateP.getw(operateP)*0.5 - 5,
				operateP.geth(operateP) - 18
			}
		end

		an.newLabel(title, 20, 1, {
			color = cc.c3b(240, 200, 150)
		}):anchor(align[1], align[2]):add2(operateP):pos(pos[1], pos[2])
	end

	an.newBtn(res.gettex2("pic/panels/npc/sure0.png"), function ()
		sound.playSound("103")

		if self.operateItem then
			self:operateItemCallBack(self.operateItem, type)
		end

		return 
	end, {
		pressImage = res.gettex2("pic/panels/npc/sure1.png")
	}).anchor(slot5, 1, 0):pos(operateP.getw(operateP) - 4, 4):addto(operateP)

	return 
end
bag.operateItemCallBack = function (self, item, type)
	if type == "销毁" then
		local itemConfig = def.items.getItemsDiuqi(item.data:getVar("name")) or {
			canNotDestroy = 1
		}

		if itemConfig.canNotDestroy == 1 then
			main_scene.ui:tip("该物品无法销毁", 6)
			self.operateItemGoOut(self)

			return 
		end

		local function destroy()
			local rsb = DefaultClientMessage(CM_ITEM_Destroy)
			rsb.FItemIndex = item.data.FItemIdent

			MirTcpClient:getInstance():postRsb(rsb)
			self:operateItemGoOut()

			return 
		end

		if itemConfig.destroyConfirm == 1 or item.data.isGoodItem(slot5) then
			local texts = {
				{
					"确认销毁" .. item.data:getVar("name"),
					cc.c3b(255, 255, 255)
				},
				{
					"\n销毁物品后该物品将直接消失",
					cc.c3b(255, 0, 0)
				}
			}

			an.newMsgbox(texts, function (isOk)
				if isOk == 1 then
					destroy()
				end

				return 
			end, {
				fontSize = 20,
				disableScroll = true,
				center = true,
				hasCancel = true
			})
		else
			slot4()
		end

		return 
	end

	if type == "修理" then
		local rsb = DefaultClientMessage(CM_USERREPAIRITEM)
		rsb.Flag = 0
		rsb.FRepairMode = 4
		rsb.FItemIdent = item.data.FItemIdent

		MirTcpClient:getInstance():postRsb(rsb)
		self.operateItemGoOut(self)
	elseif type == "特殊修理" then
		local rsb = DefaultClientMessage(CM_USERREPAIRITEM)
		rsb.Flag = 0
		rsb.FRepairMode = 5
		rsb.FItemIdent = item.data.FItemIdent

		MirTcpClient:getInstance():postRsb(rsb)
		self.operateItemGoOut(self)
	end
end
bag.operateItemGoOut = function (self, notResetPos)
	if self.operateItem then
		if not notResetPos then
			local srcIdx = self.operateItem.params.idx

			self.operateItem:pos(self.idx2pos(self, srcIdx))
		end

		self.operateItem = nil

		if (self.operatePanel.type == "修理" or self.operatePanel.type == "特殊修理") and self.operatePanel.price then
			self.operatePanel.price:removeSelf()

			self.operatePanel.price = nil
		end
	end

	return 
end
bag.operateItemEnter = function (self, item)
	local operateP = self.operatePanel

	self.operateItemGoOut(self)

	self.operateItem = item

	item.pos(item, operateP.getPositionX(operateP) + 81, operateP.getPositionY(operateP) + 96)

	if self.operatePanel.type == "修理" then
		local rsb = DefaultClientMessage(CM_USERREPAIRITEM)
		rsb.Flag = 1
		rsb.FRepairMode = 4
		rsb.FItemIdent = item.data.FItemIdent

		MirTcpClient:getInstance():postRsb(rsb)
	elseif self.operatePanel.type == "特殊修理" then
		local rsb = DefaultClientMessage(CM_USERREPAIRITEM)
		rsb.Flag = 1
		rsb.FRepairMode = 5
		rsb.FItemIdent = item.data.FItemIdent

		MirTcpClient:getInstance():postRsb(rsb)
	end

	return 
end
bag.operateItemPrice = function (self, result)
	if not self.operatePanel or not self.operateItem or result.FItemIdent ~= self.operateItem.data.FItemIdent then
		return 
	end

	if result.FRepairMode == 4 and self.operatePanel.type == "修理" then
		self.operatePanel.price = an.newLabel(result.FPrice .. "金币", 20, 1, {
			color = cc.c3b(240, 200, 150)
		}):anchor(0, 0.5):add2(self.operatePanel):pos(62, self.operatePanel:geth() - 18)
	elseif result.FRepairMode == 5 and self.operatePanel.type == "特殊修理" then
		self.operatePanel.price = an.newLabel(result.FPrice .. "金币", 20, 1, {
			color = cc.c3b(240, 200, 150)
		}):anchor(0, 0.5):add2(self.operatePanel):pos(62, self.operatePanel:geth() - 18)
	end

	return 
end
bag.closeOperatePanel = function (self)
	if self.operatePanel then
		self.operateItemGoOut(self)
		self.removeTouchFrame(self, "operatePanel")
		self.operatePanel:removeSelf()

		self.operatePanel = nil
	end

	return 
end
bag.isInOperatePanel = function (self, item)
	if self.operateItem and self.operateItem.params.idx == item.params.idx then
		return true
	end

	return false
end
bag.onExit = function (self)
	g_data.eventDispatcher:removeListener(self)

	return 
end
bag.onSM_ItemListMaterStorage = function (self, result, protoId)
	if not main_scene.ui.panels.materialBag then
		self.resetPanelPosition(self, "left")
		main_scene.ui:showPanel("materialBag", result)
	end

	return 
end

return bag
