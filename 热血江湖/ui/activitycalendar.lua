-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_activityCalendar = i3k_class("wnd_activityCalendar", ui.wnd_base)

local SHOW_DAYS = 7
function wnd_activityCalendar:ctor()
	self._content = {};
	local l = os.date("*t", g_i3k_get_GMTtime(i3k_game_get_time()))
	l = os.time({year = l.year, month = l.month, day = l.day, hour = 0, min = 0, sec = 0})
	self._line = l + 24 * 60 * 60
end

function wnd_activityCalendar:configure()
	local vars = self._layout.vars
	vars.imgBK:onClick(self,self.onClose)
	for i = 1, SHOW_DAYS do
		table.insert(self._content,{title = vars["title" .. i], scroll = vars["scroll" .. i]})
	end
end

function wnd_activityCalendar:refresh()
	local days = g_i3k_db.i3k_db_get_calendar_activity()

	for i = 1, SHOW_DAYS do
	
		local content = self._content[i]
		local date = os.date("*t", days[i].date)
		if date and content then 
			content.scroll:removeAllChildren()
			content.title:setText(i3k_get_string(15438, date.month, date.day, g_week_days[date.wday - 1]))
			local cfg = days[i].activitys
			for _, v in ipairs(cfg) do
				local item = require("ui/widgets/rilit" .. (v.isHoliday == 1 and "2" or "" ))()
				if v.cornerMark == 0 then
							item.vars.pvp:setVisible(false)
						else
					item.vars.pvp:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_schedule.cornerMarkIcon[v.cornerMark]))
						end
				item.vars.name:setText(v.name)
				if v.actTime == "-1.0" then
					item.vars.time:setText(i3k_get_string(621))
				else
				local beginTime = string.split(v.actTime, ';')
				for k, v in ipairs(beginTime) do
					v = string.split(v, ':')
					beginTime[k] = string.format("%s:%s", v[1], v[2])
				end
				item.vars.time:setText(i3k_get_string(15439,beginTime[1] ,beginTime[2]))
				end
				item.vars.select1_btn:onClick(self,self.onShowDetail,v)
						content.scroll:addItem(item)
			end
		end
	end
end

function wnd_activityCalendar:onShowDetail(sender, detail)
	g_i3k_ui_mgr:OpenUI(eUIID_Activity_CalendarDetail)
	g_i3k_ui_mgr:RefreshUI(eUIID_Activity_CalendarDetail, detail)
end

function wnd_activityCalendar:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_Activity_Calendar)
end

function wnd_activityCalendar:onUpdate()
	if g_i3k_get_GMTtime(i3k_game_get_time()) >= self._line then
		self._line = self._line + 24 * 60 * 60
		self:refresh()
	end
end
function wnd_create(layout, ...)
	local wnd = wnd_activityCalendar.new()
	wnd:create(layout, ...)
	return wnd
end