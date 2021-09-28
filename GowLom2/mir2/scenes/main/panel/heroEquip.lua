local equip = import(".equip")
local heroEquip = class("heroEquip", equip)

table.merge(heroEquip, {
	isHero = true
})

heroEquip.ctor = function (self, params)
	heroEquip.super.ctor(self, params)

	if main_scene.ui.panels.heroBag then
		main_scene.ui.panels.heroBag:resetPanelPosition("left")
	end

	return 
end
heroEquip.putItem = function (self, item, x, y)
	local form = item.formPanel.__cname

	if self.page == "main" and form == "heroBag" then
		local anchor = self.content.bg:getAnchorPoint()
		local offset = cc.p(self.content.bg:getw()*anchor.x, self.content.bg:geth()*anchor.y)
		y = y - self.content.bg:getPositionY() + offset.y
		x = x - self.content.bg:getPositionX() + offset.x
		local putIdx = self.pos2idx(self, x, y)

		if putIdx == "-1" then
			return 
		end

		item.use(item, putIdx)
	end

	return 
end

return heroEquip
