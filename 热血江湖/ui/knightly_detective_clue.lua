-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_knightly_detective_clue = i3k_class("wnd_knightly_detective_clue", ui.wnd_base)

function wnd_knightly_detective_clue:ctor()
	
end

function wnd_knightly_detective_clue:configure()
	self._layout.vars.okBtn:onClick(self, self.onCloseUI)
end

function wnd_knightly_detective_clue:refresh(clue)
	self._layout.vars.scroll:removeAllChildren()
	g_i3k_ui_mgr:AddTask(self, {}, function(ui)
		local textNode = require("ui/widgets/guiyingwangluo2t")()
		textNode.vars.desc:setText(clue)
		ui._layout.vars.scroll:addItem(textNode)
		g_i3k_ui_mgr:AddTask(self, {textNode}, function(ui)
			local textUI = textNode.vars.desc
			local size = textNode.rootVar:getContentSize()
			local height = textUI:getInnerSize().height
			local width = size.width
			height = size.height > height and size.height or height
			textNode.rootVar:changeSizeInScroll(ui._layout.vars.scroll, width, height, true)
		end, 1)
	end, 1)
end

function wnd_create(layout)
	local wnd = wnd_knightly_detective_clue.new()
	wnd:create(layout)
	return wnd
end