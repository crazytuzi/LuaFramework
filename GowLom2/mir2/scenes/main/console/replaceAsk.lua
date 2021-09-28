local replaceAsk = class("replaceAsk", function ()
	return display.newNode()
end)

table.merge(slot0, {})

replaceAsk.ctor = function (self, btn, callback, form)
	self.size(self, display.width, display.height):addto(main_scene.ui, main_scene.ui.z.replaceAsk)
	self.setTouchEnabled(self, true)
	self.addNodeEventListener(self, cc.NODE_TOUCH_EVENT, function ()
		return 
	end)

	local bg = res.get2("pic/common/msgbox.png").center(slot4):add2(self):scale(0.01):runs({
		cc.ScaleTo:create(0.1, 1.5),
		cc.ScaleTo:create(0.1, 1)
	})

	an.newLabelM(200, 18, 1, {
		manual = true
	}):anchor(0, 1):pos(150, bg.geth(bg)*0.5 + 50):add2(bg):nextLine():addLabel("该位置已存在控件"):nextLine():addLabel("请选择操作.")

	local bgTex = btn.btn.bg:getSpriteFrame()
	local btnbg = display.newSprite(bgTex):pos(140, bg.geth(bg)*0.5 + 50):anchor(1, 1):add2(bg)

	if btn.btn.sprite then
		local sprTex = btn.btn.sprite:getSpriteFrame()

		display.newSprite(sprTex):pos(btnbg.centerPos(btnbg)):add2(btnbg)
	end

	if btn.btn.text then
		local textTex = btn.btn.text:getSpriteFrame()

		display.newSprite():pos(btnbg.centerPos(btnbg)):add2(btnbg)
	end

	if form == "console" then
		an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
			callback("swap")
			self:removeSelf()

			return 
		end, {
			pressImage = res.gettex2("pic/common/btn21.png"),
			sprite = res.gettex2("pic/common/charge.png")
		}).anchor(slot7, 0.5, 0):pos(bg.getw(bg)*0.5 - 120, 12):add2(bg)
	end

	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		callback("replace")
		self:removeSelf()

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/common/fugai.png")
	}).anchor(slot7, 0.5, 0):pos((form == "console" and bg.getw(bg)*0.5) or bg.getw(bg)*0.3, 12):add2(bg)
	an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
		callback("cancel")
		self:removeSelf()

		return 
	end, {
		pressImage = res.gettex2("pic/common/btn21.png"),
		sprite = res.gettex2("pic/common/cancel.png")
	}).anchor(slot7, 0.5, 0):pos((form == "console" and bg.getw(bg)*0.5 + 120) or bg.getw(bg)*0.7, 12):add2(bg)

	return 
end

return replaceAsk
