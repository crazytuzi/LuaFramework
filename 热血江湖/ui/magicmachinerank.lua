
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_MMRank = i3k_class("wnd_MMRank",ui.wnd_base)

function wnd_MMRank:ctor()

end

function wnd_MMRank:configure()
	self.ui = self._layout.vars
	self.ui.close_btn:onClick(self, self.onCloseUI)
end

function wnd_MMRank:refresh(teamInfos)
	self.ui.scroll:removeAllChildren()
	for k, v in ipairs(teamInfos) do	
		local wg = require("ui/widgets/shenjizanghaixytdt")()
		local wgs = wg.vars
		local time = ''
		if v.killTime > 0 then
			time = g_i3k_db.i3k_db_get_format_time(g_i3k_get_GMTtime(v.killTime))
		end
		
		wgs.order:setText(k)
		wgs.mbrCnt:setText(#v.members)	--团队人数
		wgs.mapLvl:setText(v.grade)
		wgs.killed:setText(v.killTime > 0 and '是' or '否')
		wgs.time:setText(time)
		wgs.detail:onClick(self, function()
			g_i3k_ui_mgr:OpenUI(eUIID_MMRankDetail)
			g_i3k_ui_mgr:RefreshUI(eUIID_MMRankDetail, v.members, time)
		end)
		self.ui.scroll:addItem(wg)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_MMRank.new()
	wnd:create(layout, ...)
	return wnd;
end
