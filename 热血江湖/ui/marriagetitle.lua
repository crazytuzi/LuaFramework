
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_marriageTitle = i3k_class("wnd_marriageTitle",ui.wnd_base)

function wnd_marriageTitle:ctor()
	self.allItems = nil
end

function wnd_marriageTitle:configure()
	local widgets = self._layout.vars
	widgets.helpBtn:onClick(self, self.help)
	widgets.close:onClick(self, self.onCloseUI)
	self.scroll = widgets.scroll
	self.allItems = nil
end

function wnd_marriageTitle:refresh()
	local marryTime = g_i3k_game_context:getRecordMarryTime()
	local hadTitle = g_i3k_game_context:GetAllRoleTitle()
	local tcfg = i3k_db_marry_title
	local tbasecfg = i3k_db_title_base
	if not self.allItems then
		self.allItems = self.scroll:addChildWithCount("ui/widgets/yycht", 2, #i3k_db_marry_title)
	end
	for index, item in ipairs(self.allItems) do
		local widgets = item.vars
		local cfg = tcfg[index]
		widgets.titleImg:setImage(g_i3k_db.i3k_db_get_icon_path(tbasecfg[cfg.id].iconbackground))
		
		local day = math.modf(cfg.time/86400)
		if i3k_game_get_time() >= marryTime + cfg.time then
			widgets.conditionTxt:setText(i3k_get_string(16363,"<c=green>"..day.."</c>"))
			widgets.getBtn:onClick(self, self.getTitle, cfg.id)
			widgets.getBtn:show()
			widgets.striveImg:hide()
		else
			widgets.conditionTxt:setText(i3k_get_string(16363,"<c=red>"..day.."</c>"))
			widgets.getBtn:hide()
			widgets.striveImg:show()
		end
		if hadTitle[cfg.id]~=nil then
			widgets.getBtn:hide()
			widgets.getImg:setVisible(true)
		else
			widgets.getImg:setVisible(false)
		end
	end
end

function wnd_marriageTitle:getTitle(sender, title)
	i3k_sbean.take_marriage_titleReq(title)
end

function wnd_marriageTitle:help()
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(16360))
end

function wnd_create(layout, ...)
	local wnd = wnd_marriageTitle.new()
	wnd:create(layout, ...)
	return wnd;
end

