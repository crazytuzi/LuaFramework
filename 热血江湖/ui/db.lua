-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_t_func = i3k_class("wnd_t_func", ui.wnd_base)


function wnd_t_func:ctor()
	self._pos = {}
end

function wnd_t_func:configure()
	local widgets = self._layout.vars
	self.diamond = widgets.diamond
	self.diamondLock = widgets.diamondLock
	self.root = widgets.root
	widgets.add_diamond:onClick(self, self.addDiamondBtn)

end

function wnd_t_func:onShow()
	-- self.root:hide()
	-- local delay = cc.DelayTime:create(0.4)
	-- local seq =	cc.Sequence:create(delay, cc.CallFunc:create(function ()
	-- 	self.root:show()
	-- end))
	-- self:runAction(seq)
end

function wnd_t_func:updateMoney(diamondF, diamondR)
	self.diamond:setText(diamondF)
	self.diamondLock:setText(diamondR)
end

function wnd_t_func:addDiamondBtn(sender)
	g_i3k_logic:OpenChannelPayUI()
end

function wnd_t_func:addCoinBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BuyCoin)
end


function wnd_t_func:refresh()
	self:updateMoney(g_i3k_game_context:GetDiamond(true), g_i3k_game_context:GetDiamond(false))
end

function wnd_create(layout)
	local wnd = wnd_t_func.new()
	wnd:create(layout)
	return wnd
end

