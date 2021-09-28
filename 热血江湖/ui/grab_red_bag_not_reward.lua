-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

--未抢到红包提示界面
-------------------------------------------------------
local tab = {[-1]=2814,[-3]=2815,[-2]=2816} --没抢到，抢光了 ，已经过期
wnd_grab_red_bag_not_reward = i3k_class("wnd_grab_red_bag_not_reward",ui.wnd_base)

function wnd_grab_red_bag_not_reward:ctor()
	
end

function wnd_grab_red_bag_not_reward:configure()
	local widgets = self._layout.vars
	self.okBtn = widgets.okBtn
	self.okBtn:onClick(self, self.closeButton)
	self.image =  widgets.image
end

function wnd_grab_red_bag_not_reward:refresh(text)
	if tab[text] then
		self.image:setImage(i3k_db_icons[tab[text]].path)
	end
end

function wnd_grab_red_bag_not_reward:closeButton(sender)	
	g_i3k_ui_mgr:CloseUI(eUIID_Grab_Red_Bag_Not_HaveReward)
end

function wnd_create(layout)
	local wnd = wnd_grab_red_bag_not_reward.new()
	wnd:create(layout)
	return wnd
end
