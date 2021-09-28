-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_setSex = i3k_class("wnd_setSex", ui.wnd_base)


function wnd_setSex:ctor()
	self.sex = 0
end

function wnd_setSex:configure()
	local widgets = self._layout.vars
	widgets.cancel:onClick(self, self.onCloseUI)
	widgets.sure:onClick(self, self.onConfirm)
	widgets.male_btn:onClick(self, self.onChooseMale)
	widgets.female_btn:onClick(self, self.onChooseFemale)
end

function wnd_setSex:refresh()
	self:showSex()
end

function wnd_setSex:showSex()
	
end

function wnd_setSex:onChooseMale(sender)
	local widgets = self._layout.vars
	if not widgets.male_frame:isVisible() then
		widgets.male_frame:setVisible(true)
		if widgets.female_frame:isVisible() then
			widgets.female_frame:setVisible(false)
		end
	end
	self.sex = 1
end

function wnd_setSex:onChooseFemale(sender)
	local widgets = self._layout.vars
	if not widgets.female_frame:isVisible() then
		widgets.female_frame:setVisible(true)
		if widgets.male_frame:isVisible() then
			widgets.male_frame:setVisible(false)
		end
	end
	self.sex = 2
end

function wnd_setSex:onConfirm(sender)
	if self.sex == 0 then
		g_i3k_ui_mgr:PopupTipMessage("您还未设置性别")
	else
		local fun = (function(ok)
			if ok then
				i3k_sbean.mood_diary_set_sex(self.sex)
			end
		end)
		local desc = i3k_get_string(17486, i3k_db_mood_diary_sex[self.sex].sexName)
		g_i3k_ui_mgr:ShowConstellationBox("确定", "取消", desc, fun)
	end
	
end

function wnd_create(layout)
	local wnd = wnd_setSex.new()
	wnd:create(layout)
	return wnd
end
