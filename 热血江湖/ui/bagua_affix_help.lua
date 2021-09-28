module(..., package.seeall)
local require = require
local ui = require("ui/base")
local wg = require("ui/widgets/baguaczylt")

wnd_baguaAffixHelp = i3k_class("wnd_baguaAffixHelp", ui.wnd_base)

function wnd_baguaAffixHelp:ctor()

end

function wnd_baguaAffixHelp:configure()
	self.ui = self._layout.vars
	self.ui.close:onClick(self, self.onCloseUI)
end

function wnd_baguaAffixHelp:refresh()
	local affixInfo = g_i3k_db.i3k_db_get_affix_info()
	for k, v in ipairs(affixInfo) do
		local scr = self.ui["notice_content"..k]
		local showPlate = false
		for _, v2 in ipairs(v) do
			local item = wg()
			item.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v2.icon))
			item.vars.plate:setVisible(showPlate)
			showPlate = not showPlate
			item.vars.des:setText(v2.desc)
			scr:addItem(item)
		end
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_baguaAffixHelp.new()
	wnd:create(layout, ...)
	return wnd
end