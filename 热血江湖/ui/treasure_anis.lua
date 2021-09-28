-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_treasure_anis = i3k_class("wnd_treasure_anis", ui.wnd_base)

function wnd_treasure_anis:ctor()

end

function wnd_treasure_anis:configure()

end

function wnd_treasure_anis:onShow()
	-- local node = require("ui/widgets/yunt")()
	-- self._layout.vars.yunScroll:addItem(node)
	-- self._layout.vars.yunScroll:show()
	-- node.anis.c_yun2.play(function ()
		self:showHostelGuide()
	-- end)
end

function wnd_treasure_anis:finishAnis()
-- 	local node = self._layout.vars.yunScroll:getChildAtIndex(1)
-- 	if node then
-- 		node.anis.c_yun_san.play(function ()
			g_i3k_ui_mgr:CloseUI(eUIID_TreasureAnis)
-- 		end)
-- 	end
end

function wnd_treasure_anis:showHostelGuide()
	g_i3k_ui_mgr:OpenUI(eUIID_HostelGuide1)
	g_i3k_ui_mgr:RefreshUI(eUIID_HostelGuide1, 1)
end


function wnd_create(layout, ...)
	local wnd = wnd_treasure_anis.new()
	wnd:create(layout, ...)
	return wnd;
end
