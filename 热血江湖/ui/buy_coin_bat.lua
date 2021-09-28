-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------
wnd_buy_coin_bat = i3k_class("wnd_buy_coin_bat",ui.wnd_base)

function wnd_buy_coin_bat:ctor()

end

function wnd_buy_coin_bat:configure()
	self._layout.vars.cancel_btn:onClick(self, self.cancelBtn)
	self._layout.vars.sure_btn:onClick(self, self.okBtn)
	self.suo = self._layout.vars.suo

	self.power_label =	self._layout.vars.power_label
	self.diam_lab =	self._layout.vars.diam_lab
	self.coin_lab =	self._layout.vars.coin_lab
end

function wnd_buy_coin_bat:okBtn(sender)
	i3k_sbean.buy_coins(self.num, self.number, self.diamondData)
end

function wnd_buy_coin_bat:cancelBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_BuyCoinBat)
end

function wnd_buy_coin_bat:refresh(data)
	self.num = data.num
	self.number = data.number
	self.needDiamond = data.needDiamond
	self.coinCount = data.coinCount
	self.diamondData = data.diamondData

	self.power_label:setText(string.format("连续使用%s次炼金术", self.num))
	self.diam_lab:setText(self.needDiamond)
	self.coin_lab:setText(self.coinCount)

	self:updateBinding()
end

function wnd_buy_coin_bat:updateBinding()
	if g_i3k_game_context:GetDiamond(false) == 0  and g_i3k_game_context:GetDiamond(true) > 0 then
		self.suo:hide()
	else
		self.suo:show()
	end
end

function wnd_create(layout)
	local wnd = wnd_buy_coin_bat.new()
		wnd:create(layout)
	return wnd
end
