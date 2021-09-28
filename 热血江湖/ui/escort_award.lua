-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_escort_award = i3k_class("wnd_escort_award", ui.wnd_base)

--
local DIVIDE_NUMBER1 = 100 --服务器发过来的数字减去改值添加%


function wnd_escort_award:ctor()
	
end

function wnd_escort_award:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.time_award = self._layout.vars.time_award 
	self.wish_exp = self._layout.vars.wish_exp 
	self.rob_lose = self._layout.vars.rob_lose 
	self.wish_coin = self._layout.vars.wish_coin 
	
	self.exp_count = self._layout.vars.exp_count 
	self.coin_count = self._layout.vars.coin_count
	self.coin_suo = self._layout.vars.coin_suo
	
	self.protect_desc = self._layout.vars.protect_desc 
end

function wnd_escort_award:onShow()
	
end

function wnd_escort_award:refresh(expCount,coinCount,timeArgs,robArgs,expArgs,coinArgs,skinArgs)
	self:updateData(expCount,coinCount,timeArgs,robArgs,expArgs,coinArgs,skinArgs)
	
end 

function wnd_escort_award:updateData(expCount,coinCount,timeArgs,robArgs,expArgs,coinArgs,skinArgs)
	self.exp_count:setText(expCount)
	self.coin_count:setText(coinCount)
	self.coin_suo:setVisible(false)
	
	local tmp = string.format("%s%%",timeArgs - DIVIDE_NUMBER1 )
	self.time_award:setText(tmp)
	local tmp = string.format("%s%%",robArgs - DIVIDE_NUMBER1 )
	self.rob_lose:setText(tmp)
	local tmp = string.format("%s%%",expArgs - DIVIDE_NUMBER1 )
	self.wish_exp:setText(tmp)
	local tmp = string.format("%s%%",coinArgs - DIVIDE_NUMBER1 )
	self.wish_coin:setText(tmp)
	self.protect_desc:setVisible(g_i3k_game_context:GetEsortIsProtect() == 1)
end 

--[[function wnd_escort_award:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_EscortAward)
end--]] 

function wnd_create(layout, ...)
	local wnd = wnd_escort_award.new();
	wnd:create(layout, ...);

	return wnd
end

