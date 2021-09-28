-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_dungeon_fenpei = i3k_class("wnd_faction_dungeon_fenpei", ui.wnd_base)

local LAYER_BFFPBT = "ui/widgets/bffpbt"

function wnd_faction_dungeon_fenpei:ctor()
	
end



function wnd_faction_dungeon_fenpei:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.record_scroll = self._layout.vars.record_scroll 
end

function wnd_faction_dungeon_fenpei:onShow()
	
end

function wnd_faction_dungeon_fenpei:refresh(data)
	self:setData(data)
end 

function wnd_faction_dungeon_fenpei:setData(data)
	
	self.record_scroll:removeAllChildren()
	for k,v in pairs(data) do
		local _layer = require(LAYER_BFFPBT)()
		local item_bg = _layer.vars.item_bg 
		local item_icon = _layer.vars.item_icon 
		local time_label = _layer.vars.time_label 
		local name = _layer.vars.name 
		name:setText(v.roleName)
		
		item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.rewardId))
		item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.rewardId,i3k_game_context:IsFemaleRole()))
		time_label:setText(self:getTimeStr(g_i3k_get_GMTtime(v.time)))
		self.record_scroll:addItem(_layer)
	end
end

function wnd_faction_dungeon_fenpei:getTimeStr(TimeCount)
	local m = os.date("%m",TimeCount)
	local d = os.date("%d",TimeCount)
	local h = os.date("%H",TimeCount)
	local min = os.date("%M",TimeCount)
	
	return string.format("%s-%s %s:%s",m,d,h,min)
end 

--[[function wnd_faction_dungeon_fenpei:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionDungeonFenpei)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_faction_dungeon_fenpei.new();
		wnd:create(layout, ...);

	return wnd;
end

