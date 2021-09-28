local common = import("...common.common")
local bottom = class("bottom", function ()
	return display.newNode()
end)

table.merge(slot1, {
	config,
	data,
	progress,
	mapTitle,
	mapPos,
	zoneInfo
})

bottom.ctor = function (self, config, data)
	self.size(self, display.width, 28):anchor(0.5, 0.5):pos(data.x, data.y - 4)

	local bg1 = res.get2("pic/console/bottom/bg1.png"):anchor(0, 0):add2(self)
	local bg2 = res.get2("pic/console/bottom/bg2.png"):anchor(0, 0):pos(bg1.getw(bg1), 0):add2(self)
	local bg3 = res.get2("pic/console/bottom/bg3.png"):anchor(1, 0):pos(display.width, 0):add2(self)

	bg2.scalex(bg2, (display.width - bg1.getw(bg1) - bg3.getw(bg3))/bg2.getw(bg2))

	self.mapTitle = an.newLabel(g_data.map.mapTitle .. "", 16, 1):pos(2, 5):add2(self)
	self.zoneInfo = an.newLabel("", 16, 1):pos(self.mapTitle:getw() + 4, 5):add2(self)
	self.mapPos = an.newLabel("", 16, 1):pos(2, 20):add2(self)

	res.get2("pic/console/bottom/w1.png"):anchor(1, 0):pos(display.width, 0):add2(self)

	local space = 2
	local expBgX = display.width - 103
	self.progress = an.newProgress(res.gettex2("pic/console/bottom/exp2.png"), res.gettex2("pic/console/bottom/expbg.png"), {
		x = 1,
		y = 5
	}):anchor(1, 0):pos(expBgX, 10):add2(self)
	local expFont = res.get2("pic/console/bottom/expFont.png"):anchor(1, 0.5)
	local expFontX = expBgX - self.progress:getw() - space

	expFont.pos(expFont, expFontX, self.geth(self)/2 + 6):add2(self)

	self.text = an.newLabel("", 14, 1):anchor(0.5, 0.5):pos(self.progress:getw()/2, self.progress:geth()/2 + 2):add2(self.progress, 1)
	local lvbg = res.get2("pic/console/bottom/lvbg.png"):anchor(1, 0.5):add2(self)
	local lvbgPosX = expFontX - expFont.getw(expFont) - space

	lvbg.pos(lvbg, lvbgPosX, self.geth(self)/2 - 1 + 6)

	local lvFont = res.get2("pic/console/bottom/lvFont.png"):anchor(1, 0.5):add2(self)
	local lvFontPosX = lvbgPosX - lvbg.getw(lvbg) - space

	lvFont.pos(lvFont, lvFontPosX, self.geth(self)/2 + 6)

	self.lvText = an.newLabel("999", 14, 1):anchor(0.5, 0.5):pos(lvbg.getw(lvbg)/2, lvbg.geth(lvbg)/2 + 2):add2(lvbg, 1)

	self.upt(self)

	if device.platform == "ios" and not g_data.login.hasCheckServer then
		local msg = "¹«ÖÚºÅ£ºfgcq39"
		self.wechatLabel = an.newLabel(msg, 16, 1, {
			color = cc.c3b(250, 210, 100)
		}):add2(self):anchor(0, 0)
	end

	return 
end
bottom.upt = function (self)
	local ability = g_data.player.ability

	if not ability then
		return 
	end

	local p = ability.FCurrExp/ability.FNextExp

	if 1 < p then
		p = 1
	end

	if p < 0 then
		p = 0
	end

	self.progress:setp(p)
	self.text:setString(string.format("%s / %s (%.2f£¥)", ability.FCurrExp, tostring(ability.FNextExp), p*100))

	local strlvl = common.getLevelText(ability.FLevel) .. "¼¶"

	self.lvText:setString(strlvl)

	return 
end
bottom.update = function (self, dt)
	local map = main_scene.ground.map
	local player = main_scene.ground.player

	if not map or not player then
		return 
	end

	local empty = ""

	if game.deviceFix then
		empty = "        "
	end

	self.mapPos:setString(empty .. player.x .. ":" .. player.y)

	return 
end
bottom.uptMap = function (self)
	local empty = ""

	if game.deviceFix then
		empty = "        "
	end

	print("bottom:uptMap ", getMapStateStr(g_data.map.mapState))
	self.mapTitle:setString(empty .. g_data.map.mapTitle .. "")

	local stateStr, stateColor = getMapStateStr(g_data.map.mapState)

	self.zoneInfo:setString(stateStr)
	self.zoneInfo:setColor(stateColor)
	self.zoneInfo:pos(self.mapTitle:getw() + 4, 0)
	self.zoneInfo:setColor((g_data.map.mapState == 1 and display.COLOR_RED) or display.COLOR_GREEN)

	if self.wechatLabel then
		self.wechatLabel:pos(self.zoneInfo:getw() + self.zoneInfo:getPositionX() + 60, 5)
	end

	return 
end

return bottom
