local itemInfo = import(".itemInfo")
local item = class("item", function ()
	return display.newNode()
end)
local common = import(".common")

table.merge(slot1, {
	mute = false,
	w = 45,
	h = 45,
	enableDress = false
})

item.ctor = function (self, data, formPanel, params)
	self.data = data
	self.formPanel = formPanel
	self.params = params or {}
	params = params or {}

	if params.fromMdePanel then
		self.formPanel.__cname = "medalEnhanting"
	end

	local form = formPanel.__cname
	local isSetOffset = params.isSetOffset

	if params.tex then
		self.sprite = display.newSprite(params.tex):addto(self)

		if params.tex.isMiz then
			self.sprite:anchor(0.5, 0.5)
		end
	else
		self.sprite = res.get(params.img or "items", self.data:getVar("looks") or 0):addto(self)
	end

	if isSetOffset then
		local info = res.getinfo(params.img or "items", self.data:getVar("looks"))

		if info and info.x and info.y then
			self.sprite:anchor(0, 0):pos(info.x*formPanel._scale, info.y*formPanel._scale):scale(formPanel._scale)
		end

		self.sprite2 = res.get("items", self.data:getVar("looks"), isSetOffset):addto(self):hide()
	else
		display.newNode():size(item.w, item.h):anchor(0.5, 0.5):addto(self)
	end

	if data.isPileUp and data.isPileUp(data) then
		self.dura = an.newLabel("" .. data.FDura, 12, 1, {
			color = cc.c3b(0, 255, 0)
		}):anchor(1, 0):pos(16, -20):add2(self, 1)
	end

	if not params.donotClick then
		if WIN32_OPERATE then
			self.registerMouseEvent(self)
		else
			self.registerTouchEvent(self)
		end
	end

	if params.scroll then
		self.setTouchSwallowEnabled(self, false)
	end

	if self.data:getVar("stdMode") == 37 then
		params.showLevel = true
	end

	if (form == "bag" or form == "storage" or form == "materialBag") and params.showLevel then
		self.addLevelLabel(self)
	end

	return 
end
item.addLevelLabel = function (self)
	if self.levelLabel then
		self.levelLabel:removeSelf()

		self.levelLabel = nil
	end

	local name = self.data:getVar("name")
	local strs = string.split(name, "级")

	if #strs == 2 then
		self.levelLabel = an.newLabel("+" .. strs[1], 16, 1, {
			color = def.colors.Cf0c896
		}):anchor(1, 0):pos(22, 7):add2(self, 1)
	end

	return 
end
item.enableDefaultDress = function (self)
	self.enableDress = true

	return 
end
item.registerTouchEvent = function (self)
	self.setTouchEnabled(self, true)
	self.addNodeEventListener(self, cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			return self:onTouchBegan(event)
		elseif event.name == "moved" then
			self:onTouchMoved(event)
		elseif event.name == "ended" then
			self:onTouchEnded(event)
		elseif event.name == "exit" then
			self:onExit()
		end

		return 
	end)

	return 
end
item.onTouchBegan = function (self, event)
	if self.handler then
		self.clicked = true

		return false
	end

	self.beganPos = cc.p(self.getPosition(self))
	self.beganTouchPos = cc.p(event.x, event.y)
	self.hasMove = false

	self.setLocalZOrder(self, self.getLocalZOrder(self) + 1)

	return true
end
item.onTouchMoved = function (self, event)
	if not self.params.donotMove and (10 < math.abs(self.beganTouchPos.x - event.x) or 10 < math.abs(self.beganTouchPos.y - event.y)) then
		if not self.hasMove then
			if self.params.isGold then
				sound.playSound(sound.s_money)
			else
				sound.play("item", self.data)
			end
		end

		self.hasMove = true
		local scale = (not self.params.isSetOffset and self.formPanel._scale) or 1

		if self.params.isSetOffset then
			self.sprite:hide()
			self.sprite2:show()

			local p = self.getParent(self):convertToWorldSpace(cc.p(0, 0))

			self.pos(self, (event.x - p.x)/scale, (event.y - p.y)/scale)

			if self.enableDress then
				self.formPanel:showDefaultDress(true)
			end
		else
			self.pos(self, (event.x - self.beganTouchPos.x)/scale + self.beganPos.x, (event.y - self.beganTouchPos.y)/scale + self.beganPos.y)
		end

		if self.levelLabel then
			self.levelLabel:removeSelf()

			self.levelLabel = nil
		end
	end

	return 
end
item.onTouchEnded = function (self, event)
	if self.hasMove then
		local ret = false
		local notShowTipFromMaterialBag = false
		local isInPanel = false
		local form = self.formPanel.__cname
		local pos = cc.p(event.x, event.y)
		local panels = sortNodes(table.values(main_scene.ui.panels))

		if (form == "bag" or form == "storage" or form == "materialBag") and self.params.showLevel then
			self.addLevelLabel(self)
		end

		for i, v in ipairs(panels) do
			if v.checkInPanel(v, pos) then
				if v.putItem and not self.params.isGold then
					local p = v.convertToWorldSpace(v, cc.p(0, 0))
					ret, notShowTipFromMaterialBag = v.putItem(v, self, pos.x - p.x, pos.y - p.y)
				elseif v.putGold and self.params.isGold then
					v.putGold(v, self)
				end

				isInPanel = true

				break
			elseif form == "bag" and self.formPanel.isInOperatePanel and self.formPanel:isInOperatePanel(self) then
				isInPanel = true
				ret = false

				break
			end
		end

		local isInCustom = false

		if not isInPanel then
			local customs = sortNodes(table.values(main_scene.ui.customs))

			for i, v in ipairs(customs) do
				if v.checkInButton(v, pos) then
					isInCustom = true
				end

				if isInCustom then
					if v.checkItemType(v, self.data) then
						local data = self.data
						local owner = self.owner

						if self.customNode and v ~= self.customNode then
							self.customNode:custom_delItem()
						end

						v.setCustomProps(v, data, owner)
					end

					break
				end
			end
		end

		if self.customNode and not isInCustom then
			local customs = sortNodes(table.values(main_scene.ui.customs))

			for i, v in ipairs(customs) do
				if v.btn.item == self then
					v.custom_delItem(v)

					break
				end
			end
		end

		if not isInPanel and not isInCustom and (form == "bag" or form == "heroBag") then
			self.throw(self)
		end

		if self.params and self.params.isSetOffset and self.sprite then
			self.sprite:show()
			self.sprite2:hide()

			if self.enableDress then
				self.formPanel:showDefaultDress(false)
			end
		end

		if not ret and self.beganPos then
			self.pos(self, self.beganPos.x, self.beganPos.y)

			if form == "materialBag" and not notShowTipFromMaterialBag then
				main_scene.ui:tip("请先将材料取出至背包")
			end
		else
			return 
		end
	else
		self.handler = scheduler.performWithDelayGlobal(handler(self, self.click), 0.25)
	end

	self.hasMove = false

	self.setLocalZOrder(self, self.getLocalZOrder(self) - 1)

	return 
end
item.click = function (self)
	if not self.formPanel then
		return 
	end

	local form = self.formPanel.__cname
	local quick = nil

	if main_scene.ui.panels.storage and main_scene.ui.panels.storage.quick then
		quick = true
	end

	if quick and (form == "storage" or form == "bag") then
		if form == "bag" and not self.params.isGold then
			main_scene.ui.panels.storage:putItem(self)
		elseif form == "storage" and main_scene.ui.panels.bag then
			main_scene.ui.panels.bag:putItem(self)
		end
	else
		local isInOperatePanel = false

		if form == "bag" and self.formPanel.isInOperatePanel then
			isInOperatePanel = self.formPanel:isInOperatePanel(self)
		end

		if form == "smelting" and main_scene.ui.panels.smelting and main_scene.ui.panels.smelting.inMelting then
			main_scene.ui.panels.smelting:putItem(self.data)

			return 
		end

		if form == "f2fDeal" then
			slot4 = main_scene.ui.panels.f2fDeal and slot4
		end

		if self.clicked then
			if not self.params.mute then
				sound.play("item", self.data)
			end

			if form == "bag" and not isInOperatePanel and not self.params.isGold then
				self.use(self)
			elseif form == "heroBag" then
				self.use(self)
			elseif form == "equip" or form == "heroEquip" or form == "rankEquip" or (form == "horseUpgrade" and self.data:getVar("stdMode") == 37) then
				self.takeOff(self)
			elseif self.customNode then
				main_scene.ui.console.btnCallbacks:handle("custom", self.customNode)
			end
		elseif not self.params.isGold and self.sprite then
			if not self.params.noItemInfoTips then
				local p = self.sprite:convertToWorldSpace(cc.p(self.sprite:getw()/2, self.sprite:geth()/2))

				itemInfo.show(self.data, p, {
					from = form,
					extend = self.params.extend,
					hidePileUp = isInOperatePanel
				})
			end

			if self.params.clickcb then
				self.params.clickcb(self)
			end
		end
	end

	self.handler = nil
	self.clicked = nil

	return 
end
item.canUseEquip = function (self, item, dataFrom, weight, isPlayer)
	if not item then
		return 
	end

	local function chargeNeed(info, value)
		if value then
			return true
		else
			main_scene.ui:tip(info, 6)
		end

		return 
	end

	local playerData = (isPlayer and g_data.player) or g_data.hero
	local need = item.getVar(slot1, "need")
	local needLevel = item.getVar(item, "needLevel")
	local where = getTakeOnPosition(item.getVar(item, "stdMode"))

	if where then
		local ret = true

		if need == 0 then
			ret = chargeNeed("等级不足", needLevel <= playerData.ability.FLevel)
		elseif need == 1 then
			ret = chargeNeed("攻击不足", needLevel <= g_data.player.ability.FMaxDC)
		elseif need == 2 then
			ret = chargeNeed("魔法不足", needLevel <= g_data.player.ability.FMaxMC)
		elseif need == 3 then
			ret = chargeNeed("道术不足", needLevel <= g_data.player.ability.FMaxSC)
		elseif need == 5 and isPlayer then
			ret = chargeNeed("你的声望不足，不能佩戴", g_data.player.ability3:get("prestige") <= needLevel)
		end

		if not ret then
			return 
		end
	end

	if playerData.ability.FMaxWeapWgt < item.getVar(item, "weight") then
		main_scene.ui:tip("腕力不足", 6)

		return false
	end

	local function memoNeed(memoKey)
		local needMemo = item:getVar("Memo")
		local memeT = common.decodeMemo(needMemo)

		for k, v in pairs(memeT) do
			if k == memoKey and v[1] and v[2] then
				local skillLvlNeed = tonumber(v[2])
				local skillId = tonumber(v[1])
				local skillData = g_data.player:getMagic(skillId)

				if not skillData then
					skillData = def.magic.getMagicConfigByUid(skillId)
					skillData.FMagicName = skillData.name
					skillData.FLevel = 0
				end

				return skillData.FMagicName, skillLvlNeed <= skillData.FLevel
			end
		end

		return 
	end

	if item.getVar(slot1, "stdMode") == 4 then
		local shape = item.getVar(item, "shape") or 0

		if shape ~= playerData.job and shape ~= playerData.job + 10 then
			main_scene.ui:tip("职业不符", 6)

			return false
		end

		local needLevel = math.modf(Word(item.getVar(item, "duraMax")))

		if playerData.ability.FLevel < needLevel then
			main_scene.ui:tip("等级不足", 6)

			return false
		end

		local need = item.getVar(item, "need")

		if need == 10 then
			local name, flag = memoNeed("NeedSkillIdx")

			return chargeNeed(name .. "技能等级不符", flag)
		end
	elseif item.getVar(item, "stdMode") ~= 5 and item.getVar(item, "stdMode") ~= 6 and item.getVar(item, "name") ~= "金条" and weight < item.getVar(item, "weight") and playerData.ability.FMaxWeapWgt - playerData.ability.FCurWeapWgt < item.getVar(item, "weight") - weight then
		main_scene.ui:tip("负重不足", 6)

		return false
	end

	return true
end
item.getItemSourceInfo = function (self)
	if self.formPanel.__cname == "bag" then
		equipData = g_data.equip
		bagData = g_data.bag
		takeonMsg = CM_TAKEONITEM
		eatMsg = CM_EAT
	else
		isPlayer = false
		equipData = g_data.heroEquip
		bagData = g_data.heroBag
		takeonMsg = CM_HERO_TAKEON
		eatMsg = CM_HERO_EAT
	end

	return bagData, equipData, eatMsg, takeonMsg
end
item.use = function (self, equipIdx, type)
	local myPlayer = main_scene.ground.player

	if not myPlayer or myPlayer.die then
		return 
	end

	local bagData, equipData, eatMsg, takeonMsg = nil
	local isPlayer = true

	if self.formPanel.__cname == "bag" then
		equipData = g_data.equip
		bagData = g_data.bag
		takeonMsg = CM_TAKEONITEM
		eatMsg = CM_EAT
	else
		isPlayer = false
		equipData = g_data.heroEquip
		bagData = g_data.heroBag
		takeonMsg = CM_HERO_TAKEON
		eatMsg = CM_HERO_EAT
	end

	local where = getTakeOnPosition(self.data:getVar("stdMode"))

	if where then
		if U_RINGL == where or U_RINGR == where then
			if equipIdx then
				where = equipIdx
			elseif not equipData.items[U_RINGL] then
				where = U_RINGL
			elseif not equipData.items[U_RINGR] then
				where = U_RINGR
			elseif equipData.lastTakeOnRingIsLeft then
				equipData.lastTakeOnRingIsLeft = false
				where = U_RINGR
			else
				equipData.lastTakeOnRingIsLeft = true
				where = U_RINGL
			end
		elseif U_ARMRINGL == where or U_ARMRINGR == where then
			if equipIdx then
				where = equipIdx
			elseif not equipData.items[U_ARMRINGL] then
				where = U_ARMRINGL
			elseif not equipData.items[U_ARMRINGR] then
				where = U_ARMRINGR
			elseif equipData.lastTakeOnBraceletIsLeft then
				equipData.lastTakeOnBraceletIsLeft = false
				where = U_ARMRINGR
			else
				equipData.lastTakeOnBraceletIsLeft = true
				where = U_ARMRINGL
			end
		elseif U_MINGZHONG == where then
			if equipIdx then
				where = equipIdx
			else
				local name = self.data:getVar("name")

				if string.find(name, "命中石") then
					where = U_MINGZHONG
				elseif string.find(name, "物闪石") then
					where = U_WUSHAN
				elseif string.find(name, "魔闪石") then
					where = U_MOSHAN
				elseif string.find(name, "神防石") then
					where = U_SHENFANG
				elseif string.find(name, "神伤石") then
					where = U_SHENSHANG
				end
			end
		elseif equipIdx then
			where = equipIdx
		end

		local weight = (equipData.items[where] and equipData.items[where]:getVar("weight")) or 0

		if self.canUseEquip(self, self.data, bagData, weight, isPlayer) and bagData.use(bagData, "take", self.data.FItemIdent, {
			where = where
		}) then
			local rsb = DefaultClientMessage(CM_TAKEONITEM)
			rsb.FWhere = where
			rsb.Flag = type or rsb.Flag
			rsb.FItemIdent = self.data.FItemIdent

			MirTcpClient:getInstance():postRsb(rsb)

			local cuItem = self.data

			self.formPanel:delItem(self.data.FItemIdent)
		end
	else
		if equipIdx then
			return 
		end

		if not self.canUseEquip(self, self.data, bagData, 0, isPlayer) then
			return 
		end

		local function use()
			if self.data and bagData:use("eat", self.data.FItemIdent) then
				local rsb = DefaultClientMessage(eatMsg)
				rsb.FItemIdent = self.data.FItemIdent
				rsb.FUseType = 0
				rsb.Flag = type or rsb.Flag

				MirTcpClient:getInstance():postRsb(rsb)

				local pile = self.data:isPileUp()
				local multiUse = self.data:getVar("stdMode") == 2

				if not pile and not multiUse then
					local cuItem = self.data

					self.formPanel:delItem(self.data.FItemIdent)
				end
			end

			return 
		end

		if self.data.getVar(slot11, "stdMode") == 4 then
			an.newMsgbox(string.format("[%s] 你想要开始训练吗? ", self.data:getVar("name")), function (isOk)
				if isOk == 1 then
					use()
				end

				return 
			end, {
				center = true,
				hasCancel = true
			}).setName(slot11, "msgBoxLearnSkill")
		elseif self.data:getVar("stdMode") == 47 then
			if self.data:getVar("name") == "传情烟花" then
				local msgbox = nil
				slot12 = an.newMsgbox("请输入传情烟花文字", function (idx)
					if idx == 2 then
						if msgbox.input:getString() == "" then
							return 
						end

						local rsb = DefaultClientMessage(CM_YANHUA_TEXT)
						rsb.FTargetItemIdent = self.data.FItemIdent
						rsb.FTargetMsg = msgbox.input:getString()

						MirTcpClient:getInstance():postRsb(rsb)
					end

					return 
				end, {
					disableScroll = true,
					checkCLen = true,
					input = 12,
					btnTexts = {
						"关闭",
						"确定"
					}
				})
				msgbox = slot12
			elseif self.data:getVar("name") == "金条" then
				an.newMsgbox("确定使用一根金条兑换998000金币吗？\n未验证玩家可携带200万金币。\n已验证玩家可携带5000万金币。", function ()
					if self and self.data and g_data.bag:use("eat", self.data.FItemIdent) then
						local rsb = DefaultClientMessage(eatMsg)
						rsb.FItemIdent = self.data.FItemIdent
						rsb.FUseType = 0

						MirTcpClient:getInstance():postRsb(rsb)
						self.formPanel:delItem(self.data.FItemIdent)
					end

					return 
				end, {
					center = true
				})
			elseif self.data.getVar(slot11, "name") == "金砖" then
				an.newMsgbox("确定使用一块金砖兑换5根金条吗？", function ()
					if g_data.bag:use("eat", self.data.FItemIdent) then
						local rsb = DefaultClientMessage(eatMsg)
						rsb.FItemIdent = self.data.FItemIdent
						rsb.FUseType = 0

						MirTcpClient:getInstance():postRsb(rsb)
						self.formPanel:delItem(self.data.FItemIdent)
					end

					return 
				end, {
					center = true
				})
			elseif self.data.getVar(slot11, "name") == "金箱" then
				an.newMsgbox("确定使用一个金箱兑换1000万金币吗？\n未验证玩家可携带200万金币。\n已验证玩家可携带5000万金币。", function ()
					if g_data.bag:use("eat", self.data.FItemIdent) then
						local rsb = DefaultClientMessage(eatMsg)
						rsb.FItemIdent = self.data.FItemIdent
						rsb.FUseType = 0

						MirTcpClient:getInstance():postRsb(rsb)
						self.formPanel:delItem(self.data.FItemIdent)
					end

					return 
				end, {
					center = true
				})
			end
		elseif self.data.getVar(slot11, "stdMode") == 159 then
			if g_data.bag:use("eat", self.data.FItemIdent) then
				local rsb = DefaultClientMessage(CM_EAT)
				rsb.FItemIdent = self.data.FItemIdent
				rsb.FUseType = 0

				MirTcpClient:getInstance():postRsb(rsb)
			end
		elseif self.data:getVar("stdMode") == 3 or self.data:getVar("stdMode") == 2 then
			local iName = self.data:getVar("name")

			if iName == "回城卷" or iName == "行会回城卷" or iName == "地牢逃脱卷" then
				common.stopAuto()
			end

			if iName == "随机传送卷" or iName == "随机传送石" then
				g_data.useRandomSend = true
			end

			use()
		elseif self.data:getVar("name") == "易名符" then
			local msgbox = nil
			slot12 = an.newMsgbox("  更改角色名", function (idx)
				if idx == 1 then
					local name = msgbox.input:getString()

					if name == "" then
						main_scene.ui.panels.bag:useItemByName("易名符")
					else
						local rsb = DefaultClientMessage(CM_CHG_USERNAME)
						rsb.FNewName = name

						MirTcpClient:getInstance():postRsb(rsb)
					end
				end

				return 
			end, {
				disableScroll = true,
				hasCancel = true,
				btnTexts = {
					"确定",
					"取消"
				}
			})
			msgbox = slot12
			msgbox.input = an.newInput(0, 0, msgbox.bg:getw() - 60, 40, 12, {
				checkCLen = true,
				label = {
					"",
					20,
					1
				},
				bg = {
					tex = res.gettex2("pic/scale/edit.png"),
					offset = {
						-10,
						2
					}
				},
				tip = {
					"点击输入角色名（最多输入6个字）",
					20,
					1,
					{
						color = cc.c3b(128, 128, 128)
					}
				}
			}):add2(msgbox.bg):pos(msgbox.bg:getw()*0.5 + 10, msgbox.bg:geth()*0.5 + 20)
			msgbox.remark = an.newLabelM(msgbox.bg:getw() - 60, 17, 0):add2(msgbox.bg):pos(40, 95):addLabel("注：确认改名后会返回到登录界面才会改名成功", cc.c3b(255, 0, 0))
		else
			use()
		end
	end

	return 
end
item.takeOff = function (self)
	local myPlayer = main_scene.ground.player

	if not myPlayer or myPlayer.die then
		return 
	end

	if g_data.map.state == 2 then
		return 
	end

	if self.formPanel.__cname == "equip" or self.formPanel.__cname == "rankEquip" or (self.formPanel.__cname == "horseUpgrade" and self.data:getVar("stdMode") == 37) then
		if g_data.equip:takeOff(self.data.FItemIdent, {
			where = self.params.idx
		}) then
			local rsb = DefaultClientMessage(CM_TAKEOFFITEM)
			rsb.FWhere = self.params.idx
			rsb.FItemIdent = self.data.FItemIdent

			MirTcpClient:getInstance():postRsb(rsb)
			self.formPanel:delItem(self.data.FItemIdent)
		end
	elseif g_data.heroEquip:takeOff(self.data.FItemIdent, {
		where = self.params.idx
	}) then
		self.formPanel:delItem(self.data.FItemIdent)
	end

	return 
end
item.throw = function (self)
	local myPlayer = main_scene.ground.player

	if not myPlayer or myPlayer.die then
		return 
	end

	if g_data.player:getIsCrossServer() then
		an.newMsgbox("该物品无法丢弃", nil, {
			center = true
		})

		return 
	end

	local function dropItem(cmd, from)
		if not self.data then
			return 
		end

		local rsb = DefaultClientMessage(cmd)
		rsb.FItemIdent = self.data.FItemIdent

		MirTcpClient:getInstance():postRsb(rsb)
		from.throw(from, self.data.FItemIdent)

		local dropItem = self.data

		self.formPanel:delItem(self.data.FItemIdent)
		g_data.eventDispatcher:dispatch("ITEM_DROP", dropItem)

		return 
	end

	if self.formPanel.__cname == "bag" then
		if self.params.isGold then
			local msgbox = nil
			local extStr = (g_data.player.isAuthen(slot4) and "") or "\n未验证角色丢弃金币会销毁金币"
			local fee = (g_data.player.transferFee and g_data.player.transferFee.FDropOffJB_JB) or 0
			local str = {
				{
					"请输入丢的金币数量（税率" .. fee .. "%）",
					cc.c3b(255, 255, 255)
				},
				{
					extStr,
					cc.c3b(255, 0, 0)
				},
				{
					"\n",
					cc.c3b(255, 255, 255)
				},
				{
					"\n",
					cc.c3b(255, 255, 255)
				}
			}
			slot7 = an.newMsgbox(str, function (idx)
				if idx ~= 1 then
					return 
				end

				if msgbox.nameInput:getString() == "" then
					return 
				end

				local num = tonumber(msgbox.nameInput:getString())

				if num and 0 < num then
					if g_data.player.gold < num then
						main_scene.ui:tip("超过最大值", 6)
					end

					local rsb = DefaultClientMessage(CM_DROPGOLD)
					rsb.FGoldID = num

					MirTcpClient:getInstance():postRsb(rsb)
				end

				return 
			end, {
				disableScroll = true,
				center = true,
				btnTexts = {
					"确 定",
					"取 消"
				}
			})
			msgbox = slot7
			msgbox.nameInput = an.newInput(0, 0, msgbox.bg:getw() - 60, 40, 9, {
				checkCLen = true,
				label = {
					"",
					20,
					1
				},
				bg = {
					tex = res.gettex2("pic/scale/edit.png"),
					offset = {
						-10,
						2
					}
				},
				tip = {
					"",
					20,
					1,
					{
						color = cc.c3b(128, 128, 128)
					}
				}
			}):add2(msgbox.bg):pos(msgbox.bg:getw()*0.5 + 10, msgbox.bg:geth()*0.5 - 22)

			return 
		end

		local cfg = def.items.getItemsDiuqi(self.data:getVar("name"))

		if not cfg then
			an.newMsgbox("该物品无法丢弃", nil, {
				center = true
			})

			return 
		end

		local isGood = self.data:isGoodItem()

		if cfg.canNotDrop == 1 then
			an.newMsgbox("该物品无法丢弃", nil, {
				center = true
			})

			return 
		elseif cfg.dropConfirm == 1 or isGood then
			local extStr = (g_data.player:isAuthen() and "") or "\n未验证角色丢弃物品会销毁该物品"
			local str = string.format("确认丢弃%s?", self.data:getVar("name"))
			str = {
				{
					str,
					cc.c3b(255, 255, 255)
				},
				{
					extStr,
					cc.c3b(255, 0, 0)
				}
			}

			an.newMsgbox(str, function (idx)
				if idx ~= 1 then
					return 
				end

				dropItem(CM_DROPITEM, g_data.bag)

				return 
			end, {
				center = true,
				btnTexts = {
					"确 定",
					"取 消"
				}
			})
		else
			slot2(CM_DROPITEM, g_data.bag)
		end
	else
		local cfg = def.items.getItemsDiuqi(self.data:getVar("name"))
		local itemData = def.items.filt[self.data:getVar("name")]

		if not cfg or not itemData then
			an.newMsgbox("该物品无法丢弃", nil, {
				center = true
			})

			return 
		end

		local isGood = (itemData and itemData.isGood == 1) or false

		if cfg.canNotDrop then
			an.newMsgbox("该物品无法丢弃", nil, {
				center = true
			})
		elseif cfg.dropConfirm == 1 or isGood then
			local extStr = (g_data.player:isAuthen() and "") or "\n未验证角色丢弃物品会销毁该物品"
			local str = string.format("确认丢弃%s?%s", self.data:getVar("name"), extStr)

			an.newMsgbox(str, function (idx)
				if idx ~= 1 then
					return 
				end

				dropItem(CM_HERO_DROPITEM, g_data.heroBag)

				return 
			end, {
				center = true,
				btnTexts = {
					"确 定",
					"取 消"
				}
			})
		else
			slot2(CM_HERO_DROPITEM, g_data.heroBag)
		end
	end
end
item.duraChange = function (self)
	if self.data:isPileUp() and self.dura then
		self.dura:setString("" .. self.data.FDura)
	end

	return 
end
item.isChose = nil
item.isShowInfo = nil
item.registerMouseEvent = function (self)
	self.registerScriptHandler(self, function (event)
		if event == "exit" then
			self:onExit()
		end

		return 
	end)

	self.mouseListener = cc.EventListenerMouse.create(slot1)

	self.mouseListener:registerScriptHandler(function (evt)
		if g_data.hotKey.isSettingKey then
			return 
		end

		self:onMouseDown(evt)

		return 
	end, cc.Handler.EVENT_MOUSE_DOWN)
	self.mouseListener.registerScriptHandler(slot1, function (evt)
		if g_data.hotKey.isSettingKey then
			return 
		end

		self:onMouseMoved(evt)

		return 
	end, cc.Handler.EVENT_MOUSE_MOVE)
	self.mouseListener.registerScriptHandler(slot1, function (evt)
		if g_data.hotKey.isSettingKey then
			return 
		end

		self:onMouseUp(evt)

		return 
	end, cc.Handler.EVENT_MOUSE_UP)
	cc.Director.getInstance(slot1):getEventDispatcher():addEventListenerWithFixedPriority(self.mouseListener, 1)

	return 
end
item.onExit = function (self)
	if self.isChose then
		main_scene.ui.isChoseItem = false
	end

	self.removeItemInfo(self)

	if self.mouseListener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.mouseListener)

		self.mouseListener = nil
	end

	return 
end
item.onMouseDown = function (self, evt)
	if evt.getMouseButton(evt) == 1 then
		return 
	end

	if main_scene.ui.isChoseItem and not self.isChose then
		return 
	end

	self.mouseDown = true
	local x = evt.getCursorX(evt)
	local y = evt.getCursorY(evt)

	if self.isInRect(self, cc.p(x, y)) then
		if self.handler then
			scheduler.unscheduleGlobal(self.handler)

			self.handler = nil
			self.clicked = true
			self.isChose = false
			main_scene.ui.isChoseItem = false
		end

		if not self.isChose then
			self.beganPos = cc.p(self.getPosition(self))
			self.beganTouchPos = cc.p(x, y)
			self.hasMove = false

			self.setLocalZOrder(self, self.getLocalZOrder(self) + 1)
		end
	end

	return 
end
item.onMouseMoved = function (self, evt)
	local x = evt.getCursorX(evt)
	local y = evt.getCursorY(evt)

	if self.isChose then
		if not self.beganTouchPos then
			return 
		end

		if 5 < math.abs(self.beganTouchPos.x - x) or 5 < math.abs(self.beganTouchPos.y - y) then
			if self.handler then
				scheduler.unscheduleGlobal(self.handler)

				self.handler = nil
			end

			self.followMouse(self, x, y)
			self.setLocalZOrder(self, main_scene.ui.z.focus + 1)
		end
	elseif self.isInRect(self, cc.p(x, y)) then
		if not self.infoLayer and not self.params.isGold and self.sprite then
			local p = self.sprite:convertToWorldSpace(cc.p(self.sprite:getw()/2, self.sprite:geth()/2))
			self.infoLayer = itemInfo.show(self.data, p, {
				from = form,
				extend = self.params.extend
			})

			if self.infoLayer then
				self.infoLayer:setTouchEnabled(false)
			end

			if self.params.clickcb then
				self.params.clickcb(self)
			end
		end
	else
		self.removeItemInfo(self)
	end

	return 
end
item.onMouseUp = function (self, evt)
	self.removeItemInfo(self)

	local x = evt.getCursorX(evt)
	local y = evt.getCursorY(evt)

	if evt.getMouseButton(evt) == 0 then
		if not self.mouseDown then
			return 
		end

		if self.clicked then
			print("----双击------")

			if self.isInRect(self, cc.p(x, y)) then
				self.mouseDoubleClick(self)

				self.clicked = nil
			end
		elseif not self.isChose then
			if not main_scene.ui.isChoseItem then
				if self.isInRect(self, cc.p(x, y)) then
					if not self.params.donotMove then
						print("----选中------")

						self.isChose = true
						main_scene.ui.isChoseItem = true
						self.initZorder = self.getLocalZOrder(self)

						if self.params.isGold then
							sound.playSound(sound.s_money)
						else
							sound.play("item", self.data)
						end
					end

					self.handler = scheduler.performWithDelayGlobal(function ()
						self.handler = nil

						return 
					end, 0.25)
				end
			else
				self.mouseDown = nil
			end
		else
			print("----放下------")

			self.isChose = false
			main_scene.ui.isChoseItem = false
			self.hasMove = true

			self.setLocalZOrder(slot0, self.initZorder)
			self.onTouchEnded(self, {
				x = x,
				y = y
			})
		end

		self.mouseDown = nil
	elseif self.isChose then
		print("----撤销------")

		self.isChose = false
		main_scene.ui.isChoseItem = false

		self.pos(self, self.beganPos.x, self.beganPos.y)

		if self.params and self.params.isSetOffset and self.sprite then
			self.sprite:show()
			self.sprite2:hide()
		end

		self.setLocalZOrder(self, self.initZorder)
	end

	return 
end
item.mouseDoubleClick = function (self)
	local form = self.formPanel.__cname
	local quick = nil

	if main_scene.ui.panels.storage and main_scene.ui.panels.storage.quick then
		quick = true
	end

	if quick and (form == "storage" or form == "bag") then
		if form == "bag" then
			main_scene.ui.panels.storage:putItem(self)
		else
			main_scene.ui.panels.bag:putItem(self)
		end
	else
		if not self.params.mute then
			sound.play("item", self.data)
		end

		if form == "bag" or form == "heroBag" then
			self.use(self)
		elseif form == "equip" or form == "heroEquip" then
			self.takeOff(self)
		elseif self.customNode then
			main_scene.ui.console.btnCallbacks:handle("custom", self.customNode)
		end
	end

	return 
end
item.followMouse = function (self, x, y)
	local scale = (not self.params.isSetOffset and self.formPanel._scale) or 1

	if self.params.isSetOffset then
		self.sprite:hide()
		self.sprite2:show()

		local p = self.getParent(self):convertToWorldSpace(cc.p(0, 0))

		self.pos(self, (x - p.x)/scale, (y - p.y)/scale)
	else
		self.pos(self, (x - self.beganTouchPos.x)/scale + self.beganPos.x, (y - self.beganTouchPos.y)/scale + self.beganPos.y)
	end

	return 
end
item.removeItemInfo = function (self)
	if self.infoLayer then
		g_data.player.showTips = false

		self.infoLayer:removeSelf()

		self.infoLayer = nil
	end

	return 
end
item.isInRect = function (self, pos)
	local lastZ = -1
	local topForm = nil
	local panels = sortNodes(table.values(main_scene.ui.panels))

	for i, v in ipairs(panels) do
		if v.checkInPanel(v, pos) and lastZ < v.getLocalZOrder(v) then
			lastZ = v.getLocalZOrder(v)
			topForm = v
		end
	end

	local customs = sortNodes(table.values(main_scene.ui.customs))

	for i, v in ipairs(customs) do
		if v.checkInButton(v, pos) and lastZ < 0 then
			lastZ = v.getLocalZOrder(v)
			topForm = v
		end
	end

	local p = self.sprite:convertToWorldSpace(cc.p(0, 0))
	local rect = cc.rect(p.x, p.y, self.sprite:getw(), self.sprite:geth())

	if cc.rectContainsPoint(rect, pos) and topForm and topForm.__cname == self.formPanel.__cname then
		return true
	end

	return false
end

return item
