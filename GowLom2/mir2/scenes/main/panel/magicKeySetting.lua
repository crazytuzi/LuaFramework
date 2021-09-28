local common = import("..common.common")
local magicKeySetting = class("magicKeySetting", function ()
	return display.newNode()
end)
magicKeySetting.ctor = function (self, params)
	local bg = res.get2("pic/common/black_3.png"):addTo(self):anchor(0, 0)

	self.size(self, bg.getContentSize(bg)):anchor(0.5, 0.5):center()
	res.get2("pic/panels/mail/title.png"):addTo(bg):pos(bg.getw(bg)/2, bg.geth(bg) - 10):anchor(0.5, 1)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).addTo(slot3, bg):pos(bg.getw(bg) - 5, bg.geth(bg) - 9):anchor(1, 1)

	for i = 1, 2, 1 do
		for j = 1, 8, 1 do
			local strKey = ""

			if i == 1 then
				strKey = "F" .. j
			else
				strKey = "F" .. j .. "\nCtrl"
			end

			local button = an.newBtn(res.gettex2("pic/common/btn101.png"), function (owner)
				sound.playSound("103")
				g_data.hotKey:setMagicHotKey((i - 1)*12 + 5 + j, params.magicId)
				gameEvent:dispatchEvent({
					name = gameEvent.skillHotKey
				})

				return 
			end, {
				pressBig = true,
				label = {
					strKey,
					18,
					1,
					{
						color = cc.c3b(255, 255, 0)
					}
				}
			}).pos(slot12, (j - 1)*39*1.2 + 60, bg.geth(bg) - ((i - 1)*41*1.5 + 80)):anchor(0.5, 0.5):add2(self)
			button.index = (i - 1)*12 + j
			button.keyId = button.index + 5
		end
	end

	return 
end

return magicKeySetting
