-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_activityCalendarDetail = i3k_class("wnd_activityCalendarDetail", ui.wnd_base)

function wnd_activityCalendarDetail:ctor()
	self_content = nil;
end

function wnd_activityCalendarDetail:configure()
	local vars = self._layout.vars
	vars.imgBK:onClick(self,self.onClose)
	self._content = {
		title = vars.title,
		mapInfo = vars.desc,
		npcInfo = vars.des2,
		exNpcInfo = vars.des3
	}
end

function wnd_activityCalendarDetail:getNpcName(id)
	local npcConfig = i3k_db_npc[id] 
	if npcConfig then
		return npcConfig.remarkName
	end
	return i3k_get_string(15443)
end

function wnd_activityCalendarDetail:getMapName(id)
	local mapConfig = i3k_db_dungeon_base[id]
	if mapConfig then
		return mapConfig.name
	end
	return i3k_get_string(15444)
end

function wnd_activityCalendarDetail:refresh(data)
	self._content.title:setText(data.name)
	self._content.mapInfo:setText(i3k_get_string(15440, self:getMapName(data.worldMapID)));
	self._content.npcInfo:setText(i3k_get_string(15441, self:getNpcName(data.enterNPC)));
	self._content.exNpcInfo:setText(i3k_get_string(15442, self:getNpcName(data.rewardNPC)));
end

function wnd_activityCalendarDetail:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_Activity_CalendarDetail)
end

function wnd_create(layout, ...)
	local wnd = wnd_activityCalendarDetail.new()
		wnd:create(layout, ...)
	return wnd
end