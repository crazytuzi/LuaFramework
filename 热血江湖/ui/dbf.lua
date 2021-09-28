-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_tf_func = i3k_class("wnd_tf_func", ui.wnd_base)


function wnd_tf_func:ctor()
	self._pos = {}
end

function wnd_tf_func:configure()
	local widgets = self._layout.vars
	self.coin = widgets.coin
	self.coinLock = widgets.coinLock
	self.root = widgets.root
	widgets.add_coin:onClick(self, self.addCoinBtn)
end

function wnd_tf_func:onShow()
	-- self.root:hide()
	-- local delay = cc.DelayTime:create(0.4)
	-- local seq =	cc.Sequence:create(delay, cc.CallFunc:create(function ()
	-- 	self.root:show()
	-- end))
	-- self:runAction(seq)
end

function wnd_tf_func:updateMoney(coinF, coinR)
	self.coin:setText(i3k_get_num_to_show(coinF))
	self.coinLock:setText(i3k_get_num_to_show(coinR))
end

function wnd_tf_func:addDiamondBtn(sender)
	g_i3k_logic:OpenChannelPayUI()
end

function wnd_tf_func:addCoinBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BuyCoin)
end

function wnd_tf_func:setRootVisible(show)
	self.root:setVisible(show)
end

function wnd_tf_func:refresh()
	self:updateMoney(g_i3k_game_context:GetMoney(true), g_i3k_game_context:GetMoney(false))
end

function wnd_create(layout)
	local wnd = wnd_tf_func.new()
	wnd:create(layout)
	return wnd
end
