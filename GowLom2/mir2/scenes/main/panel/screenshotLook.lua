local screenshotLook = class("screenshotLook", function ()
	return display.newNode()
end)

table.merge(slot0, {})

screenshotLook.ctor = function (self, params)
	self._supportMove = true
	local screen = display.newSprite(params.diskpath)
	local picw = 615
	local picscale = picw/screen.getw(screen)
	local pich = screen.geth(screen)*picscale
	local size = cc.size(picw, pich)

	screen.scale(screen, picscale):anchor(0, 0):pos(13, 14):add2(self)
	display.newScale9Sprite(res.getframe2("pic/scale/scale2.png"), 0, 0, size):pos(screen.getPosition(screen)):anchor(0, 0):add2(self)

	local controlHeight = 70
	local b1 = res.get2("pic/panels/bigmap/bg1.png")
	local b2 = res.get2("pic/panels/bigmap/bg2.png")
	local b3 = res.get2("pic/panels/bigmap/bg3.png")

	self.size(self, b1.getw(b1), size.height + controlHeight):anchor(0.5, 0.5):center()
	self.scale(self, 0.01):scaleTo(0.2, 1)
	b3.anchor(b3, 0, 0):add2(self, -1)
	b2.anchor(b2, 0, 0):pos(0, b3.geth(b3)):scaleY((self.geth(self) - b1.geth(b1) - b3.geth(b3))/b2.geth(b2)):add2(self, -1)
	b1.anchor(b1, 0, 1):pos(0, self.geth(self)):add2(self, -1)
	res.get2("pic/panels/screenshot/title.png"):add2(b1):pos(b1.getw(b1)/2, b1.geth(b1) - 23)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png")
	}).anchor(slot11, 1, 1):pos(self.getw(self) - 8, self.geth(self) - 8):addto(self, 1)

	local title = an.newLabelM(self.getw(self) - 30, 18, 1, {
		manual = true
	}):anchor(0, 0.5):pos(20, self.geth(self) - 32):add2(self):nextLine():addLabel(params.user, cc.c3b(0, 255, 0)):addLabel("µÄÆÁÄ»")

	return 
end

return screenshotLook
