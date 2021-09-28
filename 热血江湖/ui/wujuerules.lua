-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_wujueRules = i3k_class("wnd_wujueRules", ui.wnd_base)

-- 武诀规则提示
-- [eUIID_WujueRules]	= {name = "wujueRules", layout = "wujuegz1", order = eUIO_TOP_MOST,},
-------------------------------------------------------

function wnd_wujueRules:ctor()

end

function wnd_wujueRules:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_wujueRules:refresh()
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	scroll:removeAllChildren()
	local sort_levels = i3k_db_wujue.sort_levels
	for i = 1, #i3k_db_wujue.sort_levels + 1 do
		local v = i3k_db_wujue.sort_levels[i]
		local ui = require("ui/widgets/wujuegz1t")()
		local from,to,exp,txt
		if i == #i3k_db_wujue.sort_levels + 1 then
			txt = i3k_get_string(17698, sort_levels[#sort_levels])
		else
			from = i == 1 and 1 or sort_levels[i - 1]
			to = v
			exp = i3k_db_wujue.levels[v]
			txt = i3k_get_string(17699, from + (i ~= 1 and 1 or 0), to, exp)
		end
		ui.vars.text:setText(txt)
		scroll:addItem(ui)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_wujueRules.new()
	wnd:create(layout, ...)
	return wnd;
end
