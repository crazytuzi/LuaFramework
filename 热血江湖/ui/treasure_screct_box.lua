-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_screct_box = i3k_class("wnd_screct_box", ui.wnd_base)

function wnd_screct_box:ctor()
	
end

function wnd_screct_box:configure()
	self._needItems = nil
end

function wnd_screct_box:onShow()
	
end

function wnd_screct_box:refresh(spotIndex, needItems)
	self._layout.vars.close:onClick(self, function ()
		g_i3k_ui_mgr:CloseUI(eUIID_TreasureScrectBox)
	end)
	self._needItems = needItems
	
	self:loadNeedItems()
	
	
	local needItemTable = {}
	for i,v in ipairs(needItems) do
		needItemTable[v.id] = v.count
	end
	self._layout.vars.openBtn:setTag(spotIndex)
	self._layout.vars.openBtn:onClick(self, self.openScrectBox, needItemTable)
	
end

function wnd_screct_box:loadNeedItems()
	local widgets = self._layout.vars
	local needItemWidget = {
		[1] = {gradeIcon = widgets.gradeIcon1, icon = widgets.icon1, btn = widgets.btn1, countLabel = widgets.countLabel1},
		[2] = {gradeIcon = widgets.gradeIcon2, icon = widgets.icon2, btn = widgets.btn2, countLabel = widgets.countLabel2},
	}
	local needItems = self._needItems
	
	self._isEnough = true
	for i,v in pairs(needItemWidget) do
		local needId = needItems[i].id
		v.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(needId))
		v.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needId,i3k_game_context:IsFemaleRole()))
		local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(needId)
		v.countLabel:setText(string.format("%d/%d", canUseCount, needItems[i].count))
		v.countLabel:setTextColor(g_i3k_get_cond_color(needItems[i].count<=canUseCount))
		if needItems[i].count>canUseCount then
			self._isEnough = false
		end
		v.btn:onClick(self, function ()
			g_i3k_ui_mgr:ShowCommonItemInfo(needId)
		end)
	end
end

function wnd_screct_box:openScrectBox(sender, items)
	if self._isEnough then
		local index = sender:getTag()
		local callback = function()
			for i,v in pairs(items) do
				g_i3k_game_context:UseCommonItem(i, v,AT_LOG_TREASURE_TASK)
			end
			g_i3k_ui_mgr:CloseUI(eUIID_TreasureScrectBox)
		end
		i3k_sbean.explore_spot(index, callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15079))
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_screct_box.new()
	wnd:create(layout, ...)
	return wnd;
end