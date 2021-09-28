local fashion = class("fashion", import(".panelBase"))
local CommonItem = import("..common.item")
local mapDef = import("..map.def")
local ani = import("..role.ani")
local info = import("..role.info")
local tip_msg = {
	{
		"1. 每获得一件时装，该件时装带来的属性会累加。\n"
	},
	{
		"2. 只有获得的时装才可展示。\n"
	},
	{
		"3. 展示时装后，会替换原先装备的显示。\n"
	},
	{
		"4. 限时时装的有效期结束后，属性会消失，并且不可再展示。\n"
	},
	{
		"5. 如羽翼和时装同时展示，则羽翼的优先级会高于时装，即只展示羽翼。\n"
	}
}
fashion.ctor = function (self, param)
	self.super.ctor(self)
	self.setMoveable(self, true)

	if param and param.mode then
		self.mode = 1
		self.otherSex = param._param.FUserSex%2
		self.otherJob = param._param.FJob
		self.otherId = param._param.FUserId
		self.rolename = param._param.FUserName .. "的"
		self.otherHair = param._param.FUserHair
		self.otherEquip = param._param.FItemList
		self.OtherFList = {}
		self.otherFeature = {}
	end

	self.sex = self.otherSex or g_data.player.sex
	self.job = self.otherJob or g_data.player.job

	return 
end
fashion.bindMsg = function (self)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_ClientQueryFEInfo, self, self.onSM_ClientQueryFEInfo)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_ClientShowFE, self, self.onSM_ClientShowFE)
	MirTcpClient:getInstance():subscribeMemberOnProtocol(SM_ClientUpFELev, self, self.onSM_ClientUpFELev)

	return 
end
local str = {
	{
		"你已展示了羽翼的外显，展示时装后仍然会",
		cc.c3b(255, 255, 255)
	},
	{
		"显示羽翼的外显",
		cc.c3b(255, 0, 0)
	},
	{
		"，你确定展示时装么？",
		cc.c3b(255, 255, 255)
	}
}
fashion.requestShowFashion = function (self, dataIdx, text)
	if 0 < g_data.player.wingInfo.FCurrWingShowId and self.fashionType == def.fashion.clothType and text == "展示时装" then
		an.newMsgbox(str, function (idx)
			if idx == 1 then
				local rsb = DefaultClientMessage(CM_ClientShowFE)
				rsb.FFashionID = dataIdx

				MirTcpClient:getInstance():postRsb(rsb)
				main_scene.ui.waiting:show(3, "CM_ClientShowFE")
			end

			return 
		end, {
			noclose = true,
			title = "提示",
			center = true,
			contentLabelSize = 20,
			btnTexts = {
				"确定",
				"取消"
			}
		})
	else
		local rsb = DefaultClientMessage(CM_ClientShowFE)
		rsb.FFashionID = dataIdx

		MirTcpClient.getInstance(slot4):postRsb(rsb)
		main_scene.ui.waiting:show(3, "CM_ClientShowFE")
	end

	return 
end
fashion.checkItemExist = function (self, itemName)
	local result = false

	for k, v in pairs(g_data.bag.items) do
		if v._item.name == itemName then
			result = true

			break
		end
	end

	return result
end
fashion.onEnter = function (self)
	local tabstr = {}
	local tabcb = {}
	tabstr[#tabstr + 1] = "服\n装"
	tabcb[#tabcb + 1] = self.loadDressPage
	tabstr[#tabstr + 1] = "武\n器"
	tabcb[#tabcb + 1] = self.loadEquipPage
	self.tabCallbacks = tabcb

	self.initPanelUI(self, {
		bg = "pic/common/black_2.png",
		title = (self.rolename or "") .. "时装",
		tab = {
			default = 1,
			strs = tabstr
		}
	})
	self.pos(self, display.cx - 50, display.cy)
	an.newBtn(res.gettex2("pic/common/question.png"), function ()
		sound.playSound("103")
		an.newMsgbox(tip_msg, nil, {
			contentLabelSize = 20,
			title = "提示"
		})

		return 
	end, {
		pressBig = true,
		pressImage = res.gettex2("pic/common/question.png")
	}).pos(slot3, 200, 380):add2(self, 10)
	self.bindMsg(self)

	local rsb = DefaultClientMessage(CM_ClientQueryFEInfo)

	if self.mode then
		rsb.FFEType = 2
		rsb.FPlayerById = self.otherId
	else
		rsb.FFEType = 1
	end

	MirTcpClient:getInstance():postRsb(rsb)

	return 
end
fashion.initShowDress = function (self, heroBg, data)
	local heroJob = self.job
	local heroSex = self.sex
	local heroSp = (heroSex == 0 and "pic/common/man.png") or "pic/common/woman.png"

	display.newSprite(res.gettex2(heroSp)):add2(heroBg):anchor(0, 0):pos(35, 65)

	self.disY = 0
	self._scale = 1.2
	local hairTemp = nil

	if self.otherHair then
		local _, hair = def.role.hair({
			sex = heroSex,
			hair = self.otherHair
		})
		hairTemp = hair
	else
		hairTemp = main_scene.ground.player.hair
	end

	if hairTemp and 0 < hairTemp then
		heroHair = hairTemp + 438

		res.getui(1, heroHair):addto(heroBg, 2):anchor(0.5, 1):pos(91, 242):scale(self._scale)
	end

	equipData = self.otherEquip or g_data.equip.items
	self.items = {}

	local function getClothEffect(idx)
		for k, v in pairs(def.stateEffectCfg) do
			if k == idx then
				return v
			end
		end

		return 
	end

	local function getEffectPos(effectitem)
		local xPos = effectitem.offsetX + 70
		local yPos = effectitem.offsetY + 192

		return xPos, yPos
	end

	for k, v in pairs(slot6) do
		if k == 0 or k == 1 then
			local x, y, z, isSetOffset, attach = self.idx2pos(self, k)
			x = x - 67
			y = y + 4
			self.items[k] = CommonItem.new(v, self, {
				scroll = true,
				donotClick = true,
				img = data.statealtlas,
				isSetOffset = isSetOffset,
				idx = k
			}):addto(heroBg, z):pos(x, y)

			if k == 0 and self.fashionType == def.fashion.weaponType then
				local clothEffect = getClothEffect(v.FIndex)

				if clothEffect then
					local xPos, yPos = getEffectPos(clothEffect)

					m2spr.playAnimation(clothEffect.atlasName, clothEffect.frameBegin, clothEffect.frames, 0.1, true):add2(heroBg, 3):pos(xPos, yPos):anchor(0, 0):setName("effectAni")
				end
			end
		end
	end

	if self.fashionType == def.fashion.clothType then
		local clo_x, clo_y, clo_z, clo_isSetOffset, clo_attach = self.idx2pos(self, 0)
		local defaultDress = res.get(data.statealtlas, data.stateid)
		local info = res.getinfo(data.statealtlas, data.stateid)

		defaultDress.anchor(defaultDress, 0, 0):addto(heroBg, 0):pos((clo_x + self._scale*info.x) - 67, clo_y + self._scale*info.y + 4)
		defaultDress.scale(defaultDress, self._scale)

		local clothEffect = getClothEffect(data.stateeffectid)

		if clothEffect then
			local xPos, yPos = getEffectPos(clothEffect)

			m2spr.playAnimation(clothEffect.atlasName, clothEffect.frameBegin, clothEffect.frames, 0.1, true):add2(heroBg, 3):pos(xPos, yPos)
		end

		if self.items[0] then
			self.items[0]:hide()

			local effectAni = heroBg.getChildByName(heroBg, "effectAni")

			if effectAni then
				effectAni.removeSelf(effectAni)
			end
		end
	end

	if self.fashionType == def.fashion.weaponType then
		local clo_x, clo_y, clo_z, clo_isSetOffset, clo_attach = self.idx2pos(self, 1)
		local weaponFashion = res.get(data.statealtlas, data.stateid)
		local info = res.getinfo(data.statealtlas, data.stateid)

		weaponFashion.anchor(weaponFashion, 0, 0):addto(heroBg, 0)
		weaponFashion.scale(weaponFashion, self._scale)

		if info and info.x and info.y then
			weaponFashion.pos(weaponFashion, (clo_x + info.x) - 66, (clo_y + info.y) - 10)
		else
			weaponFashion.pos(weaponFashion, clo_x - 66, clo_y - 10)
		end

		if self.items[1] then
			self.items[1]:hide()
		end

		if not self.items[0] then
			local sex = (self.sex == 0 and 60) or 80
			local clo_x, clo_y, clo_z, clo_isSetOffset, clo_attach = self.idx2pos(self, 0)
			local defaultDress = res.get("stateitem", sex)
			local info = res.getinfo("stateitem", sex)

			defaultDress.scale(defaultDress, self._scale)
			defaultDress.anchor(defaultDress, 0, 0):addto(heroBg, 0):pos((clo_x + info.x) - 56, (clo_y + info.y) - 25)
		end
	end

	return 
end
fashion.idx2pos = function (self, idx)
	self.itemPosTable = self.itemPosTable or {
		[0] = {
			44,
			240,
			0,
			true,
			130,
			90,
			100,
			160
		},
		{
			42,
			240,
			1,
			true,
			80,
			90,
			45,
			200
		},
		{
			226,
			218,
			2
		},
		{
			226,
			280,
			2
		},
		{
			44,
			242,
			2,
			true,
			160,
			300,
			80,
			60
		},
		{
			50,
			162,
			2
		},
		{
			226,
			162,
			2
		},
		{
			50,
			104,
			2
		},
		{
			226,
			104,
			2
		},
		{
			50,
			44,
			2
		},
		{
			107,
			44,
			2
		},
		{
			165,
			44,
			2
		},
		{
			226,
			44,
			2
		},
		{
			9,
			158,
			2,
			true,
			74,
			140,
			60,
			40,
			attach = {
				-26,
				138,
				2
			}
		}
	}
	local pos = self.itemPosTable[tonumber(idx)] or {
		0,
		0,
		0,
		0
	}

	return pos[1], pos[2], pos[3], pos[4], pos.attach
end
fashion.switchBtn = function (self, state)
	if self.state ~= state then
		if state then
			self.limitBtn:select()
			self.limitBtn.label:setColor(def.colors.Cdcd2be)
			self.permanentBtn:unselect()
			self.permanentBtn.label:setColor(def.colors.Cf0c896)
		else
			self.permanentBtn:select()
			self.permanentBtn.label:setColor(def.colors.Cdcd2be)
			self.limitBtn:unselect()
			self.limitBtn.label:setColor(def.colors.Cf0c896)
		end

		self.switchBg:scaleX(self.switchBg:getScaleX()*-1)

		self.state = state

		self.updateLeftView(self, self.state)
	end

	return 
end
fashion.ItemSelected = function (self, idx)
	for i = 1, #self.ItemList, 1 do
		local selectBg = self.ItemList[i]:getChildByName("selectBg")

		if selectBg then
			if i == idx then
				selectBg.show(selectBg)

				local data = self.ItemList[idx].data

				self.updateRightView(self, data)
			else
				selectBg.hide(selectBg)
			end
		end
	end

	return 
end
fashion.updateRightView = function (self, data)
	local rightNode = self.getChildByName(self, "rightNode")

	if rightNode then
		rightNode.removeSelf(rightNode)
	end

	rightNode = display.newScale9Sprite(res.getframe2("pic/common/black_5.png")):anchor(0, 0):pos(171, 14):size(457, 390):addTo(self)

	rightNode.setName(rightNode, "rightNode")

	local center_bg = display.newSprite(res.gettex2("pic/panels/wingUpgrade/role_wing_bg.png")):anchor(0.5, 0.5):pos(150, 180):add2(rightNode)
	local heroBg = display.newNode():add2(center_bg):anchor(0, 0):pos(90, 80)

	self.initShowDress(self, heroBg, data)
	heroBg.scale(heroBg, 0.8)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/title_bg.png")):anchor(0.5, 0.5):pos(rightNode.getw(rightNode)/2 - 80, 366):add2(rightNode)

	local lblWingName = an.newLabel(data.FEName, 20, 1, {
		color = def.colors.Cdcd2be
	}):anchor(0.5, 0.5):pos(150, 366):add2(rightNode)

	local function createTipLayer(x, y, info)
		local layer = display.newNode():size(display.width, display.height):addto(display.getRunningScene())

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

		local bg = display.newScale9Sprite(res.getframe2("pic/scale/scale24.png")).addto(slot4, layer):anchor(0, 1):pos(x, y)
		local text = info
		local lbl = an.newLabel(text, 16, 1, {
			color = cc.c3b(220, 210, 190)
		})

		bg.size(bg, lbl.getw(lbl) + 20, lbl.geth(lbl) + 20)
		lbl.add2(lbl, bg):anchor(0.5, 0):pos(bg.getw(bg)/2, 10)

		return 
	end

	local labelTrail = an.newLabel("说明", 20, 0, {
		color = def.colors.Cf0c896
	}).anchor(slot7, 0.5, 0.5):add2(center_bg):pos(35, 105):anchor(0, 0.5)

	labelTrail.addUnderline(labelTrail)
	labelTrail.setTouchEnabled(labelTrail, true)
	labelTrail.setTouchSwallowEnabled(labelTrail, false)
	labelTrail.addNodeEventListener(labelTrail, cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			return true
		elseif event.name == "ended" then
			createTipLayer(event.x, event.y - 10, data.Desc)
		end

		return 
	end)

	local btnText = "隐藏时装"

	if data.FIsShow == 0 then
		btnText = "展示时装"
	end

	local level = data.FLevel or 0
	local expdata = def.fashion.getPropertyByLevel(data.idx, level + 1)

	if type(data.TimeLimit) == "string" and data.have then
		if def.fashion.isCanUpLevel(data.idx) then
			local starPosY = 120

			if not self.mode and level < 10 then
				starPosY = 125
				local processBg = display.newScale9Sprite(res.getframe2("pic/panels/wingUpgrade/pg_bg.png"), 0, 0, cc.size(260, 15)).anchor(slot12, 0.5, 0.5):add2(rightNode):pos(rightNode.getw(rightNode)/2 - 78, 100)
				local processBar = display.newScale9Sprite(res.getframe2("pic/common/slider2.png"), 0, 0, cc.size(260, 12)):anchor(0, 0.5):add2(processBg):pos(3, processBg.geth(processBg)/2)
				local FEHaveStuff = data.FHaveStuff or 0

				processBar.setScaleX(processBar, FEHaveStuff/expdata.UpNeedItemCount)

				local lblProcess = an.newLabel(string.format("%d/%d", FEHaveStuff*expdata.ItemGetExp, expdata.UpNeedItemCount*expdata.ItemGetExp), 18, 1, {
					color = cc.c3b(220, 210, 190)
				}):anchor(0.5, 0):pos(processBg.getw(processBg)/2, 0):add2(processBg)

				an.newLabel("升星消耗：", 18, 1, {
					color = def.colors.Cdcd2be
				}):anchor(0.5, 0.5):pos(80, 70):add2(rightNode)

				local itemIdx = def.items.getItemIdByName(expdata.UpNeedItem)
				local itemData = def.items.getStdItemById(itemIdx)
				local m1 = CommonItem.new(itemData, self, {
					scroll = true,
					donotMove = true,
					idx = idx
				}):add2(rightNode, 2):pos(140, 73)

				m1.setScale(m1, 0.7)

				if m1.dura then
					m1.dura:removeSelf()

					m1.dura = nil
				end

				an.newLabel("*" .. tostring(expdata.UpNeedItemCount), 20, 1, {
					color = def.colors.Cdcd2be
				}):anchor(0, 0.5):pos(30, m1.geth(m1)/2):add2(m1)
				an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
					sound.playSound("103")
					self:requestShowFashion(data.idx, btnText)

					return 
				end, {
					pressImage = res.gettex2("pic/common/btn21.png"),
					label = {
						btnText,
						16,
						0,
						{
							color = def.colors.Cf0c896
						}
					}
				}).add2(slot19, rightNode):anchor(0.5, 0.5):pos(90, 30)
				an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
					sound.playSound("103")

					local strMsg = {
						{
							"你确定消耗",
							cc.c3b(255, 255, 255)
						},
						{
							expdata.UpNeedItem .. "*" .. tostring(expdata.UpNeedItemCount),
							cc.c3b(255, 0, 0)
						},
						{
							"对",
							cc.c3b(255, 255, 255)
						},
						{
							data.FEName,
							cc.c3b(255, 0, 0)
						},
						{
							"进行升星么？",
							cc.c3b(255, 255, 255)
						}
					}

					an.newMsgbox(strMsg, function (idx)
						if idx == 1 then
							if not self:checkItemExist(expdata.UpNeedItem) then
								main_scene.ui:tip("升级失败，材料不足", 6)

								return 
							end

							if g_data.player.ability.FLevel < expdata.UpNeedLv then
								main_scene.ui:tip("升星失败，等级不足", 6)

								return 
							end

							if g_data.client.serverState < expdata.UpNeedSvrStep then
								main_scene.ui:tip("升星失败，服务器阶段不足", 6)

								return 
							end

							local rsb = DefaultClientMessage(CM_ClientUpFELev)
							rsb.FFashionID = data.idx
							rsb.FUpType = 2

							MirTcpClient:getInstance():postRsb(rsb)
							main_scene.ui.waiting:show(3, "CM_ClientUpFELev")
						end

						return 
					end, {
						noclose = true,
						title = "提示",
						center = true,
						contentLabelSize = 20,
						btnTexts = {
							"确定",
							"取消"
						}
					})

					return 
				end, {
					pressImage = res.gettex2("pic/common/btn21.png"),
					label = {
						"升星",
						16,
						0,
						{
							color = def.colors.Cf0c896
						}
					}
				}).add2(slot19, rightNode):anchor(0.5, 0.5):pos(220, 30)

				local labelPreview = an.newLabel("升星预览", 20, 0, {
					color = def.colors.Cf0c896
				}):anchor(0.5, 0.5):add2(center_bg):pos(210, 105):anchor(0, 0.5)

				labelPreview.addUnderline(labelPreview)
				labelPreview.setTouchEnabled(labelPreview, true)
				labelPreview.setTouchSwallowEnabled(labelPreview, false)
				labelPreview.addNodeEventListener(labelPreview, cc.NODE_TOUCH_EVENT, function (event)
					if event.name == "began" then
						return true
					elseif event.name == "ended" then
						main_scene.ui:togglePanel("fashionPreview", {
							data = data,
							job = self.otherJob
						})
					end

					return 
				end)
			end

			if not self.mode and level == 10 then
				an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
					sound.playSound("103")
					self:requestShowFashion(data.idx, btnText)

					return 
				end, {
					pressImage = res.gettex2("pic/common/btn21.png"),
					label = {
						btnText,
						16,
						0,
						{
							color = def.colors.Cf0c896
						}
					}
				}).add2(slot12, rightNode):anchor(0.5, 0.5):pos(150, 70)
			end

			for i = 1, 10, 1 do
				local star = an.newBtn(res.gettex2("pic/panels/wingUpgrade/starBg.png"), function ()
					return 
				end, {
					select = {
						res.gettex2("pic/panels/wingUpgrade/star.png")
					}
				}).add2(slot16, rightNode):anchor(0.5, 0.5):pos(i*24 + 15, starPosY)

				star.setTouchEnabled(star, false)

				if data.FLevel and i <= data.FLevel then
					star.select(star)
				end
			end
		else
			an.newLabel("不可升星", 18, 1, {
				color = def.colors.Cf0c896
			}):anchor(0.5, 0.5):pos(160, 110):add2(rightNode)

			if not self.mode then
				an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
					sound.playSound("103")
					self:requestShowFashion(data.idx, btnText)

					return 
				end, {
					pressImage = res.gettex2("pic/common/btn21.png"),
					label = {
						btnText,
						16,
						0,
						{
							color = def.colors.Cf0c896
						}
					}
				}).add2(slot11, rightNode):anchor(0.5, 0.5):pos(160, 50)
			end
		end
	elseif type(data.TimeLimit) == "number" and data.have then
		if not self.mode then
			an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
				self:requestShowFashion(data.idx, btnText)
				sound.playSound("103")

				return 
			end, {
				pressImage = res.gettex2("pic/common/btn21.png"),
				label = {
					btnText,
					16,
					0,
					{
						color = def.colors.Cf0c896
					}
				}
			}).add2(slot11, rightNode):anchor(0.5, 0.5):pos(150, 70)
		end

		if data.FInvalidTime then
			local ts = ""
			local curTime = g_data.serverTime:getTime()
			local lastTime = tonumber(data.FInvalidTime)
			local d, h = common.convertDayTimeFromSec(lastTime - curTime)

			if d < 0 then
				d = 0
			end

			if h < 0 then
				h = 0
			end

			if d == 0 and h < 1 then
				an.newLabel("剩余时间小于1小时", 18, 1, {
					color = cc.c3b(216, 231, 232)
				}):anchor(0.5, 0.5):pos(150, 20):add2(rightNode)
			else
				ts = string.format("%d天%d小时", d, h)

				an.newLabel(string.format("剩余时间: %s", ts), 18, 1, {
					color = cc.c3b(216, 231, 232)
				}):anchor(0.5, 0.5):pos(150, 20):add2(rightNode)
			end
		end
	elseif self.mode then
		an.newLabel("暂未拥有", 18, 1, {
			color = def.colors.Cf0c896
		}):anchor(0.5, 0.5):pos(150, 110):add2(rightNode)
	else
		an.newLabel("解锁消耗：", 18, 1, {
			color = def.colors.Cdcd2be
		}):anchor(0.5, 0.5):pos(120, 100):add2(rightNode)

		local itemArr = string.split(data.needitem, "|")
		local itemName = itemArr[1]
		local itemCount = itemArr[2]
		local itemIdx = def.items.getItemIdByName(itemName)
		local itemData = def.items.getStdItemById(itemIdx)
		local m1 = CommonItem.new(itemData, self, {
			scroll = true,
			donotMove = true,
			idx = idx
		}):add2(rightNode, 2):pos(180, 100)

		m1.setScale(m1, 0.7)

		if m1.dura then
			m1.dura:removeSelf()

			m1.dura = nil
		end

		an.newLabel("*" .. tostring(itemCount), 20, 1, {
			color = def.colors.Cdcd2be
		}):anchor(0, 0.5):pos(30, m1.geth(m1)/2):add2(m1)
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			sound.playSound("103")

			local strMsg = {
				{
					"你确定消耗",
					cc.c3b(255, 255, 255)
				},
				{
					itemName .. "*" .. tostring(itemCount),
					cc.c3b(255, 0, 0)
				},
				{
					"对",
					cc.c3b(255, 255, 255)
				},
				{
					data.FEName,
					cc.c3b(255, 0, 0)
				},
				{
					"进行解锁么？",
					cc.c3b(255, 255, 255)
				}
			}

			an.newMsgbox(strMsg, function (idx)
				if idx == 1 then
					if not self:checkItemExist(itemName) then
						main_scene.ui:tip("解锁失败，道具不足", 6)

						return 
					end

					local rsb = DefaultClientMessage(CM_ClientUpFELev)
					rsb.FFashionID = data.idx
					rsb.FUpType = 1

					MirTcpClient:getInstance():postRsb(rsb)
					main_scene.ui.waiting:show(3, "CM_ClientUpFELev")
				end

				return 
			end, {
				noclose = true,
				title = "提示",
				center = true,
				contentLabelSize = 20,
				btnTexts = {
					"确定",
					"取消"
				}
			})

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			label = {
				"解锁",
				16,
				0,
				{
					color = def.colors.Cf0c896
				}
			}
		}).add2(slot17, rightNode):anchor(0.5, 0.5):pos(150, 40)
	end

	local propertyBg = display.newScale9Sprite(res.getframe2("pic/scale/scale9.png"), 0, 0, cc.size(150, 380)):anchor(0, 0):pos(300, 5):addTo(rightNode)

	display.newSprite(res.gettex2("pic/panels/wingUpgrade/flag.png")):anchor(0, 0.5):pos(rightNode.getw(rightNode) - 155, 369):add2(rightNode)
	display.newSprite(res.gettex2("pic/panels/fashion/jcsx.png")):anchor(0, 0.5):pos(rightNode.getw(rightNode) - 136, 369):add2(rightNode)
	display.newSprite(res.gettex2("pic/panels/wingUpgrade/flag.png")):anchor(0, 0.5):pos(rightNode.getw(rightNode) - 155, 160):add2(rightNode)
	display.newSprite(res.gettex2("pic/panels/fashion/wxyl.png")):anchor(0, 0.5):pos(rightNode.getw(rightNode) - 136, 160):add2(rightNode)

	local propertyM = an.newLabelM(propertyBg.getw(propertyBg) - 10, 18, 0, {}):add2(propertyBg):anchor(0, 1):pos(5, propertyBg.geth(propertyBg) - 30)
	local ProStr = {}

	if level <= 0 then
		ProStr = data.ProStr
	else
		ProStr = def.fashion.getPropertyByLevel(data.idx, level).ProStr
	end

	local job = self.otherJob or g_data.player.job
	local props = def.property.dumpPropertyStr(ProStr):clearZero():toStdProp():grepJob(job)
	local idx = 0

	for i, v in ipairs(props.props) do
		local p = props.getPropStrings(props, v[1])

		propertyM.addLabel(propertyM, p[1] .. ": ", def.colors.Cf0c896)
		propertyM.addLabel(propertyM, (p[3] ~= nil and p[2] .. "-" .. p[3]) or "+" .. p[2], def.colors.Cdcd2be)
		propertyM.nextLine(propertyM)
	end

	self.playMiniAnimation(self, data, heroBg.clone(heroBg), rightNode)

	return 
end
fashion.getParts = function (self, feature)
	local parts = {}
	local sex = feature.sex
	local weapon = def.role.getHeroWeapon(feature.weapon*2 + sex)
	parts.weapon = {
		id = weapon.Id,
		imgid = string.lower(weapon.WhichLib or ""),
		offset = weapon.OffSet,
		frame = frame or {}
	}
	local hairImg, hair = def.role.hair(feature)
	parts.hair = {
		id = hair,
		imgid = hairImg,
		offset = def.role.humFrame*hair,
		frame = frame or {},
		delete = hair == 0
	}

	return parts
end
fashion.playMiniAnimation = function (self, data, tempheroBg, rightNode)
	local showBg = display.newScale9Sprite(res.getframe2("pic/scale/scale9.png"), 0, 0, cc.size(135, 135), cc.rect(1, 1, 62, 62)):anchor(0, 0):pos(308, 10):addTo(rightNode)

	local function playAni()
		local role = {}

		if self.mode then
			role.feature = self.otherFeature
			role.parts = self:getParts(self.otherFeature)
		else
			role = main_scene.ground.map.player
		end

		if not role.parts then
			return 
		end

		local roleDress, roleWeapon, roleHair, roleEffect = nil

		if 0 < role.feature.hair or self.sex == 1 then
			roleHair = role.parts.hair
		end

		if self.fashionType == def.fashion.clothType then
			local dress = def.role.getHeroDress(data.shapeid*2 + self.sex)
			roleDress = {
				id = dress.Id,
				imgid = string.lower(dress.WhichLib or ""),
				offset = dress.OffSet
			}

			if dress.WihichEffectLib then
				roleEffect = {
					blend = true,
					id = dress.Id,
					imgid = string.lower(dress.WihichEffectLib or ""),
					offset = (dress.offsetEnd and dress.EffectOffSet) or dress.EffectOffSet + 136,
					offsetEnd = dress.offsetEnd or dress.EffectOffSet + 191,
					delay = dress.delay,
					alwaysPlay = dress.alwaysPlay,
					frame = frame
				}
			end

			if 0 < role.feature.weapon then
				roleWeapon = role.parts.weapon
			end
		elseif self.fashionType == def.fashion.weaponType then
			local dress = def.role.getHeroDress(role.feature.dress*2 + self.sex)
			roleDress = {
				id = dress.Id,
				imgid = string.lower(dress.WhichLib or ""),
				offset = dress.OffSet
			}

			if dress.WihichEffectLib then
				roleEffect = {
					blend = true,
					id = dress.Id,
					imgid = string.lower(dress.WihichEffectLib or ""),
					offset = (dress.offsetEnd and dress.EffectOffSet) or dress.EffectOffSet + 136,
					offsetEnd = dress.offsetEnd or dress.EffectOffSet + 191,
					delay = dress.delay,
					alwaysPlay = dress.alwaysPlay,
					frame = frame
				}
			end

			local weapon = def.role.getHeroWeapon(data.shapeid*2 + self.sex)
			roleWeapon = {
				id = weapon.Id,
				imgid = string.lower(weapon.WhichLib or ""),
				offset = weapon.OffSet,
				frame = frame or {}
			}
		end

		local node = display.newNode():pos(showBg:getw()/2 - 20, showBg:geth()/2 - 20):add2(showBg)

		if roleDress then
			m2spr.playAnimation(roleDress.imgid, roleDress.offset + 136, 55, 0.1, true):add2(node, 2)
		end

		if roleEffect then
			m2spr.playAnimation(roleEffect.imgid, roleEffect.offset, roleEffect.offsetEnd - roleEffect.offset + 1, roleEffect.delay, roleEffect.blend):add2(node, 4)
		end

		if roleWeapon then
			m2spr.playAnimation(roleWeapon.imgid, roleWeapon.offset + 136, 55, 0.1, true):add2(node, 2)
		end

		if roleHair then
			m2spr.playAnimation(roleHair.imgid, roleHair.offset + 136, 55, 0.1, false):add2(node, 10):pos(0, 0)
		end

		return 
	end

	tempheroBg.add2(slot2, showBg)
	tempheroBg.scale(tempheroBg, 0.4):pos(35, 0)

	local playCGBg = display.newScale9Sprite(res.getframe2("pic/common/50p_MaskBg.png"), 0, 0, cc.size(135, 135)):anchor(0, 0):pos(308, 10):addTo(rightNode)
	local playCG = res.get2("pic/panels/fashion/playCG.png"):add2(rightNode):pos(308, 20):scale(1.4):anchor(0, 0)

	playCG.enableClick(playCG, function ()
		tempheroBg:hide()
		playCG:removeSelf()
		playCGBg:removeSelf()
		playAni()

		return 
	end)

	return showBg
end
fashion.updateLeftView = function (self, islimit)
	local leftNode = self.getChildByName(self, "leftNode")

	if leftNode then
		leftNode.removeSelf(leftNode)
	end

	leftNode = display.newNode():add2(self):anchor(0, 0):pos(14, 14):size(162, 390)

	leftNode.setName(leftNode, "leftNode")

	local tempList = def.fashion.setHaveFashion(self.list, islimit, self.OtherFList)
	local count = #tempList
	local minheight = math.max(math.ceil(count/2)*70, 330)
	local leftScroll = an.newScroll(4, 4, 140, 330):anchor(0, 1):add2(leftNode):pos(10, 335)
	local posX = 0
	local posY = minheight
	local isExist = false
	self.ItemList = {}

	if count == 0 then
		an.newLabel("暂无时装", 20, 1, {
			color = def.colors.Cdcd2be
		}):anchor(0.5, 0.5):pos(leftNode.getw(leftNode)/2, leftNode.geth(leftNode)/2):add2(leftNode)
	end

	for i = 1, count, 1 do
		local tv = tempList[i]

		if i%2 == 0 then
			posX = 105
		else
			posX = 35
		end

		posY = posY - math.ceil(i%2)*70
		local selectBg = nil
		local itemBg = an.newBtn(res.gettex2("pic/panels/fusion/equip3_0.png"), function ()
			sound.playSound("103")
			self:ItemSelected(i)

			self.selectedIdx = tv.idx

			selectBg:show()

			return 
		end, {
			support = "scroll"
		}).add2(slot16, leftScroll):pos(posX, posY):anchor(0.5, 0)

		res.get(tv.itemaltlas, tv.itemid):addto(itemBg):anchor(0.5, 0.5):pos(33, 35)

		if not tv.have then
			local lockBg = display.newScale9Sprite(res.getframe2("pic/common/50p_MaskBg.png"), 0, 0, cc.size(66, 66)):add2(itemBg):anchor(0, 0)

			res.get2("pic/common/lock.png"):add2(lockBg):pos(lockBg.getw(lockBg)/2, lockBg.geth(lockBg)/2):anchor(0.5, 0.5)
		end

		if tv.FIsShow and tv.FIsShow == 1 then
			display.newSprite(res.gettex2("pic/panels/horseUpgrade/showing.png")):pos(45, 50):add2(itemBg)
		end

		if tv.FLevel and 0 < tv.FLevel then
			an.newLabel("+" .. tostring(tv.FLevel), 16, 0, {
				color = def.colors.Cf0c896
			}):anchor(1, 0.5):add2(itemBg):pos(itemBg.getw(itemBg) - 10, 16)
		end

		selectBg = res.get2("pic/common/light.png"):add2(itemBg):pos(0, 2):scale(1.5):anchor(0, 0)

		selectBg.setName(selectBg, "selectBg")
		selectBg.hide(selectBg)

		itemBg.data = tv
		self.ItemList[i] = itemBg

		if self.selectedIdx == tv.idx then
			isExist = true

			self.ItemSelected(self, i)
		end
	end

	leftScroll.setScrollSize(leftScroll, 0, minheight)

	if 0 < #self.ItemList then
		if not isExist then
			self.ItemSelected(self, 1)
		end
	else
		local rightNode = self.getChildByName(self, "rightNode")

		if rightNode then
			rightNode.removeSelf(rightNode)
		end
	end

	return 
end
fashion.reloadButton = function (self)
	local btnNode = self.getChildByName(self, "btnNode")

	if btnNode then
		btnNode.removeSelf(btnNode)
	end

	btnNode = display.newNode():add2(self):anchor(0, 0):pos(14, 14):size(162, 390)

	btnNode.setName(btnNode, "btnNode")

	local normalImg = res.gettex2("pic/common/btn152.png")
	local selectedImg = res.gettex2("pic/common/btn153.png")
	self.switchBg = res.get2("pic/panels/fashion/switchBg.png"):add2(btnNode):pos(80, btnNode.geth(btnNode) - 30)

	display.newScale9Sprite(res.getframe2("pic/panels/fashion/lsbg.png"), 0, 0, cc.size(162, 390)):anchor(0, 0):pos(0, 0):addTo(btnNode)

	self.limitBtn = an.newBtn(normalImg, function ()
		sound.playSound("103")
		self:switchBtn(true)

		return 
	end, {
		select = {
			selectedImg,
			manual = true
		},
		label = {
			"限时",
			18,
			0,
			{
				color = def.colors.Cdcd2be
			}
		}
	}).pos(slot4, 40, 365):addto(btnNode)
	self.permanentBtn = an.newBtn(normalImg, function ()
		sound.playSound("103")
		self:switchBtn(false)

		return 
	end, {
		select = {
			selectedImg,
			manual = true
		},
		label = {
			"永久",
			18,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).pos(slot4, 120, 365):addto(btnNode)

	self.limitBtn:select()

	self.state = true

	self.switchBg:scaleX(self.switchBg:getScaleX()*-1)

	return 
end
fashion.loadDressPage = function (self)
	self.fashionType = def.fashion.clothType
	self.list = def.fashion.getFashion(self.fashionType, self.sex)

	self.reloadButton(self)
	self.updateLeftView(self, true)

	return 
end
fashion.loadEquipPage = function (self)
	self.fashionType = def.fashion.weaponType
	self.list = def.fashion.getFashion(self.fashionType)

	self.reloadButton(self)
	self.updateLeftView(self, true)

	return 
end

local function tip(str)
	main_scene.ui:tip(str, 6)

	return 
end

fashion.onSM_ClientQueryFEInfo = function (self, result)
	if not result then
		return 
	end

	if result.FFEListType == 2 then
		self.OtherFList = result.FrevgList
		self.otherFeature = common.convertFeature(result.FOtherFeature)
	elseif result.FFEListType == 1 then
		g_data.player:setFashionInfo(result)
	end

	self.updateLeftView(self, self.state)

	return 
end
fashion.onCloseWindow = function (self)
	main_scene.ui:hidePanel("fashionPreview")

	return self.super.onCloseWindow(self)
end
fashion.onSM_ClientShowFE = function (self, result)
	if not result then
		return 
	end

	if result.Fretcode == 1 then
		g_data.player:updateFashionShowInfo(result.FFEID, true)
		self.updateLeftView(self, self.state)
	end

	if result.Fretcode == 2 then
		g_data.player:updateFashionShowInfo(result.FFEID, false)
		self.updateLeftView(self, self.state)
	end

	main_scene.ui.waiting:close("CM_ClientShowFE")

	local errorMsg = {
		"展示成功",
		"隐藏成功",
		[-1.0] = "当前未拥有此时装"
	}

	tip(errorMsg[result.Fretcode])

	return 
end
fashion.onSM_ClientUpFELev = function (self, result)
	if not result then
		return 
	end

	if result.FRetCode == 1 then
		g_data.player:updateFashionLevelInfo(result.FFEID, result.FFELevel, result.FFEHaveStuff)
		self.updateLeftView(self, self.state)
	end

	main_scene.ui.waiting:close("CM_ClientUpFELev")

	if result.FUpType == 2 then
		local errorMsg = {
			"升星成功",
			[-6.0] = "升星失败，材料不足",
			[-5.0] = "升星失败，当前等级已满",
			[-8.0] = "升星失败，等级不足",
			[-9.0] = "升星失败，服务器阶段不足"
		}

		if errorMsg[result.FRetCode] then
			tip(errorMsg[result.FRetCode])
		else
			tip("升星失败")
		end
	elseif result.FUpType == 1 then
		local errorMsg = {
			"解锁成功",
			[-6.0] = "解锁失败，材料不足",
			[-8.0] = "解锁失败，等级不足"
		}

		if errorMsg[result.FRetCode] then
			tip(errorMsg[result.FRetCode])
		else
			tip("解锁失败")
		end
	end

	return 
end
fashion.onTabClick = function (self, idx, btn)
	self.curTab = self.tabCallbacks[idx]
	self.curIdx = idx

	self.tabCallbacks[idx](self)

	return 
end

return fashion
