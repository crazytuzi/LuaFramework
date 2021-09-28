local infoBar = class("infoBar", function ()
	return display.newNode()
end)

table.merge(slot0, {
	bg,
	info = {
		player,
		energy,
		mobile
	},
	default = {
		g = 0,
		a = 255,
		b = 0,
		r = 0
	}
})

local color = {
	origin = cc.c3b(230, 105, 70),
	green = cc.c3b(50, 177, 108),
	golden = cc.c3b(250, 210, 100)
}
infoBar.ctor = function (self, config, data)
	data.r = data.r or self.default.r
	data.g = data.g or self.default.g
	data.b = data.b or self.default.b
	data.a = data.a or self.default.a
	local bgH = 30
	self.bg = display.newScale9Sprite(res.getframe2("pic/console/infobar/top.png"), display.cx, bgH/2, cc.size(display.width, bgH)):add2(self)

	self.size(self, display.width, self.bg:geth()):anchor(0.5, 0.5):pos(data.x, data.y)

	local deviceFix = 30

	if game.deviceFix then
		deviceFix = game.deviceFix - 10
	end

	self.state = an.newBtn(res.gettex2("pic/common/state.png"), function ()
		self:switch()
		self:showActiveType(nil, -1)

		return 
	end, {
		size = cc.size(60, self.geth(color))
	}):addTo(self):pos(deviceFix, self.geth(self)/2):anchor(0.5, 0.5)
	local cfg = {
		player = {
			gold = {
				type = "label",
				icon = true
			},
			yb = {
				type = "label",
				icon = true
			},
			sycee = {
				type = "label",
				icon = true
			},
			credit = {
				type = "label",
				icon = true
			},
			creditAuthen = {
				type = "label"
			}
		},
		energy = {
			active = {
				value = 1,
				bg = true,
				type = "label"
			},
			stamina = {
				value = 2,
				bg = true,
				type = "label"
			},
			exp = {
				value = 3,
				bg = true,
				type = "label"
			},
			blood = {
				value = 4,
				bg = true,
				type = "label"
			}
		},
		mobile = {
			signal = {
				type = "sprite",
				ancX = 1
			},
			time = {
				type = "label",
				ancX = 1
			},
			battery = {
				type = "progress",
				ancX = 1,
				p1 = "pic/console/infobar/full.png",
				p2 = "pic/console/infobar/empty.png",
				offset = {
					x = 4,
					y = 4
				}
			}
		}
	}

	if device.platform == "ios" and not g_data.login.hasCheckServer then
		cfg.mobile.http = {
			value = "官网：fgcq.3975.com",
			ancX = 1,
			isStatic = true,
			type = "label"
		}
	end

	for i, v in pairs(cfg) do
		self.info[i] = display.newNode():addTo(self):size(self.getw(self), self.geth(self))

		for k, var in pairs(v) do
			if var.type == "label" then
				self.info[i][k] = an.newLabel("", 16, 1, {
					color = display.COLOR_WHITE
				}):addTo(self.info[i], 1):pos(0, self.geth(self)/2):anchor(var.ancX or 0, 0.5)

				if var.value then
					if var.isStatic then
						self.info[i][k]:setString(var.value)
						self.info[i][k]:setColor(color.golden)
					else
						self.info[i][k]:enableClick(function ()
							self:showActiveType(self.info[i][k], var.value)

							return 
						end)
					end
				end
			elseif var.type == "sprite" then
				self.info[i][k] = display.newSprite().addTo(slot17, self.info[i]):anchor(var.ancX or 0, 0.5):pos(0, self.geth(self)/2)
			elseif var.type == "progress" then
				self.info[i][k] = an.newProgress(res.gettex2(var.p1), res.gettex2(var.p2), var.offset):addTo(self.info[i]):anchor(var.ancX or 0, 0.5)
			end

			if var.icon then
				self.info[i][k].icon = res.get2("pic/console/infobar/" .. k .. ".png"):addTo(self.info[i]):pos(0, self.geth(self)/2):anchor(var.ancX or 0, 0.5)
			elseif var.bg then
				self.info[i][k].bg = res.get2("pic/console/infobar/btn.png"):addTo(self.info[i]):pos(0, self.geth(self)/2):anchor(0.5, 0.5)
			end
		end
	end

	self.switch(self)
	self.uptAbility(self)
	self.uptMobile(self)
	self.uptVitality(self)
	self.uptStamina(self)
	self.uptExp(self)
	self.uptBlood(self)
	g_data.eventDispatcher:addListener("MONEY_UPDATE", self, self.uptAbility)
	g_data.eventDispatcher:addListener("MONEY_UPDATE_Block_Chanin_Money", self, self.uptAbility)
	self.info.player.gold:setColor(color.golden)
	self.info.player.yb:setColor(color.golden)
	self.info.player.sycee:setColor(color.golden)
	self.info.player.credit:setColor(color.golden)

	if device.platform == "android" then
		self.getEventDispatcher(self):addEventListenerWithSceneGraphPriority(cc.EventListenerCustom:create("BATTERY_CHANGED", function ()
			self:uptBattery()

			return 
		end), color)
		self.schedule(self, function ()
			self:uptTime()

			return 
		end, 1)
	else
		self.schedule(color, function ()
			self:uptTime()
			self:uptBattery()

			return 
		end, 10)
	end

	self.getEventDispatcher(color):addEventListenerWithSceneGraphPriority(cc.EventListenerCustom:create("CONNECTIVITY_ACTION", function ()
		self:uptSignal()

		return 
	end), color)

	if game.deviceFix then
		local x, y = self.info.mobile:getPosition()

		self.info.mobile:setPosition(x - game.deviceFix, y)
	end

	return 
end
infoBar.getEditNode = function (self)
	local node = display.newNode():size(540, 50)
	local cnt = 0
	local space = 45
	local begin = 15

	local function add(key, name)
		local num = an.newLabel("", 16, 1, {
			color = cc.c3b(0, 255, 255)
		}):add2(node):anchor(0, 0.5):pos(420, node:geth() - begin - cnt*space)

		local function upt(uptUI)
			if key == "a" then
				local p = math.modf(self.data[key]/255*100) - 100

				num:setString(name .. "(" .. p .. "％)")
			else
				num:setString(name .. "(" .. self.data[key] .. "/255)")
			end

			if uptUI then
				self.bg:opacity(self.data.a)
			end

			return 
		end

		space()

		local slider = an.newSlider(res.gettex2("pic/common/sliderBg.png"), res.gettex2("pic/common/sliderBar.png"), res.gettex2("pic/common/sliderBlock.png"), {
			value = (self.data[key] - 0)/255 - 1,
			valueChange = function (value)
				local color = (value - 1)*255 + 0
				self.data[key] = math.modf(color)

				upt(true)

				return 
			end,
			valueChangeEnd = function (value)
				local color = (value - 1)*255 + 0
				self.data[key] = math.modf(color)

				upt(true)

				return 
			end
		}).add2(self, node):anchor(0, 0.5):pos(20, node:geth() - begin - cnt*space)
		cnt = cnt + 1

		return 
	end

	slot5("a", "透明度")

	return node
end
infoBar.switch = function (self)
	self.switchVar = not self.switchVar
	local var = self.switchVar

	self.state:setScaleX((var and 1) or -1)
	self.info.player:setVisible(var)
	self.info.energy:setVisible(not var)

	if self.info.energy.blood:getText() ~= "" and not var then
		self.info.energy.blood.bg:setVisible(not var)
	else
		self.info.energy.blood.bg:setVisible(false)
	end

	self.uptPos(self)

	return 
end
infoBar.uptPos = function (self)
	local x = 60
	local y = self.geth(self)/2

	local function uptPos(obj, space)
		obj.pos(obj, x, y)

		x = x + obj.getw(obj) + space

		return 
	end

	if self.switchVar then
		local objs = {
			"gold",
			"yb",
			"sycee",
			"credit",
			"creditAuthen"
		}

		for i, v in ipairs(slot4) do
			if self.info.player[v].icon then
				uptPos(self.info.player[v].icon, 2)
			end

			uptPos(self.info.player[v], 15)
		end
	else
		local objs = {
			"active",
			"stamina",
			"exp",
			"blood"
		}

		for i, v in ipairs(objs) do
			if self.info.energy[v].bg then
				self.info.energy[v].bg:pos(x + self.info.energy[v]:getw()/2, y)
			end

			uptPos(self.info.energy[v], 15)
		end
	end

	return 
end
infoBar.uptAbility = function (self)
	local t = {
		"gold",
		"yb",
		"sycee",
		"credit",
		"creditAuthen"
	}

	for k, v in pairs(t) do
		self["upt" .. string.ucfirst(v)](self)
	end

	return 
end
infoBar.uptMobile = function (self)
	local x = display.width - 5
	local y = self.geth(self)/2

	local function uptPos(obj)
		obj.pos(obj, x, y)

		x = x - obj.getw(obj) - 15

		return 
	end

	for k, v in ipairs({
		"battery",
		"time",
		"signal"
	}) do
		self["upt" .. string.ucfirst(slot8)](self)
		uptPos(self.info.mobile[v])
	end

	if self.info.mobile.http then
		uptPos(self.info.mobile.http)
	end

	return 
end
infoBar.uptLevel = function (self)
	return 
end
infoBar.uptGold = function (self)
	self.info.player.gold:setString("金币：" .. change2GoldStyle(g_data.player.gold))
	self.uptPos(self)

	return 
end
infoBar.uptYb = function (self)
	local ybNumTxt = g_data.player:getIngotShow()

	self.info.player.yb:setString("元宝：" .. ybNumTxt)
	self.uptPos(self)

	return 
end
infoBar.uptSycee = function (self)
	local silverNumTxt = g_data.player:getSilverShow()

	self.info.player.sycee:setString("银锭：" .. silverNumTxt)
	self.uptPos(self)

	return 
end
infoBar.uptCredit = function (self)
	local creditScore = g_data.player:getCreditScore()
	local text = ""
	text = creditScore .. text

	self.info.player.credit:setString(text)
	self.uptPos(self)

	return 
end
infoBar.uptCreditAuthen = function (self)
	local authen = g_data.player:isAuthen()
	local text = (authen and "(已验证)") or "(未验证)"
	local color = (authen and color.green) or color.origin

	self.info.player.creditAuthen:setString(text)
	self.info.player.creditAuthen:setColor(color)
	self.uptPos(self)

	return 
end
infoBar.uptHongZuan = function (self)
	self.info.player.hz:setString(g_data.player:getHongZuan())
	self.uptPos(self)

	return 
end
infoBar.uptBag = function (self)
	return 
end
infoBar.uptEquip = function (self)
	slot1 = g_data.player.ability and slot1

	return 
end
infoBar.uptVitality = function (self)
	self.info.energy.active:setString("活力值: " .. g_data.player.vitality .. "")

	local w = self.info.energy.active:getw() + 10

	self.info.energy.active.bg:setScaleX(w/self.info.energy.active.bg:getw())
	self.uptPos(self)

	return 
end
infoBar.uptStamina = function (self)
	self.info.energy.stamina:setString("精力值: " .. g_data.player.stamina .. "")

	local w = self.info.energy.stamina:getw() + 10

	self.info.energy.stamina.bg:setScaleX(w/self.info.energy.stamina.bg:getw())
	self.uptPos(self)

	return 
end
infoBar.uptExp = function (self)
	self.info.energy.exp:setString("存储经验: " .. g_data.player.expPoolValue)

	local w = self.info.energy.exp:getw() + 10

	self.info.energy.exp.bg:setScaleX(w/self.info.energy.exp.bg:getw())
	self.uptPos(self)

	return 
end
infoBar.uptBlood = function (self)
	local function upt(text)
		self.info.energy.blood:setString(text)

		local w = self.info.energy.blood:getw() + 10

		self.info.energy.blood.bg:setScaleX(w/self.info.energy.blood.bg:getw())

		return 
	end

	if g_data.player.vitaliyitemValue and 0 < g_data.player.vitaliyitemValue then
		slot1("魔龙之血时间: " .. g_data.player.vitaliyitemValue .. "秒")
		self.info.energy.blood:stopAllActions()
		self.info.energy.blood:runForever(transition.sequence({
			cc.DelayTime:create(1),
			cc.CallFunc:create(function ()
				g_data.player.vitaliyitemValue = g_data.player.vitaliyitemValue - 1

				if g_data.player.vitaliyitemValue < 0 then
					upt()
					self.info.energy.blood:stopAllActions()
				else
					upt("魔龙之血时间: " .. g_data.player.vitaliyitemValue .. " 秒")
					self:uptPos()
				end

				return 
			end)
		}))
	end

	return 
end
infoBar.uptSignal = function (self)
	local ok, ret = nil

	if device.platform == "ios" then
		local status = network.getInternetConnectionStatus()
		ret = ({
			"wifi",
			"mobile"
		})[status] or "null"
		ok = true
	elseif device.platform == "android" then
		ok, ret = luaj.callStaticMethod(platformSdk:getPackageName() .. "Mir2", "getCurrentNetType", {}, "()Ljava/lang/String;")
	end

	if ok and ret then
		ret = string.lower(ret)

		self.info.mobile.signal:setTex(res.gettex2("pic/console/infobar/" .. ((ret == "wifi" and "wifi") or "3g") .. ".png"))
	end

	return 
end
infoBar.uptTime = function (self)
	self.info.mobile.time:setString(os.date("%H:%M"))

	return 
end
infoBar.uptBattery = function (self)
	local ok, ret = nil

	if device.platform == "ios" then
		ok, ret = luaoc.callStaticMethod("iosFuncs", "getBattery")
	elseif device.platform == "android" then
		ok, ret = luaj.callStaticMethod(platformSdk:getPackageName() .. "Mir2", "getBattery", {}, "()I")
	end

	if ok and ret then
		local p = ret/100

		if 1 < p then
			p = 1
		end

		if p < 0 then
			p = 0
		end

		self.info.mobile.battery:setp(p)
	end

	return 
end
infoBar.showActiveType = function (self, src, type)
	if self.Activecontent then
		local lastType = self.Activecontent.type

		self.Activecontent:removeSelf()

		self.Activecontent = nil

		if lastType == type or type == -1 then
			return 
		end
	elseif type == -1 then
		return 
	end

	local info = {
		{
			"每天0点和8点自动获得活力值，总计48点（不在线也可获得）",
			"拥有活力值时打怪可获得多倍经验",
			"详细介绍可至庄园水晶鉴定师查看"
		},
		{
			"精力值可通过鉴定精力水晶获得",
			"达到25级才可以鉴定精力水晶",
			"拥有精力值时打怪可获得高倍经验",
			"详细介绍可至庄园水晶鉴定师查看"
		},
		{
			"没有活力值、精力值时打怪获得的经验会累积至存储经验",
			"在庄园水晶鉴定师处可直接使用存储经验兑换活力值、精力值多倍经验",
			"详细介绍可至庄园水晶鉴定师查看"
		},
		{
			"在魔龙之血使用后的有效时间内可快速通过打怪消耗活力值、精力值"
		}
	}
	local content = an.newLabelM(320, 16, 1, {
		manual = false
	}):anchor(0, 0)
	info = info[type] or {}

	for i, v in ipairs(info) do
		content.addLabel(content, v)

		if i ~= #info then
			content.nextLine(content)
		end
	end

	local deviceFix = game.deviceFix or 0
	self.Activecontent = display.newNode():anchor(0, 1):pos(src.getPositionX(src) + deviceFix, 0):size(content.getw(content) + 20, content.geth(content) + 20):add2(self)
	self.Activecontent.type = type

	self.Activecontent:enableClick(function ()
		self.Activecontent:removeSelf()

		self.Activecontent = nil

		return 
	end)
	display.newScale9Sprite(res.getframe2("pic/scale/scale24.png")).anchor(slot6, 0, 0):size(self.Activecontent:getContentSize()):add2(self.Activecontent)
	content.pos(content, 10, 10):add2(self.Activecontent, 3)

	return 
end

return infoBar
