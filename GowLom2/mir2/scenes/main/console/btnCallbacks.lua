local common = import("..common.common")
local magic = import("..common.magic")
local btnCallbacks = class("btnCallbacks")

table.merge(btnCallbacks, {
	console
})

btnCallbacks.ctor = function (self, console)
	self.console = console

	return 
end
btnCallbacks.handle = function (self, btntype, ...)
	self["handle_" .. btntype](self, ...)

	return 
end
btnCallbacks.attack = function (self)
	common.stopAuto()

	local lock = self.console.controller.lock

	if lock.skill.enable then
		lock.skill = {}

		main_scene.ui.console.skills:select()
	end

	if lock.target.skill then
		local role = main_scene.ground.map:findRole(lock.target.skill)

		if role then
			lock.stop(lock)
			lock.setAttackTarget(lock, role)

			return 
		end
	end

	if lock.target.select then
		local role = main_scene.ground.map:findRole(lock.target.select)

		if role then
			lock.stop(lock)
			lock.setAttackTarget(lock, role)

			return 
		end
	end

	if lock.target.attack then
		local role = main_scene.ground.map:findRole(lock.target.attack)

		if role and not role.die then
			return 
		else
			lock.setAttackTarget(lock)
		end
	end

	local role = main_scene.ground.map:findNearMon()

	if role then
		lock.setAttackTarget(lock, role)
	else
		lock.setAttackTarget(lock)
		main_scene.ui:tip("附近没有怪物")
	end

	return 
end
btnCallbacks.autoRat = function (self)
	local myPlayer = main_scene.ground.player

	if not myPlayer or myPlayer.die then
		return 
	end

	if g_data.setting.job.autoSkill.enable then
		self.handle(self, "setting", "btnAutoSkill")
	end

	if self.console.autoRat.enableRat then
		self.console.autoRat:stop()
	else
		self.console.autoRat:enable()
	end

	if btn and btn.btn then
		btn.btn:setIsSelect(self.console.autoRat.enableRat)
	end

	return 
end
btnCallbacks.autoWa = function (self)
	local curState = self.console.controller.autoWa

	common.stopAuto()

	if not curState then
		self.console.controller:toggleWa(true)
		self.console:call("lock", "stop")
	end

	if btn and btn.btn then
		btn.btn:setIsSelect(self.console.controller.autoWa)
	end

	return 
end
btnCallbacks.shiftAttack = function (self)
	local myPlayer = main_scene.ground.player

	self.console.controller:forceAttackTest(myPlayer.dir)

	return 
end
btnCallbacks.handle_normal = function (self, btn)
	sound.playSound("103")

	local key = nil

	if type(btn) == "string" then
		key = btn
	else
		key = btn.config.key
	end

	if key == "btnChat" then
		main_scene.ui:togglePanel("chat")
	else
		if key == "btnHide" then
			local needHides = {
				"rocker",
				"hp",
				"exp",
				"chat",
				"btnChat"
			}

			local function has(key)
				for i, v in ipairs(needHides) do
					if v == key then
						return true
					end
				end

				return 
			end

			btn.isHide = not btn.isHide

			if btn.isHide then
				if btn and btn.btn then
					btn.btn.setTex(slot5, res.gettex2("pic/console/btn_show.png"))
					btn.run(btn, cc.MoveTo:create(0.1, cc.p(btn.data.x, 21)))
				end
			elseif btn and btn.btn then
				btn.btn:setTex(res.gettex2("pic/console/btn_hide.png"))
				btn.run(btn, cc.MoveTo:create(0.1, cc.p(btn.data.x, btn.data.y)))
			end

			for k, v in pairs(self.console.widgets) do
				if (v ~= btn and v.config.class == "btnMove") or has(k) then
					local x, y = nil

					if v.data.btnpos then
						x, y = self.console:btnpos2pos(v.data.btnpos)
					else
						y = v.data.y
						x = v.data.x
					end

					if btn.isHide then
						v.runs(v, {
							cc.MoveTo:create(0.1, cc.p(x, y + 50)),
							cc.MoveTo:create(0.1, cc.p(x, y - display.height))
						})
					else
						v.run(v, cc.MoveTo:create(0.1, cc.p(x, y)))
					end
				end
			end

			return 
		end

		if key ~= "btnHelper" or false then
			if key == "btnGroup" then
				self.console.controller:setQuickGroup()

				if btn and btn.btn then
					btn.btn:setIsSelect(self.console.controller.quickGroup)
				end
			elseif key == "btnPet" then
				if g_data.client:checkLastTime("btnPetState", 3) then
					g_data.client:setLastTime("btnPetState", true)

					local rsb = DefaultClientMessage(CM_Juniority)

					MirTcpClient:getInstance():postRsb(rsb)
				end
			elseif key == "btnFlag" then
				if g_data.player.crossServerState == 1 then
					main_scene.ui:changeFlagState()
				else
					main_scene.ui:tip("跨服沙巴克可用", 6)
				end
			elseif key == "btnHorse" then
				main_scene.ui:changeHorseState()
			elseif key == "btnPet2" then
				main_scene.ui:changePetState()
			elseif key == "btnAutoRat" then
				local myPlayer = main_scene.ground.player

				if not myPlayer or myPlayer.die then
					return 
				end

				if g_data.map.state == 10 then
					main_scene.ui:tip("该地图不能挂机", 4)

					return 
				end

				if g_data.setting.job.autoSkill.enable then
					self.handle(self, "setting", "btnAutoSkill")
				end

				if self.console.autoRat.enableRat then
					self.console.autoRat:stop()
				else
					self.console.autoRat:enable()
					main_scene.ui:autoBindDrug(true)
				end

				if btn and btn.btn then
					btn.btn:setIsSelect(self.console.autoRat.enableRat)
				end
			elseif key == "btnAutoRat2" then
				local myPlayer = main_scene.ground.player

				if not myPlayer or myPlayer.die then
					return 
				end

				if g_data.setting.job.autoSkill.enable then
					self.handle(self, "setting", "btnAutoSkill")
				end

				if self.console.autoRat.enableRat then
					self.console.autoRat:stop()
				else
					self.console.autoRat:enable()
				end

				if btn and btn.btn then
					btn.btn:setIsSelect(self.console.autoRat.enableRat)
				end
			elseif key == "btnFlyShoe" then
				main_scene.ui:togglePanel("flyshoe")
			elseif key == "btnHostility" then
				g_data.eventDispatcher:dispatch("SELECT_HOSTILITY")
			elseif key == "btnChkSvr1" then
				self.autoRat(self)
			elseif key == "btnChkSvr2" then
				self.attack(self)
			elseif key == "btnChkSvr3" then
				main_scene.ui:togglePanel("chksvrPanel", {
					title = "审核服UI1",
					bg = "bg1"
				})
			elseif key == "btnChkSvr4" then
				main_scene.ui:togglePanel("chksvrPanel", {
					title = "审核服UI2",
					bg = "bg2"
				})
			elseif key == "btnChkSvr5" then
				main_scene.ui:togglePanel("chksvrPanel", {
					title = "审核服UI3",
					bg = "bg3"
				})
			elseif key == "btnChkSvr6" then
				main_scene.ui:togglePanel("chksvrPanel", {
					title = "审核服UI4",
					bg = "bg4"
				})
			elseif key == "btnChkSvrHead" then
				main_scene.ui:togglePanel("chksvrPanel", {
					title = "审核服UI4",
					bg = "bg4"
				})
			elseif key == "btnChkSvr7" then
				self.autoWa(self)
			elseif key == "btnChkSvr8" then
				self.shiftAttack(self)
			elseif key == "btnChkRecharge" then
				main_scene.ui:togglePanel("chkRechargePanel")
			end
		end
	end
end
btnCallbacks.handle_base = function (self, btn)
	local key = nil

	if type(btn) == "string" then
		key = btn
	else
		key = btn.config.btnid
	end

	if key == "attack" then
		common.stopAuto()

		local lock = self.console.controller.lock

		if lock.skill.enable then
			lock.skill = {}

			main_scene.ui.console.skills:select()
		end

		if lock.target.skill then
			local role = main_scene.ground.map:findRole(lock.target.skill)

			if role then
				lock.stop(lock)
				lock.setAttackTarget(lock, role)

				return 
			end
		end

		if lock.target.select then
			local role = main_scene.ground.map:findRole(lock.target.select)

			if role then
				lock.stop(lock)
				lock.setAttackTarget(lock, role)

				return 
			end
		end

		if lock.target.attack then
			local role = main_scene.ground.map:findRole(lock.target.attack)

			if role and not role.die then
				return 
			else
				lock.setAttackTarget(lock)
			end
		end

		local role = main_scene.ground.map:findNearMon()

		if role then
			lock.setAttackTarget(lock, role)
		else
			lock.setAttackTarget(lock)
			main_scene.ui:tip("附近没有怪物")
		end
	elseif key == "lock" then
		if not btn.looks then
			btn.looks = {}
		end

		local roles = {}

		for k, v in pairs(main_scene.ground.map.heros) do
			if not v.die and not v.isPlayer and not v.isDummy then
				roles[#roles + 1] = v
			end
		end

		for k, v in pairs(main_scene.ground.map.mons) do
			if not v.die and not v.isPolice(v) and not v.isDummy and v.isHaveMaster == false then
				roles[#roles + 1] = v
			end
		end

		table.sort(roles, function (a, b)
			return main_scene.ground.player:getDis(a) < main_scene.ground.player:getDis(b)
		end)

		local choose = nil

		for i, v in ipairs(slot3) do
			if not btn.looks[v.roleid] then
				btn.looks[v.roleid] = true
				choose = v

				break
			end
		end

		if not choose then
			btn.looks = {}

			if 0 < #roles then
				btn.looks[roles[1].roleid] = true
				choose = roles[1]
			end
		end

		local lock = self.console.controller.lock

		lock.stop(lock)

		if choose then
			lock.setSelectTarget(lock, choose)
		else
			main_scene.ui:tip("附近没有人物或怪物.")
		end
	elseif key == "shift" then
		local curState = self.console.controller.openShift

		common.stopAuto()

		if not curState then
			self.console.controller:toggleShift(true)
			self.console:call("lock", "stop")
		end

		if btn and btn.btn then
			btn.btn:setIsSelect(self.console.controller.openShift)
		end
	elseif key == "wa" then
		local curState = self.console.controller.autoWa

		common.stopAuto()

		if not curState then
			self.console.controller:toggleWa(true)
			self.console:call("lock", "stop")
		end

		if btn and btn.btn then
			btn.btn:setIsSelect(self.console.controller.autoWa)
		end
	elseif key == "back" then
		common.backHome()
	end

	return 
end
btnCallbacks.handle_setting = function (self, btn)
	local key = nil

	if type(btn) == "string" then
		key = btn
	else
		key = btn.config.key
	end

	local enable, settingKey = nil

	if key == "btnHeroName" then
		g_data.setting.base.heroShowName = not g_data.setting.base.heroShowName
		enable = g_data.setting.base.heroShowName
		settingKey = "heroShowName"
		local map = main_scene.ground.map

		for k, v in pairs(map.heros) do
			v.info:setName(v.info.name.texts, true)
		end
	elseif key == "btnNPCShowName" then
		g_data.setting.base.NPCShowName = not g_data.setting.base.NPCShowName
		enable = g_data.setting.base.NPCShowName
		settingKey = "NPCShowName"
		local map = main_scene.ground.map

		for k, v in pairs(map.npcs) do
			v.info:setName(v.info.name.texts, true)
		end
	elseif key == "btnPetShowName" then
		g_data.setting.base.petShowName = not g_data.setting.base.petShowName
		enable = g_data.setting.base.petShowName
		settingKey = "petShowName"
		local map = main_scene.ground.map

		for k, v in pairs(map.heros) do
			v.info:setName(v.info.name.texts, true)
		end

		for k, v in pairs(map.mons) do
			v.info:setName(v.info.name.texts, true)
		end
	elseif key == "btnMonShowName" then
		g_data.setting.base.monShowName = not g_data.setting.base.monShowName
		enable = g_data.setting.base.monShowName
		settingKey = "monShowName"
		local map = main_scene.ground.map

		for k, v in pairs(map.mons) do
			v.info:setName(v.info.name.texts, true)
		end
	elseif key == "btnOnlyname" then
		g_data.setting.base.showNameOnly = not g_data.setting.base.showNameOnly
		enable = g_data.setting.base.showNameOnly
		settingKey = "showNameOnly"
		local map = main_scene.ground.map

		for k, v in pairs(map.heros) do
			v.info:setName(v.info.name.texts)
		end
	elseif key == "btnHeroTitle" then
		g_data.setting.base.heroShowTitle = not g_data.setting.base.heroShowTitle
		enable = g_data.setting.base.heroShowTitle
		settingKey = "heroShowTitle"
		local map = main_scene.ground.map

		for k, v in pairs(map.heros) do
			v.info:setTitle(v.info.title.texts, true)
		end
	elseif key == "equipBarLvl" then
		g_data.setting.base.equipBarLvl = not g_data.setting.base.equipBarLvl
		enable = g_data.setting.base.equipBarLvl
		settingKey = "equipBarLvl"
		local equip = main_scene.ui.panels.equip

		if equip and equip.page == "equip" and equip.lblEquipBarTips then
			local lvlStr = ""

			for k, v in pairs(equip.lblEquipBarTips) do
				if g_data.setting.base.equipBarLvl then
					lvlStr = "+" .. g_data.equipGrid:getEquipBarLvlById(k)
				else
					lvlStr = "     "
				end

				v.setString(v, lvlStr)
			end
		end

		local equipOther = main_scene.ui.panels.equipOther

		if equipOther and equipOther.currentPage == "equip" and equipOther.lblEquipBarTips then
			local lvlStr = ""

			for k, v in pairs(equipOther.lblEquipBarTips) do
				if g_data.setting.base.equipBarLvl then
					lvlStr = "+" .. g_data.equipGrid:getBarLvlWithOtherBar(equipOther.equipBarInfo.barInfoList, k)
				else
					lvlStr = "     "
				end

				v.setString(v, lvlStr)
			end
		end
	elseif key == "hiBlood" then
		g_data.setting.base.hiBlood = not g_data.setting.base.hiBlood
		enable = g_data.setting.base.hiBlood
		settingKey = "hiBlood"
	elseif key == "btnDelayShow" then
		g_data.setting.base.DelayShow = not g_data.setting.base.DelayShow
		enable = g_data.setting.base.DelayShow
		settingKey = "DelayShow"

		if enable then
			main_scene.ui:delayLabelShow()
		else
			main_scene.ui:delayLabelHide()
		end
	elseif key == "defeatTip" then
		g_data.setting.base.defeatTip = not g_data.setting.base.defeatTip
		enable = g_data.setting.base.defeatTip
		settingKey = "defeatTip"
	elseif key == "showExpEnable" then
		g_data.setting.base.showExpEnable = not g_data.setting.base.showExpEnable
		enable = g_data.setting.base.showExpEnable
		settingKey = "showExpEnable"
	elseif key == "lockColor" then
		g_data.setting.base.lockColor = not g_data.setting.base.lockColor
		enable = g_data.setting.base.lockColor
		settingKey = "lockColor"
	elseif key == "btnTouchRun" then
		g_data.setting.base.touchRun = not g_data.setting.base.touchRun
		enable = g_data.setting.base.touchRun
		settingKey = "touchRun"

		self.console.controller:setTouchRun(enable)
	elseif key == "btnShowOutHP" then
		g_data.setting.base.showOutHP = not g_data.setting.base.showOutHP
		enable = g_data.setting.base.showOutHP
		settingKey = "showOutHP"
	elseif key == "btnSingleRocker" then
		g_data.setting.base.singleRocker = not g_data.setting.base.singleRocker
		enable = g_data.setting.base.singleRocker
		settingKey = "singleRocker"
		local rType = (enable and 1) or 2

		main_scene.ui.console:call("rocker", "setRockerType", rType)
	elseif key == "btnDoubleRocker" then
		g_data.setting.base.doubleRocker = not g_data.setting.base.doubleRocker
		enable = g_data.setting.base.doubleRocker
		settingKey = "doubleRocker"
		local rType = (enable and 2) or 1

		main_scene.ui.console:call("rocker", "setRockerType", rType)
	elseif key == "btnSoundEnable" then
		g_data.setting.base.soundEnable = not g_data.setting.base.soundEnable
		enable = g_data.setting.base.soundEnable
		settingKey = "soundEnable"

		sound.setEnable(enable)
	elseif key == "btnHideCorpse" then
		g_data.setting.base.hideCorpse = not g_data.setting.base.hideCorpse
		enable = g_data.setting.base.hideCorpse
		settingKey = "hideCorpse"
		local map = main_scene.ground.map

		for k, v in pairs(map.heros) do
			v.uptSelfShow(v)
		end

		for k, v in pairs(map.mons) do
			v.uptSelfShow(v)
		end
	elseif key == "btnfirePeral" then
		g_data.setting.base.firePeral = not g_data.setting.base.firePeral
		enable = g_data.setting.base.firePeral
		settingKey = "firePeral"
	elseif key == "btnguild" then
		g_data.setting.base.guild = not g_data.setting.base.guild
		enable = g_data.setting.base.guild
		settingKey = "guild"
	elseif key == "btnquickexit" then
		g_data.setting.base.quickexit = not g_data.setting.base.quickexit
		enable = g_data.setting.base.quickexit
		settingKey = "quickexit"
	elseif key == "btnautoUnpack" then
		g_data.setting.base.autoUnpack = not g_data.setting.base.autoUnpack
		enable = g_data.setting.base.autoUnpack
		settingKey = "autoUnpack"
	elseif key == "btnHighFrame" then
		g_data.setting.base.highFrame = not g_data.setting.base.highFrame
		enable = g_data.setting.base.highFrame
		settingKey = "btnHighFrame"

		if enable then
			cc.Director:getInstance():setAnimationInterval(0.016666666666666666)
		else
			cc.Director:getInstance():setAnimationInterval(0.03333333333333333)
		end
	elseif key == "btnAutoFire" then
		g_data.setting.job.autoFire = not g_data.setting.job.autoFire
		enable = g_data.setting.job.autoFire
		settingKey = "autoFire"

		if g_data.setting.job.autoFire then
			main_scene.ui:tip("自动烈火已开启")
		else
			main_scene.ui:tip("自动烈火已关闭")
		end
	elseif key == "btnAutoWide" then
		g_data.setting.job.autoWide = not g_data.setting.job.autoWide
		enable = g_data.setting.job.autoWide
		settingKey = "autoWide"

		if g_data.setting.job.autoWide then
			main_scene.ui:tip("智能半月已开启")
		else
			main_scene.ui:tip("智能半月已关闭")
		end
	elseif key == "btnAutoAllSpace" then
		g_data.setting.job.autoAllSpace = not g_data.setting.job.autoAllSpace
		enable = g_data.setting.job.autoAllSpace
		settingKey = "autoAllSpace"
	elseif key == "btnAutoSword" then
		g_data.setting.job.autoSword = not g_data.setting.job.autoSword
		enable = g_data.setting.job.autoSword
		settingKey = "autoSword"

		if g_data.setting.job.autoSword then
			main_scene.ui:tip("逐日剑法已开启")
		else
			main_scene.ui:tip("逐日剑法已关闭")
		end
	elseif key == "btnSpaceHit" then
		g_data.setting.job.spaceHit = not g_data.setting.job.spaceHit
		enable = g_data.setting.job.spaceHit
		settingKey = "btnSpaceHit"

		if enable then
			self.console.autoRat:stop()
		end

		if g_data.setting.job.spaceHit then
			main_scene.ui:tip("隔位刺杀已开启")
		else
			main_scene.ui:tip("隔位刺杀已关闭")
		end
	elseif key == "btnAutoSpace" then
		g_data.setting.job.autoSpace = not g_data.setting.job.autoSpace
		enable = g_data.setting.job.autoSpace
		settingKey = "autoSpace"
	elseif key == "btnAutoDun" then
		g_data.setting.job.autoDun = not g_data.setting.job.autoDun
		enable = g_data.setting.job.autoDun
		settingKey = "autoDun"

		if g_data.setting.job.autoDun then
			main_scene.ui:tip("自动魔法盾已开启")
		else
			main_scene.ui:tip("自动魔法盾已关闭")
		end
	elseif key == "btnautoDunHero" then
		g_data.setting.job.autoDunHero = not g_data.setting.job.autoDunHero
		enable = g_data.setting.job.autoDunHero
		settingKey = "autoDunHero"
	elseif key == "btnAutoInvisible" then
		g_data.setting.job.autoInvisible = not g_data.setting.job.autoInvisible
		enable = g_data.setting.job.autoInvisible
		settingKey = "autoInvisible"

		if g_data.setting.job.autoInvisible then
			main_scene.ui:tip("自动隐身已开启")
		else
			main_scene.ui:tip("自动隐身已关闭")
		end
	elseif key == "btnAutoSkill" then
		g_data.setting.job.autoSkill.enable = not g_data.setting.job.autoSkill.enable
		enable = g_data.setting.job.autoSkill.enable
		settingKey = "autoSkill"

		if g_data.setting.job.autoSkill.enable then
			main_scene.ui:tip("自动练功已开启")
		else
			main_scene.ui:tip("自动练功已关闭")
		end
	elseif key == "btnAutoSpaceMove" then
		g_data.setting.autoRat.autoSpaceMove.enable = not g_data.setting.autoRat.autoSpaceMove.enable
		enable = g_data.setting.autoRat.autoSpaceMove.enable
		settingKey = "autoSpaceMove"
	elseif key == "btnNoPickUpItem" then
		g_data.setting.autoRat.noPickUpItem = not g_data.setting.autoRat.noPickUpItem
		enable = g_data.setting.autoRat.noPickUpItem
		settingKey = "btnNoPickUpItem"
	elseif key == "btnPickUpGood" then
		g_data.setting.autoRat.pickUpRatting = not g_data.setting.autoRat.pickUpRatting
		enable = g_data.setting.autoRat.pickUpRatting
		settingKey = "btnPickUpGood"
	elseif key == "btnIgnoreCripple" then
		g_data.setting.autoRat.ignoreCripple = not g_data.setting.autoRat.ignoreCripple
		enable = g_data.setting.autoRat.ignoreCripple
		settingKey = "btnIgnoreCripple"
	elseif key == "btnAutoRoar" then
		g_data.setting.autoRat.autoRoar.enable = not g_data.setting.autoRat.autoRoar.enable
		enable = g_data.setting.autoRat.autoRoar.enable
		settingKey = "btnAutoRoar"
	elseif key == "btnAtkMagic" then
		g_data.setting.autoRat.atkMagic.enable = not g_data.setting.autoRat.atkMagic.enable
		enable = g_data.setting.autoRat.atkMagic.enable
		settingKey = "btnAtkMagic"
	elseif key == "btnareaMagic" then
		g_data.setting.autoRat.areaMagic.enable = not g_data.setting.autoRat.areaMagic.enable
		enable = g_data.setting.autoRat.areaMagic.enable
		settingKey = "btnareaMagic"
	elseif key == "btnAutoPoison" then
		g_data.setting.autoRat.autoPoison = not g_data.setting.autoRat.autoPoison
		enable = g_data.setting.autoRat.autoPoison
		settingKey = "btnAutoPoison"

		if g_data.setting.autoRat.autoPoison then
			main_scene.ui:tip("自动施毒已开启")
		else
			main_scene.ui:tip("自动施毒已关闭")
		end
	elseif key == "btnAutoZhanjiashu" then
		g_data.setting.job.autoZhanjiashu = not g_data.setting.job.autoZhanjiashu
		enable = g_data.setting.job.autoZhanjiashu
		settingKey = "btnAutoZhanjiashu"

		if g_data.setting.job.autoZhanjiashu then
			main_scene.ui:tip("自动神圣战甲术已开启")
		else
			main_scene.ui:tip("自动神圣战甲术已关闭")
		end
	elseif key == "btnCureOther" then
		g_data.setting.job.btnCureOther = not g_data.setting.job.btnCureOther
		enable = g_data.setting.job.btnCureOther
		settingKey = "btnCureOther"

		if g_data.setting.job.btnCureOther then
			main_scene.ui:tip("对他人治愈术已开启")
		else
			main_scene.ui:tip("对他人治愈术已关闭")
		end
	elseif key == "btnAutoPet" then
		g_data.setting.autoRat.autoPet.enable = not g_data.setting.autoRat.autoPet.enable
		enable = g_data.setting.autoRat.autoPet.enable
		settingKey = "btnAutoPet"
	elseif key == "btnAutoCure" then
		g_data.setting.autoRat.autoCure.enable = not g_data.setting.autoRat.autoCure.enable
		enable = g_data.setting.autoRat.autoCure.enable
		settingKey = "btnAutoCure"
	elseif key == "btnAutoCurePet" then
		g_data.setting.autoRat.autoCurePet.enable = not g_data.setting.autoRat.autoCurePet.enable
		enable = g_data.setting.autoRat.autoCurePet.enable
		settingKey = "btnAutoCurePet"
	elseif key == "btnAutoSkillAndAttack" then
		g_data.setting.autoRat.autoSkillAndAttack = not g_data.setting.autoRat.autoSkillAndAttack
		enable = g_data.setting.autoRat.autoSkillAndAttack
		settingKey = "btnAutoSkillAndAttack"
	elseif key == "btnAutoBindDrug" then
		g_data.setting.autoRat.autoBindDrug = not g_data.setting.autoRat.autoBindDrug
		enable = g_data.setting.autoRat.autoBindDrug

		main_scene.ui:autoBindDrug()

		settingKey = "btnAutoBindDrug"
	end

	local btn = self.console:get(key)

	if btn then
		btn.btn:setIsSelect(enable)
	end

	if main_scene.ui.panels.setting and main_scene.ui.panels.setting.btns[settingKey] then
		if enable then
			main_scene.ui.panels.setting.btns[settingKey].btn:select()
		else
			main_scene.ui.panels.setting.btns[settingKey].btn:unselect()
		end
	end

	return 
end
btnCallbacks.handle_cmd = function (self, btn)
	local function sendCmd(cmd)
		if g_data.client:checkLastTime("sendCmd", 0.5) then
			g_data.client:setLastTime("sendCmd", true)
			common.sendGMCmd(cmd)
		else
			main_scene.ui:tip("你操作太快了!!!")
		end

		return 
	end

	if btn.config.btnid == "chuansong" then
		local config = nil

		for i, v in ipairs(def.cmds.all) do
			if v[1] == "@传送" then
				config = slot8

				break
			end
		end

		if config then
			local msgbox = nil
			slot5 = an.newMsgbox(config[1] .. "\n" .. config[4], function ()
				if msgbox.input:getString() == "" then
					return 
				end

				if g_data.client:checkLastTime("sendCmd", 0.5) then
					g_data.client:setLastTime("sendCmd", true)

					local cmd = config[2] .. " " .. msgbox.input:getString()

					common.sendGMCmd(cmd)
				else
					main_scene.ui:tip("你操作太快了!!!")
				end

				return 
			end, {
				disableScroll = true,
				input = 20
			})
			msgbox = slot5

			msgbox.input:setString("d5071")
			msgbox.input:startInput()
		end

		return 
	end

	if (btn.config.btnid ~= "qianlichuanyin" or false) and (btn.config.btnid ~= "shuaxinbeibao" or false) then
		if btn.config.btnid == "jujuesiliao" then
			sendCmd(def.cmds.get("@拒绝私聊"))
		elseif btn.config.btnid == "jinzhijiaoyi" then
			sendCmd(def.cmds.get("@禁止交易"))
		elseif btn.config.btnid == "shituchuansong" then
			sendCmd(def.cmds.get("@师徒传送"))
		elseif btn.config.btnid == "fuqichuansong" then
			sendCmd(def.cmds.get("@夫妻传送"))
		end
	end
end
btnCallbacks.handle_panel = function (self, btn)
	local key = nil

	if type(btn) == "string" then
		key = btn
	else
		key = btn.config.btnid
	end

	if key == "bag" then
		if main_scene.ui:isPanelVisible("tradeshop") then
			main_scene.ui:tip("不能打开背包")
		else
			main_scene.ui:togglePanel("bag")
		end
	elseif key == "ebag" then
		main_scene.ui:togglePanel("bag", 1)
	elseif key == "equip" then
		main_scene.ui:togglePanel("equip")
	elseif key == "skill" then
		main_scene.ui:togglePanel("equip", {
			page = "skill"
		})
	elseif key == "trade" then
		if g_data.player:getIsCrossServer() then
			main_scene.ui:tip("该功能不能使用")

			return 
		end

		main_scene.ui:togglePanel("secondMenu", {
			"trade",
			1,
			btn
		})
	elseif key == "deal" then
		if g_data.player:getIsCrossServer() then
			main_scene.ui:tip("该功能不能使用")

			return 
		end

		if g_data.client:checkLastTime("deal", 3) then
			g_data.client:setLastTime("deal", true)

			local rsb = DefaultClientMessage(CM_F2F_DEAL)
			rsb.dealStatus = 0

			MirTcpClient:getInstance():postRsb(rsb)
		end
	elseif key == "community" then
		main_scene.ui:togglePanel("secondMenu", {
			"community",
			3,
			btn
		})
	elseif key == "group" then
		main_scene.ui:togglePanel("group")
	elseif key == "relation" then
		main_scene.ui:togglePanel("relation", 1)
	elseif key == "guild" then
		if g_data.client:checkLastTime("guild", 2) then
			g_data.client:setLastTime("guild", true)
			main_scene.ui:showPanel("guild", "")
		else
			an.newMsgbox("你操作太快了, 请稍候再试.")
		end
	elseif key == "shop" then
		main_scene.ui:togglePanel("shop", 1)
	elseif key == "recharge" then
		if g_data.player:getIsCrossServer() then
			main_scene.ui:tip("该功能不能使用")

			return 
		end

		if g_data.login:getServerType() == 1 then
			main_scene.ui:togglePanel("chkCharge")
		else
			main_scene.ui:togglePanel("shop", 2)
		end
	elseif key == "chargegift" then
		if g_data.player:getIsCrossServer() then
			main_scene.ui:tip("该功能不能使用")

			return 
		end

		if main_scene.ui:isPanelVisible("activity") then
			main_scene.ui:hidePanel("activity")
		else
			main_scene.ui:togglePanel("activity", {
				dftab2 = 1104
			})

			local rsb = DefaultClientMessage(CM_Act_DetailRequest)
			rsb.FActId = 0
			rsb.FParamA = 0
			rsb.FParamB = 0
			rsb.FStrParam = "tab1"

			MirTcpClient:getInstance():postRsb(rsb)
		end
	elseif key == "picIdentify" then
		if g_data.player:getIsCrossServer() then
			main_scene.ui:tip("该功能不能使用")

			return 
		end

		main_scene.ui:togglePanel("picIdentify")
	elseif key == "top" then
		if g_data.player:getIsCrossServer() then
			main_scene.ui:tip("该功能不能使用")

			return 
		end

		main_scene.ui:togglePanel("top")
	elseif key == "stall" then
		main_scene.ui:tip("功能暂未开放")
	elseif key == "ybdeal" then
		main_scene.ui:tip("功能暂未开放")
	elseif key == "mail" then
		main_scene.ui:togglePanel("mail")
	elseif key == "voice" then
		main_scene.ui:togglePanel("voice")
	elseif key == "setting" then
		main_scene.ui:togglePanel("setting")
	elseif key == "activity" then
		if main_scene.ui:isPanelVisible("activity") then
			main_scene.ui:hidePanel("activity")
		else
			if g_data.player:getIsCrossServer() then
				main_scene.ui:tip("该功能不能使用")

				return 
			end

			local rsb = DefaultClientMessage(CM_Act_DetailRequest)
			rsb.FActId = 0
			rsb.FParamA = 0
			rsb.FParamB = 0
			rsb.FStrParam = "tab1"

			MirTcpClient:getInstance():postRsb(rsb)
			main_scene.ui.waiting:show(10, "ACTIVITY_TAB1")

			main_scene.ui.openActFromPicIdent = false
			g_data.diffPanels.showRMBGiftPageFromNPC = false
			g_data.diffPanels.showMerchantPageFromNPC = false
		end
	elseif key == "weChatRedPacket" then
		sound.playSound("103")
		main_scene.ui:togglePanel(btn.config.btnid, 1)
	elseif key == "weChatRedPacket2" then
		sound.playSound("103")
		main_scene.ui:togglePanel(btn.config.btnid, 1)
	elseif key == "vip" then
		sound.playSound("103")
		main_scene.ui:togglePanel("focusVIPWechat")
	elseif key == "gamecenter" then
		sound.playSound("103")

		if MirSDKAgent:canOpenGameCenter() then
			MirSDKAgent:openGameCenter()
		else
			print("OPPO社区未开启")
		end
	elseif key == "arena" then
		if main_scene.ui:isPanelVisible("arena") then
			main_scene.ui:togglePanel("arena")

			return 
		end

		if g_data.player:getIsCrossServer() then
			main_scene.ui:tip("该功能不能使用")

			return 
		end

		if g_data.map:isInSafeZone(main_scene.ground.map.mapid, main_scene.ground.player.x, main_scene.ground.player.y) then
			local rsb = DefaultClientMessage(CM_ArenaReqList)
			rsb.Fdorefresh = false

			MirTcpClient:getInstance():postRsb(rsb)
		else
			main_scene.ui:tip("在安全区才可以参加跨服竞技")
		end
	end

	return 
end
btnCallbacks.handle_custom = function (self, btn)
	if not btn.makeIndex then
		return 
	end

	local _, data = g_data.bag:getItem(btn.makeIndex)
	local bagData, equipData, eatMsg, takeonMsg = nil
	local isPlayer = true
	local source = nil

	if btn.source == "bag" then
		source = main_scene.ui.panels.bag
		equipData = g_data.equip
		bagData = g_data.bag
		takeonMsg = CM_TAKEONITEM
		eatMsg = CM_EAT
	elseif btn.source == "heroBag" then
		source = main_scene.ui.panels.heroBag
		equipData = g_data.heroEquip
		bagData = g_data.heroBag
		takeonMsg = CM_HERO_TAKEON
		eatMsg = CM_HERO_EAT
	end

	local where = getTakeOnPosition(data.getVar(data, "stdMode"))

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
		end

		if self.canUseEquip(self, data, bagData, isPlayer) and bagData.use(bagData, "take", data.FItemIdent, {
			where = where
		}) then
			local rsb = DefaultClientMessage(CM_TAKEONITEM)
			rsb.FWhere = where
			rsb.FItemIdent = data.FItemIdent

			MirTcpClient:getInstance():postRsb(rsb)

			if source then
				source.delItem(source, data.FItemIdent)
			end
		end
	else
		if equipIdx then
			return 
		end

		if not self.canUseEquip(self, data, bagData, isPlayer) then
			return 
		end

		local function use()
			if bagData:use("eat", data.FItemIdent) then
				local rsb = DefaultClientMessage(eatMsg)
				rsb.FItemIdent = data.FItemIdent
				rsb.FUseType = 0

				MirTcpClient:getInstance():postRsb(rsb)

				if source then
					source:delItem(data.FItemIdent)
				end
			end

			return 
		end

		if data.getVar(slot3, "stdMode") == 4 then
			an.newMsgbox(string.format("[%s] 你想要开始训练吗? ", data.getVar(data, "name")), function (isOk)
				if isOk == 1 then
					use()
				end

				return 
			end, {
				center = true,
				hasCancel = true
			}).setName(slot12, "msgBoxLearnSkill")
		elseif data.getVar(data, "stdMode") == 47 then
			if data.getVar(data, "name") == "传情烟花" then
				local msgbox = nil
				slot13 = an.newMsgbox("请输入传情烟花文字", function (idx)
					if idx == 2 then
						if msgbox.input:getString() == "" then
							return 
						end

						local rsb = DefaultClientMessage(CM_YANHUA_TEXT)
						rsb.FTargetItemIdent = data.FItemIdent
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
				msgbox = slot13
			elseif data.getVar(data, "name") == "金条" then
				an.newMsgbox("确定使用一根金条兑换998000金币吗？\n未验证玩家可携带200万金币。\n已验证玩家可携带5000万金币。", function ()
					if g_data.bag:use("eat", data.FItemIdent, {
						quick = false
					}) then
						local rsb = DefaultClientMessage(eatMsg)
						rsb.FItemIdent = data.FItemIdent
						rsb.FUseType = 0

						MirTcpClient:getInstance():postRsb(rsb)

						if source then
							source:delItem(data.FItemIdent)
						end
					end

					return 
				end, {
					center = true
				})
			end
		else
			slot11()
		end
	end

	return 
end
btnCallbacks.canUseEquip = function (self, item, dataFrom, isPlayer)
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

	if playerData.ability:get("maxHandWeight") < item.getVar(item, "weight") then
		main_scene.ui:tip("腕力不足", 6)

		return false
	end

	if item.getVar(item, "stdMode") == 4 then
		local shape = item.getVar(item, "shape") or 0

		if shape ~= playerData.job then
			main_scene.ui:tip("职业不符", 6)

			return false
		end

		local needLevel = math.modf(Word(item.getVar(item, "duraMax")))

		if playerData.ability.FLevel < needLevel then
			main_scene.ui:tip("等级不足", 6)

			return false
		end
	elseif item.getVar(item, "stdMode") ~= 5 and item.getVar(item, "stdMode") ~= 6 and item.getVar(item, "name") ~= "金条" and playerData.ability.FMaxWeapWgt - playerData.ability.FCurWeapWgt < item.getVar(item, "weight") then
		main_scene.ui:tip("负重不足", 6)

		return false
	end

	return true
end
btnCallbacks.handle_prop = function (self, btn)
	local myPlayer = main_scene.ground.player

	if not myPlayer or myPlayer.die then
		return 
	end

	if not btn.makeIndex then
		return 
	end

	local _, data = g_data.bag:getItem(btn.makeIndex)

	if not data then
		return 
	end

	if g_data.bag:use("eat", data.FItemIdent, {
		quick = true
	}) then
		local multiUse = data.getVar(data, "stdMode") == 2

		if main_scene.ui.panels.bag and not data.isPileUp(data) and not multiUse then
			main_scene.ui.panels.bag:delItem(data.FItemIdent)
		end

		sound.play("item", data)

		local rsb = DefaultClientMessage(CM_EAT)
		rsb.FItemIdent = data.FItemIdent
		rsb.FUseType = 0

		MirTcpClient:getInstance():postRsb(rsb)

		local iName = data.getVar(data, "name")

		if iName == "回城卷" or iName == "行会回城卷" or iName == "地牢逃脱卷" then
			common.stopAuto()
		end

		if iName == "随机传送卷" or iName == "随机传送石" then
			g_data.useRandomSend = true
		end
	end

	return 
end
btnCallbacks.handle_hero = function (self, btn)
	local key = nil

	if type(btn) == "string" then
		key = btn
	else
		key = btn.config.btnid
	end

	if key == "call" then
		if g_data.hero.roleid == 0 then
		end

		return 
	end

	if g_data.hero.roleid == 0 then
		main_scene.ui:tip("您还未召唤出英雄!", 6)

		return 
	end

	if key == "bag" then
		main_scene.ui:togglePanel("heroBag")
	elseif key == "equip" then
		main_scene.ui:togglePanel("heroEquip")
	elseif key ~= "skill" or false then
		if key == "mode" then
			local rsb = DefaultClientMessage(CM_Juniority)

			MirTcpClient:getInstance():postRsb(rsb)
		elseif key == "lock" then
			self.console.controller:closeHeroGuard()
			self.console.controller:toggleHeroLock()

			if btn and btn.btn then
				btn.btn:setIsSelect(self.console.controller.heroLock)
			end
		elseif key == "guard" then
			self.console.controller:closeHeroLock()
			self.console.controller:toggleHeroGuard(btn)

			if btn and btn.btn then
				btn.btn:setIsSelect(self.console.controller.heroGuard)
			end
		end
	end

	return 
end
btnCallbacks.handle_skill = function (self, btn, skillData)
	local player = main_scene.ground.map.player

	if not player then
		return 
	end

	if def.role.isRoleStone(player.state) then
		return 
	end

	local magicID, data = nil

	if type(btn) == "number" then
		magicID = btn
		data = skillData
	else
		magicID = btn.data.magicId
		data = btn.skillData
	end

	magicID = tonumber(magicID)

	if not magicID or not data then
		return 
	end

	if checkExist(magicID, 3, 4, 7, 36, 67, 60, 61, 62) then
		main_scene.ui:tip("该技能为被动技能，无法施放")

		return 
	end

	if g_data.player.ability.FMP < data.FNeedMp then
		main_scene.ui:tip("没有足够的魔法点数")

		return 
	end

	local skillLvl = g_data.player:getMagicLvl(magicID)
	local config = def.magic.getMagicConfigByUid(magicID, skillLvl)

	if not config then
		return 
	end

	if config.type == "immediate" then
		local config = def.role.dir["_" .. player.dir]

		self.console.controller:useMagic(player.x + config[1], player.y + config[2], player.dir, data)

		return 
	end

	local effectType = data.FEffectType

	if effectType == 0 then
		if data.iscdBegin == true then
			print("____skill in cd time__")

			return 
		end

		if g_data.isSkillBegan then
			print("____globe skill in cd time__")

			return 
		end

		local x = player.x
		local y = player.y

		if magicID == 27 or magicID == 63 then
			y = 0
			x = player.dir
		end

		local rsb = DefaultClientMessage(CM_Spell)
		rsb.FMagicId = data.FMagicId
		rsb.FTargUserId = 0
		rsb.FX = x
		rsb.FY = y

		pushRsb2Queue(rsb)

		if type(btn) ~= "number" then
			g_data.client.skillBtns["skillMutex" .. data.FMagicId] = true
		end

		print("________btnCallbacks:handle_skill send success =" .. data.FMagicId .. " _=" .. socket.gettime())
	else
		self.console.skills:select(tostring(magicID))

		if not WIN32_OPERATE then
			self.console:call("lock", "useSkill", data, config)
			self.console.controller:useMagic()
		end
	end

	return 
end
btnCallbacks.changePetState = function (self)
	return 
end

return btnCallbacks
