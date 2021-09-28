local textInfo = import("..common.textInfo")
local common = import("..common.common")
local heroHead = class("heroHead", function ()
	return display.newNode()
end)

table.merge(slot2, {})

local poses = {
	openMap = {
		x = display.width - 160,
		y = display.height - 21
	},
	hideMap = {
		x = display.width - 40,
		y = display.height - 21
	}
}
heroHead.resetPanelPosition = function (self, key)
	self.pos(self, poses[key].x, poses[key].y):anchor(1, 1)

	return self
end
heroHead.isInPos = function (self, key)
	return self.getPositionX(self) == poses[key].x and self.getPositionY(self) == poses[key].y
end
heroHead.ctor = function (self)
	self._supportMove = true
	local node = display.newNode():addTo(self, 1)
	local bg = res.get2("pic/console/head-icons/head_info.png"):addTo(node):pos(0, 0):anchor(0, 0)

	self.size(self, bg.getw(bg), bg.geth(bg))
	self.resetPanelPosition(self, (main_scene.ui.panels.minimap and "openMap") or "hideMap")
	node.size(node, bg.getw(bg), bg.geth(bg))

	self.name = an.newLabel("", 18, 1):addTo(node):pos(137, 69):anchor(0.5, 0.5)
	self.lv = an.newLabel("", 14, 1):addTo(node):pos(14, 14):anchor(0.5, 0.5)
	self.prog = {}
	local config = {
		{
			key = "HP",
			posY = 46,
			pic = "head_HP",
			posX = 74,
			text = {
				posY = 52,
				posX = 140
			}
		},
		{
			key = "MP",
			posY = 30,
			pic = "head_MP",
			posX = 80,
			text = {
				posY = 35,
				posX = 140
			}
		},
		{
			key = "EXP",
			posY = 14,
			pic = "head_Exp",
			posX = 71,
			text = {
				posY = 20,
				posX = 140
			}
		},
		{
			key = "DRINK",
			posY = 5,
			pic = "head_drink",
			posX = 48,
			text = {
				posY = 0,
				posX = 0
			}
		}
	}

	for k, v in pairs(config) do
		self.prog[v.key] = res.get2("pic/console/head-icons/" .. v.pic .. ".png"):addTo(node):pos(v.posX, v.posY):anchor(0, 0)
	end

	self.upt(self)

	return 
end
heroHead.setPercent = function (self, key, params)
	local p = 0

	if params.cur and params.max then
		p = params.cur/params.max or p
	end

	if 1 < p then
		p = 1
	end

	if p < 0 then
		p = 0
	end

	if self.prog and self.prog[key] then
		local w = self.prog[key]:getTexture():getContentSize().width
		local h = self.prog[key]:getTexture():getContentSize().height

		if key == "DRINK" then
			self.prog[key]:setTextureRect(cc.rect(0, h*(p - 1), w, h*p))
		else
			self.prog[key]:setTextureRect(cc.rect(0, 0, w*p, h))
		end
	end

	return 
end
heroHead.showHeroInfo = function (self)
	local labels = {}

	local function addLabel(str)
		labels[#labels + 1] = an.newLabel(str, 15, 1)

		return 
	end

	slot2("体力值: " .. g_data.hero.ability.FHP .. "/" .. g_data.hero.ability.FMaxHP)
	addLabel("魔法值: " .. g_data.hero.ability.FMP .. "/" .. g_data.hero.ability.FMaxMP)
	addLabel("经验: " .. string.format("%.2f%%", g_data.hero.ability:get("Exp")/g_data.hero.ability:get("maxExp")*100))
	addLabel("忠诚度: " .. string.format("%.2f%%", g_data.hero.fealty/100))
	addLabel("醉酒度: " .. string.format("%d%%", g_data.hero.drinkStatusValue/g_data.hero.drinkStatusMaxValue*100))

	self.heroInfo = textInfo.show(labels, cc.p(self.getPositionX(self), self.getPositionY(self) + 3))

	return 
end
heroHead.upt = function (self)
	self.name:setString(g_data.hero.name)

	if not self.headshot and g_data.hero.sex and g_data.hero.job then
		local img = string.format("pic/console/head-icons/%d_%d.png", g_data.hero.sex, g_data.hero.job)
		self.headshot = display.newSprite(res.gettex2(img), nil, nil, {
			class = cc.FilteredSpriteWithOne
		}):addTo(self):pos(45, 40):anchor(0.5, 0.5)

		self.headshot:setTouchEnabled(true)
		self.headshot:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			if event.name == "began" then
				self.isMoved = false
				self.initPos = cc.p(self:getPosition())
				self.touchPos = cc.p(event.x, event.y)
			elseif event.name == "moved" then
				self.isMoved = true

				self:pos((self.initPos.x + event.x) - self.touchPos.x, (self.initPos.y + event.y) - self.touchPos.y)
			elseif event.name == "ended" then
				if not self.isMoved then
					self:showHeroInfo()
				end

				self.isMoved = false
			end

			return true
		end)
	end

	local strlvl = common.getLevelText(g_data.hero.ability.FLevel) .. "级"

	self.lv.setString(slot2, strlvl .. "")
	self.setPercent(self, "HP", {
		cur = g_data.hero.ability.FHP,
		max = g_data.hero.ability.FMaxHP
	})
	self.setPercent(self, "MP", {
		cur = g_data.hero.ability.FMP,
		max = g_data.hero.ability.FMaxMP
	})
	self.setPercent(self, "EXP", {
		cur = g_data.hero.ability:get("Exp"),
		max = g_data.hero.ability:get("maxExp")
	})
	self.setPercent(self, "DRINK", {
		cur = g_data.hero.drinkStatusValue,
		max = g_data.hero.drinkStatusMaxValue
	})

	return 
end

return heroHead
