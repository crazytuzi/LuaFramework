local current = ...
local item = import("...common.item")
local iconFunc = import("..iconFunc")
local common = import("...common.common")
local pointTip = import("...common.pointTip")
local btnMove = class("btnMove", function ()
	return display.newNode()
end)

table.merge(slot5, {
	data,
	config,
	btn,
	donotMutilTouch,
	clickEffAni,
	loopEffAni,
	loopEffSpr,
	progressTimer,
	isHide,
	looks,
	skillData,
	makeIndex,
	cdtime,
	pastTime,
	cdEndAni
})

btnMove.onCleanup = function (self)
	if self.clickEffAni then
		self.clickEffAni:release()

		self.clickEffAni = nil
	end

	if self["remove_" .. self.data.key] then
		self["remove_" .. self.data.key](self)
	end

	if self["remove_btntype_" .. self.config.btntype] then
		self["remove_btntype_" .. self.config.btntype](self)
	end

	if self.config.btnid == "back" and self.pastTime and self.pastTime ~= 0 then
		cache.saveDiy(common.getPlayerName() .. "back", "cdpasttime", self.pastTime)
	end

	return 
end
btnMove.ctor = function (self, config, data)
	self.data = data
	self.config = config

	if config.btntype ~= "normal" or config.key ~= "btnVoice" or false then
		if config.btntype == "normal" and config.key == "btnVoiceJIT" then
			self.donotMutilTouch = true
			self.btn = import(".voiceBtnJIT", current).new():anchor(0, 0):add2(self)
		else
			local files = iconFunc:getFilenames(config, data, true)

			if files.select then
				files.select = {
					res.gettex2(files.select),
					manual = true
				}
			end

			if config.btntype == "prop" or config.btntype == "custom" then
				files.sprite = nil
			end

			local longTouchCB_, skillConfig, filter = nil

			if config.btntype == "skill" then
				local skillLvl = g_data.player:getMagicLvl(data.magicId)
				skillConfig = def.magic.getMagicConfigByUid(data.magicId, skillLvl)
				self.skillData = g_data.player:getMagic(tonumber(data.magicId))

				if skillConfig.cdtime then
					filter = res.getFilter("gray")
				elseif not self.skillData then
					filter = res.getFilter("gray")
				end

				if skillConfig.longTouch then
					function longTouchCB_()
						main_scene.ui.console.btnCallbacks:handle(config.btntype, self)

						return 
					end
				end
			elseif self.config.btnid == "back" or self.config.key == "btnPet" or self.config.key == "btnPet2" or self.config.key == "btnFlag" then
				slot7 = res.getFilter("gray")
				filter = slot7
			end

			self.btn = an.newBtn(res.gettex2(files.bg), function ()
				if config.btntype == "base" then
					self:playClickEffect()
				end

				if data.magicId and g_data.client.skillBtns["skillMutex" .. data.magicId] then
					print("____click mutex__")

					return 
				end

				main_scene.ui.console.btnCallbacks:handle(config.btntype, self)

				return 
			end, {
				externTouch = true,
				pressBig = true,
				sprite = files.sprite and res.gettex2(files.sprite),
				select = files.select,
				filter = filter,
				filterOpen = filter ~= nil,
				longTouchCB = longTouchCB_
			}).anchor(slot7, 0, 0):add2(self)

			if files.text then
				res.get2(files.text):pos(self.btn:getw()/2, 10):add2(self.btn, 1)
			end

			if config.btntype == "custom" then
				self.btn:setTouchEnabled(true)
			end

			if skillConfig and skillConfig.cdtime and self.skillData then
				self.skill_upt(self, self.skillData)
			end

			if self.config.btnid == "back" then
				self.backHome_upt(self)
			end

			if self.config.key == "btnPet" then
				self.btnPet_upt(self)
			end

			if self.config.key == "btnPet2" then
				self.btnPet2_upt(self)
			end

			if self.config.key == "btnFlag" then
				self.btnFlag_upt(self)
			end
		end
	end

	self.size(self, self.btn:getContentSize()):anchor(0.5, 0.5):pos(data.x or 0, data.y or 0)
	self.scale(self, (config.btntype == "panel" and 0.8533333333333334) or 1)
	self.setNodeEventEnabled(self, true)

	if self["init_" .. data.key] then
		self["init_" .. data.key](self)
	end

	if self["init_btntype_" .. config.btntype] then
		self["init_btntype_" .. config.btntype](self)
	end

	if self.config.key == "btnHorse" then
		g_data.eventDispatcher:addListener("HORSE_STATE_CHG", self, self.handleHorse)
	end

	if self.config.key == "btnFlag" then
		g_data.eventDispatcher:addListener("Flag_STATE_CHG", self, self.handleFlag)
	end

	if self.config.key == "btnPet2" then
		g_data.eventDispatcher:addListener("PET_STATE_CHG", self, self.handlePet2)
	end

	if config.btnid == "relation" or config.btnid == "mail" or config.btnid == "equip" or config.btnid == "activity" then
		g_data.eventDispatcher:addListener("M_POINTTIP", self, self.onPointTip)
		self.onPointTip(self, config.btnid, nil)
	end

	return 
end
btnMove.onPointTip = function (self, type, visible)
	if type == self.config.btnid then
		self.onSocialPointTip(self, type, visible)
	elseif self.config.btnid == "equip" then
		self.onEquipPointTip(self, type, visible)
	end

	return 
end
btnMove.onSocialPointTip = function (self, type, visible)
	self.setPointTip(self, g_data.pointTip:isVisible(type))

	return 
end
btnMove.onEquipPointTip = function (self, type, visible)
	if g_data.pointTip:isVisible("gemstone_active") or g_data.pointTip:isVisible("gemstone_upgrade") or g_data.pointTip:isVisible("wing_activate") or g_data.pointTip:isVisible("wing_show") or g_data.pointTip:isVisible("solider_upgrade") or g_data.pointTip:isVisible("god_ring_upgrade") or g_data.pointTip:isVisible("horseSoul_upgrade") or g_data.pointTip:isVisible("maoyu_upgrade") or g_data.pointTip:isVisible("feiyu_upgrade") or g_data.pointTip:isVisible("lingyu_upgrade") then
		self.setPointTip(self, true)
	else
		self.setPointTip(self, false)
	end

	return 
end
btnMove.startCd = function (self)
	if self.skillData then
		self.skillData.iscdBegin = true

		self.playClickEffect(self)

		self.pastTime = 0

		if self.config.key ~= "btnBackHome" and self.config.btntype == "skill" then
			local skillLvl = g_data.player:getMagicLvl(self.data.magicId)
			local skillConfig = def.magic.getMagicConfigByUid(self.data.magicId, skillLvl)

			if skillConfig.delta and skillConfig.delta ~= 0 then
				self.limitCdBegin = true
				self.delta = skillConfig.delta/1000
				self.limitCdPt = 0
				g_data.isSkillBegan = true
			end
		end
	end

	return 
end
btnMove.updateCd = function (self, lasttime)
	if self.cdtime < lasttime then
		print("btnMove:updateCd set CD failed! invalid cdtime", lasttime)

		return 
	end

	self.pastTime = self.cdtime - lasttime/1000
	local percent = self.pastTime/self.cdtime*100

	self.setProgress(self, percent)

	self.skillData.iscdBegin = true

	return 
end
btnMove.update = function (self, dt)
	if self.skillData and self.skillData.iscdBegin == true then
		self.pastTime = dt + self.pastTime
		local percent = self.pastTime/self.cdtime*100

		if 100 <= percent then
			percent = 100
			self.skillData.iscdBegin = false
			self.pastTime = 0

			if not self.cdEndAni then
				self.cdEndAni = res.getani2("pic/effect/cdend/%d.png", 1, 5, 0.08)

				self.cdEndAni:retain()
			end

			local spr = res.get2("pic/effect/cdend/1.png")

			spr.pos(spr, self.btn:centerPos()):add2(self):runs({
				cc.Animate:create(self.cdEndAni),
				cc.CallFunc:create(function ()
					spr:removeSelf()

					spr = nil

					return 
				end)
			})
		end

		self.setProgress(slot0, percent)
	end

	if self.limitCdBegin then
		self.limitCdPt = self.limitCdPt + dt
		local per = self.limitCdPt/self.delta*100

		if 100 <= per then
			g_data.isSkillBegan = false
			self.limitCdBegin = false
		end
	end

	return 
end
btnMove.onEnter = function (self, args)
	if self.config.btntype == "custom" then
		table.insert(main_scene.ui.customs, self)
	end

	if self.config.btnid == "back" then
		local pastT = cache.getDiy(common.getPlayerName() .. "back", "cdpasttime")

		if pastT then
			self.pastTime = pastT

			self.startCd(self)
		end
	end

	return 
end
btnMove.getClickRect = function (self)
	if self.data.btnpos then
		local add = 0

		if string.split(self.data.btnpos, "-")[2] == "1" then
			add = main_scene.ui.console.btnAreaBeginX
		end

		local s = main_scene.ui.console.btnAreaSpace

		return cc.rect(self.getPositionX(self) - s/2, self.getPositionY(self) - s/2, s + add, s)
	else
		return self.getCascadeBoundingBox(self)
	end

	return 
end
btnMove.playClickEffect = function (self)
	if not self.clickEffAni then
		self.clickEffAni = res.getani2("pic/effect/btnclick/%d.png", 1, 5, 0.06)

		self.clickEffAni:retain()
	end

	local spr = nil
	slot2 = res.get2("pic/effect/btnclick/1.png"):pos(self.centerPos(self)):add2(self):scale(0.55):runs({
		cc.Animate:create(self.clickEffAni),
		cc.CallFunc:create(function ()
			spr:removeSelf()

			spr = nil

			return 
		end)
	})
	spr = slot2

	return 
end
btnMove.playLoopEffect = function (self)
	if not self.loopEffAni then
		self.loopEffAni = res.getani2("pic/effect/btnselect/%d.png", 1, 15, 0.06)

		self.loopEffAni:retain()
	end

	if not self.loopEffSpr then
		self.loopEffSpr = res.get2("pic/effect/btnselect/1.png"):pos(self.centerPos(self)):add2(self):runForever(cc.Animate:create(self.loopEffAni))
	end

	return 
end
btnMove.stopLoopEffect = function (self)
	if self.loopEffSpr then
		self.loopEffSpr:removeSelf()

		self.loopEffSpr = nil
	end

	return 
end
btnMove.setProgress = function (self, p, filename)
	if self.config.btntype == "skill" or self.config.btnid == "back" or self.config.key == "btnPet" or self.config.key == "btnPet2" or self.config.key == "btnFlag" then
		if not self.progressTimer then
			self.progressTimer = ccui.LoadingBar:create(res.gettex2(filename), 0)

			self.progressTimer:setRotation(270)
			self.progressTimer:pos(self.btn:centerPos()):add2(self.btn)
		end

		self.progressTimer:setPercent(p)
	else
		if not self.progressTimer then
			local spr = display.newSprite(res.gettex2(filename or "pic/console/radial.png"))
			self.progressTimer = display.newProgressTimer(spr, display.PROGRESS_TIMER_RADIAL):pos(self.centerPos(self)):add2(self)
		end

		self.progressTimer:setPercentage(p)
	end

	return 
end
btnMove.select = function (self)
	self.btn:select()

	return 
end
btnMove.unselect = function (self)
	self.btn:unselect()

	return 
end
btnMove.init_btnFullname = function (self)
	if g_data.setting.base.heroShowName then
		self.btn:select()
	end

	return 
end
btnMove.init_btnOnlyname = function (self)
	if g_data.setting.base.showNameOnly then
		self.btn:select()
	end

	return 
end
btnMove.init_btnSoundEnable = function (self)
	if g_data.setting.base.soundEnable then
		self.btn:select()
	end

	return 
end
btnMove.init_btnTouchRun = function (self)
	if g_data.setting.base.touchRun then
		self.btn:select()
	end

	return 
end
btnMove.init_btnAutoSpace = function (self)
	if g_data.setting.job.autoSpace then
		self.btn:select()
	end

	return 
end
btnMove.init_btnAutoWide = function (self)
	if g_data.setting.job.autoWide then
		self.btn:select()
	end

	return 
end
btnMove.init_btnAutoFire = function (self)
	if g_data.setting.job.autoFire then
		self.btn:select()
	end

	return 
end
btnMove.init_btnAutoDun = function (self)
	if g_data.setting.job.autoDun then
		self.btn:select()
	end

	return 
end
btnMove.init_btnAutoInvisible = function (self)
	if g_data.setting.job.autoInvisible then
		self.btn:select()
	end

	return 
end
btnMove.init_btnAutoSkill = function (self)
	if g_data.setting.job.autoSkill.enable then
		self.btn:select()
	end

	return 
end
btnMove.init_btnSingleRocker = function (self)
	if g_data.setting.base.singleRocker then
		self.btn:select()
	end

	return 
end
btnMove.init_btnDoubleRocker = function (self)
	if g_data.setting.base.doubleRocker then
		self.btn:select()
	end

	return 
end
btnMove.init_btntype_prop = function (self)
	g_data.bag:bindQuickItem(self.config.btnid, self.config.use, function (makeIndex)
		self.makeIndex = makeIndex

		self:prop_upt()

		return 
	end)
	self.prop_fill_test(slot0)

	return 
end
btnMove.remove_btntype_prop = function (self, btnid)
	if self.makeIndex then
		local _, data = g_data.bag:getItem(self.makeIndex)

		if data then
			g_data.bag:addItem(data)

			if main_scene.ui.panels.bag then
				main_scene.ui.panels.bag:addItem(self.makeIndex)
			end
		end
	end

	if not btnid then
		g_data.bag:unbindQuickItem(self.config.btnid)
	else
		g_data.bag:fillQuickItemTest(btnid)
	end

	return 
end
btnMove.prop_fill_test = function (self)
	if self.makeIndex then
		return 
	end

	g_data.bag:fillQuickItemTest(self.config.btnid)

	return 
end
btnMove.prop_upt = function (self)
	if not self.btn.sprite then
		self.btn.sprite = ycM2Sprite:create(res.default2(), false, false):pos(self.btn:centerPos()):add2(self.btn)
	end

	local btnid, data = nil

	if self.makeIndex then
		btnid, data = g_data.bag:getItem(self.makeIndex)
	end

	if data then
		self.btn.sprite:setTex(res.gettex("items", data.getVar(data, "looks"))):scale(1.2)
	else
		self.btn.sprite:setTex("public/empty.png")
	end

	return 
end
btnMove.backHome_upt = function (self)
	self.skillData = {
		iscdBegin = false
	}
	self.pastTime = 0
	self.cdtime = 30

	self.setProgress(self, 100, "pic/console/skill_base-icons/backp.png")
	self.btn.bg:clearFilter()

	return 
end
btnMove.btnFlag_upt = function (self)
	self.skillData = {
		iscdBegin = false
	}
	self.pastTime = 0
	self.cdtime = 5

	if self.progressTimer then
		self.progressTimer:removeSelf()

		self.progressTimer = nil
	end

	if g_data.player.crossServerState == 1 then
		if g_data.player.flagInfo.state == 0 then
			self.setProgress(self, 100, "pic/console/widget-icons/btnFlag_p.png")
		else
			self.setProgress(self, 100, "pic/console/widget-icons/btnFlag2_p.png")
		end
	end

	self.btn.bg:clearFilter()

	return 
end
btnMove.btnPet_upt = function (self)
	self.skillData = {
		iscdBegin = false
	}
	self.pastTime = 0
	self.cdtime = 3

	self.setProgress(self, 100, "pic/console/widget-icons/btnPetp.png")
	self.btn.bg:clearFilter()

	return 
end
btnMove.btnPet2_upt = function (self)
	self.skillData = {
		iscdBegin = false
	}
	self.pastTime = 0
	self.cdtime = 3

	if self.progressTimer then
		self.progressTimer:removeSelf()

		self.progressTimer = nil
	end

	if g_data.player.petInfo.state == 0 then
		self.setProgress(self, 100, "pic/console/widget-icons/btnPet2p.png")
	else
		self.setProgress(self, 100, "pic/console/widget-icons/btnPet1p.png")
	end

	self.btn.bg:clearFilter()

	return 
end
btnMove.skill_upt = function (self, data)
	if data then
		self.skillData = data
		local skillLvl = g_data.player:getMagicLvl(data.FMagicId)
		local skillConfig = def.magic.getMagicConfigByUid(data.FMagicId, skillLvl)

		if skillConfig.cdtime then
			self.iscdBegin = false
			self.pastTime = 0
			self.cdtime = skillConfig.cdtime/1000

			self.setProgress(self, 100, "pic/console/skill-icons/" .. data.FMagicId .. "p.png")
			self.btn.bg:clearFilter()
		else
			self.btn:closeFilter()
		end
	end

	return 
end
btnMove.init_btnHeroSkill = function (self)
	self.hero_upt_union(self)

	return 
end
btnMove.hero_upt_union = function (self)
	if 0 < g_data.hero.unionState then
		self.playLoopEffect(self)
	else
		self.stopLoopEffect(self)
	end

	local value = g_data.hero.unionProgress - 200
	local p = math.min(100, math.max(0, value/2))

	self.setProgress(self, p, "pic/console/heroUnion.png")

	return 
end
btnMove.voice_call = function (self, m, ...)
	self.btn[m](self.btn, ...)

	return 
end
btnMove.checkInButton = function (self, pos)
	local p = self.convertToWorldSpace(self, cc.p(0, 0))
	local rect = cc.rect(0, 0, self.btn:getContentSize().width, self.btn:getContentSize().height)

	if cc.rectContainsPoint(cc.rect(p.x + rect.x*self.btn:getScale(), p.y + rect.y*self.btn:getScale(), rect.width*self.btn:getScale(), rect.height*self.btn:getScale()), pos) then
		return true
	end

	return 
end
btnMove.checkItemType = function (self, item)
	local _, data = g_data.bag:getItem(item.FItemIdent)
	local where = getTakeOnPosition(item.getVar(item, "stdMode"))
	local stdMode = item.getVar(item, "stdMode")
	local canCustoms = {
		0,
		1,
		2,
		3
	}

	if not where then
		for _, mode in ipairs(canCustoms) do
			if tonumber(stdMode) == mode then
				return true
			end
		end
	end

	return false
end
btnMove.init_btntype_custom = function (self)
	local custom = g_data.bag:getCustom(self.config.id)

	if custom then
		self.source = custom.source

		g_data.bag:bindCustomsItem(self.config.btnid, {
			custom.name
		}, custom.makeIndex, function (makeIndex)
			self.makeIndex = makeIndex

			self:custom_upt()

			return 
		end)
	end

	return 
end
btnMove.custom_fill_test = function (self)
	if self.makeIndex then
		return 
	end

	g_data.bag:fillQuickItemTest(self.config.btnid)

	return 
end
btnMove.setCustomProps = function (self, item, source)
	g_data.bag:unbindQuickItem(self.config.btnid)

	self.makeIndex = nil
	self.source = source

	g_data.bag:bindCustomsItem(self.config.btnid, {
		item.getVar(item, "name")
	}, item.FItemIdent, function (makeIndex)
		self.makeIndex = makeIndex

		self:custom_upt()

		return 
	end)
	g_data.bag.addCustoms(slot3, self.config.id, item.FItemIdent, item.getVar(item, "name"), source)
	cache.saveCustoms(common.getPlayerName())

	return 
end
btnMove.custom_addItem = function (self, makeIndex)
	if self.btn.item then
		self.btn.item:removeSelf()

		self.btn.item = nil
	end

	local i, v = g_data.bag:getItem(makeIndex)
	local center_x, center_y = self.btn:centerPos()
	self.btn.item = item.new(v, self):pos(self.getPositionX(self), self.getPositionY(self)):addto(main_scene.ui)

	self.btn.item:setLocalZOrder(0)
	self.btn.item:setName("custom_" .. v.getVar(v, "name"))

	self.btn.item.owner = self.source
	self.btn.item.customNode = self

	return 
end
btnMove.custom_delItem = function (self)
	if self.makeIndex then
		g_data.bag:unbindQuickItem(self.config.btnid)

		self.makeIndex = nil

		g_data.bag:delCustoms(self.config.id)
		cache.saveCustoms(common.getPlayerName())
	end

	if self.btn.item then
		self.btn.item:removeSelf()

		self.btn.item = nil
	end

	return 
end
btnMove.custom_upt = function (self)
	local btnid, data = nil

	if self.makeIndex then
		btnid, data = g_data.bag:getItem(self.makeIndex)
	end

	if data then
		self.custom_addItem(self, self.makeIndex)
	else
		self.custom_delItem(self)
	end

	return 
end
btnMove.handleHorse = function (self)
	local config = self.config
	local data = self.data
	local files = iconFunc:getFilenames(config, data, true)
	local tx = res.gettex2(files.sprite)

	self.btn.sprite:setTexture(tx)

	return 
end
btnMove.handleFlag = function (self)
	local config = self.config
	local data = self.data
	local files = iconFunc:getFilenames(config, data, true)
	local tx = res.gettex2(files.sprite)

	self.btn.sprite:setTexture(tx)
	self.btnFlag_upt(self)

	return 
end
btnMove.handlePet2 = function (self)
	local config = self.config
	local data = self.data
	local files = iconFunc:getFilenames(config, data, true)
	local tx = res.gettex2(files.sprite)

	self.btn.sprite:setTexture(tx)
	self.btnPet2_upt(self)
	self.startCd(self)

	return 
end
btnMove.setPointTip = function (self, visible)
	if not self.tip then
		self.tip = pointTip.attach(self, {
			dir = "right",
			type = 0,
			visible = false
		})
	end

	self.tip:visible(visible == true)

	return 
end

return btnMove
