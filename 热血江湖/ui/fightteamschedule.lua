-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_fightTeamSchedule = i3k_class("wnd_fightTeamSchedule", ui.wnd_base)

function wnd_fightTeamSchedule:ctor()
	
end

function wnd_fightTeamSchedule:configure()
	self.ui = self._layout.vars
	self.ui.close_btn:onClick(self,self.onClose)
	self.ui.tab1:onClick(self,self.showTab1)
	self.ui.tab2:onClick(self,self.showTab2)
end

function wnd_fightTeamSchedule:refresh()
	self:showTab1()
end

function wnd_fightTeamSchedule:showTab1()
	self.ui.tab1:stateToPressed()
	self.ui.tab2:stateToNormal()
	
	self.ui.scroll:removeAllChildren()
	local season = g_i3k_game_context:getFightTeamSchedule()
	local strings = {}
	local item = require("ui/widgets/wudaohuismt")()
	local stage = g_i3k_game_context:getScheduleStage();
	for k,v in ipairs(i3k_db_fightTeam_explain) do
		local stringsIndex = 3*(k-1) + 1
		--开头标题
		local title = v.name .. "\n"
		if k == stage then 
			title = v.name .. i3k_get_string(1200) .. "\n"
		end
		strings[stringsIndex] = title
		local config = season[k+1]
		--内容
		if k == 1 then
			--开始
			local createTime = g_i3k_get_ActDateStr(season[1])
			local startString = 
				g_i3k_get_ActDateStr(config.startTime) 
				.."至" 
				..g_i3k_get_ActDateStr(config.endTime)
				..",每日"
				..g_i3k_get_show_short_time(config.dayStartTime)
				.."到"
				..g_i3k_get_show_short_time(config.dayEndTime)
			local choseString = g_i3k_get_show_time(config.resultTime)
			strings[stringsIndex+1] = string.format(v.explainDesc,createTime,startString,choseString)
		elseif k == 8 then
			--结束
			strings[stringsIndex+1] = string.format(v.explainDesc,g_i3k_get_show_time(season[k].resultTime))
		else
			local string1 = g_i3k_get_show_time(config.startJoinTime)
			local string2 = g_i3k_get_show_time(config.startFightTime)
			local string3 = g_i3k_get_show_time(config.resultTime)
			strings[stringsIndex+1] = string.format(v.explainDesc,string1,string2,string3)
		end
		strings[stringsIndex+2] = "\n\n"
	end

	g_i3k_ui_mgr:AddTask(self,{},function ()
		item.vars.text:setText(table.concat(strings));
		self.ui.scroll:addItem(item)
		g_i3k_ui_mgr:AddTask(self,{},function ()
			local innerSize = item.vars.text:getInnerSize()
			item.rootVar:changeSizeInScroll(self.ui.scroll,innerSize.width,innerSize.height,true)
		end)
	end)
end

function wnd_fightTeamSchedule:showTab2()
	self.ui.tab1:stateToNormal()
	self.ui.tab2:stateToPressed()
	self.ui.scroll:removeAllChildren()
	local item = require("ui/widgets/wudaohuismt")()
	g_i3k_ui_mgr:AddTask(self,{},function ()
		item.vars.text:setText(i3k_get_string(1201));
		self.ui.scroll:addItem(item)
		g_i3k_ui_mgr:AddTask(self,{},function ()
			local innerSize = item.vars.text:getInnerSize()
			item.rootVar:changeSizeInScroll(self.ui.scroll,innerSize.width,innerSize.height,true)
		end)
	end)
end

function wnd_fightTeamSchedule:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_FightTeamSchedule)
end

function wnd_create(layout, ...)
	local wnd = wnd_fightTeamSchedule.new()
	wnd:create(layout, ...)
	return wnd
end
