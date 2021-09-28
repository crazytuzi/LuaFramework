-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_taoist_logs = i3k_class("wnd_taoist_logs", ui.wnd_base)

function wnd_taoist_logs:ctor()
	
end

function wnd_taoist_logs:configure()
	self._layout.vars.close:onClick(self, self.onClose)
end

function wnd_taoist_logs:onShow()
	
end

function wnd_taoist_logs:refresh(logs)
	table.sort(logs, function (a, b)
		return a.time>b.time
	end)
	local scroll = self._layout.vars.scroll
	if scroll and logs then
		scroll:removeAllChildren()
		local count = #logs
		for i=1, count do
			local logsBar = require("ui/widgets/11jjzbt")()
			local overTime = g_i3k_logic:GetCurrentTimeStamp(tonumber(logs[i].time))
			local timeNow = g_i3k_get_GMTtime(i3k_game_get_time())
			local disTime = math.floor((timeNow - overTime)/60)
			local time
			if disTime==0 then
				time = "刚刚"
			else
				time = disTime.." 分钟前"
				disTime = math.floor(disTime/60)
				if disTime>=1 then
					time = disTime.." 小时前"
					disTime = math.floor(disTime/24)
					if disTime>=1 then
						time = disTime.." 天前"
						disTime = math.floor(disTime/30)
						if disTime>=1 then
							time = disTime.." 月前"
							disTime = math.floor(disTime/12)
							if disTime>=1 then
								time = disTime.." 年前"
							end
						end
					end
				end
			end
			
			local myInfo = g_i3k_game_context:GetRoleInfo()
			local myId = myInfo.curChar._id
			local win = logs[i].win == 1
			local isWin = true
			local enemySide = nil
			if win then
				if logs[i].attackingSide.role.overview.id == myId then
					isWin = true
					logs[i].isWin = true
				else
					isWin = false
					logs[i].isWin = false
				end
			else
				if logs[i].attackingSide.role.overview.id == myId then
					isWin = false
					logs[i].isWin = false
				else
					isWin = true
					logs[i].isWin = true
				end
			end
			if logs[i].attackingSide.role.overview.id == myId then
				enemySide = logs[i].defendingSide
			else
				enemySide = logs[i].attackingSide
			end
			if isWin then
				logsBar.vars.markImg:setImage(i3k_db_icons[416].path)
				logsBar.vars.word:setText("胜利阵容")
			else
				logsBar.vars.markImg:setImage(i3k_db_icons[417].path)
				logsBar.vars.word:setText("失败阵容")
			end
			local hicon = g_i3k_db.i3k_db_get_head_icon_ex(enemySide.role.overview.headIcon, g_i3k_db.eHeadShapeCircie)
			if hicon and hicon > 0 then
				logsBar.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
			end
			logsBar.vars.level:setText(enemySide.role.overview.level)
			logsBar.vars.name:setText(enemySide.role.overview.name)
			logsBar.vars.lineup:setTag(i)
			logsBar.vars.lineup:onClick(self, self.checkLineup, logs)
			logsBar.vars.timeLabel:setText(time)
			scroll:addItem(logsBar)
		end
	end
end

function wnd_taoist_logs:checkLineup(sender, logs)
	local index = sender:getTag()
	g_i3k_ui_mgr:OpenUI(eUIID_ArenaCheckLineup)
	g_i3k_ui_mgr:RefreshUI(eUIID_ArenaCheckLineup, logs[index])
end

function wnd_taoist_logs:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_TaoistLogs)
end

function wnd_create(layout, ...)
	local wnd = wnd_taoist_logs.new()
	wnd:create(layout, ...)
	return wnd;
end
