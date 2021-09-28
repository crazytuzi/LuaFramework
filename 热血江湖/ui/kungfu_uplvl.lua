-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_kungfu_uplvl = i3k_class("wnd_kungfu_uplvl", ui.wnd_base)

function wnd_kungfu_uplvl:ctor()

end

function wnd_kungfu_uplvl:configure()
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

function wnd_kungfu_uplvl:refresh(data)
	self:setData(data)
end

function wnd_kungfu_uplvl:setData(data)

	local level_data = data
	local level = level_data.level+1
	local widgets = self._layout.vars
	widgets.lvl_label:setText("熟练等级：")
	widgets.old_lvl:setText(level - 1)
	widgets.new_lvl:setText(level)

	local point1 = i3k_db_create_kungfu_base[level -1].points
	local point2 = i3k_db_create_kungfu_base[level].points
	widgets.point_label:setText("悟性点：")
	widgets.old_point:setText(point1)
	widgets.new_point:setText(point2)
	local count1 = i3k_db_create_kungfu_base[level -1].count
	local count2 = i3k_db_create_kungfu_base[level].count
	if count1 == count2 then
		self._layout.vars.dayCreateCount:setVisible(false)
	end
	widgets.count_label:setText("每日次数")
	widgets.old_count:setText(count1)
	widgets.new_count:setText(count2)
	widgets.desc:setText(i3k_db_create_kungfu_base[level].upLvlDesc)
end

--[[function wnd_kungfu_uplvl:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_KungfuUplvl)
	end
end--]]

function wnd_create(layout)
	local wnd = wnd_kungfu_uplvl.new();
		wnd:create(layout);
	return wnd;
end
