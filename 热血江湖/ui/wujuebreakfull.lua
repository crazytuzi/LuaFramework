-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_wujueBreakFull = i3k_class("wnd_wujueBreakFull", ui.wnd_base)

-- 武诀突破圆满
-- [eUIID_WujueBreakFull]	= {name = "wujueBreakFull", layout = "wujuetpm", order = eUIO_TOP_MOST,},
-------------------------------------------------------

function wnd_wujueBreakFull:ctor()

end

function wnd_wujueBreakFull:configure()
	local widgets =self._layout.vars
	local cfg = i3k_db_wujue_break[#i3k_db_wujue_break]
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.rank:setText(cfg.name)
	widgets.desc1:setText(i3k_get_string(17711))
	widgets.desc2:setText(i3k_get_string(17712))
	widgets.value1:setText(cfg.levelTop)
	widgets.value2:setText((cfg.expRate/100).."%")
end

function wnd_create(layout, ...)
	local wnd = wnd_wujueBreakFull.new()
	wnd:create(layout, ...)
	return wnd;
end
