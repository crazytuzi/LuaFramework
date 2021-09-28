-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_knightly_detective_tips = i3k_class("wnd_knightly_detective_tips", ui.wnd_base)

local tipsWidget = "ui/widgets/guiyingwangluotipst"

function wnd_knightly_detective_tips:ctor()
	
end

function wnd_knightly_detective_tips:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
end

function wnd_knightly_detective_tips:refresh()
	local spy = g_i3k_game_context:getKnightlyDetectiveData()
	if spy and spy.boss and spy.boss ~= 0 then
		local monsterId = i3k_db_knightly_detective_ringleader[spy.boss].monsterId
		self._layout.vars.title:setText(i3k_get_string(18257))
		self._layout.vars.scroll:removeAllChildren()
		g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			local textNode = require(tipsWidget)()
			textNode.vars.desc:setText(i3k_db_knightly_detective_ringleader[spy.boss].story)
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
end

function wnd_create(layout)
	local wnd = wnd_knightly_detective_tips.new()
	wnd:create(layout)
	return wnd
end