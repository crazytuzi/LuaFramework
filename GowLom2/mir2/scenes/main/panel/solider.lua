local soldier = class("soldier", import(".panelBase"))
soldier.ctor = function (self)
	self.super.ctor(self)
	self.setMoveable(self, true)

	return 
end
soldier.onEnter = function (self)
	self.initPanelUI(self, {
		title = "Éñ±ø",
		bg = "pic/common/black_2.png",
		size = cc.size(400, 400)
	})
	self.setupUI(self)

	return 
end
soldier.setupUI = function (self)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		sound.playSound("103")
		main_scene.ui:togglePanel("soldierUpgrade")

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		label = {
			"Ç°ÍùÉý¼¶",
			16,
			0,
			{
				color = def.colors.Cf0c896
			}
		}
	}).add2(slot1, self.bg):anchor(0.5, 0.5):pos(80, 300)

	return 
end

return soldier
