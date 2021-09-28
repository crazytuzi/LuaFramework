
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_MMRankDetail = i3k_class("wnd_MMRankDetail",ui.wnd_base)

function wnd_MMRankDetail:ctor()

end

function wnd_MMRankDetail:configure()
	self.ui = self._layout.vars
	self.ui.close_btn:onClick(self, self.onCloseUI)
end

function wnd_MMRankDetail:refresh(info, killTime)
	self.ui.scroll:removeAllChildren()
	for k, v in ipairs(info) do
		local wg = require("ui/widgets/shenjizanghaixytd2t")()
		local wgs = wg.vars
		local mbrInfo = v.rankRole.role
		local icon = {2718, 2719, 2720}
		
		wgs.name:setText(mbrInfo.name)
		if k > 3 then
			wgs.rankIcon:setVisible(false)
		wgs.rank:setText(k)
		else
			wgs.rankIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon[k]))
			wgs.rank:setText('')
		end
		wgs.lvl:setText(mbrInfo.level)
		wgs.killTime:setText(killTime)
		wgs.gang:setText(v.sectName)
		wgs.score:setText(v.rankRole.rankKey)
		self.ui.scroll:addItem(wg)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_MMRankDetail.new()
	wnd:create(layout, ...)
	return wnd;
end

