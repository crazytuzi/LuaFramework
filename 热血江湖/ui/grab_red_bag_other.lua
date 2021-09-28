-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

--抢到红包保底奖励界面
-------------------------------------------------------

wnd_grab_red_bag_other = i3k_class("wnd_grab_red_bag_other",ui.wnd_base)

function wnd_grab_red_bag_other:ctor()

end

function wnd_grab_red_bag_other:configure()
	local widgets = self._layout.vars

	self.count = widgets.Count
	self.okBtn = widgets.okBtn
	self.okBtn:onClick(self, self.closeButton)
end

function wnd_grab_red_bag_other:refresh(count)
	self._count = count
	local maxCount = i3k_db_grab_red_envelope.maxUnGrebTimes
	self.count:setText(count.."/"..maxCount)
	-- i3k_db_grab_red_envelope.maxUnGrebReward
end

function wnd_grab_red_bag_other:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Grab_Red_Bag_other)
end

function wnd_create(layout)
	local wnd = wnd_grab_red_bag_other.new()
	wnd:create(layout)
	return wnd
end
