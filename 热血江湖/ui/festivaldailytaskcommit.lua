--装扮圣诞树，提交任务道具。

-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require('ui/base')

-------------------------------------------------------
wnd_festivalDailyTaskCommit = i3k_class('wnd_festivalDailyTaskCommit', ui.wnd_base)


local WIDGETITEM = "ui/widgets/jierirwt"

function wnd_festivalDailyTaskCommit:ctor()
	self.commitCount = 0
	self.commitItems = {}
end

function wnd_festivalDailyTaskCommit:configure()
	local widgets = self._layout.vars
	
	widgets.ok:onClick(self, self.onOkButton)
	widgets.cancel:onClick(self, self.onCloseUI)
	widgets.close_btn:onClick(self, self.onCloseUI)
end
function wnd_festivalDailyTaskCommit:refresh()
	self:localScroll()
end

function wnd_festivalDailyTaskCommit:localScroll()
	
	self._layout.vars.scroll:removeAllChildren()
	
	for k, v in pairs(i3k_db_new_festival_commit_Items) do
		local node = require(WIDGETITEM)()
		local itemID = v.itemId
		local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
		node.vars.count:setText("x"..haveCount)
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID))
		node.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
		node.vars.suo:setVisible(itemID > 0)
		node.vars.btn:onClick(self, self.onItemTip, itemID)
		self._layout.vars.scroll:addItem(node)
		
		if haveCount > 0 then 
			table.insert(self.commitItems, k, haveCount)
			self.commitCount = self.commitCount + 1
		end
	end
end

function wnd_festivalDailyTaskCommit:onItemTip(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_festivalDailyTaskCommit:onOkButton()
	if not g_i3k_db.i3k_db_is_in_new_festival_task() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(19078))
        g_i3k_ui_mgr:CloseUI(eUIID_FestivalTaskCommit)
        g_i3k_ui_mgr:CloseUI(eUIID_FestivalActivityUI)
		return
	end
	if self.commitCount > 0 then 
		i3k_sbean.new_festival_activity_donate(self.commitItems)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18994))
	end
end


function wnd_create(layout, ...)
	local wnd = wnd_festivalDailyTaskCommit.new()
	wnd:create(layout, ...)
	return wnd;
end
