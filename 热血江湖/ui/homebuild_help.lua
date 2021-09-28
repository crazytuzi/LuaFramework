-- yuquan
-- 2018/7/24 homebuild_help
--eUIID_homebuild_help --家园建筑帮助界面
-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base");
wnd_homebuild_help = i3k_class("wnd_homebuild_help", ui.wnd_base)
function wnd_homebuild_help:ctor()
	self._dropDownList = nil -- 下拉列表
	self._info = nil
	self._widgets = nil
	
end
function wnd_homebuild_help:configure()
	local widgets = self._layout.vars
	self._widgets=widgets
	widgets.cancel:onClick(self,self.onCloseUI)
end
--[[function wnd_homebuild_help:onshow()

end--]]
function wnd_homebuild_help:refresh(helpinfo_left,scrollInfo)
	local widgets = self._widgets
	for _, e in ipairs(scrollInfo) do
		local descType = e.descType or 2 --默认是内容 
		local item= require("ui/widgets/jiayuanjzsmt"..descType)()
		item.vars.desc:setText(e.desc)
		widgets.scrollView1:addItem(item)
		if not e.descType then
			g_i3k_ui_mgr:AddTask(self, {item}, function(ui)
					local textUI = item.vars.desc
					local size = item.rootVar:getContentSize()
					local height = textUI:getInnerSize().height
					local width = size.width
					height = size.height > height and size.height or height
					item.rootVar:changeSizeInScroll(self._layout.vars.scrollView1, width, height, true)
			end, 1)
		end
		--widgets.scrollView1:addItem(item)
	end
	for i = 1, 4 do
		local desc = widgets["desc"..i]
		if helpinfo_left[i] then
			desc:setText(helpinfo_left[i])
		else --不存在则隐藏
		    desc:hide()
		end
	end
end
function wnd_homebuild_help:onCloseUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_HouseBuildinfo);
end
function wnd_create(layout,...)
	local wnd = wnd_homebuild_help.new()
	wnd:create(layout,...)
	return wnd
end
