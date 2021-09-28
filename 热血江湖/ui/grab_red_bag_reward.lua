-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

--抢到红包奖励界面
-------------------------------------------------------

wnd_grab_red_bag_reward = i3k_class("wnd_grab_red_bag_reward",ui.wnd_base)

function wnd_grab_red_bag_reward:ctor()
	
end

function wnd_grab_red_bag_reward:configure()
	local widgets = self._layout.vars
	
	self.count = widgets.Count
	self.okBtn = widgets.okBtn
	self.okBtn:onClick(self, self.closeButton)
end

function wnd_grab_red_bag_reward:refresh(count)
	self._count = count
	self.count:setText(count)
end

function wnd_grab_red_bag_reward:closeButton(sender)
	--g_i3k_game_context:AddDiamond(self._count, false)	
	g_i3k_ui_mgr:CloseUI(eUIID_Grab_Red_Bag_Reward)
end

function wnd_create(layout)
	local wnd = wnd_grab_red_bag_reward.new()
	wnd:create(layout)
	return wnd
end
