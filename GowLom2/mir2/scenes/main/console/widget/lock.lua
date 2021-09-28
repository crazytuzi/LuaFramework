local cx = 62
local cy = 45
local labelx = 23
local labely = 96
local hpx = 25
local hpy = 105
local green = cc.c3b(0, 255, 0)
local white = cc.c3b(255, 255, 255)
local lock = class("widget.lock", function ()
	return display.newNode()
end)

table.merge(slot8, {
	roleNameLabel,
	roleHPLabel,
	isSelect,
	target,
	skill
})

lock.queryTarRoleInfo = function (self)
	if not self.tarRoleID then
		return 
	end

	local role = main_scene.ground.map:findRole(self.tarRoleID)

	if not role then
		self.tarRoleID = nil

		return 
	end

	if role.__cname ~= "hero" then
		return 
	end

	self.roleNameLabel:stopAllActions()
	self.roleNameLabel:runs({
		cc.ScaleTo:create(0.1, 1.5),
		cc.ScaleTo:create(0.1, 1)
	})

	if g_data.client:checkLastTime("queryOther", 1) then
		g_data.client:setLastTime("queryOther", true)

		local rsb = DefaultClientMessage(CM_QUERYUSERSTATE)
		rsb.FPlayerByID = role.roleid

		MirTcpClient:getInstance():postRsb(rsb)
	else
		main_scene.ui:tip("你查看太快了!!!")
	end

	return 
end
lock.ctor = function (self, config, data)
	self.setNodeEventEnabled(self, true)

	self.bgSpr = res.get2("pic/console/lock_bg.png"):pos(cx, cy):add2(self)

	self.bgSpr:anchor(cx/self.bgSpr:getw(), cy/self.bgSpr:geth()):enableClick(function ()
		local b = self:isEnable()

		if b then
			self:stop()
		else
			self:startSelect()
		end

		return 
	end)
	self.anchor(cx, 0.5, 0.5):pos(data.x, data.y):size(self.bgSpr:getContentSize())

	self.lockSpr = res.get2("pic/console/lock.png"):pos(cx + 1, cy + 1):add2(self)
	self.lockSkillText = res.get2("pic/console/lock-single.png"):pos(cx, cy - 20):add2(self):hide()
	self.roleNameLabel = an.newLabel("", 18, 1, {
		color = green
	}):anchor(0, 0.5):pos(labelx, labely):add2(self)
	self.hpSpr, self.hpBg = self.createHpSpr(self)
	self.roleHPLabel = an.newLabel("", 14, 1, {
		color = white
	}):add2(self.hpBg):anchor(0.5, 0.5)
	local lblhpx = self.hpBg:getw()/2
	local lblhpy = self.hpBg:geth()/2

	self.roleHPLabel:pos(lblhpx, lblhpy)
	self.hideRoleHP(self)

	local function callback(x, y)
		self:queryTarRoleInfo()

		return 
	end

	display.newNode().anchor(slot6, 0, 0.5):pos(self.roleNameLabel:getPosition()):size(self.bgSpr:getw(), 42):add2(self):enableClick(callback)

	self.exLabels = {}
	self.target = {}
	self.skill = {}

	g_data.eventDispatcher:addListener("TARGET_HP_CHANGE", self, self.handleTarHPChange)

	return 
end
lock.stop = function (self)
	self.skill = {}
	self.target = {}
	self.isSelect = nil
	self.tarRoleID = nil

	self.setActionType(self)
	self.setRoleName(self)
	main_scene.ui.console.skills:select()
	self.uptEnable(self)

	return 
end
lock.startSelect = function (self)
	self.isSelect = true

	self.setActionType(self, "lock")
	self.setRoleName(self, "<请选择锁定目标>")
	self.uptEnable(self)

	return 
end
lock.cancelSelect = function (self)
	self.target.select = nil
	self.isSelect = nil

	return 
end
lock.setSelectTarget = function (self, role)
	if not role then
		return 
	end

	if self.target.select == role.roleid then
		main_scene.ui:tip("目标已锁定，请选择攻击方式", 6)
	else
		if not self.isSelect then
			self.startSelect(self)
		end

		self.target.select = role.roleid

		self.setRoleName(self, self.getRoleName(self, role), role.roleid)
	end

	if main_scene.ui.console.controller.quickGroup and role.__cname == "hero" then
		g_data.client:setLastTime("group", true)

		if #g_data.player.groupMembers == 0 then
			local rsb = DefaultClientMessage(CM_CreateGroup)
			rsb.FName = role.info:getName()

			MirTcpClient:getInstance():postRsb(rsb)
		else
			local rsb = DefaultClientMessage(CM_AddGroupMember)
			rsb.FName = role.info:getName()

			MirTcpClient:getInstance():postRsb(rsb)
		end
	end

	return 
end
lock.setAttackTarget = function (self, role)
	self.target.attack = role and role.roleid

	if self.target.attack then
		self.setActionType(self, "attack")
		self.setRoleName(self, self.getRoleName(self, role), role.roleid)

		if role.getRace(role) == 0 and g_data.player:getHasGuild() and g_data.setting.base.guild and g_data.client:checkLastTime("guild", 10) then
			g_data.client:setLastTime("guild", true)

			local player = main_scene.ground.player
			local str = "我正在[" .. g_data.map.mapTitle .. "]坐标:[" .. player.x .. "," .. player.y .. "]与[" .. self.getRoleName(self, role) .. "]进行战斗"
			local rsb = DefaultClientMessage(CM_SAY)
			rsb.FChannelType = 1
			rsb.FRecverName = ""
			rsb.FSayBuf = str
			rsb.FBoSpecSay = false

			MirTcpClient:getInstance():postRsb(rsb)
		end
	elseif not self.skill.enable and not self.isSelect then
		self.setActionType(self)
		self.setRoleName(self)
	end

	self.uptEnable(self)

	return 
end
lock.setSkillTarget = function (self, role)
	self.target.skill = role.roleid

	self.setRoleName(self, self.getRoleName(self, role), role.roleid)

	return 
end
lock.useSkill = function (self, data, config)
	self.skill.enable = true
	self.skill.data = data
	self.skill.config = config
	local skillID = data.FMagicId
	local skilltype = (checkExist("area", config.type) and "mutil") or "single"

	self.setActionType(self, "skill", skillID, skilltype)

	self.target.skill = self.target.skill or self.target.select or self.target.attack
	local single_skill = {
		1,
		5,
		11,
		20,
		32,
		35,
		39,
		6,
		13,
		48,
		64,
		65
	}

	if self.target.skill then
		local role = main_scene.ground.map:findRole(self.target.skill)
		self.tarRoleID = nil

		if role then
			self.setRoleName(self, self.getRoleName(self, role), role.roleid)
		else
			self.setRoleName(self, "<目标失去>")
		end
	elseif checkExist(skillID, unpack(single_skill)) then
		local role = main_scene.ground.map:findNearMon()

		if role then
			if not role.isHaveMaster then
				self.setSkillTarget(self, role)
			end
		else
			self.target.skill = nil

			main_scene.ui:tip("附近没有怪物")
			self.setRoleName(self, "<请选择技能目标>")
		end
	else
		self.setRoleName(self, "<请选择技能目标>")
	end

	self.uptEnable(self)

	return 
end
lock.skillTargetDie = function (self)
	self.tarRoleID = nil
	self.target.skill = nil

	self.setRoleName(self, "<请选择技能目标>")
	self.hideRoleHP(self)

	return 
end
lock.isEnable = function (self)
	return self.target.attack or self.skill.enable or self.isSelect
end
lock.uptEnable = function (self)
	local b = self.isEnable(self)

	self.bgSpr:stopAllActions()

	if b then
		self.bgSpr:rotateTo(0.15, 90)
	else
		self.bgSpr:rotateTo(0.15, 0)
		self.hideRoleHP(self)
	end

	return 
end
lock.setActionType = function (self, type, skillid, skilltype)
	if not type then
		self.lockSkillText:hide()
		self.lockSpr:setTex(res.gettex2("pic/console/lock.png"))
	elseif type == "attack" then
		self.lockSkillText:hide()
		self.lockSpr:setTex(res.gettex2("pic/console/skill_base-icons/attack.png"))
	elseif type == "lock" then
		self.lockSkillText:hide()
		self.lockSpr:setTex(res.gettex2("pic/console/skill_base-icons/lock.png"))
	elseif type == "skill" then
		self.lockSkillText:show()
		self.lockSkillText:setTex(res.gettex2("pic/console/lock-" .. skilltype .. ".png"))
		self.lockSpr:setTex(res.gettex2("pic/console/skill-icons/" .. skillid .. ".png"))
	end

	return 
end
lock.setRoleName = function (self, t, roleid)
	local lastTarID = self.tarRoleID

	if lastTarID == nil or roleid ~= lastTarID then
		self.hideRoleHP(self)

		local role = main_scene.ground.map:findRole(roleid)
		local isPlayer = role and role.__cname == "hero"

		if isPlayer then
			self.showRoleInfoLbl(self)
		end
	end

	self.setLabelText(self, self.roleNameLabel, t or "")

	local role = main_scene.ground.map:findRole(roleid)

	if role then
		self.tarRoleID = role.roleid

		if role.info then
			local color = role.info:getNameColor()

			if type(color) == "table" and color.r and color.g and color.b then
				self.roleNameLabel:setColor(color)
			end
		end
	else
		self.roleNameLabel:setColor(green)
	end

	return 
end
lock.createHpSpr = function (self)
	hpBg = res.get2("pic/console/lockbloodbg.png"):anchor(0, 0):pos(hpx, hpy):addto(self)
	local hptex = res.gettex2("pic/console/lockblood.png")

	local function callback(x, y)
		self:queryTarRoleInfo()

		return 
	end

	hpSpr = display.newSprite(hpy):anchor(0, 0):pos(0, 0):addto(hpBg):enableClick(callback)

	return hpSpr, hpBg
end
lock.setHPSpr = function (self, curhp, maxhp)
	if self.hpSpr then
		local value = math.min(1, math.max(curhp/((maxhp == 0 and 1) or maxhp), 0))

		self.hpSpr:setTextureRect(cc.rect(0, 0, self.hpBg:getw()*value, self.hpBg:geth()))
	end

	return 
end
lock.setRoleHP = function (self, curhp, maxhp)
	local role = main_scene.ground.map:findRole(self.tarRoleID)

	if not role then
		self.hideRoleHP(self)

		return 
	end

	if not curhp or not maxhp then
		curhp, maxhp = role.info:getHP()
	end

	if not curhp or not maxhp then
		self.hideRoleHP(self)

		return 
	end

	self.roleHPLabel:setString(curhp .. "/" .. maxhp)
	self.showRoleHP(self)
	self.setHPSpr(self, curhp, maxhp)

	return 
end
lock.showRoleHP = function (self)
	self.roleHPLabel:setVisible(true)
	self.hpBg:setVisible(true)
	self.hpSpr:setVisible(true)

	return 
end
lock.hideRoleHP = function (self)
	self.roleHPLabel:setVisible(false)
	self.hpBg:setVisible(false)
	self.hpSpr:setTextureRect(cc.rect(0, 0, self.hpBg:getw(), self.hpBg:geth()))
	self.hpSpr:setVisible(false)

	return 
end
lock.showRoleInfoLbl = function (self)
	self.showRoleHP(self)
	self.roleHPLabel:setString("<查看信息>")

	return 
end
lock.handleTarHPChange = function (self, params)
	self.setRoleHP(self, params.curhp, params.maxhp)

	return 
end
lock.getRoleName = function (self, role)
	if role.info:getName() then
		return role.info:getName()
	elseif role.__cname == "hero" then
		return "[人物]"
	else
		return "[怪物]"
	end

	return 
end
lock.setLabelText = function (self, label, text)
	label.setString(label, text)

	if label.getw(label) < 80 then
		label.pos(label, labelx + (label.getw(label) - 80)/2, label.getPositionY(label))
	else
		label.pos(label, labelx, label.getPositionY(label))
	end

	return 
end
lock.onExit = function (self)
	print("-----------------------------lock:onExit()-----------------------------")

	return 
end

return lock
